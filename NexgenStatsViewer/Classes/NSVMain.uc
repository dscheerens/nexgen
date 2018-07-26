/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $CLASS        NSVMain
 *  $VERSION      1.04 (10-8-2008 11:17)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen Statistics Viewer plugin.
 *
 **************************************************************************************************/
class NSVMain extends NexgenPlugin;

var NSVLang lng;                        // Language localization support.
var NSVConfig conf;                     // Configuration.
var NSVReplicationInfo statsRI;         // Statistics replication info.

var int versionNum;                     // Plugin version number.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {
	
	// Load localization support.
	lng = spawn(class'NSVLang', self);
	
	// Load settings.
	if (control.bUseExternalConfig) {
		conf = spawn(class'NSVConfigExt', self);
	} else {
		conf = spawn(class'NSVConfigSys', self);
	}
	conf.install();
	if (!conf.validate()) {
		control.nscLog(lng.invalidConfigMsg);
	}
	conf.initialize();
	
	// Load replication info.
	statsRI = spawn(class'NSVReplicationInfo', self);
	
	// Load UTStats client.
	if (conf.enableUTStatsClient && class'NexgenUtil'.static.trim(conf.utStatsHost) != "") {
		spawn(class'NSVUTStatsClient');
	}
	
	// Initialization complete.
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
	local NSVClient xClient;
	
	xClient = NSVClient(client.addController(class'NSVClient', self));
	
	xClient.conf = conf;
	xClient.statsRI = statsRI;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the clients that a certain part of the server configuration has changed.
 *  $PARAM        configType  Type of settings that have been changed.
 *  $ENSURE       new.conf.updateCounts[configType] = old.conf.updateCounts[configType] + 1
 *
 **************************************************************************************************/
function signalConfigUpdate(byte configType) {
	local NexgenClient client;
	local NSVClient xClient;
	local int index;
	
	// Set update counter.
	conf.updateCounts[configType]++;
	
	// Update checksum.
	conf.updateChecksum(configType);
	
	// Notify clients.
	for (client = control.clientList; client != none; client = client.nextClient) {
		xClient = NSVClient(client.getController(class'NSVClient'.default.ctrlID));
		if (xClient != none) {
			xClient.nexgenStatsViewerConfigChanged(configType, conf.updateCounts[configType], conf.dynamicChecksums[configType]);
		}
	}
	
	// Notify plugins.
	while (index < arrayCount(control.plugins) && control.plugins[index] != none) {
		control.plugins[index].notifyEvent(conf.EVENT_NexgenStatsViewerConfigChanged, string(configType));
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles a potential command message.
 *  $PARAM        sender  PlayerPawn that has send the message in question.
 *  $PARAM        msg     Message send by the player, which could be a command.
 *  $REQUIRE      sender != none
 *  $RETURN       True if the specified message is a command, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool handleMsgCommand(PlayerPawn sender, string msg) {
	local string cmd;
	local bool bIsCommand;
	local NSVClient xClient;
	
	cmd = class'NexgenUtil'.static.trim(msg);
	bIsCommand = true;
	switch (cmd) {
		case "!nscstats":
			if (conf.enableUTStatsClient) {
				xClient = getXClient(sender);
				if (xClient != none) {
					xClient.showStats();
				}
			}
			break;

		// Not a command.
		default: bIsCommand = false;
	}
	
	return bIsCommand;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the NSVClient instance for the given actor.
 *  $PARAM        a  The actor for which the extended client handler instance is to be found.
 *  $REQUIRE      a != none
 *  $RETURN       The client handler for the given actor.
 *  $ENSURE       (!a.isA('PlayerPawn') ? result == none : true) &&
 *                imply(result != none, result.client.owner == a)
 *
 **************************************************************************************************/
function NSVClient getXClient(Actor a) {
	local NexgenClient client;
	
	client = control.getClient(a);
	
	if (client == none) {
		return none;
	} else {
		return NSVClient(client.getController(class'NSVClient'.default.ctrlID));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	pluginName="Nexgen stats viewer"
	pluginAuthor="Zeropoint"
	pluginVersion="1.05 build 1014"
	versionNum=105
}

