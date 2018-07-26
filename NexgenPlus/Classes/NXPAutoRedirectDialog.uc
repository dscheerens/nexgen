/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPAutoRedirectDialog
 *  $VERSION      1.02 (08-09-2010 17:08)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the server is full. 
 *
 **************************************************************************************************/
class NXPAutoRedirectDialog extends NexgenPopupDialog;

var bool bCancelClicked;                          // Whether the user has already clicked cancel.
var bool bCountDownStarted;                       // Whether the redirect count down has been started.
var bool bConnecting;                             // Whether the user is connecting to the alternate
                                                  // server.
var string serverUrl;                             // URL of the alternate server.

var UWindowSmallButton cancelButton;              // Reconnect button component.
var UMenuLabelControl countDownLabel;             // Count down timer text.
var UMenuLabelControl serverLabel;                // Indicates the server to which the player is
                                                  // being redirected.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string serverText;                  // Title text for the server label.
var localized string cancelText;                  // Text to display on the reconnect button.
var localized string reconnectText;               // Text to display on the reconnect button.
var localized string countDownText;               // Count down label text.
var localized string countDownSuffix;             // Count down timer suffix text.
var localized string connectingText;              // Connection to server status text.
var localized string redirectCancelledText;       // Text to display if automatic redirect has been
                                                  // cancelled.

var float timeSeconds;                            // Number of seconds that elapsed since the window
                                                  // has been created.
var float countDownStartTime;                     // Time at which the countdown has been started.

const openCommand = "Open";                       // Console command for opening an URL.
const cancelCommand = "Cancel";                   // Console command to cancel connecting.
const reconnectCommand = "Reconnect";             // Console command for reconnecting.
const autoRedirectDelay = 8.0;                    // Number of seconds to wait before automatically
                                                  // redirecting player.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
 *  $ENSURE       reconnectButton != none && spectatorButton != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	local float cy;
	
	super.created();
	
	// Add components.
	cy = borderSize;
	
	addText(caption, cy, F_Bold, TA_Center);
	addNewLine(cy);
	addText(message, cy, F_Normal, TA_Left);
	addNewLine(cy);
	countDownLabel = addPropertyLabel(cy, countDownText, 80.0);
	serverLabel = addPropertyLabel(cy, serverText, 80.0);
	
	cancelButton = addButton(cancelText, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        serverName  Name of the server where the player is being redirected to.
 *  $PARAM        serverUrl   Url of the server.
 *  $PARAM        str3        Not used.
 *  $PARAM        str4        Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string serverName, optional string serverUrl, optional string str3, optional string str4) {
	self.serverUrl = serverUrl;
	countDownStartTime = timeSeconds;
	bCountDownStarted = true;
	serverLabel.setText(serverName @ "(" $ serverUrl $ ")");
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *                Checks if the reconnect or spectator buttons have been clicked and deals with it
 *                accordingly.
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType){
	super.notify(control, eventType);
	
	if (control != none && control.isA('UWindowSmallButton') && eventType == DE_Click) {
		switch (control) {
			// Cancel button.
			case cancelButton:
				if (bCancelClicked) {
					getPlayerOwner().consoleCommand(reconnectCommand);
					close();
				} else {
					if (bConnecting) {
						getPlayerOwner().consoleCommand(cancelCommand);
					}
					countDownLabel.setText(redirectCancelledText);
					cancelButton.setText(reconnectText);
					bCancelClicked = true;
				}
				break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function. Called when the game performs its next tick.
 *                The following actions are performed:
 *                 - Check if automatic redirect count down timer has expired.
 *  $PARAM        delta  Time elapsed (in seconds) since the last tick.
 *  $OVERRIDE     
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	local float timeRemaining;
	
	// Update timeSeconds.
	timeSeconds += deltaTime;
	
	// Update countdown timer.
	if (bCountDownStarted && !bCancelClicked && !bConnecting) {
		timeRemaining = fmax(autoRedirectDelay + countDownStartTime - timeSeconds, 0);
		
		if (timeRemaining > 0) {
			countDownLabel.setText(class'NXPUtil'.static.ceil(timeRemaining) @ countDownSuffix);
		} else {
			bConnecting = true;
			countDownLabel.setText(connectingText);
			getPlayerOwner().consoleCommand(openCommand @ serverUrl);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the window that a new level is going to be loaded.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notifyBeforeLevelChange() {
	super.notifyBeforeLevelChange();
	
	// Make sure window is closed.
	if (bConnecting) {
		close();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	caption="Failed to login: server is full."
	message="The server you have tried to enter has no more player slots available. You are automatically being redirected to an alternate server. If you do not wish to be redirected you can cancel the automatic redirection by clicking cancel."
	countDownText="Connecting in:"
	serverText="Connecting to:"
	cancelText="Cancel"
	reconnectText="Reconnect"
	countDownSuffix="seconds..."
	connectingText="Connecting now..."
	redirectCancelledText="Cancelled"
}