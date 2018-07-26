/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $CLASS        NSVConfig
 *  $VERSION      1.00 (23-6-2008 21:16)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Configuration class for the nexgen stats viewer plugin.
 *
 **************************************************************************************************/
class NSVConfig extends ReplicationInfo;

var NSVMain xControl;                             // Stats viewer controller.

// Special settings.
var config int lastInstalledVersion;              // Last installed version of the plugin.

// Data transfer control.
var int dynamicChecksums[2];                      // Checksum for the dynamic replicated variables.
var int dynamicChecksumModifiers[2];              // Dynamic data checksum salt.
var int updateCounts[2];                          // How many times the settings have been updated
                                                  // during the current game. Used to detect setting
                                                  // changes clientside.

// UTStats client settings.
var config bool enableUTStatsClient;              // Whether to UTStats client is enabled.
var config string utStatsHost;                    // The hostname or IP of the UTStats server.
var config int utStatsPort;                       // Port of the UTStats server.
var config string utStatsPath;                    // Path of the UTStats script on the server.

// Events.
const EVENT_NexgenStatsViewerConfigChanged = "nexgenstatsviewer_config_changed";

// Config types.
const CT_UTStatsClientSettings = 0;               // UTStats client settings config type.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

	reliable if (role == ROLE_Authority)
		// UTStats client settings.
		enableUTStatsClient, utStatsHost, utStatsPort, utStatsPath,
		
		// Data transfer control.
		dynamicChecksums, dynamicChecksumModifiers, updateCounts;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Calculates a checksum of the replicated dynamic variables.
 *  $PARAM        configType  The configuration type for which the checksum is to be calculated.
 *  $REQUIRE      configType == CT_UTStatsClientSettings
 *  $RETURN       The checksum of the replicated variables.
 *
 **************************************************************************************************/
simulated function int calcDynamicChecksum(byte configType) {
	local int checksum;
	local int index;
	
	checksum += dynamicChecksumModifiers[configType];
	
	switch (configType) {
		case CT_UTStatsClientSettings: // UTStats client settings config type.
			checksum += int(enableUTStatsClient) +
			            len(utStatsHost)         +
			            utStatsPort              +
			            len(utStatsPath)         ;
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
	
	xControl = NSVMain(owner);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs the Nexgen statistics viewer plugin.
 *  $ENSURE       lastInstalledVersion >= xControl.versionNum
 *
 **************************************************************************************************/
function install() {
	
	if (lastInstalledVersion < 100) installVersion100();
	//if (lastInstalledVersion < 101) installVersion101();
	//if (lastInstalledVersion < 102) installVersion102();
	//if (lastInstalledVersion < 103) installVersion103();
	//if (lastInstalledVersion < 104) installVersion104();
	// etc.
	
	if (lastInstalledVersion < xControl.versionNum) {
		lastInstalledVersion = xControl.versionNum;
		saveConfig();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs version 107 of the Nexgen extension plugin.
 *
 **************************************************************************************************/
function installVersion100() {
	utStatsPort = 80;
	utStatsPath = "/utstats/getstats.php";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the configuration. Problems with the Nexgen stats viewer plugin
 *                configuration will be automatically repaired.
 *  $RETURN       True if the configuration was valid, false if there were one or more configuration
 *                corruptions.
 *  $ENSURE       imply(!old.validate(), new.validate())
 *
 **************************************************************************************************/
function bool validate() {
	local bool bInvalid;
	
	if (len(utStatsHost) > 50) {
		bInvalid = true;
		utStatsHost = "";
	}
	if (utStatsPort <= 0 || utStatsPort >= 65536) {
		bInvalid = true;
		utStatsPort = 80;
	}
	if (len(utStatsPath) > 250) {
		bInvalid = true;
		utStatsPath = "";
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