/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPMain
 *  $VERSION      1.09 (18-12-2010 13:07:45)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen Plus extension package plugin.
 *
 **************************************************************************************************/
class NXPMain extends NexgenExtendedPlugin;

var NXPLang lng;                                  // Language instance to support localization.

var bool mapSwitchAutoDisplayChecked;             // Indicates that the condition for automatically
                                                  // opening the map switch tab was passed.
var bool mapSwitchOpened;                         // Whether the map switch tab has been opened.
var int originalRestartWait;                      // Original value of restart wait.
var bool enablePlayerOverlay;                     // Whether the player overlay skin should be enabled.
var int latestNexgenVersion;                      // Latest available version of Nexgen.

// Message control.
var string lastMessage;                           // Last send chat message.
var float lastMessageTimeStamp;                   // Time stamp of last send chat message.
var PlayerPawn lastMessageSender;                 // Sender of the last message.
var bool lastMessageWasSpam;                      // Whether the last send message was spam.

// Extra player attributes.
const PA_Score = "score";                         // Score / frag count.
const PA_Deaths = "deaths";                       // Number of times the player died.
const PA_StartTime = "starttime";                 // Time at which the player joined the game.

// Misc constants.
const CMD_SmartCTFToggleStats = "smartctf stats";
const CMD_AKAClientIDLog = "aka info";
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
	// Load localization support.
	lng = spawn(class'NXPLang');
	
	// Let super class initialize.
	if (!super.initialize()) {
		return false;
	}
	
	// Set panel classes.
	control.sConf.matchControlPanelClass = class'NXPMatchControlRCP';
	
	// Check if the overlay skin should be enabled.
	enablePlayerOverlay = (
		NXPConfig(xConf).showDamageProtectionShield ||
		NXPConfig(xConf).colorizePlayerSkins
	);
	
	// Load update checker.
	if (NXPConfig(xConf).checkForNexgenUpdates) {
		spawn(class'NXPUpdateCheckWR').sendRequest(self);
	}
	
	// Plugin successfully initialized.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the plugin requires the to shared data containers to be created. These
 *                may only be created / added to the shared data synchronization manager inside this
 *                function. Once created they may not be destroyed until the current map unloads.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function createSharedDataContainers() {
	dataSyncMgr.addDataContainer(class'NXPConfigDC');
	dataSyncMgr.addDataContainer(class'NXPMapListDC');
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game has started.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function gameStarted() {
	local NexgenClient client;
	local NXPClient xClient;
	
	if (enablePlayerOverlay) {
		for (client = control.clientList; client != none; client = client.nextClient) {
			xClient = NXPClient(getXClient(client));
			xClient.setPlayerOverlay(true);
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
	local NXPClient xClient;
	
	// Destroy player overlays.
	if (enablePlayerOverlay) {
		for (client = control.clientList; client != none; client = client.nextClient) {
			xClient = NXPClient(getXClient(client));
			xClient.setPlayerOverlay(false);
		}
	}
	
	// Fix infinite loop in viewPlayerNum() caused by spectators at the end of the match.
	fixSpecatorViewPlayerNumBug();
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
	local NXPClient xClient;
	
	// Allow super class to handle the event.
	super.clientCreated(client);
	
	// Get client controller.
	xClient = NXPClient(getXClient(client));
	
	// Additional initialization of client controller.
	xClient.lng = self.lng;
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
	local NXPClient xClient;
	
	// Allow super class to handle the event.
	super.clientInitialized(client);
	
	// Get client controller.
	xClient = NXPClient(getXClient(client));
	
	// Notify server admin of a Nexgen update if available.
	if (NXPConfig(xConf).checkForNexgenUpdates &&
	    latestNexgenVersion > class'NexgenUtil'.default.versionCode &&
	    client.hasRight(client.R_ServerAdmin)) {
	    xClient.notifyNexgenUpdateAvailable(latestNexgenVersion);
	}
	
	// Show rules message.
	if (NXPConfig(xConf).showServerRulesTab) {
		client.showMsg(lng.viewRulesClientMsg);
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
	local NXPClient xClient;
	
	// Get client controller.
	xClient = NXPClient(getXClient(client));
	
	// Restore saved player data.
	client.player.playerReplicationInfo.score = client.pDat.getFloat(PA_Score, client.player.playerReplicationInfo.score);
	client.player.playerReplicationInfo.deaths = client.pDat.getFloat(PA_Deaths, client.player.playerReplicationInfo.deaths);
	client.player.playerReplicationInfo.startTime = client.pDat.getInt(PA_StartTime, client.player.playerReplicationInfo.startTime);
	
	// Add player overlay.
	if (enablePlayerOverlay && control.gInf.gameState == control.gInf.GS_Playing) {
		xClient.setPlayerOverlay(true);
	}
	
	// Make AKA log the client id.
	if (NXPConfig(xConf).enableAKALogging) {
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
	local NXPClient xClient;
	local bool hasMatchAdmin;
	
	super.playerLeft(client);
	
	// Get client controller.
	xClient = NXPClient(getXClient(client));
	
	// Remove player overlay.
	xClient.setPlayerOverlay(false);
	
	// Enable default UT map switcher if no match admin is logged in.
	if (mapSwitchOpened && control.gInf.matchAdminCount <= 0) {
		mapSwitchOpened = false;
		if (level.game.isA('DeathMatchPlus')) {
			DeathMatchPlus(level.game).restartWait = originalRestartWait;
		}
	}
	
	// Store saved player data.
	client.pDat.set(PA_Score, client.player.playerReplicationInfo.score);
	client.pDat.set(PA_Deaths, client.player.playerReplicationInfo.deaths);
	client.pDat.set(PA_StartTime, client.player.playerReplicationInfo.startTime);
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
	if (NXPConfig(xConf).enableTagProtection && !client.bHasAccount) {
		if (nameContainsProtectedTag(client.playerName, tag)) {
			bRejected = true;
			reason = lng.protectedTagLoginRejectMsg;
			popupWindowClass = string(class'NXPTagRejectDialog');
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
	if (NXPConfig(xConf).enableTagProtection && !client.bHasAccount && !bWasForcedChanged) {
		if (nameContainsProtectedTag(client.playerName, tag)) {
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
function bool nameContainsProtectedTag(string playerName, out string protectedTag) {
	local bool bFound;
	local int index;
	local NXPConfig xConf;
	
	xConf = NXPConfig(self.xConf);
	
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
	local int altServerCount;
	local int serverNum;
	local NXPConfig xConf;
	
	xConf = NXPConfig(self.xConf);
	
	// Full server redirect.
	if (rejectType == control.RT_ServerFull && xConf.enableFullServerRedirect) {
		
		// Check if an alternate server is specified.
		while (index < arrayCount(xConf.altServerAddress)) {
			if (class'NexgenUtil'.static.trim(xConf.altServerAddress[index]) != "") {
				altServerCount++;
			}
			index++;
		}
		
		// Alternate server found, modify login reject.
		if (altServerCount > 0) {
			if (xConf.autoFullServerRedirect) {
				// Select a random server.
				serverNum = rand(altServerCount) + 1;
				index = 0;
				while (serverNum > 0) {
					if (class'NexgenUtil'.static.trim(xConf.altServerAddress[index]) != "") {
						serverNum--;
					}
					index++;
				}
				index--;
				
				// Set popup window parameters.
				popupWindowClass = string(class'NXPAutoRedirectDialog');
				popupArgs[0] = xConf.altServerName[index];
				popupArgs[1] = xConf.altServerAddress[index];
				popupArgs[2] = "";
				popupArgs[3] = "";
			} else {
				popupWindowClass = string(class'NXPServerFullDialog');
				popupArgs[0] = class'NexgenUtil'.static.replace(xConf.altServerName[0], separator, "") $ separator $ xConf.altServerAddress[0];
				popupArgs[1] = class'NexgenUtil'.static.replace(xConf.altServerName[1], separator, "") $ separator $ xConf.altServerAddress[1];
				popupArgs[2] = class'NexgenUtil'.static.replace(xConf.altServerName[2], separator, "") $ separator $ xConf.altServerAddress[2];
				popupArgs[3] = "";
			}
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
	local NXPClient xClient;
	
	cmd = class'NexgenUtil'.static.trim(msg);
	bIsCommand = true;
	switch (cmd) {
		case "!stats": level.game.baseMutator.mutate(CMD_SmartCTFToggleStats, sender); break;
		case "!rules":
			if (NXPConfig(xConf).showServerRulesTab) {
				xClient = NXPClient(getXClient(sender));
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
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *  $PARAM        author           Object that was responsible for the change.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function varChanged(NexgenSharedDataContainer container, string varName, optional int index, optional Object author) {
	local NexgenClient client;
	local bool bIsSensitive;
	local string varIndex;
	
	// Log admin actions.
	if (author != none && (author.isA('NexgenClient') || author.isA('NexgenClientController'))) {
		// Get client.
		if (author.isA('NexgenClientController')) {
			client = NexgenClientController(author).client;
		} else {
			client = NexgenClient(author);
		}
		
		// Only log changes for configuration variables.
		if (container.containerID ~= class'NXPConfigDC'.default.containerID) {
			// Check for variables that store sensitive data.
			bIsSensitive = varName ~= "reloadMapList";
			
			// Check for arrays.
			if (container.isArray(varName)) {
				varIndex = "[" $ index $ "]";
			}
			
			// Log action.
			control.logAdminAction(client, lng.adminChangeConfigVarMsg, client.playerName,
			                       string(xConf.class), varName $ varIndex,
			                       container.getString(varName, index),
			                       client.player.playerReplicationInfo, true, bIsSensitive);
		}
	}
	
	// Check if player overlay config was changed.
	if (container.containerID ~= class'NXPConfigDC'.default.containerID) {
		switch (varName) {
			case "showDamageProtectionShield":
			case "colorizePlayerSkins":
				playerOverlayConfigChanged();
				break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function. Called when the game performs its next tick.
 *                The following actions are performed:
 *                 - Check if the map switch tab should be opened at the end of the game.
 *  $PARAM        delta  Time elapsed (in seconds) since the last tick.
 *  $OVERRIDE     
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	local NXPConfig xConf;
	local NexgenClient client;
	
	super.tick(deltaTime);
	
	xConf = NXPConfig(self.xConf);
	
	// Check if the map switch tab should be opened.
	if (
		control.gameEndTime > 0 &&
		xConf.enableMapSwitch &&
		xConf.showMapSwitchAtEndOfGame &&
		!mapSwitchAutoDisplayChecked &&
		control.timeSeconds - control.gameEndTime >= xConf.mapSwitchAutoDisplayDelay
	) {
		// Map switch tab should be opened if any admins are around.
		mapSwitchAutoDisplayChecked = true;
		
		// Check if there are any admins with the 'match admin' privilege logged in.
		for (client = control.clientList; client != none; client = client.nextClient) {
			if (client.hasRight(client.R_MatchAdmin)) {
				mapSwitchOpened = true;
				NXPClient(getXClient(client)).showMapSwitchTab();
			}
		}
		
		// Disable UT default map switcher.
		if (mapSwitchOpened && level.game.isA('DeathMatchPlus')) {
			originalRestartWait = DeathMatchPlus(level.game).restartWait;
			DeathMatchPlus(level.game).restartWait = maxInt;
		}
	} 
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the player overlay skin settings have been changed.
 *
 **************************************************************************************************/
function playerOverlayConfigChanged() {
	local NexgenClient client;
	local NXPClient xClient;
	local bool newEnablePlayerOverlay;
	
	// Determine new player overlay enabled status.
	newEnablePlayerOverlay = (
		NXPConfig(xConf).showDamageProtectionShield ||
		NXPConfig(xConf).colorizePlayerSkins
	);
	
	// Update if status has changed.
	if (newEnablePlayerOverlay != enablePlayerOverlay) {
		enablePlayerOverlay = newEnablePlayerOverlay;
		if (control.gInf.gameState == control.gInf.GS_Playing) {
			for (client = control.clientList; client != none; client = client.nextClient) {
				xClient = NXPClient(getXClient(client));
				xClient.setPlayerOverlay(enablePlayerOverlay);
			}
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
	local NexgenClient client;
	
	for (client = control.clientList; client != none; client = client.nextClient) {
		NXPClient(getXClient(client)).updateRemainingTime(remainingTime);
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
	local NXPClient xClient;
	
	// Get extended client controller.
	xClient = NXPClient(getXClient(sender));
	
	// Stuff that needs the extended client controller.
	if (xClient != none) {
		
		// Spam detection.
		if (NXPConfig(xConf).enableNexgenAntiSpam) {
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
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	pluginName="Nexgen plus extension package"
	pluginAuthor="Zeropoint"
	pluginVersion="1.00 build 1023"
	versionNum=100
	clientControllerClass=class'NXPClient'
	extConfigClass=class'NXPConfigExt'
	sysConfigClass=class'NXPConfigSys'
}