/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXClient
 *  $VERSION      1.20 (15-03-2010 13:41)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Extension pack client controller class. This class is the base of the clientside
 *                support for the extension plugin.
 *
 **************************************************************************************************/
class NexgenXClient extends NexgenClientController;

#exec OBJ LOAD FILE=Announcer
#exec AUDIO IMPORT NAME=alertSound FILE=Resources\klax1.wav

var NexgenX xControl;                   // Extension controller.
var NexgenXLang lng;                    // Language instance to support localization.
var NexgenXConfig xConf;                // Plugin configuration.
var NexgenXHUD xHUD;                    // The HUD extension.

var NexgenXRCPMapSwitch mapSwitchTab;   // Map switch control panel tab.

var NexgenXPlayerOverlay playerOverlay; // Player overlay skin.

var bool bNetWait;                      // Client is waiting for initial replication.

// Map list control.
var NexgenXMapList mapList;             // Maps available on the server.
var bool bSendingMapList;               // Whether the server is currently sending the map list.
var bool bMapListSend;                  // Whether the map list has been sended to the client.
var int numMapsSend;                    // The number of maps that have been send to the client.

// Dynamic control info.
var int lastCountDown;                  // Last known value of gInf.countDown.
var bool bGameStartingAnnounced;        // Has the game starting state been announced yet?

// Config replication control.
var int nextDynamicUpdateCount[4];      // Last received config update count per config type.
var int nextDynamicChecksum[4];         // Checksum to wait for.
var byte bWaitingForNewConfig[4];       // Whether the client is waiting for the configuration.

// Anti spam control.
var string lastMessages[3];             // Last chat messages send by the player.
var float lastMessageTimeStamps[3];     // Time stamp of the last send chat messages.
var float lastSpamTimeStamp;            // Last time this player has spammed.

// Controller settings.
const timerFreq = 5.0;                  // Timer tick frequency.
const mapListSendtimerFreq = 2.0;       // Timer tick frequency when the map list is being send.
const minMessageInterval = 1.5;         // Minimum time between duplicate chat messages.
const spamNotifyDuration = 2.0;         // How long will the spam notification be visible?
const maxMapListPartStringSize = 100;   // Maximum size of the map list parts send to the client.
const startCountDownWait = 2;           // Second to wait before starting the count down announcer.

// General constants.
const maxStringSize = 255;              // Maximum size of strings replicated over the net.
const separator = ",";                  // Character used to seperate elements in a list.

// Client side settings.
const SSTR_LastVersionNotify = "LastVersionNotify"; // Last Nexgen update the client was notified of.
const SSTR_ShowPingStatusBox = "ShowPingStatusBox"; // Show a ping status box in the HUD.
const SSTR_ShowTimeStatusBox = "ShowTimeStatusBox"; // Show a time status box in the HUD.

// Client side settings default values.
const SSTRDV_ShowPingStatusBox = "false";
const SSTRDV_ShowTimeStatusBox = "false";



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {
	reliable if (role == ROLE_Authority) // Replicate to client...
		// Variables.
		xConf,
		
		// Functions.
		receiveMapListPart, nexgenXConfigChanged, notifyClientSpam, updateRemainingTime,
		notifyUpdateAvailable, showRules, createMapList;
		
	reliable if (role == ROLE_SimulatedProxy) // Replicate to server...
		// Variables.	
	
		// Functions.
		requestMapList, doMapSwitch, setGeneralSettings, setFullServerRedirSettings, addBots,
		setScoreLimit, setTimeLimit, setTeamScoreLimit, setGameSpeed, setRemainingTime,
		setTagProtectionSettings, setServerRule, setServerRulesSettings, adminForceClientViewRules;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function preBeginPlay() {
	super.preBeginPlay();
	
	// Execute client side actions.
	if (role == ROLE_SimulatedProxy) {
		
		// Wait for initial replication to complete.
		bNetWait = true;
		
	}
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
		lng = spawn(class'NexgenXLang');
		
		// Enable timer.
		setTimer(1.0 / timerFreq, true);
		
		// Make sure the HUD won't show a muted icon just after we joined the game.
		lastSpamTimeStamp = -spamNotifyDuration;
	} else {
		destroy();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the client is ready to initialize. 
 *  $RETURN       True if the client is ready to initialize, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function bool isReadyToInitialize() {
	return (client != none && initialConfigReplicationComplete());
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Modifies the setup of the Nexgen remote control panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function setupControlPanel() {
	
	client.addPluginClientConfigPanel(class'NexgenXRCPClientConfig');
	
	// Add control panel tabs.
	if (client.hasRight(client.R_MatchAdmin) && xConf.enableMapSwitch) {
		requestMapList();
		mapSwitchTab = NexgenXRCPMapSwitch(client.mainWindow.mainPanel.addPanel(lng.mapSwitchTabTxt, class'NexgenXRCPMapSwitch', , "game"));
	}
	if (client.hasRight(client.R_MatchAdmin)) {
		client.mainWindow.mainPanel.addPanel(lng.botControlTabTxt, class'NexgenXRCPBotControl', , "game");
	}
	if (xConf.enableServerRules) {
		client.mainWindow.mainPanel.addPanel(lng.serverRulesTabTxt, class'NexgenXRCPServerRulesView', , "server");
	}
	if (client.hasRight(client.R_ServerAdmin)) {
		client.addPluginConfigPanel(class'NexgenXRCPSettings');
		client.addPluginConfigPanel(class'NexgenXRCPFullServerRedir');
		client.addPluginConfigPanel(class'NexgenXRCPTagProtection');
		client.addPluginConfigPanel(class'NexgenXRCPServerRules');
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
	bNetWait = false;
	
	// Create HUD extension.
	xHUD = spawn(class'NexgenXHUD', self);
	xHUD.bShowPingBox = client.gc.get(SSTR_ShowPingStatusBox, SSTRDV_ShowPingStatusBox) ~= "true";
	xHUD.bShowTimeBox = client.gc.get(SSTR_ShowTimeStatusBox, SSTRDV_ShowTimeStatusBox) ~= "true";
	client.addHUDExtension(xHUD);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Time critical event detection loop.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function tick(float deltaTime) {
	
	// Client side actions.
	if (role == ROLE_SimulatedProxy && client != none && !client.bNetWait) {
		
		// Game starting count down ticked?
		if (client.gInf.gameState == client.gInf.GS_Starting && lastCountDown != client.gInf.countDown) {
			lastCountDown = client.gInf.countDown;
			
			// Play countdown announcer sound?
			if (!bNetWait && xConf.enableStartAnnouncer) {
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
		if (xConf.disableUTAntiSpam) {
			client.player.lastMessageWindow = 0;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller. This function is automatically called after
 *                the critical variables have been set, such as the client variable.
 *  $PARAM        creator  The Actor that has added the controller to the client.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function initialize(optional Actor creator) {
	xControl = NexgenX(creator);
	lng = xControl.lng;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called by the client when it wants to receive the list of maps that are available
 *                on the server.
 *  $ENSURE       bSendingMapList || bMapListSend
 *
 **************************************************************************************************/
function requestMapList() {
	
	// Check if map list is already being send or has already been send.
	if (bSendingMapList || bMapListSend) {
		// It is and there's no need to send things again.
		return;
	}
	
	// Start sending the map list to the client.
	createMapList(xControl.maps.numMaps);
	bSendingMapList = true;
	setTimer(1.0 / mapListSendtimerFreq, true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the map list for this client.
 *  $PARAM        numMaps  The number of maps that are available.
 *  $REQUIRE      numMaps >= 0
 *
 **************************************************************************************************/
simulated function createMapList(int numMaps) {
	mapList = spawn(class'NexgenXMapList', self);
	mapList.numMaps = numMaps;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function. On the server side the timer tick is responsible for sending
 *                the map list to the client if bSendingMapList is set to true.
 *
 **************************************************************************************************/
simulated function timer() {
	local string mapList;
	local string nextMap;
	local bool bMapListComplete;
	local bool bMapListFull;
	
	// Client side actions.
	if (role == ROLE_SimulatedProxy) {
				
		// Check for config updates.
		if (!bNetWait) {
			checkConfigUpdate();
		}

	// Server side actions.
	} else { 
	
		// Send next part of the map list.
		if (bSendingMapList) {
			
			// Continue adding maps to the map list till the string get too large.
			while (!bMapListComplete && !bMapListFull) {
				
				if (numMapsSend >= xControl.maps.numMaps) {
					// All maps have been send, so we're done.
					bMapListComplete = true;
				} else {
					// Get next map to send.
					nextMap = xControl.maps.maps[numMapsSend];
					
					// Check if next map can be send.
					if (mapList == "")  {
						// Map list is empty, so we can safely add the next map.
						mapList = nextMap;
						numMapsSend++;
					} else if (len(mapList) + len(separator) + len(nextMap) > maxMapListPartStringSize) {
						// Can't add the next map without exceeding the maximum string size.
						bMapListFull = true;
					} else {
						// There's still enough space to add the next map.
						mapList = mapList $ separator $ nextMap;
						numMapsSend++;
					}
				}

			}
			
			// Send the map list.
			receiveMapListPart(bMapListComplete, mapList);
			
			// Check if sending has been completed.
			if (bMapListComplete) {
				bSendingMapList = false;
				bMapListSend = true;
				setTimer(0.0, false);
			}
		}
		
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called on the client when a new part of the map list has been received.
 *  $PARAM        bLastPart    Indicates whether this is the last part of the map list.
 *  $PARAM        mapListPart  String containing a part of the map list.
 *
 **************************************************************************************************/
simulated function receiveMapListPart(bool bLastPart, string mapListPart) {
	local string remaining;
	local string mapName;
	
	remaining = mapListPart;
	while (remaining != "" && numMapsSend < arrayCount(mapList.maps)) {
		class'NexgenUtil'.static.split(remaining, mapName, remaining);
		mapList.maps[numMapsSend++] = mapName;
	}
	
	if (bLastPart) {
		mapSwitchTab.notifyMapListAvailable();
	} else {
		mapSwitchTab.notifyMapListPartRecieved();
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
	local string serverActors;
	
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
	
	// Get server actor list.
	serverActors = caps(consoleCommand("get Engine.GameEngine ServerActors"));
	
	// Get mutator classes.
	remaining = mutators;
	while (remaining != "") {
		class'NexgenUtil'.static.split(remaining, indexStr, remaining);
		index = int(indexStr);
		if (0 <= index && index < arrayCount(client.sConf.mutatorInfo)) {
			class'NexgenUtil'.static.split(client.sConf.mutatorInfo[index], mutatorClass, temp);
			
			// Only add mutator class if not already in the server actor list.
			if (instr(serverActors, "\"" $ caps(mutatorClass) $ "\"") < 0) {
				if (mutatorClasses == "") {
					mutatorClasses = mutatorClass;
				} else {
					mutatorClasses = mutatorClasses $ separator $ mutatorClass;
				}
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
 *  $DESCRIPTION  Adds or removes the player overlay skin for this client.
 *  $PARAM        bRemove  Whether the overlay skin is to be removed.
 *  $ENSURE       bRemove ? new.playerOverlay == none : new.playerOverlay != none
 *
 **************************************************************************************************/	
function setPlayerOverlay(optional bool bRemove) {
	
	// Remove overlay skin?
	if (bRemove && playerOverlay != none) {
		// Yes.
		playerOverlay.destroy();
		playerOverlay = none;
	
	} else if (!bRemove && playerOverlay == none && !client.bSpectator) {
		// No, add overlay skin.
		playerOverlay = spawn(class'NexgenXPlayerOverlay', client.player, ,
		                      client.player.location, client.player.rotation);
		playerOverlay.client = client;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client that the server configuration has been updated. The new
 *                settings might not yet have been replicated, so the client has to wait for the
 *                replication to complete. Once the replication is completed an event will be
 *                triggered to signal the GUI and other client controllers that the new settings
 *                are available, see checkConfigUpdate(). Note this function is similar to the
 *                configChanged() function in NexgenClient.
 *  $PARAM        configType   Type of settings that have been changed.
 *  $PARAM        updateCount  Config update number for the new settings.
 *  $PARAM        checksum     Checksum of the new settings.
 *  $REQUIRE      0 <= configType && configType < arrayCount(configChecksum) && updateCount >= 0
 *
 **************************************************************************************************/
simulated function nexgenXConfigChanged(byte configType, int updateCount, int checksum) {
	if (updateCount > nextDynamicUpdateCount[configType]) {
		nextDynamicUpdateCount[configType] = updateCount;
		nextDynamicChecksum[configType] = checksum;
		bWaitingForNewConfig[configType] = byte(true);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether some of the configuration was updated and if the new configuration
 *                has been replicated yet to the client. If this is the case an event will be
 *                signalled on the client to notify the system that the new configuration is
 *                available.
 *
 **************************************************************************************************/
simulated function checkConfigUpdate() {
	local byte type;
	
	// Server configuration.
	for (type = 0; type < arrayCount(nextDynamicChecksum); type++) {
		if (bool(bWaitingForNewConfig[type]) &&
		    xConf.updateCounts[type] >= nextDynamicUpdateCount[type] &&
		    xConf.calcDynamicChecksum(type) == nextDynamicChecksum[type]) {
		    
			bWaitingForNewConfig[type] = byte(false);
			
			// Signal event GUI.
			client.notifyEvent(xConf.EVENT_NexgenXConfigChanged, string(type));
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the initial replication of the configuration has completed.
 *  $RETURN       True if the initial data of the xConf instance has been recieved, false if not.
 *
 **************************************************************************************************/
simulated function bool initialConfigReplicationComplete() {
	local int index;
	
	// Check if configuration instance has been spawned (via replication).
	if (xConf == none) {
		return false;
	}
	
	// Check dynamic replication data.
	for (index = 0; index < arrayCount(nextDynamicChecksum); index++) {
		if (xConf.updateCounts[index] <= 0 ||
		    xConf.dynamicChecksums[index] != xConf.calcDynamicChecksum(index)) {
		    return false;
		}
	}
	
	// All checks passed, initial replication complete!
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the general Nexgen extension plugin settings.
 *  $PARAM        enableOverlaySkin     Whether the player overlay skin effect is enabled.
 *  $PARAM        enableMapSwitch       Whether the map switch tab is enabled.
 *  $PARAM        enableStartAnnouncer  Whether the game starting voice announcer is enabled.
 *  $PARAM        enableAntiSpam        Whether prevent players from message spamming.
 *  $PARAM        enableClientIDAKALog  Whether to log the client ID's to AKA.
 *  $PARAM        checkForUpdates       Whether to check for new versions of Nexgen.
 *  $PARAM        disableUTAntiSpam     Whether to disable UTs buildin anti spam feature.
 *  $PARAM        enablePerformanceOptimizer  Enable the server performance optimizer.
 *
 **************************************************************************************************/
function setGeneralSettings(bool enableOverlaySkin, bool enableMapSwitch, bool enableStartAnnouncer,
                            bool enableAntiSpam, bool enableClientIDAKALog, bool checkForUpdates,
                            bool disableUTAntiSpam, bool enablePerformanceOptimizer) {
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Save settings.
	xConf.enableOverlaySkin = enableOverlaySkin;
	xConf.enableMapSwitch = enableMapSwitch;
	xConf.enableStartAnnouncer = enableStartAnnouncer;
	xConf.enableAntiSpam = enableAntiSpam;
	xConf.enableClientIDAKALog = enableClientIDAKALog;
	xConf.checkForUpdates = checkForUpdates;
	xConf.disableUTAntiSpam = disableUTAntiSpam;
	xConf.enablePerformanceOptimizer = enablePerformanceOptimizer;
	xConf.saveConfig();
	
	// Notify system.
	xControl.signalConfigUpdate(xConf.CT_GeneralSettings);
	
	// Log action.
	client.showMsg(control.lng.settingsSavedMsg);
	logAdminAction(lng.adminUpdateGeneralSettingsMsg);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the full server redirect settings.
 *  $PARAM        enableFullServerRedirect  Whether full server redirect is enabled.
 *  $PARAM        fullServerRedirectMsg     Message to display when the server is full.
 *  $PARAM        redirectServerName1       First redirect server name.
 *  $PARAM        redirectServerName2       Second redirect server name.
 *  $PARAM        redirectServerName3       Third redirect server name.
 *  $PARAM        redirectURL1              First redirect server address/URL.
 *  $PARAM        redirectURL2              Second redirect server address/URL.
 *  $PARAM        redirectURL3              Third redirect server address/URL.
 *  $PARAM        enableAutoRedirect        Automatically redirect player.
 *
 **************************************************************************************************/
function setFullServerRedirSettings(bool enableFullServerRedirect, string fullServerRedirectMsg,
                                    string redirectServerName1, string redirectServerName2,
                                    string redirectServerName3, string redirectURL1,
                                    string redirectURL2, string redirectURL3,
                                    bool enableAutoRedirect) {

	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Save settings.
	xConf.enableFullServerRedirect = enableFullServerRedirect;
	xConf.fullServerRedirectMsg = left(fullServerRedirectMsg, 250);
	xConf.redirectServerName[0] = left(redirectServerName1, 24);
	xConf.redirectServerName[1] = left(redirectServerName2, 24);
	xConf.redirectServerName[2] = left(redirectServerName3, 24);
	xConf.redirectURL[0] = left(redirectURL1, 64);
	xConf.redirectURL[1] = left(redirectURL2, 64);
	xConf.redirectURL[2] = left(redirectURL3, 64);
	xConf.enableAutoRedirect = enableAutoRedirect;
	xConf.saveConfig();
	
	// Notify system.
	xControl.signalConfigUpdate(xConf.CT_FullServerRedirect);
	
	// Log action.
	client.showMsg(control.lng.settingsSavedMsg);
	logAdminAction(lng.adminFullServerRedirSettingsMsg);
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
 *  $DESCRIPTION  Wrapper function for NexgenController.logAdminAction().
 *  $PARAM        msg           Message that describes the action performed by the administrator.
 *  $PARAM        str1          Message specific content.
 *  $PARAM        str2          Message specific content.
 *  $PARAM        str3          Message specific content.
 *  $PARAM        bNoBroadcast  Whether not to broadcast this administrator action.
 *
 **************************************************************************************************/
function logAdminAction(string msg, optional coerce string str1, optional coerce string str2,
                        optional coerce string str3, optional bool bNoBroadcast) {
	control.logAdminAction(client, msg, client.playerName, str1, str2, str3,
	                       client.player.playerReplicationInfo, bNoBroadcast);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when an instance of this class is destroyed. Automatically cleans up any
 *                remaining objects.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function destroyed() {
	
	// Destroy player overlay.
	if (playerOverlay != none) {
		playerOverlay.destroy();
		playerOverlay = none;
	}
	
	// Client side only.
	if (role == ROLE_SimulatedProxy) {

		// Destroy localization support.
		if (xConf != none) {
			xConf.destroy();
			xConf = none;
		}
		
		// Destroy localization support.
		if (lng != none) {
			lng.destroy();
			lng = none;
		}
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds bots to the current game. A negative amount indicates that bots should be
 *                removed.
 *  $PARAM        amount  The amount of bots to add or remove
 *
 **************************************************************************************************/
function addBots(int amount) {
	local bool bAddBots;
	local int count;
	local Bot bot;
	local string mulStr;
	local DeathMatchPlus game;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchSet) || amount == 0) {
		return;
	}
	
	// Perform action.
	bAddBots = amount > 0;
	if (bAddBots) {
		// Add bots to the game.
		for (count = 0; count < amount; count++) {
			level.game.forceAddBot();
		}
		
	} else {
		// Get DeathMatchPlus game.
		if (level.game.isA('DeathMatchPlus')) {
			game = DeathMatchPlus(level.game);
		}
		
		// Destroy some bots.
	    foreach allActors(class 'Bot', bot) {
	    	if (game != none) {
	    		game.minPlayers = max(game.minPlayers - 1, game.numPlayers + game.numBots - 1);
	    	}
	    	bot.destroy();
	    	count++;
	    	if (count >= -amount) {
	    		break;
	    	}
	    }
	    
	    // Save minPlayers setting.
	    if (game != none) {
	    	if (game.numBots < 1) {
	    		game.minPlayers = 0;
	    	}
	    	game.saveConfig();
	    }
	    	    
	    // Rebalance game if necessary.
	    if (level.game.isA('TeamGamePlus') && TeamGamePlus(level.game).bBalanceTeams) {
	    	TeamGamePlus(level.game).reBalance();
	    }
	}
	
	// Log action.
	if (bAddBots) {
		if (amount != 1) mulStr = "s";
		logAdminAction(lng.adminAddBotsMsg, amount, mulStr);
	} else {
		if (count != 1) mulStr = "s";
		logAdminAction(lng.adminRemoveBotsMsg, count, mulStr);
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
	xControl.announceNewRemainingTime(game.remainingTime);
	
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
	    !class'NexgenXUtil'.static.getTimeInSeconds(remainingTimeStr, remainingTime)) {
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
	xControl.announceNewRemainingTime(remainingTime);
	
	// Log action.
	logAdminAction(lng.adminChangeTimeRemainingMsg, lng.getLongTimeDescription(remainingTime));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the tag protection settings. Note that we can't use an array for the list
 *                of tags to protect, because this will give unexpected behaviour when the function
 *                call is replicated.
 *  $PARAM        enableTagProtection  Whether tag protection should be used or not.
 *  $PARAM        tagsToProtect_0      Tag to protect.
 *  $PARAM        tagsToProtect_1      Tag to protect.
 *  $PARAM        tagsToProtect_2      Tag to protect.
 *  $PARAM        tagsToProtect_3      Tag to protect.
 *  $PARAM        tagsToProtect_4      Tag to protect.
 *  $PARAM        tagsToProtect_5      Tag to protect.
 *
 **************************************************************************************************/
function setTagProtectionSettings(bool enableTagProtection, string tagsToProtect_0,
                                  string tagsToProtect_1, string tagsToProtect_2,
                                  string tagsToProtect_3, string tagsToProtect_4,
                                  string tagsToProtect_5) {
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Save settings.
	xConf.enableTagProtection = enableTagProtection;
	xConf.tagsToProtect[0] = class'NexgenUtil'.static.trim(tagsToProtect_0);
	xConf.tagsToProtect[1] = class'NexgenUtil'.static.trim(tagsToProtect_1);
	xConf.tagsToProtect[2] = class'NexgenUtil'.static.trim(tagsToProtect_2);
	xConf.tagsToProtect[3] = class'NexgenUtil'.static.trim(tagsToProtect_3);
	xConf.tagsToProtect[4] = class'NexgenUtil'.static.trim(tagsToProtect_4);
	xConf.tagsToProtect[5] = class'NexgenUtil'.static.trim(tagsToProtect_5);
	xConf.saveConfig();
	
	// Notify system.
	xControl.signalConfigUpdate(xConf.CT_TagProtectionSettings);
	
	// Log action.
	client.showMsg(control.lng.settingsSavedMsg);
	logAdminAction(lng.adminUpdateTagProtectionSettingsMsg);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client that there is an update for Nexgen available
 *  $PARAM        version  The latest version of Nexgen that is available.
 *
 **************************************************************************************************/
simulated function notifyUpdateAvailable(int version) {
	local int lastNotifiedVersion;
	
	lastNotifiedVersion = int(client.gc.get(SSTR_LastVersionNotify, "0"));

	// Check if the client should be notified of this update.
	if (version > lastNotifiedVersion) {
		client.gc.set(SSTR_LastVersionNotify, string(version));
		client.gc.saveConfig();
		client.showPopup(string(class'NexgenXUpdateNotifyDialog'), string(version));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes a server rule.
 *  $PARAM        index  The rule that is to be changed..
 *  $PARAM        rule   New server rule.
 *
 **************************************************************************************************/
function setServerRule(int index, string rule) {
	// Check rights & parameters.
	if (!client.hasRight(client.R_ServerAdmin) ||
	    index < 0 || index >= arrayCount(xConf.serverRules)) {
		return;
	}
	
	// Save rule.
	xConf.serverRules[index] = class'NexgenUtil'.static.trim(rule);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the server rules settings.
 *  $PARAM        enableServerRules  Whether the server rules should be displayed.
 *
 **************************************************************************************************/
function setServerRulesSettings(bool enableServerRules) {
	local bool bGameRestartRequired;
	
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Check if the game has to be restarted in order to apply the changes.
	bGameRestartRequired = (xConf.enableServerRules != enableServerRules);
	
	// Save settings.
	xConf.enableServerRules = enableServerRules;
	xConf.saveConfig();

	// Notify system.
	xControl.signalConfigUpdate(xConf.CT_ServerRulesSettings);
	
	// Notify client.
	client.showMsg(control.lng.settingsSavedMsg);
	if (bGameRestartRequired) {
		client.showMsg(lng.gameRestartRequiredMsg);
	}
	
	// Log action.
	logAdminAction(lng.adminUpdateServerRulesSettingsMsg);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Shows the server rules at the client.
 *
 **************************************************************************************************/
simulated function showRules(optional bool bAdminForced, optional string reason) {
	local NexgenXRCPServerRulesView rulesViewTab;
	
	if (xConf.enableServerRules) {
		// Get rules view tab.
		rulesViewTab = NexgenXRCPServerRulesView(client.mainWindow.mainPanel.getPanel(class'NexgenXRCPServerRulesView'.default.panelIdentifier));
		if (rulesViewTab == none) {
			rulesViewTab = NexgenXRCPServerRulesView(client.mainWindow.mainPanel.addPanel(lng.serverRulesTabTxt, class'NexgenXRCPServerRulesView', , "server"));
		}
		
		// Set force message.
		if (bAdminForced) {
			rulesViewTab.setAdminForcedViewMessage(reason);
		}
		
		// Show the rules view tab.
		client.showPanel(class'NexgenXRCPServerRulesView'.default.panelIdentifier);
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
	local NexgenXClient xTarget;
	local string logReason;
	
	// Check rights.
	if (!client.hasRight(client.R_Moderate) ||
	    !xConf.enableServerRules) {
		return;
	}
	
	// Get target client.
	target = control.getClientByNum(targetPlayer);
	if (target == none) return;
	xTarget = NexgenXClient(target.getController(class'NexgenXClient'.default.ctrlID));
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
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	ctrlID="ClientExtension"
	bCanModifyHUDStatePanel=true
}