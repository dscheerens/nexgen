/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenConfig
 *  $VERSION      1.43 (05-12-2010 19:35:35)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen configuration container/replication class. This class contains the settings
 *                for the server controller and necessary code to gather a lot of required data.
 *                WARNING: Any changes made to one of the variables during the game may prevent new
 *                clients from initializing. MAKE SURE THE CHECKSUMS ARE ALWAYS UP TO DATE!!!
 *
 **************************************************************************************************/
class NexgenConfig extends ReplicationInfo;

var bool bInitialized;                            // NexgenConfig instance has been initialized.

var NexgenController control;                     // Server controller.

const separator = ",";                            // Character used to seperate elements in a list.

// Replication / data transfer control.
var int staticChecksum;                           // Checksum for the static replicated variables.
var int dynamicChecksums[9];                      // Checksum for the dynamic replicated variables.
var int dynamicChecksumModifiers[9];              // Dynamic data checksum salt.
var int updateCounts[9];                          // How many times the settings have been updated
                                                  // during the current game. Used to detect setting
                                                  // changes clientside.

const CT_GlobalServerSettings = 0;                // Global server settings config type.
const CT_AccountTypes = 1;                        // Account types config type.
const CT_UserAccounts = 2;                        // User account list config type.
const CT_BanList = 3;                             // The player ban list config type.
const CT_BootControl = 4;                         // Boot control settings config type.
const CT_MatchSettings = 5;                       // Match settings config type.
const CT_ExtraServerSettings = 6;                 // Extra server settings config type.
const CT_ExclWeaponList = 7;                      // Excluded weapon list.
const CT_LogSettings = 8;                         // The log settings.

// Special settings.
var config bool bInstalled;                       // Whether or not Nexgen has been installed.
var config int lastInstalledVersion;              // Last installed version of Nexgen.
var private config string serverKey;              // Unique server key.
var config bool isNexgenBoot;                     // Whether the current map has been loaded by the
                                                  // Nexgen boot controller.
var config bool isAdminReboot;                    // Whether an admin has rebooted the server.

// Data encryption support.
var int encryptionKey[3];                         // Key used to encrypt data.
var string codeScheme[3];                         // Code scheme used to encrypt data.
var config int configEncryptionKeys[3];           // You should keep this private.
var config string configCodeSchemes[3];           // You should keep this private.

const CS_GlobalServerSettings = 0;                // Code scheme for global server settings.
const CS_AccountTypes = 1;                        // Code scheme for account types config
const CS_MatchSettings = 2;                       // Code scheme for match settings.

// Global server settings.
var config string serverName;                     // Name of the server.
var config string shortName;                      // Short server name.
var config string adminName;                      // Name of the admin that controls the server.
var config string adminEmail;                     // Email of the admin that controls the server.
var        string globalServerPassword;           // Global password needed to enter the server.
var        string globalAdminPassword;            // Global server administrator password.
var config bool enableUplink;                     // Enable uplink to master server.
var config byte playerSlots;                      // Maximum number of players.
var config byte vipSlots;                         // Extra slots for VIPs if the server if full.
var config byte adminSlots;                       // Extra slots for admins if the server if full.
var config byte spectatorSlots;                   // Number of spectators allowed.
var config string MOTDLine[4];                    // Message of the day lines.
var config bool variablePlayerSlots;              // Use variable player slots.

// Extended server settings.
var config bool autoUpdateBans;                   // Automatically update bans?
var config bool removeExpiredBans;                // Automatically remove expired bans at the
                                                  // beginning of each game?
var config byte waitTime;                         // Time to wait before the game can be started.
var config byte startTime;                        // Time to wait before the game starts.
var config byte autoReconnectTime;                // Time to wait before automatically reconnecting.
var config int maxIdleTime;                       // Maximum time a player can be idle.
var config int maxIdleTimeCP;                     // Maximum idle time when the control panel is open.
var config byte spawnProtectionTime;              // Amount of time spawn protection stays activated.
var config byte teamKillDamageProtectionTime;     // Amount of time team kill damage protection
                                                  // stays activated.
var config byte teamKillPushProtectionTime;       // Amount of time team kill push protection stays
                                                  // activated.
var config bool broadcastTeamKillAttempts;        // Notify players of team kill attempts.
var config bool allowTeamSwitch;                  // Whether team switching is allowed by default.
var config bool allowTeamBalance;                 // Whether team balancing is allowed by default.
var config bool allowNameChange;                  // Whether name changing is allowed by default.
var config byte autoDisableMatchTime;             // Automatically disable match mode if a game is
                                                  // inactive for more then this amount of minutes.
var config string spawnProtectExcludeWeapons[16]; // Weapons and fire modes excluded from cancelling
                                                  // spawn protection.
var config bool restoreScoreOnTeamSwitch;         // Restore the players score when the player has
                                                  // switched to another team.
var config bool enableNexgenStartControl;         // Whether to use the Nexgen game start control
                                                  // feature.
var config bool enableAdminStartControl;          // Only allow match admins (when present) to start
                                                  // the game.
var config bool broadcastAdminActions;            // Should administrator actions be broadcasted to
                                                  // all players?
var config bool autoRegisterServer;               // Automatically register the server in the
                                                  // Nexgen server database.
var config bool useNexgenHUD;                     // Enable the Nexgen HUD extensions.

// Logging.
var config bool logEvents;                        // Write events to the log?
var config bool logSystemMessages;                // Write system messages to the log?
var config bool logChatMessages;                  // Write chat messages to the log?
var config bool logPrivateMessages;               // Write private messages to the log?
var config bool logAdminActions;                  // Write administrator actions to the log?
var config bool logToConsole;                     // Write log entries to stdout?
var config bool logToFile;                        // Write log entries to a special file?
var config string logPath;                        // Path where should the log files be stored.
var config string logFileExtension;               // Extension of log files.
var config string logFileNameFormat;              // File name format for the log files.
var config string logFileTimeStampFormat;         // Time stamp format to use in log files.
var config bool sendPrivateMessagesToMsgSpecs;    // Will message specators recieve pm's?

// Boot control.
var config bool enableBootControl;                // Whether the nexgen boot control is enabled.
var config bool restartOnLastGame;                // Whether to restart on the last game played.
var config string bootGameType;                   // Game type to use when booting.
var config string bootMapPrefix;                  // Map prefix to used to select the map to boot.
var config string bootMutators;                   // Mutators to load for the nexgen server boot.
var        string bootMutatorIndices;             // Indices in the mutatorInfo list of the mutators
                                                  // to load for the nexgen server boot.
var config string bootOptions;                    // Additional boot command line options.
var config string bootCommands;                   // Pre map switch console commands.
var config string lastServerURL;                  // Server commandline URL of last game.

// Match setup.
var config bool matchModeActivated;               // Whether a match is in progress.
var config byte matchesToPlay;                    // Number of games to play for the current match.
var config byte currentMatch;                     // Number of games to play for the current match.
var config string serverPassword;                 // Password (Nexgen) needed to enter the server.
var config bool spectatorsNeedPassword;           // Do spectators need to enter the password?
var config bool muteSpectatorsDuringMatch;        // Should spectators be muted during the match?
var config bool enableMatchBootControl;           // Enable boot control for matches.
var config bool matchAutoLockTeams;               // Automatically lock teams in match mode.
var config bool matchAutoPause;                   // Automatically pause game when a player leaves.
var config bool matchAutoSeparate;                // Automatically separate players by tag.
var config string tagsToSeparate[4];              // Name tags used to separate players in teams.

// Account system.
var config string atTypeName[10];                 // Account type names.
var config string atRights[10];                   // Rights for the account types.
var config string atTitle[10];                    // Titles for the account types.
var config string atPassword[10];                 // Password for the account types.
var config string paPlayerID[128];                // Player ID list.
var config string paPlayerName[128];              // Names of the player accounts.
var config int paAccountType[128];                // Associated account type.
var config string paCustomRights[128];            // Custom rights if no account type is used.
var config string paCustomTitle[128];             // Custom title if no account type is used.
var string rightsDef[18];                         // Rights definitions.
var byte giveRightToRoot[18];                     // Whether root admins recieve this right.

// Ban system.
var config string bannedName[128];                // Name of banned player.
var config string bannedIPs[128];                 // IP address(es) of the banned player.
var config string bannedIDs[128];                 // Client ID(s) of the banned player.
var config string banReason[128];                 // Reason why the player was banned.
var config string banPeriod[128];                 // Ban period; how long the player is banned.

const maxBanIPAddresses = 8;                      // Maximum number of banned IP's per ban entry.
const maxBanClientIDs = 6;                        // Maximum number of banned ID's per ban entry.

const BP_Forever = 0;                             // Banned forever.
const BP_Matches = 1;                             // Banned for 'x' matches.
const BP_UntilDate = 2;                           // Banned until some 'date'.

// Misc.
var string serverID;                              // Public (unique) server identification code.
                                                  // Should be the last value replicated, so the
                                                  // client can check when the replication is
                                                  // complete. Edit: this is now taken care of by
                                                  // the checksum variable.
var class<NexgenPanel> serverInfoPanelClass;      // Server info panel class.
var class<NexgenPanel> gameInfoPanelClass;        // Game info panel class.
var class<NexgenPanel> matchControlPanelClass;    // Match control panel class.
var string gameTypeInfo[32];                      // Game type description strings.
var string mutatorInfo[128];                      // Mutator description strings.
var byte activeGameType;                          // Index in the gameTypeInfo list of the currently
                                                  // active game type.
var string activeMutatorIndices;                  // Indices in the mutatorInfo list of the mutators
                                                  // currently loaded.

const IW_Fire = "P";                              // Ignore weapon primary fire tag.
const IW_AltFire = "S";                           // Ignore weapon alt fire tag.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

	reliable if (role == ROLE_Authority)
		// Static. Doesn't change during the game.
		staticChecksum, serverID, rightsDef, gameTypeInfo, mutatorInfo, activeGameType,
		serverInfoPanelClass, gameInfoPanelClass, activeMutatorIndices, matchControlPanelClass,
		
		// Dynamic.	May change during the game.
		dynamicChecksums, dynamicChecksumModifiers, updateCounts,
		
		// Global server settings config type.
		serverName, shortName, adminName, adminEmail, globalServerPassword, globalAdminPassword,
		playerSlots, vipSlots, adminSlots, spectatorSlots,  enableUplink, MOTDLine,
		variablePlayerSlots, 
		
		// Account types config type.
		atTypeName, atRights, atTitle, atPassword, paCustomTitle,
		
		// User account list config type.
		paPlayerID, paPlayerName, paAccountType, paCustomRights,
		
		// The player ban list config type.
		bannedName, bannedIPs, bannedIDs, banReason, banPeriod,
		
		// Boot control settings config type.
		enableBootControl, restartOnLastGame, bootGameType, bootMapPrefix, bootMutatorIndices,
		bootOptions, bootCommands,
		
		// Match settings config type.
		serverPassword, spectatorsNeedPassword, matchModeActivated, matchesToPlay, currentMatch,
		muteSpectatorsDuringMatch, enableMatchBootControl, matchAutoLockTeams, matchAutoPause,
		matchAutoSeparate, tagsToSeparate,
		
		// Extra server settings config type.
		autoReconnectTime, maxIdleTime, spawnProtectionTime, teamKillDamageProtectionTime,
		teamKillPushProtectionTime, broadcastTeamKillAttempts, autoUpdateBans, removeExpiredBans,
		useNexgenHUD, waitTime, startTime, allowTeamSwitch, allowTeamBalance, allowNameChange,
		autoDisableMatchTime, maxIdleTimeCP, restoreScoreOnTeamSwitch, enableNexgenStartControl,
		enableAdminStartControl, broadcastAdminActions, autoRegisterServer,
		
		// Excluded weapon list.
		spawnProtectExcludeWeapons,
		
		// The log settings.
		logEvents, logSystemMessages, logChatMessages, logPrivateMessages, logAdminActions,
		logToConsole, logToFile, logPath, logFileExtension, logFileNameFormat,
		logFileTimeStampFormat, sendPrivateMessagesToMsgSpecs;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Calculates a checksum of the replicated dynamic variables.
 *  $PARAM        configType  The configuration type for which the checksum is to be calculated.
 *  $REQUIRE      configType == CT_GlobalServerSettings ||
 *                configType == CT_AccountTypes ||
 *                configType == CT_UserAccounts ||
 *                configType == CT_BanList ||
 *                configType == CT_BootControl ||
 *                configType == CT_MatchSettings ||
 *                configType == CT_ExtraServerSettings ||
 *                configType == CT_ExclWeaponList ||
 *                configType == CT_LogSettings
 *  $RETURN       The checksum of the replicated variables.
 *
 **************************************************************************************************/
simulated function int calcDynamicChecksum(byte configType) {
	local int checksum;
	local int index;
	
	checksum += dynamicChecksumModifiers[configType];
	
	switch (configType) {
		case CT_GlobalServerSettings: // Global server settings config type.
			checksum += len(serverName)               +
			            len(shortName)                +
			            len(adminName)                +
			            len(adminEmail)               +
			            len(globalServerPassword)     +
			            playerSlots                   +
			            vipSlots                      +
			            adminSlots                    +
			            int(enableUplink)             |
                        int(variablePlayerSlots) << 1 ;
			for (index = 0; index < arrayCount(MOTDLine); index++) {
				checksum += len(MOTDLine[index]);
			}
			break;
		
		case CT_AccountTypes: // Account types config type.
			for (index = 0; index < arrayCount(atTypeName); index++) {
				checksum += len(atTypeName[index]);
			}
			for (index = 0; index < arrayCount(atRights); index++) {
				checksum += len(atRights[index]);
			}
			for (index = 0; index < arrayCount(atTitle); index++) {
				checksum += len(atTitle[index]);
			}
			for (index = 0; index < arrayCount(atPassword); index++) {
				checksum += len(atPassword[index]);
			}
			break;
		
		case CT_UserAccounts: // User account list config type.
			for (index = 0; index < arrayCount(paPlayerID); index++) {
				checksum += len(paPlayerID[index]);
			}
			for (index = 0; index < arrayCount(paPlayerName); index++) {
				checksum += len(paPlayerName[index]);
			}
			for (index = 0; index < arrayCount(paAccountType); index++) {
				checksum += paAccountType[index];
			}
			for (index = 0; index < arrayCount(paCustomRights); index++) {
				checksum += len(paCustomRights[index]);
			}
			for (index = 0; index < arrayCount(paCustomTitle); index++) {
				checksum += len(paCustomTitle[index]);
			}
			break;
		
		case CT_BanList: // The player ban list config type.
			for (index = 0; index < arrayCount(bannedName); index++) {
				checksum += len(bannedName[index]);
			}
			for (index = 0; index < arrayCount(bannedIPs); index++) {
				checksum += len(bannedIPs[index]);
			}
			for (index = 0; index < arrayCount(bannedIDs); index++) {
				checksum += len(bannedIDs[index]);
			}
			for (index = 0; index < arrayCount(banReason); index++) {
				checksum += len(banReason[index]);
			}
			for (index = 0; index < arrayCount(banPeriod); index++) {
				checksum += len(banPeriod[index]);
			}
			break;
			
		case CT_BootControl: // Boot control settings config type.
			checksum += int(enableBootControl)      |
			            int(restartOnLastGame) << 1 +
			            len(bootGameType)           +
			            len(bootMapPrefix)          +
			            len(bootMutatorIndices)     +
			            len(bootOptions)            +
			            len(bootCommands)           ;
			break;
		
		case CT_MatchSettings: // Match settings config type.
			checksum += int(spectatorsNeedPassword)         |
			            int(matchModeActivated)        << 1 |
			            int(muteSpectatorsDuringMatch) << 2 |
			            int(enableMatchBootControl)    << 3 |
			            int(matchAutoLockTeams)        << 4 |
			            int(matchAutoPause)            << 5 |
			            int(matchAutoSeparate)         << 6 +
			            len(serverPassword)                 +
			            matchesToPlay                       +
			            currentMatch                        ;
			for (index = 0; index < arrayCount(tagsToSeparate); index++) {
				checksum += len(tagsToSeparate[index]);
			}
			break;
			
		case CT_ExtraServerSettings: // Extra server settings config type.
			checksum += int(broadcastTeamKillAttempts)      |
			            int(autoUpdateBans)           <<  1 |
			            int(removeExpiredBans)        <<  2 |
			            int(allowTeamSwitch)          <<  3 |
			            int(allowTeamBalance)         <<  4 |
			            int(allowNameChange)          <<  5 |
			            int(restoreScoreOnTeamSwitch) <<  6 |
			            int(enableNexgenStartControl) <<  7 |
			            int(enableAdminStartControl)  <<  8 |
			            int(broadcastAdminActions)    <<  9 |
			            int(autoRegisterServer)       << 10 |
			            int(useNexgenHUD)             << 11 +
			            autoReconnectTime                   +
			            maxIdleTime                         +
			            spawnProtectionTime                 +
			            teamKillDamageProtectionTime        +
			            teamKillPushProtectionTime          +
			            waitTime                            +
			            startTime                           +
			            autoDisableMatchTime                +
			            maxIdleTimeCP                       ;
			break;
		
		case CT_ExclWeaponList: // Excluded weapon list.
			for (index = 0; index < arrayCount(spawnProtectExcludeWeapons); index++) {
				checksum += len(spawnProtectExcludeWeapons[index]);
			}
			break;
		
		case CT_LogSettings: // The log settings.
			checksum += int(logEvents)                          |
			            int(logSystemMessages)             << 1 |
			            int(logChatMessages)               << 2 |
			            int(logPrivateMessages)            << 3 |
			            int(logAdminActions)               << 4 |
			            int(logToConsole)                  << 5 |
			            int(logToFile)                     << 6 |
			            int(sendPrivateMessagesToMsgSpecs) << 7 +
			            len(logPath)                            +
			            len(logFileExtension)                   +
			            len(logFileNameFormat)                  +
			            len(logFileTimeStampFormat)             ;
			break;
	}
		
	return checksum;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Calculates a checksum of the replicated static variables.
 *  $RETURN       The checksum of the replicated variables.
 *
 **************************************************************************************************/
simulated function int calcStaticChecksum() {
	local int checksum;
	local int index;
	
	for (index = 0; index < arrayCount(rightsDef); index++) {
		checksum += len(rightsDef[index]);
	}
	for (index = 0; index < arrayCount(gameTypeInfo); index++) {
		checksum += len(gameTypeInfo[index]);
	}
	for (index = 0; index < arrayCount(mutatorInfo); index++) {
		checksum += len(mutatorInfo[index]);
	}
	checksum += len(serverID)              +
	            len(serverInfoPanelClass)  +
	            len(gameInfoPanelClass)    +
	            activeGameType             +
	            len(activeMutatorIndices)  +
	            len(matchControlPanelClass);
	
	return checksum;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the checksums for the current replication info.
 *  $PARAM        configType  The configuration type for which the checksum is to be calculated.
 *  $ENSURE       dynamicChecksums[configType] == calcDynamicChecksum(configType)
 *
 **************************************************************************************************/
function updateChecksum(byte configType) {
	dynamicChecksumModifiers[configType] = rand(maxInt);
	dynamicChecksums[configType] = calcDynamicChecksum(configType);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the checksum for the static replication info.
 *  $ENSURE       staticChecksum == calcStaticChecksum()
 *
 **************************************************************************************************/
function updateStaticChecksum() {
	staticChecksum = calcStaticChecksum();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the checksums for the dynamic replication info.
 *  $ENSURE       foreach(type => dynamicChecksum in dynamicChecksums)
 *                  dynamicChecksum == calcDynamicChecksum(type)
 *
 **************************************************************************************************/
function updateDynamicChecksums() {
	local byte index;
	
	for (index = 0; index < arrayCount(dynamicChecksums); index++) {
		updateChecksum(index);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the server configuration.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	
	// Check owner.
	if (owner == none || !owner.isA('NexgenController')) {
		destroy();
		return;
	}
	control = NexgenController(owner);
	
	// Finish initialization.
	bInitialized = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Finalizes the initialization process. Calling this function makes sure that any
 *                uninitialized variables are set.
 *  $REQUIRE      bInitialized && bInstalled
 *
 **************************************************************************************************/
function postInitialize() {
	local string mutatorClass;
	local string remaining;
	local int index;
	local string url;
	local string activeGameTypeClass;
	local string gameTypeClass;
	local bool bFound;
	
	serverID = class'MD5Hash'.static.MD5String(serverKey);
	for (index = 0; index < arrayCount(dynamicChecksums); index++) {
		updateCounts[index] = 1;
	}
	
	for (index = 0; index < arrayCount(configEncryptionKeys); index++) {
		setEncryptionParams(index, configEncryptionKeys[index], configCodeSchemes[index]);
	}
	
	// Read settings from server config file.
	globalServerPassword = encode(CS_GlobalServerSettings, consoleCommand("get Engine.GameInfo GamePassword"));
	globalAdminPassword = encode(CS_GlobalServerSettings, consoleCommand("get Engine.GameInfo AdminPassword"));
	
	// Add default right definitions.
	addRightDefiniton("A", control.lng.allowedToPlayRightDesc);
	addRightDefiniton("B", control.lng.vipSlotAccessRightDesc);
	addRightDefiniton("C", control.lng.adminSlotAccessRightDesc);
	addRightDefiniton("D", control.lng.needsNoPWRightDesc);
	addRightDefiniton("E", control.lng.canBeIdleRightDesc);
	addRightDefiniton("F", control.lng.matchAdminRightDesc);
	addRightDefiniton("G", control.lng.moderatorRightDesc);
	addRightDefiniton("K", control.lng.matchSetRightDesc);
	addRightDefiniton("H", control.lng.banOpRightDesc);
	addRightDefiniton("I", control.lng.accountMngrRightDesc);
	addRightDefiniton("J", control.lng.serverAdminRightDesc);
	addRightDefiniton("L", control.lng.canBanAccountsRightDesc);
	addRightDefiniton("M", control.lng.hiddenAdminRightDesc, true);
	
	// Load game & mutator lists.
	loadGameTypeList();
	loadMutatorList();
	
	// Load mutator index list.
	remaining = bootMutators;
	while (remaining != "") {
		class'NexgenUtil'.static.split(remaining, mutatorClass, remaining);
		index = getMutatorIndex(mutatorClass);
		if (index >= 0) {
			if (bootMutatorIndices == "") {
				bootMutatorIndices = string(index);
			} else {
				bootMutatorIndices = bootMutatorIndices $ separator $ index;
			}
		}
	}
	
	// Get current server command line.
	url = level.getLocalURL();
	url = mid(url, instr(url, "/") + 1);
	lastServerURL = url;
	
	// Get currently active game type.
	activeGameTypeClass = string(level.game.class);
	index = 0;
	while (!bFound && index < arrayCount(gameTypeInfo) && gameTypeInfo[index] != "") {
		// Get game type class.
		class'NexgenUtil'.static.split(gameTypeInfo[index], gameTypeClass, remaining);
		
		// Check if the classes match.
		if (activeGameTypeClass ~= gameTypeClass) {
			bFound = true;
			activeGameType = index;
		} else {
			index++;
		}
	}
	
	// Update match settings.
	if (matchModeActivated) {
		if (currentMatch > matchesToPlay) {
			currentMatch = 0;
			matchModeActivated = false;
		}
	}
	
	// Remove expired bans if desired.
	if (removeExpiredBans) {
		cleanExpiredBans();
	}
	
	// Update ban periods.
	updateBanPeriods();
	
	// Clear Nexgen boot controller flag.
	isNexgenBoot = false;
	
	// Update player slots if set to variable.
	if (variablePlayerSlots) {
		playerSlots = level.game.maxPlayers;
	}
	
	// Save data.
	saveConfig();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads a list of all game types available on this server.
 *
 **************************************************************************************************/
function loadGameTypeList() {
	local string game;
	local string description;
	local int index;
	local string gameInfoStr;
	local class<GameInfo> gameClass;
	local string mapName;
	
	// For each game type...
	getNextIntDesc("TournamentGameInfo", 0, game, description);
	while(game != "" && index < arrayCount(gameTypeInfo)) {
		
		// Get game type info.
		gameClass = class<GameInfo>(dynamicLoadObject(game, class'Class'));
		
		if (class'NexgenUtil'.static.trim(description) == "") {
			description = gameClass.default.gameName;
		}
		
		gameInfoStr = game $ separator $
		              gameClass.default.mapPrefix $ separator $
		              description;
		
		// Store game type info.
		gameTypeInfo[index] = gameInfoStr;
		
		// Continue with next game type.
		getNextIntDesc("TournamentGameInfo", ++index, game, description);
	}	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads a list of all mutators available on this server.
 *
 **************************************************************************************************/
function loadMutatorList() {
	local string mutator;
	local string description;
	local int index;
	local string mutatorInfoStr;
	
	// For each mutator...
	getNextIntDesc("Mutator", 0, mutator, description);
	while (mutator != "" && index < arrayCount(mutatorInfo)) {
		
		// Get mutator info.
		if (instr(description, ",") >= 0) {
			description = left(description, instr(description, ","));
		}
		mutatorInfoStr = mutator $ separator $ description;
		
		// Store mutator info.
		mutatorInfo[index] = mutatorInfoStr;
		
		// Continue with next mutator.
		getNextIntDesc("Mutator", ++index, mutator, description);	
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Generates new encryption parameters for the server.
 *
 **************************************************************************************************/
function resetEncryptionConfig(int index) {
	local byte cb;
	local bool bValidChar;
	
	configEncryptionKeys[index] = (rand(0x10000) << 16) | rand(0x10000);
	configCodeSchemes[index] = "";
	while (len(configCodeSchemes[index]) < 32) {
		do {
			cb = rand(93) + 33;
			bValidChar = (cb != 34) && (instr(configCodeSchemes[index], chr(cb)) < 0);
		} until (bValidChar);
		configCodeSchemes[index] =  configCodeSchemes[index] $ chr(cb);
	}
	setEncryptionParams(index, configEncryptionKeys[index], configCodeSchemes[index]);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Performs a default installation of the Nexgen Server Controller. Calling this
 *                function will automatically configure the server for first use.
 *  $REQUIRE      bInitialized && !bInstalled
 *
 **************************************************************************************************/
function install() {
	local string packageName;
	local int index;
	
	packageName = class'NexgenUtil'.default.packageName;
	
	// Create unique key for this server.
	serverKey = class'NexgenUtil'.static.makeKey();
	
	// Set encryption parameters for this server.
	resetEncryptionConfig(CS_GlobalServerSettings);
	
	// Add default account types.
	addAccountType("<Default>",     "A", "Player"); // No account.
	addAccountType("VIP",           "A,B");
	addAccountType("Level 3 Admin", "A,B,C,D,F",               "L3 Admin");
	addAccountType("Level 4 Admin", "A,B,C,D,F,G",             "L4 Admin");
	addAccountType("Level 5 Admin", "A,B,C,D,E,F,G,H,K",       "L5 Admin");
	addAccountType("Level 6 Admin", "A,B,C,D,E,F,G,H,I,K,L",   "L6 Admin");
	addAccountType("Level 7 Admin", "A,B,C,D,E,F,G,H,I,J,K,L", "L7 Admin");
	
	// Set default settings.
	serverName = level.game.gameReplicationInfo.serverName;
	shortName = level.game.gameReplicationInfo.shortName;
	adminName = level.game.gameReplicationInfo.adminName;
	adminEmail = level.game.gameReplicationInfo.adminEmail;
	//globalServerPassword = encode(consoleCommand("get Engine.GameInfo GamePassword")); -- No longer config.
	//globalAdminPassword = encode(consoleCommand("get Engine.GameInfo AdminPassword")); -- No longer config.
	serverPassword = "";
	enableUplink = consoleCommand("get IpServer.UdpServerUplink DoUplink") ~= "True";
	spectatorsNeedPassword = false;
	variablePlayerSlots = true;
	playerSlots = level.game.maxPlayers;
	vipSlots = 0;
	adminSlots = 0;
	spectatorSlots = level.game.maxSpectators;
	autoUpdateBans = true;
	waitTime = 10;
	startTime = 5;
	autoReconnectTime = 10;
	maxIdleTime = 40;
	maxIdleTimeCP = 120; 
	spawnProtectionTime = 10;
	teamKillDamageProtectionTime = 0;
	teamKillPushProtectionTime = 8;
	broadcastTeamKillAttempts = false;
	MOTDLine[0] = level.game.gameReplicationInfo.MOTDLine1;
	MOTDLine[1] = level.game.gameReplicationInfo.MOTDLine2;
	MOTDLine[2] = level.game.gameReplicationInfo.MOTDLine3;
	MOTDLine[3] = level.game.gameReplicationInfo.MOTDLine4;
	spawnProtectExcludeWeapons[0]="Botpack.Translocator,PS";
	spawnProtectExcludeWeapons[1]="Botpack.SniperRifle,S";
	
	enableBootControl = false;
	lastServerURL = "";
	restartOnLastGame = true;
	
	matchModeActivated = false;
	matchesToPlay = 5;
	currentMatch = 1;
	serverPassword = "";
	spectatorsNeedPassword = true;
	muteSpectatorsDuringMatch = true;
	enableMatchBootControl = true;
	matchAutoLockTeams = true;
	matchAutoPause = false;
	matchAutoSeparate = false;
	
	allowTeamSwitch = true;
	allowTeamBalance = true;
	allowNameChange = true;
	autoDisableMatchTime = 5;
	
	// Server controller has been successfully installed.
	bInstalled = true;
	saveConfig();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the configuration to the current Nexgen version.
 *  $ENSURE       lastInstalledVersion >= class'NexgenUtil'.default.versionCode
 *
 **************************************************************************************************/
function updateConfig() {
	
	if (lastInstalledVersion < 106) installVersion106();
	if (lastInstalledVersion < 107) installVersion107();
	if (lastInstalledVersion < 108) installVersion108();
	if (lastInstalledVersion < 109) installVersion109();
	if (lastInstalledVersion < 110) installVersion110();
	if (lastInstalledVersion < 112) installVersion112();
	
	lastInstalledVersion = class'NexgenUtil'.default.versionCode;
	saveConfig();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 1.06 of the Nexgen Server Controller.
 *
 **************************************************************************************************/
function installVersion106() {
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 1.07 of the Nexgen Server Controller.
 *
 **************************************************************************************************/
function installVersion107() {
	enableNexgenStartControl = true;
	addAccountType("Hidden Admin", "A,B,C,D,E,F,G,H,K,M");
	logAdminActions = logEvents;
	broadcastAdminActions = true;
	logToConsole = true;
	logToFile = false;
	logPath = "../Logs";
	logFileExtension = "log";
	logFileNameFormat = control.lng.defaultLogFileNameFormat;
	logFileTimeStampFormat = control.lng.defaultLogFileTimeStampFormat;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 1.08 of the Nexgen Server Controller.
 *
 **************************************************************************************************/
function installVersion108() {
	autoRegisterServer = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 1.09 of the Nexgen Server Controller.
 *
 **************************************************************************************************/
function installVersion109() {
	local int index;
	
	setEncryptionParams(CS_GlobalServerSettings, configEncryptionKeys[CS_GlobalServerSettings],
	                    configCodeSchemes[CS_GlobalServerSettings]);
	resetEncryptionConfig(CS_AccountTypes);
	resetEncryptionConfig(CS_MatchSettings);
	
	for (index = 0; index < arrayCount(atPassword); index++) {
		atPassword[index] = encode(CS_AccountTypes, decode(CS_GlobalServerSettings, atPassword[index]));
	}
	serverPassword = encode(CS_MatchSettings, decode(CS_GlobalServerSettings, serverPassword));
	
	sendPrivateMessagesToMsgSpecs = false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 1.10 of the Nexgen Server Controller.
 *
 **************************************************************************************************/
function installVersion110() {
	useNexgenHUD = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 1.12 of the Nexgen Server Controller.
 *
 **************************************************************************************************/
function installVersion112() {
	enableAdminStartControl = false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified account type to the server controller.
 *  $PARAM        typeName  Name of the account type to add.
 *  $PARAM        rights    The rights for this account type.
 *  $PARAM        title     Title for players that have this account name.
 *  $REQUIRE      typeName != ""
 *
 **************************************************************************************************/
function addAccountType(string typeName, string rights, optional string title) {
	local int index;
	local bool bFound;
	
	// Find an empty account type slot.
	while (!bFound && index < arrayCount(atTypeName)) {
		if (atTypeName[index] == "") {
			// This slot is empty.
			bFound = true;
			atTypeName[index] = typeName;
			atRights[index] = rights;
			atTitle[index] = title;
		} else {
			// This one is used, continue search.
			index++;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Defines a new type of client right. Note that defining a right may fail if there
 *                isn't a free slot available for the definition. 
 *  $PARAM        rightID      String identifier of the client right.
 *  $PARAM        description  Description of the right.
 *  $REQUIRE      bInitialized && rightID != "" && description != ""
 *  $RETURN       True, if the right definition was added, false not.
 *
 **************************************************************************************************/
function bool addRightDefiniton(string rightID, string description, optional bool bNotForRoot) {
	local bool bFound;
	local int index;
	
	// Find empty slot.
	while (!bFound && index < arrayCount(rightsDef)) {
		if (rightsDef[index] == "") {
			// Empty slot found.
			bFound = true;
			rightsDef[index] = rightID $ separator $ description;
			giveRightToRoot[index] = byte(!bNotForRoot);
		} else {
			// Slot is in use, continue with the next one.
			index++;
		}
	}
	
	return bFound;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the current configuration. Any invalid settings will be automatically
 *                adjusted to a proper setting.
 *  $REQUIRE      bInitialized
 *  $RETURN       True, if the configuration was valid, false otherwise.
 *  $ENSURE       !old.checkConfig() ? new.checkConfig() : true
 *
 **************************************************************************************************/
function bool checkConfig() {
	local bool bConfigOk;
	local NexgenConfigChecker cCheck;

	cCheck = spawn(class'NexgenConfigChecker');
	bConfigOk = cCheck.checkConfig(self);
	cCheck.destroy();

	return bConfigOk;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the index in the ban list for the given player info.
 *  $PARAM        playerName  Name of the player for which the entry in the ban list is to be found.
 *  $PARAM        playerIP    IP address of the player.
 *  $PARAM        playerID    ID code of the player.
 *  $RETURN       The index in the ban list for the specified player if banned, -1 if the player is
 *                not banned on the server.
 *  $ENSURE       0 <= result && result <= arrayCount(bannedName) || result == -1
 *
 **************************************************************************************************/
function int getBanIndex(string playerName, string playerIP, string playerID) {
	local int index;
	local bool bFound;
	local bool bIPMatch;
	local bool bIDMatch;
	
	// Lookup player in the ban list.
	while (!bFound && index < arrayCount(bannedName) && bannedName[index] != "") {
		
		bIPMatch = instr(bannedIPs[index], playerIP) >= 0;
		bIDMatch = instr(bannedIDs[index], playerID) >= 0;
		
		// Match?
		if (bIPMatch || bIDMatch) {
			// Oh yeah.
			bFound = true;
			
		} else {
			// Nope, maybe next.
			index++;
		}
		
	}
	
	// Return index in the ban list.
	if (bFound) {
		return index;
	} else {
		return -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the specified ban entry. If a new IP or ID for the specified entry is
 *                detected it will be added.
 *  $PARAM        index     Location in the banlist.
 *  $PARAM        playerIP  IP address of the player.
 *  $PARAM        playerID  ID code of the player.
 *  $REQUIRE      0 <= index && index <= arrayCount(bannedName) && bannedName[index] != ""
 *  $RETURN       True if the specified ban entry was updated, false if no changes were made.
 *  $ENSURE       instr(bannedIPs[index], playerIP) >= 0 && instr(bannedIDs[index], playerID) >= 0
 *
 **************************************************************************************************/
function bool updateBan(int index, string playerIP, string playerID) {
	local bool bIPMatch;
	local bool bIDMatch;
	local string remaining;
	local string currIP;
	local string currID;
	local int ipCount;
	local int idCount;
	
	// Compare & count IP address.
	remaining = bannedIPs[index];
	while (!bIPMatch && remaining != "") {
		class'NexgenUtil'.static.split(remaining, currIP, remaining);
		currIP = class'NexgenUtil'.static.trim(currIP);
		if (currIP ~= playerIP) {
			bIPMatch = true;
		} else {
			ipCount++;
		}
	}
	
	// Add IP address if not already in the list and the list isn't full.
	if (!bIPMatch && ipCount < maxBanIPAddresses) {
		if (bannedIPs[index] == "") {
			bannedIPs[index] = playerIP;
		} else {
			bannedIPs[index] = bannedIPs[index] $ separator $ playerIP;
		}
	}
	
	// Compare & count client ID's.
	remaining = bannedIDs[index];
	while (!bIDMatch && remaining != "") {
		class'NexgenUtil'.static.split(remaining, currID, remaining);
		currID = class'NexgenUtil'.static.trim(currID);
		if (currID ~= playerID) {
			bIDMatch = true;
		} else {
			idCount++;
		}
	}
	
	// Add client ID if not already in the list and the list isn't full.
	if (!bIDMatch && idCount < maxBanClientIDs) {
		if (bannedIDs[index] == "") {
			bannedIDs[index] = playerID;
		} else {
			bannedIDs[index] = bannedIDs[index] $ separator $ playerID;
		}
	}
	
	// Save changes.
	if (!bIPMatch || !bIDMatch) {
		saveConfig();
		return true;
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified ban entry has expired.
 *  $PARAM        index  Location in the banlist.
 *  $REQUIRE      0 <= index && index <= arrayCount(bannedName) && bannedName[index] != ""
 *  $RETURN       True if the specified ban entry has expired, false if not.
 *
 **************************************************************************************************/
function bool isExpiredBan(int index) {
	local bool bExpired;
	local byte banPeriodType;
	local string banPeriodArgs;
	local int year, month, day, hour, minute;
	
	// Get period type.
	getBanPeriodType(banPeriod[index], banPeriodType, banPeriodArgs);
	
	// Check for expiration.
	if (banPeriodType == BP_Matches) {
		// Banned for some matches.
		bExpired = (int(banPeriodArgs) <= 0);
		
	} else if (banPeriodType == BP_UntilDate) {
		// Banned until some date.
		class'NexgenUtil'.static.readDate(banPeriodArgs, year, month, day, hour, minute);
		
		bExpired =  level.year   > year  || level.year  == year  &&
		           (level.month  > month || level.month == month &&
		           (level.day    > day   || level.day   == day   &&
		           (level.hour   > hour  || level.hour  == hour  &&
		            level.minute >= minute)));

	} else {
		// Banned forever, never expires.
		bExpired = false;
	}
	
	// Return result.
	return bExpired;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes all expired bans from the banlist.
 *  $RETURN       True if one ore more bans were removed from the banlist.
 *
 **************************************************************************************************/
function bool cleanExpiredBans() {
	local int currBan;
	local bool bBanDeleted;
	
	// Check each ban entry.
	while (currBan < arrayCount(bannedName) && bannedName[currBan] != "") {
		if (isExpiredBan(currBan)) {
			removeBan(currBan);
			bBanDeleted = true;
		} else {
			currBan++;
		}
	}
	
	// Return result.
	return bBanDeleted;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the specified entry from the banlist.
 *  $PARAM        entryNum  Location in the banlist.
 *  $REQUIRE      0 <= entryNum && entryNum <= arrayCount(bannedName) && bannedName[entryNum] != ""
 *  $ENSURE       new.bannedName[entryNum] != old.bannedName[entryNum]
 *
 **************************************************************************************************/
function removeBan(int entryNum) {
	local int index;
	
	for (index = entryNum; index < arrayCount(bannedName); index++) {
		// Last entry?
		if (index + 1 == arrayCount(bannedName)) {
			// Yes, clear fields.
			bannedName[index] = "";
			bannedIPs[index] = "";
			bannedIDs[index] = "";
			banReason[index] = "";
			banPeriod[index] = "";
		} else {
			// No, copy fields from next entry.
			bannedName[index] = bannedName[index + 1];
			bannedIPs[index] = bannedIPs[index + 1];
			bannedIDs[index] = bannedIDs[index + 1];
			banReason[index] = banReason[index + 1];
			banPeriod[index] = banPeriod[index + 1];
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the ban period strings. Note this function should only be called once
 *                during the game, preferrably at the beginning of the game as it might cause a
 *                checksum mismatch for the dynamic config data.
 *
 **************************************************************************************************/
function updateBanPeriods() {
	local int currBan;
	local byte banPeriodType;
	local string banPeriodArgs;
	
	// Check each ban entry.
	while (currBan < arrayCount(bannedName) && bannedName[currBan] != "") {
		getBanPeriodType(banPeriod[currBan], banPeriodType, banPeriodArgs);
		
		if (banPeriodType == BP_Matches) {
			banPeriod[currBan] = "M" $ max(0, int(banPeriodArgs) - 1);
		}
		
		currBan++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the title for the specified user account.
 *  $PARAM        accountNum  Index of the user account which is to be used.
 *  $REQUIRE      0 <= accountNum && accountNum <= arrayCount(paPlayerID)
 *  $RETURN       The title assigned to the specified account.
 *  $ENSURE       result != ""
 *
 **************************************************************************************************/
simulated function string getUserAccountTitle(byte accountNum) {
	if (paAccountType[accountNum] < 0) {
		return paCustomTitle[accountNum];
	} else {
		return getAccountTypeTitle(paAccountType[accountNum]);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the title for the specified account type.
 *  $PARAM        accountType  Index of the account type which is to be used.
 *  $REQUIRE      0 <= accountType && accountType <= arrayCount(atTypeName)
 *  $RETURN       The title assigned to the specified account type.
 *  $ENSURE       result != ""
 *
 **************************************************************************************************/
simulated function string getAccountTypeTitle(byte accountType) {
	if (atTitle[accountType] == "") {
		return atTypeName[accountType];
	} else {
		return atTitle[accountType];
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the account index for the specified clientID.
 *  $PARAM        clientID  The client identification code of the player whose account index is to
 *                          be returned.
 *  $REQUIRE      clientID != ""
 *  $RETURN       The index in the user account list for the specified player. In case there is no
 *                account for the player, -1 will be returned.
 *  $ENSURE       result == -1 || 0 <= result && result <= arrayCount(paPlayerID) &&
 *                result >= 0 ? paPlayerID[result] ~= clientID : true
 *
 **************************************************************************************************/
simulated function int getUserAccountIndex(string clientID) {
	local int index;
	local bool bFound;
	
	// Locate account.
	while (!bFound && index < arrayCount(paPlayerID) && paPlayerID[index] != "") {
		// Check entry...
		if (paPlayerID[index] ~= clientID) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Return result.
	if (bFound) {
		return index;
	} else {
		return -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new user account to the server. Note that if there already is an existing
 *                account for the specified clientID, that account will be overwritten.
 *  $PARAM        clientID      Identification code of the player for which an account has to be
 *                              added.
 *  $PARAM        accountName   Name of the player for which the account is to be made.
 *  $PARAM        accountType   Type of account to use. Use -1 to indicate a custom account.
 *  $PARAM        customRights  Rights string for a custom account type.
 *  $PARAM        customTitle   User title for a custom account type.
 *  $REQUIRE      clientID != "" && accountName != "" &&
 *                -1 <= accountType && accountType <= arrayCount(atTypeName) &&
 *                (accountType == -1 ? customTitle != "" : true)
 *  $RETURN       The position in the user accountlist where the account was stored. If all user
 *                account slots are occupied -1 will be returned and the account isn't saved.
 *  $ENSURE       -1 <= result && result <= arrayCount(paPlayerID) &&
 *                (result >= 0 ? paPlayerID[result] == clientID &&
 *                               paPlayerName[result] == accountName &&
 *                               paAccountType[result] == accountType &&
 *                               paCustomRights[result] == customRights &&
 *                               paCustomTitle[result] == customTitle
 *                             : true)
 *
 **************************************************************************************************/
function int addUserAccount(string clientID, string accountName, int accountType,
                            optional string customRights, optional string customTitle) {
	local int index;
	local bool bFound;
	
	// Check if player already has an account.
	index = getUserAccountIndex(clientID);
	if (index >= 0) {
		// Yeah, update existing account.
		bFound = true;
	} else {
		// Nope find an empty slot.
		index = 0;
		while (!bFound && index < arrayCount(paPlayerID)) {
			if (paPlayerID[index] == "") {
				// Empty slot found, use it!
				bFound = true;
			} else {
				// Slot is used, check next one.
				index++;
			}
		}
	}
	
	// Store account.
	if (bFound) {
		paPlayerID[index] = clientID;
		paPlayerName[index] = accountName;
		paAccountType[index] = accountType;
		paCustomRights[index] = customRights;
		paCustomTitle[index] = customTitle;
	}
	
	// Return index of created account.
	if (bFound) {
		return index;
	} else {
		return -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a rights string containing all available rights.
 *  $PARAM        bForRootAdmin  Whether to include only the rights that are for root admins.
 *  $RETURN       A rights string with all rights that are defined on this server.
 *  $ENSURE       result != ""
 *
 **************************************************************************************************/
function string getAllRights(optional bool bForRootAdmin) {
	local int index;
	local string rights;
	
	while (index < arrayCount(rightsDef) && rightsDef[index] != "") {
		if (!bForRootAdmin || bool(giveRightToRoot[index])) {
			if (index > 0) {
				rights = rights $ separator $ left(rightsDef[index], instr(rightsDef[index], separator));
			} else {
				rights = left(rightsDef[index], instr(rightsDef[index], separator));
			}
		}
		index++;
	}
	
	return rights;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the ban period type and its argument from the specified ban period
 *                string.
 *  $PARAM        banPeriodStr   The ban period description string.
 *  $PARAM        banPeriodType  Ban period type number.
 *  $PARAM        args           Optional arguments of the ban period type.
 *  $ENSURE       banPeriodType == BP_Forever ||
 *                banPeriodType == BP_Matches ||
 *                banPeriodType == BP_UntilDate
 *
 **************************************************************************************************/
static function getBanPeriodType(string banPeriodStr, out byte banPeriodType, out string args) {
	if (banPeriodStr == "") {
		banPeriodType = BP_Forever;
	} else if (left(banPeriodStr, 1) ~= "M") {
		banPeriodType = BP_Matches;
		args = mid(banPeriodStr, 1);
	} else if (left(banPeriodStr, 1) ~= "U") {
		banPeriodType = BP_UntilDate;
		args = mid(banPeriodStr, 1);
	} else {
		banPeriodType = BP_Forever;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the position of the specified mutator in the mutator list.
 *  $PARAM        mutatorClass  The class of the mutator that is to be located.
 *  $RETURN       The index of the specified mutator in the mutator list, or -1 if the mutator isn't
 *                found.
 *
 **************************************************************************************************/
simulated function int getMutatorIndex(string mutatorClass) {
	local int index;
	local bool bFound;
	local string currClass;
	local string remaining;
	
	// Attempt to locate mutator.
	while (!bFound && index < arrayCount(mutatorInfo) && mutatorInfo[index] != "") {
		remaining = mutatorInfo[index];
		class'NexgenUtil'.static.split(remaining, currClass, remaining);
		if (currClass ~= mutatorClass) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Return result.
	if (bFound) {
		return index;
	} else {
		return -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the position of the specified game in the game list.
 *  $PARAM        gameClass  The class of the game that is to be located.
 *  $RETURN       The index of the specified gane in the game list, or -1 if the game isn't found.
 *
 **************************************************************************************************/
simulated function int getGameIndex(string gameClass) {
	local int index;
	local bool bFound;
	local string currClass;
	local string remaining;
	
	// Attempt to locate mutator.
	while (!bFound && index < arrayCount(gameTypeInfo) && gameTypeInfo[index] != "") {
		remaining = gameTypeInfo[index];
		class'NexgenUtil'.static.split(remaining, currClass, remaining);
		if (currClass ~= gameClass) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Return result.
	if (bFound) {
		return index;
	} else {
		return -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the list of active mutators.
 *
 **************************************************************************************************/
function setActiveMutatorList() {
	local Mutator m;
	local int index;
	
	// Reset list.
	activeMutatorIndices = "";
	
	// Get name for each mutator instance.
	foreach allActors(class'Mutator', m) {
		index = getMutatorIndex(string(m.class));
		if (index >= 0) {
			if (activeMutatorIndices == "") {
				activeMutatorIndices = string(index);
			} else {
				activeMutatorIndices = activeMutatorIndices $ separator $ string(index);
			}
		}
	}
	
	// Update checksum.
	updateStaticChecksum();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the current encryption parameters.
 *
 **************************************************************************************************/
simulated function setEncryptionParams(int index, int k, string cs) {
	default.encryptionKey[index] = k;
	default.codeScheme[index] = cs;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the current encryption parameters.
 *
 **************************************************************************************************/
function int getEncryptionParams(int index, out int k, out string cs) {
	k = default.encryptionKey[index];
	cs = default.codeScheme[index];
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Encodes the given string.
 *  $PARAM        str  The string that is to be encoded.
 *  $RETURN       The encoded string.
 *  $ENSURE       decode(result) == str
 *
 **************************************************************************************************/
simulated function string encode(int i, string str) {
	local string output;
	local int index;
	local byte ck[4];
	local byte cb;
	local byte nb;
	
	if (len(default.codeScheme[i]) != 32 || str == "") return "";
	
	ck[0] = default.encryptionKey[i] & 0xFF;
	ck[1] = (default.encryptionKey[i] >>> 8) & 0xFF;
	ck[2] = (default.encryptionKey[i] >>> 16) & 0xFF;
	ck[3] = (default.encryptionKey[i] >>> 24) & 0xFF;
	
	for (index = 0; index <= len(str); index++) {
		if (index == len(str)) {
			cb = nb;
			nb = 0;
		} else if (index == len(str) - 1) {
			cb = asc(mid(str, index, 1));
			nb = rand(256);
		} else {
			cb = asc(mid(str, index, 1));
			nb = asc(mid(str, index + 1, 1));
		}
		cb = cb ^ ck[index % 4] ^ nb;
		output = output $ mid(default.codeScheme[i], (cb >>> 4) & 0x0F, 1) $ mid(default.codeScheme[i], cb & 0x0F, 1);
	}
	
	return output;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Decodes the given string.
 *  $PARAM        str  The string that is to be decoded.
 *  $RETURN       The decoded string.
 *
 **************************************************************************************************/
simulated function string decode(int i, string str) {
	local string output;
	local int index;
	local int ci;
	local byte ck[4];
	local byte cb;
	local byte lb;

	if (len(default.codeScheme[i]) != 32 || str == "" || len(str) % 2 == 1) return "";

	ck[0] = default.encryptionKey[i] & 0xFF;
	ck[1] = (default.encryptionKey[i] >>> 8) & 0xFF;
	ck[2] = (default.encryptionKey[i] >>> 16) & 0xFF;
	ck[3] = (default.encryptionKey[i] >>> 24) & 0xFF;

	for (index = len(str) / 2 - 1;  index >= 0; index--) {
		ci = instr(default.codeScheme[i], mid(str, index * 2 + 1, 1));
		if (ci < 0) return ""; else cb = ci;
		ci = instr(default.codeScheme[i], mid(str, index * 2, 1));
		if (ci < 0) return ""; else cb = cb | (ci << 4);
		if (index == len(str) / 2 - 1) {
			lb = cb ^ ck[index % 4];
		} else {
			cb = cb ^ lb ^ ck[index % 4];
			output = chr(cb) $ output;
			lb = cb;
		}
	}
	
	return output;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Wrapper function for retrieving an element from the paAccountType array.
 *                This function is required because the array can't be accessed outside this class
 *                once its size exceeds 63 entries. Increasing the size beyond 63 will make the
 *                compiler go mad.
 *  $PARAM        index  The index of the element that is to be retrieved.
 *  $RETURN       The value of the element stored at the specified index.
 *
 **************************************************************************************************/
simulated function int get_paAccountType(int index) {
	return paAccountType[index];
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Wrapper function for storing an element to the paAccountType array.
 *                This function is required because the array can't be accessed outside this class
 *                once its size exceeds 63 entries. Increasing the size beyond 63 will make the
 *                compiler go mad.
 *  $PARAM        index  The index of the element that is to be stored.
 *  $PARAM        value  The value that is to be stored.
 *
 **************************************************************************************************/
simulated function set_paAccountType(int index, int value) {
	paAccountType[index] = value;
}

