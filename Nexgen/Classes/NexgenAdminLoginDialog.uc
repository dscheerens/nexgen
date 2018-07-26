/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenAdminLoginDialog
 *  $VERSION      1.00 (27-10-2007 18:41)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the player has entered an invalid password. 
 *
 **************************************************************************************************/
class NexgenAdminLoginDialog extends NexgenPopupDialog;

var UWindowSmallButton loginButton;               // Spectator button component.
var UWindowEditControl passwordInput;             // Password input field component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string passwordText;                // Label to display before the password field.
var localized string loginText;                   // Text to display on the login button.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
 *  $ENSURE       reconnectButton != none && spectatorButton != none && passwordInput != none
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
	passwordInput = addEditControl(cy, passwordText, 64.0);
	
	loginButton = addButton(loginText, 64.0);
	
	// Set component properties.
	passwordInput.setMaxLength(32);
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
function notify(UWindowDialogControl control, byte eventType) {
	local string password;
	local NexgenClientCore rpci;
	
	super.notify(control, eventType);
	
	// Login button.
	if (control == loginButton && eventType == DE_Click) {
		close();
		password = class'NexgenUtil'.static.trim(passwordInput.getValue());
		rpci = NexgenClientCore(client.getController(class'NexgenClientCore'.default.ctrlID));
		if (password != "" && rpci != none) {
			rpci.adminLogin(password);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	wrapLength=79
	caption="Administrator login."
	message="Please enter your administrator password below and click login. If no account passwords have been set you can login as root administrator by entering the server admin password."
	passwordText="Password:"
	loginText="Login"
}