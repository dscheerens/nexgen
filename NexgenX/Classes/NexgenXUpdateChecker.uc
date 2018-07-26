/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXUpdateChecker
 *  $VERSION      1.01 (23-12-2009 17:47)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  The HTTP client used to check if there is a new version of Nexgen available.
 *
 **************************************************************************************************/
class NexgenXUpdateChecker extends UBrowserHTTPClient;

var NexgenX xControl;                             // Extension controller.

var int latestVersion;                            // The latest version of Nexgen that is available.
var bool bUpdateAvailable;                        // Whether there is an update available.

// Settings.
const updateServerHost = "130.89.163.70";
const updateServerPath = "/nexgen_update.txt";
const updateServerPort = 80;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks for an update of Nexgen.
 *
 **************************************************************************************************/
function preBeginPlay() {
	super.preBeginPlay();
	
	foreach allActors(class'NexgenX', xControl) {
		break;
	}
	
	browse(updateServerHost, updateServerPath, updateServerPort);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request failed.
 *
 **************************************************************************************************/
function HTTPError(int code) {
	xControl.control.nscLog(class'NexgenUtil'.static.format(xControl.lng.updateCheckFailedMsg, code));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request has been replied and the data has been received.
 *  $PARAM        data  The data that has been received.
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
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Processes the specified string.
 *
 **************************************************************************************************/
function processData(string str) {
	local string key;
	local string value;
	
	// Check format
	if (instr(str, ":") > 0) {
		class'NexgenUtil'.static.split2(str, key, value, ":");
		key = class'NexgenUtil'.static.trim(key);
		value = class'NexgenUtil'.static.trim(value);
		
		// Check key.
		switch (key) {
			
			// Latest Nexgen version.
			case "latest-version":
				latestVersion = int(value);
				if (latestVersion > class'NexgenUtil'.default.versionCode) {
					xControl.control.nscLog(xControl.lng.updateAvailableMsg);
					bUpdateAvailable = true;
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