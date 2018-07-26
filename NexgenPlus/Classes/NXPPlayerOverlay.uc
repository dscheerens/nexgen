/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPPlayerOverlay
 *  $VERSION      1.00 (01-08-2010 00:01)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Player overlay skin effect.
 *
 **************************************************************************************************/
class NXPPlayerOverlay extends Effects;

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

var NXPClient xClient;                  // The client controllor for the player.

// States.
var byte currentState;                  // Current appearance state of the overlay skin.
const STATE_HIDDEN = 0;                 // Overlay is hidden.
const STATE_SHIELD = 1;                 // Overlay acts as a shield around the player.
const STATE_GLOW = 2;                   // Overlay creates a team colored glow on the players skin.



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
	setState(STATE_GLOW);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function. Called when the game performs its next tick.
 *                The following actions are performed:
 *                 - Check if the appearance of the overlay skin should be changed.
 *  $PARAM        delta  Time elapsed (in seconds) since the last tick.
 *  $OVERRIDE     
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	local byte desiredState;
	
	// Update appearance state if necessary.
	desiredState = getDesiredState();
	if (desiredState != currentState) {
		setState(desiredState);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the desired appearance state for the overlay skin.
 *  $RETURN       The ID of the desired appearance state.
 *  $ENSURE       result == STATE_HIDDEN || result == STATE_SHIELD || result == STATE_GLOW
 *
 **************************************************************************************************/
function byte getDesiredState() {
	// Check if overlay should be hidden.
	if (   PlayerPawn(owner) == none
	    || PlayerPawn(owner).playerReplicationInfo == none
	    || PlayerPawn(owner).playerReplicationInfo.bIsSpectator
	    || PlayerPawn(owner).playerReplicationInfo.bWaitingPlayer
	    || PlayerPawn(owner).health <= 0
	) {
		return STATE_HIDDEN;
	}
	
	// Check if should overlay should be enabled.
	if (    NXPConfig(xClient.xControl.xConf).showDamageProtectionShield
	    && (xClient.client.spawnProtectionTimeX > 0
	    ||  xClient.client.tkDmgProtectionTimeX > 0
	    ||  xClient.client.tkPushProtectionTimeX > 0)
	) {
		return STATE_SHIELD;
	}
	
	// Check if colorized glow overlay shoudl be enabled.
	if (NXPConfig(xClient.xControl.xConf).colorizePlayerSkins) {
		return STATE_GLOW;
	}
	
	// If non of the above conditions is true the overlay should be hidden.
	return STATE_HIDDEN;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the appearance state of the overlay skin.
 *  $PARAM        stateID  The new appearance state for the overlay skin
 *  $REQUIRE      stateID == STATE_HIDDEN || stateID == STATE_SHIELD || stateID == STATE_GLOW
 *  $ENSURE       new.currentSate == stateID
 *
 **************************************************************************************************/
function setState(byte stateID) {
	local int teamNum;
	
	// Update state.
	currentState = stateID;
	
	// Get players team.
	teamNum = PlayerPawn(owner).playerReplicationInfo.team;
	
	// Update appearance.
	switch (stateID) {
		case STATE_HIDDEN:
			bHidden = true;
			break;
			
		case STATE_SHIELD:
			bHidden = false;
			ambientGlow = 64;
			fatness = 145;
			switch (teamNum) {
				case 0:  texture = Texture'overlaySkinARed';   break;
				case 1:  texture = Texture'overlaySkinABlue';  break;
				case 2:  texture = Texture'overlaySkinAGreen'; break;
				case 3:  texture = Texture'overlaySkinAGold';  break;
				default: texture = Texture'overlaySkinASilver';
			}
			break;
			
		case STATE_GLOW:
			bHidden = false;
			ambientGlow = 16;
			fatness = 128;
			switch (teamNum) {
				case 0:  texture = Texture'overlaySkinRed';   break;
				case 1:  texture = Texture'overlaySkinBlue';  break;
				case 2:  texture = Texture'overlaySkinGreen'; break;
				case 3:  texture = Texture'overlaySkinGold';  break;
				default: texture = Texture'overlaySkinSilver';
			}
			break;
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