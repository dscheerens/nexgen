/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenServerFullDialog
 *  $VERSION      1.01 (23-12-2006 14:15)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the player has entered an invalid password. 
 *
 **************************************************************************************************/
class NexgenServerFullDialog extends NexgenPopupDialog;

var UWindowSmallButton reconnectButton;           // Reconnect button component.
var UWindowSmallButton spectatorButton;           // Spectator button component.
var UMenuLabelControl slotLabel;                  // Slot label component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string slotMessage;                 // Message describing the amount of slots.
var localized string passwordText;                // Label to display before the password field.
var localized string reconnectText;               // Text to display on the reconnect button.
var localized string spectatorText;               // Text to display on the spectator button.

const SSTR_OverrideClass = "OverrideClass";       // Override class setting string.
const reconnectCommand = "Reconnect";             // Console command for reconnecting.
const spectatorClass = "Botpack.CHSpectator";     // Override class to use for spectators.



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
	slotLabel = addLabel(cy);
	
	spectatorButton = addButton(spectatorText, 64.0);
	reconnectButton = addButton(reconnectText, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        playerSlots  Number of slots available for regular players.
 *  $PARAM        vipSlots     Number of slots available for VIPs.
 *  $PARAM        adminSlots   Number of slots available for administrators.
 *  $PARAM        str4         Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string playerSlots, optional string vipSlots, optional string adminSlots, optional string str4) {
	slotLabel.setText(class'NexgenUtil'.static.format(slotMessage, playerSlots, vipSlots, adminSlots));
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
	caption="Failed to login: server is full."
	message="The server you have tried to enter has no more player slots available. You can try again in a few minutes or reconnect immediately as a spectator. Note that the server may appear to have some unused slots available. These are reserved slots for VIPs or administrators and are not accessible for regular players."
	slotMessage="This server has %1 regular players slots, %2 VIP slots and %3 admin slots."
	passwordText="Password:"
	reconnectText="Reconnect"
	spectatorText="Spectator"
}