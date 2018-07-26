/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSClient
 *  $VERSION      1.08 (20-11-2008 16:31)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Global login system plugin client controller class.
 *
 **************************************************************************************************/
class NGLSClient extends NexgenClientController;

#exec TEXTURE IMPORT NAME=loginIcon  FILE=Resources\loginIcon_.pcx  GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=loginIcon2 FILE=Resources\loginIcon2_.pcx GROUP="GFX" FLAGS=3 MIPS=OFF

var NGLSMain xControl;                            // Extension controller.
var NGLSLang lng;                                 // Language instance to support localization.
var NGLSConfig xConf;                             // Plugin configuration.
var NGLSHTTPClient httpClient;			          // The HTTP client for checking login info.

var bool bNetWait;                                // Client is waiting for initial replication.

// Dynamic control info.
var bool bClientLoginDone;                        // Client has send it's login information to the server?
var bool bLoginInfoReceived;                      // Set once the server has received the login info.
var bool bLoginComplete;                          // Whether the login procudere has been completed.
var string loginUsername;                         // The login name received from the client.
var string loginPasswordHash;                     // The password hash received from the client.
var float loginCheckTimestamp;                    // Time at which the login check was started.
var bool loginCheckTimeoutDetected;               // Has a login check timeout been detected?

// Config replication control.
var int nextDynamicUpdateCount[2];                // Last received config update count per config type.
var int nextDynamicChecksum[2];                   // Checksum to wait for.
var byte bWaitingForNewConfig[2];                 // Whether the client is waiting for the configuration.

// Settings.
const timerFreq = 5.0;                            // Timer tick frequency.
const loginCheckTimeout = 10.0;                   // Time to wait before login check timeout occurs.

// Client side configuration settings.
const SSTR_NGLSUserName = "NGLSUserName";         // NGLS login user name.
const SSTR_NGLSPassword = "NGLSPassword";         // NGLS login password.

// Error codes.
const IO_ERR_InvalidAddress = -1;                 // Invalid server address in configuration.
const IO_ERR_PortBindFailed = -2;                 // Unable to open a socket.
const IO_ERR_Timeout = -3;                        // Timeout during connection setup.
const IO_ERR_FileNotFound = 404;                  // Script file not found on server.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {
	reliable if (role == ROLE_Authority) // Replicate to client...
		// Variables.
		xConf, bLoginComplete,
		
		// Functions.
		xConfigChanged;
		
	reliable if (role == ROLE_SimulatedProxy) // Replicate to server...
		// Variables.	
	
		// Functions.
		login, setGeneralSettings;
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
		
		// Enable timer.
		setTimer(1.0 / timerFreq, true);
		
		// Load localization support.
		lng = spawn(class'NGLSLang');
	} else {
		destroy();
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
	xControl = NGLSMain(creator);
	lng = xControl.lng;
	
	// Start timer (set for the login procedure).
	setTimer(1.0 / timerFreq, true);
	
	// Skip login procedure if the global login systen is disabled.
	if (!xControl.xConf.enableNGLS) {
		bLoginInfoReceived = true;
		bLoginComplete = true;
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
 *  $DESCRIPTION  Called when the NexgenClient has received its initial replication info is has
 *                been initialized. At this point it's safe to use all functions of the client.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function clientInitialized() {
	bNetWait = false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Modifies the setup of the Nexgen remote control panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function setupControlPanel() {
	// Add control panel tabs.
	if (client.hasRight(client.R_ServerAdmin)) {
		client.addPluginConfigPanel(class'NGLSRCPSettings');
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function.
 *
 **************************************************************************************************/
simulated function timer() {
	
	// Client side actions.
	if (role == ROLE_SimulatedProxy) {
				
		// Perform login.
		if (!bClientLoginDone && !bLoginComplete && client != none && client.loginComplete) {
			clientLogin();
		}
		
		// Check for config updates.
		if (!bNetWait) {
			checkConfigUpdate();
		}

	// Server side actions.
	} else { 
		
		// Check for login timeout.
		if (!bLoginInfoReceived && xConf != none && xConf.loginTimeout > 0 &&
		    client.timeSeconds >= xConf.loginTimeout) {
			
			// Disable timeout timer.
			setTimer(0.0, false);
			
			// Notify client of event.
			loginFailed(lng.loginTimeoutMsg, true, xControl.packageName $ ".NGLSLoginTimeoutDialog");
		}
		
		// Check for login verify timeout.
		if (bLoginInfoReceived && !bLoginComplete && !loginCheckTimeoutDetected &&
		    client.timeSeconds - loginCheckTimestamp >= loginCheckTimeout) {
			
			// Yeah we've got a timeout :(
			loginCheckTimeoutDetected = true;
			
			// Destroy login checker HTTP client.
			if (httpClient != none) {
				httpClient.destroy();
				httpClient = none;
			}
			
			// Signal event.
			checkFailed(IO_ERR_Timeout);
		}
		
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the verification of the login info of this client has failed.
 *  $PARAM        errorCode  Code that indicates the type of error that occurred.
 *
 **************************************************************************************************/
function checkFailed(int errorCode) {
	local string errorMsg;
	
	// Get error message.
	switch (errorCode) {
		case IO_ERR_InvalidAddress: errorMsg = lng.loginCheckInvalidServerAddressMsg; break;
		case IO_ERR_PortBindFailed: errorMsg = lng.loginCheckOpenConnectionFailedMsg; break;
		case IO_ERR_Timeout: errorMsg = lng.loginCheckTimeoutMsg; break;
		case IO_ERR_FileNotFound: errorMsg = lng.loginCheckScriptMissingMsg; break;
			
		default:
			errorMsg = control.lng.format(lng.loginCheckIOErrorMsg, errorCode);
			break;
	}
	
	// Signal and log event.
	xControl.nglsLog(errorMsg);
	loginFailed(lng.loginVerifyFailedMsg, xConf.disconnectClientWhenVerifyFails, xControl.packageName $ ".NGLSLoginVerifyFailedDialog", errorMsg);
	
	// Accept player if this option is set.
	if (!xConf.disconnectClientWhenVerifyFails) {
		bLoginComplete = true;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the login of this client has failed.
 *  $PARAM        reason       A message that describes why the login has failed.
 *  $PARAM        bDisconnect  Whether the client should be disconnected from the server.
 *  $PARAM        popupClass   Class name of the popup dialog to show.
 *  $PARAM        str1         Dialog specific argument.
 *  $PARAM        str2         Dialog specific argument.
 *  $PARAM        str3         Dialog specific argument.
 *  $PARAM        str4         Dialog specific argument.
 *
 **************************************************************************************************/
function loginFailed(string reason, optional bool bDisconnect, optional string popupClass,
                     optional string str1, optional string str2, optional string str3,
                     optional string str4) {
	// Log event.
	if (!bDisconnect) {
		xControl.nglsLog(control.lng.format(lng.loginFailedMsg, client.player.playerReplicationInfo.playerName, reason));
	} else {
		xControl.nglsLog(control.lng.format(lng.loginFailedWithDisconnectMsg, client.player.playerReplicationInfo.playerName, reason));
	}
	
	// Disconnect client if necessary.
	if (bDisconnect) {
		// Disconnect player.
		if (!client.loginComplete) {
			control.disconnectClient(client);
		} else {
			if (class'NexgenUtil'.static.trim(popupClass) != "") {
				client.showPopup(popupClass, str1, str2, str3, str4);
			}
			client.player.destroy();
		}
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
simulated function xConfigChanged(byte configType, int updateCount, int checksum) {
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
			client.notifyEvent(xConf.EVENT_NexgenGLSConfigChanged, string(type));
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
 *  $DESCRIPTION  Reads the login information and sends it to the server.
 *  $REQUIRE      !bClientLoginDone
 *  $ENSURE       bClientLoginDone
 *
 **************************************************************************************************/
simulated function clientLogin() {
	local string username;
	local string password;
	local string passwordHash;
	
	username = client.sc.get(client.serverID, SSTR_NGLSUserName);
	password = client.sc.get(client.serverID, SSTR_NGLSPassword);
	
	if (password == "") {
		passwordHash = "";
	} else {
		passwordHash = class'MD5Hash'.static.MD5String(password);
	}
	login(username, passwordHash);
	
	bClientLoginDone = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Logs the user in on the server.
 *  $PARAM        username      User name of the player that wishes to login.
 *  $PARAM        passwordHash  MD5 hash of the players password.
 *  $ENSURE       bLoginInfoReceived
 *
 **************************************************************************************************/
function login(string username, string passwordHash) {
	
	bLoginInfoReceived = true;
	loginUsername = username;
	loginPasswordHash = passwordHash;
	
	xControl.nglsLog(control.lng.format(lng.loginInfoReceivedMsg, client.playerName));
	xControl.nglsLog(control.lng.format(lng.loginUsernameMsg, loginUsername));
	xControl.nglsLog(control.lng.format(lng.loginPasswordMsg, loginPasswordHash));
	
	// Accept or reject login.
	if (!xConf.enableNGLS) {
		// The global login system is disabled.
		acceptLogin();
	
	} else if (!xControl.xConf.nglsServerSettingsOk()) {
		// If the NGLS master server settings are not set we can't check the login info, so accept
		// the player else nobody will be able to join the server.
		acceptLogin();
	
	} else if (client.hasRight(client.R_ServerAdmin)) {
		// Server administrators do not need to login.
		acceptLogin();
	
	} else if (xConf.acceptLocalAccounts && client.bHasAccount) {
		// The player has a local Nexgen account, so accept him/her.
		acceptLogin();
	
	} else if (xConf.allowUnregisteredSpecs && client.bSpectator) {
		// Specators are allowed to enter the server without being registered.
		acceptLogin();
		
	} else if (class'NexgenUtil'.static.trim(username) == "") {
		// No user name specified.
		loginFailed(lng.loginNoUsernameMsg, true, xControl.packageName $ ".NGLSLoginDialog",
		            string(xConf.allowUnregisteredSpecs), xConf.registerURL);

	} else if (class'NexgenUtil'.static.trim(passwordHash) == "") {
		// No password specified.
		loginFailed(lng.loginNoPasswordMsg, true, xControl.packageName $ ".NGLSLoginDialog",
		            string(xConf.allowUnregisteredSpecs), xConf.registerURL);
		            
	} else {
		// Check username and password.
		checkLoginInfo();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the login information of the client.
 *
 **************************************************************************************************/
function checkLoginInfo() {
	loginCheckTimestamp = client.timeSeconds;
	httpClient = spawn(class'NGLSHTTPClient', xControl);
	httpClient.verifyLoginInfo(self);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Accepts the NGLS login request for this client.
 *  $REQUIRE      bLoginInfoReceived
 *  $ENSURE       bLoginComplete
 *
 **************************************************************************************************/
function acceptLogin() {
	if (!bLoginComplete) {
		bLoginComplete = true;
		xControl.nglsLog(control.lng.format(lng.loginAcceptedMsg, client.playerName));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Rejects the NGLS login request for this client. The client will be disconnected.
 *  $PARAM        reason  The reason why the login was rejected.
 *  $REQUIRE      bLoginInfoReceived
 *
 **************************************************************************************************/
function rejectLogin(string reason) {
	local string dialogClass;
	
	switch (reason) {
		case "unknown_user":      
		case "invalid_password": 
			dialogClass = "NGLSInvalidLoginInfoDialog";
			break;
			
		case "banned":      
		case "deactivated": 
		case "suspended":
			dialogClass = "NGLSAccountBannedDialog";
			break;
			
		default:
			dialogClass = "NGLSLoginDialog";
			break;
	}
	
	loginFailed(reason, true, xControl.packageName $ "." $ dialogClass,
	            string(xConf.allowUnregisteredSpecs), xConf.registerURL);
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
	
	if (!bLoginComplete) {
		icon      = Texture'LoginIcon';
		solidIcon = Texture'LoginIcon2';
		stateType = client.nscHUD.CS_Login;
		text      = client.lng.loginState;
		textColor = client.nscHUD.colors[client.nscHUD.C_WHITE];	
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
	
	// Client side.
	if (role == ROLE_SimulatedProxy) {
		// Client side.

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
	
	// Destroy login checker HTTP client.
	if (httpClient != none) {
		httpClient.destroy();
		httpClient = none;
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the settings for the global login system.
 *
 **************************************************************************************************/
function setGeneralSettings(bool enableNGLS, int loginTimeout, bool acceptLocalAccounts,
                            bool allowUnregisteredSpecs, string registerURL,
                            bool disconnectClientWhenVerifyFails, string nglsServerHost,
                            int nglsServerPort, string nglsServerPath) {
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Check settings.
	if (loginTimeout < 0 || loginTimeout > 999) {
		loginTimeout = 30;
	}
	if (nglsServerPort <= 0 || nglsServerPort >= 65536) {
		nglsServerPort = 80;
	}
	
	// Save settings.
	xConf.enableNGLS = enableNGLS;
	xConf.loginTimeout = loginTimeout;
	xConf.acceptLocalAccounts = acceptLocalAccounts;
	xConf.allowUnregisteredSpecs = allowUnregisteredSpecs;
	xConf.registerURL = registerURL;
	xConf.disconnectClientWhenVerifyFails = disconnectClientWhenVerifyFails;
	xConf.nglsServerHost = nglsServerHost;
	xConf.nglsServerPort = nglsServerPort;
	xConf.nglsServerPath = nglsServerPath;
	xConf.saveConfig();
	
	// Notify system.
	xControl.signalConfigUpdate(xConf.CT_GeneralSettings);
	
	// Log action.
	client.showMsg(control.lng.settingsSavedMsg);
	logAdminAction(lng.adminUpdateGeneralSettingsMsg);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	ctrlID="GlobalLoginSystemClient"
	bCanModifyHUDStatePanel=true
	bAlwaysTick=true
}