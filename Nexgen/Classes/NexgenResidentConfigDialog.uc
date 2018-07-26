/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenResidentConfigDialog
 *  $VERSION      1.00 (16-12-2007 15:32)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog displayed if a resident Nexgen configuration is detected.
 *
 **************************************************************************************************/
class NexgenResidentConfigDialog extends NexgenPopupDialog;

var localized string caption;           // Caption to display on the dialog.
var localized string message;           // Message to dispay on the dialog.




/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
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
}	



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	wrapLength=78
	caption="Local Nexgen configuration detected!"
	message="A Nexgen configuration has been detected on your client. This may prevent your client from initializing correctly. If you experience problems delete Nexgen.ini or the Nexgen configuration stored UnrealTournament.ini. You can find these files in the system folder of your Unreal Tournament installation.\\n \\nSorry for the inconvenience."
}