/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSLoginDialog
 *  $VERSION      1.01 (1-11-2008 20:41)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog that will be displayed if the username and password of player have to be
 *                entered.
 *
 **************************************************************************************************/
class NGLSLoginDialog extends NexgenPopupDialog;

var UWindowSmallButton registerButton;            // Register button component.
var UWindowSmallButton reconnectButton;           // Reconnect button component.
var UWindowSmallButton spectatorButton;           // Spectator button component.
var UWindowEditControl usernameInput;             // Password input field component.
var UWindowEditControl passwordInput;             // Password input field component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string usernameText;                // Label to display before the username field.
var localized string passwordText;                // Label to display before the password field.
var localized string reconnectText;               // Text to display on the reconnect button.
var localized string spectatorText;               // Text to display on the spectator button.
var localized string registerText;                // Text to display on the register button.

var string registerURL;                           // The URL of the website where the player can register.

const SSTR_NGLSUserName = "NGLSUserName";         // NGLS login user name.
const SSTR_NGLSPassword = "NGLSPassword";         // NGLS login password.
const SSTR_OverrideClass = "OverrideClass";       // Override class setting string.
const reconnectCommand = "Reconnect";             // Console command for reconnecting.
const openURLCommand = "open";                    // Console command for opening an URL.
const spectatorClass = "Botpack.CHSpectator";     // Override class to use for spectators.



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
	usernameInput = addEditControl(cy, usernameText, 64.0);
	cy += 2;
	passwordInput = addEditControl(cy, passwordText, 64.0);
	
	registerButton = addButton(registerText, 64.0);
	spectatorButton = addButton(spectatorText, 64.0);
	reconnectButton = addButton(reconnectText, 64.0);
	
	// Set component properties.
	usernameInput.setMaxLength(64);
	passwordInput.setMaxLength(64);
	
	setControlFocus();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        allowSpecs   Indicates if reconnecting as spectator should be allowed.
 *  $PARAM        registerURL  The URL of the website where the player can register.
 *  $PARAM        str3         Not used.
 *  $PARAM        str4         Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string allowSpecs, optional string registerURL, optional string str3, optional string str4) {
	usernameInput.setValue(sc.get(serverID, SSTR_NGLSUserName));
	passwordInput.setValue(sc.get(serverID, SSTR_NGLSPassword));
	spectatorButton.bDisabled = !parseBool(allowSpecs);
	self.registerURL = class'NexgenUtil'.static.trim(registerURL);
	registerButton.bDisabled = (self.registerURL == "");
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the focus to the desired control.
 *
 **************************************************************************************************/
function setControlFocus() {
	usernameInput.bringToFront();
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
	
	// Reconnect button.
	if (control == reconnectButton && eventType == DE_Click) {
		// Update password.
		sc.visitServer(serverID);
		sc.set(serverID, SSTR_NGLSUserName, usernameInput.getValue());
		sc.set(serverID, SSTR_NGLSPassword, passwordInput.getValue());
		sc.saveConfig();
		
		// Reconnect.
		getplayerowner().consoleCommand(reconnectCommand);
		close();
	}
	
	// Spectator button.
	if (control == spectatorButton && eventType == DE_Click && !spectatorButton.bDisabled) {
		getplayerowner().updateURL(SSTR_OverrideClass, spectatorClass, true);
		getplayerowner().consoleCommand(reconnectCommand);
		close();
	}
	
	// Register button.
	if (control == registerButton && eventType == DE_Click && !registerButton.bDisabled) {
		getplayerowner().consoleCommand(openURLCommand @ registerURL);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	caption="Nexgen Global Login System login information required."
	message="This server is running NGLS, which will only allow registered players to play on the server. Please enter your username and password. If you do not have an account click the register button to create one online."
	usernameText="Username:"
	passwordText="Password:"
	registerText="Register"
	reconnectText="Login"
	spectatorText="Spectate"
}