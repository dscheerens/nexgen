/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXConfig
 *  $VERSION      1.07 (16-3-2009 17:53)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  NexgenX configuration container/replication class. This class contains the 
 *                settings for the extension plugin.
 *
 **************************************************************************************************/
class NexgenXConfig extends ReplicationInfo;

var NexgenX xControl;                             // NexgenX plugin.

// Special settings.
var config int lastInstalledVersion;              // Last installed version of the plugin.

// General settings.
var int generalSettingsChecksum;                  // Checksum for the general settings variables.
var config bool enableOverlaySkin;                // Enable the player overlay skin effect.
var config bool enableMapSwitch;                  // Whether map switch is available.
var config bool enableStartAnnouncer;             // Play a voice announcer when the game starts.
var config bool enableAntiSpam;                   // Enable message spam detection.
var config bool enableClientIDAKALog;             // Enable AKA player ID logging.
var config bool checkForUpdates;                  // Automatically check if there is a new version
                                                  // of Nexgen available.
var config bool disableUTAntiSpam;                // Disable UT's buildin anti-spam feature.
var config bool enablePerformanceOptimizer;       // Enable server performance optimizer.

// Full server redirect settings.
var int fullServerRedirectChecksum;               // Check for the full server redirect variables.
var config bool enableFullServerRedirect;         // Whether full server redirect is enabled.
var config string fullServerRedirectMsg;          // Message to display when the server is full.
var config string redirectServerName[3];          // Names of the alternate servers.
var config string redirectURL[3];                 // Redirect URL for the servers.
var config bool enableAutoRedirect;               // Automatically redirect player to alternate server.

// Clan tag protection.
var config bool enableTagProtection;              // Whether the clan tag protection should be used.
var config string tagsToProtect[6];               // The tags that are protected.

// Server rules.
var config bool enableServerRules;                // Display server rules?
var config string serverRules[10];                // The rules of the server.

// Data transfer control.
var int dynamicChecksums[4];                      // Checksum for the dynamic replicated variables.
var int dynamicChecksumModifiers[4];              // Dynamic data checksum salt.
var int updateCounts[4];                          // How many times the settings have been updated
                                                  // during the current game. Used to detect setting
                                                  // changes clientside.

// Events.
const EVENT_NexgenXConfigChanged = "nexgenx_config_changed";

// Config types.
const CT_GeneralSettings = 0;                     // General settings config type.
const CT_FullServerRedirect = 1;                  // Full server redirect settings config type.
const CT_TagProtectionSettings = 2;               // Clan tag protection settings config type.
const CT_ServerRulesSettings = 3;                 // Server rules settings config type.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

	reliable if (role == ROLE_Authority)
		// General settings.
		enableOverlaySkin, enableMapSwitch, enableStartAnnouncer, enableAntiSpam,
		enableClientIDAKALog, checkForUpdates, disableUTAntiSpam, enablePerformanceOptimizer,
		
		// Full server redirect settings.
		enableFullServerRedirect, fullServerRedirectMsg, redirectServerName, redirectURL,
		enableAutoRedirect,
		
		// Clan tag protection.
		enableTagProtection, tagsToProtect,
		
		// Server rules.
		enableServerRules, serverRules,
		
		// Data transfer control.
		dynamicChecksums, dynamicChecksumModifiers, updateCounts;
}




/***************************************************************************************************
 *
 *  $DESCRIPTION  Calculates a checksum of the replicated dynamic variables.
 *  $PARAM        configType  The configuration type for which the checksum is to be calculated.
 *  $REQUIRE      configType == CT_GeneralSettings ||
 *                configType == CT_FullServerRedirect ||
 *                configType == CT_TagProtectionSettings
 *  $RETURN       The checksum of the replicated variables.
 *
 **************************************************************************************************/
simulated function int calcDynamicChecksum(byte configType) {
	local int checksum;
	local int index;
	
	checksum += dynamicChecksumModifiers[configType];
	
	switch (configType) {
		case CT_GeneralSettings: // General settings config type.
			checksum += int(enableOverlaySkin)               |
			            int(enableMapSwitch)            << 1 |
			            int(enableStartAnnouncer)       << 2 |
			            int(enableAntiSpam)             << 3 | 
			            int(enableClientIDAKALog)       << 4 |
			            int(checkForUpdates)            << 5 |
			            int(disableUTAntiSpam)          << 6 |
			            int(enablePerformanceOptimizer) << 7 ;
			break;
			
		case CT_FullServerRedirect: // Full server redirect settings config type.
			checksum += int(enableFullServerRedirect)        |
			            int(enableAutoRedirect)         << 1 +
			            len(fullServerRedirectMsg);
			for (index = 0; index < arrayCount(redirectServerName); index++) {
				checksum += len(redirectServerName[index]);
			}
			for (index = 0; index < arrayCount(redirectURL); index++) {
				checksum += len(redirectURL[index]);
			}
			break;
			
		case CT_TagProtectionSettings: // Clan tag protection settings config type.
			checksum += int(enableTagProtection);
			for (index = 0; index < arrayCount(tagsToProtect); index++) {
				checksum += len(tagsToProtect[index]);
			}
			break;
		
		case CT_ServerRulesSettings: // Server rules settings config type.
			checksum += int(enableServerRules);
			for (index = 0; index < arrayCount(serverRules); index++) {
				checksum += len(serverRules[index]);
			}
	}
		
	return checksum;
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
 *  $DESCRIPTION  Loads the plugins configuration.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	
	xControl = NexgenX(owner);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs the extension plugin.
 *  $ENSURE       lastInstalledVersion >= xControl.versionNum
 *
 **************************************************************************************************/
function install() {
	
	if (lastInstalledVersion < 105) installVersion105();
	if (lastInstalledVersion < 106) installVersion106();
	if (lastInstalledVersion < 107) installVersion107();
	//if (lastInstalledVersion < 108) installVersion108();
	if (lastInstalledVersion < 109) installVersion109();
	// etc.
	
	if (lastInstalledVersion < xControl.versionNum) {
		lastInstalledVersion = xControl.versionNum;
	}
	saveConfig();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 105 of the Nexgen extension plugin.
 *
 **************************************************************************************************/
function installVersion105() {
	enableOverlaySkin = true;
	enableMapSwitch = true;
	enableStartAnnouncer = true;
	enableFullServerRedirect = false;
	fullServerRedirectMsg = xControl.lng.defaultFullServerRedirMsg;
	redirectServerName[0] = "Server 1";
	redirectURL[0] = "unreal://127.0.0.1:7777/";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 106 of the Nexgen extension plugin.
 *
 **************************************************************************************************/
function installVersion106() {
	enableAntiSpam = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 107 of the Nexgen extension plugin.
 *
 **************************************************************************************************/
function installVersion107() {
	checkForUpdates = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 109 of the Nexgen extension plugin.
 *
 **************************************************************************************************/
function installVersion109() {
	enablePerformanceOptimizer = false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the configuration. Problems with the Nexgen extension plugin
 *                configuration will be automatically repaired.
 *  $RETURN       True if the configuration was valid, false if there were one or more configuration
 *                corruptions.
 *  $ENSURE       imply(old.validate(), new.validate())
 *
 **************************************************************************************************/
function bool validate() {
	local bool bInvalid;
	local int index;
	
	bInvalid = bInvalid || fixStrLen(fullServerRedirectMsg, 250);
	for (index = 0; index < arrayCount(redirectServerName); index++) {
		bInvalid = bInvalid || fixStrLen(redirectServerName[index], 24);
	}
	for (index = 0; index < arrayCount(redirectURL); index++) {
		bInvalid = bInvalid || fixStrLen(redirectURL[index], 64);
	}
	for (index = 0; index < arrayCount(tagsToProtect); index++) {
		bInvalid = bInvalid || fixStrLen(tagsToProtect[index], 10);
	}
	for (index = 0; index < arrayCount(serverRules); index++) {
		bInvalid = bInvalid || fixStrLen(serverRules[index], 200);
	}
	
	if (bInvalid) {
		saveConfig();
	}
	
	return !bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the configuration.
 *
 **************************************************************************************************/
function initialize() {
	local int index;
	
	// Last thing to do is to make sure all the checksums are up to date.
	updateDynamicChecksums();
	for (index = 0; index < arrayCount(dynamicChecksums); index++) {
		updateCounts[index] = 1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixes the length of a string. This function makes sure the length of a given
 *                string doesn't exceed the specified maximum length.
 *  $PARAM        str  The string of which the length has to be checked.
 *  $PARAM        maxLen  The maximum length of the string.
 *  $REQUIRE      maxLen >= 0
 *  $RETURN       True if the length of the string was changed, false otherwise.
 *  $ENSURE       len(new.str) <= maxLen
 *
 **************************************************************************************************/
function bool fixStrLen(out string str, int maxLen) {
	if (len(str) > maxLen) {
		str = left(str, maxLen);
		return true;
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixes the value of a given integer variable. Calling this function will ensure
 *                that the value of the variable will be in the specified domain.
 *  $PARAM        intVar      The integer variable whose value is to be checked.
 *  $PARAM        lowerBound  Lower bound on the range of the variable.
 *  $PARAM        upperBound  Upperbound bound on the range of the variable.
 *  $RETURN       True if value of the integer variable was changed, false otherwise.
 *  $ENSURE       lowerBound <= intVar && intVar <= upperBound
 *
 **************************************************************************************************/
function bool fixIntRange(out int intVar, int lowerBound, int upperBound) {
	if (intVar < lowerBound) {
		intVar = lowerBound;
		return true;
	} else if (intVar > upperBound) {
		intVar = upperBound;
		return true;
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixes the value of a given byte variable. Calling this function will ensure
 *                that the value of the variable will be in the specified domain.
 *  $PARAM        byteVar     The byte variable whose value is to be checked.
 *  $PARAM        lowerBound  Lower bound on the range of the variable.
 *  $PARAM        upperBound  Upperbound bound on the range of the variable.
 *  $RETURN       True if value of the byte variable was changed, false otherwise.
 *  $ENSURE       lowerBound <= byteVar && byteVar <= upperBound
 *
 **************************************************************************************************/
function bool fixByteRange(out byte byteVar, byte lowerBound, byte upperBound) {
	if (byteVar < lowerBound) {
		byteVar = lowerBound;
		return true;
	} else if (byteVar > upperBound) {
		byteVar = upperBound;
		return true;
	} else {
		return false;
	}
}
