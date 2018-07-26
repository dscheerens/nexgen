/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPConfig
 *  $VERSION      1.08 (17-12-2010 22:56:26)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Configuration class for the Nexgen Plus plugin.
 *
 **************************************************************************************************/
class NXPConfig extends NexgenPluginConfig;

// Map switch settings.
var config bool enableMapSwitch;                  // Whether map switch is available.
var config bool cacheMapList;                     // Whether to use the cached map list.
var config bool reloadMapList;                    // Reload the map list next game.
var config int autoMapListCachingThreshold;       // Map number threshold for automatically enabling
                                                  // map list caching.
var config string cachedMaps[1024];               // List of cached map package names.
var config bool showMapSwitchAtEndOfGame;         // Automatically open map switch tab at the end of
                                                  // the game?
var config int mapSwitchAutoDisplayDelay;         // Time to wait before automatically opening the
                                                  // map switch tab.

// Misc settings.
var config bool showDamageProtectionShield;       // Show a damage protection shield around players.
var config bool colorizePlayerSkins;              // Colorize the player skins with team colors.
var config bool enableAKALogging;                 // Enable AKA client ID logging.
var config bool disableUTAntiSpam;                // Disable UTs buildin anti message spam feature.
var config bool enableNexgenAntiSpam;             // Enable Nexgens anti message spam feature.
var config bool checkForNexgenUpdates;            // Automatically check for new Nexgen versions.

// Full server redirect settings.
var config bool enableFullServerRedirect;         // Show list of alternate servers when server is full.
var config bool autoFullServerRedirect;           // Automatically redirect player when server is full.
var config string altServerName[3];               // Names of the alternate servers.
var config string altServerAddress[3];            // Addresses of the alternate servers.

// Tag protection.
var config bool enableTagProtection;              // Whether tag protection should be enabled.
var config string tagsToProtect[6];               // The tags that are protected.

// Server rules.
var config string serverRules[10];                // The rules of the server.
var config bool showServerRulesTab;               // Whether to display the server rules tab in the control panel.
var config bool showServerRulesInHUD;             // Whether to display the server rules tab in the players HUD.
var config byte serverRulesHUDAnchorPointLocH;    // Horizontal anchor point of the server rules HUD window.
var config byte serverRulesHUDAnchorPointLocV;    // Vertical anchor point of the server rules HUD window.
var config int serverRulesHUDPosX;                // Horizontal position of the HUD anchor point on the screen.
var config int serverRulesHUDPosY;                // Vertical position of the HUD anchor point on the screen.
var config byte serverRulesHUDPosXUnits;          // Units of the horizontal rules HUD anchor point.
var config byte serverRulesHUDPosYUnits;          // Units of the vertical rules HUD anchor point.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs the plugin.
 *  $ENSURE       lastInstalledVersion >= xControl.versionNum
 *  $OVERRIDE
 *
 **************************************************************************************************/
function install() {
	if (lastInstalledVersion < 100) installVersion100();
	
	super.install();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 100 of the plugin.
 *
 **************************************************************************************************/
function installVersion100() {
	enableMapSwitch               = true;
	cacheMapList                  = false;
	autoMapListCachingThreshold   = 200;
	showMapSwitchAtEndOfGame      = false;
	mapSwitchAutoDisplayDelay     = 5;
	showDamageProtectionShield    = true;
	colorizePlayerSkins           = false;
	enableAKALogging              = false;
	disableUTAntiSpam             = false;
	enableNexgenAntiSpam          = false;
	checkForNexgenUpdates         = true;
	enableFullServerRedirect      = false;
	autoFullServerRedirect        = false;
	altServerName[0]              = "Another UT server";
	altServerAddress[0]           = "unreal://127.0.0.1:7777/";
	enableTagProtection           = false;
	showServerRulesTab            = false;
	showServerRulesInHUD          = false;
	serverRulesHUDAnchorPointLocH = 2;
	serverRulesHUDAnchorPointLocV = 2;
	serverRulesHUDPosX            = 50;
	serverRulesHUDPosY            = 70;
	serverRulesHUDPosXUnits       = 2;
	serverRulesHUDPosYUnits       = 2;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the configuration. Problems with the plugin configuration will be 
 *                automatically repaired.
 *  $RETURN       True if the configuration was valid, false if there were one or more configuration
 *                corruptions.
 *  $ENSURE       new.validate()
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool validate() {
	local bool wasInvalid;
	
	if (clamp(autoMapListCachingThreshold, 0, 9999) != autoMapListCachingThreshold) {
		autoMapListCachingThreshold = clamp(autoMapListCachingThreshold, 0, 9999);
		wasInvalid = true;
	}
	
	if (clamp(mapSwitchAutoDisplayDelay, 0, 999) != mapSwitchAutoDisplayDelay) {
		mapSwitchAutoDisplayDelay = clamp(mapSwitchAutoDisplayDelay, 0, 999);
		wasInvalid = true;
	}
	
	if (clamp(serverRulesHUDAnchorPointLocH, 1, 3) != serverRulesHUDAnchorPointLocH) {
		serverRulesHUDAnchorPointLocH = clamp(serverRulesHUDAnchorPointLocH, 1, 3);
		wasInvalid = true;
	}
	
	if (clamp(serverRulesHUDAnchorPointLocV, 1, 3) != serverRulesHUDAnchorPointLocV) {
		serverRulesHUDAnchorPointLocV = clamp(serverRulesHUDAnchorPointLocV, 1, 3);
		wasInvalid = true;
	}
	
	if (clamp(serverRulesHUDPosXUnits, 1, 2) != serverRulesHUDPosXUnits) {
		serverRulesHUDPosXUnits = clamp(serverRulesHUDPosXUnits, 1, 2);
		wasInvalid = true;
	}
	
	if (clamp(serverRulesHUDPosYUnits, 1, 2) != serverRulesHUDPosYUnits) {
		serverRulesHUDPosYUnits = clamp(serverRulesHUDPosYUnits, 1, 2);
		wasInvalid = true;
	}
	
	return !wasInvalid;
}