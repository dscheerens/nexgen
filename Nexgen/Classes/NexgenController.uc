/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenController
 *  $VERSION      1.70 (05-12-2010 19:41:15)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  The Nexgen Server Controller.
 *
 **************************************************************************************************/
class NexgenController extends Mutator config(Nexgen);

var config bool bUseExternalConfig;     // Use an external configuration file rather than using the 
                                        // servers system config file.

//var config string language;             // Language to use.

var bool bSpecialMode;                  // Indicates if the server is running in special mode.
                                        // During this mode nexgen is executing a special server
                                        // process and the current game isn't open for players.
var bool bBootSeqFailed;                // True if the Nexgen boot sequence failed.
var bool bServerReloaded;               // Whether the server has been reloaded after a crash.
var bool bIsNexgenBoot;                 // Whether the current map has been loaded by the Nexgen
                                        // boot controller.
var bool bIsAdminReboot;                // Whether the server has been rebooted by an admin using
                                        // the Nexgen control panel.

var NexgenConfig sConf;                 // Server configuration.
var NexgenClient clientList;            // First client of the linked client list.
var NexgenCommandHandler cmdHandler;    // Handles the execution of nexgen commands.
var NexgenGameInfo gInf;                // Extended game info.
var NexgenLang lng;                     // Language instance to support localization.
var NexgenPlugin plugins[16];           // Controller plugins.
var NexgenTeamBalancer teamBalancer;    // Team balancer.
var NexgenPlayerData playerDataList;    // First player data object of the linked player data list.
var class<NexgenClientLoginHandler> loginHandler; // Client login handler.
var NexgenLogEntry logBuffer;           // Buffered log messages.
var NexgenLogFile logFile;              // The log file.

var int nextPlayerNum;                  // Next client ID num.

var int joinOverrideCodes[8];           // Override codes for players trying to enter a locked game.
var float overrideCodeLeaseTimes[8];    // Time at which an override code was leased.
const maxOverrideCodeLeaseTime = 15.0;  // Maximum time an override code is valid.
const joinOverrideCodeOption = "NXOC";  // Player login option name of the login override code.

var bool bUTPureEnabled;                // Whether UTPure has been found on the server.

// Event detection support variables.
var float lastTimeDilation;             // Last known time dilation value.
var bool bServerTravelDetected;         // Has the server travel been detected?
var bool bForcedGameEnd;                // Has the game been forced to an end?

// Timer control.
var float virtualTimerCounter;          // Just like Actor.TimerCounter for our virtual timer.
var float timeSeconds;                  // Just like level.timeSeconds, but independent of the gamespeed.
var bool bFirstTickPassed;              // Whether the first tick has been executed.

// Timings.
var float lastPlayerLeftTime;           // Time at which the last player has left the server.
var float gameStartTime;                // Time at which the game has started.
var float gameEndTime;                  // Time at which the game has ended.

// Controller settings.
const logTag = 'NSC';                   // Console log tag.
const timerFreq = 10.0;                 // Frequency of the main timer in Hz.
const serverPauserName = "server";      // Name to use for level.pauser when the server pauses the
                                        // game instead of a player.
const maxBootAttempts = 5;              // Maximum number of times Nexgen may try to boot from a
                                        // random map.

// Nexgen commands.
const CMD_Prefix       = "NSC";
const CMD_SwitchTeam   = "SETTEAM";
const CMD_BalanceTeams = "BALANCETEAMS";
const CMD_Play         = "PLAY";
const CMD_Spectate     = "SPECTATE";
const CMD_StartGame    = "START";
const CMD_Exit         = "EXIT";
const CMD_Disconnect   = "DISCONNECT";
const CMD_Open         = "OPENRCP";
const CMD_OpenVote     = "OPENVOTE";
const CMD_Pause        = "PAUSE";

// Console commands.
const rebootCommand = "debug gpf";      // Server console command for rebooting the server.

// Damage types.
const suicideDamageType = 'Suicided';
const fallDamageType = 'Fell';
const burnDamageType = 'Burned';
const corrodeDamageType = 'CorrodedMessage';

// Log types.
const LT_System = 0;                    // Nexgen system generated log message.
const LT_Event = 1;                     // Nexgen broadcasted message.
const LT_Message = 2;                   // Mutator broadcasted message.
const LT_Say = 3;                       // Normal chat message.
const LT_TeamSay = 4;                   // Team say chat message.
const LT_PrivateMsg = 5;                // Private chat message.
const LT_AdminAction = 6;               // Admin actions.

// Reject types.
const RT_IllegalLoginParameters = 'illegallogin';
const RT_DuplicateID = 'duplicateid';
const RT_Banned = 'banned';
const RT_InvalidPassword = 'invalidpass';
const RT_ServerFull = 'serverfull';
const RT_NoPlayRight = 'noplayright';

// Misc constants.
const secondsPerMinute = 60;            // The number of seconds in a minute.
const wildcardToken = "*";              // Token used to denote a wildcard.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Starts the Nexgen server controller.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	local int index;
	
	// Load language localization support.
	lng = spawn(class'NexgenLang');
	nscLog(lng.startingControllerMsg);
	
	// Check server mode.
	if (level.netMode != NM_DedicatedServer) {
		nscLog(lng.noDedicatedServerMsg);
		destroy();
		return;
	}
	
	// Load settings.
	if (bUseExternalConfig) {
		sConf = spawn(class'NexgenConfigExt', self);
	} else {
		sConf = spawn(class'NexgenConfigSys', self);
	}
	if (!sConf.bInstalled) {
		nscLog(lng.autoInstallMsg);
		sConf.install();
	}
	
	// Update configuration to current version.
	if (sConf.lastInstalledVersion < class'NexgenUtil'.default.versionCode) {
		nscLog(lng.format(lng.autoUpdateMsg, left(string(class'NexgenUtil'.default.version), 4)));
		sConf.updateConfig();
	}
	
	// Check configuration.
	if (!sConf.checkConfig()) {
		nscLog(lng.invalidConfigMsg);
	}
	
	// Check boot status.
	bIsNexgenBoot = sConf.isNexgenBoot;
	if (isFirstGame() || bIsNexgenBoot) {
		bServerReloaded = true;
		bIsAdminReboot = sConf.isAdminReboot;
	}
	
	// Check if nexgen boot should be executed.
	if (isFirstGame() && (sConf.enableBootControl ||
	    sConf.enableMatchBootControl && sConf.matchModeActivated)) {
		nscLog(lng.nexgenBootMsg);
		
		// Execute Nexgen boot.
		bSpecialMode = doNexgenBoot();
		
		// Check if Nexgen boot has been initialized.
		if (bSpecialMode) {
			// Yes, stop the initialization process.
			sConf.isNexgenBoot = true;
			sConf.saveConfig();
			level.nextSwitchCountdown = 0; // We do not wish to wait another 4 seconds.
			return;
		} else {
			// No, continue in normal mode.
			nscLog(lng.nexgenBootFailMsg);
			bBootSeqFailed = true;
		}
	}
	
	// Clear admin reboot flag.
	if (bServerReloaded) {
		sConf.isAdminReboot = false;
	}
	
	// Post initialize (replication) info.
	sConf.postInitialize();
	nscLog(lng.format(lng.attrServerIDMsg, class'NexgenUtil'.static.formatGUID(sConf.serverID)));
	
	// Begin file logging (if enabled).
	if (sConf.logToFile) {
		logFile = spawn(class'NexgenLogFile', self);
	}
	clearLogBuffer();
	
	// Apply configuration.
	applyConfig();
	
	// Setup current game.
	initGameInfo();
	
	// Setup for Nexgen controlled game state.
	if (sConf.enableNexgenStartControl) {
		DeathMatchPlus(level.game).bNetReady = false;
		if (bUTPureEnabled) {
			// Disable UTPure warmup, which doesn't work with NSC.
			DeathMatchPlus(level.game).countDown = 1;
		}
	}
	
	// Load command handler.
	cmdHandler = spawn(class'NexgenCommandHandler', self);
	
	// Load team balancer.
	if (level.game.isA('TeamGamePlus')) {
		teamBalancer = spawn(class'NexgenTeamBalancer', self);
	}
	
	// Register controller.
	nextMutator = level.game.baseMutator;
	level.game.baseMutator = self;
	level.game.registerMessageMutator(self);
	level.game.registerDamageMutator(self);
	
	// Set join override codes.
	for (index = 0; index < arrayCount(joinOverrideCodes); index++) {
		joinOverrideCodes[index] = -1;
	}
	
	// Load core plugin.
	spawn(class'NexgenCorePlugin', self);
	
	// Let mutator class initialize.
	super.preBeginPlay();
	
	// Make sure the checksums are up to date.
	sConf.updateDynamicChecksums();
	sConf.updateStaticChecksum();
	
	// Get time dilation value.
	lastTimeDilation = level.timeDilation;
	
	// Set client login handler class.
	loginHandler = class'NexgenClientLoginHandler';
	
	// Start running the main loop (via a timer).
	setTimer(1.0 / timerFreq * level.timeDilation, true);	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether this is the first game played since the server was started.
 *  $RETURN       True if this is the the first game, false if not.
 *
 **************************************************************************************************/
function bool isFirstGame() {
	return getURLMap() == "";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Starts the Nexgen boot sequence.
 *  $RETURN       True if the boot sequence was successfully executed, false if not.
 *
 **************************************************************************************************/
function bool doNexgenBoot() {
	local class<GameInfo> gameTypeClass;
	local string randomMap;
	local string bootURL;
	local string remaining;
	local string command;
	local string result;
	local int attempts;
	local bool bMapLoaded;
	
	// Check boot method.
	if (sConf.restartOnLastGame ||
	    sConf.enableMatchBootControl && sConf.matchModeActivated) {
		
		// Last game + map.
		
		// Check last server url.
		if (sConf.lastServerURL == "") {
			return false; // Invalid URL.
		}
		
		// Perform the map switch.
		level.serverTravel(sConf.lastServerURL, false);
		
	} else {
		// Custom game + random map.
	
		// Check if game class exists.
		gameTypeClass = class<GameInfo>(dynamicLoadObject(sConf.bootGameType, class'Class'));
		if (gameTypeClass == none) {
			return false; // Game class doesn't exist.
		}
		
		// Select a random map.
		while (!bMapLoaded && attempts < maxBootAttempts) {
			randomMap = selectRandomBootMap();
			if (randomMap != "") {
				bMapLoaded = preloadMap(randomMap);
				if (!bMapLoaded) {
					nscLog(lng.format(lng.nexgenMapLoadFailMsg, randomMap));
				}
			}
			attempts++;
		}
		
		if (!bMapLoaded) {
			return false; // Failed to load a map.
		}
		
		// Execute pre switch commands.
		remaining = sConf.bootCommands;
		while (remaining != "") {
			class'NexgenUtil'.static.split(remaining, command, remaining);
			nscLog(lng.format(lng.execCommandMsg, command));
			result = consoleCommand(command);
			if (result != "") {
				nscLog("> " $ result);
			}
		}
		
		// Assemble boot command line string.
		bootURL = randomMap $ "?game=" $ sConf.bootGameType $ "?mutator=" $ sConf.bootMutators $
		          sConf.bootOptions;
	
		// Perform the map switch.
		nscLog(lng.format(lng.bootLevelSwitchMsg, randomMap));
		level.serverTravel(bootURL, false);
	}
	
	// Boot sequence successfully executed.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Selects a random map matching the boot map prefix.
 *  $RETURN       The filename of the randomly selected map.
 *
 **************************************************************************************************/
function string selectRandomBootMap() {
	local string mapName;
	local string firstMap;
	local string shortMapName;
	local bool bFirst;
	local int mapCount;
	local int index;
	local int randomMapIndex;
	local string randomMap;
	
	// Count number of maps with the specified prefix.
	mapName = getMapName("", "", 0);
	firstMap = mapName;
	bFirst = true;
	while(mapName != "" && (bFirst || mapName != firstMap)) {
		bFirst = false;

		// Valid map?
		if (left(mapName, len(sConf.bootMapPrefix) + 1) ~= (sConf.bootMapPrefix $ "-") &&
			class'NexgenUtil'.static.isValidLevel(mapName)) {
			mapCount++;
		}
		
		mapName = getMapName("", mapName, 1);
	}
	
	// Cancel if there are no matching maps.
	if (mapCount == 0) {
		return "";
	}
	
	// Select random map.
	randomMapIndex = rand(mapCount);
	mapName = getMapName("", "", 0);
	firstMap = mapName;
	bFirst = true;
	while(mapName != "" && (bFirst || mapName != firstMap) && randomMap == "") {
		bFirst = false;

		// Valid map?
		if (left(mapName, len(sConf.bootMapPrefix) + 1) ~= (sConf.bootMapPrefix $ "-") &&
		    class'NexgenUtil'.static.isValidLevel(mapName)) {
			if (index == randomMapIndex) {
				randomMap = mapName;
			}
			index++;
		}
		
		mapName = getMapName("", mapName, 1);
	}
	
	// Return result.
	return randomMap;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Preloads the specified map.
 *  $REQUIRE      mapName != ""
 *  $RETURN       True if the specified map was successfully loaded, false if not.
 *
 **************************************************************************************************/
function bool preloadMap(string mapName) {
	local object levelSummary;
	local string lvlSummaryObjectStr;
	local int index;
	
	// Get level summary object name.
	index = instr(mapName, ".");
	if (index >= 0) {
		lvlSummaryObjectStr = left(mapName, index);
	} else {
		lvlSummaryObjectStr = mapName;
	}
	lvlSummaryObjectStr = lvlSummaryObjectStr $ ".LevelSummary";
	
	// Attempt to load level summary.
	levelSummary = dynamicLoadObject(lvlSummaryObjectStr, class'LevelSummary', true);
	
	// Return result.
	return levelSummary != none;
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Applies the current configuration to the server.
 *  $REQUIRE      sConf != none
 *
 **************************************************************************************************/
function applyConfig() {
	// Apply global server settings.
	consoleCommand("set Engine.GameInfo GamePassword" @ sConf.decode(sConf.CS_GlobalServerSettings, sConf.globalServerPassword));
	consoleCommand("set Engine.GameInfo AdminPassword" @ sConf.decode(sConf.CS_GlobalServerSettings, sConf.globalAdminPassword));
	level.game.gameReplicationInfo.serverName = sConf.serverName;
	level.game.gameReplicationInfo.shortName = sConf.shortName;
	level.game.gameReplicationInfo.adminName = sConf.adminName;
	level.game.gameReplicationInfo.adminEmail = sConf.adminEmail;
	if (!sConf.variablePlayerSlots) {
		level.game.maxPlayers = sConf.playerSlots + sConf.vipSlots + sConf.adminSlots;
	}
	level.game.maxSpectators = sConf.spectatorSlots;
	if (sConf.enableUplink) {
		consoleCommand("set IpServer.UdpServerUplink DoUplink True");
	} else {
		consoleCommand("set IpServer.UdpServerUplink DoUplink False");
	}
	level.game.gameReplicationInfo.MOTDLine1 = sConf.MOTDLine[0];
	level.game.gameReplicationInfo.MOTDLine2 = sConf.MOTDLine[1];
	level.game.gameReplicationInfo.MOTDLine3 = sConf.MOTDLine[2];
	level.game.gameReplicationInfo.MOTDLine4 = sConf.MOTDLine[3];
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the extended game (replication) info.
 *  $REQUIRE      sConf != none
 *  $ENSURE       gInf != none
 *
 **************************************************************************************************/
function initGameInfo() {
	// Setup current game.
	gInf = spawn(class'NexgenGameInfo', self);
	gInf.gameState = gInf.GS_Waiting;
	gInf.countDown = sConf.waitTime;
	gInf.gameSpeed = level.game.gameSpeed;
	if (level.game.isA('TeamGamePlus')) {
		gInf.maxTeams = TeamGamePlus(level.game).maxTeams;
	}
	gInf.bNoTeamSwitch = !sConf.allowTeamSwitch;
	gInf.bNoTeamBalance = !sConf.allowTeamBalance;
	gInf.bNoNameChange = !sConf.allowNameChange;
	gInf.updateCount = 1;
	if (level.game.isA('DeathMatchPlus')) {
		gInf.bTournamentMode = DeathMatchPlus(level.game).bTournament;
		if (sConf.enableNexgenStartControl) {
			doTournamentModeReadySignalCheck();
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Registers a new controller plugin. Since there a limit to the amount of plugins
 *                this action may fail.
 *  $PARAM        plugin  The plugin to register.
 *  $REQUIRE      plugin != none
 *  $RETURN       True if the plugin was succesfully added to the server controller, false if the
 *                plugin limit has been reached.
 *
 **************************************************************************************************/
function bool registerPlugin(NexgenPlugin plugin) {
	local bool bFound;
	local int index;
	
	// Locate empty slot.
	while (!bFound && index < arrayCount(plugins)) {
		if (plugins[index] == none) {
			bFound = true;
			plugins[index] = plugin; // Store plugin in this free slot.
		} else {
			index++;
		}
	}
	
	// Return result.
	return bFound;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles the connection of a new client.
 *  $PARAM        client  The playerpawn instance of the new client.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function newClient(PlayerPawn client) {
	local NexgenClient clientHandler;
	local int index;
	
	// Create new client handler.
	clientHandler = spawn(class'NexgenClient', client);
	
	// Set attributes.
	clientHandler.serverID = sConf.serverID;
	clientHandler.control = self;
	clientHandler.sConf = sConf;
	clientHandler.gInf = gInf;
	clientHandler.lng = lng;
	clientHandler.playerNum = nextPlayerNum++;
	clientHandler.loginHandler = loginHandler;
	clientHandler.loginHandlerChecksum = class'NexgenUtil'.static.stringHash(string(loginHandler));
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].clientCreated(clientHandler);
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player attempts to login to the server. Allows mutators to modify
 *                some of the login parameters.
 *  $PARAM        spawnClass  The PlayerPawn class to use for the player.
 *  $PARAM        portal      Name of the portal where the player wishes to spawn.
 *  $PARAM        option      Login option parameters.
 *
 **************************************************************************************************/
function modifyLogin(out class<playerpawn> spawnClass, out string portal, out string options) {
	local int overrideCode;
	local int index;
	
	// Only continue if the login wasn't denied.
	if (spawnClass == none) {
		return;
	}
	
	// Check if the player isn't allowed to join the game as player.
	overrideCode = level.game.getIntOption(options, joinOverrideCodeOption, -1);
	if (gInf.bTeamsLocked && !isValidJoinOverrideCode(overrideCode)) {
		spawnClass = class'Botpack.CHSpectator';
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].modifyLogin(spawnClass, portal, options);
		index++;
	}

	// Allow other mutators to do their job.	
	if (nextMutator != none) {
		nextMutator.modifyLogin(spawnClass, portal, options);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the given login override code is correct.
 *
 **************************************************************************************************/
function bool isValidJoinOverrideCode(int overrideCode) {
	local bool bValid;
	local bool bInvalid;
	local int index;
	
	// Check override code.
	while (!bValid && !bInvalid && index < arrayCount(joinOverrideCodes)) {
		if (joinOverrideCodes[index] == overrideCode) {
			// Check if lease has expired.
			if (timeSeconds - overrideCodeLeaseTimes[index] <= maxOverrideCodeLeaseTime) {
				bValid = true;
			} else {
				bInvalid = true;
			}
			
			// Clear override code.
			joinOverrideCodes[index] = -1;
			overrideCodeLeaseTimes[index] = 0;
		} else {
			index++;
		}
	}
	
	// Return result.
	return bValid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Gives the specified client a login override code, so he or she can join a locked
 *                game as player.
 *
 **************************************************************************************************/
function giveJoinOverrideCode(NexgenClient client) {
	local int index;
	local bool bFound;
	
	// Find a free slot.
	while (!bFound && index < arrayCount(joinOverrideCodes)) {
		// Check if current slot is free.
		if (joinOverrideCodes[index] < 0 ||
		    timeSeconds - overrideCodeLeaseTimes[index] > maxOverrideCodeLeaseTime) {
			// Slot is free, use this one.
			bFound = true;
		} else {
			// Nope, maybe next one.
			index++;
		}
	}
	
	// Create override code & send to client.
	if (bFound) {
		joinOverrideCodes[index] = rand(maxInt);
		overrideCodeLeaseTimes[index] = timeSeconds;
		client.updateLoginOption(joinOverrideCodeOption, joinOverrideCodes[index]);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks if the login request of the specified client should be accepted. If the
 *                request is rejected, this function will automatically kill the client.
 *  $PARAM        client  The client whose login request is to be checked.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function checkLogin(NexgenClient client) {
	local string password;
	local bool bRejected;
	local string reason;
	local string banReason;
	local string banPeriod;
	local bool allowSpecReconnect;
	local int index;
	local int k0, k1, k2;
	local string cs0, cs1, cs2;
	local name rejectType;
	local string popupWindowClass;
	local string popupArgs[4];
	
	// Get login options.
	password = class'NexgenUtil'.static.getProperty(client.loginOptions, client.SSTR_ServerPassword);
	
	// Check login parameters.
	if (!loginHandler.static.checkLoginParameters(client)) {
		bRejected = true;
		rejectType = RT_IllegalLoginParameters;
		reason = lng.illegalLoginParametersMsg;
		popupWindowClass = "NexgenIllegalLoginDialog";
	}
	
	// Log the login request.
	nscLog(lng.format(lng.loginRequestMsg, client.playerName));
	nscLog(lng.format(lng.attrClientIPMsg, client.ipAddress));
	nscLog(lng.format(lng.attrClientIDMsg, class'NexgenUtil'.static.formatGUID(client.playerID)));
	if (password != "") {
		nscLog(lng.format(lng.attrPasswordMsg, password));
	}
	
	// Check for duplicate ID's.
	if ((!bRejected) && !hasUniqueKey(client)) {
		bRejected = true;
		rejectType = RT_DuplicateID;
		reason = lng.duplicateIDMsg;
		popupWindowClass = "NexgenIDUsedDialog";
	}
	
	// Check for bans.
	if ((!bRejected) && isBanned(client, banReason, banPeriod)) {
		bRejected = true;
		rejectType = RT_Banned;
		reason = lng.bannedMsg;
		popupWindowClass = "NexgenBannedDialog";
		popupArgs[0] = banReason;
		popupArgs[1] = banPeriod;
	}
	
	// Check password.
	if ((!bRejected) && (sConf.matchModeActivated) && (sConf.serverPassword != "") &&
	    (password != sConf.decode(sConf.CS_MatchSettings, sConf.serverPassword)) && (!client.hasRight(client.R_NeedsNoPW)) &&
	    (!client.bSpectator || sConf.spectatorsNeedPassword)) {
		bRejected = true;
		rejectType = RT_InvalidPassword;
		reason = lng.invalidPassMsg;
		allowSpecReconnect = !client.bSpectator && !sConf.spectatorsNeedPassword;
		popupWindowClass = "NexgenPasswordDialog";
		popupArgs[0] = string(allowSpecReconnect);
	}
	
	// Check slots.
	if ((!bRejected) && !canGetSlot(client)) {
		bRejected = true;
		rejectType = RT_ServerFull;
		reason = lng.serverCapacityMsg;		
		popupWindowClass = "NexgenServerFullDialog";
		popupArgs[0] = string(sConf.playerSlots);
		popupArgs[1] = string(sConf.vipSlots);
		popupArgs[2] = string(sConf.adminSlots);
	}

	// Check play rights.
	if ((!bRejected) && (!client.bSpectator) && (!client.hasRight(client.R_MayPlay))) {
		bRejected = true;
		rejectType = RT_NoPlayRight;
		reason = lng.noPlayRightMsg;
		popupWindowClass = "NexgenNoPlayRightDialog";
	}
	
	// Get player data object for this client.
	setPlayerData(client);
	
	// Check with plugins.
	while (!bRejected && index < arrayCount(plugins) && plugins[index] != none) {
		bRejected = !plugins[index].checkLogin(client, rejectType, reason, popupWindowClass, popupArgs);
		index++;
	}
	
	// Accept or reject player.
	if (bRejected) {
		// Allow plugins to modify the rejection of this player.
		index = 0;
		while (index < arrayCount(plugins) && plugins[index] != none) {
			plugins[index].modifyLoginReject(client, rejectType, reason, popupWindowClass, popupArgs);
			index++;
		}
		
		// Reject the player.
		if (popupWindowClass != "") {
			client.showPopup(popupWindowClass, popupArgs[0], popupArgs[1], popupArgs[2], popupArgs[3]);
		}
		disconnectClient(client);
		nscLog(lng.format(lng.loginRejectedMsg, reason));
	
	} else {
		// Send encryption paramters.
		if (client.shouldGetEncryptionParams(0)) sConf.getEncryptionParams(0, k0, cs0);
		if (client.shouldGetEncryptionParams(1)) sConf.getEncryptionParams(1, k1, cs1);
		if (client.shouldGetEncryptionParams(2)) sConf.getEncryptionParams(2, k2, cs2);
		client.setEncryptionParams(k0, cs0, k1, cs1, k2, cs2);
		
		// Signal events.
		nscLog(lng.loginAcceptedMsg);
		playerJoined(client);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks if the player ID of the specified client is unique.
 *  $PARAM        client  The client whose player ID is to be checked.
 *  $REQUIRE      client != none
 *  $RETURN       True none of the other clients has the same player ID, false otherwise.
 *
 **************************************************************************************************/
function bool hasUniqueKey(NexgenClient client) {
	local bool bUnique;
	local NexgenClient currClient;
	
	// Compare each ID of the other clients with the ID of the specified client.
	bUnique = true;
	currClient = clientList;
	while (bUnique && currClient != none) {
		// Same ID?
		if (currClient != client && currClient.playerID ~= client.playerID) {
			bUnique = false;
		}
		
		// Compare ID with the next client.
		currClient = currClient.nextClient;
	}
	
	// Return result.
	return bUnique;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks if the specified client is banned on this server.
 *  $PARAM        client     The client for which the ban is to be checked.
 *  $PARAM        banReason  Description of why the client was banned.  
 *  $PARAM        banPeriod  Textual description indicating how long the player is banned.
 *  $REQUIRE      client != none
 *  $RETURN       True if the client is banned, false if not.
 *  $ENSURE       result == true ? new.banPeriod != "" : true
 *
 **************************************************************************************************/
function bool isBanned(NexgenClient client, out string banReason, out string banPeriod) {
	local int banIndex;
	local bool bBanned;
	
	// Get ban entry.
	banIndex = sConf.getBanIndex(client.playerName, client.ipAddress, client.playerID);
	
	// Check if player is banned and the ban hasn't expired.
	if (banIndex >= 0) {
		if (sConf.autoUpdateBans) {
			if (sConf.updateBan(banIndex, client.ipAddress, client.playerID)) {
				// Ban entry was changed, update dynamic config data checksum & notify clients.
				signalConfigUpdate(sConf.CT_BanList);
			}
		}
		banReason = sConf.banReason[banIndex];
		banPeriod = lng.getBanPeriodDescription(sConf.banPeriod[banIndex]);
		bBanned = !sConf.isExpiredBan(banIndex);
	}
	
	// Return result.
	return bBanned;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks if the specified client can get a player slot on the server, i.e. the
 *                server isn't full for this client.
 *  $PARAM        client  The client for which is to be checked if a slot available.
 *  $REQUIRE      client != none
 *  $RETURN       True if there is an empty slot available that the specified client may occupy,
 *                false if not.
 *
 **************************************************************************************************/
function bool canGetSlot(NexgenClient client) {
	local NexgenClient currClient;
	local bool hasVIPSlotAccess;
	local bool hasAdminSlotAccess;
	local int playerCount;
	local int vipCount;
	local int adminCount;
	local int vipAdminCount;
	local int specialSlotsUsed;

	// Spectators can always get a slot.
	if (client.bSpectator) {
		return true;
	}

	// Count used slots.
	currClient = clientList;
	while (currClient != none) {
		// Count all players, except the specified client and spectators.
		if (currClient != client && !currClient.bSpectator) {
			hasVIPSlotAccess = currClient.hasRight(client.R_VIPAccess);
			hasAdminSlotAccess = currClient.hasRight(client.R_AdminAccess);
			
			if (hasVIPSlotAccess && hasAdminSlotAccess) {
				vipAdminCount++;
			} else if (hasVIPSlotAccess) { 
				vipCount++;
			} else if (hasAdminSlotAccess) {
				adminCount++;
			} else {
				playerCount++;
			}
		}
		
		// Next player.
		currClient = currClient.nextClient;
	}
	
	// Get slot access level for the specified client.
	hasVIPSlotAccess = client.hasRight(client.R_VIPAccess);
	hasAdminSlotAccess = client.hasRight(client.R_AdminAccess);
	
	// Check slot access.
	if (hasVIPSlotAccess && hasAdminSlotAccess) {
		return (playerCount + vipCount + adminCount + vipAdminCount) <
		       (sConf.playerSlots + sConf.vipSlots + sConf.adminSlots);
	} else if (hasVIPSlotAccess) {
		specialSlotsUsed = max(0, vipAdminCount - (sConf.adminSlots - adminCount)) + vipCount;
		return (playerCount + specialSlotsUsed) < (sConf.playerSlots + sConf.vipSlots);
	} else if (hasAdminSlotAccess) {
		specialSlotsUsed = max(0, vipAdminCount - (sConf.vipSlots - vipCount)) + adminCount;
		return (playerCount + specialSlotsUsed) < (sConf.playerSlots + sConf.adminSlots);
	} else {
		return playerCount < sConf.playerSlots;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the player data object for the specified client.
 *  $PARAM        client  The client for which the player data object has to be set.
 *  $REQUIRE      client != none
 *  $ENSURE       client.pDat != none && client.pDat.clientID ~= client.playerID
 *
 **************************************************************************************************/
function setPlayerData(NexgenClient client) {
	local NexgenPlayerData pDat;
	local bool bFound;
	
	// Search for saved player data object for this client.
	pDat = playerDataList;
	while (!bFound && pDat != none) {
		if (pDat.clientID ~= client.playerID) {
			bFound = true;
		} else {
			pDat = pDat.next;
		}
	}
	
	// Create player data object if necessary.
	if (!bFound) {
		// Create & initialize player data object.
		pDat = spawn(class'NexgenPlayerData', self);
		pDat.clientID = client.playerID;
		
		// Add player data object to the list
		pDat.next = playerDataList;
		playerDataList = pDat;
	}
	
	// Set player data object for the client.
	client.pDat = pDat;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Disconnects the specified client from this server.
 *  $PARAM        client  The client that is to be disconnected from the server.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function disconnectClient(NexgenClient client) {

	// Remove client from the client list.
	removeClientHandler(client);
	
	// Close connection.
	client.player.destroy(); // Is this safe? At least thats how Epic does it.
	client.destroy();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the specified client from the client list.
 *  $PARAM        client  The client that is to be removed.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function removeClientHandler(NexgenClient client) {
	local NexgenClient currClient;
	local bool bDone;
	
	// Remove the client from the linked client list.
	if (clientList == client) {
		// First element in the list.
		clientList = client.nextClient;
	} else {
		// Somewhere else in the list.
		currClient = clientList;
		while (!bDone && currClient != none) {
			if (currClient.nextClient == client) {
				bDone = true;
				currClient.nextClient = client.nextClient;
			} else {
				currClient = currClient.nextClient;
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player (re)spawns and allows us to modify the player.
 *  $PARAM        other  The pawn/player that has (re)spawned.
 *  $REQUIRE      other != none
 *
 **************************************************************************************************/
function modifyPlayer(Pawn other) {
	local NexgenClient client;
	local int index;
	
	// Detect game start.
	if (!sConf.enableNexgenStartControl && DeathMatchPlus(level.game).bStartMatch &&
	    gInf.gameState == gInf.GS_Waiting) {
		gInf.gameState = gInf.GS_Playing;
		gameStarted();
	}
	
	// Get client.
	client = getClient(other);
	
	// Signal event.
	if (client != none) {
		// Signal event on client.
		client.respawned();
		
		// Notify plugins.
		while (index < arrayCount(plugins) && plugins[index] != none) {
			plugins[index].playerRespawned(client);
			index++;
		}
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].modifyPlayer(other);
		index++;
	}
	
	// Let other mutators do their job.
	if (nextMutator != none) {
		nextMutator.modifyPlayer(other);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Accepts the login request for the specified client.
 *  $PARAM        client  The client whose login request has been accepted.
 *  $REQUIRE      client != none && !client.loginComplete
 *
 **************************************************************************************************/
function playerJoined(NexgenClient client) {
	local int index;
	local bool bFound;
	
	// Add client to the client list.
	client.nextClient = clientList;
	clientList = client;
	
	// Set player team if auto separate is enabled.
	if (!client.bSpectator && level.game.isA('TeamGamePlus') &&
	    sConf.matchModeActivated && sConf.matchAutoSeparate) {
		while (!bFound && index < arrayCount(sConf.tagsToSeparate) &&
		       index < TeamGamePlus(level.game).maxTeams) {
			// Check if player has a tag that separates him/her.
			if (sConf.tagsToSeparate[index] != "" &&
			    instr(caps(client.playerName), caps(sConf.tagsToSeparate[index])) >= 0) {
				bFound = true;
				if (client.player.playerReplicationInfo.team != index) {
					client.setTeam(index);
				}
			} else {
				index++;
			}
		}
	}
	
	// Update client attributes.
	client.team = client.player.playerReplicationInfo.team;
	client.lastSwitchTime = timeSeconds;
	client.loginComplete = true;
	if (gInf.gameState == gInf.GS_Playing && !client.bSpectator) {
		client.spawnProtectionTimeX = sConf.spawnProtectionTime;
	}
	
	// Update game info.
	if (client.hasRight(client.R_MatchAdmin)) {
		gInf.matchAdminCount++;
	}
	
	// Notify plugins.
	index = 0;
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].playerJoined(client);
		index++;
	}
	
	// Notify other players.
	broadcastMsg(lng.playerJoinMsg, client.playerName, client.title, , , client.player.playerReplicationInfo);
	
	// Update tournament start status.
	if (sConf.enableNexgenStartControl && gInf.bTournamentMode && gInf.gameState == gInf.GS_Ready) {
		doTournamentModeReadySignalCheck();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles the events where a client has been initialized.
 *  $PARAM        client  The client that has just been initialized.
 *  $REQUIRE      client != none && client.loginComplete
 *
 **************************************************************************************************/
function clientInitialized(NexgenClient client) {
	local int index;
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].clientInitialized(client);
		index++;
	}
	
	// Show message if the server has crashed.
	if (bServerReloaded && gInf.gameState < gInf.GS_Playing) {
		if (bIsAdminReboot) {
			client.showMsg(lng.serverAdminRebootClientMsg);
		} else {
			client.showMsg(lng.serverCrashedClientMsg);
		}
	}
	
	// Send warning to the client in case the Nexgen boot sequence has failed.
	if (bBootSeqFailed) {
		client.showMsg(lng.bootFailedClientMsg);
	}
	
	// Show game is ready to launch message.
	if (gInf.gameState == gInf.GS_Ready) {
		showGameReadyToLaunchMessage(client);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles the leaving of the specified client.
 *  $PARAM        client  The client that has left the server.
 *  $REQUIRE      client.owner == none
 *
 **************************************************************************************************/
function playerLeft(NexgenClient client) {
	local int index;
	
	// Remove client from the client list.
	removeClientHandler(client);
	
	// Clear player data (data should be added by the plugins).
	client.pDat.clearData();
	
	// Update game info.
	if (client.hasRight(client.R_MatchAdmin)) {
		gInf.matchAdminCount--;
	}
	lastPlayerLeftTime = timeSeconds;
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].playerLeft(client);
		index++;
	}
	
	// Notify other players.
	broadcastMsg(lng.playerLeaveMsg, client.playerName, client.title);
	
	// Log event.
	nscLog(lng.format(lng.playerLeaveLogMsg, client.playerName));
	
	// Pause the game?
	if (sConf.matchModeActivated && sConf.matchAutoPause && clientList != none &&
	    gInf.gameState == gInf.GS_Playing && gInf.matchAdminCount > 0 && !client.bSpectator) {
		level.pauser = serverPauserName;
	}
	
	// Unpause the game?
	if (level.pauser != "" && gInf.matchAdminCount == 0) {
		//level.pauser = "";
	}
	
	// Update tournament start status.
	if (sConf.enableNexgenStartControl && gInf.bTournamentMode && gInf.gameState == gInf.GS_Ready) {
		clearReadySignals();
		doTournamentModeReadySignalCheck();
	}
	
	// No longer need the client handler.
	client.destroy();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deals with a client that has changed his/her name during the game.
 *  $PARAM        client  The client that has changed his/her name.
 *  $REQUIRE      client.playerName != client.player.playerReplicationInfo.playerName
 *
 **************************************************************************************************/
function playerNameChanged(NexgenClient client) {
	local bool bAllowChange;
	local string reason;
	local string oldName;
	local int index;
	local bool bWasForcedChanged;

	// Check if the name change should be allowed.
	if (timeSeconds - client.nameChangeOverrideTime <= client.maxOverrideTime) {
		client.nameChangeOverrideTime = 0; // Clear admin override flag.
		bAllowChange = true;
		bWasForcedChanged = true;
	} else if (gInf.bNoNameChange) {
		reason = lng.nameChangeDisabled;
	} else {
		bAllowChange = true;
	}
	
	// Update name if allowed.
	if (bAllowChange) {
		// Update player name.
		oldName = client.playerName;
		client.playerName = client.player.playerReplicationInfo.playerName;
		
		// Notify plugins.
		while (index < arrayCount(plugins) && plugins[index] != none) {
			plugins[index].playerNameChanged(client, oldName, bWasForcedChanged);
			index++;
		}
		
		// Notify other players.
		if (!bWasForcedChanged && oldName != client.player.playerReplicationInfo.playerName) {
			broadcastMsg(lng.playerNameChangeMsg, oldName, client.playerName, , , client.player.playerReplicationInfo);
		}
		
	} else {
		// Reset original name.
		client.changeName(client.playerName);
		sendMsg(client, lng.nameChangeFailMsg, reason);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deals with a client that has switched to another team.
 *  $PARAM        client  The client that has changed team.
 *  $REQUIRE      client.team != client.player.playerReplicationInfo.team
 *
 **************************************************************************************************/
function playerTeamChanged(NexgenClient client) {
	local bool bAllowSwitch;
	local string reason;
	local int index;
	
	// Restore players score?
	if (sConf.restoreScoreOnTeamSwitch &&
	    timeSeconds - client.teamSwitchOverrideTime <= client.maxOverrideTime &&
	    client.player.playerReplicationInfo.score == client.scoreBeforeTeamSwitch - 1) {
		client.player.playerReplicationInfo.score = client.scoreBeforeTeamSwitch;
	}
	
	// Check if the teamswitch should be allowed.
	if (timeSeconds - client.teamSwitchOverrideTime <= client.maxOverrideTime) {
		client.teamSwitchOverrideTime = 0; // Clear admin override flag.
		bAllowSwitch = true;
	} else if (gInf.bNoTeamSwitch) {
		reason = lng.teamSwitchDisabledMsg;
	} else if (gInf.bTeamsLocked) {
		reason = lng.teamsLockedMsg;
	} else if (client.bNoTeamSwitch) {
		reason = lng.playerTeamSwitchDisabledMsg;
	} else {
		bAllowSwitch = true;
	}
	
	// Update team if allowed.
	if (bAllowSwitch) {
		client.team = client.player.playerReplicationInfo.team;
		client.lastSwitchTime = timeSeconds;
		
		// Notify plugins.
		while (index < arrayCount(plugins) && plugins[index] != none) {
			plugins[index].playerTeamChanged(client);
			index++;
		}
	} else {
		// Switch back to original team.
		client.setTeam(client.team);
		sendMsg(client, lng.teamSwitchFailMsg, reason);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a pawn takes damage.
 *  $PARAM        actualDamage  The amount of damage sustained by the pawn.
 *  $PARAM        victim        Pawn that has become victim of the damage.
 *  $PARAM        instigatedBy  The pawn that has instigated the damage to the victim.
 *  $PARAM        hitLocation   Location where the damage was dealt.
 *  $PARAM        momentum      Momentum of the damage that has been dealt.
 *  $PARAM        damageType    Type of damage dealt to the victim.
 *  $REQUIRE      victim != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function mutatorTakeDamage(out int actualDamage, Pawn victim, Pawn instigatedBy,
                           out vector hitLocation, out vector momentum, name damageType) {
	local NexgenClient client;
	local byte bPreventDamage;
	local byte bResetPlayer;
	local int index;
	
	// Get client.
	client = getClient(victim);
	
	// Check if damage should be prevented.
	if (client != none && damageType != suicideDamageType) {
		checkPreventDamage(client, instigatedBy, damageType, actualDamage, bPreventDamage, bResetPlayer);
		
		// Prevent the damage.
		if (bool(bPreventDamage)) {
			actualDamage = 0;
			if (bool(bResetPlayer)) {
				level.game.restartPlayer(client.player);
				client.showMsg(lng.deathPreventedMsg);
			}
		}
		
		// Team kill?
		if (victim != instigatedBy && level.game.gameReplicationInfo.bTeamGame &&
		    instigatedBy != none && (instigatedBy.isA('PlayerPawn') || instigatedBy.isA('Bot')) &&
		    victim.playerReplicationInfo.team == instigatedBy.playerReplicationInfo.team) {
			
			// Yes, prevent damage & protect victim.
			client.tkPushProtectionTimeX = sConf.teamKillPushProtectionTime;
			
			if (!bool(bPreventDamage) && sConf.teamKillDamageProtectionTime > 0 &&
			    (!level.game.isA('TeamGamePlus') || TeamGamePlus(level.game).friendlyFireScale <= 0 )) {
				// Damage hasn't been prevented yet.
				actualDamage = 0;
				client.tkDmgProtectionTimeX = sConf.teamKillDamageProtectionTime;
		
				// Notify players if desired.
				if (sConf.broadcastTeamKillAttempts) {
					broadcastMsg(lng.teamKillAttemptMsg, instigatedBy.playerReplicationInfo.playerName,
					             victim.playerReplicationInfo.playerName, , ,
					             instigatedBy.playerReplicationInfo);
				}
			}
		}
	}

	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].mutatorTakeDamage(actualDamage, victim, instigatedBy, hitLocation, momentum, damageType);
		index++;
	}

	// Let other mutators do their job.
	if (nextDamageMutator != none) {
		nextDamageMutator.mutatorTakeDamage(actualDamage, victim, instigatedBy, hitLocation, momentum, damageType);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the server wants to check if a players death should be prevented.
 *  $PARAM        victim       The pawn that was killed.
 *  $PARAM        killer       The pawn that has killed the victim.
 *  $PARAM        damageType   Type of damage dealt to the victim.
 *  $PARAM        hitLocation  Location where the damage was dealt.
 *  $RETURN       True if the players death should be prevented, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool preventDeath(Pawn victim, Pawn killer, name damageType, vector hitLocation) {
	local NexgenClient client;
	local byte bPreventDamage;
	local byte bResetPlayer;
	local int index;
	
	// Get client.
	client = getClient(victim);
	
	// Check if damage should be prevented.
	if (client != none && damageType != suicideDamageType) {
		checkPreventDamage(client, killer, damageType, 99999, bPreventDamage, bResetPlayer);
		
		// Prevent the damage.
		if (bool(bPreventDamage)) {
			client.player.health = 100;
			if (bool(bResetPlayer)) {
				level.game.restartPlayer(client.player);
				client.showMsg(lng.deathPreventedMsg);
			}
			return true;
		}
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		if (plugins[index].preventDeath(victim, killer, damageType, hitLocation)) return true;
		index++;
	}
	
	// Let other mutators do their job.
	if (nextMutator == none) {
		return false;
	} else {
		return nextMutator.preventDeath(victim, killer, damageType, hitLocation);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified damage to the client should be prevented.
 *  $PARAM        client          The client for which the damage prevention check should be executed.
 *  $PARAM        instigator      The pawn that has instigated the damage to the victim.
 *  $PARAM        damageType      Type of damage the player has sustained.
 *  $PARAM        damage          The amount of damage sustained by the client.
 *  $PARAM        bPreventDamage  Whether the damage should be prevented or not.
 *  $PARAM        bResetPlayer    Indicates if the player should restart if the damage is prevented.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function checkPreventDamage(NexgenClient client, Pawn instigator, name damageType, int damage,
                            out byte bPreventDamage, out byte bResetPlayer) {
	// Check if player has switched to another team.
	if (client.team != client.player.playerReplicationInfo.team) {
		// Yes, don't prevent the damage.
		bPreventDamage = byte(false);
		bResetPlayer = byte(false);
		return;
	}
	
	// Spawn protection.
	if (client.spawnProtectionTimeX > 0) {
		bPreventDamage = byte(true);
		bResetPlayer = byte(client.player.playerReplicationInfo.hasFlag == none &&
		                    (damageType == fallDamageType && client.player.health <= damage ||
		                     damageType == burnDamageType ||
		                     damageType == corrodeDamageType));
	}
	
	// Team kill damage & push protection.
	if (!bool(bPreventDamage)) {
		bPreventDamage = byte(client.tkDmgProtectionTimeX > 0 &&
		                      client.player == instigator ||
		                      client.tkPushProtectionTimeX > 0 &&
		                      (damageType == fallDamageType ||
		                       damageType == burnDamageType ||
		                       damageType == corrodeDamageType ||
		                       instigator == none));
		bResetPlayer = byte(client.tkPushProtectionTimeX > 0 &&
		                    client.player.playerReplicationInfo.hasFlag == none &&
		                    (damageType == fallDamageType && client.player.health <= damage ||
		                     damageType == burnDamageType ||
		                     damageType == corrodeDamageType));
		                    
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attempts to balance the current teams.
 *  $RETURN       True if the teams have been balanced, false if they are already balanced.
 *
 **************************************************************************************************/
function bool balanceTeams() {
	if (teamBalancer == none) {
		return false;
	} else {
		return teamBalancer.balanceTeams();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Starts the current game.
 *  $PARAM        bForced  Whether to force the game to start (if it hasn't already been started).
 *  $REQUIRE      gInf.gameState == gInf.GS_Ready || gInf.gameState == gInf.GS_Starting ||
 *                (bForced && gInf.gameState == gInf.GS_Waiting)
 *  $ENSURE       gInf.gameState == gInf.GS_Playing;
 *
 **************************************************************************************************/ 
function startGame(optional bool bForced) {
	
	// Start the game immediately?
	if (!sConf.enableNexgenStartControl ||
	    gInf.gameState == gInf.GS_Ready && sConf.startTime <= 0 ||
	    gInf.gameState == gInf.GS_Starting && gInf.countDown <= 0) {
		// Yes.
		gInf.gameState = gInf.GS_Playing;
		DeathMatchPlus(level.game).bRequireReady = false;
		DeathMatchPlus(level.game).startMatch();
		
		gameStarted();
		
	} else if ((gInf.gameState == gInf.GS_Ready ||
	           bForced && gInf.gameState == gInf.GS_Waiting) && 
	           sConf.startTime > 0) {
		// No, delayed start.
		gInf.gameState = gInf.GS_Starting;
		gInf.countDown = sConf.startTime;
		
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Logs the given message.
 *  $PARAM        msg      Message that should be written to the log.
 *  $PARAM        logType  The type of log message.
 *
 **************************************************************************************************/
function nscLog(string msg, optional byte logType) {
	if (shouldLog(logType)) {
		// Log to console (stdout).
		if (sConf == none || sConf.logToConsole || logType == LT_System) {
			log(getLogTypeTag(logType) @ msg, logTag);
		}

		// Log to file.
		if (sConf == none || sConf.logToFile && logFile == none) {
			addLogBufferEntry(msg, logType);
		} else if (logFile != none) {
			logFile.addLog(msg, logType);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the log tag for the specified log type.
 *  $PARAM        logType  The type of log message.
 *  $RETURN       The tag that should be prepended for log messages of the specified type.
 *
 **************************************************************************************************/
function string getLogTypeTag(byte logType) {
	switch (logType) {
		case LT_Event:       return lng.eventLogTag;
		case LT_Message:     return lng.messageLogTag;
		case LT_Say:         return lng.chatMessageLogTag;
		case LT_TeamSay:     return lng.teamSayMessageLogTag;
		case LT_PrivateMsg:  return lng.privateMessageLogTag;
		case LT_AdminAction: return lng.adminActionLogTag;
		default:             return lng.controllerSystemLogTag;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether messages of the specified log type should be written to the log.
 *  $PARAM        logType  The type of log message.
 *  $RETURN       True if the message of this type should be logged, false if not.
 *
 **************************************************************************************************/
function bool shouldLog(byte logType) {
	switch (logType) {
		case LT_Event:       return sConf.logEvents;
		case LT_Message:     return sConf.logSystemMessages;
		case LT_Say:         return sConf.logChatMessages;
		case LT_TeamSay:     return sConf.logChatMessages;
		case LT_PrivateMsg:  return sConf.logPrivateMessages;
		case LT_AdminAction: return sConf.logAdminActions;
		default:             return true;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified logs to the log buffer.
 *  $PARAM        msg      Message that should be written to the log.
 *  $PARAM        logType  The type of log message.
 *
 **************************************************************************************************/
function addLogBufferEntry(string msg, optional byte logType) {
	local NexgenLogEntry newLog;
	local NexgenLogEntry logEntry;
	
	// Create log entry.
	newLog           = spawn(class'NexgenLogEntry', self);
	newLog.message   = msg;
	newLog.type      = logType;
	newLog.year      = level.year;
	newLog.month     = level.month;
	newLog.day       = level.day;
	newLog.dayOfWeek = level.dayOfWeek;
	newLog.hour      = level.hour;
	newLog.minute    = level.minute;
	newLog.second    = level.second;
	
	// Add new log entry to the linked list.
	if (logBuffer == none) {
		// First entry.
		logBuffer = newLog;
		
	} else {
		// Find last entry and append new log entry.
		logEntry = logBuffer;
		while (logEntry.nextLogEntry != none) logEntry = logEntry.nextLogEntry;
		logEntry.nextLogEntry = newLog;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Clears the log buffer.
 *
 **************************************************************************************************/
function clearLogBuffer() {
	if (logBuffer != none) {
		logBuffer.destroy();
		logBuffer = none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Logs the specified administrator action.
 *  $PARAM        admin              The client that performed the action.
 *  $PARAM        msg                Message that describes the action performed by the administrator.
 *  $PARAM        str1               Message specific content.
 *  $PARAM        str2               Message specific content.
 *  $PARAM        str3               Message specific content.
 *  $PARAM        str4               Message specific content.
 *  $PARAM        pri                Replication info of the player related to this message.
 *  $PARAM        bNoBroadcast       Whether not to broadcast this administrator action.
 *  $PARAM        bServerAdminsOnly  Broadcast message only to administrators with the server admin
 *                                   privilege.
 *  $REQUIRE      admin != none
 *
 **************************************************************************************************/
function logAdminAction(NexgenClient admin, string msg, optional string str1, optional string str2,
                        optional string str3, optional string str4,
                        optional PlayerReplicationInfo pri, optional bool bNoBroadcast,
                        optional bool bServerAdminsOnly) {
	local NexgenClient client;
	local bool bSendToAdminsOnly;
	
	// Format message.
	msg = class'NexgenUtil'.static.format(msg, str1, str2, str3, str4);
	
	// Log message.
	nscLog(class'NexgenUtil'.static.removeMessageColorTag(msg), LT_AdminAction);
	
	// Send message to all clients.
	bSendToAdminsOnly = bNoBroadcast || admin.hasRight(admin.R_HiddenAdmin) ||
	                    !sConf.broadcastAdminActions;
	for (client = clientList; client != none; client = client.nextClient) {
		if (!bSendToAdminsOnly || client.bHasAccount && !bServerAdminsOnly || client.hasRight(client.R_ServerAdmin)) {
			client.showMsg(msg, pri);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Broadcasts the given message to all connected clients.
 *  $PARAM        msg   Message that should send to all the clients.
 *  $PARAM        str1  Message specific content.
 *  $PARAM        str2  Message specific content.
 *  $PARAM        str3  Message specific content.
 *  $PARAM        str4  Message specific content.
 *  $PARAM        pri   Replication info of the player related to this message.
 *
 **************************************************************************************************/
function broadcastMsg(string msg, optional string str1, optional string str2, optional string str3,
                      optional string str4, optional PlayerReplicationInfo pri) {
	local NexgenClient client;
	
	// Format message.
	msg = class'NexgenUtil'.static.format(msg, str1, str2, str3, str4);
	
	// Log message.
	nscLog(class'NexgenUtil'.static.removeMessageColorTag(msg), LT_Event);
	
	// Send message to all clients.
	for (client = clientList; client != none; client = client.nextClient) {
		client.showMsg(msg, pri);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Broadcasts the given message to all connected clients.
 *  $PARAM        client  The client to which the message should be send.
 *  $PARAM        msg     Message that should send to all the clients.
 *  $PARAM        str1    Message specific content.
 *  $PARAM        str2    Message specific content.
 *  $PARAM        str3    Message specific content.
 *  $PARAM        str4    Message specific content.
 *  $PARAM        pri     Replication info of the player related to this message.
 *
 **************************************************************************************************/
function sendMsg(NexgenClient client, string msg, optional string str1, optional string str2,
                 optional string str3, optional string str4, optional PlayerReplicationInfo pri) {
	msg = class'NexgenUtil'.static.format(msg, str1, str2, str3, str4);
	client.showMsg(msg, pri);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the NexgenClient instance for the given actor.
 *  $PARAM        a  The actor for which the client handler instance is to be found.
 *  $REQUIRE      a != none
 *  $RETURN       The client handler for the given actor.
 *  $ENSURE       (!a.isA('PlayerPawn') ? result == none : true) &&
 *                (result != none ? result.owner == a : true)
 *
 **************************************************************************************************/
function NexgenClient getClient(Actor a) {
	local NexgenClient client;
	local bool bFound;
	
	// Search for NexgenClient owning this actor.
	client = clientList;
	while (!bFound && client != none) {
		if (client.owner == a) {
			bFound = true;
		} else {
			client = client.nextClient;
		}
	}
	
	// Return result.
	if (bFound) {
		return client;
	} else {
		return none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the NexgenClient instance for the given player code.
 *  $PARAM        playerNum  The player code of the client handler instance that is to be found.
 *  $REQUIRE      playerNum >= 0
 *  $RETURN       The client handler for the given player code.
 *  $ENSURE       (result != none ? result.playerNum == playerNum : true)
 *                
 *
 **************************************************************************************************/
function NexgenClient getClientByNum(int playerNum) {
	local NexgenClient client;
	local bool bFound;
	
	// Search for NexgenClient with the specified player code.
	client = clientList;
	while (!bFound && client != none) {
		if (client.playerNum == playerNum) {
			bFound = true;
		} else {
			client = client.nextClient;
		}
	}
	
	// Return result.
	if (bFound) {
		return client;
	} else {
		return none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the NexgenClient instance for the given player client ID.
 *  $PARAM        clientID  The client ID of the client handler instance that is to be found.
 *  $REQUIRE      clientID != ""
 *  $RETURN       The client handler for the given player code.
 *  $ENSURE       (result != none ? result.playerID ~= clientID : true)
 *                
 *
 **************************************************************************************************/
function NexgenClient getClientByID(string clientID) {
	local NexgenClient client;
	local bool bFound;
	
	// Search for NexgenClient with the specified player code.
	client = clientList;
	while (!bFound && client != none) {
		if (client.playerID ~= clientID) {
			bFound = true;
		} else {
			client = client.nextClient;
		}
	}
	
	// Return result.
	if (bFound) {
		return client;
	} else {
		return none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles a potential command message.
 *  $PARAM        sender     PlayerPawn that has send the message in question.
 *  $PARAM        msg        Message send by the player, which could be a command.
 *  $REQUIRE      sender != none
 *  $RETURN       True if the specified message is a command, false if not.
 *
 **************************************************************************************************/
function bool handleMsgCommand(PlayerPawn sender, string msg) {
	local string cmd;
	local bool bIsCommand;
	local int index;
	
	cmd = class'NexgenUtil'.static.trim(msg);
	bIsCommand = true;
	switch (cmd) {
		// Team commands.
		case "!r": case "!red":     mutate(CMD_Prefix @ CMD_SwitchTeam @ 0, sender); break;
		case "!b": case "!blue":    mutate(CMD_Prefix @ CMD_SwitchTeam @ 1, sender); break;
		case "!g": case "!green":   mutate(CMD_Prefix @ CMD_SwitchTeam @ 2, sender); break;
		case "!y": case "!yellow": case "!gold":   mutate(CMD_Prefix @ CMD_SwitchTeam @ 3, sender); break;
		case "!t": case "!team":   case "!teams":  mutate(CMD_Prefix @ CMD_BalanceTeams,   sender); break;
		
		// Game commands.
		case "!p": case "!play":    mutate(CMD_Prefix @ CMD_Play,           sender); break;
		case "!s": case "!spec":    mutate(CMD_Prefix @ CMD_Spectate,       sender); break;
		case "!l": case "!start":   mutate(CMD_Prefix @ CMD_StartGame,      sender); break;
		case "!quit": case "!exit": mutate(CMD_Prefix @ CMD_Exit,           sender); break;
		case "!leave": case "!bye": mutate(CMD_Prefix @ CMD_Disconnect,     sender); break; 
		
		// GUI commands.
		case "!o": case "!open":    mutate(CMD_Prefix @ CMD_Open,           sender); break;
		case "!v": case "!vote":    mutate(CMD_Prefix @ CMD_OpenVote,       sender); break;
		
		// Not a command.
		default: bIsCommand = false;
	}
	
	// Allow plugins to handle commands.
	index = 0;
	while (!bIsCommand && index < arrayCount(plugins) && plugins[index] != none) {
		bIsCommand = plugins[index].handleMsgCommand(sender, msg);
		index++;
	}
	
	return bIsCommand;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game executes its next 'game' tick. This function provides the
 *                support for the gamespeed independent timing support.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	local NexgenClient client;
	
	if (level.pauser == "") {
		timeSeconds += deltaTime / level.timeDilation;
	}
	
	for (client = clientList; client != none; client = client.nextClient) {
		if (client.player.player == none) {
			playerLeft(client);
		}
	}
	
	if (!bServerTravelDetected && level.nextURL != "" && level.nextSwitchCountdown - deltaTime <= 0) {
		bServerTravelDetected = true;
		notifyBeforeLevelChange();
	}
	
	if (!bFirstTickPassed) {
		firstTick();
		bFirstTickPassed = true;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes one iteration of the server controller main loop. Various events are
 *                detected and handled here, including:
 *                - Players that change their name.
 *                - Players that have switched to another team.
 *                - When the game has ended.
 *                - Game speed changes.
 *                This function is also responsible for making our virtual 1 Hz timer tick.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function timer() {
	local NexgenClient client;
	
	// For each client...
	for (client = clientList; client != none; client = client.nextClient) {
			
		// Name changed?
		if (client.playerName != client.player.playerReplicationInfo.playerName) {
			playerNameChanged(client);
		}
		
		// Team changed?
		if (client.team != client.player.playerReplicationInfo.team) {
			playerTeamChanged(client);
		}
		
	}
	
	// Game ended?
	if (level.game.bGameEnded && gInf.gameState != gInf.GS_Ended) {
		gInf.gameState = gInf.GS_Ended;
		gameEnded();
	}
	
	// Check speed changed?
	if (level.timeDilation != lastTimeDilation) {
		lastTimeDilation = level.timeDilation;
		gInf.gameSpeed = level.game.gameSpeed;
		gameSpeedChanged();
	}
	
	// Simulated 1 Hz timer.
	virtualTimerCounter += timerRate;
	if (virtualTimerCounter > level.timeDilation) {
		virtualTimerCounter = 0;
		virtualTimer();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  This is our home cooked timer, which ticks at a frequency of 1 Hz and is
 *                independent of the game speed.
 *
 **************************************************************************************************/
function virtualTimer() {
	local int index;
	local NexgenClient client;
	
	// Update countdown.
	if (gInf.countDown > 0) {
		gInf.countDown--;
	}
	
	// Check if the game if ready to start
	if (gInf.countDown == 0 && gInf.gameState == gInf.GS_Waiting && sConf.enableNexgenStartControl) {
		gInf.gameState = gInf.GS_Ready;
		for (client = clientList; client != none; client = client.nextClient) {
			showGameReadyToLaunchMessage(client);
		}
	}
	if (gInf.countDown == 0 && gInf.gameState == gInf.GS_Starting) {
		startGame();
	}
	
	// Automatically disable an inactive match?
	if (sConf.matchModeActivated && sConf.autoDisableMatchTime > 0 && clientList == none &&
	    timeSeconds - lastPlayerLeftTime > secondsPerMinute * sConf.autoDisableMatchTime) {
		// Yes.
		sConf.matchModeActivated = false;
		sConf.saveConfig();
		signalConfigUpdate(sConf.CT_MatchSettings);
		if (sConf.matchAutoLockTeams) {
			gInf.bTeamsLocked = false;
		}
	}
	
	// Reboot server?
	if (gInf.rebootCountDown > 0) {
		gInf.rebootCountDown--;
		if (gInf.rebootCountDown == 0) {
			sConf.isAdminReboot = true;
			sConf.saveConfig();
			consoleCommand(rebootCommand);
		}
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].virtualTimer();
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends a message to the specified client that the game is ready to be started.
 *  $PARAM        client  The client that should receive the 'ready to launch' message.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function showGameReadyToLaunchMessage(NexgenClient client) {
	if (sConf.matchModeActivated && gInf.bTournamentMode) {
		client.showMsg(lng.tournamentLaunchGameMsg);
	} else if ((sConf.enableAdminStartControl || sConf.matchModeActivated) &&
	    gInf.matchAdminCount > 0 && !client.hasRight(client.R_MatchAdmin)) {
		client.showMsg(lng.adminLaunchGameMsg);
	} else {
		client.showMsg(lng.launchGameMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game has started.
 *
 **************************************************************************************************/
function gameStarted() {
	local int index;
	local Pawn p;
	
	// Record current time.
	gameStartTime = timeSeconds;
	
	// Log event.
	nscLog(lng.gameStartedMsg, LT_Event);
	
	// Lock teams?
	if (sConf.matchModeActivated && sConf.matchAutoLockTeams && !gInf.bTeamsLocked) {		
		gInf.bTeamsLocked = true;
		signalGameInfoUpdate(gInf.IT_GlobalRights);
	}
	
	// Remove UTPure flags.
	if (bUTPureEnabled) {
		for (p = level.pawnList; p != none; p = p.nextPawn) {
			if (p.playerReplicationInfo != none && p.playerReplicationInfo.hasFlag != none &&
			    p.playerReplicationInfo.hasFlag.isA('PureFlag')) {
				p.playerReplicationInfo.hasFlag = none;
			}
			if (p.isA('PlayerPawn')) {
				PlayerPawn(p).bReadyToPlay = false;
			}
		}
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].gameStarted();
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game has ended.
 *  $REQUIRE      level.game.bGameEnded
 *
 **************************************************************************************************/
function gameEnded() {
	local int index;
	
	// Record current time.
	gameEndTime = timeSeconds;
	
	// Log event.
	nscLog(lng.format(lng.gameEndedMsg, int(gameEndTime - gameStartTime + 0.5)), LT_Event);
	
	// Update match settings.
	if (sConf.matchModeActivated) {
		sConf.currentMatch++;
	}
	
	// Unlock teams?
	if (sConf.matchModeActivated && sConf.matchAutoLockTeams && gInf.bTeamsLocked) {		
		gInf.bTeamsLocked = false;
		signalGameInfoUpdate(gInf.IT_GlobalRights);
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].gameEnded();
		index++;
	}
	
	// Save configuration.
	sConf.saveConfig();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the server is about to perform a server travel. Note that the server
 *                travel may fail to switch to the desired map. In that case the server will
 *                continue running the current game or a second notifyBeforeLevelChange() call may
 *                occur when trying to switch to another map. So be carefull what you do in this
 *                function!!!
 *
 **************************************************************************************************/
function notifyBeforeLevelChange() {
	local int index;
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].notifyBeforeLevelChange();
		index++;
	}
	
	// Close log file.
	if (logFile != none) {
		logFile.endLog();
		logFile = none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game speed has changed.
 *
 **************************************************************************************************/
function gameSpeedChanged() {
	local int index;
	
	// Update timer rate.
	timerRate = 1.0 / timerFreq * level.timeDilation;
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		//plugins[index].gameSpeedChanged();
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Hooked into the message mutator chain so commands can be detected. This function
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
	local bool bIsCommand;
	local NexgenClient client;
	local byte logType;
	local int index;
	local bool bSend;
	
	// Check for commands.
	if (sender != none && sender.isA('PlayerPawn') && sender == receiver &&
	    (type == 'Say' || type == 'TeamSay')) {
		bIsCommand = handleMsgCommand(PlayerPawn(sender), s);
	}
	
	// Check if player is muted.
	client = getClient(sender);
	if (client != none && client.isMuted()) {
		// Yeah he/she is, block the message.
		if (sender == receiver) {
			if (bIsCommand) {
				return true;
			} else {
				client.showMsg(lng.mutedReminderMsg);
			}
		}
		return false;
	}
	
	// Log message.
	if (sender == none && receiver != none && receiver.nextPawn == none) {
		nscLog(s, LT_Message);
	} else if (sender != none && sender == receiver && receiver.playerReplicationInfo != none) {
		if (type == 'Say') {
			logType = LT_Say;
		} else if (type == 'TeamSay') {
			logType = LT_TeamSay;
		} else {
			logType = LT_Message;
		}
		nscLog(receiver.playerReplicationInfo.playerName $ ": " $ s, logType);
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		bSend = plugins[index].mutatorTeamMessage(sender, receiver, pri, s, type, bBeep);
		if (!bSend) return false;
		index++;
	}
	
	// Allow other message mutators to do their job.
    if (nextMessageMutator != none) {
        return nextMessageMutator.mutatorTeamMessage(sender, receiver, pri, s, type, bBeep);
    } else {
        return true;
    }	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Hooked into the message mutator chain so commands can be detected. This function
 *                is called if a message is send to player. Spectators that use say (not teamsay)
 *                seem to be calling this function instead of mutatorTeamMessage.
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
	local bool bIsCommand;
	local NexgenClient client;
	local bool bIsSpecMessage;
	local int index;
	local bool bSend;
	
	// Suppress default player join / leave messages.
	if (sender == level.game && right(msg, len(level.game.leftMessage)) ~= level.game.leftMessage ||
	    sender == level.game && right(msg, len(level.game.enteredMessage)) ~= level.game.enteredMessage) {
		return false;
	}

	// Get sender player replication info.
	if (sender != none && sender.isA('Pawn')) {
		senderPRI = Pawn(sender).playerReplicationInfo;
	}
	
	// Check if we're dealing with a spectator chat message.
	bIsSpecMessage = senderPRI != none && sender.isA('Spectator') &&
	                 left(msg, len(senderPRI.playerName) + 1) ~= (senderPRI.playerName $ ":");
	
	// Check for commands.
	if (bIsSpecMessage && sender == receiver) {
		bIsCommand = handleMsgCommand(PlayerPawn(sender), mid(msg, len(senderPRI.playerName) + 1));
	}
	
	// Check if spectator is muted.
	if (bIsSpecMessage) {
		client = getClient(sender);
		if (client != none && client.isMuted() ||
		    sConf.matchModeActivated && sConf.muteSpectatorsDuringMatch &&
		    gInf.gameState == gInf.GS_Playing &&
		    !client.hasRight(client.R_MatchAdmin) && !client.hasRight(client.R_Moderate)) {
			// Spectator is muted, block the message.
			if (sender == receiver) {
				if (bIsCommand) {
					return true;
				} else {
					client.showMsg(lng.mutedReminderMsg);
				}
			}
			return false;
		}
	}
	
	// Write message to the log.
	if (bIsSpecMessage && sender == receiver) {
		nscLog(msg, LT_Say);
	} else if (!bIsSpecMessage && receiver != none && receiver.nextPawn == none) {
		if (senderPRI == none) {
			nscLog(msg, LT_Message);
		} else {
			nscLog(senderPRI.playerName $ ": " $ msg, LT_Message);
		}
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		bSend = plugins[index].mutatorBroadcastMessage(sender, receiver, msg, bBeep, type);
		if (!bSend) return false;
		index++;
	}
	
	// Allow other message mutators to do their job.
    if (nextMessageMutator != none) {
        return nextMessageMutator.mutatorBroadcastMessage(sender, receiver, msg, bBeep, type);
    } else {
        return true;
    }
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Hooked into the message mutator chain so messages can be logged.
 *  $PARAM        sender          The actor that has send the message.
 *  $PARAM        receiver        Pawn receiving the message.
 *  $PARAM        message         The class of the localized message that is to be send.
 *  $PARAM        switch          Optional message switch argument.
 *  $PARAM        relatedPRI_1    PlayerReplicationInfo of a player that is related to the message.
 *  $PARAM        relatedPRI_2    PlayerReplicationInfo of a player that is related to the message.
 *  $PARAM        optionalObject  Optional object used to construct the message string.
 *  $REQUIRE      message != none
 *  $RETURN       True if the message should be send, false if it should be suppressed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool mutatorBroadcastLocalizedMessage(Actor sender, Pawn receiver,
                                               out class<LocalMessage> message,
                                               out optional int switch,
                                               out optional PlayerReplicationInfo relatedPRI_1,
                                               out optional PlayerReplicationInfo relatedPRI_2,
                                               out optional Object optionalObject) {
	local PlayerReplicationInfo senderPRI;
	local string msg;
	local int index;
	local bool bSend;
	
	// Get sender player replication info.
	if (sender != none && sender.isA('Pawn')) {
		senderPRI = Pawn(sender).playerReplicationInfo;
	}
	
	// Prevent duplicate messages in the log.
	if (receiver != none && receiver.nextPawn == none && message != none) {
		
		// Construct message.
		msg = message.static.getString(switch, relatedPRI_1, relatedPRI_2, optionalObject);
		
		// Log the message.
		if (senderPRI == none) {
			nscLog(msg, LT_Message);
		} else {
			nscLog(senderPRI.playerName $ ": " $ msg, LT_Message);
		}
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		bSend = plugins[index].mutatorBroadcastLocalizedMessage(sender, receiver, message, switch,
		                                                        relatedPRI_1, relatedPRI_2, optionalObject);
		if (!bSend) return false;
		index++;
	}
	
	// Allow other message mutators to do their job.
	if (nextMessageMutator != none) {
		return nextMessageMutator.mutatorBroadcastLocalizedMessage(sender, receiver, message,
		                                                           switch, relatedPRI_1,
		                                                           relatedPRI_2, optionalObject);
	} else {
		return true;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Hooked into the mutator chain to detect Nexgen actions issued by the clients. If
 *                a Nexgen command is detected it will be parsed and send to the execCommand()
 *                function.
 *  $PARAM        mutateString  Mutator specific string (indicates the action to perform).
 *  $PARAM        sender        Player that has send the message.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function mutate(string mutateString, PlayerPawn sender) {
	local bool bIsNexgenCommand;
	local bool bIsLegacyCommand;
	local NexgenClient client;
	local string cmd;
	local string args[10];
	local int index;
	
	// Get client handler for the sender.
	client = getClient(sender);
	
	// Parse command.
	bIsNexgenCommand = class'NexgenUtil'.static.parseCommandStr(mutateString, cmd, args);
	
	// Execute command.
	if (client != none) {
		if (bIsNexgenCommand) {
			cmdHandler.execCommand(client, cmd, args);
		} else if (mutateString ~= "asc#get#window" || mutateString ~= "hz0090") {
			// ASC/HUT legacy commands.
			cmdHandler.execCommand(client, CMD_Open, args);
			bIsLegacyCommand = true;
		}
	}
	
	// Let plugins and other mutators handle the string if this isn't a valid Nexgen command.
    if (!bIsNexgenCommand && !bIsLegacyCommand) {
	
		// Notify plugins.
		while (index < arrayCount(plugins) && plugins[index] != none) {
			plugins[index].mutate(mutateString, sender);
			index++;
		}
        
        // Allow other mutators to do their job.
        if (nextMutator != none) {
        	nextMutator.mutate(mutateString, sender);
        }
    }
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the clients that a certain part of the server configuration has changed.
 *  $PARAM        configType  Type of settings that have been changed.
 *  $ENSURE       new.sConf.updateCounts[configType] = old.sConf.updateCounts[configType] + 1
 *
 **************************************************************************************************/
function signalConfigUpdate(byte configType) {
	local NexgenClient client;
	local int index;
	
	// Set update counter.
	sConf.updateCounts[configType]++;
	
	// Update checksum.
	sConf.updateChecksum(configType);
	
	// Notify clients.
	for (client = clientList; client != none; client = client.nextClient) {
		client.configChanged(configType, sConf.updateCounts[configType], sConf.dynamicChecksums[configType]);
	}
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].configChanged(configType);
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the clients that a certain part of the server configuration has changed.
 *  $PARAM        configType  Type of settings that have been changed.
 *  $ENSURE       new.sConf.updateCount = old.sConf.updateCount + 1
 *
 **************************************************************************************************/
function signalGameInfoUpdate(byte infoType) {
	local NexgenClient client;
	
	// Set update counter.
	gInf.updateCount++;
	
	// Notify clients.
	for (client = clientList; client != none; client = client.nextClient) {
		client.gameInfoChanged(infoType, gInf.updateCount);
	}	
}




/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies all clients that a specified attribute of a player has changed.
 *  $PARAM        client  The client of which an attribute has changed.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function announcePlayerAttrChange(NexgenClient client, string attributeName, coerce string value) {
	local NexgenClient c;
	local string args;
	
	// Get event arguments.
	class'NexgenUtil'.static.addProperty(args, attributeName, value);
	
	// Signal attribute change events.
	for (c = clientList; c != none; c = c.nextClient) {
		c.playerEvent(client.playerNum, client.PE_AttributeChanged, args);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Forces the current game to end.
 *
 **************************************************************************************************/
function forceEndGame() {
	// Prevent ties, else BDBMapVote won't show.
	preventTie();
	
	// End game using the game's end game handler.
	bForcedGameEnd = true;
	level.game.endGame("Forced");

	// Set end game comments.
	level.game.gameReplicationInfo.gameEndedComments = lng.forcedEndMsg;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Prevents the game from ending in a tie.
 *
 **************************************************************************************************/
function preventTie() {
	local Pawn p;
	local Pawn bestPlayer;
	local TeamInfo bestTeam;
	local TeamGamePlus teamGame;
	local int index;
	local int bestCount;
	
	// Make sure there is no tie else BDBMapVote won't show.
	if (level.game.isA('Assault')) {
		// Ignore.
	} else if (level.game.isA('Domination')) {
		// Ignore.
	} else if (level.game.isA('TeamGamePlus')) {
		// Get shortcut to TeamGamePlus instance.
		teamGame = TeamGamePlus(level.game);
		
		// Find team with best score.
		for (index = 0; index < teamGame.maxTeams; index++) {
			if ((bestTeam == none) || (bestTeam.score < teamGame.teams[index].score)) {
				bestTeam = teamGame.teams[index];
				bestCount = 1;
			} else if ((bestTeam != none) && (bestTeam.score == teamGame.teams[index].score)) {
				bestCount++;
			}
		}
		
		// Make sure at least one team has the highest score.
		if (bestCount > 1) {
			bestTeam.score += 1.0;
		}

	} else {
		// Find player with best score.
		for (p = level.pawnList; p != none; p = p.nextPawn) {
			if (p.bIsPlayer && p.playerReplicationInfo != none) {
				if ((bestPlayer == none) ||
				    (bestPlayer.playerReplicationInfo.score < p.playerReplicationInfo.score)) {
					bestPlayer = p;
					bestCount = 1;
				} else if ((bestPlayer != none) &&
				           (bestPlayer.playerReplicationInfo.score == p.playerReplicationInfo.score)) {
					bestCount++;
				}
			}
		}
		
		// Make sure at least one player has the highest score.
		if (bestCount > 1) {
			bestPlayer.playerReplicationInfo.score += 1.0;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game is about to be ended and allows the mutator to prevent the
 *                game from being stopped.
 *  $RETURN       True if the game shouldn't be ended yet, false if it is alright if the game is
 *                ended.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool handleEndGame() {
	
	// Was the game forced to an end by Nexgen?
	if (bForcedGameEnd) {
		// Yes, make sure the game is always ended.
		nextMutator.handleEndGame();
		return false;
		
	} else {
		// No, game ended normally, use default logic.
		return super.handleEndGame();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player was killed by another player.
 *  $PARAM        killer  The pawn that killed the other pawn. Might be none.
 *  $PARAM        victim  Pawn that was the victim.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function scoreKill(Pawn killer, Pawn victim) {
	local int index;
	
	// Notify plugins.
	while (index < arrayCount(plugins) && plugins[index] != none) {
		plugins[index].scoreKill(killer, victim);
		index++;
	}
	
	// Let other mutators do their job.
	if (nextMutator != none) {
		nextMutator.scoreKill(killer, victim);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Check for other mutators that might create compatibility issues with Nexgen.
 *
 **************************************************************************************************/
function doCompatibilityCheck() {
	local Actor a;
	local string actorClass;
	
	foreach allActors(class'Actor', a) {
		actorClass = caps(string(a.class));
		if (!bUTPureEnabled && instr(actorClass, ".UTPURESA") > 0) {
			bUTPureEnabled = true;
			nscLog(lng.format(lng.compatibilityModeMsg, "UTPure"));
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Signals a general event. The event is broadcasted to all clients and called on
 *                all plugins.
 *  $PARAM        type            The type of event that has occurred.
 *  $PARAM        argument        Optional arguments providing details about the event.
 *  $PARAM        bNotForClients  Whether the event should not be send to clients.
 *  $PARAM        bNotForPlugins  Whether the event should not be send to local plugins.
 *
 **************************************************************************************************/
function signalEvent(string type, optional string arguments, optional bool bNotForClients,
                     optional bool bNotForPlugins) {
	local NexgenClient client;
	local int index;
	
	// Notify clients.
	if (!bNotForClients) {
		for (client = clientList; client != none; client = client.nextClient) {
			client.notifyEvent(type, arguments);
		}
	}
	
	// Notify plugins.
	if (!bNotForPlugins) {
		while (index < arrayCount(plugins) && plugins[index] != none) {
			plugins[index].notifyEvent(type, arguments);
			index++;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the number of players that have send a ready signal and the required
 *                number of ready signals. Also once the required number of ready signals is met
 *                the game will start automatically.
 *
 **************************************************************************************************/
function doTournamentModeReadySignalCheck() {
	local NexgenClient client;
	local byte numReady;
	local byte numRequiredReady;
	local byte numPlayers;
	
	// Count ready signals and number of players.
	for (client = clientList; client != none; client = client.nextClient) {
		if (!client.bSpectator) {
			numPlayers++;
			if (client.bIsReadyToPlay) {
				numReady++;
			}
		}
	}
	
	// Determine required ready count.
	numRequiredReady = max(2, numPlayers);
	
	// Update game info.
	gInf.numReady = numReady;
	gInf.numRequiredReady = numRequiredReady;
	
	// Start game if minimum required ready signals is reached.
	if (numReady >= numRequiredReady) {
		startGame();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the bIsReadyToPlay flag for all clients to false.
 *
 **************************************************************************************************/
function clearReadySignals() {
	local NexgenClient client;
	
	for (client = clientList; client != none; client = client.nextClient) {
		client.bIsReadyToPlay = false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game is executing it's first tick.
 *
 **************************************************************************************************/
function firstTick() {
	local int index;
	local NexgenWRRegisterServer registerServerWR;
	
	// Check for compatibility issues with other mutators.
	doCompatibilityCheck();
	
	if (!bSpecialMode) {
		// Update the list of active mutators.
		sConf.setActiveMutatorList();
		
		// Set Nexgen HUD.
		if (sConf.useNexgenHUD) {
			gInf.originalHUDClass = level.game.HUDType;
			if (level.game.HUDType == class'ChallengeTeamHUD' ||
			    classIsChildOf(level.game.HUDType, class'ChallengeTeamHUD')) {
				level.game.HUDType = class'NexgenHUDWrapperT';
			} else {
				level.game.HUDType = class'NexgenHUDWrapper';
			}
		}
		
		// Notify plugins.
		while (index < arrayCount(plugins) && plugins[index] != none) {
			plugins[index].firstTick();
			index++;
		}
		
		// Register server in the Nexgen database.
		if (sConf.autoRegisterServer) {
			registerServerWR = spawn(class'NexgenWRRegisterServer');
			registerServerWR.loadRequestData(self);
			registerServerWR.executeRequest();
		}
		
		nscLog(lng.nexgenActiveMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	bUseExternalConfig=true
	bAlwaysTick=true
}

