/***************************************************************************************************
 *
 *  NXACE. Nexgen ACE plugin by Zeropoint.
 *
 *  $CLASS        NXACEMain
 *  $VERSION      1.01 (14-07-2010 23:01)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen ACE plugin.
 *
 **************************************************************************************************/
class NXACEMain extends NexgenPlugin;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {
	// Override client login handler class.
	control.loginHandler = class'NXACEClientLoginHandler';
	
	// Initialization successful.
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
	local NXACEClient xClient;
	
	// Disable client login initiative, except for spectators which aren't checked by ACE.
	if (!client.owner.isA('Spectator')) {
		client.serverID = "";
	}
	
	// Create client controller.
	xClient = NXACEClient(client.addController(class'NXACEClient', self));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	pluginName="Nexgen ACE plugin"
	pluginAuthor="Zeropoint"
	pluginVersion="1.12-0.8 build 1004"
}