/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenWRRegisterServer
 *  $VERSION      1.00 (15-03-2010 23:27)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Web request handler for registering the server in the Nexgen server database.
 *
 **************************************************************************************************/
class NexgenWRRegisterServer extends NexgenWebRequest;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the web request data for this web request.
 *  $PARAM        control  Reference to the Nexgen server controller.
 *  $REQUIRE      control != none
 *
 **************************************************************************************************/
function loadRequestData(NexgenController control) {
	requestData.set("server_id", control.sConf.serverID);
	requestData.set("ver", class'NexgenUtil'.default.versionCode);
	requestData.set("port", level.game.getServerPort());
	requestData.set("name", control.sConf.serverName);
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
	destroy();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	host="130.89.163.70"
	requestURL="/regnscsvr.php"
}