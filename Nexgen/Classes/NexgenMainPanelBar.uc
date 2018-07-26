/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenMainPanelBar
 *  $VERSION      1.02 (4-3-2007 23:06)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen control panel root toolbar.
 *
 **************************************************************************************************/
class NexgenMainPanelBar extends UWindowDialogClientWindow;

var UWindowSmallButton closeButton;     // Button to close the control panel.
var UWindowSmallButton sendButton;      // Button to send the message entered in the msgInp EditBox.
var UWindowEditControl msgInp;          // Input field for the chat message.

var localized string closeButtonText;   // Text displayed on the close button.
var localized string sendButtonText;    // Text displayed on the send button.
var localized string msgLabelText;      // Label text displayed in front of the input field.

const borderDist = 4.0;                 // Minimum distance between a component and vertical edges.
const separatorDist = 4.0;              // Extra distance between components for separation.
const componentDist = 4.0;              // Horizontal distance between components (in pixels).
const buttonWidth = 64.0;               // Width of button components.
const buttonHeight = 16.0;              // Height of button components.
const labelWidth = 48.0;                // Width of label components.
const labelHeight = 12.0;               // Height of label components.
const editCtrlHeight = 16.0;            // Height of edit control components.

const sayCommand = "say";               // Chat message console command.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the layout for this GUI component.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	local float cx, cy, cw, ch;
	local UMenuLabelControl label;
	
	super.created();
	
	// Add close button.
	cw = buttonWidth;
	ch = buttonHeight;
	cx = winWidth - cw - borderDist;
	cy = (winHeight - ch) / 2.0;
	closeButton = UWindowSmallButton(createControl(class'UWindowSmallButton', cx, cy, cw, ch));
	closeButton.setText(closeButtonText);
	
	// Add send button.
	cx = cx - cw - componentDist - separatorDist;
	sendButton = UWindowSmallButton(createControl(class'UWindowSmallButton', cx, cy, cw, ch));
	sendButton.setText(sendButtonText);
	
	// Add message input field.
	ch = editCtrlHeight;
	cw = cx - borderDist - labelWidth - 2 * componentDist;
	cx = borderDist + labelWidth + componentDist;
	cy = (winHeight - ch) / 2.0;
	msgInp = UWindowEditControl(createControl(class'UWindowEditControl', cx, cy, cw, ch));
	msgInp.editBoxWidth = cw;
	msgInp.setMaxLength(250);
	msgInp.setHistory(true);
	
	// Add 'say' label.
	cw = labelWidth;
	ch = labelHeight;
	cx = borderDist;
	cy = (winHeight - ch) / 2.0;
	label = UMenuLabelControl(createControl(class'UMenuLabelControl', cx, cy, cw, ch));
	label.setText(msgLabelText);
	label.align = TA_Center;	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Paints the dialog area.
 *  $PARAM        c  The canvas object which acts as a drawing surface for the dialog.
 *  $PARAM        x  Unknown.
 *  $PARAM        y  Unknown.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function paint(Canvas c, float x, float y){
	super.paint(c, x, y);
	
	drawUpBevel(c, 0, 0, winWidth, winHeight, getLookAndFeelTexture());
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType){
	super.notify(control, eventType);
	
	if (control == closeButton && eventType == DE_Click) {
		UWindowFramedWindow(getParent(class'UWindowFramedWindow')).close();
	}
	
	if (control == sendButton && eventType == DE_Click) {
		msgInp.editBox.keyDown(getPlayerOwner().EInputKey.IK_Enter, 0.0, 0.0);
	}
	
	if (control == msgInp && eventType == DE_EnterPressed) {
		sendMessage();
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the message in the msgInp EditBox to the server and clears the value of the
 *                editBox. No message will be send if the message is an empty string.
 *  $ENSURE       msgInp.getValue() == ""
 *
 **************************************************************************************************/
function sendMessage() {
	local string msg;
	
	// Get chat message.
	msg = msgInp.getValue();
	
	// Send message & reset edit box value.
	if (msg != "") {
		msgInp.setValue("");
		getPlayerOwner().consoleCommand(sayCommand @ msg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	closeButtonText="Close"
	sendButtonText="Send"
	msgLabelText="Say:"
}