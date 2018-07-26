/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenWebRequestHTTPClient
 *  $VERSION      1.00 (04-03-2010 22:53)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  HTTP Client for web requests.
 *
 **************************************************************************************************/
class NexgenWebRequestHTTPClient extends NexgenHTTPClient;

var NexgenWebRequest requestHandler;    // The web request handler.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request failed.
 *  $PARAM        code  The error code indicating the kind of failure that has occurred.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function HTTPError(int code) {
	if (requestHandler != none) {
		requestHandler.notifyRequestError(code);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the HTTP request has completed and the reponse message has been
 *                recieved.
 *  $PARAM        data  The data that has been received.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function HTTPReceivedData(string data) {
	if (requestHandler != none) {
		requestHandler.requestCompleted(data);
	}
}

