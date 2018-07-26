/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenHTTPClient
 *  $VERSION      1.01 (15-03-2010 22:26)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Advanced version of the UBrowserHTTPClient that supports POST requests.
 *
 **************************************************************************************************/
class NexgenHTTPClient extends UBrowserHTTPClient;

var byte requestMode;                   // HTTP request mode.
var string postData;                    // Data to be send with the post request.

const RM_Get = 0;                       // HTTP GET request.
const RM_Post = 1;                      // HTTP POST request.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Puts the HTTP client in GET request mode.
 *
 **************************************************************************************************/
function setGetRequestMode() {
	requestMode = RM_Get;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Puts the HTTP client in POST request mode.
 *  $PARAM        postData  An map containing the data to be send with the post request.
 *
 **************************************************************************************************/
function setPostRequestMode(optional NexgenStringMap postData) {
	local int numArgs;
	local int index;
	local string key;
	local string value;
	
	requestMode = RM_Post;
	self.postData = "";
	
	// Encode post data.
	if (postData != none) {
		numArgs = postData.size();
		for (index = 0; index < numArgs; index++) {
			postData.getElement(index, key, value);
			key = class'NexgenUtil'.static.urlEncode(key);
			value = class'NexgenUtil'.static.urlEncode(value);
			if (index > 0) {
				self.postData = self.postData $ "&";
			}
			self.postData = self.postData $ key $ "=" $ value;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Clears the I/O buffers for the TCP link.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function resetBuffer() {
	super.resetBuffer();
	CRLF = chr(13) $ chr(10); // Fix the CRLF bug.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the connection with the HTTP server has opened. Once called this
 *                function will send the HTTP request to the server.
 *  $OVERRIDE
 *
 **************************************************************************************************/
event opened() {
	local string request;
	
	// Enable tick event to check for incoming data.
	enable('Tick');
	
	// Send request header.
	if (requestMode == RM_Post) {
		request = "POST";
	} else {
		request = "GET";
	}
	if (proxyServerAddress != "") {
		sendBufferedData(request $ " http://" $ serverAddress $ ":" $ string(serverPort) $ serverURI $ " HTTP/1.1" $ CRLF);
	} else {
		sendBufferedData(request $ " " $ serverURI $ " HTTP/1.1" $ CRLF);
	}
	sendBufferedData("User-Agent: Unreal" $ CRLF);
	sendBufferedData("Connection: close" $ CRLF);
	sendBufferedData("Host: " $ serverAddress $ ":" $ serverPort $ CRLF);
	
	// Send request body.
	if (requestMode == RM_Post && len(postData) > 0) {
		sendBufferedData("Content-Type: application/x-www-form-urlencoded" $ CRLF);
		sendBufferedData("Content-Length: " $ string(len(postData)) $ CRLF $ CRLF);
		sendBufferedData(postData);
	}
	sendBufferedData(CRLF);

	// Update current state.
	currentState = waitingForHeader;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	remoteRole=ROLE_None
}