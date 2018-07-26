/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPHUD
 *  $VERSION      1.05 (21-12-2010 11:16:54)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  NexgenPlus HUD extensions.
 *
 **************************************************************************************************/
class NXPHUD extends NexgenHUDExtension;

#exec TEXTURE IMPORT NAME=pingBox      FILE=Resources\PingBox.pcx        GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=timeBox      FILE=Resources\TimeBox.pcx        GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=windowBG     FILE=Resources\HUDBackground.pcx  GROUP="GFX"         MIPS=Off

var NXPClient xClient;                            // The NexgenPlus client controller.
var NexgenSharedDataContainer xConf;              // The NexgenPlus configuration.

var color blankColor;                             // White color (#FFFFFF).
var color serverRuleHighlightColor;               // Color of the highlighted server rules.

var bool bShowPingBox;                            // Show the ping box.
var bool bShowTimeBox;                            // Display elapsed/remaining time box.
var bool bTimeDown;                               // Whether the time is counting down.

enum EAnimSequence {                              // Animation sequence type.
	AS_FadeIn,                                    // Fade in effect.
	AS_Sustained,                                 // Stationary on the screen.
	AS_FadeOut,                                   // Fade out effect.
	AS_Hidden                                     // Not displayed on the screen.
};

var EAnimSequence serverRulesAnimSequence;        // Current animation sequence for the server rules.
var float serverRulesAnimStartTime;               // Time at which the current animation sequence started.

// Settings.
const serverRulesWindowBorderSize = 10;           // Border size of the server rules HUD window.
const serverRulesFadeInTime = 0.7;                // Server rules window fade in time.
const serverRulesSustainTime = 9.0;               // Server rules window sustained display time.
const serverRulesFadeOutTime = 0.5;               // Server rules window fade out time.
const serverRuleHightlightTime = 0.4;             // Time a single server rule is highlighted.
const serverRuleHightlightDelay = 0.07;           // Highlight delay between successive rules.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the NexgenX HUD extension.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function preBeginPlay() {
	super.preBeginPlay();
	
	xClient = NXPClient(owner);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the HUD. Called before anything of the game HUD has been drawn. This
 *                function is only called if the Nexgen HUD is enabled.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function preRender(Canvas c) {
	local ChallengeHUD ch;
	local float statScale;
	local bool bShowExtraStatus;
	
	ch = ChallengeHUD(client.player.myHUD);
	
	// Render stuff that requires a ChallengeHUD.
	if (ch != none) {

		// Extra status to show.
		bShowExtraStatus = (bShowPingBox || bShowTimeBox) && !ch.bHideFrags &&
		                   !ch.pawnOwner.playerReplicationInfo.bIsSpectator &&
		                   !(client.player.bShowScores || ch.bForceScores);
		
		// Render extra status boxes.
		if (bShowExtraStatus) {
			// Get common status variables.
			if (!ch.bHideStatus && c.clipX >= 400 &&  (TournamentPlayer(ch.pawnOwner) != none || Bot(ch.pawnOwner) != none)) {
				statScale = ch.scale * ch.statusScale;
			} else {
				statScale = 0.0;
			}
			
			// Render ping box.
			if (bShowPingBox) {
				renderPingBox(c, ch, statScale);
			}
			
			// Render time box.
			if (bShowTimeBox) {
				renderTimeBox(c, ch, statScale);
			}
		}
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders a HUD status box that displays the ping of the player being viewed.
 *  $PARAM        c          Canvas object that provides the drawing capabilities.
 *  $PARAM        ch         The ChallengeHUD of the local player.
 *  $PARAM        statScale  Scale of the status doll on the HUD.
 *  $REQUIRE      c != none && ch != none
 *
 **************************************************************************************************/
simulated function renderPingBox(Canvas c, ChallengeHUD ch, float statScale) {
	local float x, y;
	local int ping;
	
	// Get ping.
	if (ch.pawnOwner.playerReplicationInfo != none) {
		ping = ch.pawnOwner.playerReplicationInfo.ping;
	} else {
		ping = 0;
	}
	
	// Get location.
	if (ch.bHideStatus && ch.bHideAllWeapons) {
	    x = 0.5 * c.clipX + 256 * ch.scale;
	    y = c.clipY - 64 * ch.scale;
	} else {
	    x = c.clipX - 128 * statScale - 140 * ch.scale;
	    y = 128 * ch.scale;
	}

	// Render box background.
	c.drawColor = ch.HUDColor;
	c.style = ch.style;
	c.setPos(x, y);
	c.drawTile(Texture'BotPack.pingBox', 128 * ch.scale, 64 * ch.scale, 0, 0, 128.0, 64.0);
				
	// Render ping.
	c.drawColor = ch.whiteColor;
	ch.drawBigNum(c, ping, x + 4 * ch.scale, y + 16 * ch.scale, 1);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders a HUD status box that displays the remaining time or the elapsed time.
 *  $PARAM        c          Canvas object that provides the drawing capabilities.
 *  $PARAM        ch         The ChallengeHUD of the local player.
 *  $PARAM        statScale  Scale of the status doll on the HUD.
 *  $REQUIRE      c != none && ch != none
 *
 **************************************************************************************************/
simulated function renderTimeBox(Canvas c, ChallengeHUD ch, float statScale) {
	local float x, y;
	local int min;
	local int sec;
	
	// Get time.
	sec = client.player.gameReplicationInfo.remainingTime;
	if (bTimeDown || sec > 0) {
		bTimeDown = true;
		if (sec > 0) {
			min = sec / 60;
			sec = sec % 60;
		} else {
			sec = 0;
		}
	} else {
		sec = client.player.gameReplicationInfo.elapsedTime;
		min = sec / 60;
		sec = sec % 60;
	}
	
	// Get location.
	if (ch.bHideStatus && ch.bHideAllWeapons) {
	    x = 0.5 * c.clipX - 384 * ch.scale;
	    y = c.clipY - 64 * ch.scale;
	} else {
	    x = c.clipX - 128 * statScale - 140 * ch.scale;
	    if (bShowPingBox) {
	    	y = 192 * ch.scale;
	    } else {
	    	y = 128 * ch.scale;
	    }
	}

	// Render box background.
	c.drawColor = ch.HUDColor;
	c.style = ch.style;
	c.setPos(x, y);
	c.drawTile(Texture'BotPack.timeBox', 128 * ch.scale, 64 * ch.scale, 0, 0, 128.0, 64.0);
	
	// Render time.
	renderTime(c, ch, x, y, min, sec);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders a time display in a status box.
 *  $PARAM        c    Canvas object that provides the drawing capabilities.
 *  $PARAM        ch   The ChallengeHUD of the local player.
 *  $PARAM        x    Horizontal offset of the status box.
 *  $PARAM        y    Vertical offset of the status box.
 *  $PARAM        min  The amount of minutes to display.
 *  $PARAM        sec  The amount of seconds to display.
 *  $REQUIRE      c != none && ch != none
 *
 **************************************************************************************************/
simulated function renderTime(Canvas c, ChallengeHUD ch, float x, float y, int min, int sec) {
	local float cx, cy;
	local byte m;
	local float scale;
	local int length;
	
	if (min >= 1000) {
		min = 999;
	}
	
	// Get string length and scale.
	if (min >= 100) {
		scale = ch.scale * 0.75;
		length = 6;
	} else {
		scale = ch.scale * 0.90;
		length = 5;
	}
	
	// Compute offset.
	cx = int((128 * ch.scale - length * 25 * scale) / 2);
	cy = int((64 * ch.scale - 36 * scale) / 2);
	
	// Set rendering attributes.
	c.drawColor = ch.whiteColor;
	c.style = ch.style;
	c.setPos(x + cx, y + cy);
	
	// Render minutes.
	if (min >= 100) {
		drawDigit(c, min / 100, scale);
	}
	drawDigit(c, (min / 10) % 10, scale);
	drawDigit(c, min % 10, scale);
	
	// Render colon.
	drawColon(c, scale);
	
	// Render seconds.
	drawDigit(c, (sec / 10) % 10, scale);
	drawDigit(c, sec % 10, scale);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders a digit character at the current position.
 *  $PARAM        c      Canvas object that provides the drawing capabilities.
 *  $PARAM        d      The digit that is to be rendered
 *  $PARAM        scale  Scale of the character.
 *  $REQUIRE      c != none && 0 <= d && d <= 9
 *
 **************************************************************************************************/
simulated function drawDigit(Canvas c, int d, float scale) {
    c.drawTile(Texture'BotPack.HudElements1', scale * 25, int(64 * scale), 25 * d, 0, 25.0, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders a colon character at the current position.
 *  $PARAM        c      Canvas object that provides the drawing capabilities.
 *  $PARAM        scale  Scale of the character.
 *  $REQUIRE      c != none
 *
 **************************************************************************************************/
simulated function drawColon(Canvas c, float scale) {
    c.drawTile(Texture'BotPack.HudElements1', scale * 25, int(64 * scale), 25, 64, 25.0, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the HUD. Called while the mutators are allowed to render. Only called if
 *                no special screens are shown (like the scoreboard).
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function render(Canvas c) {
	if (xConf != none && xConf.getBool("showServerRulesInHUD")) {
		renderServerRulesHUD(c);
	}
}


/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the server rules HUD window on the given canvas.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function renderServerRulesHUD(Canvas c) {
	local int index;
	local int numRules;
	local float maxRuleWidth;
	local string rule;
	local float lineWidth;
	local float lineHeight;
	local float windowWidth;
	local float windowHeight;
	local int windowXOffset;
	local int windowYOffset;
	local int cx, cy;
	local float animationTimeElapsed;
	local float animationIndex;
	local float timeSeconds;
	local int ruleNum;
	local bool playerFiring;
	
	// Update animation sequence.
	timeSeconds = xClient.client.timeSeconds;
	playerFiring = (bool(xClient.client.player.bFire) || bool(xClient.client.player.bAltFire));
	if (serverRulesAnimStartTime <= 0) {
		serverRulesAnimSequence = AS_FadeIn;
		serverRulesAnimStartTime = timeSeconds;
	} else if (playerFiring && serverRulesAnimSequence == AS_FadeIn) {
		serverRulesAnimSequence = AS_FadeOut;
		serverRulesAnimStartTime = timeSeconds - (1 - (timeSeconds - serverRulesAnimStartTime) / serverRulesFadeInTime) * serverRulesFadeOutTime;
	} else if (serverRulesAnimSequence == AS_FadeIn && timeSeconds - serverRulesAnimStartTime > serverRulesFadeInTime) {
		serverRulesAnimSequence = AS_Sustained;
		serverRulesAnimStartTime = timeSeconds;
	} else if (serverRulesAnimSequence == AS_Sustained && (playerFiring || timeSeconds - serverRulesAnimStartTime > serverRulesSustainTime)) {
		serverRulesAnimSequence = AS_FadeOut;
		serverRulesAnimStartTime = timeSeconds;
	} else if (serverRulesAnimSequence == AS_FadeOut && timeSeconds - serverRulesAnimStartTime > serverRulesFadeOutTime) {
		serverRulesAnimSequence = AS_Hidden;
		serverRulesAnimStartTime = timeSeconds;
	}
	switch (serverRulesAnimSequence) {
		case AS_FadeIn:    animationIndex = (timeSeconds - serverRulesAnimStartTime) / serverRulesFadeInTime; break;
		case AS_Sustained: animationTimeElapsed = (timeSeconds - serverRulesAnimStartTime); break;
		case AS_FadeOut:   animationIndex = (timeSeconds - serverRulesAnimStartTime) / serverRulesFadeOutTime; break;
		case AS_Hidden:    return;
	}
	
	// Setup.
	c.font = xClient.client.nscHUD.baseFont;
	
	// Get number of rules & max width.
	for (index = 0; index < xConf.getArraySize("serverRules"); index++) {
		rule = Class'NexgenUtil'.static.trim(xConf.getString("serverRules", index));
		if (rule != "") {
			numRules++;
			c.strLen(rule, lineWidth, lineHeight);
			maxRuleWidth = fmax(maxRuleWidth, lineWidth);
		}
	}
	
	// Quit if there are no rules to show.
	if (numRules == 0) {
		return;
	}
	
	// Compute window size.
	windowWidth = 2 * serverRulesWindowBorderSize + maxRuleWidth;
	windowHeight = 2 * serverRulesWindowBorderSize + numRules * lineHeight;
	if (serverRulesAnimSequence == AS_FadeIn) {
		windowWidth *= animationIndex;
		windowHeight *= animationIndex;
	} else if (serverRulesAnimSequence == AS_FadeOut) {
		windowWidth *= 1 - animationIndex;
		windowHeight *= 1 - animationIndex;
	}
	windowWidth = int(windowWidth);
	windowHeight = int(windowHeight);
	
	// Compute window offset.
	switch (xConf.getByte("serverRulesHUDPosXUnits")) {
		case xClient.UNIT_Pixels: cx = xConf.getInt("serverRulesHUDPosX"); break;
		case xClient.UNIT_Percentage: cx = int(xConf.getInt("serverRulesHUDPosX") / 100.0 * c.clipX); break;
	}
	switch (xConf.getByte("serverRulesHUDPosYUnits")) {
		case xClient.UNIT_Pixels: cy = xConf.getInt("serverRulesHUDPosY"); break;
		case xClient.UNIT_Percentage: cy = int(xConf.getInt("serverRulesHUDPosY") / 100.0 * c.clipY); break;
	}
	switch (xConf.getByte("serverRulesHUDAnchorPointLocH")) {
		case xClient.APH_Left:   windowXOffset = cx; break;
		case xClient.APH_Middle: windowXOffset = int(cx - windowWidth / 2); break;
		case xClient.APH_right:  windowXOffset = c.clipX - cx - windowWidth; break;
	}
	switch (xConf.getByte("serverRulesHUDAnchorPointLocV")) {
		case xClient.APV_Top:    windowYOffset = cy; break;
		case xClient.APV_Middle: windowYOffset = int(cy - windowHeight / 2); break;
		case xClient.APV_Bottom: windowYOffset = c.clipY - cy - windowHeight; break;	
	}
	
	// Render window.
	if (windowWidth > 0 && windowHeight > 0) {
		c.style = ERenderStyle.STY_Modulated;
		c.setPos(windowXOffset, windowYOffset);
		c.drawColor = blankColor;
		c.drawRect(Texture'windowBG', windowWidth, windowHeight);
	}
	
	// Render rules.
	if (serverRulesAnimSequence == AS_Sustained) {
		c.style = ERenderStyle.STY_Normal;
		cx = windowXOffset + serverRulesWindowBorderSize;
		cy = windowYOffset + serverRulesWindowBorderSize;
		for (index = 0; index < xConf.getArraySize("serverRules"); index++) {
			rule = Class'NexgenUtil'.static.trim(xConf.getString("serverRules", index));
			if (rule != "") {
				ruleNum++;
				
				// Compute text color.
				c.drawColor = xClient.client.nscHUD.colors[9];
				if (animationTimeElapsed > (ruleNum - 1) * serverRuleHightlightDelay &&
				    animationTimeElapsed - (ruleNum - 1) * serverRuleHightlightDelay < serverRuleHightlightTime) {
					animationIndex = (animationTimeElapsed - (ruleNum - 1) * serverRuleHightlightDelay) / serverRuleHightlightTime;
					c.drawColor.r = int(animationIndex * c.drawColor.r + (1 - animationIndex) * serverRuleHighlightColor.r);
					c.drawColor.g = int(animationIndex * c.drawColor.g + (1 - animationIndex) * serverRuleHighlightColor.g);
					c.drawColor.b = int(animationIndex * c.drawColor.b + (1 - animationIndex) * serverRuleHighlightColor.b);
				}
				
				// Render text.
				if (animationTimeElapsed > (ruleNum - 1) * serverRuleHightlightDelay) {
					c.setPos(cx, cy);
					c.drawText(rule, false);
					cy = cy + lineHeight;
				}
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	blankColor=(R=255,G=255,B=255)
	serverRuleHighlightColor=(R=255,G=255,B=255)
}
