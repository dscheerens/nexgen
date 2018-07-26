/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPUpdateCheckWR
 *  $VERSION      1.00 (03-08-2010 17:57)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Web request handler for checking for Nexgen updates.
 *
 **************************************************************************************************/
class NXPUpdateCheckWR extends NexgenWebRequest;

var NXPMain xControl;                   // The plugin controller object.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads and executes the web request data for this web request.
 *  $PARAM        xControl  Reference to the plugin server controller.
 *  $REQUIRE      xControl != none
 *
 **************************************************************************************************/
function sendRequest(NXPMain xControl) {
	self.xControl = xControl;
	
	// Send the web request.
	executeRequest();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the last attempt at executing the web request has failed. Once this
 *                function is called there will be no more attempts to make a connection with the
 *                web service and executing the request.
 *  $PARAM        errorCode  The error code indicating the kind of failure that has occurred.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function lastAttemptFailed(int errorCode) {
	destroy();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the web request was successfully completed.
 *  $PARAM        response  Optional response message recieved from the web service.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function requestCompleted(string response) {
	local string remainingData;
	local string command;
	
	// Process data.
	remainingData = response;
	do {
		command = class'NexgenUtil'.static.trim(class'NexgenUtil'.static.getNextLine(remainingData));
		if (command != "") {
			processCommand(command);
		}
	} until (remainingData == "");
	
	// We do no longer need this object.
	destroy();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Processes the specified command string.
 *  $PARAM        str  The command string that is to be proccessed.
 *
 **************************************************************************************************/
function processCommand(string str) {
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
				xControl.latestNexgenVersion = int(value);
				if (xControl.latestNexgenVersion > class'NexgenUtil'.default.versionCode) {
					xControl.control.nscLog(xControl.lng.updateAvailableMsg);
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
	host="130.89.163.70"
	requestURL="/nexgen_update.txt"
}