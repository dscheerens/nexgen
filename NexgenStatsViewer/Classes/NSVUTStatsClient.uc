/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $CLASS        NSVUTStatsClient
 *  $VERSION      1.03 (21-12-2010 13:20:34)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  The HTTP client used to retrieve statistics from UTStats.
 *
 **************************************************************************************************/
class NSVUTStatsClient extends UBrowserHTTPClient;

var NSVMain xControl;                   // Stats viewer controller.

var int listIndex;                      // Current list index.
var int playerIndex;                    // Current player index.

// Commands.
const CMD_BeginList = "BEGINLIST";      // Begins a new list of best players.
const CMD_AddPlayer = "ADDPLAYER";      // Adds a new player to the current list.

// Command arguments.
const CMD_BeginList_ListName = 0;

const CMD_AddPlayer_PlayerName = 0;
const CMD_AddPlayer_Score = 1;
const CMD_AddPlayer_Country = 2;
const CMD_AddPlayer_rankChange = 3;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the UTStats statistics retriever client.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	local string url;
	
	super.preBeginPlay();
	
	listIndex = -1;
	
	// Get controller.
	foreach allActors(class'NSVMain', xControl) {
		break;
	}
	
	// Construct url to retrieve the stats.
	url = xControl.conf.utStatsPath; // $ scriptArgumentStart $ gameArgument $ level.game.class;
	
	// Retrieve stats.
	browse(xControl.conf.utStatsHost, url, xControl.conf.utStatsPort);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function HTTPError(int code) {
	xControl.control.nscLog(class'NexgenUtil'.static.format(xControl.lng.utstatsRetrieveFailedMsg, code));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request has been replied and the data has been received.
 *  $PARAM        data  The data that has been received.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function HTTPReceivedData(string data) {
	local string remaining;
	local string currLine;
	
	// Process data.
	remaining = data;
	do {
		currLine = class'NexgenUtil'.static.trim(class'NexgenUtil'.static.getNextLine(remaining));
		if (currLine != "") {
			processData(currLine);
		}
	} until (remaining == "");
	
	// Update checksum.
	xControl.statsRI.playerListChecksum = xControl.statsRI.calcPlayerListChecksum();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Splits the given string in two parts: the first line and the rest.
 *  $PARAM        str  The string that should be splitted.
 *  $RETURN       The first line in the given string.
 *
 **************************************************************************************************/
function processData(string str) {
	local string cmdType;
	local string cmdArgs[10];
	local int index;
	local bool bFound;
	local int port;
	local int queryPort;
	
	// Parse command.
	if (class'NexgenUtil'.static.parseCmd(str, cmdType, cmdArgs)) {
		switch (cmdType) {
			case CMD_BeginList: // Add a new player list.
				listIndex++;
				
				// Check index.
				if (0 <= listIndex && listIndex < arrayCount(xControl.statsRI.listName)) {
					// Store list name.
					xControl.statsRI.listName[listIndex] = cmdArgs[CMD_BeginList_ListName];
				}

				break;
				
			case CMD_AddPlayer: // A a new player to the list.

				// Check index.
				if (0 <= listIndex && listIndex < arrayCount(xControl.statsRI.listName) &&
				    0 <= playerIndex && playerIndex < arrayCount(xControl.statsRI.playerName)) {
					// Store player info.
					xControl.statsRI.playerName[playerIndex] = cmdArgs[CMD_AddPlayer_PlayerName];
					xControl.statsRI.score[playerIndex] = cmdArgs[CMD_AddPlayer_Score];
					xControl.statsRI.country[playerIndex] = cmdArgs[CMD_AddPlayer_Country];
					switch (cmdArgs[CMD_AddPlayer_rankChange]) {
						case "UP":   xControl.statsRI.positionChange[playerIndex] = xControl.statsRI.PC_MovedUp; break;
						case "DOWN": xControl.statsRI.positionChange[playerIndex] = xControl.statsRI.PC_MovedDown; break;
						case "NC":   xControl.statsRI.positionChange[playerIndex] = xControl.statsRI.PC_NoChange; break;
						default:     xControl.statsRI.positionChange[playerIndex] = xControl.statsRI.PC_NotAvailable; break;
					}
					
					// Increase list size.
					xControl.statsRI.listLength[listIndex]++;
					playerIndex++;
				}

				break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	remoteRole=ROLE_None
}