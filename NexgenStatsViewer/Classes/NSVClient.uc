/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $CLASS        NSVClient
 *  $VERSION      1.03 (23-6-2008 22:50)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen stats viewer client controller class. This class is the base of the
 *                clientside support for the statistics viewer plugin.
 *
 **************************************************************************************************/
class NSVClient extends NexgenClientController;

var NSVMain xControl;                   // Plugin controller.
var NSVLang lng;                        // Language localization support.
var NSVReplicationInfo statsRI;         // Statistics replication info.
var NSVConfig conf;                     // Plugin configuration.
var NSVHUD xHUD;                        // The stats viewer HUD.

var bool bNetWait;                      // Client is waiting for initial replication.

var bool bWaitingForPlayerList;         // Waiting for the top player list.

// Config replication control.
var int nextDynamicUpdateCount[2];      // Last received config update count per config type.
var int nextDynamicChecksum[2];         // Checksum to wait for.
var byte bWaitingForNewConfig[2];       // Whether the client is waiting for the configuration.

// Controller settings.
const timerFreq = 5.0;                  // Timer tick frequency.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

	reliable if (role == ROLE_Authority) // Replicate to client...
		// Variables.
		statsRI, conf,
		
		// Functions.
		nexgenStatsViewerConfigChanged, showStats;

	reliable if (role == ROLE_SimulatedProxy) // Replicate to server...
		setUTStatsClientSettings;
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
	xControl = NSVMain(creator);
	lng = xControl.lng;
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
		lng = spawn(class'NSVLang');
		
		// Wait until the stats have been received.
		bWaitingForPlayerList = true;
		
		// Enable timer.
		setTimer(1.0 / timerFreq, true);
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
 *  $DESCRIPTION  Timer tick. Checks if the replication info has been received.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function timer() {
	
	// Client side actions.
	if (role == ROLE_SimulatedProxy) {
		
		// Check if the player list has been received.
		if (bWaitingForPlayerList && statsRI != none &&
		    statsRI.playerListChecksum == statsRI.calcPlayerListChecksum()) {
			bWaitingForPlayerList = false;
			playerListReceived();
		}
		
		// Check for config updates.
		if (!bNetWait) {
			checkConfigUpdate();
		}
	}
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
		client.addPluginConfigPanel(class'NSVRCPUTStatsClientSettings');
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
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the top player list has been received.
 *
 **************************************************************************************************/
simulated function playerListReceived() {
	// Create HUD.
	xHUD = spawn(class'NSVHUD', self);
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
simulated function nexgenStatsViewerConfigChanged(byte configType, int updateCount, int checksum) {
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
		    conf.updateCounts[type] >= nextDynamicUpdateCount[type] &&
		    conf.calcDynamicChecksum(type) == nextDynamicChecksum[type]) {
		    
			bWaitingForNewConfig[type] = byte(false);
			
			// Signal event GUI.
			client.notifyEvent(conf.EVENT_NexgenStatsViewerConfigChanged, string(type));
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the initial replication of the configuration has completed.
 *  $RETURN       True if the initial data of the conf instance has been recieved, false if not.
 *
 **************************************************************************************************/
simulated function bool initialConfigReplicationComplete() {
	local int index;
	
	// Check if configuration instance has been spawned (via replication).
	if (conf == none) {
		return false;
	}
	
	// Check dynamic replication data.
	for (index = 0; index < arrayCount(nextDynamicChecksum); index++) {
		if (conf.updateCounts[index] <= 0 ||
		    conf.dynamicChecksums[index] != conf.calcDynamicChecksum(index)) {
		    return false;
		}
	}
	
	// All checks passed, initial replication complete!
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
function setUTStatsClientSettings(bool enableUTStatsClient, string utStatsHost, int utStatsPort,
                                  string utStatsPath) {
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Check settings.
	if (utStatsPort <= 0 || utStatsPort >= 65536) {
		utStatsPort = 80;
	}
	
	// Safe settings.
	conf.enableUTStatsClient = enableUTStatsClient;
	conf.utStatsHost = utStatsHost;
	conf.utStatsPort = utStatsPort;
	conf.utStatsPath = utStatsPath;
	conf.saveConfig();
	
	// Notify system.
	xControl.signalConfigUpdate(conf.CT_UTStatsClientSettings);
	
	// Log action.
	client.showMsg(control.lng.settingsSavedMsg);
	logAdminAction(lng.adminUpdateUTStatsClientSettingsMsg, , , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Makes the stats appear on the client.
 *
 **************************************************************************************************/
simulated function showStats() {
	if (xHUD != none) {
		xHUD.showStats();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	ctrlID="NexgenStatsViewerClient"
	bAlwaysTick=true
}

