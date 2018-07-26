/***************************************************************************************************
 *
 *  NXACE. Nexgen ACE plugin by Zeropoint.
 *
 *  $CLASS        NXACEClientLoginHandler
 *  $VERSION      1.00 (15-07-2010 00:07)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Login handler for the hardware GUID provided by ACE.
 *
 **************************************************************************************************/
class NXACEClientLoginHandler extends NexgenClientLoginHandler abstract;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the login parameters for the specified client.
 *  $PARAM        client        The Nexgen client whose login parameters are to be retrieved.
 *  $PARAM        clientID      Unique client identifier GUID.
 *  $PARAM        loginOptions  Extra login parameters.
 *  $OVERRIDE
 *
 **************************************************************************************************/
static function getLoginParameters(NexgenClient client, out string clientID, out string loginOptions) {
	local string clientKey;
	local string password;
	local NXACEClient xClient;
	
	
	// Retrieve Nexgen ACE client controller.
	xClient = NXACEClient(client.getController(class'NXACEClient'.default.ctrlID));
	
	// Set client ID.
	clientID = xClient.hardwareID;
	if (clientID == "") {
		// Load client key.
		clientKey = client.gc.get(client.SSTR_ClientKey);
		clientID = client.gc.get(client.SSTR_ClientID);
		if (clientKey == "" || class'MD5Hash'.static.MD5String(clientKey) != clientID) {
			// Client has no key. Create a new one.
			clientKey = class'NexgenUtil'.static.makeKey();
			clientID = class'MD5Hash'.static.MD5String(clientKey);
			client.gc.set(client.SSTR_ClientKey, clientKey);
			client.gc.set(client.SSTR_ClientID, clientID);
			client.gc.saveConfig();
			
		}
	}
	
	// Load login info.
	password = client.sc.get(client.serverID, client.SSTR_ServerPassword);
	
	// Set login options.
	if (password != "") class'NexgenUtil'.static.addProperty(loginOptions, client.SSTR_ServerPassword, password);
	if (clientKey != "") class'NexgenUtil'.static.addProperty(loginOptions, client.SSTR_ClientKey, clientKey);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the login parameters send by the client.
 *  $PARAM        client  The Nexgen client whose login parameters are to be checked.
 *
 **************************************************************************************************/
static function bool checkLoginParameters(NexgenClient client) {
	local NXACEClient xClient;
	local bool bLoginParametersValid;
	local string clientKey;

	// Retrieve Nexgen ACE client controller.
	xClient = NXACEClient(client.getController(class'NXACEClient'.default.ctrlID));
	
	// Check for spectators or Wine users.
	if (client.owner.isA('Spectator') || xClient.bUsingWine) {
		// Check client ID.
		bLoginParametersValid = class'NexgenUtil'.static.isValidClientID(client.playerID);
		
		// Check client key.
		if (bLoginParametersValid) {
			clientKey = class'NexgenUtil'.static.getProperty(client.loginOptions, client.SSTR_ClientKey);
			bLoginParametersValid = class'NexgenUtil'.static.isValidKey(clientKey);
		}
		
		// Check client ID / key match.
		if (bLoginParametersValid) {
			bLoginParametersValid = (class'MD5Hash'.static.MD5String(clientKey) == client.playerID);
		}
		
	} else {	
		// Check if received client ID matches hardware ID.
		bLoginParametersValid = (
			xClient != none &&
			client.playerID == xClient.hardwareID &&
			class'NexgenUtil'.static.isValidClientID(client.playerID)
		);
	}
	
	// Return result.
	return bLoginParametersValid;
}