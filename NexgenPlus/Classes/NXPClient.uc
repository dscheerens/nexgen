/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPClient
 *  $VERSION      1.09 (19-12-2010 15:20:35)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Client controller for the Nexgen Plus plugin.
 *
 **************************************************************************************************/
class NXPClient extends NexgenExtendedClientController;

#exec OBJ LOAD FILE=Announcer
#exec AUDIO IMPORT NAME=alertSound FILE=Resources\klax1.wav

var NXPLang lng;                                  // Localization support instance.
var NXPMapSwitchRCP mapSwitchTab;                 // Map switch control panel page.
var NXPServerRulesOverviewRCP serverRulesTab;     // Server rules overview control panel page.
var NXPHUD xHUD;                                  // The HUD extension.
var NXPPlayerOverlay playerOverlay;               // The player overlay skin.

// Dynamic control info.
var bool bEnableStartAnnouncer;                   // Enable game start count down voice announcer.
var int lastCountDown;                            // Last known value of gInf.countDown.
var bool bGameStartingAnnounced;                  // Has the game starting state been announced yet?

// Anti spam control.
var string lastMessages[3];                       // Last chat messages send by the player.
var float lastMessageTimeStamps[3];               // Time stamp of the last send chat messages.
var float lastSpamTimeStamp;                      // Last time this player has spammed.

// Client side settings.
const SSTR_EnableStartAnnouncer = "EnableStartCountDown";   // Enable game start countdown voice.
const SSTR_ShowPingStatusBox = "ShowPingStatusBox";         // Show a ping status box in the HUD.
const SSTR_ShowTimeStatusBox = "ShowTimeStatusBox";         // Show a time status box in the HUD.
const SSTR_LastVersionNotify = "LastVersionNotify";         // Last Nexgen update the client was notified of.

// Client side settings default values.
const SSTRDV_EnableStartAnnouncer = "true";
const SSTRDV_ShowPingStatusBox = "false";
const SSTRDV_ShowTimeStatusBox = "false";

// Server rules HUD positioning constants.
const APH_Left = 1;                               // Left side anchor point.
const APH_Middle = 2;                             // Middle anchor point.
const APH_Right = 3;                              // Right side anchor point.
const APV_Top = 1;                                // Top side anchor point.
const APV_Middle = 2;                             // Middle anchor point.
const APV_Bottom = 3;                             // Bottom anchor point.
const UNIT_Pixels = 1;                            // Pixels unit measure.
const UNIT_Percentage = 2;                        // Percentage unit measure.

// Settings.
const startCountDownWait = 2;                     // Game start count down announcer delay.
const minMessageInterval = 1.5;                   // Minimum time between duplicate chat messages.
const spamNotifyDuration = 2.0;                   // How long will the spam notification be visible?



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {
	reliable if (role == ROLE_Authority) // Replicate to client...
		showMapSwitchTab, updateRemainingTime, notifyClientSpam, notifyNexgenUpdateAvailable,
		showRules;

	reliable if (role == ROLE_SimulatedProxy) // Replicate to server...
		doMapSwitch, setScoreLimit, setTimeLimit, setTeamScoreLimit, setGameSpeed, setRemainingTime,
		adminForceClientViewRules;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated event postNetBeginPlay() {
	if (bNetOwner) {
		super.postNetBeginPlay();
		
		// Load localization support.
		lng = spawn(class'NXPLang', self);
		
		// Check if start announcer should be enabled.
		bEnableStartAnnouncer = client.gc.get(SSTR_EnableStartAnnouncer, SSTRDV_EnableStartAnnouncer) ~= "true";
		
		// Make sure the HUD won't show a muted icon just after we joined the game.
		lastSpamTimeStamp = -spamNotifyDuration;
	} else {
		destroy();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function. Called when the game performs its next tick.
 *                The following actions are performed:
 *                 - Game start count down announcing.
 *  $PARAM        delta  Time elapsed (in seconds) since the last tick.
 *  $OVERRIDE     
 *
 **************************************************************************************************/
simulated function tick(float deltaTime) {
	super.tick(deltaTime);
	
	// Client side actions.
	if (role == ROLE_SimulatedProxy && client != none && !client.bNetWait) {
		
		// Game starting count down ticked?
		if (client.gInf.gameState == client.gInf.GS_Starting && lastCountDown != client.gInf.countDown) {
			lastCountDown = client.gInf.countDown;
			
			// Play count down announcer sound?
			if (bEnableStartAnnouncer) {
				if (1 <= lastCountDown && lastCountDown <= 10 &&
				    lastCountDown <= client.sConf.startTime - startCountDownWait) {
					client.player.receiveLocalizedMessage(class'Botpack.TimeMessage', 16 - lastCountDown);
				} else if (!bGameStartingAnnounced) {
					bGameStartingAnnounced = true;
					client.player.clientPlaySound(sound'Announcer.Prepare', , true);
				}
			}
		}
		
	}
	
	// Server side actions.
	if (role == ROLE_Authority) {
		// Disable UT antispam.
		if (NXPConfig(xControl.xConf).disableUTAntiSpam) {
			client.player.lastMessageWindow = 0;
		}
	}

}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the NexgenClient has received its initial replication info is has
 *                been initialized. At this point it's safe to use all functions of the client.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function clientInitialized() {
	super.clientInitialized();
	
	// Create HUD extension.
	xHUD = spawn(class'NXPHUD', self);
	xHUD.bShowPingBox = client.gc.get(SSTR_ShowPingStatusBox, SSTRDV_ShowPingStatusBox) ~= "true";
	xHUD.bShowTimeBox = client.gc.get(SSTR_ShowTimeStatusBox, SSTRDV_ShowTimeStatusBox) ~= "true";
	client.addHUDExtension(xHUD);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Modifies the setup of the Nexgen remote control panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function setupControlPanel() {
	
	client.addPluginClientConfigPanel(class'NXPClientConfigRCP');
	
	if (client.hasRight(client.R_ServerAdmin)) {
		client.addPluginConfigPanel(class'NXPSettingsRCP');
		client.addPluginConfigPanel(class'NXPServerRedirectRCP');
		client.addPluginConfigPanel(class'NXPTagProtectionRCP');
		client.addPluginConfigPanel(class'NXPServerRulesRCP');
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization of the given shared data container is
 *                done. After this has happend the client may query its variables and receive valid
 *                results (assuming the client is allowed to read those variables).
 *  $PARAM        container  The shared data container that has become available for use.
 *  $REQUIRE      container != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function dataContainerAvailable(NexgenSharedDataContainer container) {
	if (container.containerID == "nxp_config") {
		if (client.hasRight(client.R_MatchAdmin) && container.getBool("enableMapSwitch")) {
			mapSwitchTab = NXPMapSwitchRCP(client.mainWindow.mainPanel.addPanel(lng.mapSwitchTabTxt, class'NXPMapSwitchRCP', , "game"));
		}
		if (container.getBool("showServerRulesTab")) {
			serverRulesTab = NXPServerRulesOverviewRCP(client.mainWindow.mainPanel.addPanel(lng.serverRulesTabTxt, class'NXPServerRulesOverviewRCP', , "server"));
		}
		
		xHUD.xConf = container;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Causes the server to load the specified map with the given game type and mutators.
 *  $PARAM        mapName   File name of the map that is to be loaded.
 *  $PARAM        gameType  The game type to use when the new map is loaded.
 *  $PARAM        mutators  List of mutators that are to be loaded.
 *
 **************************************************************************************************/
function doMapSwitch(string mapName, byte gameType, string mutators) {
	local string remaining;
	local string indexStr;
	local int index;
	local string mutatorClass;
	local string mutatorClasses;
	local string temp;
	local string gameClass;
	local string clientTravelURL;
	local string serverTravelURL;
	local string mapNameNoExt;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin)) {
		return;
	}
	
	// Get game type.
	if (0 <= gameType && gameType < arrayCount(client.sConf.gameTypeInfo)) {
		class'NexgenUtil'.static.split(client.sConf.gameTypeInfo[gameType], gameClass, temp);
	} else {
		gameClass = "";
	}
	
	// Get mutator classes.
	remaining = mutators;
	while (remaining != "") {
		class'NexgenUtil'.static.split(remaining, indexStr, remaining);
		index = int(indexStr);
		if (0 <= index && index < arrayCount(client.sConf.mutatorInfo)) {
			class'NexgenUtil'.static.split(client.sConf.mutatorInfo[index], mutatorClass, temp);
			
			if (mutatorClasses == "") {
				mutatorClasses = mutatorClass;
			} else {
				mutatorClasses = mutatorClasses $ "," $ mutatorClass;
			}
		}
	}
	
	// Assemble URL & set server travel.
	clientTravelURL = mapName $ "?game=" $ gameClass;
	serverTravelURL = mapName $ "?game=" $ gameClass $ "?mutator=" $ mutatorClasses;
	level.serverTravel(clientTravelURL, false);
	level.nextURL = serverTravelURL; // Now make the server use the 'real' travel url.
	
	// Log action.
	mapNameNoExt = left(mapName, instr(mapName, "."));
	logAdminAction(lng.adminMapSwitchMsg, mapNameNoExt);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Opens the map switch tab for the client. In case the client does not have the
 *                correct privileges nothing will happen.
 *
 **************************************************************************************************/
simulated function showMapSwitchTab() {
	if (mapSwitchTab != none) {
		client.showPanel(mapSwitchTab.panelIdentifier);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds or removes the player overlay skin for this client.
 *  $PARAM        enable  Whether the overlay skin is to be added.
 *  $ENSURE       enable ? new.playerOverlay != none : new.playerOverlay == none
 *
 **************************************************************************************************/	
function setPlayerOverlay(bool enable) {
	// Add or remove overlay skin?
	if (enable && playerOverlay == none && !client.bSpectator) {
		// Add overlay skin.
		playerOverlay = spawn(
			  class'NXPPlayerOverlay'
			, client.player
			,
			, client.player.location
			, client.player.rotation
		);
		playerOverlay.xClient = self;
		
	} else if (!enable && playerOverlay != none) {
		// Remove overlay skin.
		playerOverlay.destroy();
		playerOverlay = none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the score limit for the current game.
 *  $PARAM        amount  The new score limit.
 *
 **************************************************************************************************/
function setScoreLimit(int amount) {
	local DeathMatchPlus game;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchSet) || !level.game.isA('DeathMatchPlus')) {
		return;
	}
	
	// Get DeathMatchPlus game.
	game = DeathMatchPlus(level.game);
	
	// Change frag limit.
	game.fragLimit = amount;
	TournamentGameReplicationInfo(game.gameReplicationInfo).fragLimit = amount;
	game.saveConfig();
	
	// Log action.
	logAdminAction(lng.adminChangeScoreLimitMsg, amount);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the time limit for the current game.
 *  $PARAM        amount  The new time limit.
 *
 **************************************************************************************************/
function setTimeLimit(int amount) {
	local DeathMatchPlus game;
	local int previousTimeLimit;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchSet) || !level.game.isA('DeathMatchPlus')) {
		return;
	}
	
	// Get DeathMatchPlus game.
	game = DeathMatchPlus(level.game);
	
	// Change time limit.
	previousTimeLimit = game.timeLimit;
	
	game.timeLimit = amount;
	TournamentGameReplicationInfo(game.gameReplicationInfo).timeLimit = amount;
	game.saveConfig();
	
	// Update remaining time.
	if (previousTimeLimit == 0 && amount > 0) {
		game.remainingTime = amount * control.secondsPerMinute;
	} else if (previousTimeLimit > 0 && amount == 0) {
		game.remainingTime = 0;
	} else if (amount < previousTimeLimit) {
		game.remainingTime = min(game.remainingTime, amount * control.secondsPerMinute);
	} else {
		game.remainingTime = game.remainingTime + (amount - previousTimeLimit) * control.secondsPerMinute;
	}
	game.gameReplicationInfo.remainingTime = game.remainingTime;
	NXPMain(xControl).announceNewRemainingTime(game.remainingTime);
	
	// Log action.
	logAdminAction(lng.adminChangeTimeLimitMsg, amount);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the value of the remaining time at the client.
 *  $PARAM        remainingTime  The new remaining time.
 *
 **************************************************************************************************/
simulated function updateRemainingTime(int remainingTime) {
	if (client.player.gameReplicationInfo != none) {
		client.player.gameReplicationInfo.remainingTime = remainingTime;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the team score limit for the current game.
 *  $PARAM        amount  The new team score limit.
 *
 **************************************************************************************************/
function setTeamScoreLimit(int amount) {
	local TeamGamePlus game;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchSet) || !level.game.isA('TeamGamePlus')) {
		return;
	}
	
	// Get TeamGamePlus game.
	game = TeamGamePlus(level.game);
	
	// Change frag limit.
	game.goalTeamScore = amount;
	TournamentGameReplicationInfo(game.gameReplicationInfo).goalTeamScore = amount;
	game.saveConfig();
	
	// Log action.
	logAdminAction(lng.adminChangeTeamScoreLimitMsg, amount);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the game speed for the current game.
 *  $PARAM        gameSpeed  The new game speed limit.
 *
 **************************************************************************************************/
function setGameSpeed(int gameSpeed) {
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchSet)) {
		return;
	}
	
	// Change the game speed.
	level.game.setGameSpeed(gameSpeed / 100.0);
	level.game.saveConfig(); 
	level.game.gameReplicationInfo.saveConfig();
	
	// Log action.
	logAdminAction(lng.adminChangeGameSpeedMsg, int(level.game.gameSpeed * 100));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the remaining time for the current game.
 *  $PARAM        remainingTimeStr  The new remaining time.
 *
 **************************************************************************************************/
function setRemainingTime(string remainingTimeStr) {
	local DeathMatchPlus game;
	local int remainingTime;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin) || !level.game.isA('DeathMatchPlus') ||
	    !class'NXPUtil'.static.getTimeInSeconds(remainingTimeStr, remainingTime)) {
		return;
	}
	
	// Get DeathMatchPlus game.
	game = DeathMatchPlus(level.game);
	
	// Check if there is a time limit.
	if (game.timeLimit <= 0) {
		return;
	}
	
	// Update time limit.
	remainingTime = min(remainingTime, game.timeLimit * control.secondsPerMinute);
	game.remainingTime = remainingTime;
	game.gameReplicationInfo.remainingTime = remainingTime;
	NXPMain(xControl).announceNewRemainingTime(remainingTime);
	
	// Log action.
	logAdminAction(lng.adminChangeTimeRemainingMsg, lng.getLongTimeDescription(remainingTime));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified message should be considered spam by this player.
 *  $PARAM        msg  The message that the player tried to send.
 *  $RETURN       True whether the specified message is spam, false if not.
 *
 **************************************************************************************************/
function bool isSpam(string msg) {
	local int index;
	
	// Moderators can say whatever they want.
	if (client.hasRight(client.R_Moderate)) return false;
	
	// Check if we already said this message in the last x seconds.
	for (index = 0; index < arrayCount(lastMessages); index++) {
		if (lastMessages[index] == msg &&
			(client.control.timeSeconds - lastMessageTimeStamps[index]) <= minMessageInterval) {
			return true;
		}
	}
	
	// No matching rules found, so message isn't spam.
	return false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
function addMessage(string msg) {
	local int index;
	
	// Shift old messages up in the list.
	for (index = 0; index < arrayCount(lastMessages) - 1; index++) {
		lastMessages[index] = lastMessages[index + 1];
		lastMessageTimeStamps[index] = lastMessageTimeStamps[index + 1];
	}
	
	// Store new message at the back of the list.
	lastMessages[index] = msg;
	lastMessageTimeStamps[index] = client.control.timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when this client is spamming.
 *
 **************************************************************************************************/
simulated function notifyClientSpam() {
	client.player.clientPlaySound(sound'alertSound', , true);
	lastSpamTimeStamp = client.timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Modifies the client state panel on the Nexgen HUD.
 *  $PARAM        stateType  State type identifier.
 *  $PARAM        text       Text to display on the state panel.
 *  $PARAM        textColor  Color of the text to display.
 *  $PARAM        icon       State icon. The icon is displayed in front of the text.
 *  $PARAM        solidIcon  Solid version of the icon (masked, no transparency).
 *  $PARAM        bBlink     Whether the text on the panel should blink.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function modifyClientState(out name stateType, out string text, out Color textColor, 
                                     out Texture icon, out Texture solidIcon, out byte bBlink) {
	
	if (client != none && stateType == client.nscHUD.CS_Normal &&
	    (client.timeSeconds - lastSpamTimeStamp) <= spamNotifyDuration) {
		
		stateType = client.nscHUD.CS_Muted;
		text      = lng.antiSpamMutedState;
		textColor = client.nscHUD.colors[client.nscHUD.C_RED];	
		icon      = Texture'mutedIcon';
		solidIcon = Texture'mutedIcon2';
		bBlink    = byte(true);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client that there is an update for Nexgen available
 *  $PARAM        version  The latest version of Nexgen that is available.
 *
 **************************************************************************************************/
simulated function notifyNexgenUpdateAvailable(int version) {
	local int lastNotifiedVersion;
	
	lastNotifiedVersion = int(client.gc.get(SSTR_LastVersionNotify, "0"));

	// Check if the client should be notified of this update.
	if (version > lastNotifiedVersion) {
		client.gc.set(SSTR_LastVersionNotify, string(version));
		client.gc.saveConfig();
		client.showPopup(string(class'NXPUpdateNotificationDialog'), string(version));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Forces the client with the specified player code to view the server rules.
 *  $PARAM        targetPlayer  Player code of the player that should view the server rules.
 *  $PARAM        reason        Reason of the admin to make the player view the rules.
 *
 **************************************************************************************************/
function adminForceClientViewRules(int targetPlayer, optional string reason) {
	local NexgenClient target;
	local NXPClient xTarget;
	local string logReason;
	
	// Check rights.
	if (!client.hasRight(client.R_Moderate) ||
	    !dataSyncMgr.getDataContainer("nxp_config").getBool("showServerRulesTab")) {
		return;
	}
	
	// Get target client.
	target = control.getClientByNum(targetPlayer);
	if (target == none) return;
	xTarget = NXPClient(target.getController(class'NXPClient'.default.ctrlID));
	if (xTarget == none) return;
	
	// Show rules at target client.
	xTarget.showRules(true, reason);
	
	// Log action.
	if (reason == "") {
		logReason = lng.noReasonGivenMsg;
	} else {
		logReason = reason;
	}
	logAdminAction(lng.adminForceClientViewRulesMsg, target.playerName, logReason, , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Shows the server rules at the client.
 *
 **************************************************************************************************/
simulated function showRules(optional bool bAdminForced, optional string reason) {
	
	if (serverRulesTab != none) {
		
		// Set force message.
		if (bAdminForced) {
			serverRulesTab.setAdminForcedViewMessage(reason);
		}
		
		// Show the rules view tab.
		client.showPanel(class'NXPServerRulesOverviewRCP'.default.panelIdentifier);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	ctrlID="NexgenPlusClient"
	bCanModifyHUDStatePanel=true
}