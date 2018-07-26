/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXPlayerOverlay
 *  $VERSION      1.00 (23-11-2007 19:01)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Player overlay skin effect.
 *
 **************************************************************************************************/
class NexgenXPlayerOverlay extends Effects;

#exec TEXTURE IMPORT NAME=overlaySkinRed     FILE=Resources\RedSkin.pcx     GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=overlaySkinBlue    FILE=Resources\BlueSkin.pcx    GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=overlaySkinGreen   FILE=Resources\GreenSkin.pcx   GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=overlaySkinGold    FILE=Resources\GoldSkin.pcx    GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=overlaySkinSilver  FILE=Resources\SilverSkin.pcx  GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=overlaySkinARed    FILE=Resources\RedSkinA.pcx    GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=overlaySkinABlue   FILE=Resources\BlueSkinA.pcx   GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=overlaySkinAGreen  FILE=Resources\GreenSkinA.pcx  GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=overlaySkinAGold   FILE=Resources\GoldSkinA.pcx   GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=overlaySkinASilver FILE=Resources\SilverSkinA.pcx GROUP="GFX" FLAGS=2 MIPS=OFF

var NexgenClient client;                // The NexgenClient instance of the player.
var bool bActivated;                    // Whether the overlay skin is activated.
var int teamNum;                        // Current team number of the player owning this instance.

const activatedAmbientGlow = 64;        // AmbientGlow when activated.
const activatedFatness = 145;           // Fatness when activated.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the player overlay skin.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	if (PlayerPawn(owner) == none) {
		destroy();
		return;
	}
	mesh = owner.mesh;
	drawScale = owner.drawscale;
	setSkin();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Global world tick.
 *  $PARAM        deltaTime  Time elapsed since last tick.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	local bool bClientProtected;
	
	// Hide / show player overlay skin?
	if (!bHidden && client.player.health <= 0) {
		// Hide overlay skin.
		bHidden = true;
	}
	if (bHidden && client.player.health > 0) {
		// Show overlay skin.
		bHidden = false;
	}
	
	// Activate / deactivate player overlay skin?
	bClientProtected = client.spawnProtectionTimeX > 0 ||
	                   client.tkDmgProtectionTimeX > 0 ||
	                   client.tkPushProtectionTimeX > 0;
	if (!bActivated && bClientProtected) {
		// Activate overlay skin.
		ambientGlow = activatedAmbientGlow;
		fatness = activatedFatness;
		bActivated = true;
		setSkin();
	}
	if (bActivated && !bClientProtected) {
		// Deactivate overlay skin.
		ambientGlow = default.ambientGlow;
		fatness = default.fatness;
		bActivated = false;
		setSkin();
	}
	
	// Team changed?
	if (owner != none && PlayerPawn(owner).playerReplicationInfo.team != teamNum) {
		setSkin();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the skin.
 *  $ENSURE       teamNum == PlayerPawn(owner).playerReplicationInfo.team
 *
 **************************************************************************************************/
function setSkin() {
	teamNum = PlayerPawn(owner).playerReplicationInfo.team;
	
	if (bActivated) {
		// Activated overlay skins.
		switch (teamNum) {
			case 0:  texture = Texture'overlaySkinARed';   break;
			case 1:  texture = Texture'overlaySkinABlue';  break;
			case 2:  texture = Texture'overlaySkinAGreen'; break;
			case 3:  texture = Texture'overlaySkinAGold';  break;
			default: texture = Texture'overlaySkinASilver';
		}
		
	} else {
		// Normal overlay skins.
		switch (teamNum) {
			case 0:  texture = Texture'overlaySkinRed';   break;
			case 1:  texture = Texture'overlaySkinBlue';  break;
			case 2:  texture = Texture'overlaySkinGreen'; break;
			case 3:  texture = Texture'overlaySkinGold';  break;
			default: texture = Texture'overlaySkinSilver';
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	remoteRole=ROLE_SimulatedProxy
	bOwnerNoSee=true
	bNetTemporary=false
	drawType=DT_Mesh
	bAnimByOwner=true
	bHidden=false
	bMeshEnviroMap=true
	fatness=128
	style=STY_Translucent
	drawScale=1.0
	scaleGlow=0.1
	ambientGlow=16
	bUnlit=true
	physics=PHYS_Trailer
	bTrailerSameRotation=true
}
