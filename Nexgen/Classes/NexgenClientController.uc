/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenClientController
 *  $VERSION      1.07 (29-07-2010 15:54)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Client controller class. Multiple client controller can be hooked onto a
 *                NexgenClient instance in order to have client side control. This class is used to
 *                support plugins for the Nexgen server controller system.
 *
 **************************************************************************************************/
class NexgenClientController extends Info abstract;

var string ctrlID;                      // Identifier for this controller.
var NexgenClient client;                // The client to which this controller is linked.
var NexgenController control;           // Nexgen controller.
var bool bCanModifyHUDStatePanel;       // Whether it can modify the client and server state panels
                                        // in the Nexgen HUD.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

	reliable if (role == ROLE_Authority) // Replicate to client...
		client;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated event postNetBeginPlay() {
	// Check if we're the net owner. The client controller appears to be replicated to other players
	// that view the player owning this controller, which makes sense if you think about it. However
	// this is not desirable as the client controller is meant for only one client, so kill this
	// instance if we're not the owner (i.e. we're viewing another player).
	if (bNetOwner) {
		super.postNetBeginPlay();
	} else {
		destroy();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller. This function is automatically called after
 *                the critical variables have been set, such as the client variable.
 *  $PARAM        creator  The Actor that has added the controller to the client.
 *
 **************************************************************************************************/
function initialize(optional Actor creator) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the NexgenClient has received its initial replication info is has
 *                been initialized. At this point it's safe to use all functions of the client.
 *
 **************************************************************************************************/
simulated function clientInitialized() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Modifies the setup of the Nexgen remote control panel.
 *
 **************************************************************************************************/
simulated function setupControlPanel() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies this panel that the server configuration has been updated.
 *  $PARAM        configType  Type of settings that have been changed.
 *
 **************************************************************************************************/
simulated function configChanged(byte configType) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies this panel that the extended game info has been updated.
 *  $PARAM        infoType  Type of information that has been changed.
 *
 **************************************************************************************************/
simulated function gameInfoChanged(byte infoType) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client of a player event. Additional arguments to the event should be
 *                combined into one string which then can be send along with the playerEvent call.
 *  $PARAM        playerNum  Player identification number.
 *  $PARAM        eventType  Type of event that has occurred.
 *  $PARAM        args       Optional arguments.
 *  $REQUIRE      playerNum >= 0
 *
 **************************************************************************************************/
simulated function playerEvent(int playerNum, string eventType, optional string args) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Modifies the client state panel on the Nexgen HUD.
 *  $PARAM        stateType  State type identifier.
 *  $PARAM        text       Text to display on the state panel.
 *  $PARAM        textColor  Color of the text to display.
 *  $PARAM        icon       State icon. The icon is displayed in front of the text.
 *  $PARAM        solidIcon  Solid version of the icon (masked, no transparency).
 *  $PARAM        bBlink     Whether the text on the panel should blink.
 *
 **************************************************************************************************/
simulated function modifyClientState(out name stateType, out string text, out Color textColor, 
                                     out Texture icon, out Texture solidIcon, out byte bBlink) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Modifies the client state panel on the Nexgen HUD.
 *  $PARAM        stateType  State type identifier.
 *  $PARAM        text       Text to display on the state panel.
 *  $PARAM        textColor  Color of the text to display.
 *  $PARAM        icon       State icon. The icon is displayed in front of the text.
 *  $PARAM        solidIcon  Solid version of the icon (masked, no transparency).
 *  $PARAM        bBlink     Whether the text on the panel should blink.
 *
 **************************************************************************************************/
simulated function modifyServerState(out name stateType, out string text, out Color textColor, 
                                     out Texture icon, out Texture solidIcon, out byte bBlink) {
	// To implement in subclass.
}




/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *
 **************************************************************************************************/
simulated function notifyEvent(string type, optional string arguments) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the client is ready to initialize. 
 *  $RETURN       True if the client is ready to initialize, false if not.
 *
 **************************************************************************************************/
simulated function bool isReadyToInitialize() {
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Wrapper function for NexgenController.logAdminAction().
 *  $PARAM        msg                Message that describes the action performed by the administrator.
 *  $PARAM        str1               Message specific content.
 *  $PARAM        str2               Message specific content.
 *  $PARAM        str3               Message specific content.
 *  $PARAM        bNoBroadcast       Whether not to broadcast this administrator action.
 *  $PARAM        bServerAdminsOnly  Broadcast message only to administrators with the server admin
 *                                   privilege.
 *
 **************************************************************************************************/
function logAdminAction(string msg, optional coerce string str1, optional coerce string str2,
                        optional coerce string str3, optional bool bNoBroadcast,
                        optional bool bServerAdminsOnly) {
	control.logAdminAction(client, msg, client.playerName, str1, str2, str3,
	                       client.player.playerReplicationInfo, bNoBroadcast, bServerAdminsOnly);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	remoteRole=ROLE_SimulatedProxy
	netPriority=1.5
	netUpdateFrequency=4.0
	bCanModifyHUDStatePanel=false
}