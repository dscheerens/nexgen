/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSConfig
 *  $VERSION      1.04 (21-11-2008 0:21)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Configuration container class for the global login system plugin settings.
 *
 **************************************************************************************************/
class NGLSConfig extends ReplicationInfo;

var NGLSMain xControl;                            // Global login system plugin.

// Special settings.
var config int lastInstalledVersion;              // Last installed version of the plugin.

// General settings.
var config bool enableNGLS;                       // Whether the global login system is enabled.
var config int loginTimeout;                      // Client should login within this time.
var config bool acceptLocalAccounts;              // Always accept players with a local Nexgen account?
var config bool allowUnregisteredSpecs;           // Whether or not spectators have to be registered.
var config string registerURL;                    // URL of the site where the players can register.
var config bool disconnectClientWhenVerifyFails;  // Disconnect the client when unable to communicate
                                                  // with the NGLS master server.
var config string nglsServerHost;                 // The hostname or IP of the NGLS master server.
var config int nglsServerPort;                    // Port of the NGLS master server.
var config string nglsServerPath;                 // Path of the script on the NGLS master server.

// Data transfer control.
var int dynamicChecksums[2];                      // Checksum for the dynamic replicated variables.
var int dynamicChecksumModifiers[2];              // Dynamic data checksum salt.
var int updateCounts[2];                          // How many times the settings have been updated
                                                  // during the current game. Used to detect setting
                                                  // changes clientside.

// Events.
const EVENT_NexgenGLSConfigChanged = "nexgengls_config_changed";

// Config types.
const CT_GeneralSettings = 0;                     // General settings config type.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

	reliable if (role == ROLE_Authority)
		// General settings.
		enableNGLS, loginTimeout, acceptLocalAccounts, allowUnregisteredSpecs, registerURL,
		disconnectClientWhenVerifyFails, nglsServerHost, nglsServerPort, nglsServerPath,
		
		// Data transfer control.
		dynamicChecksums, dynamicChecksumModifiers, updateCounts;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Calculates a checksum of the replicated dynamic variables.
 *  $PARAM        configType  The configuration type for which the checksum is to be calculated.
 *  $REQUIRE      configType == CT_GeneralSettings
 *  $RETURN       The checksum of the replicated variables.
 *
 **************************************************************************************************/
simulated function int calcDynamicChecksum(byte configType) {
	local int checksum;
	local int index;
	
	checksum += dynamicChecksumModifiers[configType];
	
	switch (configType) {
		case CT_GeneralSettings: // General settings config type.
			checksum += loginTimeout                                          +
			            nglsServerPort                                        +
			            int(enableNGLS)                                  << 0 +
			            int(acceptLocalAccounts)                         << 1 +
			            int(allowUnregisteredSpecs)                      << 2 +
			            int(disconnectClientWhenVerifyFails)             << 3 +
			            len(registerURL)                                      +
			            len(nglsServerHost)                                   +
			            len(nglsServerPath)                                   ;
			break;
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
	
	xControl = NGLSMain(owner);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs the extension plugin.
 *  $ENSURE       lastInstalledVersion >= xControl.versionNum
 *
 **************************************************************************************************/
function install() {
	
	if (lastInstalledVersion < 100) installVersion100();
	
	if (lastInstalledVersion < xControl.versionNum) {
		lastInstalledVersion = xControl.versionNum;
	}
	saveConfig();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 100 of the global login system plugin.
 *
 **************************************************************************************************/
function installVersion100() {
	enableNGLS = false;
	loginTimeout = 30;
	acceptLocalAccounts = true;
	allowUnregisteredSpecs = false;
	registerURL = "http://www.your-site.com/";
	disconnectClientWhenVerifyFails = false;
	nglsServerPort = 80;
	nglsServerPath = "/ngls_check.php";
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
	
	bInvalid = bInvalid || fixIntRange(loginTimeout, 0, 999);
	bInvalid = bInvalid || fixStrLen(registerURL, 150);
	
	if (len(nglsServerHost) > 50) {
		bInvalid = true;
		nglsServerHost = "";
	}
	if (nglsServerPort <= 0 || nglsServerPort >= 65536) {
		bInvalid = true;
		nglsServerPort = 80;
	}
	if (len(nglsServerPath) > 250) {
		bInvalid = true;
		nglsServerPath = "";
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
 *  $DESCRIPTION  Checks whether the server settings are configured properly so clients can be
 *                checked.
 *
 **************************************************************************************************/
function bool nglsServerSettingsOk() {
	return (class'NexgenUtil'.static.trim(nglsServerPath) != "") &&
	       (class'NexgenUtil'.static.trim(nglsServerHost) != "");
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
