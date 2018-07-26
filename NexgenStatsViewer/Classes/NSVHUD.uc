/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $CLASS        NSVHUD
 *  $VERSION      1.04 (7-12-2008 18:04)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen stats HUD mutator. Displays the list of top players.
 *
 **************************************************************************************************/
class NSVHUD extends Mutator;

#exec TEXTURE IMPORT NAME=scoreStable FILE=Resources\ScoreStable.pcx GROUP="GFX" FLAGS=2 MIPS=Off
#exec TEXTURE IMPORT NAME=scoreUp     FILE=Resources\ScoreUp.pcx     GROUP="GFX" FLAGS=2 MIPS=Off
#exec TEXTURE IMPORT NAME=scoreDown   FILE=Resources\ScoreDown.pcx   GROUP="GFX" FLAGS=2 MIPS=Off
#exec TEXTURE IMPORT NAME=listBG      FILE=Resources\Background.pcx  GROUP="GFX"         MIPS=Off

var NSVClient xClient;                  // The client that is displaying the player list.

var color blankColor;                   // White color (#FFFFFF).
var color listTitleColor;               // Color of the text displayed above a player list.
var color playerColors[4];              // Player colors per rank.

var bool bInitialSetupDone;             // Whether the HUD has been setup.
var float lastClipX;                    // Last known horizontal screen resolution.
var float lastClipY;                    // Last known vertical screen resolution.

var font baseFont;                      // The font used to render the player lists.
var float baseFontHeight;               // Height of the used font.

struct PlayerInfo {                     // Extra player information.
	var Texture flag;                   // Country flag texture.
	var bool flagTexSet;                // Whether the flag texture has been set.
};

var int flagHeight;                     // Height of the flag icon.
var int flagWidth;                      // Width of the flag icon.
var int scoreChangeHeight;              // Height of the score change icon.
var int scoreChangeWidth;               // Width of the score change icon.
var int maxRankStrLen;                  // Maximum width of the rank strings.
var int maxPlayerNameStrLen;            // Maximum width of the player name strings.
var int maxScoreStrLen;                 // Maximum width of the score strings.
var int numPlayers;                     // Number of players to display.
var int maxListNameStrLen;              // Maximum width of the list name strings.
var int numLists;                       // Number of lists to display.
var int playerLineWidth;                // Width of a player info line.
var int listWidth;                      // Width of the player list.
var int listHeight;                     // Height of the player list.
var int totalWidth;                     // Total width of the player list window.
var int totalHeight;                    // Total height of the player list window.
var PlayerInfo pInf[30];                // Extra player infomation.

var float animTimeStart;                // Time at which the animation has started.
var enum EAnimSequence {                // Animation sequence type.
	AS_SlideIn,                         // Slide in effect.
	AS_Stationary,                      // Stationary on the screen.
	AS_SlideOut,                        // Slide out effect.
	AS_Hidden                           // Not displayed on the screen.
} animSequence;                         // Current animation sequence to use.

var float lastShowStartTime;            // Start time at which the stats were shown last.

const flagNormalWidth = 16.0;           // Normal width of the flag textures.
const flagNormalHeight = 10.0;          // Noraml height of the flag textures.
const scoreChangeNormalWidth = 9.0;     // Normal width of the score change textures.
const scoreChangeNormalHeight = 10.0;   // Normal height of the score change textures.
const lineDistance = 1;                 // Distance between lines.
const columnDistance = 4;               // Distance between columns.
const borderSize = 16;                  // Border size of the player list window.
const animSlideInTime = 1.0;            // Amount of time it takes to complete the slide in effect.
const animSlideOutTime = 0.5;           // Amount of time it takes to complete the slide out effect.

const maxShowTime = 8.0;                // Amount of time the stats should be visible when the game
                                        // is in progress.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Command interface function. Can be used by other mods to query the status of the
 *                the stats list visibility and to hide or show it. Supported commands:
 *                show    Shows the stats list.
 *                hide    Hides the stats list.
 *                status  Returns "show" if the list is shown, and "hide" if it isn't visible.
 *  $PARAM        cmd  The command to execute.
 *  $RETURN       Result of the command.
 *
 **************************************************************************************************/
function string getItemName(string cmd) {
	switch(cmd) {
		case "show": // Show the stats.
			showStats();
			break;
		
		case "hide": // Hide the stats.
			hideStats(true);
			break;
		
		case "status": // Return visibility status of stats.
			if (animSequence == AS_Hidden) {
				return "hide";
			} else {
				return "show";
			}
			break;
	}
	
	return "";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the statistics HUD.
 *  $REQUIRE      owner != none && owner.isA('NXStatsClient')
 *  $ENSURE       client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function postBeginPlay() {
	xClient = NSVClient(owner);
	//registerHUDMutator();
	animSequence = AS_SlideIn;
	animTimeStart = xClient.client.timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Shows the statistics list.
 *
 **************************************************************************************************/
function showStats() {
	animSequence = AS_SlideIn;
	animTimeStart = xClient.client.timeSeconds;
	lastShowStartTime = xClient.client.timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Hides the statistics list.
 *  $PARAM        bForced  Whether to hide the stats immediately or not.
 *
 **************************************************************************************************/
function hideStats(optional bool bForced) {
	if (bForced) {
		animSequence = AS_Hidden;
	} else {
		animSequence = AS_SlideOut;
		animTimeStart = xClient.client.timeSeconds;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attemps to register this NSVHUD instance as a HUD mutator.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	// Register as HUD mutator if not already done. Note this may fail several times.
	if (!bHUDMutator) registerHUDMutator();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the statistics HUD.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function postRender(Canvas c) {
	// Let other HUD mutators do their job first.
	if (nextHUDMutator != none) {
		nextHUDMutator.postRender(c);
	}
	
	// Render own stuff.
	if (animSequence == AS_Hidden) {
		return;
	} else if (animSequence == AS_Stationary &&
	           xClient.client != none && xClient.client.gInf != none && xClient.client.player != none &&
	           (xClient.client.gInf.gameState != xClient.client.gInf.GS_Playing &&
	            (bool(xClient.client.player.bFire) || bool(xClient.client.player.bAltFire)) ||
	           (xClient.client.gInf.gameState == xClient.client.gInf.GS_Playing &&
	             xClient.client.timeSeconds - lastShowStartTime > maxShowTime))) {
		animSequence = AS_SlideOut;
		animTimeStart = xClient.client.timeSeconds;
	}
	setup(c);
	renderPlayerList(c);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets up the HUD appearance variables.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $ENSURE       bInitialSetupDone = true
 *
 **************************************************************************************************/
function setup(Canvas c) {
	local bool bNeedsSetup;
	local float cw, ch;
	local int index;
	
	// Check if the HUD should be setup.
	bNeedsSetup = lastClipX != c.clipX || lastClipY != c.clipY || !bInitialSetupDone;
	
	// Setup the HUD only if necessary.
	if (bNeedsSetup) {
		// Save updated variables.
		bInitialSetupDone = true;
		lastClipX = c.clipX;
		lastClipY = c.clipY;
		
		// Set base variables.
		baseFont = ChallengeHUD(c.viewport.actor.myHUD).myFonts.getStaticSmallestFont(c.clipX);
		c.font = baseFont;
		c.strLen("TEST", cw, baseFontHeight);
		
		// Compute column widths.
		numPlayers = 0;
		maxRankStrLen = 0;
		maxPlayerNameStrLen = 0;
		maxScoreStrLen = 0;
		for (index = 0; index < arrayCount(xClient.statsRI.playerName); index++) {
			if (xClient.statsRI.playerName[index] != "") {
				numPlayers++;
				
				c.strLen(index $ ".", cw, ch);
				if (cw > maxRankStrLen) maxRankStrLen = cw;
				
				c.strLen(xClient.statsRI.playerName[index], cw, ch);
				if (cw > maxPlayerNameStrLen) maxPlayerNameStrLen = cw;
				
				c.strLen(xClient.statsRI.score[index], cw, ch);
				if (cw > maxScoreStrLen) maxScoreStrLen = cw;
				
				if (!pInf[index].flagTexSet) {
					pInf[index].flagTexSet = true;
					if (len(xClient.statsRI.country[index]) == 2) {
						pInf[index].flag = Texture(dynamicLoadObject(class'NexgenUtil'.default.countryFlagsPkg $ "." $ xClient.statsRI.country[index], class'Texture'));
					}
				}
			}
		}
		
		// Count number of lists.
		numLists = 0;
		maxListNameStrLen = 0;
		for (index = 0; index < arrayCount(xClient.statsRI.listName); index++) {
			if (xClient.statsRI.listName[index] != "") {
				c.strLen(xClient.statsRI.listName[index] $ ".", cw, ch);
				if (cw > maxListNameStrLen) maxListNameStrLen = cw;
				numLists++;
			}
		}
		
		// Scale icons.
		if (flagNormalHeight > baseFontHeight) {
			flagHeight = baseFontHeight;
			flagWidth = baseFontHeight / flagNormalHeight * flagNormalWidth;
		} else {
			flagHeight = flagNormalHeight;
			flagWidth = flagNormalWidth;
		}
		
		if (scoreChangeNormalHeight > baseFontHeight) {
			scoreChangeHeight = baseFontHeight;
			scoreChangeWidth = baseFontHeight / scoreChangeNormalHeight * scoreChangeNormalWidth;
		} else {
			scoreChangeHeight = scoreChangeNormalHeight;
			scoreChangeWidth = scoreChangeNormalWidth;
		}
		
		// Compute player line width.
		playerLineWidth = maxRankStrLen + flagWidth + maxPlayerNameStrLen + maxScoreStrLen +
		                  scoreChangeWidth + 4 * columnDistance;
		                  
		listWidth = max(playerLineWidth, maxListNameStrLen);
		listHeight = (numPlayers + numLists * 2 - 1) * (baseFontHeight + lineDistance) + 1;
		totalWidth = listWidth + 2 * borderSize;
		totalHeight = listHeight + 2 * borderSize;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets up the HUD appearance variables.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none && bInitialSetupDone
 *
 **************************************************************************************************/
function renderPlayerList(Canvas c) {
	local int baseX, baseY;
	local int cx, cy;
	local int index;
	local int count;
	local int rank;
	local int playerNum;
	local float cw, ch;
	local color lineCol;
	local Texture scoreChangeIcon;
	local float animIndex;
	
	// Determine base position.
	if (animSequence == AS_SlideIn) {
		animIndex = (xClient.client.timeSeconds - animTimeStart) / animSlideInTime;
		if (animIndex > 1.0) {
			animSequence = AS_Stationary;
			animIndex = 1.0;
		}
		baseX = animIndex * (borderSize + totalWidth) - totalWidth;
	} else if (animSequence == AS_SlideOut) {
		animIndex = 1.0 - (xClient.client.timeSeconds - animTimeStart) / animSlideOutTime;
		if (animIndex > 1.0) {
			animSequence = AS_Hidden;
			animIndex = 1.0;
		}
		baseX = animIndex * (borderSize + totalWidth) - totalWidth;
	} else {
		baseX = borderSize;
	}
	baseY = (c.clipY - totalHeight) / 2.0;
	
	// Render background.
	c.style = ERenderStyle.STY_Modulated;
	c.setPos(baseX, baseY);
	c.drawColor = blankColor;
	c.drawRect(Texture'listBG', totalWidth, totalHeight);
	baseX += borderSize;
	baseY += borderSize;
	
	// Render player lists.
	c.font = baseFont;
	c.style = ERenderStyle.STY_Normal;
	for (index = 0; index < numLists; index++) {
		rank = 1;

		// Render list title.
		c.drawColor = listTitleColor;
		c.setPos(baseX, baseY + cy);
		c.drawText(xClient.statsRI.listName[index], false);
		cy += baseFontHeight + lineDistance;
		
		c.setPos(baseX, baseY + cy);
		c.drawTile(Texture'base', listWidth, 1.0, 0.0, 0.0, 1.0, 1.0);	
		
		cy += 1 + lineDistance;
		
		// Render players.
		for (count = 0; count < xClient.statsRI.listLength[index]; count++) {
			if (xClient.statsRI.playerName[playerNum] != "") {
				// Determine line color.
				if (rank >= arrayCount(playerColors)) {
					lineCol = playerColors[arrayCount(playerColors) - 1];
				} else {
					lineCol = playerColors[rank - 1];
				}
	
				// Render rank.
				cx = 0;
				c.strLen(rank $ ".", cw, ch);
				c.setPos(baseX + cx + maxRankStrLen - cw, baseY + cy);
				c.drawColor = lineCol;
				c.drawText(rank $ ".", false);
				cx += maxRankStrLen + columnDistance;
				
				// Render player country flag.
				if (pInf[playerNum].flag != none) {
					c.setPos(baseX + cx, baseY + cy + (baseFontHeight - flagHeight) / 2);
					c.drawColor = blankColor;
					c.drawTile(pInf[playerNum].flag, flagWidth, flagHeight, 0.0, 0.0, flagNormalWidth, flagNormalHeight);
				}
				cx += flagWidth + columnDistance;
				
				// Render player name.
				c.setPos(baseX + cx, baseY + cy);
				c.drawColor = lineCol;
				c.drawText(xClient.statsRI.playerName[playerNum], false);
				cx += maxPlayerNameStrLen + columnDistance;
				
				// Render score.
				c.strLen(xClient.statsRI.score[playerNum], cw, ch);
				c.setPos(baseX + cx + maxScoreStrLen - cw, baseY + cy);
				c.drawText(xClient.statsRI.score[playerNum], false);
				cx += maxScoreStrLen + columnDistance;
				
				// Render score change icon.
				c.setPos(baseX + cx, baseY + cy + (baseFontHeight - scoreChangeHeight) / 2);
				c.drawColor = blankColor;
				switch (xClient.statsRI.positionChange[playerNum]) {
					case xClient.statsRI.PC_NoChange:  scoreChangeIcon = Texture'scoreStable'; break;
					case xClient.statsRI.PC_MovedUp:   scoreChangeIcon = Texture'scoreUp';     break;
					case xClient.statsRI.PC_MovedDown: scoreChangeIcon = Texture'scoreDown';   break;
					default:                           scoreChangeIcon = none;                 break;
				}
				if (scoreChangeIcon != none) {
					c.drawTile(scoreChangeIcon, scoreChangeWidth, scoreChangeHeight, 0.0, 0.0, scoreChangeNormalWidth, scoreChangeNormalHeight);
				}
				
				cy += baseFontHeight + lineDistance;
				rank++;
			}
			playerNum++;
		}
		
		cy += baseFontHeight + lineDistance;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	remoteRole=ROLE_None
	bAlwaysTick=true
	blankColor=(R=255,G=255,B=255)
	listTitleColor=(R=64,G=64,B=255)
	playerColors(0)=(R=236,G=188,B=0)
	playerColors(1)=(R=203,G=137,B=1)
	playerColors(2)=(R=170,G=85,B=2)
	playerColors(3)=(R=192,G=192,B=192)
}