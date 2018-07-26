/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenHUD
 *  $VERSION      1.23 (15-3-2009 11:55)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen HUD extension class.
 *
 **************************************************************************************************/
class NexgenHUD extends Mutator;

#exec OBJ LOAD FILE=..\Textures\LadrStatic.utx PACKAGE=Botpack.LadrStatic

#exec TEXTURE IMPORT NAME=base         FILE=Resources\base.pcx         GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=grad32       FILE=Resources\grad32.pcx       GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=grad64       FILE=Resources\grad64.pcx       GROUP="GFX" FLAGS=2 MIPS=OFF

#exec TEXTURE IMPORT NAME=playerIcon   FILE=Resources\PlayerIcon.pcx   GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=playerIcon2  FILE=Resources\PlayerIcon2.pcx  GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=serverIcon   FILE=Resources\ServerIcon.pcx   GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=serverIcon2  FILE=Resources\ServerIcon2.pcx  GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=offlineIcon  FILE=Resources\OfflineIcon.pcx  GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=offlineIcon2 FILE=Resources\OfflineIcon2.pcx GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=waitIcon     FILE=Resources\WaitIcon.pcx     GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=waitIcon2    FILE=Resources\WaitIcon2.pcx    GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=specIcon     FILE=Resources\SpecIcon.pcx     GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=specIcon2    FILE=Resources\SpecIcon2.pcx    GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=shieldIcon   FILE=Resources\ShieldIcon.pcx   GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=shieldIcon2  FILE=Resources\ShieldIcon2.pcx  GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=idleIcon     FILE=Resources\IdleIcon.pcx     GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=idleIcon2    FILE=Resources\IdleIcon2.pcx    GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=mutedIcon    FILE=Resources\MutedIcon.pcx    GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=mutedIcon2   FILE=Resources\MutedIcon2.pcx   GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=matchIcon    FILE=Resources\MatchIcon.pcx    GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=matchIcon2   FILE=Resources\MatchIcon2.pcx   GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=loginIcon    FILE=Resources\loginIcon.pcx    GROUP="GFX" FLAGS=3 MIPS=OFF
#exec TEXTURE IMPORT NAME=loginIcon2   FILE=Resources\loginIcon2.pcx   GROUP="GFX" FLAGS=3 MIPS=OFF

var NexgenClient client;                // Client owning this HUD.
var PlayerPawn player;                  // Local player (which has a viewport).

var float lastSetupTime;                // Last time setup() was called.
var Font baseFont;                      // Base font to use for rendering text.
var Color blankColor;                   // White color (#FFFFFF).
var Color baseHUDColor;                 // Base color of the HUD (background color).
var Color baseColors[6];                // Base colors available for the HUD.
var Color colors[11];                   // List of colors for text.
var float baseFontHeight;               // Height of the base font.

struct MessageInfo {                    // Structure for storing message information.
	var string text[5];                 // Message text list.
	var int col[5];                     // Message text colors.
	var float timeStamp;                // Time at which the message was received.
};

struct PanelInfo {                      // Panel info container structure.
	var string text;                    // Text displayed on the panel.
	var Color textCol;                  // Color of the text to display.
	var Texture icon;                   // Icon displayed in front of the text.
	var Texture solidIcon;              // Solid version of the icon.
	var bool bBlink;                    // Indicates if the text should 'blink'.
};

var MessageInfo chatMessages[3];        // List of chat messages.
var MessageInfo messages[5];            // List of all other messages.
var int chatMsgCount;                   // Number of chat messages stored in the list.
var int msgCount;                       // Number of other messages stored.
var Texture faceImg;                    // Face texture to display in the chat message box.

var float msgBoxWidth;                  // Width of the message box.
var float msgBoxLineHeight;             // Height of a line in the message box.
var float msgBoxHeight;                 // Total height of the message box.
var float minPanelWidth;                // Minimum size of the panel.

var bool bFlashMessages;                // Whether new messages should flash.

var float lastResX;                     // Horizontal resolution at last setup call.
var float lastResY;                     // Vertical resolution at last setup call.

var float lastLevelTimeSeconds;         // Last value of level.time seconds.
var float timeSeconds;                  // Gamespeed independent timeSeconds, that keeps counting
                                        // even when the game is paused.
                                        
var bool bShowPlayerLocation;           // Show player location name in teamsay messages?

var NexgenHUDExtension extensions[10];  // Registered HUD extensions.

const iconSize = 24.0;                  // Size of the status icons.

const chatMessageLifeTime = 16.0;       // The amount of time a chat message is diplayed (in sec).
const messageLifeTime = 12.0;           // Amount of time any other message is displayed (in sec).
const messageBlinkTime = 4.0;           // How long a message is highlighted (in sec).
const messageBlinkRate = 4.0;           // Message highlight blink rate (in Hz).
const panelBlinkRate = 2.0;             // Panel text highlight blink rate (in Hz).
const blinkColorDamp = 0.70;            // Dampening factor for blinking text.

const connectionAlertDelay = 2;         // Time to wait before showing the bad connection alert.
const secPerMinute = 60;                // Number of seconds per minute -- duh!
const matchInfoSwitchTime = 4;          // Number of seconds to wait before switching between time
                                        // remaining and match num.

// Alert window settings.
const hDefBarSize = 20;                 // Animated horizontal bar size.
const alertAnimTime = 0.5;              // Animation cycle time.
const alertAnimDist = 64;               // Distance the animated bar moves away from the window.
const alertBorderSize = 32;             // Distance between borders and text of the window.
const newLineToken = "\\n";             // Token used to break the text in multiple lines.

// Colors.
const C_RED = 0;
const C_BLUE = 1;
const C_GREEN = 2;
const C_YELLOW = 3;
const C_WHITE = 4;
const C_BLACK = 5;
const C_PINK = 6;
const C_CYAN = 7;
const C_METAL = 8;
const C_ORANGE = 9;

// Server states.
const SS_Loading = 'ssloading';         // Loading.
const SS_Offline = 'ssoffline';         // Connection with server is failing.
const SS_Waiting = 'sswaiting';         // Server is waiting for players.
const SS_Ready = 'ssready';             // Game is ready to start.
const SS_Starting = 'ssstaring';        // Game is counting down to start.
const SS_Ended = 'ssended';             // Game is ended.
const SS_Paused = 'sspaused';           // Game is paused.
const SS_Match = 'ssmatch';             // A match is in progress.
const SS_Normal = 'ssnormal';           // A normal game is in progress.

// Client states.
const CS_Login = 'cslogin';             // Client is logging in.
const CS_Idle = 'csidle';               // Client is idle or camping.
const CS_Protected = 'csprotected';     // Client is (damage) protected.
const CS_Muted = 'csmuted';             // Client is muted.
const CS_Dead = 'csdead';               // Client is dead.
const CS_Normal = 'csnormal';           // Client is in normal state.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the extended HUD.
 *  $REQUIRE      owner != none && owner.isA('NexgenClient')
 *  $ENSURE       client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function postBeginPlay() {
	client = NexgenClient(owner);
	bFlashMessages = client.gc.get(client.SSTR_FlashMessages, "false") ~= "true";
	bShowPlayerLocation = client.gc.get(client.SSTR_ShowPlayerLocation, "true") ~= "true";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Game tick. Attemps to register this NexgenHUD instance as a HUD mutator.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	// Register as HUD mutator if not already done. Note this may fail several times.
	if (!bHUDMutator) registerHUDMutator();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the extended Nexgen HUD.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function postRender(Canvas c) {
	local float badConnectionTime;
	local int timeRemaining;
	local int index;
	
	setup(c);
	
	// Let other HUD mutators do their job first.
	if (nextHUDMutator != none) {
		nextHUDMutator.postRender(c);
	}
	
	// Render HUD extensions.
	for (index = 0; index < arrayCount(extensions); index++) {
		if (extensions[index] != none) {
			extensions[index].render(c);
		}
	}
	
	// Render alerts.
	badConnectionTime = client.timeSeconds - client.badConnectionSince;
	if (client.bBadConnectionDetected && client.sConf != none && client.sConf.autoReconnectTime > 0 &&
	    (badConnectionTime > connectionAlertDelay || client.gInf.rebootCountDown > 0)) {
		// Connection lost alert.
		timeRemaining = client.sConf.autoReconnectTime - badConnectionTime + 1;
		if (timeRemaining > 0) {
			renderAlert(c, client.lng.format(client.lng.autoReconnectAlert, timeRemaining), colors[C_RED], colors[C_RED]);
		} else {
			renderAlert(c, client.lng.reconnectingAlert, colors[C_RED], colors[C_RED]);
		}
		
	} else if (client.gInf != none && client.gInf.rebootCountDown > 0) {
		// Reboot warning.
		timeRemaining = client.gInf.rebootCountDown;
		renderAlert(c, client.lng.format(client.lng.rebootAlert, timeRemaining), colors[C_WHITE], baseHUDColor);
		
	} else if (client.idleTimeRemaining >= 0 && client.idleTimeRemaining <= client.idleTimeWarning) {
		// Idle warning.
		timeRemaining = client.idleTimeRemaining;
		renderAlert(c, client.lng.format(client.lng.idleAlert, timeRemaining), colors[C_WHITE], baseHUDColor);
		
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders an alert window.
 *  $PARAM        msg        The message to display on the alert window.
 *  $PARAM        textColor  Color of the text displayed on the alert window.
 *  $PARAM        baseColor  Background color of the alert window.
 *
 **************************************************************************************************/
simulated function renderAlert(Canvas c, string msg, color textColor, color baseColor) {
	local int windowWidth;
	local int windowHeight;
	local int cx, cy;
	local float animIndex;
	local int dist;
	local int hBarSize;
	local float textWidth;
	local int maxTextWidth;
	local float textHeight;
	local int lineCount;
	local string remaining;
	local int index;
	local string text;
	
	// Initialize.
	c.font = ChallengeHUD(c.viewport.actor.myHUD).myFonts.getStaticHugeFont(c.clipX);
	remaining = msg;
	lineCount = 0;
	while (remaining != "") {
		index = instr(remaining, newLineToken);
		if (index > 0) {
			text = left(remaining, index);
			remaining = mid(remaining, index + len(newLineToken));
		} else {
			text = remaining;
			remaining = "";
		}
		c.strLen(text, textWidth, textHeight);
		maxTextWidth = max(maxTextWidth, textWidth);
		lineCount++;
	}
	
	windowWidth = maxTextWidth + 2 * alertBorderSize;
	windowHeight = lineCount * textHeight + 2 * alertBorderSize;
	cx = (c.clipX - windowWidth) / 2;
	cy = (c.clipY - windowHeight) / 2;
	
	// Render frame background.
	c.style = ERenderStyle.STY_Translucent;
	c.drawColor = baseColor * 0.4;
	c.setPos(cx, cy);
	c.drawTile(Texture'grad64', windowWidth, windowHeight, 0.0, 0.0, 64.0, 64.0);
	
	// Render borders.
	c.drawColor = baseColor * 0.8;
	c.setPos(cx - 3.0, cy - 1.0);
	c.drawTile(Texture'base', 2.0, windowHeight + 2.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(cx + 1.0 + windowWidth, cy - 1.0);
	c.drawTile(Texture'base', 2.0, windowHeight + 2.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(cx - 3.0, cy - 2.0);
	c.drawTile(Texture'base', hDefBarSize, 1.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(cx - 3.0, cy + 1.0 + windowHeight);
	c.drawTile(Texture'base', hDefBarSize, 1.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(cx + 3.0 + windowWidth - hDefBarSize, cy - 2.0);
	c.drawTile(Texture'base', hDefBarSize, 1.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(cx + 3.0 + windowWidth - hDefBarSize, cy + 1.0 + windowHeight);
	c.drawTile(Texture'base', hDefBarSize, 1.0, 0.0, 0.0, 1.0, 1.0);
	
	// High detail animation effect.
	if (level.bHighDetailMode) {
		animIndex = (client.timeSeconds % alertAnimTime) / alertAnimTime;
		
		c.drawColor = baseColor * (1.0 - animIndex);
		
		dist = sin(animIndex * pi * 0.5) * alertAnimDist;
		hBarSize = hDefBarSize + hDefBarSize * ((windowWidth + alertAnimDist) / windowWidth) * animIndex;
		c.setPos(cx - 3.0 - dist, cy - 1.0 - dist);
		c.drawTile(Texture'base', 2.0, windowHeight + 2.0 + 2 * dist, 0.0, 0.0, 1.0, 1.0);
		c.setPos(cx + 1.0 + windowWidth + dist, cy - 1.0 - dist);
		c.drawTile(Texture'base', 2.0, windowHeight + 2.0 + 2 * dist, 0.0, 0.0, 1.0, 1.0);
		c.setPos(cx - 3.0 - dist, cy - 2.0 - dist);
		c.drawTile(Texture'base', hBarSize, 1.0, 0.0, 0.0, 1.0, 1.0);
		c.setPos(cx - 3.0 - dist, cy + 1.0 + windowHeight + dist);
		c.drawTile(Texture'base', hBarSize, 1.0, 0.0, 0.0, 1.0, 1.0);
		c.setPos(cx + 3.0 + windowWidth - hBarSize + dist, cy - 2.0 - dist);
		c.drawTile(Texture'base', hBarSize, 1.0, 0.0, 0.0, 1.0, 1.0);
		c.setPos(cx + 3.0 + windowWidth - hBarSize + dist, cy + 1.0 + windowHeight + dist);
		c.drawTile(Texture'base', hBarSize, 1.0, 0.0, 0.0, 1.0, 1.0);
	}
	
	// Render text.
	remaining = msg;
	lineCount = 0;
	c.drawColor = textColor;
	while (remaining != "") {
		index = instr(remaining, newLineToken);
		if (index > 0) {
			text = left(remaining, index);
			remaining = mid(remaining, index + len(newLineToken));
		} else {
			text = remaining;
			remaining = "";
		}
		c.setPos(cx + alertBorderSize, cy + alertBorderSize + lineCount * textHeight);
		c.drawText(text, false);
		lineCount++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a message to the message HUD.
 *  $PARAM        msg      The message that is to be displayed.
 *  $PARAM        msgType  Message type identifier.
 *  $PARAM        pri1     Replication info of the first player involved.
 *  $PARAM        pri2     Replication info of the second player involved.
 *
 **************************************************************************************************/
simulated function message(string msg, name msgType, PlayerReplicationInfo pri1, PlayerReplicationInfo pri2) {
	local int playerColor;
	local int messageColor;
	local bool bIsSpecSayMsg;
	local PlayerReplicationInfo specPRI;
	local GameReplicationInfo gri;
	local int index;
	local string locationName;


	// Check if the message was send by a spectator using say.
	if (msgType == 'Event' && instr(msg, ":") >= 0) {
		// Get shortcut to the game replication info.
		gri = player.gameReplicationInfo;	
		
		// Find a player.
		while (index < arrayCount(gri.PRIArray) && gri.PRIArray[index] != none) {
			if (gri.PRIArray[index].bIsSpectator &&
			    left(msg, len(gri.PRIArray[index].playerName) + 1) ~=
			    (gri.PRIArray[index].playerName $ ":")) {
				if (bIsSpecSayMsg) {
					if (len(gri.PRIArray[index].playerName) > len(pri1.playerName)) {
						pri1 = gri.PRIArray[index];
					}
				} else {
					bIsSpecSayMsg = true;
					pri1 = gri.PRIArray[index];
				}
			}
			index++;
		}	
	}

	// Check message type.
	if (bIsSpecSayMsg) {
		// Chat message. Special case: player is spec and using say (not teamsay).
		if (pri1.talkTexture != none) {
			faceImg = pri1.talkTexture;
		}
		addChatMsg(C_METAL, pri1.playerName $ ": ", C_METAL, mid(msg, len(pri1.playerName) + 1));

	} else if (pri1 != none && msg != "" && (msgType == 'Say' || msgType == 'TeamSay')) {
		// Chat message.
		playerColor = getPlayerColor(pri1);
		if (pri1.talkTexture != none) {
			faceImg = pri1.talkTexture;
		}
		
		if (msgType == 'TeamSay') {
			if (pri1.bIsSpectator && !pri1.bWaitingPlayer) {
				messageColor = C_WHITE;
			} else {
				messageColor = playerColor;
			}

			if (!pri1.bIsSpectator) {
			    if (pri1.playerLocation != none) {
			        locationName = pri1.playerLocation.locationName;
			    } else if (pri1.playerZone != none) {
					locationName = pri1.playerZone.zoneName;
				}
			}
		} else {
			if (pri1.bIsSpectator && !pri1.bWaitingPlayer) {
				messageColor = C_METAL;
			} else {
				messageColor = C_ORANGE;
			}
		}
		
		if (locationName != "" && bShowPlayerLocation) {
			addChatMsg(playerColor, pri1.playerName, C_CYAN, " (" $ locationName $ "): ", messageColor, msg);
		} else {
			addChatMsg(playerColor, pri1.playerName $ ": ", messageColor, msg);
		}
		
	} else if (msg != "") {
		// Other message.
		addColorizedMessage(msg, pri1, pri2);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a message to the area just below the chatbox. Before the message is added an
 *                attempt will be made to highlight player names. This is done by checking if the
 *                messages contain the names of the given player replication info objects.
 *  $PARAM        msg   Message to add.
 *  $PARAM        pri1  Replication info of the first player involved.
 *  $PARAM        pri2  Replication info of the second player involved.
 *
 **************************************************************************************************/
simulated function addColorizedMessage(string msg, PlayerReplicationInfo pri1, PlayerReplicationInfo pri2) {
	local string firstPlayerName;
	local string secondPlayerName;
	local int firstIndex;
	local int secondIndex;
	local int firstPlayerColor;
	local int secondPlayerColor;
	local string msgPart1;
	local string msgPart2;
	local string msgPart3;
	local int msgColor;
	local string tempPlayerName;
	local int tempIndex;
	local int tempPlayerColor;
	
	// Get message color.
	msgColor = class'NexgenUtil'.static.getMessageColor(msg);
	if (msgColor < 0) {
		msgColor = C_ORANGE;
	}
	msg = class'NexgenUtil'.static.removeMessageColorTag(msg);
	
	// Get player name indices.
	getPlayerNameIndices(msg, pri1, pri2, firstIndex, secondIndex);
	
	// Get player names & colors.
	if (pri1 != none) {
		firstPlayerName = pri1.playerName;
		firstPlayerColor = getPlayerColor(pri1);
	}
	if (pri2 != none) {
		secondPlayerName = pri2.playerName;
		secondPlayerColor = getPlayerColor(pri2);	
	}
	
	// Swap first and second player if necessary.
	if (secondIndex >= 0 && (secondIndex < firstIndex || firstIndex < 0)) {
		tempPlayerName = secondPlayerName;
		tempIndex = secondIndex;
		tempPlayerColor = secondPlayerColor;
		secondPlayerName = firstPlayerName;
		secondIndex = firstIndex;
		secondPlayerColor = firstPlayerColor;
		firstPlayerName = tempPlayerName;
		firstIndex = tempIndex;
		firstPlayerColor = tempPlayerColor;
	}
	
	// Split message.
	if (firstIndex >= 0 && secondIndex >= 0) {
		msgPart1 = left(msg, firstIndex);
		msgPart2 = mid(msg, firstIndex + len(firstPlayerName), secondIndex - firstIndex - len(firstPlayerName));
		msgPart3 = mid(msg, secondIndex + len(secondPlayerName));
	} else if (firstIndex >= 0) {
		msgPart1 = left(msg, firstIndex);
		msgPart2 = mid(msg, firstIndex + len(firstPlayerName));
		secondPlayerName = "";
	} else {
		firstPlayerName = "";
		secondPlayerName = "";
		msgPart1 = msg;
	}
	
	// Add message.
	addMsg(msgColor, msgPart1, firstPlayerColor, firstPlayerName, msgColor, msgPart2,
	       secondPlayerColor, secondPlayerName, msgColor, msgPart3);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attemps to locate the indices of player names in the given message. To speed up
 *                the locating process you can pass the player replication info actors of the
 *                players that are most likely to be included in the message.
 *  $PARAM        msg     The message which may contain player names.
 *  $PARAM        pri1    Replication info of the first player involved.
 *  $PARAM        pri2    Replication info of the second player involved.
 *  $PARAM        index1  The location in the string where the first player name occurs.
 *  $PARAM        index2  The location in the string where the second player name occurs.
 *  $ENSURE       (index1 >= 0 ? pri1 != none : true) && (index2 >= 0 ? pri2 != none : true)
 *
 **************************************************************************************************/
simulated function getPlayerNameIndices(string msg, out PlayerReplicationInfo pri1,
                                        out PlayerReplicationInfo pri2, out int index1,
                                        out int index2) {
	local PlayerReplicationInfo tmpPRI;
	local GameReplicationInfo gri;
	local int index;
	local int nameIndex;
	local int tmpIndex;
	
	// Get shortcut to the game replication info.
	gri = player.gameReplicationInfo;
	
	
	
	// Initially no indices have been found.
	index1 = -1;
	index2 = -1;
	
	// Check if the first PRI is actually in the message. This appears not to be the case for some
	// messages (for example with the Stranglove weapon mod).
	if (pri1 != none && instr(msg, pri1.playerName) < 0) {
		pri1 = none;
	}
	
	// Swap player replication info's if needed.
	if (pri1 == none && pri2 != none) {
		pri1 = pri2;
		pri2 = none;
	} else if (pri1 != none && pri2 != none && len(pri2.playerName) > len(pri1.playerName)) {
		// Ensure the longest playername is located first.
		tmpPRI = pri1;
		pri1 = pri2;
		pri2 = tmpPRI;
	}
	
	
	
	// Get the position of the first player name in the message.
	if (pri1 == none) {
		// No PRI found, try to find one.
		index = 0;
		while (index < arrayCount(gri.PRIArray) && gri.PRIArray[index] != none) {
			
			// Get current player replication info.
			tmpPRI = gri.PRIArray[index];
			
			// Get position of the players name in the message.
			nameIndex = instr(msg, tmpPRI.playerName);
			
			// Select PRI?
			if (nameIndex >= 0 && (pri1 == none || len(tmpPRI.playerName) > len(pri1.playerName))) {
				// Yes, no name has been found so far or a longer player name has been found.
				pri1 = tmpPRI;
				index1 = nameIndex;
			}
			
			// Continue with next player name.
			index++;
		}
	} else {
		// Already got PRI, just find the index of the name.
		index1 = instr(msg, pri1.playerName);
	}
	
	
	
	// Get the position of the second player name in the message.
	if (pri1 != none && pri2 == none) {
		// No PRI found, try to find one.
		index = 0;
		while (index < arrayCount(gri.PRIArray) && gri.PRIArray[index] != none) {
			// Get current player replication info.
			tmpPRI = gri.PRIArray[index];
			
			// Get position of the players name in the message.
			nameIndex = instr(msg, tmpPRI.playerName);
			
			// Check for overlap.
			if (index1 >=0 && nameIndex >= 0 && index1 <= nameIndex &&
			    nameIndex < index1 + len(pri1.playerName)) {
				// Overlap detected, check if name occurs after the first player name.
				nameIndex = instr(mid(msg, index1 + len(pri1.playerName)), tmpPRI.playerName);
				if (nameIndex >= 0) {
					nameIndex += index1 + len(pri1.playerName);
				}
			}
			
			// Select PRI?
			if (nameIndex >= 0 && (pri2 == none || len(tmpPRI.playerName) > len(pri2.playerName))) {
				// Yes, no name has been found so far or a longer player name has been found.
				pri2 = tmpPRI;
				index2 = nameIndex;
			}
			
			// Continue with next player name.
			index++;
		}
		
	} else if (pri2 != none) {
		// Already got PRI, just find the index of the name.
		nameIndex = instr(msg, pri2.playerName);
		
		// Check for overlap.
		if (index1 >= 0 && nameIndex >= 0 && index1 <= nameIndex && nameIndex < index1 + len(pri1.playerName)) {
			// Overlap detected, check if name occurs after the first player name.
			nameIndex = instr(mid(msg, index1 + len(pri1.playerName)), pri2.playerName);
			if (nameIndex >= 0) {
				nameIndex += index1 + len(pri1.playerName);
			}
		}
		
		// Set index.
		index2 = nameIndex;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a message to the chatbox. The message is split in several parts, so each can
 *                be displayed in a specified color.
 *  $PARAM        col1   Color of the first part of the message.
 *  $PARAM        text1  First part of the message.
 *  $PARAM        col2   Color of the second part of the message.
 *  $PARAM        text2  Second part of the message.
 *  $PARAM        col3   Color of the third part of the message.
 *  $PARAM        text3  Third part of the message.
 *  $PARAM        col4   Color of the fourth part of the message.
 *  $PARAM        text4  Fourth part of the message.
 *  $PARAM        col5   Color of the fifth part of the message.
 *  $PARAM        text5  Fifth part of the message.
 *
 **************************************************************************************************/
simulated function addChatMsg(int col1, string text1,
                              optional int col2, optional string text2,
                              optional int col3, optional string text3,
                              optional int col4, optional string text4,
                              optional int col5, optional string text5) {
	local int index;
	
	// Find position in messages list.
	if (chatMsgCount < arrayCount(chatMessages)) {
		index = chatMsgCount;
		chatMsgCount++;
	} else {
		// List is full, shift messages.
		for (index = 1; index < chatMsgCount; index++) {
			chatMessages[index - 1] = chatMessages[index];
		}
		index = chatMsgCount - 1;
	}
	
	// Store message.
	chatMessages[index].text[0] = text1;
	chatMessages[index].text[1] = text2;
	chatMessages[index].text[2] = text3;
	chatMessages[index].text[3] = text4;
	chatMessages[index].text[4] = text5;
	chatMessages[index].col[0] = col1;
	chatMessages[index].col[1] = col2;
	chatMessages[index].col[2] = col3;
	chatMessages[index].col[3] = col4;
	chatMessages[index].col[4] = col5;
	chatMessages[index].timeStamp = timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a message to the area below the chatbox. The message is split in several
 *                parts, so each can be displayed in a specified color.
 *  $PARAM        col1   Color of the first part of the message.
 *  $PARAM        text1  First part of the message.
 *  $PARAM        col2   Color of the second part of the message.
 *  $PARAM        text2  Second part of the message.
 *  $PARAM        col3   Color of the third part of the message.
 *  $PARAM        text3  Third part of the message.
 *  $PARAM        col4   Color of the fourth part of the message.
 *  $PARAM        text4  Fourth part of the message.
 *  $PARAM        col5   Color of the fifth part of the message.
 *  $PARAM        text5  Fifth part of the message.
 *
 **************************************************************************************************/
simulated function addMsg(int col1, string text1,
                          optional int col2, optional string text2,
                          optional int col3, optional string text3,
                          optional int col4, optional string text4,
                          optional int col5, optional string text5) {
	local int index;
	
	// Find position in messages list.
	if (msgCount < arrayCount(messages)) {
		index = msgCount;
		msgCount++;
	} else {
		// List is full, shift messages.
		for (index = 1; index < msgCount; index++) {
			messages[index - 1] = messages[index];
		}
		index = msgCount - 1;
	}
	
	// Store message.
	messages[index].text[0] = text1;
	messages[index].text[1] = text2;
	messages[index].text[2] = text3;
	messages[index].text[3] = text4;
	messages[index].text[4] = text5;
	messages[index].col[0] = col1;
	messages[index].col[1] = col2;
	messages[index].col[2] = col3;
	messages[index].col[3] = col4;
	messages[index].col[4] = col5;
	messages[index].timeStamp = timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes/updates the variables used in the rendering procedure.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $ENSURE       c.font != none
 *
 **************************************************************************************************/
simulated function setup(Canvas c) {
	local int index;
	local bool bUpdateBase;
	
	// Make sure the font ain't none.
	if (baseFont == none) baseFont = getStaticSmallestFont(c.clipX);
	c.font = baseFont;
	
	// Get local PlayerPawn.
	player = c.viewport.actor;
	
	// Set base hud color.
	if (player == none || player.playerReplicationInfo == none || player.gameReplicationInfo == none) {
		baseHUDColor = baseColors[5];
	} else if (player.playerReplicationInfo.bIsSpectator &&
	    !player.playerReplicationInfo.bWaitingPlayer) {
		baseHUDColor = baseColors[4];
	} else if (!player.gameReplicationInfo.bTeamGame &&
		       ChallengeHUD(player.myHUD) != none) {
		baseHUDColor = ChallengeHUD(player.myHUD).favoriteHUDColor * 15.9;
	} else if (0 <= player.playerReplicationInfo.team && player.playerReplicationInfo.team <= 3) {
		baseHUDColor = baseColors[player.playerReplicationInfo.team];
	} else {
		baseHUDColor = baseColors[5];
	}
	
	// Prevent redundant setups.
	if (lastSetupTime == level.timeSeconds) {
		return;
	}

	// Timer control.
	timeSeconds += (level.timeSeconds - lastLevelTimeSeconds) / level.timeDilation;
	lastLevelTimeSeconds = level.timeSeconds;
		
	// Check if the base variables need to be updated.
	bUpdateBase = lastResX != c.clipX ||
	              lastResY != c.clipY;
	
	// Update HUD base variables.
	if (bUpdateBase) {	
		// General variables.
		baseFont = getStaticSmallestFont(c.clipX);
		c.font = baseFont;
		c.strLen("Online [00:00]", minPanelWidth, baseFontHeight);
		lastResX = c.clipX;
		lastResY = c.clipY;
		
		// Message box info.
		msgBoxWidth = int(c.clipX * 0.75);
		msgBoxLineHeight = int(baseFontHeight + 4.0);
		msgBoxHeight = msgBoxLineHeight * arrayCount(chatMessages);
	}
	
	// Remove expired messages.
	if (chatMsgCount > 0 && timeSeconds - chatMessages[0].timeStamp > chatMessageLifeTime) {
		for (index = 1; index < chatMsgCount; index++) {
			chatMessages[index - 1] = chatMessages[index];
		}
		chatMsgCount--;
		if (chatMsgCount == 0) {
			faceImg = none;
		}
	} 
	if (msgCount > 0 && timeSeconds - messages[0].timeStamp > messageLifeTime) {
		for (index = 1; index < msgCount; index++) {
			messages[index - 1] = messages[index];
		}
		msgCount--;
	} 
	
	lastSetupTime = level.timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the Nexgen HUD. Called before anything of the game HUD has been drawn.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *
 **************************************************************************************************/
simulated function preRenderHUD(Canvas c) {
	local int index;
	
	setup(c);
	
	for (index = 0; index < arrayCount(extensions); index++) {
		if (extensions[index] != none) {
			extensions[index].preRender(c);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the Nexgen HUD. Called after everything of the game HUD has been drawn.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *
 **************************************************************************************************/
simulated function postRenderHUD(Canvas c) {
	local int index;
	
	// Render the message box.
	if (client.bUseNexgenMessageHUD) {
		renderMessageBox(c);
	}
	
	// Render HUD extensions.
	for (index = 0; index < arrayCount(extensions); index++) {
		if (extensions[index] != none) {
			extensions[index].postRender(c);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the chat message box.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *
 **************************************************************************************************/
simulated function renderMessageBox(Canvas c) {
	local float panelWidth;
	local float panelHeight;
	local PanelInfo serverState;
	local PanelInfo clientState;
	local int index;
	local float cx;
	local float cy;
	
	// Initialize.
	panelHeight = int((msgBoxHeight - 3.0) / 2.0);
	serverState = getServerState();
	clientState = getClientState();
	panelWidth = fMax(getPanelWidth(serverState, c, panelHeight), getPanelWidth(clientState, c, panelHeight));
	
	// Background.
	c.style = ERenderStyle.STY_Translucent;
	c.drawColor = baseHUDColor * 0.4;
	c.setPos(1.0, 1.0);
	c.drawTile(Texture'grad64', msgBoxWidth - 2.0, msgBoxHeight - 2.0, 0.0, 0.0, 64.0, 64.0);
	
	// Borders.
	c.drawColor = baseHUDColor * 0.8;
	c.setPos(0.0, 0.0);
	c.drawTile(Texture'base', msgBoxWidth, 1.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(0.0, msgBoxHeight - 1.0);
	c.drawTile(Texture'base', msgBoxWidth, 1.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(msgBoxWidth - 1.0 - panelWidth, panelHeight + 1.0);
	c.drawTile(Texture'base', panelWidth, 1.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(0.0, 1.0);
	c.drawTile(Texture'base', 1.0, msgBoxHeight - 2.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(msgBoxWidth - 1.0, 1.0);
	c.drawTile(Texture'base', 1.0, msgBoxHeight - 2.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(msgBoxHeight - 1.0, 1.0);
	c.drawTile(Texture'base', 1.0, msgBoxHeight - 2.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(msgBoxWidth - 2.0 - panelWidth, 1.0);
	c.drawTile(Texture'base', 1.0, msgBoxHeight - 2.0, 0.0, 0.0, 1.0, 1.0);
	
	// Panels.
	renderPanel(serverState, c, panelHeight, msgBoxWidth - panelWidth - 1.0, 1.0);
	renderPanel(clientState, c, panelHeight, msgBoxWidth - panelWidth - 1.0, panelHeight + 2.0);
	
	// Face image.
	if (faceImg != none) {
		c.style = ERenderStyle.STY_Normal;
		c.drawColor = blankColor;
		c.setPos(1.0, 1.0);
		c.drawTile(faceImg, msgBoxHeight - 2.0, msgBoxHeight - 2.0, 0.0, 0.0, faceImg.uSize, faceImg.vSize);
     	c.style = ERenderStyle.STY_Translucent;
        c.drawColor = baseHUDColor * 0.25;
        c.setPos(1.0, 1.0);
        c.drawTile(Texture'LadrStatic.Static_a00', msgBoxHeight - 2.0, msgBoxHeight - 2.0, 0.0, 0.0,
                   Texture'LadrStatic.Static_a00'.uSize, Texture'LadrStatic.Static_a00'.vSize);
	} 
	
	// Typing prompt.
	if (player.player.console.bTyping) {
		renderTypingPromt(c, "(>" $ player.player.console.typedStr $ "_");
	}
	
	// Chat messages.
	cx = msgBoxHeight + 2.0;
	cy = (msgBoxLineHeight - baseFontHeight) / 2.0;
	for (index = 0; index < chatMsgCount; index++) {
		renderMessage(c, cx, cy, chatMessages[index]);
		cy += msgBoxLineHeight;
	}
	
	// Other messages.
	cx = 1.0;
	cy = msgBoxHeight + 2.0;
	if (player.player.console.bTyping) {
		cy += msgBoxLineHeight;
	}
	for (index = 0; index < msgCount; index++) {
		renderMessage(c, cx, cy, messages[index]);
		cy += baseFontHeight;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the typing promt for the chat message box.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *
 **************************************************************************************************/
simulated function renderTypingPromt(Canvas c, string msg) {
	local float msgOffset;
	
	// Background.
	c.style = ERenderStyle.STY_Translucent;
	c.drawColor = baseHUDColor * 0.4;
	c.setPos(1.0, msgBoxHeight);
	c.drawTile(Texture'grad32', msgBoxWidth - 2.0, msgBoxLineHeight - 1.0, 0.0, 0.0, 32.0, 32.0);
	
	// Borders.
	c.drawColor = baseHUDColor * 0.8;
	c.setPos(0.0, msgBoxHeight + msgBoxLineHeight - 1.0);
	c.drawTile(Texture'base', msgBoxWidth, 1.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(0.0, msgBoxHeight);
	c.drawTile(Texture'base', 1.0, msgBoxLineHeight - 1.0, 0.0, 0.0, 1.0, 1.0);
	c.setPos(msgBoxWidth - 1.0, msgBoxHeight);
	c.drawTile(Texture'base', 1.0, msgBoxLineHeight - 1.0, 0.0, 0.0, 1.0, 1.0);
	
	// Message.
	msgOffset = (msgBoxLineHeight - baseFontHeight) / 2.0;
	c.font = baseFont;
	c.style = ERenderStyle.STY_Normal;
	c.drawColor = colors[C_WHITE];
	c.setPos(msgOffset, msgOffset + msgBoxHeight);
	c.drawText(msg, false);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the specified message.
 *  $PARAM        c    Canvas object that provides the drawing capabilities.
 *  $PARAM        x    Horizontal offset.
 *  $PARAM        y    Vertical offset.
 *  $PARAM        msg  The message that is to be rendered.
 *  $REQUIRE      c != none && msg != none
 *
 **************************************************************************************************/
simulated function renderMessage(Canvas c, float x, float y, MessageInfo msg) {
	local float cx;
	local int msgIndex;
	local float msgWidth;
	local float msgHeight;
	local float lifeTime;
	local float blinkFactor;
	local float blinkIntensity;
	
	// Check if the message should blink.
	lifeTime = (timeSeconds - msg.timeStamp);
	if (bFlashMessages && lifeTime < messageBlinkTime) {
		blinkFactor = (1.0 + cos(lifeTime * 2 * pi * messageBlinkRate)) / 2.0;
		blinkIntensity = (1.0 - blinkFactor) * 255.0;
	}

	// Render message.
	cx = x;
	c.font = baseFont;
	c.style = ERenderStyle.STY_Normal;	
	for (msgIndex = 0; msgIndex < 5; msgIndex++) {
		c.setPos(cx, y);
		c.drawColor = colors[msg.col[msgIndex]];
		if (bFlashMessages && lifeTime < messageBlinkTime) {
			c.drawColor = c.drawColor * blinkColorDamp;
			c.drawColor.r = int(float(c.drawColor.r) * blinkFactor + blinkIntensity);
			c.drawColor.g = int(float(c.drawColor.g) * blinkFactor + blinkIntensity);
			c.drawColor.b = int(float(c.drawColor.b) * blinkFactor + blinkIntensity);
		}
		c.drawText(msg.text[msgIndex], false);
		c.strLen(msg.text[msgIndex], msgWidth, msgHeight);
		cx += msgWidth;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the current state of the server. The result will be stored in a
 *                PanelInfo struct so it can be immediately rendered.
 *  $RETURN       The current server state.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
simulated function PanelInfo getServerState() {
	local PanelInfo pInf;
	local string stateInfo;
	local int remainingTime;
	local int minutes, seconds;
	local name stateType;
	local byte bBlink;
	local int index;
	
	// Check current state.
	if (!client.bInitialized) {
		// Loading Nexgen.
		stateType = SS_Offline;
		pInf.text = client.lng.loadingState;
		pInf.textCol = colors[C_WHITE];
		pInf.bBlink = true;
		pInf.icon = Texture'offlineIcon';
		pInf.solidIcon = Texture'offlineIcon2';	
		
	} else if (player.bBadConnectionAlert) {
		// Server is offline.
		stateType = SS_Offline;
		if (client.sConf.autoReconnectTime > 0) {
			stateInfo = string(max(0, 1 + client.sConf.autoReconnectTime - (client.timeSeconds - client.badConnectionSince)));
			pInf.text = client.lng.format(client.lng.offlineStateRCN, stateInfo);
		} else {
			pInf.text = client.lng.offlineState;
		}
		pInf.textCol = colors[C_RED];
		pInf.icon = Texture'offlineIcon';
		pInf.solidIcon = Texture'offlineIcon2';	
		
	} else if (client.gInf.gameState == client.gInf.GS_Waiting) {
		// Waiting for players.
		stateType = SS_Waiting;
		if (client.gInf.countDown <= 0 || !client.sConf.enableNexgenStartControl) {
			pInf.text = client.lng.waitingStateUnknownTime;
		} else {
			pInf.text = client.lng.format(client.lng.waitingState, client.gInf.countDown);
		}
		pInf.textCol = colors[C_RED];		
		pInf.icon = Texture'waitIcon';
		pInf.solidIcon = Texture'waitIcon2';
		
	} else if (client.gInf.gameState == client.gInf.GS_Ready) {
		// Ready to start the game.
		stateType = SS_Ready;
		if (client.gInf.bTournamentMode) {
			pInf.text = client.lng.format(client.lng.readySignalWaitState,
			                              client.gInf.numReady,
			                              client.gInf.numRequiredReady);
		} else {
			pInf.text = client.lng.readyState;
		}
		pInf.textCol = colors[C_ORANGE];
		pInf.bBlink = true;
		pInf.icon = Texture'waitIcon';
		pInf.solidIcon = Texture'waitIcon2';
		
	} else if (client.gInf.gameState == client.gInf.GS_Starting) {
		// Game is starting.
		stateType = SS_Starting;
		pInf.text = client.lng.format(client.lng.startingState, client.gInf.countDown);
		pInf.textCol = colors[C_YELLOW];
		pInf.bBlink = true;
		pInf.icon = Texture'waitIcon';
		pInf.solidIcon = Texture'waitIcon2';
		
	} else if (client.gInf.gameState == client.gInf.GS_Ended) {
		// Game has ended.
		stateType = SS_Ended;
		pInf.text = client.lng.endedState;
		pInf.textCol = colors[C_YELLOW];
		pInf.icon = Texture'serverIcon';
		pInf.solidIcon = Texture'serverIcon2';
	
	} else if (level.pauser != "") {
		// Game has been paused.
		stateType = SS_Paused;
		pInf.text = client.lng.pausedState;
		pInf.textCol = colors[C_METAL];
		pInf.bBlink = true;
		pInf.icon = Texture'offlineIcon';
		pInf.solidIcon = Texture'offlineIcon2';
	
	} else if (client.sConf.matchModeActivated) {
		// Match in progress.
		stateType = SS_Match;
		remainingTime = player.gameReplicationInfo.remainingTime ;
		if (remainingTime > 0 && (remainingTime / matchInfoSwitchTime) % 2 == 1) {
			minutes = remainingTime / secPerMinute;
			seconds = remainingTime % secPerMinute;
			stateInfo = right("0" $ minutes, 2) $ ":" $ right("0" $ seconds, 2);
		} else {
			stateInfo = client.sConf.currentMatch $ "/" $ client.sConf.matchesToPlay;
		}
		pInf.text = client.lng.format(client.lng.matchState, stateInfo);
		pInf.textCol = colors[C_YELLOW];
		pInf.icon = Texture'matchIcon';
		pInf.solidIcon = Texture'matchIcon2';
		
	} else {
		// Game in progress.
		stateType = SS_Normal;
		remainingTime = player.gameReplicationInfo.remainingTime ;
		if (remainingTime > 0) {
			minutes = remainingTime / secPerMinute;
			seconds = remainingTime % secPerMinute;
			stateInfo = right("0" $ minutes, 2) $ ":" $ right("0" $ seconds, 2);
		} else {
			stateInfo = right("0" $ level.hour, 2) $ ":" $ right("0" $ level.minute, 2);
		}
		pInf.text = client.lng.format(client.lng.onlineState, stateInfo);
		pInf.textCol = colors[C_GREEN];
		pInf.icon = Texture'serverIcon';
		pInf.solidIcon = Texture'serverIcon2';
	}
	
	// Allow plugins to modify the state panel.
	bBlink = byte(pInf.bBlink);
	while (index < arrayCount(client.clientCtrl) && client.clientCtrl[index] != none) {
		if (client.clientCtrl[index].bCanModifyHUDStatePanel) {
			client.clientCtrl[index].modifyServerState(stateType, pInf.text, pInf.textCol,
			                                           pInf.icon, pInf.solidIcon, bBlink);
		}
		index++;
	}
	pInf.bBlink = bool(bBlink);
	
	// Return state panel.
	return pInf;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the current state of the client. The result will be stored in a
 *                PanelInfo struct so it can be immediately rendered.
 *  $RETURN       The current client state.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
simulated function PanelInfo getClientState() {
	local PanelInfo pInf;
	local string stateInfo;
	local byte protectTime;
	local name stateType;
	local byte bBlink;
	local int index;
	
	pInf.icon = Texture'playerIcon';
	pInf.solidIcon = Texture'playerIcon2';
	
	// Check current state.
	if (!client.loginComplete) {
		// Logging in to the server.
		stateType = CS_Login;
		pInf.text = client.lng.loginState;
		pInf.textCol = colors[C_WHITE];
		pInf.icon = Texture'LoginIcon';
		pInf.solidIcon = Texture'LoginIcon2';
		pInf.bBlink = true;
	
	} else if (client.idleTimeRemaining >= 0) {
		// Idle / camping.
		stateType = CS_Idle;
		stateInfo = string(client.idleTimeRemaining);
		pInf.text = client.lng.format(client.lng.idleState, stateInfo);
		pInf.textCol = colors[C_CYAN];
		pInf.icon = Texture'idleIcon';
		pInf.solidIcon = Texture'idleIcon2';
		pInf.bBlink = true;
	
	} else if (client.spawnProtectionTime > 0 ||
	           client.tkDmgProtectionTime > 0 ||
	           client.tkPushProtectionTime > 0) {
		// Client is damage protected.
		stateType = CS_Protected;
		protectTime = max(max(client.spawnProtectionTime,
		                      client.tkDmgProtectionTime),
		                      client.tkPushProtectionTime);
		pInf.text = client.lng.format(client.lng.protectedState, protectTime);
		if (client.tkDmgProtectionTime > 0) {
			pInf.textCol = colors[C_ORANGE];
		} else {
			pInf.textCol = colors[C_YELLOW];
		}
		pInf.icon = Texture'shieldIcon';
		pInf.solidIcon = Texture'shieldIcon2';	
	
	} else if (client.bMuted || client.gInf.bMuteAll) {
		// Client is muted.
		stateType = CS_Muted;
		pInf.text = client.lng.mutedState;
		pInf.textCol = colors[C_RED];	
		pInf.icon = Texture'mutedIcon';
		pInf.solidIcon = Texture'mutedIcon2';
	
	} else if (player.health <= 0) {
		// Player is dead.
		stateType = CS_Dead;
		pInf.text = client.lng.deadState;
		pInf.textCol = colors[C_RED];	
		
	} else {
		// Normal state.
		stateType = CS_Normal;
		pInf.text = client.title;
		if (client.bSpectator) {
			pInf.textCol = colors[C_CYAN];
			pInf.icon = Texture'specIcon';
			pInf.solidIcon = Texture'specIcon2';
		} else {
			pInf.textCol = colors[C_GREEN];
		}
	}
	
	// Allow plugins to modify the state panel.
	bBlink = byte(pInf.bBlink);
	while (index < arrayCount(client.clientCtrl) && client.clientCtrl[index] != none) {
		if (client.clientCtrl[index].bCanModifyHUDStatePanel) {
			client.clientCtrl[index].modifyClientState(stateType, pInf.text, pInf.textCol,
			                                           pInf.icon, pInf.solidIcon, bBlink);
		}
		index++;
	}
	pInf.bBlink = bool(bBlink);
	
	// Return state panel.
	return pInf;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the space necessary for the given panel if it is to be rendered.
 *  $PARAM        pInf         Panel contents.
 *  $PARAM        c            Canvas object that provides the drawing capabilities.
 *  $PARAM        panelHeight  Vertical space available for the panel (in pixels).
 *  $REQUIRE      pInf != none && c != none && panelHeight > 0
 *  $RETURN       
 *  $ENSURE       result > 0
 *
 **************************************************************************************************/
simulated function float getPanelWidth(PanelInfo pInf, canvas c, float panelHeight) {
	local float separatorWidth;
	local float width;
	local float temp;
	
	// Get text width.
	separatorWidth = int(baseFontHeight * 0.4);
	c.font = baseFont;
	c.strLen(pInf.text, width, temp);
	width = fMax(minPanelWidth, width);
	
	// And add icon and separator width.
	if (pInf.icon == none) {
		width += 2.0 * separatorWidth;
	} else {
		if (iconSize > panelHeight) {
			width += panelHeight + 3.0 * separatorWidth;
		} else {
			width += iconSize + 3.0 * separatorWidth;
		}
	}
	
	return width;
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders a panel with the specified contents at the given location.
 *  $PARAM        pInf         Panel contents.
 *  $PARAM        c            Canvas object that provides the drawing capabilities.
 *  $PARAM        panelHeight  Vertical space available for the panel (in pixels).
 *  $PARAM        x            Horizontal offset.
 *  $PARAM        y            Vertical offset.
 *  $REQUIRE      pInf != none && c != none && panelHeight > 0
 *
 **************************************************************************************************/
simulated function renderPanel(PanelInfo pInf, canvas c, float panelHeight, float x, float y) {
	local float separatorWidth;
	local float cx;
	local float cy;
	local float iconHeight;
	local float lifeTime;
	local float blinkFactor;
	local float blinkIntensity;
	
	if (pInf.bBlink) {
		blinkFactor = (1.0 + cos(timeSeconds * 2 * pi * panelBlinkRate)) / 2.0;
		blinkIntensity = (1.0 - blinkFactor) * 255.0;
	}
			
	separatorWidth = int(baseFontHeight * 0.4);
	
	// Draw icon.
	cx = x + separatorWidth;
	if (pInf.icon != none) {
		if (iconSize > panelHeight) {
			iconHeight = panelHeight;
			cy = y;
		} else {
			iconHeight = iconSize;
			cy = y + int((panelHeight - iconSize) / 2.0);
		}
		
		c.style = ERenderStyle.STY_Translucent;
		c.drawColor = blankColor;
		c.setPos(cx, cy);
		c.drawTile(pInf.icon, iconHeight, iconHeight, 0.0, 0.0, iconSize, iconSize);
		if (pInf.solidIcon != none) {
			c.style = ERenderStyle.STY_Normal;
			c.setPos(cx, cy);
			c.drawTile(pInf.solidIcon, iconHeight, iconHeight, 0.0, 0.0, iconSize, iconSize);
		}
		
		cx += separatorWidth + iconHeight;
	}
	
	// Draw the text.
	cy = y + (panelHeight - baseFontHeight) / 2.0;
	c.style = ERenderStyle.STY_Normal;
	c.drawColor = pInf.textCol;
	if (pInf.bBlink) {
		c.drawColor = c.drawColor * blinkColorDamp;
		c.drawColor.r = int(float(c.drawColor.r) * blinkFactor + blinkIntensity);
		c.drawColor.g = int(float(c.drawColor.g) * blinkFactor + blinkIntensity);
		c.drawColor.b = int(float(c.drawColor.b) * blinkFactor + blinkIntensity);
	}
	c.setPos(cx, cy);
	c.font = baseFont;
	c.drawText(pInf.text, false);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the color for the specified player.
 *  $PARAM        pri  Replication info of the player whose color is to be returned.
 *  $RETURN       The color of the player (index in the base color palette).
 *  $ENSURE       0 <= result && result < arrayCount(colors)
 *
 **************************************************************************************************/
simulated function int getPlayerColor(PlayerReplicationInfo pri) {
	local int colorNum;
	
	if (pri.bIsSpectator && !pri.bWaitingPlayer) {
		colorNum = C_METAL;
	} else if (0 <= pri.team && pri.team <= 3) {
		colorNum = pri.team;
	} else {
		colorNum = C_WHITE;
	}
	
	return colorNum;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Registers a new HUD extension so that it will receive preRender and postRender
 *                calls.
 *  $PARAM        extension  The HUD extenstion that is to be added.
 *  $REQUIRE      extension != none
 *
 **************************************************************************************************/
simulated function addHUDExtension(NexgenHUDExtension extension) {
	local int index;
	local bool bFound;
	
	while (!bFound && index < arrayCount(extensions)) {
		if (extensions[index] == none) {
			extensions[index] = extension;
			bFound = true;
		} else {
			index++;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves a small font size for the specified canvas width.
 *  $PARAM        width  The width of the canvas in pixels.
 *  $RETURN       A small font.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
static function Font getStaticSmallestFont(float width) {
	if (width < 640) {
		return Font'SmallFont';
	} else if (width < 800) {
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	} else if (width < 1024) {
		return Font(DynamicLoadObject("LadderFonts.UTLadder12", class'Font'));
	} else {
		return Font(DynamicLoadObject("LadderFonts.UTLadder14", class'Font'));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	blankColor=(R=255,G=255,B=255)
	baseColors(0)=(R=255,G=16,B=16)     // Red team
	baseColors(1)=(R=16,G=16,B=255)     // Blue team
	baseColors(2)=(R=16,G=250,B=16)     // Green team
	baseColors(3)=(R=250,G=250,B=16)    // Yellow team
	baseColors(4)=(R=150,G=150,B=255)   // Spectator
	baseColors(5)=(R=255,G=255,B=255)   // No team
	colors(0)=(R=250,G=90,B=90)		    // Red
	colors(1)=(R=90,G=90,B=255)		    // Blue
	colors(2)=(R=90,G=250,B=90)		    // Green
	colors(3)=(R=250,G=250,B=90)	    // Yellow
	colors(4)=(R=255,G=255,B=255)       // White
	colors(5)=(R=0,G=0,B=0)			    // Black
	colors(6)=(R=250,G=50,B=200)	    // Pink
	colors(7)=(R=50,G=250,B=250)	    // Cyan
	colors(8)=(R=150,G=150,B=250)	    // Metal
	colors(9)=(R=250,G=150,B=50)	    // Orange
	colors(10)=(R=150,G=10,B=0)	        // Dark red
}
