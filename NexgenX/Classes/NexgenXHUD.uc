/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXHUD
 *  $VERSION      1.01 (7-12-2008 14:30)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  NexgenX HUD extensions.
 *
 **************************************************************************************************/
class NexgenXHUD extends NexgenHUDExtension;

#exec TEXTURE IMPORT NAME=pingBox      FILE=Resources\PingBox.pcx      GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=timeBox      FILE=Resources\TimeBox.pcx      GROUP="GFX" FLAGS=2 MIPS=OFF

var NexgenXClient xClient;    // The NexgenX client controller.

var bool bShowPingBox;
var bool bShowTimeBox;
var bool bTimeDown;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the NexgenX HUD extension.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function preBeginPlay() {
	super.preBeginPlay();
	
	xClient = NexgenXClient(owner);
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
