/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenWebRequest
 *  $VERSION      1.01 (15-03-2010 22:17)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Web request handler class. This class can be used to make a request on a web
 *                service using HTTP POST requests. 
 *
 **************************************************************************************************/
class NexgenWebRequest extends Info;

var string host;                        // Host name of the web service.
var string requestURL;                  // URL of the web service.
var int port;                           // Port of the web server.
var int maxAttempts;                    // Maximum number of attempts to execute the request.
var int responseTimeout;                // Number of seconds to wait for a response.
var float attemptInterval;              // Time to wait before a new attempt to execute the request is made.

var int numAttempts;                    // Number of attempts that have been executed.
var NexgenStringMap requestData;        // Data that is to be send with the request.
var NexgenWebRequestHTTPClient webClient; // Currently active HTTP client.
var float nextAttemptCountdown;         // Countdown timer for the next request attempt.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the web request.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	requestData = spawn(class'NexgenStringMap');
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the request to the web server.
 *
 **************************************************************************************************/
function executeRequest() {
	doNextAttempt();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Runs the next request attempt.
 *
 **************************************************************************************************/
function doNextAttempt() {
	if (numAttempts < maxAttempts) {
		numAttempts++;
		discardWebClient();
		createWebClient();
		webClient.setPostRequestMode(requestData);
		webClient.browse(host, requestURL, port, responseTimeout);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Callback function for the web client in case an error has occurred.
 *  $PARAM        errorCode  The error code indicating the kind of failure that has occurred.
 *
 **************************************************************************************************/
function notifyRequestError(int errorCode) {
	attemptFailed(numAttempts, errorCode);
	if (numAttempts < maxAttempts) {
		scheduleNextAttempt();
	} else {
		lastAttemptFailed(errorCode);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Schedules the next request attempt in this web request handler. If the attempt
 *                interval is zero the next attempt will immediately be performed.
 *
 **************************************************************************************************/
function scheduleNextAttempt() {
	if (attemptInterval > 0) {
		nextAttemptCountdown = attemptInterval;
	} else {
		doNextAttempt();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function. Called when the game performs its next tick.
 *                The following actions are performed:
 *                 - Check for scheduled attempts to execute a web request.
 *  $PARAM        delta  Time elapsed (in seconds) since the last tick.
 *  $OVERRIDE     
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	if (nextAttemptCountdown > 0) {
		nextAttemptCountdown -= deltaTime / level.timeDilation;
		if (nextAttemptCountdown <= 0) {
			nextAttemptCountdown = 0;
			doNextAttempt();
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a HTTP client for the web request.
 *  $ENSURE       webClient != none
 *
 **************************************************************************************************/
function createWebClient() {
	if (webClient == none) {
		webClient = spawn(class'NexgenWebRequestHTTPClient');
		webClient.requestHandler = self;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Discards the currently active HTTP client.
 *  $ENSURE       webClient == none
 *
 **************************************************************************************************/
function discardWebClient() {
	if (webClient != none) {
		webClient.requestHandler = none;
		webClient.destroy();
		webClient = none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the actor is destroyed and it will no longer be used during the game.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function destroyed() {
	discardWebClient();
	if (requestData != none) {
		requestData.destroy();
		requestData = none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when an attempt at executing the web request has failed.
 *  $PARAM        attemptNum  The number of failed attempts to execute the request.
 *  $PARAM        errorCode  The error code indicating the kind of failure that has occurred.
 *
 **************************************************************************************************/
function attemptFailed(int attemptNum, int errorCode) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the last attempt at executing the web request has failed. Once this
 *                function is called there will be no more attempts to make a connection with the
 *                web service and executing the request.
 *  $PARAM        errorCode  The error code indicating the kind of failure that has occurred.
 *
 **************************************************************************************************/
function lastAttemptFailed(int errorCode) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the web request was successfully completed.
 *  $PARAM        response  Optional response message recieved from the web service.
 *
 **************************************************************************************************/
function requestCompleted(string response) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	port=80
	maxAttempts=3
	responseTimeout=10
	attemptInterval=1.0
}

