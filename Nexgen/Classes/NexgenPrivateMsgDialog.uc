/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPrivateMsgDialog
 *  $VERSION      1.00 (25-12-2006 17:06)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the player is banned from the server.
 *
 **************************************************************************************************/
class NexgenPrivateMsgDialog extends NexgenPopupDialog;

var UMenuLabelControl msgLabel[5];      // Message content label components.
var UMenuLabelControl senderLabel;      // Message sender label component.
var UWindowSmallButton replyButton;     // Reply button component.

var localized string caption;           // Caption to display on the dialog.
var localized string senderText;        // Message sender label text.
var localized string messageText;       // Received message label text.
var localized string replyButtonText;   // Received message label text.

const firstLineWrapLen = 60;            // Wrap lenght at the first message line.



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
	senderLabel = addPropertyLabel(cy, senderText, 64.0);
	msgLabel[0] = addPropertyLabel(cy, messageText, 64.0);
	msgLabel[1] = addLabel(cy);
	msgLabel[2] = addLabel(cy);
	msgLabel[3] = addLabel(cy);
	msgLabel[4] = addLabel(cy);
	replyButton = addButton(replyButtonText, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        message  The message that was received.
 *  $PARAM        sender   Name of the player that has send the message.
 *  $PARAM        str3     Not used.
 *  $PARAM        str4     Not used.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string message, optional string sender, optional string str3, optional string str4) {
	local int lineNum;
	local int index;
	local string remaining;
	local string lineStr;
	local int wrapLen;
	local int wrapPos;
	local string lineEntry;
	
	// Set sender label.
	senderLabel.setText(sender);
	
	// Set message labels.
	remaining = message $ newlineToken;
	while (remaining != "" && lineNum < arrayCount(msgLabel)) {
		// Split at new line tokens.
		index = instr(remaining, newlineToken);
		lineStr = left(remaining, index);
		remaining = mid(remaining, index + len(newlineToken));
				
		// Split at wrap length.
		do {
			// Get wrap position.
			if (lineNum == 0) {
				wrapLen = firstLineWrapLen;
			} else {
				wrapLen = wrapLength;
			}
			wrapPos = getWrapPosition(lineStr, wrapLen);
			
			// Split line.
			if (wrapPos < 0) {
				lineEntry = lineStr;
				lineStr = "";
			} else {
				lineEntry = left(lineStr, wrapPos);
				lineStr = mid(lineStr, wrapPos);
			}
			
			msgLabel[lineNum++].setText(class'NexgenUtil'.static.trim(lineEntry));
			
		} until (lineStr == "" || lineNum >= arrayCount(msgLabel));
	}
	
	// Clean empty lines.
	for (index = lineNum; index < arrayCount(msgLabel); index++) {
		msgLabel[index].setText("");
	}
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
	super.notify(control, eventType);
	
	// Reply button.
	if (control == replyButton && eventType == DE_Click) {
		client.showPanel(class'NexgenRCPPrivateMsg'.default.panelIdentifier);
		close();
	}
}
	



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	wrapLength=79
	caption="You have received a new private message."
	senderText="From:"
	messageText="Message:"
	replyButtonText="Reply"
}