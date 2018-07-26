/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPUpdateNotificationDialog
 *  $VERSION      1.01 (04-08-2010 22:11)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the player has entered an invalid password. 
 *
 **************************************************************************************************/
class NXPUpdateNotificationDialog extends NexgenPopupDialog;

var UMenuLabelControl versionLabel;               // Slot label component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string versionMessage;              // Message that tells the new Nexgen version.



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
	versionLabel = addLabel(cy);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        newVersion  The new version of Nexgen that is available.
 *  $PARAM        str2        Not used.
 *  $PARAM        str3        Not used.
 *  $PARAM        str4        Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string newVersion, optional string str2, optional string str3, optional string str4) {
	local string newVersionStr;
	
	newVersionStr = left(newVersion, len(newVersion) - 2) $ "." $ right(newVersion, 2);
	
	versionLabel.setText(class'NexgenUtil'.static.format(versionMessage, newVersionStr));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	wrapLength=79
	caption="A new version of Nexgen is available."
	message="The server is automatically checking for Nexgen updates and has found a new version. Visit www.unrealadmin.org for more information. You can turn automatic update checking off in the plugin configuration tab. This message will not be repeated until another new version of Nexgen is released."
	versionMessage="Latest Nexgen version: %1"
}