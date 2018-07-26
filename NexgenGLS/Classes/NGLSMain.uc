/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSMain
 *  $VERSION      1.07 (20-11-2008 16:22)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  The global login system plugin.
 *
 **************************************************************************************************/
class NGLSMain extends NexgenPlugin;

var NGLSLang lng;                       // Language instance to support localization.
var NGLSConfig xConf;                   // Plugin configuration.

var int versionNum;                     // Plugin version number.

var string packageName;                 // Name of the NGLS plugin package.

var string gameID;                      // Identifier string for the current game.

const gameIDChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const gameIDLength = 8;



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
	lng = spawn(class'NGLSLang');
	
	// Load settings.
	if (control.bUseExternalConfig) {
		xConf = spawn(class'NGLSConfigExt', self);
	} else {
		xConf = spawn(class'NGLSConfigSys', self);
	}
	xConf.install();
	if (!xConf.validate()) {
		nglsLog(lng.invalidConfigMsg);
	}
	xConf.initialize();
	
	// Set game ID.
	setGameID();
	
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
	local NGLSClient xClient;
	
	xClient = NGLSClient(client.addController(class'NGLSClient', self));
	
	xClient.xConf = xConf;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the clients that a certain part of the server configuration has changed.
 *  $PARAM        configType  Type of settings that have been changed.
 *  $ENSURE       new.xConf.updateCount = old.xConf.updateCount + 1
 *
 **************************************************************************************************/
function signalConfigUpdate(byte configType) {
	local NexgenClient client;
	local NGLSClient xClient;
	local int index;
	
	// Set update counter.
	xConf.updateCounts[configType]++;
	
	// Update checksum.
	xConf.updateChecksum(configType);
	
	// Notify clients.
	for (client = control.clientList; client != none; client = client.nextClient) {
		xClient = NGLSClient(client.getController(class'NGLSClient'.default.ctrlID));
		if (xClient != none) {
			xClient.xConfigChanged(configType, xConf.updateCounts[configType], xConf.dynamicChecksums[configType]);
		}
	}
	
	// Notify plugins.
	while (index < arrayCount(control.plugins) && control.plugins[index] != none) {
		control.plugins[index].notifyEvent(xConf.EVENT_NexgenGLSConfigChanged, string(configType));
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the identifier for the current game.
 *
 **************************************************************************************************/
function setGameID() {
	local int index;
	
	gameID = "";
	for (index = 0; index < gameIDLength; index++) {
		gameID = gameID $ mid(gameIDChars, rand(len(gameIDChars)), 1);
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
	local NexgenClient client;
	
	cmd = class'NexgenUtil'.static.trim(msg);
	bIsCommand = true;
	switch (cmd) {
		case "!login":
			if (xConf.enableNGLS) {
				client = control.getClient(sender);
				if (client != none) {
					client.showPopup(packageName $ ".NGLSLoginDialog", string(true), xConf.registerURL);
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
 *  $DESCRIPTION  Retrieves the NGLSClient with the specified player code.
 *  $PARAM        playerNum  The player code of the client handler instance that is to be found.
 *  $REQUIRE      playerNum >= 0
 *  $RETURN       The client handler for the given player code.
 *  $ENSURE       imply(result != none, result.client.playerNum == playerNum)
 *
 **************************************************************************************************/
function NGLSClient getClientByNum(int playerNum) {
	local NexgenClient client;
	local NGLSClient xClient;
	
	client = control.getClientByNum(playerNum);
	if (client != none) {
		xClient = NGLSClient(client.getController(class'NGLSClient'.default.ctrlID));
	}
	
	return xClient;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locates the NGLSClient instance for the given actor.
 *  $PARAM        a  The actor for which the extended client handler instance is to be found.
 *  $REQUIRE      a != none
 *  $RETURN       The client handler for the given actor.
 *  $ENSURE       (!a.isA('PlayerPawn') ? result == none : true) &&
 *                imply(result != none, result.client.owner == a)
 *
 **************************************************************************************************/
function NGLSClient getXClient(Actor a) {
	local NexgenClient client;
	
	client = control.getClient(a);
	
	if (client == none) {
		return none;
	} else {
		return NGLSClient(client.getController(class'NGLSClient'.default.ctrlID));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Logs the given message.
 *  $PARAM        msg      Message that should be written to the log.
 *
 **************************************************************************************************/
function nglsLog(coerce string msg) {
	control.nscLog(lng.nglsLogTag @ msg);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	pluginName="Nexgen global login system"
	pluginAuthor="Zeropoint"
	pluginVersion="1.06 build 1014"
	versionNum=106
	packageName="NexgenGLS106"
}