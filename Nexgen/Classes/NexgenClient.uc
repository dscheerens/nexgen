/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenClient
 *  $VERSION      1.64 (20-12-2010 15:33:03)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Client information class. An instance of this class keeps track of the information
 *                of a specific player. It will also provide a the necessary means to allow
 *                communication between the client and server, via replication.
 *
 **************************************************************************************************/
class NexgenClient extends Info;

#exec AUDIO IMPORT NAME=timer_tick FILE=Resources\TimerTick.wav

// General info.
var NexgenClient nextClient;                      // Next client (linked list).
var NexgenController control;                     // The Nexgen server controller instance.
var NexgenConfig sConf;                           // Server configuration.
var NexgenGameInfo gInf;                          // Extended game info.
var GeneralConfig gc;                             // General client configuration.
var ServerConfig sc;                              // Server specific client configuration.
var PlayerPawn player;                            // The PlayerPawn object for this client.
var NexgenLang lng;                               // Language instance to support localization.
var NexgenPlayerData pDat;                        // Player data actor for this client.
var NexgenPlayerInfo playerList;                  // List of players.
var class<NexgenClientLoginHandler> loginHandler; // Client login handler.
var int loginHandlerChecksum;                     // Login handler class checksum.

// Login support.
var string serverID;                              // ID of the server.
var bool bNetLogin;                               // Client is ready to login (waiting for server).
var bool bNetWait;                                // Client is waiting for initial replication.
var bool loginComplete;                           // Login procedure has been completed?
var string ipAddress;                             // IP address of the client.
var string playerID;                              // Player identification code.
var int playerNum;                                // Client number.
var bool bHasAccount;                             // Indicates if this client has an account on the
                                                  // server.
var string loginOptions;                          // Extra login parameters.
const loginTimerFreq = 5.0;                       // Rate of the main timer when loggin in.
const waitTimeOut = 20.0;                         // Login timeout (in seconds).

// Player info.
var string playerName;                            // Name of the player in the current game.
var int team;                                     // Current team.
var string rights;                                // Rights owned by the client.
var string title;                                 // Title of the client.
var string country;                               // Country based on IP address.
var bool bSpectator;                              // The client is a spectator.
var bool bFirePressed;                            // Player has the fire button pressed.

// Dynamic control info.
var bool bInitialized;                            // Whether the client has been fully initialized.
var float badConnectionSince;                     // Bad connection has been detected at this time.
var bool bBadConnectionDetected;                  // Whether the bad connection alert has been detected.
var vector oldLocation;                           // Last known 'camp/idle' location.
var bool bMuted;                                  // Indicates if this client has been muted.
var bool bNoTeamSwitch;                           // Whether team switching for this player is disabled.
var float teamSwitchOverrideTime;                 // Time at which the team switch override flag was set.
var float nameChangeOverrideTime;                 // Time at which the name change override flag was set.
var float lastRespawnTime;                        // Last time at which the player has respawned. 
var float lastSwitchTime;                         // Last time the player has switched to another team.
var float spawnProtectionTimeX;                   // Spawn protection time remaining (server only).
var byte spawnProtectionTime;                     // Spawn protection time remaining (replicated).
var float tkDmgProtectionTimeX;                   // Team kill damage protection time remaining (server only).
var byte tkDmgProtectionTime;                     // Team kill damage protection time remaining (replicated).
var float tkPushProtectionTimeX;                  // Team kill push protection time remaining (server only).
var byte tkPushProtectionTime;                    // Team kill push protection time remaining (replicated).
var bool bScreenShotTaken;                        // Whether a screenshot has been taken.
var bool bReconnecting;                           // Client is reconnecting to the server.
var float gameEndTime;                            // Time at which the game has ended (local).
var bool bEncryptionParamsSet;                    // Set to true when the client has received the
                                                  // encryption parameters.
var float idleTime;                               // Number of seconds the player has been idle.
var float idleTimeCP;                             // Same but when the control panel is open.
var int idleTimeRemaining;                        // Time remaining before the player will be kicked.
var bool bUseNexgenMessageHUD;                    // Whether the extended Nexgen message HUD is used.
var float scoreBeforeTeamSwitch;                  // The player's score just before the team switch.
var bool bIsReadyToPlay;                          // Ready signal for this client.
var float lastAliveCheck;                         // Last time the client pinged the server to check
                                                  // whether it is still alive.

// Game speed independent timer support.
var float timeSeconds;                            // Time elpased since the creation of this client.

// Controller extensions.
var NexgenClientController clientCtrl[16];        // Client controller extensions.
var int clientCtrlCount;                          // Number of client controller extensions.

// GUI data.
var NexgenHUD nscHUD;                             // Nexgen HUD extension mutator.
var WindowConsole consoleWindow;                  // Shortcut to the console of the player.
var NexgenPopupFrame popupWindow;                 // The popup window.
var NexgenMainFrame mainWindow;                   // The main window.

// Config change events.
var int nextDynamicUpdateCount[9];                // Last received config update count per config type.
var int nextDynamicChecksum[9];                   // Checksum to wait for.
var byte bWaitingForNewConfig[9];                 // Whether the client is waiting for the configuration.

// Game info change events
var int gameInfoUpdate[2];                        // Game info update check per type.

// Client side settings.
const SSTR_ClientKey = "ClientKey";               // Private client key setting.
const SSTR_ClientID = "ClientID";                 // Public client ID setting.
const SSTR_ServerPassword = "Password";           // Server join password setting.
const SSTR_OverrideClass = "OverrideClass";       // Override class setting string.
const SSTR_UseNexgenHUD = "UseNexgenHUD";         // Whether or not to use the Nexgen HUD.
const SSTR_FlashMessages = "FlashMessages";       // Flash new messages on the Nexgen HUD.
const SSTR_ShowPlayerLocation = "ShowPlayerLoc";  // Show player location on teamsay messages.
const SSTR_PlayPMSound = "PlayPMSound";           // Play a sound when a PM is received.
const SSTR_AutoSSNormalGame = "AutoSSNormalGame"; // Automatically take scrshot at end of normal games.
const SSTR_AutoSSMatch = "AutoSSMatch";           // Automatically take scrshot at end of matches.
const SSTR_RunCount = "RunCount";                 // Number of times Nexgen has been used.

// Client rights.
const R_MayPlay = "A";                            // Allowed to play on the server.
const R_VIPAccess = "B";                          // Has access to VIP slots.
const R_AdminAccess = "C";                        // Has access to admin slots.
const R_NeedsNoPW = "D";                          // Doesn't need a password to enter the server.
const R_CanBeIdle = "E";                          // Whether the client can be idle on the server.
const R_MatchAdmin = "F";                         // Controls the current game.
const R_Moderate = "G";                           // Player can moderate the game.
const R_BanOperator = "H";                        // Player can ban and unban players.
const R_AccountManager = "I";                     // Is allowed to change the player accounts.
const R_ServerAdmin = "J";                        // Can edit the global server settings.
const R_MatchSet = "K";                           // Can setup clan matches.
const R_BanAccounts = "L";                        // Can kick or ban players with an account.
const R_HiddenAdmin = "M";                        // Whether the admin and his/her actions are
                                                  // invisible.

// Reconnect options.
const RCN_ReconnectOnly = 0;                      // Just reconnect, nothing more.
const RCN_ReconnectAsPlayer = 1;                  // Set OverrideClass to "" and reconnect.
const RCN_ReconnectAsSpec = 2;                    // Set OverrideClass to 'spec' and reconnect.

// General constants.
const reconnectCommand = "Reconnect";             // Console command for reconnecting.
const disconnectCommand = "Disconnect";           // Console command for disconnecting.
const exitCommand = "Exit";                       // Console command for quitting UT.
const startCommand = "Mutate NSC START";          // Console command for starting the game.
const changeNetSpeedCommand = "Netspeed";         // Console command for changing a players netspeed.
const spectatorClass = "Botpack.CHSpectator";     // Override class to use for spectators.
const separator = ",";                            // Character used to seperate elements in a list.

// Player events.
const PE_PlayerJoined = "pj";                     // A new player has joined the server.
const PE_PlayerLeft = "pl";                       // Somebody left the server.
const PE_AttributeChanged = "ac";                 // An attribute of the player has changed.

// Player attributes.
const PA_ClientID = "id";                         // The client identification code.
const PA_IPAddress = "ip";                        // IP address of the client.
const PA_Name = "name";                           // Nickname of the player
const PA_Title = "title";                         // The players title/role on the server.
const PA_Team = "team";                           // Team to which the player belongs.
const PA_Country = "country";                     // Country where the player is from.

// Settings.
const maxIdleRadius = 192;                        // Radius around oldLocation that counts as idle.
const idleCountDelay = 4;                         // Delay before player is marked as idle.
const idleTimeWarning = 15;                       // Idle time remaining when alerting the player.
const maxOverrideTime = 0.50;                     // Max elapsed time since override flag was set (in sec).
const cancelSpawnProtectDelay = 1.25;             // Delay in seconds before checking the spawn
                                                  // protection cancelling conditions.
const normalModeTimerFreq = 4.0;                  // Frequency of timer when the client is fully
                                                  // initialized (in Hz).
const autoScreenShotDelay = 2.0;                  // Seconds to wait before automatically taking a
                                                  // a screenshot at the end of the game.
const autoSSMinGameTime = 30.0;                   // Number of seconds the player has to be at least
                                                  // in the game if a screenshot is to be taken.
                                                  // This prevents players entering an ended game to
                                                  // take a screenshot.
const welcomeMsgCount = 10;                       // How many times should the welcome message be displayed?
const maxClientCtrlInitWaitTime = 10;             // How long should the client wait for client
                                                  // controllers to become ready before
                                                  // initializing.
const minDesiredNetSpeed = 5000;                  // Minimum net speed setting to use if a login
                                                  // timeout occurs.
const serverHealthCheckInterval = 0.2;            // Intervals between server health check when a bad
                                                  // connection alert has been detected.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

	reliable if (role == ROLE_Authority) // Replicate to client...
		// Variables.
		clientCtrl, clientCtrlCount, serverID, loginHandler, loginHandlerChecksum, sConf, gInf,
		loginComplete, ipAddress, playerName, rights, title, bSpectator, playerNum, bHasAccount,
		country, bMuted, spawnProtectionTime, tkDmgProtectionTime, tkPushProtectionTime,
		
		// Functions.
		showPopup, showPanel, showMsg, reconnect, clientCommand, configChanged, gameInfoChanged,
		playerEvent, updateLoginOption, setEncryptionParams, notifyEvent, notifyLoginFailed,
		notifyServerHealth;
		
	reliable if (role < ROLE_Authority) // Replicate to server...
		// Variables.
		
		// Functions.
		login, clientInitialized, doHealthCheck;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client handler. If called it will initiate the login procedure.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function preBeginPlay() {
	
	// Execute server side actions.
	if (role == ROLE_Authority) {
		// Set player.
		player = PlayerPawn(owner);
		
		// Start timer (set for the login procedure).
		setTimer(1.0 / loginTimerFreq, true);
	}
	
	// Execute client side actions.
	if (role == ROLE_SimulatedProxy) {
		
		// The following code was move from postNetBeginPlay() to this function, because these
		// variables have to be set from the moment the actor is spawned. The function
		// postNetBeginPlay() may be called a few ticks later. This caused the NexgenX plugin to
		// think that the client was already initialized and produced accessed none warnings.
		
		// Start waiting for replication.
		bNetLogin = true;
		bNetWait = true;
		idleTimeRemaining = -1;
		
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
		
		// Load client configuration.
		gc = spawn(class'GeneralConfig');
		sc = spawn(class'ServerConfig');
		lng = spawn(class'NexgenLang');
		
		// Start timer (set for the login procedure).
		setTimer(1.0 / loginTimerFreq, true);
		
		// Setup GUI.
		nscHUD = spawn(class'NexgenHUD', self);
		if (gc.get(SSTR_UseNexgenHUD, "true") ~= "true") {
			setNexgenMessageHUD(true);
		}
		
	} else {
		// See remarks in NexgenClientController.postNetBeginPlay().
		destroy();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Main loop for the client handler. Handles the following:
 *                - Login triggering (waiting for replication).
 *                - Server config update checks.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function timer() {
	local int index;
	local bool bClientControllersReady;
	
	// Client side code.
	if (role == ROLE_SimulatedProxy) {
		
		// Received login info?
		if (bNetLogin && serverID != "" && owner != none && sConf != none &&
		    PlayerPawn(owner).playerReplicationInfo != none && loginHandler != none &&
		    loginHandlerChecksum == class'NexgenUtil'.static.stringHash(string(loginHandler))) {
			bNetLogin = false;
			clientLogin();
		}
		
		// Client has received initial replication info?
		if (!bNetLogin && bNetWait && initialConfigReplicationComplete() && gInf != none &&
		    gInf.updateCount > 0 && player != none && rights != "" && bEncryptionParamsSet &&
		    clientCtrlCount > 0) {
		    
		    // Check if all client controllers have been replicated.
		    bClientControllersReady = true;
		    index = 0;
		    while (bClientControllersReady && index < clientCtrlCount) {
		    	if (clientCtrl[index] == none) {
		    		bClientControllersReady = false;
		    	} else {
		    		index++;
		    	}
		    }
		    
		    // Check if client controllers are ready to initialize.
		    if (bClientControllersReady && timeSeconds < maxClientCtrlInitWaitTime) {
			    index = 0;
			    while (bClientControllersReady && index < clientCtrlCount) {
			    	bClientControllersReady = clientCtrl[index].isReadyToInitialize();
			    	index++;
			    }
			}
		    
		    // Initialize client and client controllers if all are ready.
		    if (bClientControllersReady) {
				bNetWait = false;
				setTimer(0.0, false);
				clientInitialize();
			}
		}

		// Server config update check.
		if (loginComplete) {
			checkConfigUpdate();
		}
		
		// Check if game has ended.
		if (!bNetWait && gameEndTime <= 0 && gInf.gameState == gInf.GS_Ended) {
			gameEndTime = timeSeconds;
		}
		
		// Automatically take a screenshot.
		if (gameEndTime > 0 && timeSeconds - gameEndTime >= autoScreenShotDelay &&
		    !bScreenShotTaken && player.bShowScores) {
			if (timeSeconds > autoSSMinGameTime &&
			    (gc.get(SSTR_AutoSSNormalGame, "false") ~= "true" ||
			     gc.get(SSTR_AutoSSMatch, "true") ~= "true" && sConf.matchModeActivated)) {
				player.sShot();
			}
			bScreenShotTaken = true;
		}
	}
	
	// Server side code.
	if (role == ROLE_Authority) {
		// Check if player has left the server before able to login.
		if (!loginComplete && owner == none) {
			setTimer(0.0, false);
			destroy();
		}
		
		// Check for timeout.
		if (!loginComplete && timeSeconds >= waitTimeOut && owner != none) {
			setTimer(0.0, false);
			notifyLoginFailed();
			control.nscLog("Login timeout for" @ player.playerReplicationInfo.playerName);
			control.disconnectClient(self);
		}
		
		// Disable voice packs for muted players.
		if (loginComplete && isMuted()) {
			player.oldMessageTime = level.timeSeconds;
		}
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Time critical event detection loop. Detects the following events:
 *                - If the fire button is pressed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function tick(float deltaTime) {
	local int lastIdleTimeRemaining;
	
	// Gamespeed independent timer support.
	if (level.pauser == "") {
		timeSeconds += deltaTime / level.timeDilation;
	}
	
	// Client side actions.
	if (role == ROLE_SimulatedProxy && player != none && !bNetWait) {
		
		// Check fire button state.
		if (player.bFire != 0 && !bFirePressed) {
			// Fire button press.
			bFirePressed = true;
			firePressed();
		} else if (player.bFire == 0 && bFirePressed) {
			// Fire button release.
			bFirePressed = false;
		}
		
		// Check for bad connection.
		if (player.bBadConnectionAlert && !bBadConnectionDetected) {
			badConnectionSince = timeSeconds;
			bBadConnectionDetected = true;
			checkServerHealth();
		} else if (bBadConnectionDetected && timeSeconds - lastAliveCheck > serverHealthCheckInterval) {
			checkServerHealth();
		} else if (bBadConnectionDetected && sConf.autoReconnectTime > 0 && !bReconnecting &&
		           timeSeconds - badConnectionSince > sConf.autoReconnectTime) {
			bReconnecting = true;
			reconnect();
		}
		
		// Idle detection.
		if (gInf.gameState == gInf.GS_Playing) {
			if (vSize((oldLocation - player.location) * vect(1, 1, 0)) > maxIdleRadius) {
				oldLocation = player.location;
				idleTime = -idleCountDelay;
				idleTimeCP = -idleCountDelay;
				idleTimeRemaining = -1;
			} else if (!bSpectator && !hasRight(R_CanBeIdle) && level.pauser == "") {
				lastIdleTimeRemaining = idleTimeRemaining;
				
				// Control panel opened?
				if (mainWindow.bWindowVisible) {
					// Yes, increase open control panel idle time.
					idleTimeCP += deltaTime / level.timeDilation;
					if (idleTimeCP < 0 || sConf.maxIdleTimeCP == 0) {
						idleTimeRemaining = -1;
					} else {
						idleTimeRemaining = max(0, 1 + sConf.maxIdleTimeCP - idleTimeCP);
					}
					
				} else {
					// No, increase normal idle time.
					idleTime += deltaTime / level.timeDilation;
					if (idleTime < 0 || sConf.maxIdleTime == 0) {
						idleTimeRemaining = -1;
					} else {
						idleTimeRemaining = max(0, 1 + sConf.maxIdleTime - idleTime);
					}
				}
				
				// Play warning sound?
				if (idleTimeRemaining >= 0 && idleTimeRemaining <= idleTimeWarning &&
				    idleTimeRemaining != lastIdleTimeRemaining) {
					player.clientPlaySound(sound'timer_tick', , true);
				}
				
				// Maximum idle time reached?
				if (idleTimeRemaining == 0) {
					showPopup("NexgenIdleKickedDialog");
					clientCommand(disconnectCommand);
				}
			}
		} else if (idleTimeRemaining >= 0) {
			idleTime = -idleCountDelay;
			idleTimeCP = -idleCountDelay;
			idleTimeRemaining = -1;
		}
		
	}
	
	// Server side actions.
	if (role == ROLE_Authority) {
		
		// Spawn protection.
		if (spawnProtectionTimeX > 0) {
			// Disable spawn protection?
			if ((control.timeSeconds - lastRespawnTime >= cancelSpawnProtectDelay) &&
			    (player.playerReplicationInfo.hasFlag != none || !ignoreWeaponFire()) ||
			    (player.health <= 0) || (gInf.gameState == gInf.GS_Ended)) {
				// Yes.
				spawnProtectionTimeX = 0;
				spawnProtectionTime = 0;
				
			} else {
				// No, update timer.
				spawnProtectionTimeX -= deltaTime / level.timeDilation;
				if (spawnProtectionTimeX <= 0) {
					spawnProtectionTime = 0;
				} else {
					spawnProtectionTime = byte(spawnProtectionTimeX) + 1;
				}
			}
		}
		
		// Team kill damage protection.
		if (tkDmgProtectionTimeX > 0) {
			tkDmgProtectionTimeX -= deltaTime / level.timeDilation;
			if (tkDmgProtectionTimeX <= 0) {
				tkDmgProtectionTime = 0;
			} else {
				tkDmgProtectionTime = byte(tkDmgProtectionTimeX) + 1;
			}
		}
		
		// Team kill push protection.
		if (tkPushProtectionTimeX > 0) {
			tkPushProtectionTimeX -= deltaTime / level.timeDilation;
			if (tkPushProtectionTimeX <= 0) {
				tkPushProtectionTime = 0;
			} else {
				tkPushProtectionTime = byte(tkPushProtectionTimeX) + 1;
			}
		}
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether primary or alt fire for the current weapon carried by the player
 *                should be ignored when checking if it should cancel spawn protection.
 *  $RETURN       True if the weapon should be ignored, false if not.
 *
 **************************************************************************************************/
function bool ignoreWeaponFire() {
	local bool bIgnore;
	local bool bFound;
	local bool bIgnoreFire;
	local bool bIgnoreAltFire;
	local int index;
	local string weaponClass;
	local string currWeaponClass;
	local string excludedModes;
	
	// Trivial case.
	if (player.weapon == none || player.bFire == 0 && player.bAltFire == 0) {
		return true;
	}
	
	// Non trivial case, locate weapon class in configuration file.
	weaponClass = string(player.weapon.class);
	while(!bFound && index < arrayCount(sConf.spawnProtectExcludeWeapons) &&
	      sConf.spawnProtectExcludeWeapons[index] != "") {
		// Get currently selected weapon in exclude list.
		class'NexgenUtil'.static.split(sConf.spawnProtectExcludeWeapons[index], currWeaponClass, excludedModes);
		
		// Class match?
		if (weaponClass ~= currWeaponClass) {
			// Yes.
			bFound = true;
			excludedModes = caps(class'NexgenUtil'.static.trim(excludedModes));
			bIgnore = (instr(excludedModes, sConf.IW_Fire) >= 0 && player.bFire > 0) ||
			          (instr(excludedModes, sConf.IW_AltFire) >= 0 && player.bAltFire > 0);
		} else {
			// No, continue searching...
			index++;
		}
	}
	
	// Return result.
	return bIgnore;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the fire button is pressed.
 *
 **************************************************************************************************/
simulated function firePressed() {
	// Check if the game should be started.
	if (gInf != none && gInf.gameState == gInf.GS_Ready) {
		clientCommand(startCommand);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initiates the client side login procedure. Retrieves the necessary client info
 *                and sends it to the server for a login request.
 *  $REQUIRE      owner != none && serverID != ""
 *  $ENSURE       player != none && playerID != none
 *
 **************************************************************************************************/
simulated function clientLogin() {
	
	// Set player.
	player = PlayerPawn(owner);
	
	// Retrieve login information.
	loginHandler.static.getLoginParameters(self, playerID, loginOptions);
	
	// Initialize the popup window, client might receive a message if login fails.
	initializePopupWindow();
	
	// Try to login to the server.
	login(playerID, loginOptions);
	
	// Check if a Nexgen configuration is resident on the client.
	checkResidentConfig();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Requests the login of this client.
 *  $ENSURE       playerName != "" && ipAddress != "" && playerID != ""
 *
 **************************************************************************************************/
function login(string clientID, string args) {
	
	// Stop timer (it is no longer used server side).
	//setTimer(0.0, false);
	// Set timer in normal mode (it is being used since v1.09).
	setTimer(1.0 / normalModeTimerFreq, true);
	
	// Store client information.
	playerName = player.playerReplicationInfo.playerName;
	ipAddress = player.getPlayerNetworkAddress();
	ipAddress = left(ipAddress, instr(ipAddress, ":"));
	bSpectator = player.isA('Spectator');
	playerID = clientID;
	loginOptions = args;
		
	// Set account information.
	setAccountInfo();
	
	// Let the server controller check the login request.
	control.checkLogin(self);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the clientside of this object. This can only be done once the initial
 *                replication data has been received (detected in the timer function). Calling this
 *                function will setup things like the HUD and user interface objects.
 *  $REQUIRE      player != none && sConf != none && gInf != none
 *  $ENSURE       nscHUD != none
 *
 **************************************************************************************************/
simulated function clientInitialize() {
	local int index;
	local int runCount;
	
	// Setup GUI.
	initializeControlPanel();
	
	// Set timer frequency.
	setTimer(1.0 / normalModeTimerFreq, true);
	
	// Let the client controllers know we're initialized.
	for (index = 0; index < arrayCount(clientCtrl); index++) {
		if (clientCtrl[index] != none) {
			clientCtrl[index].clientInitialized();
		}
	}
	
	// Update run count.
	runCount = int(gc.get(SSTR_RunCount, "0")) + 1;
	gc.set(SSTR_RunCount, string(runCount));
	gc.saveConfig();
	
	// Show 'welcome to Nexgen' message?
	if (runCount <= welcomeMsgCount) {
		showMsg(lng.welcomeMsg);
	}
	
	// Initialisation complete, notify server.
	bInitialized = true;
	clientInitialized();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Enables or disables the Nexgen message HUD.
 *  $PARAM        bEnable  Whether the nexgen message HUD should be enabled.
 *  $REQUIRE      sConf.HUDReplacementClass != none
 *
 **************************************************************************************************/
simulated function setNexgenMessageHUD(bool bEnable) {

	bUseNexgenMessageHUD = bEnable;
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the client has finished its initialisation process. This function is
 *                called on the client in the clientInitialize() function and is replicated to the
 *                server.
 *
 **************************************************************************************************/
function clientInitialized() {
	bInitialized = true;
	control.clientInitialized(self);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Displays the specified message on the screen of this client.
 *  $PARAM        msg  The message to display.
 *  $PARAM        pri  Player replication info related to this message.
 *
 **************************************************************************************************/
simulated function showMsg(string msg, optional PlayerReplicationInfo pri) {
	local string cleanMsg;
	
	if (role == ROLE_SimulatedProxy) {
		// Strip color tag.
		cleanMsg = class'NexgenUtil'.static.removeMessageColorTag(msg);
		
		// Write message to console.
	    if (player.player.console != none) {
	        player.player.console.message(pri, cleanMsg, 'Event');
	    }
	    
	    // Write message to HUD.
	    if (player.myHUD != none) {
	    	if (bUseNexgenMessageHUD && (instr(string(player.myHUD.class), "NexgenHUDWrapper") >= 0)) {
	        	player.myHUD.message(pri, msg, 'Event');
	        } else {
	        	player.myHUD.message(pri, cleanMsg, 'Event');
	        }
	    }
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the account information of this client.
 *  $REQUIRE      playerID != none
 *  $ENSURE       rights != "" && title != none
 *
 **************************************************************************************************/
function setAccountInfo() {
	local int accountNum;
	
	// Player has an account?
	accountNum = sConf.getUserAccountIndex(playerID);
	if (accountNum < 0) {
		// No, use default account type.
		if (bSpectator) {
			title = control.lng.specTitle;
		} else {
			title = sConf.getAccountTypeTitle(0);
		}
		rights = sConf.atRights[0];
	} else {
		// Yes, load account info.
		bHasAccount = true;
		title = sConf.getUserAccountTitle(accountNum);
		if (sConf.get_paAccountType(accountNum) < 0) {
			rights = sConf.paCustomRights[accountNum];
		} else {
			rights = sConf.atRights[sConf.get_paAccountType(accountNum)];
		}
		
		// Change title for hidden admins.
		if (hasRight(R_HiddenAdmin)) {
			if (bSpectator) {
				title = control.lng.specTitle;
			} else {
				title = sConf.getAccountTypeTitle(0);
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether this client has the specified right.
 *  $PARAM        rightID  String identifier of the client right.
 *  $REQUIRE      rightID != ""
 *  $RETURN       True if the client has the specfied right, false if not.
 *
 **************************************************************************************************/
simulated function bool hasRight(string rightID) {
	return instr(separator $ rights $ separator, separator $ rightID $ separator) >= 0;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether this client has the specified rights.
 *  $PARAM        rightsStr  String containing the rights to check.
 *  $RETURN       True if the client has the specfied rights, false if not.
 *
 **************************************************************************************************/
simulated function bool hasRights(string rightsStr) {
	local string remaining;
	local string rightID;
	local bool bHasRights;
	
	remaining = rightsStr;
	
	// Check rights.
	bHasRights = true;
	while (bHasRights && remaining != "") {
		class'NexgenUtil'.static.split(remaining, rightID, remaining);
		bHasRights = hasRight(rightID);
	}
	
	// Return result.
	return bHasRights;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the console window so other windows can be created.
 *  $ENSURE       consoleWindow != none
 *
 **************************************************************************************************/
simulated function initializeConsoleWindow() {
	consoleWindow = WindowConsole(player.player.console);
	if (consoleWindow.bShowConsole) {
		consoleWindow.hideConsole();
	}
	if (consoleWindow.root == none) {
		consoleWindow.createRootWindow(none);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the popup window.
 *  $ENSURE       popupWindow != none
 *
 **************************************************************************************************/
simulated function initializePopupWindow() {
	local float wWidth;
	local float wHeight;
	local float wTop;
	local float wLeft;
	local UWindowWindow window;
	
	// Initialize only once.
	if (popupWindow != none) {
		return;
	}
	
	// Setup console window.
	if (consoleWindow == none) {
		initializeConsoleWindow();
	}

	// Create popup window.
	wWidth = class'NexgenPopupFrame'.default.windowWidth;
	wHeight = class'NexgenPopupFrame'.default.windowHeight;
	wLeft = fMax(0.0, (consoleWindow.root.winWidth - wWidth) / 2.0);
	wTop = fMax(0.0, (consoleWindow.root.winHeight - wHeight) / 2.0);
	window = consoleWindow.root.createWindow(class'NexgenPopupFrame', wLeft, wTop, wWidth, wHeight);
	popupWindow = NexgenPopupFrame(window);
	popupWindow.client = self;
	popupWindow.gc = gc;
	popupWindow.sc = sc;
	popupWindow.serverID = serverID; //sConf.serverID;
	popupWindow.close();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the remote control panel window.
 *  $ENSURE       mainWindow != none
 *
 **************************************************************************************************/
simulated function initializeControlPanel() {
	local float wWidth;
	local float wHeight;
	local float wTop;
	local float wLeft;
	local UWindowWindow window;
	local int index;
	
	// Setup console window.
	if (consoleWindow == none) {
		initializeConsoleWindow();
	}
	
	// Make sure the control panel of the last game is closed.
	if (consoleWindow.root != none) {
		window = consoleWindow.root.firstChildWindow;
		while (window != none) {
			// Window is a control panel?
			if (window.isA('NexgenMainFrame')) {
				// Yes, close it.
				window.close();
			}
			
			// Continue with next window.
			window = window.nextSiblingWindow;
		}
	}

	// Create main window.
	wWidth = class'NexgenMainFrame'.default.windowWidth;
	wHeight = class'NexgenMainFrame'.default.windowHeight;
	wLeft = fMax(0.0, (consoleWindow.root.winWidth - wWidth) / 2.0);
	wTop = fMax(0.0, (consoleWindow.root.winHeight - wHeight) / 2.0);
	window = consoleWindow.root.createWindow(class'NexgenMainFrame', wLeft, wTop, wWidth, wHeight);
	mainWindow = NexgenMainFrame(window);
	//mainWindow.close(); // Causes the typing promt to be reset.
	mainWindow.hideWindow();
	mainWindow.mainPanel.client = self;
	
	// Let the client controllers add stuff to the control panel.
	for (index = 0; index < arrayCount(clientCtrl); index++) {
		if (clientCtrl[index] != none) {
			clientCtrl[index].setupControlPanel();
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Shows a popup dialog at the client.
 *  $PARAM        popupClass  Class name of the popup dialog to show.
 *  $PARAM        str1        Dialog specific argument.
 *  $PARAM        str2        Dialog specific argument.
 *  $PARAM        str3        Dialog specific argument.
 *  $PARAM        str4        Dialog specific argument.
 *  $REQUIRE      windowsInitialized
 *
 **************************************************************************************************/
simulated function showPopup(string popupClass, optional string str1, optional string str2, optional string str3, optional string str4) {
	popupWindow.showPopup(popupClass, str1, str2, str3, str4);
	popupWindow.focusWindow();
	popupWindow.bringToFront();
	popupWindow.showWindow();
	consoleWindow.bQuickKeyEnable = true;
	consoleWindow.launchUWindow();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Opens the Nexgen control panel (main window).
 *  $PARAM        panel The panel that is to be displayed.
 *
 **************************************************************************************************/
simulated function showPanel(optional string panel) {
	if (mainWindow != none) {
		mainWindow.focusWindow();
		mainWindow.bringToFront();
		mainWindow.showWindow();
		consoleWindow.bQuickKeyEnable = true;
		consoleWindow.launchUWindow();
		if (panel != "") {
			mainWindow.mainPanel.selectPanel(panel);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reconnects this client.
 *  $PARAM        option  Determines the reconnect option.
 *  $REQUIRE      option == RCN_ReconnectOnly ||
 *                option == RCN_ReconnectAsPlayer ||
 *                option == RCN_ReconnectAsSpec
 *
 **************************************************************************************************/
simulated function reconnect(optional byte option) {
	if (option == RCN_ReconnectAsPlayer) {
		player.updateURL(SSTR_OverrideClass, "", true);
	} else if (option == RCN_ReconnectAsSpec) {
		player.updateURL(SSTR_OverrideClass, spectatorClass, true);
	}
	
	player.consoleCommand(reconnectCommand);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Update a login option for the client.
 *  $PARAM        optionName    Name of the option that is to be updated.
 *  $PARAM        value         The new value of the option.
 *  $PARAM        bSaveDefault  Whether this value should be saved as default for this option.
 *  $REQUIRE      optionName != ""
 *
 **************************************************************************************************/
simulated function updateLoginOption(string optionName, coerce string value, optional bool bSaveDefault) {
	player.updateURL(optionName, value, bSaveDefault);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes the given command on the client.
 *  $PARAM        cmd  Console command to execute.
 *
 **************************************************************************************************/
simulated function clientCommand(string cmd) {
	player.consoleCommand(cmd);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a new client controller and hooks it onto this client.
 *  $PARAM        controllerClass  Type of controller to create.
 *  $PARAM        creator          The Actor that wants to add the controller.
 *  $REQUIRE      controllerClass != none
 *  $RETURN       The newly created controller or none if all client controller slots are used.
 *
 **************************************************************************************************/
function NexgenClientController addController(class<NexgenClientController> controllerClass,
                                              optional Actor creator) {
	local NexgenClientController controller;
	
	// Create controller.
	if (clientCtrlCount < arrayCount(clientCtrl)) {
		controller = spawn(controllerClass, player);
		controller.client = self;
		controller.control = control;
		controller.initialize(creator);
		clientCtrl[clientCtrlCount++] = controller;
	}
	
	// Return the new controller.
	return controller;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fetches the client controller with the specified id.
 *  $PARAM        controllerID  ID of the controller to return.
 *  $RETURN       The controller with the specified id, or none if the controller couln't be found.
 *  $ENSURE       result != none ? result.ctrlID == controllerID : true
 *
 **************************************************************************************************/
simulated function NexgenClientController getController(string controllerID) {
	local int index;
	local bool bFound;
		
	// Locate controller.
	while (!bFound && index < arrayCount(clientCtrl)) {
		if (clientCtrl[index] != none && clientCtrl[index].ctrlID ~= controllerID) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Return controller if found.
	if (bFound) {
		return clientCtrl[index];
	} else {
		return none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client that the server configuration has been updated. The new
 *                settings might not yet have been replicated, so the client has to wait for the
 *                replication to complete. Once the replication is completed an event will be
 *                triggered to signal the GUI and other client controllers that the new settings
 *                are available, see checkConfigUpdate().
 *  $PARAM        configType   Type of settings that have been changed.
 *  $PARAM        updateCount  Config update number for the new settings.
 *  $PARAM        checksum     Checksum of the new settings.
 *  $REQUIRE      0 <= configType && configType < arrayCount(nextDynamicChecksum) && updateCount >= 0
 *
 **************************************************************************************************/
simulated function configChanged(byte configType, int updateCount, int checksum) {
	if (updateCount > nextDynamicUpdateCount[configType]) {
		nextDynamicUpdateCount[configType] = updateCount;
		nextDynamicChecksum[configType] = checksum;
		bWaitingForNewConfig[configType] = byte(true);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client that the extended game information  has been updated. The new
 *                settings might not yet have been replicated, so the client has to wait for the
 *                replication to complete. In that case the function will be automatically called
 *                again once the replication has completed, see checkConfigUpdate().
 *  $PARAM        infoType   Type of information that has been changed.
 *  $PARAM        updateNum  Game info update number for the new settings.
 *  $REQUIRE      0 <= configType && configType < arrayCount(gameInfoUpdate) && updateNum >= 0
 *
 **************************************************************************************************/
simulated function gameInfoChanged(byte infoType, int updateNum) {
	local int index;
	
	// Check if replication of the new settings has completed.
	if (gInf.updateCount >= updateNum) {
		// It has, notify GUI.
		mainWindow.mainPanel.gameInfoChanged(infoType);
		
		// Notify client controllers.
		while(index < arrayCount(clientCtrl) && clientCtrl[index] != none) {
			clientCtrl[index++].gameInfoChanged(infoType);
		}
		
	} else {
		// No it hasn't, wait for replication to complete.
		gameInfoUpdate[infoType] = updateNum;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks for each config type if new settings have been received. If new settings
 *                have been received configChanged() is called.
 *
 **************************************************************************************************/
simulated function checkConfigUpdate() {
	local byte type;
	local int index;
	
	// Server configuration.
	for (type = 0; type < arrayCount(nextDynamicChecksum); type++) {
		if (bool(bWaitingForNewConfig[type]) &&
		    sConf.updateCounts[type] >= nextDynamicUpdateCount[type] &&
		    sConf.calcDynamicChecksum(type) == nextDynamicChecksum[type]) {
		    
			bWaitingForNewConfig[type] = byte(false);
			
			// Notify GUI.
			mainWindow.mainPanel.configChanged(type);
			
			// Notify client controllers.
			index = 0;
			while(index < arrayCount(clientCtrl) && clientCtrl[index] != none) {
				clientCtrl[index++].configChanged(type);
			}
		}
	}
	
	// Extended game info.
	for (type = 0; type < arrayCount(gameInfoUpdate); type++) {
		if (gameInfoUpdate[type] > 0 && gInf.updateCount >= gameInfoUpdate[type]) {
			gameInfoUpdate[type] = 0;
			gameInfoChanged(type, gInf.updateCount);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client of a player event. Additional arguments to the event should be
 *                combined into one string which then can be send along with the playerEvent call.
 *  $PARAM        playerNum  Player identification number.
 *  $PARAM        eventType  Type of event that has occurred.
 *  $PARAM        args       Optional arguments.
 *  $REQUIRE      playerNum >= 0
 *
 **************************************************************************************************/
simulated function playerEvent(int playerNum, string eventType, optional string args) {
	local NexgenPlayerInfo player;
	local int index;
	local string value;
	
	// Update player list.
	switch (eventType) {
		case PE_PlayerJoined:
			// Create player info object.
			player = createPlayerInfo(playerNum, args);
			
			// Store player.
			if (playerList == none) {
				playerList = player;
			} else {
				playerList.addPlayer(player);
			}
			break;
			
		case PE_PlayerLeft:
			if (playerList != none) {
				if (playerList.playerNum == playerNum) {
					playerList = playerList.nextPlayer;
				} else {
					playerList.removePlayer(playerNum);
				}
			}
			break;
			
		case PE_AttributeChanged:
			if (playerList != none) {
				player = playerList.getPlayer(playerNum);
			}
			if (player != none) {
				// Name attribute.
				value = class'NexgenUtil'.static.getProperty(args, PA_Name);
				if (value != "") {
					player.playerName = value;
				}
				
				// Title attribute.
				value = class'NexgenUtil'.static.getProperty(args, PA_Title);
				if (value != "") {
					player.playerTitle = value;
				}
				
				// Country attribute.
				value = class'NexgenUtil'.static.getProperty(args, PA_Country);
				if (value != "") {
					player.countryCode = value;
				}
				
				// Team attribute.
				value = class'NexgenUtil'.static.getProperty(args, PA_Team);
				if (value != "") {
					player.teamNum = byte(value);
				}
			}
			break;
	}

	// Notify GUI.
	if (mainWindow != none) {
		mainWindow.mainPanel.playerEvent(playerNum, eventType, args);
	}
	
	// Notify client controllers.
	while(index < arrayCount(clientCtrl) && clientCtrl[index] != none) {
		clientCtrl[index++].playerEvent(playerNum, eventType, args);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a new player info object for a player with the specified number.
 *  $PARAM        playerNum   Number of the player for which the info object is to be created.
 *  $PARAM        attributes  A string containing the players attribute list.
 *
 **************************************************************************************************/
simulated function NexgenPlayerInfo createPlayerInfo(int playerNum, string attributes) {
	local NexgenPlayerInfo player;
	
	// Create instance.
	player = spawn(class'NexgenPlayerInfo');
	player.playerNum = playerNum;
	
	// Store attributes.
	player.playerName = class'NexgenUtil'.static.getProperty(attributes, PA_Name);
	player.playerTitle = class'NexgenUtil'.static.getProperty(attributes, PA_Title);
	player.ipAddress = class'NexgenUtil'.static.getProperty(attributes, PA_IPAddress);
	player.clientID = class'NexgenUtil'.static.getProperty(attributes, PA_ClientID);
	player.countryCode = class'NexgenUtil'.static.getProperty(attributes, PA_Country);
	player.teamNum = byte(class'NexgenUtil'.static.getProperty(attributes, PA_Team));
	
	// Return player info object.
	return player;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the client has respawned.
 *
 **************************************************************************************************/
function respawned() {
	
	// Actions that require the login to be completed.
	if (loginComplete) {
		if (!bSpectator) {
			spawnProtectionTimeX = sConf.spawnProtectionTime;
		}
	}
	
	lastRespawnTime = control.timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether this client is muted.
 *  $RETURN       True if the player has been muted, false if not.
 *
 **************************************************************************************************/
simulated function bool isMuted() {
	return (bMuted || gInf.bMuteAll) && !hasRight(R_Moderate);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether this client should received the specified encryption parameters.
 *  $PARAM        type  The encryption parameters type.
 *  $REQUIRE      sConf != none
 *
 **************************************************************************************************/
function bool shouldGetEncryptionParams(int type) {
	switch (type) {
		case sConf.CS_GlobalServerSettings: return hasRight(R_ServerAdmin);
		case sConf.CS_AccountTypes:         return hasRight(R_ServerAdmin);
		case sConf.CS_MatchSettings:        return hasRight(R_MatchSet);
		default:                            return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the current encryption parameters.
 *  $REQUIRE      sConf != none
 *  $ENSURE       bEncryptionParamsSet
 *
 **************************************************************************************************/
simulated function setEncryptionParams(int k0, string cs0, int k1, string cs1, int k2, string cs2) {
	sConf.setEncryptionParams(0, k0, cs0);
	sConf.setEncryptionParams(1, k1, cs1);
	sConf.setEncryptionParams(2, k2, cs2);
	bEncryptionParamsSet = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the team for this player.
 *  $PARAM        newTeam  The index of the target team.
 *
 **************************************************************************************************/
function setTeam(byte newTeam) {
	local bool bPlayersBalanceTeams;
	
	// We should use the changeTeam function or else we might break compatibility with other game
	// types. However if bPlayersBalanceTeams is set to true it might prevent the player from being
	// switched to the desired team. Therefore it is temporarily disabled when we make the switch.
	
	// Set bPlayersBalanceTeams to false.
	if (level.game.isA('TeamGamePlus')) {
		bPlayersBalanceTeams = TeamGamePlus(level.game).bPlayersBalanceTeams;
		TeamGamePlus(level.game).bPlayersBalanceTeams = false;
	}
	
	// Set override flag.
	teamSwitchOverrideTime = control.timeSeconds;
	
	// Backup the players score.
	scoreBeforeTeamSwitch = player.playerReplicationInfo.score;
	
	// Switch to target team.
	player.changeTeam(newTeam);

	// Restore bPlayersBalanceTeams value.
	if (level.game.isA('TeamGamePlus')) {
		TeamGamePlus(level.game).bPlayersBalanceTeams = bPlayersBalanceTeams;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether there is a Nexgen configuration resident on the client. If this is
 *                the case the client might not be able to initialize correctly because of checksum
 *                mismatches. Therefore the client will be notified if problems may occur.
 *
 **************************************************************************************************/
simulated function checkResidentConfig() {
	if (player.consoleCommand("get " $ class'NexgenUtil'.default.packageName $ ".NexgenConfigExt bInstalled") ~= string(true) ||
	    player.consoleCommand("get " $ class'NexgenUtil'.default.packageName $ ".NexgenConfigSys bInstalled") ~= string(true)) {
		showPopup("NexgenResidentConfigDialog");
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the player name of this client. Automatically sets the name change
 *                override flag, so Nexgen won't reset it if name changing isn't allowed by the
 *                administrators.
 *  $PARAM        newName  The new name of the player.
 *  $REQUIRE      newName != ""
 *
 **************************************************************************************************/
function changeName(string newName) {
	nameChangeOverrideTime = control.timeSeconds;
	//playerName = newName; // This prevents the nameChanged() event from being fired.
	level.game.changeName(player, newName, false);
	updateLoginOption("Name", newName, true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new plugin configuration panel to the control panel.
 *  $PARAM        panelClass  The panel class of the plugin configuration panel.
 *  $REQUIRE      panelClass != none
 *
 **************************************************************************************************/
simulated function addPluginConfigPanel(class<NexgenPanel> panelClass) {
	local NexgenPanelContainer container;
	
	container = NexgenPanelContainer(mainWindow.mainPanel.getPanel("pluginsettings"));
	if (container == none) {
		container = NexgenPanelContainer(mainWindow.mainPanel.addPanel(lng.pluginsTabTxt, class'NexgenScrollPanelContainer', "pluginsettings", "server,serversettings"));
	}
	
	container.addPanel("", panelClass);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new client plugin configuration panel to the control panel.
 *  $PARAM        panelClass  The panel class of the plugin client configuration panel.
 *  $REQUIRE      panelClass != none
 *
 **************************************************************************************************/
simulated function addPluginClientConfigPanel(class<NexgenPanel> panelClass) {
	local NexgenPanelContainer container;
	
	container = NexgenPanelContainer(mainWindow.mainPanel.getPanel("pluginclientsettings"));
	if (container == none) {
		container = NexgenPanelContainer(mainWindow.mainPanel.addPanel(lng.settingsTabTxt, class'NexgenScrollPanelContainer', "pluginclientsettings", "client"));
	}
	
	container.addPanel("", panelClass);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client of an event. The event is passed to the Nexgen control panel
 *                and the client controllers attached to this client.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *
 **************************************************************************************************/
simulated function notifyEvent(string type, optional string arguments) {
	local int index;
	
	// Notify GUI.
	if (mainWindow != none) {
		mainWindow.mainPanel.notifyEvent(type, arguments);
	}
	
	// Notify client controllers.
	while(index < arrayCount(clientCtrl) && clientCtrl[index] != none) {
		clientCtrl[index++].notifyEvent(type, arguments);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when an instance of this class is destroyed. Automatically cleans up any
 *                remaining objects.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function destroyed() {
	local int index;
	
	// Destroy client controllers.
	for (index = 0; index < arrayCount(clientCtrl); index++) {
		if (clientCtrl[index] != none) {
			clientCtrl[index].destroy();
			clientCtrl[index] = none;
		}
	}
	
	// Client side only.
	if (role == ROLE_SimulatedProxy) {

		// Destroy localization support.
		if (sConf != none) {
			sConf.destroy();
			sConf = none;
		}
		
		// Destroy localization support.
		if (gInf != none) {
			gInf.destroy();
			gInf = none;
		}
		
		// Destroy Nexgen HUD.
		if (nscHUD != none) {
			nscHUD.destroy();
			nscHUD = none;
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
 *  $DESCRIPTION  Checks whether the initial replication of the configuration has completed.
 *  $RETURN       True if the initial data of the sConf instance has been recieved, false if not.
 *
 **************************************************************************************************/
simulated function bool initialConfigReplicationComplete() {
	local int index;
	
	// Check if configuration instance has been spawned (via replication).
	if (sConf == none) {
		return false;
	}
	
	// Check dynamic replication data.
	if (sConf.staticChecksum != sConf.calcStaticChecksum()) {
		return false;
	}
	
	// Check dynamic replication data.
	for (index = 0; index < arrayCount(nextDynamicChecksum); index++) {
		if (sConf.updateCounts[index] <= 0 ||
		    sConf.dynamicChecksums[index] != sConf.calcDynamicChecksum(index)) {
		    return false;
		}
	}
	
	// All checks passed, initial replication complete!
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client that it failed to login. The server calls this function if it
 *                hasn't received a login request within the specified timeout time.
 *
 **************************************************************************************************/
simulated function notifyLoginFailed() {
	local int status;
	local string diagnosticsCode;
	local bool check1, check2, check3, check4, check5, check6, check7, check8;
	
	// Automatically fix low netspeed setting.
	if (class'Player'.default.configuredInternetSpeed < minDesiredNetSpeed && owner != none) {
		owner.consoleCommand(changeNetSpeedCommand @ minDesiredNetSpeed);
		owner.consoleCommand(reconnectCommand);
		return;
	}
	
	// Compute status and diagnostics code.
	check1 = bNetLogin;
	check2 = true; //bIsNetOwner;
	check3 = serverID != "";
	check4 = owner != none;
	check5 = sConf != none;
	check6 = PlayerPawn(owner).playerReplicationInfo != none;
	check7 = loginHandler != none;
	check8 = loginHandlerChecksum == class'NexgenUtil'.static.stringHash(string(loginHandler));
	
	status = int(check1)      |
	         int(check2) << 1 |
	         int(check3) << 2 |
	         int(check4) << 3 |
	         int(check5) << 4 |
	         int(check6) << 5 |
	         int(check7) << 6 |
	         int(check8) << 7 ;
	
	diagnosticsCode = "0x" $ class'MD5Hash'.static.DecToHex(status, 4);

	// Show popup window.
	player = PlayerPawn(owner);
	if (player != none) {
		initializePopupWindow();
		showPopup("NexgenLoginFailedDialog", diagnosticsCode);
	}
	
	// Log error.
	log("[" $ self $ ".notifyLoginFailed()] Diagnostics code: " $ diagnosticsCode, 'NSC');
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Registers a new HUD extension so that it will receive preRender and postRender
 *                calls.
 *  $PARAM        extension  The HUD extenstion that is to be added.
 *  $REQUIRE      extension != none
 *
 **************************************************************************************************/
simulated function addHUDExtension(NexgenHUDExtension extension) {
	if (nscHUD != none) {
		extension.client = self;
		nscHUD.addHUDExtension(extension);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the server is still alive.
 *
 **************************************************************************************************/
simulated function checkServerHealth() {
	lastAliveCheck = timeSeconds;
	doHealthCheck();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the servers health (i.e. whether it is still alive).
 *
 **************************************************************************************************/
function doHealthCheck() {
	notifyServerHealth();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client of the servers health (i.e. whether it is still alive).
 *
 **************************************************************************************************/
simulated function notifyServerHealth() {
	bBadConnectionDetected = false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	remoteRole=ROLE_SimulatedProxy
	netPriority=4.0
	netUpdateFrequency=4.0
	bAlwaysTick=true
}
