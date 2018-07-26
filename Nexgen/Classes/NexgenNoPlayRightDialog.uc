/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenNoPlayRightDialog
 *  $VERSION      1.00 (23-12-2006 19:18)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the player hasn't got the right to play on the server.
 *
 **************************************************************************************************/
class NexgenNoPlayRightDialog extends NexgenPopupDialog;

var UWindowSmallButton spectatorButton;           // Spectator button component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string spectatorText;               // Text to display on the spectator button.

const SSTR_OverrideClass = "OverrideClass";       // Override class setting string.
const spectatorClass = "Botpack.CHSpectator";     // Override class to use for spectators.
const reconnectCommand = "Reconnect";             // Console command for reconnecting.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
 *  $ENSURE       spectatorButton != none
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
	
	spectatorButton = addButton(spectatorText, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *                Checks if the spectator button has been clicked and deals with it accordingly.
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType){
	super.notify(control, eventType);
	
	// Spectator button.
	if (control == spectatorButton && eventType == DE_Click) {
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
	caption="Failed to login: you have no playing rights."
	message="This server has playing rights disabled by default. You can't play on this server unless an administrator has explicitly allowed you to play. Meanwhile you can still be a spectator on the server."
	spectatorText="Spectator"
}