/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenX
 *  $VERSION      1.12 (8-4-2009 20:08)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen controller extension plugin.
 *
 **************************************************************************************************/
class NexgenX extends NexgenPlugin;

var int versionNum;                     // Plugin version number.

var NexgenXLang lng;                    // Language instance to support localization.
var NexgenXConfig xConf;                // Plugin configuration.
var NexgenXUpdateChecker xUpdate;       // Nexgen update checker.
var NexgenXMapList maps;                // Maps available on the server.

var bool bIsOptimized;                  // Is the performance of the server optimized?

// Message control.
var string lastMessage;                 // Last send chat message.
var float lastMessageTimeStamp;         // Time stamp of last send chat message.
var PlayerPawn lastMessageSender;       // Sender of the last message.
var bool lastMessageWasSpam;            // Whether the last send message was spam.

// Settings.
const optimizerRunDelay = 5.0;          // Number of seconds to wait before running the optimizer.

// Extra player attributes.
const PA_Score = "score";               // Score / frag count.
const PA_Deaths = "deaths";             // Number of times the player died.
const PA_StartTime = "starttime";       // Time at which the player joined the game.

// Misc constants.
const CMD_SmartCTFToggleStats = "smartctf stats";
const CMD_AKAClientIDLog = "aka info";
const CMD_GarbageCollect = "obj garbage";
const separator = ",";



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {
	local Actor a;
	
	// Load localization support.
	lng = spawn(class'NexgenXLang');
	
	// Load settings.
	if (control.bUseExternalConfig) {
		xConf = spawn(class'NexgenXConfigExt', self);
	} else {
		xConf = spawn(class'NexgenXConfigSys', self);
	}
	xConf.install();
	if (!xConf.validate()) {
		control.nscLog(lng.invalidConfigMsg);
	}
	xConf.initialize();
	
	// Set panel classes.
	control.sConf.matchControlPanelClass = class'NexgenXRCPMatchControl';
	
	// Load update checker.
	if (xConf.checkForUpdates) {
		xUpdate = spawn(class'NexgenXUpdateChecker');
	}
	
	// Load map list.
	maps = spawn(class'NexgenXMapList', self);
	maps.loadLocalMaps();
	
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a new client has been created. Use this function to setup the new
 *                client with your own extensions (in order to support the plugin).
 *  $PARAM        client  The client that was just created.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function clientCreated(NexgenClient client) {
	local NexgenXClient xClient;
	
	xClient = NexgenXClient(client.addController(class'NexgenXClient', self));
	
	xClient.xConf = xConf;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever the login request of a player has been rejected and allows the
 *                plugin to modify the behaviour.
 *  $PARAM        client            The client that was denied access to the server.
 *  $PARAM        rejectType        Reject type identification code.
 *  $PARAM        reason            Reason why the player was rejected from the server.
 *  $PARAM        popupWindowClass  Class name of the popup window that is to be shown at the client.
 *  $PARAM        popupArgs         Optional arguments for the popup window. Note you may have to
 *                                  explicitly reset them if you change the popupWindowClass.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function modifyLoginReject(NexgenClient client, out name rejectType, out string reason,
                           out string popupWindowClass, out string popupArgs[4]) {
	local int index;
	local bool bFound;
	
	if (rejectType == control.RT_ServerFull && xConf.enableFullServerRedirect) {
		
		// Check if an alternate server is specified.
		while (!bFound && index < arrayCount(xConf.redirectURL)) {
			if (class'NexgenUtil'.static.trim(xConf.redirectURL[index]) != "") {
				bFound = true;
			} else {
				index++;
			}
		}
		
		// Alternate server found, modify login reject.
		if (bFound) {
			if (xConf.enableAutoRedirect) {
				popupWindowClass = string(class'NexgenXAutoRedirectDialog');
				popupArgs[0] = xConf.redirectServerName[index];
				popupArgs[1] = xConf.redirectURL[index];
				popupArgs[2] = "";
				popupArgs[3] = "";
			} else {
				popupWindowClass = string(class'NexgenXServerFullDialog');
				popupArgs[0] = xConf.fullServerRedirectMsg;
				popupArgs[1] = class'NexgenUtil'.static.replace(xConf.redirectServerName[0], separator, "") $ separator $ xConf.redirectURL[0];
				popupArgs[2] = class'NexgenUtil'.static.replace(xConf.redirectServerName[1], separator, "") $ separator $ xConf.redirectURL[1];
				popupArgs[3] = class'NexgenUtil'.static.replace(xConf.redirectServerName[2], separator, "") $ separator $ xConf.redirectURL[2];
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a player has joined the game (after its login has been accepted).
 *  $PARAM        client  The player that has joined the game.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerJoined(NexgenClient client) {
	local NexgenXClient xClient;
	
	// Spawn player overlay for the client.
	if (control.gInf.gameState == control.gInf.GS_Playing && !client.bSpectator) {
		xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
		if (xConf.enableOverlaySkin) xClient.setPlayerOverlay();
	}
	
	// Restore saved player data.
	client.player.playerReplicationInfo.score = client.pDat.getFloat(PA_Score, client.player.playerReplicationInfo.score);
	client.player.playerReplicationInfo.deaths = client.pDat.getFloat(PA_Deaths, client.player.playerReplicationInfo.deaths);
	client.player.playerReplicationInfo.startTime = client.pDat.getInt(PA_StartTime, client.player.playerReplicationInfo.startTime);
	
	// Make AKA log the client id.
	if (xConf.enableClientIDAKALog) {
		client.player.mutate(CMD_AKAClientIDLog @ client.playerID);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called if a player has left the server.
 *  $PARAM        client  The player that has left the game.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerLeft(NexgenClient client) {
	local NexgenXClient xClient;
	
	// Get extended client controller.
	xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
	
	// Remove player overlay.
	xClient.setPlayerOverlay(true);
	
	// Store saved player data.
	client.pDat.set(PA_Score, client.player.playerReplicationInfo.score);
	client.pDat.set(PA_Deaths, client.player.playerReplicationInfo.deaths);
	client.pDat.set(PA_StartTime, client.player.playerReplicationInfo.startTime);
	
	// Flag server as not optimized.
	bIsOptimized = false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game has started.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function gameStarted() {
	local NexgenClient client;
	local NexgenXClient xClient;
	
	// Spawn player overlays for client that haven't received one yet.
	if (xConf.enableOverlaySkin) {
		for (client = control.clientList; client != none; client = client.nextClient) {
			xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
			xClient.setPlayerOverlay();
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game has ended.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function gameEnded() {
	local NexgenClient client;
	local NexgenXClient xClient;
	
	// Destroy player overlays.
	for (client = control.clientList; client != none; client = client.nextClient) {
		xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
		xClient.setPlayerOverlay(true);
	}
	
	// Fix infinite loop in viewPlayerNum() caused by spectators at the end of the match.
	fixSpecatorViewPlayerNumBug();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called to check if the specified message should be send to the given receiver.
 *  $PARAM        sender    The actor that has send the message.
 *  $PARAM        receiver  Pawn receiving the message.
 *  $PARAM        msg       The message that is to be send.
 *  $PARAM        bBeep     Whether or not to make a beep sound once received.
 *  $PARAM        type      Type of the message that is to be send.
 *  $RETURN       True if the message should be send, false if it should be suppressed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool mutatorBroadcastMessage(Actor sender, Pawn receiver, out coerce string msg,
                                      optional bool bBeep, out optional name type) {
	local PlayerReplicationInfo senderPRI;
	local bool isChatMessage;
	local bool bSuppressMessage;

	// Get sender player replication info.
	if (sender != none && sender.isA('Pawn')) {
		senderPRI = Pawn(sender).playerReplicationInfo;
	}
	
	// Check if the current message is a chat message.
	isChatMessage = senderPRI != none && sender.isA('Spectator') &&
	                left(msg, len(senderPRI.playerName) + 1) ~= (senderPRI.playerName $ ":");
	
	// Handle new chat messages.
	if (isChatMessage && isNewChatMessage(PlayerPawn(sender), msg)) {
		handleNewChatMessage(PlayerPawn(sender), right(msg, len(msg) - len(senderPRI.playerName) - 1));
	}

	// Suppress message in case of spam.
	bSuppressMessage = bSuppressMessage || isChatMessage && lastMessageWasSpam;
	
	// Indicate whether the message should be suppressed or not.
	return !bSuppressMessage;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called to check if the specified team message should be send to the given
 *                receiver.
 *                is called if a message is send to player.
 *  $PARAM        sender    The actor that has send the message.
 *  $PARAM        receiver  Pawn receiving the message.
 *  $PARAM        pri       Player replication info of the sending player.
 *  $PARAM        s         The message that is to be send.
 *  $PARAM        type      Type of the message that is to be send.
 *  $PARAM        bBeep     Whether or not to make a beep sound once received.
 *  $RETURN       True if the message should be send, false if it should be suppressed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool mutatorTeamMessage(Actor sender, Pawn receiver, PlayerReplicationInfo pri,
                                 coerce string s, name type, optional bool bBeep) {
	local bool isChatMessage;
	local bool bSuppressMessage;
	
	// Check if the current message is a chat message.
	isChatMessage = sender != none && sender.isA('PlayerPawn') && (type == 'Say' || type == 'TeamSay');

	// Handle new chat messages.
	if (isChatMessage && isNewChatMessage(PlayerPawn(sender), s)) {
		handleNewChatMessage(PlayerPawn(sender), s);
	}
	
	// Suppress message in case of spam.
	bSuppressMessage = bSuppressMessage || isChatMessage && lastMessageWasSpam;
	
	// Indicate whether the message should be suppressed or not.
	return !bSuppressMessage;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified message is a new message.
 *  $PARAM        sender  PlayerPawn that has send the message in question.
 *  $PARAM        msg     Message send by the player.
 *  $RETURN       True if this is a new chat message, false if not.
 *
 **************************************************************************************************/
function bool isNewChatMessage(PlayerPawn sender, string msg) {
	local bool bIsNew;
	
	// Check if this is a new message.
	bIsNew = lastMessage != msg ||
	         lastMessageTimeStamp != level.timeSeconds ||
	         lastMessageSender != sender;
	
	// Store message info if this is a new message.
	if (bIsNew) {
		lastMessage = msg;
		lastMessageTimeStamp = level.timeSeconds;
		lastMessageSender = sender;
	}
	
	// Return result.
	return bIsNew;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Chat message handler procedure.
 *  $PARAM        sender  PlayerPawn that has send the message in question.
 *  $PARAM        msg     Message send by the player.
 *
 **************************************************************************************************/
function handleNewChatMessage(PlayerPawn sender, string msg) {
	local NexgenXClient xClient;
	
	// Get extended client controller.
	xClient = getXClient(sender);
	
	// Stuff that needs the extended client controller.
	if (xClient != none) {
		
		// Spam detection.
		if (xConf.enableAntiSpam) {
			// Check if message is spam.
			lastMessageWasSpam = xClient.isSpam(msg);
			
			if (!lastMessageWasSpam) {
				// Store message for future spam detection.
				xClient.addMessage(msg);
			} else {
				// Notify client.
				xClient.notifyClientSpam();
			}
		} else {
			lastMessageWasSpam = false;
		}
		
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles a potential command message.
 *  $PARAM        sender  PlayerPawn that has send the message in question.
 *  $PARAM        msg     Message send by the player, which could be a command.
 *  $REQUIRE      sender != none
 *  $RETURN       True if the specified message is a command, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool handleMsgCommand(PlayerPawn sender, string msg) {
	local string cmd;
	local bool bIsCommand;
	local NexgenXClient xClient;
	
	cmd = class'NexgenUtil'.static.trim(msg);
	bIsCommand = true;
	switch (cmd) {
		case "!stats": level.game.baseMutator.mutate(CMD_SmartCTFToggleStats, sender); break;
		case "!rules":
			if (xConf.enableServerRules) {
				xClient = getXClient(sender);
				if (xClient != none) {
					xClient.showRules();
				}
			}
			break;

		// Not a command.
		default: bIsCommand = false;
	}
	
	return bIsCommand;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the clients that a certain part of the server configuration has changed.
 *  $PARAM        configType  Type of settings that have been changed.
 *  $ENSURE       new.xConf.updateCount = old.xConf.updateCount + 1
 *
 **************************************************************************************************/
function signalConfigUpdate(byte configType) {
	local NexgenClient client;
	local NexgenXClient xClient;
	local int index;
	
	// Set update counter.
	xConf.updateCounts[configType]++;
	
	// Update checksum.
	xConf.updateChecksum(configType);
	
	// Notify clients.
	for (client = control.clientList; client != none; client = client.nextClient) {
		xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
		if (xClient != none) {
			xClient.nexgenXConfigChanged(configType, xConf.updateCounts[configType], xConf.dynamicChecksums[configType]);
		}
	}
	
	// Notify plugins.
	while (index < arrayCount(control.plugins) && control.plugins[index] != none) {
		control.plugins[index].notifyEvent(xConf.EVENT_NexgenXConfigChanged, string(configType));
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the NexgenXClient instance for the given actor.
 *  $PARAM        a  The actor for which the extended client handler instance is to be found.
 *  $REQUIRE      a != none
 *  $RETURN       The client handler for the given actor.
 *  $ENSURE       (!a.isA('PlayerPawn') ? result == none : true) &&
 *                imply(result != none, result.client.owner == a)
 *
 **************************************************************************************************/
function NexgenXClient getXClient(Actor a) {
	local NexgenClient client;
	
	client = control.getClient(a);
	
	if (client == none) {
		return none;
	} else {
		return NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixes the bug in UT that cases the server to crash when a spectator does a
 *                viewPlayerNum(-1) call when the game is ended.
 *
 **************************************************************************************************/
function fixSpecatorViewPlayerNumBug() {
	local Pawn p;
	
	for (p = level.pawnList; p != none; p = p.nextPawn) {
		if (p.isA('CHSpectator')) {
			CHSpectator(p).viewTarget = none;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the remaining time for the current game at all connected clients.
 *  $PARAM        remainingTime  The new remaining time.
 *
 **************************************************************************************************/
function announceNewRemainingTime(int remainingTime) {
	local NexgenClient currClient;
	local NexgenXClient currXClient;
	
	for (currClient = control.clientList; currClient != none; currClient = currClient.nextClient) {
		currXClient = NexgenXClient(currClient.getController(class'NexgenXClient'.default.ctrlID));
		if (currXClient != none) {
			currXClient.updateRemainingTime(remainingTime);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a client is attempting to login. This allows to plugin to accept or
 *                reject the login request. If the function returns false the login request will be
 *                rejected (player will be disconnected). Please make sure the reason parameter
 *                is set in that case, as it will be written to the log.
 *  $PARAM        client      Client that is requesting to login to the server.
 *  $PARAM        rejectType  Reject type identification code.
 *  $PARAM        reason      Message describing why the login is rejected.
 *  $PARAM        popupWindowClass  Class name of the popup window that is to be shown at the client.
 *  $PARAM        popupArgs         Optional arguments for the popup window. Note you may have to
 *                                  explicitly reset them if you change the popupWindowClass.
 *  $REQUIRE      client != none
 *  $RETURN       True if the login request is accepted, false if it should be rejected.
 *  $ENSURE       result == false ? new.reason != "" : true
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool checkLogin(NexgenClient client, out name rejectType, out string reason,
                         out string popupWindowClass, out string popupArgs[4]) {
	local bool bRejected;
	local int index;
	local string playerName;
	local string tag;
	
	// Check if the client uses a protected tag and is not allowed to do so.
	if (xConf.enableTagProtection && !client.bHasAccount) {
		if (containsProtectTag(client.playerName, tag)) {
			bRejected = true;
			reason = lng.protectedTagLoginRejectMsg;
			popupWindowClass = string(class'NexgenXTagRejectDialog');
			popupArgs[0] = tag;
		}
	}
	
	// Return result.
	return !bRejected;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deals with a client that has changed his or her name.
 *  $PARAM        client             The client that has changed name.
 *  $PARAM        oldName            The old name of the player.
 *  $PARAM        bWasForcedChanged  Whether the name change was forced by the controller.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerNameChanged(NexgenClient client, string oldName, bool bWasForcedChanged) {
	local int index;
	local string playerName;
	local string tag;
	
	// Check if the client uses a protected tag and is not allowed to do so.
	if (xConf.enableTagProtection && !client.bHasAccount && !bWasForcedChanged) {
		if (containsProtectTag(client.playerName, tag)) {
			client.changeName(oldName); // Reset to old name.
			client.showMsg(client.lng.format(lng.tagNotAllowedMsg, tag));
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified player name contains a protected tag.
 *  $PARAM        playerName    The name of the player that is to be checked for protected tags.
 *  $PARAM        protectedTag  The protected tag that was found in the name of the player.
 *  $RETURN       True if a protected tag was found in the players name, false if not.
 *
 **************************************************************************************************/
function bool containsProtectTag(string playerName, out string protectedTag) {
	local bool bFound;
	local int index;
	
	// Format player name.
	playerName = caps(playerName);
	
	// Check for each tag if the name contains the tag.
	while (!bFound && index < arrayCount(xConf.tagsToProtect)) {
		// Uses protected tag?
		if (xConf.tagsToProtect[index] != "" &&
		    instr(playerName, caps(xConf.tagsToProtect[index])) >= 0) {
			// Yes, protected tag is a substring of the players name.
			bFound = true;
			protectedTag = xConf.tagsToProtect[index];
		} else {
			// Nope, check next protected tag.
			index++;
		}
	}
	
	// Retun result.
	return bFound;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a client has finished its initialisation process. During this
 *                process things such as the remote control window are created. So only after the
 *                client is fully initialized all functions can be safely called.
 *  $PARAM        client  The client that has finished initializing.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function clientInitialized(NexgenClient client) {
	local NexgenXClient xClient;
	
	// Notify server admin of a Nexgen update if available.
	if (xConf.checkForUpdates && xUpdate != none && xUpdate.bUpdateAvailable &&
	    client.hasRight(client.R_ServerAdmin)) {
		xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
		if (xClient != none) {
			xClient.notifyUpdateAvailable(xUpdate.latestVersion);
		}
	}
	
	// Show rules message.
	if (xConf.enableServerRules) {
		client.showMsg(lng.viewRulesClientMsg);
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game is executing it's first tick.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function firstTick() {
	if (xConf.enablePerformanceOptimizer) {
		runServerOptimizer();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Runs the server performance optimizer.
 *
 **************************************************************************************************/
function runServerOptimizer() {
	if (!bIsOptimized) {
		consoleCommand(CMD_GarbageCollect);
		bIsOptimized = true;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Plugin timer driven by the Nexgen controller. Ticks at a frequency of 1 Hz and is
 *                independent of the game speed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function virtualTimer() {
	// Optimize server performance.
	if (xConf.enablePerformanceOptimizer &&
	    control.clientList == none &&
	    control.timeSeconds - control.lastPlayerLeftTime > optimizerRunDelay &&
	    control.gInf.gameState != control.gInf.GS_Ended &&
	    !bIsOptimized) {
		runServerOptimizer();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	pluginName="Nexgen extension pack"
	pluginAuthor="Zeropoint"
	pluginVersion="1.12 build 1043"
	versionNum=112
}