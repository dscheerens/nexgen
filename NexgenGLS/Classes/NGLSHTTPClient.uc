/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSHTTPClient
 *  $VERSION      1.05 (23-12-2009 18:25)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  The HTTP client used to verify login information.
 *
 **************************************************************************************************/
class NGLSHTTPClient extends UBrowserHTTPClient;

var NGLSMain xControl;                  // Global login system controller.
var NGLSClient xClient;                 // The client that is being checked.

// Commands.
const CMD_AcceptLogin = "ACCEPT";       // Accepts the login request of a player.
const CMD_RejectLogin = "REJECT";       // Rejects the login request of a player.

// Command arguments.
const CMD_AcceptLogin_GameID = 0;
const CMD_AcceptLogin_PlayerNum = 1;

const CMD_RejectLogin_GameID = 0;
const CMD_RejectLogin_PlayerNum = 1;
const CMD_RejectLogin_Reason = 2;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the UTStats statistics retriever client.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	super.preBeginPlay();
	
	// Get client & controller.
	foreach allActors(class'NGLSMain', xControl) {
		break;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends a HTTP get request to the server to check the login information for the
 *                specified client.
 *  $PARAM        xClient  The client for which the login information is to be checked.
 *  $REQUIRE      xClient != none
 *
 **************************************************************************************************/
function verifyLoginInfo(NGLSClient xClient) {
	local string url;
	
	self.xClient = xClient;
			
	xControl.nglsLog(class'NexgenUtil'.static.format(xControl.lng.startCheckMsg, xClient.client.playerName));
	
	// Construct request url.
	url = xControl.xConf.nglsServerPath $
	      "?checkplayer=" $ xClient.client.playerNum $
	      "&gameid="      $ xControl.gameID $
	      "&username="    $ class'NexgenUtil'.static.urlEncode(xClient.loginUsername) $
	      "&password="    $ xClient.loginPasswordHash;

	// Send request.
	browse(xControl.xConf.nglsServerHost, url, xControl.xConf.nglsServerPort);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function HTTPError(int code) {
	// Notify the client that the check has failed.
	xClient.checkFailed(code);
	
	// Destroy HTTP client, since it's no longer used.
	destroy();
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
	
	setTimer(0, false);
	
	// Process data.
	remaining = data;
	do {
		currLine = class'NexgenUtil'.static.trim(class'NexgenUtil'.static.getNextLine(remaining));
		if (currLine != "") {
			processData(currLine);
		}
	} until (remaining == "");
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
	//local NGLSClient xClient;
	
	// Parse command.
	if (class'NexgenUtil'.static.parseCommandStr("nsc" @ str, cmdType, cmdArgs)) {
		switch (cmdType) {
			case CMD_AcceptLogin:
				if (cmdArgs[CMD_AcceptLogin_GameID] == xControl.gameID) {
					//xClient = xControl.getClientByNum(int(cmdArgs[CMD_AcceptLogin_PlayerNum]));
					if (xClient != none) {
						xClient.acceptLogin();
					}
				}
				break;
				
			case CMD_RejectLogin:
				if (cmdArgs[CMD_RejectLogin_GameID] == xControl.gameID) {
					//xClient = xControl.getClientByNum(int(cmdArgs[CMD_RejectLogin_PlayerNum]));
					if (xClient != none) {
						xClient.rejectLogin(cmdArgs[CMD_RejectLogin_Reason]);
					}
				}
				break;
		}
	}
	
	// Destroy HTTP client, since it's no longer used.
	destroy();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	remoteRole=ROLE_None
}