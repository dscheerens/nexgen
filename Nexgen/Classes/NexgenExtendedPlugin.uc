/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenExtendedPlugin
 *  $VERSION      1.03 (01-08-2010 13:13)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen controller plugin with extended features.
 *
 **************************************************************************************************/
class NexgenExtendedPlugin extends NexgenPlugin abstract;

var int versionNum;                               // Version number of the plugin.

var NexgenPluginConfig xConf;                     // The plugin configuration container.
var class<NexgenPluginConfig> extConfigClass;     // External configuration container class.
var class<NexgenPluginConfig> sysConfigClass;     // Server system configuration container class.

var NexgenSharedDataSyncManager dataSyncMgr;      // Manager for the shared server variables.
var class<NexgenExtendedClientController> clientControllerClass; // Client controller class used by this plugin.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {
	// Create shared variable manager.
	dataSyncMgr = spawn(class'NexgenSharedDataSyncManager');
	dataSyncMgr.xControl = self;
	
	// Load configuration.
	if (extConfigClass != none || sysConfigClass != none) {
		// Spawn configuration container.
		if (control.bUseExternalConfig && extConfigClass != none || sysConfigClass == none) {
			xConf = spawn(extConfigClass, self);
		} else {
			xConf = spawn(sysConfigClass, self);
		}
			
		// Check if configuration container was created.
		if (xConf == none) {
			control.nscLog(control.lng.format(control.lng.pluginConfigFailedMsg, class'NexgenUtil'.static.getObjectPackage(self)));
			return false; 
		}
		
		// Install plugin configuration.
		xConf.xControl = self;
		xConf.install();
		
		// Validate plugin configuration.
		if (!xConf.validate()) {
			control.nscLog(control.lng.format(control.lng.pluginConfigRepairedMsg, class'NexgenUtil'.static.getObjectPackage(self)));
			xConf.saveConfig();
		}
	}
	
	// Load shared data containers.
	createSharedDataContainers();
	
	// Load shared data.
	dataSyncMgr.loadSharedData();
	
	// Plugin has successfully initialized.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a new client has been created. Use this function to setup the new
 *                client with your own extensions (in order to support the plugin).
 *  $PARAM        client  The client that was just created.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function clientCreated(NexgenClient client) {
	local NexgenExtendedClientController xClient;
	
	xClient = NexgenExtendedClientController(client.addController(clientControllerClass, self));
	xClient.dataSyncMgr = dataSyncMgr;
	xClient.xControl = self;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a client has finished its initialisation process. During this
 *                process things such as the remote control window are created. So only after the
 *                client is fully initialized all functions can be safely called.
 *  $PARAM        client  The client that has finished initializing.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function clientInitialized(NexgenClient client) {
	local NexgenExtendedClientController xClient;
	
	// Get client controller.
	xClient = getXClient(client);
	
	// Initialize shared data for the client.
	if (xClient != none) {
		dataSyncMgr.initRemoteClient(xClient);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the client controller instance for the given actor. The actor may either
 *                be a PlayerPawn or a NexgenClient.
 *  $PARAM        a  The actor for which the client controller instance is to be found.
 *  $REQUIRE      a != none
 *  $RETURN       The client controller for the given actor.
 *
 **************************************************************************************************/
function NexgenExtendedClientController getXClient(Actor a) {
	local NexgenClient client;
	
	// Get Nexgen client handler.
	if (a.isA('NexgenClient')) {
		client = NexgenClient(a);
	} else {
		client = control.getClient(a);
	}
	
	// Get client controllor for the Nexgen client handler.
	if (client == none) {
		return none;
	} else {
		return NexgenExtendedClientController(client.getController(clientControllerClass.default.ctrlID));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the plugin requires the to shared data containers to be created. These
 *                may only be created / added to the shared data synchronization manager inside this
 *                function. Once created they may not be destroyed until the current map unloads.
 *
 **************************************************************************************************/
function createSharedDataContainers() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $PARAM        author           Object that was responsible for the change.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *
 **************************************************************************************************/
function varChanged(NexgenSharedDataContainer container, string varName, optional int index, optional Object author) {
	// To implement in subclass.
}