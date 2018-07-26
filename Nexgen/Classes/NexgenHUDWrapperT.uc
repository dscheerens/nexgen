/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenHUDWrapperT
 *  $VERSION      1.04 (15-3-2009 13:21)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  HUD Wrapper class. Used to support the Nexgen HUD extensions, while still being
 *                able to view custom HUDs. Team game version.
 *
 **************************************************************************************************/
class NexgenHUDWrapperT extends ChallengeTeamHUD;

var ChallengeHUD originalHUD;           // Original HUD.
var NexgenClient client;                // The Nexgen Client
var NexgenHUD nscHUD;                   // The Nexgen HUD instance.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the HUD wrapper.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function postBeginPlay() {
	super.postBeginPlay();
	setTimer(0.0, false);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Prepares the system for the HUD render phase. Probably never used.
 *  $PARAM        c  The canvas object on which the rendering will be done.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated event preRender(Canvas c) {
	if (originalHUD != none) originalHUD.preRender(c);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the HUD. It will simply call the postRender() function of the original HUD
 *                and also calls the renderMessageBox() function on the NexgenHUD.
 *  $PARAM        c  The canvas object on which the rendering will be done.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated event postRender(Canvas c) {
	local Console cons;
	local bool bWasTyping;
	local NexgenClient client;
	
	// Get NexgenClient and NexgenHUD instances.
	if (client == none) {
		foreach allactors(class'NexgenClient', client) {
			if (client.owner != none && Viewport(PlayerPawn(client.owner).player) != none) {
				self.client = client;
				nscHUD = client.nscHUD;
				break;
			}
		}
	}
	
	// Spawn original HUD if not already done.
	if (originalHUD == none && client != none && client.gInf != none &&
	    client.gInf.originalHUDClass != none) {
		originalHUD = ChallengeHUD(spawn(client.gInf.originalHUDClass, self.owner));
	}
	
	// Nexgen HUD extension pre rendering.
	if (nscHUD != none) {
		nscHUD.preRenderHUD(c);
	}
	
	// Draw HUD.
	if (originalHUD == none) {
		super.postRender(c);
	} else {
		// Copy HUD settings to original HUD.
		copyVarsToOriginalHUD();
		
		// Save data & fool the original HUD.
		if (playerOwner != none && client.bUseNexgenMessageHUD) {
			cons = playerOwner.player.console;
			bWasTyping = cons.bTyping;
			cons.bTyping = false;
		}
		
		// Let the original HUD render it's stuff.
		originalHUD.postRender(c);
		
		// Restore data.
		if (playerOwner != none && client.bUseNexgenMessageHUD) {
			cons.bTyping = bWasTyping;
		}
		
		// Copy HUD settings from original HUD.
		copyVarsFromOriginalHUD();
	}
	
	// Nexgen HUD extension post rendering.
	if (nscHUD != none) {
		nscHUD.postRenderHUD(c);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Copies the relevant variables from the wrapper HUD to the original HUD.
 *
 **************************************************************************************************/
simulated function copyVarsToOriginalHUD() {
	local Mutator m, temp;
	
	// Check mutator chain of original HUD.
	m = originalHUD.hudMutator;
	while (m != none) {
		if (!hasHUDMutator(m)) {
			temp = m.nextHUDMutator;
			m.nextHUDMutator = hudMutator;
			hudMutator = m;
			m = temp;
		} else {
			m = m.nextHUDMutator;
		}
	}
	
	// Copy variables.
	originalHUD.bHideHUD         = bHideHUD;
	originalHUD.bHideAllWeapons  = bHideAllWeapons;
	originalHUD.bHideStatus      = bHideStatus;
	originalHUD.bHideAmmo        = bHideAmmo;
	originalHUD.bHideTeamInfo    = bHideTeamInfo;
	originalHUD.bHideFrags       = bHideFrags;
	originalHUD.bHideFaces       = bHideFaces;
	originalHUD.bUseTeamColor    = bUseTeamColor;
	originalHUD.opacity          = opacity;
	originalHUD.hudScale         = hudScale;
	originalHUD.weaponScale      = weaponScale;
	originalHUD.statusScale      = statusScale;
	originalHUD.favoriteHUDColor = favoriteHUDColor;
	originalHUD.crosshairColor   = CrosshairColor;
	originalHUD.hudMutator       = hudMutator;
	originalHUD.bForceScores     = bForceScores;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks if the HUD chains contains the specified HUDMutator.
 *  $PARAM        m  The mutator which is to be found.
 *  $PARAM        Return true if the HUDMutator was found.
 *
 **************************************************************************************************/
function bool hasHUDMutator(Mutator m) {
	local Mutator localM;
	local bool bFound;
	
	localM = hudMutator;
	while (!bFound && localM != none) {
		// if (localM == m) {
		if (localM.class == m.class) {
			bFound =  true;
		} else {
			localM = localM.nextHUDMutator;
		}
	}
	
	return bFound;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Copies the relevant variables from the original HUD to the wrapper HUD.
 *
 **************************************************************************************************/
simulated function copyVarsFromOriginalHUD() { 
	playerOwner         = originalHUD.playerOwner;
	MOTDFadeOutTime     = originalHUD.MOTDFadeOutTime;
	identifyFadeTime    = originalHUD.identifyFadeTime;
	identifyTarget      = originalHUD.identifyTarget;
	pawnOwner           = originalHUD.pawnOwner;
	myFonts             = originalHUD.myFonts;
	faceTexture         = originalHUD.faceTexture;
	faceTime            = originalHUD.faceTime;
	faceTeam            = originalHUD.faceTeam;
	playerCount         = originalHUD.playerCount;
	bTiedScore          = originalHUD.bTiedScore;
	lastReportedTime    = originalHUD.lastReportedTime;
	bStartUpMessage     = originalHUD.bStartUpMessage;
	bTimeValid          = originalHUD.bTimeValid;
	bLowRes             = originalHUD.bLowRes;
	bResChanged         = originalHUD.bResChanged;
	bAlwaysHideFrags    = originalHUD.bAlwaysHideFrags;
	bHideCenterMessages = originalHUD.bHideCenterMessages;
	scale               = originalHUD.scale;
	style               = originalHUD.style;
	baseColor           = originalHUD.baseColor;
	HUDColor            = originalHUD.HUDColor;
	solidHUDColor       = originalHUD.solidHUDColor;
	rank                = originalHUD.rank;
	lead                = originalHUD.lead;
	pickupTime          = originalHUD.pickupTime;
	weaponNameFade      = originalHUD.weaponNameFade;
	messageFadeTime     = originalHUD.messageFadeTime;
	messageFadeCount    = originalHUD.messageFadeCount;
	bDrawMessageArea    = originalHUD.bDrawMessageArea;
	bDrawFaceArea       = originalHUD.bDrawFaceArea;
	faceAreaOffset      = originalHUD.faceAreaOffset;
	minFaceAreaOffset   = originalHUD.minFaceAreaOffset;
	serverInfoClass     = originalHUD.serverInfoClass;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the player switches to the specified weapon group. Doesn't appear to
 *                be used anywhere.
 *  $PARAM        f  The number of the weapon group to which the player is about to switch.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function inputNumber(byte f) {
	if (originalHUD != none) originalHUD.inputNumber(f);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the HUD mode. Not used in Unreal Tournament.
 *  $PARAM        d  Number to add to the HUD mode number (delta).
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function changeHud(int d) {
	if (originalHUD != none) originalHUD.changeHud(d);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the crosshair to use.
 *  $PARAM        d  Number to add to the crosshair number (delta).
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function changeCrosshair(int d) {
	if (originalHUD != none) originalHUD.changeCrosshair(d);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the crosshair on the screen.
 *  $PARAM        c       The canvas object on which the rendering will be done.
 *  $PARAM        startX  Horizontal offset.
 *  $PARAM        startX  Vertical offset.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function drawCrossHair(Canvas c, int startX, int startY) {
	if (originalHUD != none) originalHUD.drawCrossHair(c, startX, startY);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Displays a new message on the screen.
 *  $PARAM        pri      Information about the player that is related with this message.
 *  $PARAM        msg      String containing the message to be displayed.
 *  $PARAM        msgType  Type of the message.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function message(PlayerReplicationInfo pri, coerce string msg, name msgType) {
	local bool bHandleByOriginalHUD;
	
	// Check class responsible for this message.
	bHandleByOriginalHUD = msgType == 'CriticalEvent' ||
	                       client != none && !client.bUseNexgenMessageHUD;
	
	// Handle message.
	if (bHandleByOriginalHUD) {
		if (originalHUD != none) originalHUD.message(pri, msg, msgType);
	} else {
		addMessage(msg, msgType, pri, none);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Displays a new localized message on the screen.
 *  $PARAM        message         Class used to construct the localized message string.
 *  $PARAM        switch          Message selection switch number.
 *  $PARAM        relatedPRI_1    First player that is related to this message.
 *  $PARAM        relatedPRI_2    Second player that is related to this message.
 *  $PARAM        optionalObject  Object involved in the construction of the message string.
 *  $PARAM        criticalString  Critical message string.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function localizedMessage(class<LocalMessage> message,
                                    optional int switch,
                                    optional PlayerReplicationInfo relatedPRI_1,
                                    optional PlayerReplicationInfo relatedPRI_2,
                                    optional Object optionalObject,
                                    optional string criticalString) {
	local bool bHandleByOriginalHUD;
	local string msgStr;
	
	// Check class responsible for this message.
	bHandleByOriginalHUD = message.default.bIsSpecial ||
	                       client != none && !client.bUseNexgenMessageHUD;
	
	// Handle message.
	if (bHandleByOriginalHUD) {
		if (originalHUD != none) originalHUD.localizedMessage(message, switch, relatedPRI_1, relatedPRI_2, optionalObject, criticalString);
	} else {
		// Get message string.
        if (message.default.bComplexString) {
            msgStr = criticalString;
        } else {
            msgStr = message.static.getString(switch, relatedPRI_1, relatedPRI_2, optionalObject);
        }
		
		// Add the message.
		addMessage(msgStr, '', relatedPRI_1, relatedPRI_2);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Displays the specified message. Doesn't appear to be used.
 *  $PARAM        s      The message to display.
 *  $PARAM        pName  Name of the player that created the message?
 *  $PARAM        pZone  Location of the player that created the message?
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function playReceivedMessage(string s, string pName, ZoneInfo pZone) {
	if (originalHUD != none) originalHUD.playReceivedMessage(s, pName, pZone);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether this HUD is responsible for displaying messages.
 *  $RETURN       True if this HUD handles the messages instead of the console.
 *  $ENSURE       result == true
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function bool displayMessages(Canvas c) {
    return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called by the engine when a key, mouse, or joystick button is pressed or released,
 *                or any analog axis movement is processed.
 *  $PARAM        key     The key that was involved.
 *  $PARAM        action  The action that was taken on the involved key.
 *  $PARAM        delta   Amount of time elapsed/used for the action.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool processKeyEvent(int key, int action, float delta) {
	if (originalHUD != none) return originalHUD.processKeyEvent(key, action, delta);
    return false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the location where the player took damage.
 *  $PARAM        hitLoc  The location where the player was hit.
 *  $PARAM        damage  The amount of damage taken by the player.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setDamage(vector hitLoc, float damage) {
	if (originalHUD != none) originalHUD.setDamage(hitLoc, damage);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new message to display. If the message can't be added directly because the
 *                NexgenHUD object hasn't been set, the message will be buffered.
 *  $PARAM        msg      String containing the message to add.
 *  $PARAM        msgType  Type of the message.
 *  $PARAM        pri1     First player that is related to this message.
 *  $PARAM        pri2     Second player that is related to this message.
 *
 **************************************************************************************************/
simulated function addMessage(string msg, name msgType, PlayerReplicationInfo pri1, PlayerReplicationInfo pri2) {
	if (nscHUD != none) nscHUD.message(msg, msgType, pri1, pri2);
}

