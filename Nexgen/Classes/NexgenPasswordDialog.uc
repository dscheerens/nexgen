/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPasswordDialog
 *  $VERSION      1.01 (23-12-2006 14:15)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the player has entered an invalid password. 
 *
 **************************************************************************************************/
class NexgenPasswordDialog extends NexgenPopupDialog;

var UWindowSmallButton reconnectButton;           // Reconnect button component.
var UWindowSmallButton spectatorButton;           // Spectator button component.
var UWindowEditControl passwordInput;             // Password input field component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string passwordText;                // Label to display before the password field.
var localized string reconnectText;               // Text to display on the reconnect button.
var localized string spectatorText;               // Text to display on the spectator button.

const SSTR_ServerPassword = "Password";           // Server password setting string.
const SSTR_OverrideClass = "OverrideClass";       // Override class setting string.
const reconnectCommand = "Reconnect";             // Console command for reconnecting.
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
	passwordInput = addEditControl(cy, passwordText, 64.0);
	
	spectatorButton = addButton(spectatorText, 64.0);
	reconnectButton = addButton(reconnectText, 64.0);
	
	// Set component properties.
	passwordInput.setMaxLength(24);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        allowSpecs  Indicates if reconnecting as spectator should be allowed.
 *  $PARAM        str2        Not used.
 *  $PARAM        str3        Not used.
 *  $PARAM        str4        Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string allowSpecs, optional string str2, optional string str3, optional string str4) {
	// sc.get(serverID, NexgenClient.SSTR_ServerPassword); // Bah, doesn't work!
	passwordInput.setValue(sc.get(serverID, SSTR_ServerPassword));
	spectatorButton.bDisabled = !parseBool(allowSpecs);
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
		sc.set(serverID, SSTR_ServerPassword, passwordInput.getValue());
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
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	caption="Failed to login: invalid password."
	message="This server is password protected. You have either entered an invalid password or no password at all. Please enter the password for this server and click reconnect to login with the new password."
	passwordText="Password:"
	reconnectText="Reconnect"
	spectatorText="Spectator"
}