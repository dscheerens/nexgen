/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCMain
 *  $VERSION      1.03 (21-02-2010 18:53)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen Mod Config Tool plugin.
 *
 **************************************************************************************************/
class NMCMain extends NexgenPlugin;

var NMCLang lng;                        // Language instance to support localization.
var NMCModConfigContainer cfgContainer; // The local (server side) config container.
var NMCCommandHandler cmdHandler;       // Handles the execution of commands.
var NMCDeferredUpdateHandler updates;   // Handler for deferred mod configuration updates.

const SYSTEM_NAME = 'ModConfigTool';    // Mods that want to use this plugin should search for this.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {
	local NMCModConfigContainerServer cfgContainer;
	
	// Load localization support.
	lng = spawn(class'NMCLang');
	lng.control = self.control;
	
	// Create mod configuration container.
	cfgContainer = spawn(class'NMCModConfigContainerServer', self);
	cfgContainer.xControl = self;
	cfgContainer.lng = self.lng;
	self.cfgContainer = cfgContainer;
	
	// Create command handler.
	cmdHandler = spawn(class'NMCCommandHandlerServer', self);
	cmdHandler.cfgContainer = cfgContainer;
	cmdHandler.lng = lng;
	
	// Create update handler & check for deferred updates.
	updates = spawn(class'NMCDeferredUpdateHandler', self);
	updates.cfgContainer = cfgContainer;
	if (updates.numUpdates > 0) {
		lng.nmcLog(lng.foundUpdatesMsg);
		updates.applyUpdates();
	}
	
	// Set tag (system name) so it can be located by other mods.
	tag = SYSTEM_NAME;
	
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
	local NMCClient xClient;
	xClient = NMCClient(client.addController(class'NMCClient', self));
	xClient.cfgContainer = cfgContainer;
	xClient.cmdHandler = cmdHandler;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Command interface function. This function accepts commands and executes them.
 *  $PARAM        cmd  The command that is to be executed.
 *  $REQUIRE      cmd != ""
 *  $RETURN       The result of the command that was executed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getItemName(string cmd) {
	return cmdHandler.execCommand(self, cmd);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a mod configuration value has changed.
 *  $PARAM        modConfigVar  The variable whose value was changed.
 *  $REQUIRE      modConfigVar != none
 *
 **************************************************************************************************/
function modConfigVarChanged(NMCModConfigVar modConfigVar) {
	local NexgenClient client;
	local NMCClient xClient;
	
	// Store update.
	updates.addUpdateFromVar(modConfigVar);
	
	// Notify clients.
	for (client = control.clientList; client != none; client = client.nextClient) {
		xClient = NMCClient(client.getController(class'NMCClient'.default.ctrlID));
		if (xClient != none && xClient.bModDefRequested) {
			xClient.sendStr(cfgContainer.CMD_SET_VAL
		                    @ class'NexgenUtil'.static.formatCmdArg(modConfigVar.modConfig.modID)
		                    @ class'NexgenUtil'.static.formatCmdArg(cfgContainer.netType2Str(modConfigVar.netType))
		                    @ class'NexgenUtil'.static.formatCmdArg(modConfigVar.className)
		                    @ class'NexgenUtil'.static.formatCmdArg(modConfigVar.varName)
		                    @ class'NexgenUtil'.static.formatCmdArg(modConfigVar.serialValue));
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the NMCClient instance for the given actor.
 *  $PARAM        a  The actor for which the extended client handler instance is to be found.
 *  $REQUIRE      a != none
 *  $RETURN       The client handler for the given actor.
 *  $ENSURE       (!a.isA('PlayerPawn') ? result == none : true) &&
 *                imply(result != none, result.client.owner == a)
 *
 **************************************************************************************************/
function NMCClient getXClient(Actor a) {
	local NexgenClient client;
	
	client = control.getClient(a);
	
	if (client == none) {
		return none;
	} else {
		return NMCClient(client.getController(class'NMCClient'.default.ctrlID));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the server is about to perform a server travel. Note that the server
 *                travel may fail to switch to the desired map. In that case the server will
 *                continue running the current game or a second notifyBeforeLevelChange() call may
 *                occur when trying to switch to another map. So be carefull what you do in this
 *                function!!!
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notifyBeforeLevelChange() {
	// Apply deferred updates.
	if (updates.numUpdates > 0) {
		updates.applyUpdates();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	pluginName="Nexgen mod configuration tool"
	pluginAuthor="Zeropoint"
	pluginVersion="1.01 build 1022"
}

