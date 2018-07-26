/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenActor
 *  $VERSION      1.02 (17-11-2008 16:42)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  The Nexgen ServerActor. Execution of the Nexgen server controller starts in this
 *                class. New client connections are also detected in this class.
 *
 **************************************************************************************************/
class NexgenActor extends SpawnNotify;

var NexgenController serverController;  // Active Nexgen Server Controller.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a NexgenServer instance if called on the server.
 *
 **************************************************************************************************/
simulated function preBeginPlay() {
	if(role == ROLE_Authority) {
		serverController = spawn(class'NexgenController');
	}
}




/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the server controller that a new client has connected to the server.
 *  $PARAM        a  Newly spawned actor.
 *  $REQUIRE      a != none
 *
 **************************************************************************************************/
simulated function Actor spawnNotification(Actor a) {
	if (a.isA('PlayerPawn') &&
	    !a.isA('MessagingSpectator') &&
	    serverController != none) {
		serverController.newClient(PlayerPawn(a));
	}
	return a;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
    actorClass=class'PlayerPawn'
    bAlwaysRelevant=false
    bNetTemporary=false
}