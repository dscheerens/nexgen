/***************************************************************************************************
 *
 *  IGSRVEXT. IG Generation 3 server extension by Zeropoint.
 *
 *  $CLASS        IGSXClient
 *  $VERSION      1.03 (6-12-2008 14:56)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  IG Server extension pack client controller class. This class is the base of the
 *                clientside support for the extension plugin.
 *
 **************************************************************************************************/
class IGSXClient extends NexgenClientController;

var float lastKillTime;       // Last time this player killed another player.
var int multiLevel;           // Number of kills on a short time.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated event postNetBeginPlay() {
	super.postNetBeginPlay();
	
	if (!bNetOwner) {
		destroy();
	} else {
		spawn(class'IGSXHud', self);
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the NexgenClient has received its initial replication info is has
 *                been initialized. At this point it's safe to use all functions of the client.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function clientInitialized() {
	local SmartCTFPlayerReplicationInfo pri;
	
	// Enable SmartCTF scoreboard by default.
	foreach allActors(class'SmartCTFPlayerReplicationInfo', pri) {
		if (pri.owner == client.player.playerReplicationInfo) {
			pri.bViewingStats = true;
			break;
		}
	}
	
	// Add snow HUD.
	if (level.month == 1 || level.month == 12) {
		client.addHUDExtension(spawn(class'IGSXSnowHUD', self));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	ctrlID="IGClientExtension"
}