/***************************************************************************************************
 *
 *  NXACE. Nexgen ACE plugin by Zeropoint.
 *
 *  $CLASS        NXACEClient
 *  $VERSION      1.00 (14-07-2010 23:01)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen ACE client controller.
 *
 **************************************************************************************************/
class NXACEClient extends NexgenClientController;

var Actor aceClient;                              // The ACE client interface.
var bool bLoginEnabled;                           // Whether login has been enabled for the client.
var bool bUsingWine;                              // Whether the player is running UT in Wine.
var float aceClientCheckTimer;                    // Timer for locating the ACE client interface.
var string hardwareID;                            // The hardware ID of the client.

// Settings.
const aceClientCheckFrequency = 1;                // Frequency of locating the ACE client interface.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {
	reliable if (role == ROLE_Authority) // Replicate to client...
		setLoginInfo;

}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function. Called when the game performs its next tick.
 *                The following actions are performed:
 *                 - Locate the ACE client interface for this client.
 *                 - Check if the ACE hardware GUID for the client is available.
 *  $PARAM        delta  Time elapsed (in seconds) since the last tick.
 *  $OVERRIDE     
 *
 **************************************************************************************************/
simulated function tick(float deltaTime) {
	local string temp;
	
	// Execute server side actions.
	if (role == ROLE_Authority) {
		
		// Locate ACE client.
		if (aceClient == none && !client.bSpectator) {
			aceClientCheckTimer += deltaTime / level.timeDilation;
			if (aceClientCheckTimer >= (1.0 / aceClientCheckFrequency)) {
				aceClientCheckTimer = 0;
				locateACEClientInterface();
			}
		}
		
		// Enable client login if allowed.
		if (!bLoginEnabled && aceClient != none) {

			if (aceClient.getPropertyText("bWine") ~= string(true)) {
				bUsingWine = true;
				enableLogin();
			} else if (aceClient.getPropertyText("hwHash") != "") {
				hardwareID = aceClient.getPropertyText("hwHash");
				class'NexgenUtil'.static.split2(hardwareID, temp, hardwareID, ":");			
				enableLogin(hardwareID);
			}
		}
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attemps to locate the ACE client interface for this client controller. Once the
 *                client interface is found the variable aceClient will not be null.
 *
 **************************************************************************************************/
function locateACEClientInterface() {
	local Actor a;
	
	foreach allActors(class'Actor', a) {
		if (a.owner == client.owner && class'NexgenUtil'.static.getObjectClassName(a) ~= "ACEReplicationInfo") {
			aceClient = a;
			break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Enables the login procedure for the client.
 *  $PARAM        hardwareID  The hardware GUID that will be used as the players client ID.
 *
 **************************************************************************************************/
function enableLogin(optional string hardwareID) {
	bLoginEnabled = true;
	setLoginInfo(control.sConf.serverID, hardwareID);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the login information for the client.
 *  $PARAM        serverID    The public server identifier.
 *  $PARAM        hardwareID  The hardware GUID that will be used as the players client ID.
 *  $REQUIRE      serverID != ""
 *
 **************************************************************************************************/
simulated function setLoginInfo(string serverID, string hardwareID) {
	client.serverID = serverID;
	self.hardwareID = hardwareID;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	ctrlID="nexgen_ace_client"
	bAlwaysTick=true
}