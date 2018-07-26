/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPopupDialog
 *  $VERSION      1.06 (21-10-2007 15:28)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Parent class for all popup dialogs.
 *
 **************************************************************************************************/
class NexgenPopupDialog extends UWindowDialogClientWindow;

var NexgenClient client;                // Nexgen client instance.
var GeneralConfig gc;                   // General client configuration.
var ServerConfig sc;                    // Server specific client configuration.
var string serverID;                    // Identification code of the server.

var bool hasCloseButton;                // Automatically add a close button to the dialog?
var UWindowSmallButton closeButton;     // Default close button.

var int wrapLength;                     // Insert a new line after this many characters.
                                        // NOTE: This value is only an estimation for word wrapping.
const minWrapRetain = 0.60;             // Minimum size of the text before wrapping inside words
                                        // will occur.
const wrapChars = " -,.";               // Preferred characters where wrapping should occur.

var bool autoCloseControlPanel;         // Automatically close the control panel once the dialog is
                                        // shown?

// Component positioning. All values are measured in pixels.
var float nextButtonPos;                // Next horizontal position of a button that is to be added.
var float borderSize;                   // Distance between objects on the dialog and its borders.
var float labelHeight;                  // Height of label objects.
var float editControlHeight;            // Height of edit control objects.
var float editControlLabelVOffset;      // Vertical offset of labels relative to their edit control.
var float buttonPanelBorderSize;        // Distance between the dialog borders and the button panel.
var float buttonPanelHeight;            // The height of the button panel.
var float buttonHeight;                 // Height of buttons on this dialog.
var float buttonWidth;                  // Default width of a button on this dialog.
var float buttonSpace;                  // Space between two buttons.

const newLineToken = "\\n";             // Token used to detect new lines in texts.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
 *  $ENSURE       hasCloseButton ? closeButton != none : true
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	local UMenuLabelControl label;
	local UWindowRootWindow rootWin;
	local UWindowWindow win;
	
	super.created();
	
	nextButtonPos = winWidth - buttonSpace - buttonPanelBorderSize;
	
	// Automatically add close button?
	if (hasCloseButton) {
		closeButton = addButton("Close");
	}
	
	// Automatically close control panel?
	if (autoCloseControlPanel) {
		// Yes, iterate over each window.
		rootWin = WindowConsole(getPlayerOwner().player.console).root;
		if (rootWin != none) {
			win = rootWin.firstChildWindow;
			while (win != none) {
				// Window is a control panel?
				if (win.isA('NexgenMainFrame')) {
					// Yes, close it.
					win.close();
				}
				
				// Continue with next window.
				win = win.nextSiblingWindow;
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *                This function will only check if the close button has been clicked.
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType){
	super.notify(control, eventType);
	
	if (control == closeButton && eventType == DE_Click) {
		close();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new button to the dialog. The button will be added to the button panel of
 *                the dialog and will be automatically positioned.
 *  $PARAM        text   Text to display on the button.
 *  $PARAM        width  Width of the button in pixels.
 *  $RETURN       The button that has been added to the button panel of this dialog.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UWindowSmallButton addButton(string text, optional int width) {
	local float cx, cy, cw, ch;
	local UWindowSmallButton newButton;
	
	if (width > 0.0) {
		cw = width;
	} else {
		cw = buttonWidth;
	}
	ch = buttonHeight;
	cx = nextButtonPos - cw;
	cy = winHeight - buttonPanelHeight - buttonPanelBorderSize + (buttonPanelHeight - ch) / 2.0 - 3;
	
	newButton = UWindowSmallButton(createControl(class'UWindowSmallButton', cx, cy, cw, ch));
	newButton.setText(text);
	
	nextButtonPos -= cw + buttonSpace;
	
	return newButton;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new label component to the dialog.
 *  $PARAM        yPos  Vertical position on the dialog where the text will be added. 
 *  $REQUIRE      yPos >= 0
 *  $RETURN       The label that has been added to the dialog.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UMenuLabelControl addLabel(out float yPos) {
	local float cx, cy, cw, ch;
	
	// Initialze position & dimensions.
	cx = borderSize;
	cy = yPos;
	cw = winWidth - 2.0 * borderSize;
	ch = labelHeight;
	yPos += ch;
	
	// Create label.
	return UMenuLabelControl(createControl(class'UMenuLabelControl', cx, cy, cw, ch));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new label component to the dialog with a property description label in
 *                front of the label.
 *  $PARAM        yPos        Vertical position on the dialog where the text will be added.
 *  $PARAM        text        Property name / description.
 *  $PARAM        labelWidth  Width of the property name label (in pixels).
 *  $REQUIRE      yPos >= 0 && labelWidth > 0
 *  $RETURN       The label that has been added to the dialog.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UMenuLabelControl addPropertyLabel(out float yPos, string text, float labelWidth) {
	local float cx, cy, cw, ch;
	local UMenuLabelControl label;
	
	cx = borderSize;
	cy = yPos;
	cw = labelWidth;
	ch = labelHeight;
	label = UMenuLabelControl(createControl(class'UMenuLabelControl', cx, cy, cw, ch));
	label.setText(text);
	label.setFont(F_Bold);
	
	cx += labelWidth;
	cw = winWidth - 2.0 * borderSize - labelWidth;
	yPos += ch;
	return UMenuLabelControl(createControl(class'UMenuLabelControl', cx, cy, cw, ch));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a text to the dialog. This function detects new line tokens and writes the
 *                after the token on a new line. Note that it doesn't support word wrapping. The
 *                fontType and align properties will be maintained for all lines written.
 *  $PARAM        text      The text to write to the dialog.
 *  $PARAM        yPos      Vertical position on the dialog where the text will be added.
 *  $PARAM        fontType  Type of font used to display the text.
 *  $PARAM        align     Horizontal alignment of the text to add.
 *  $PARAM        wrapLen   Maximum characters on a line. For word wrapping. 
 *  $REQUIRE      yPos >= 0 && (fontType == F_Normal || fontType == F_Bold) &&
 *                (align == TA_Left || align == TA_Center || align == TA_Right)
 *
 **************************************************************************************************/
function addText(string text, out float yPos, int fontType, TextAlign align, optional int wrapLen) {
	local float cx, cy, cw, ch;
	local UMenuLabelControl label;
	local string textStr;
	local string lineStr;
	local int newLinePos;
	local string wrapStr;
	local int wrapPos;
	
	// Set proper wrapping length.
	if (wrapLen <= 0) {
		wrapLen = wrapLength;
	}
	
	// Initialze position & dimensions.
	cx = borderSize;
	cy = yPos;
	cw = winWidth - 2.0 * borderSize;
	ch = labelHeight;
	
	// Create a label for each line in the text string.
	textStr = text;
	while (textStr != "") {
		
		// Get text for the current line.
		newLinePos = instr(textStr, newLineToken);
		if (newLinePos < 0) {
			lineStr = textStr;
			textStr = "";
		} else {
			lineStr = left(textStr, newLinePos);
			textStr = mid(textStr, newLinePos + len(newLineToken));
		}
		
		// Word wrapping for the current line.
		while (lineStr != "") {
			wrapPos = getWrapPosition(lineStr, wrapLen);
			
			// Wrap current line.
			if (wrapPos < 0) {
				wrapStr = lineStr;
				lineStr = "";
			} else {
				wrapStr = left(lineStr, wrapPos + 1);
				lineStr = mid(lineStr, wrapPos + 1);
			}
			
			// Create label.
			label = UMenuLabelControl(createControl(class'UMenuLabelControl', cx, cy, cw, ch));
			label.setText(wrapStr);
			label.setFont(fontType);
			label.align = align;
			
			// Update vertical offset.
			cy += ch;
		}
	}
	
	// Update vertical offset.
	yPos = cy;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Gets the first position in the given string where a new line should be inserted
 *                for word wrapping.
 *  $PARAM        text      The string for which the first wrapping position is to be determined.
 *  $PARAM        maxChars  Maximum characters allowed on a line.
 *  $REQUIRE      maxChars > 0
 *  $RETURN       The first position in the specified string where word wrapping should occur, or
 *                -1 if no wrapping is necessary.
 *  $ENSURE       result >= 0 && result < len(text) && result < maxChars || result == -1
 *
 **************************************************************************************************/
function int getWrapPosition(string text, int maxChars) {
	local int index;
	
	// Find wrap position.
	if (len(text) < maxChars) {
		// No wrapping necessary.
		index = -1;
	} else {
		
		// Start at the back.
		index = maxChars - 1;
		while ((instr(wrapChars, mid(text, index, 1)) < 0) && (index >= minWrapRetain * maxChars)) {
			index--;
		}
		
		// Wrap at least after 1 character.
		index = max(1, index);
	}
	
	return index;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds an empty line in this dialog. No control object is created, only the value of
 *                yPos will be increased.
 *  $PARAM        yPos  Vertical position of the new line on this dialog.
 *  $ENSURE       new.yPos >= old.yPos
 *
 **************************************************************************************************/
function addNewLine(out float yPos) {
	yPos += labelHeight;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new edit control object to this dialog.
 *  $PARAM        yPos        Vertical position of the edit control on this dialog.
 *  $PARAM        labelText   Label to display before the edit control.
 *  $PARAM        labelWidth  Width of the label to display
 *  $REQUIRE      yPos >= 0 && (labelText != "" ? labelWidth > 0 : true)
 *  $RETURN       The edit control object created for this dialog.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UWindowEditControl addEditControl(out float yPos, optional string labelText, optional float labelWidth) {
	local float cx, cy, cw, ch;
	local UMenuLabelControl label;
	local UWindowEditControl editControl;
	
	// Set control position & dimension.
	ch = editControlHeight;
	cx = borderSize;
	cy = yPos;
	if (labelText != "") {
		// Add a label before the edit control.
		cw = labelWidth;
		cy += editControlLabelVOffset;
		label = UMenuLabelControl(createControl(class'UMenuLabelControl', cx, cy, cw, ch));
		label.setText(labelText);
		label.setFont(F_Bold);
		cx += labelWidth;
		cy = yPos;
		cw = winWidth - 2.0 * borderSize - labelWidth;
	} else {
		cw = winWidth - 2.0 * borderSize;
	}
	
	yPos = cy + ch;
	
	// Create & setup the edit control.
	editControl = UWindowEditControl(createControl(class'UWindowEditControl', cx, cy, cw, ch));
	editControl.editBoxWidth = cw;
	editControl.setMaxLength(250);
	
	// Return the control.
	return editControl;
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
	local float cx, cy, cw, ch;
	
	super.paint(c, x, y);
	
	// Draw the button panel.
	cx = buttonPanelBorderSize;
	cy = winHeight - buttonPanelHeight - buttonPanelBorderSize;
	cw = winWidth - buttonPanelBorderSize * 2;
	ch = buttonPanelHeight;
	drawUpBevel(c, cx, cy, cw, ch, getLookAndFeelTexture());
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Closes the dialog.
 *  $PARAM        bByParent  The close call was issued by the parent of the dialog.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function close(optional bool bByParent) {
	local UWindowRootWindow rootWin;
	local UWindowWindow win;
	local bool bWindowVisible;
	
	// Check if there is another visible window.
	rootWin = WindowConsole(getPlayerOwner().player.console).root;
	if (rootWin != none) {
		win = rootWin.firstChildWindow;
		while (!bWindowVisible && win != none) {
			// Current window visible?
			bWindowVisible = win != parentWindow && win.windowIsVisible() && win.bLeaveOnscreen;
			
			// Continue with next window.
			win = win.nextSiblingWindow;
		}
	}
	
	// Close the window.
	if (!bWindowVisible) {
		WindowConsole(getPlayerOwner().player.console).closeUWindow();
	}
	super.close(bByParent);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Parses a boolean string value.
 *  $PARAM        str  The string representation of a boolean value.
 *  $RETURN       True if the string equals "true" (case insensitive), false otherwise.
 *
 **************************************************************************************************/
function bool parseBool(string str) {
	return str ~= "true";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        str1  Dialog specific content data.
 *  $PARAM        str2  Dialog specific content data. 
 *  $PARAM        str3  Dialog specific content data.
 *  $PARAM        str4  Dialog specific content data.
 *  $ABSTRACT
 *
 **************************************************************************************************/
function setContent(optional string str1, optional string str2, optional string str3, optional string str4);



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	hasCloseButton=true
	wrapLength=80
	borderSize=16.0
	labelHeight=16.0
	editControlHeight=16.0
	editControlLabelVOffset=3.0;
	buttonPanelBorderSize=2.0
	buttonPanelHeight=22.0
	buttonHeight=16.0
	buttonWidth=48.0
	buttonSpace=4.0
}