/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenClientLoginHandler
 *  $VERSION      1.01 (2-8-2008 14:12)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Default login handler for the Nexgen Server Controller.
 *
 **************************************************************************************************/
class NexgenClientLoginHandler extends Object abstract;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the login parameters for the specified client.
 *  $PARAM        client        The Nexgen client whose login parameters are to be retrieved.
 *  $PARAM        clientID      Unique client identifier GUID.
 *  $PARAM        loginOptions  Extra login parameters.
 *
 **************************************************************************************************/
static function getLoginParameters(NexgenClient client, out string clientID, out string loginOptions) {
	local string clientKey;
	local string password;
	
	// Load client key.
	clientKey = client.gc.get(client.SSTR_ClientKey);
	clientID = client.gc.get(client.SSTR_ClientID);
	if (clientKey == "") {
		// Client has no key. Create a new one.
		clientKey = class'NexgenUtil'.static.makeKey();
		clientID = class'MD5Hash'.static.MD5String(clientKey);
		client.gc.set(client.SSTR_ClientKey, clientKey);
		client.gc.set(client.SSTR_ClientID, clientID);
		client.gc.saveConfig();
		
	} else if (class'MD5Hash'.static.MD5String(clientKey) != clientID) {
		// KEY/ID mismatch. Reset key.
		clientKey = class'NexgenUtil'.static.makeKey();
		clientID = class'MD5Hash'.static.MD5String(clientKey);
		client.gc.set(client.SSTR_ClientKey, clientKey);
		client.gc.set(client.SSTR_ClientID, clientID);
		client.gc.saveConfig();
		
	}
	
	// Load login info.
	password = client.sc.get(client.serverID, client.SSTR_ServerPassword);
	
	// Set login options.
	if (password != "") class'NexgenUtil'.static.addProperty(loginOptions, client.SSTR_ServerPassword, password);
	class'NexgenUtil'.static.addProperty(loginOptions, client.SSTR_ClientKey, clientKey);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the login parameters send by the client.
 *  $PARAM        client        The Nexgen client whose login parameters are to be checked.
 *
 **************************************************************************************************/
static function bool checkLoginParameters(NexgenClient client) {
	local bool bLoginParametersValid;
	local string clientKey;
	
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
	
	// Return result.
	return bLoginParametersValid;
}

