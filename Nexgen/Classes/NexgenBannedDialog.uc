/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenBannedDialog
 *  $VERSION      1.00 (25-12-2006 17:06)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the player is banned from the server.
 *
 **************************************************************************************************/
class NexgenBannedDialog extends NexgenPopupDialog;

var UMenuLabelControl reasonLabel;                // Ban reason label component.
var UMenuLabelControl periodLabel;                // Ban period label component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Dialog help / info / description message.
var localized string reasonText;                  // Ban reason label text.
var localized string periodText;                  // Ban period label text.
var localized string noReasonText;                // Text to display if no reason is given.



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
	addNewLine(cy);
	reasonLabel = addPropertyLabel(cy, reasonText, 48.0);
	periodLabel = addPropertyLabel(cy, periodText, 48.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        reason  Reason why the player was banned.
 *  $PARAM        period  The period for which the player is banned.
 *  $PARAM        str3  Not used.
 *  $PARAM        str4  Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string reason, optional string period, optional string str3, optional string str4) {
	if (reason == "") {
		reasonLabel.setText(noReasonText);
	} else {
		reasonLabel.setText(reason);
	}
	periodLabel.setText(period);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	wrapLength=79
	caption="Failed to login: you are banned/kicked from the server."
	message="The server has refused to let you join the game because you have been banned or kicked, meaning you are probably not welcome for the time being. Please go play somewhere else, there are enough of other servers and games out there."
	reasonText="Reason:"
	periodText="Period:"
	noReasonText="<no reason has been given>"
}