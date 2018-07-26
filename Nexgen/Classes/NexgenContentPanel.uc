/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenContentPanel
 *  $VERSION      1.09 (30-07-2010 22:19)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen control panel page with layout managing support. This basic
 *                UWindowPageWindow provides functions to automatically setup the layout of the
 *                window, so it is not necessary to position all components manually.
 *
 **************************************************************************************************/
class NexgenContentPanel extends UWindowPageWindow;

struct LayoutRegion {                   // Structure for containing the definition of a region.
	var float x;                        // Horizontal offset.
	var float y;                        // Vertical offset.
	var float w;                        // Width of the region.
	var float h;                        // Height of the region.
};

var LayoutRegion regions[255];          // Active regions for this panel.
var int regionCount;                    // Number of regions created.
var int currRegion;                     // Current selected region.

var enum EPanelBackType {               // Background type of the panel.
	PBT_Default,                        // Default background.
	PBT_Beveled,                        // Beveld background.
	PBT_Transparent                     // No background.
} panelBGType;

var NexgenContentPanel parentCP;        // Parent NexgenContentPanel (may be none).

const borderSize = 4.0;                 // Distance between the root region and the window borders.
const minRegionSize = 4.0;              // Minimum size of a region (in pixels).

const AL_Center = 0;                    // Component is aligned in the center.
const AL_Left = 1;                      // Component is aligned to the left border of the region.
const AL_Top = 1;                       // Component is aligned to the upper border of the region.
const AL_Right = 2;                     // Component is aligned to the right border of the region.
const AL_Bottom = 2;                    // Component is aligned to the lower border of the region.

const defaultComponentDist = 4.0;       // Default distance between components.
const defaultButtonHeight = 16.0;       // Default height for UWindowSmallButton components.
const defaultLabelHeight = 12.0;        // Default height for UMenuLabelControl components.
const defaultEditBoxHeight = 16.0;      // Default height for UWindowEditControl components.
const defaultCheckBoxHeight = 13.0;     // Default height for UWindowCheckbox components.
const defaultRaisedButtonHeight = 18.0; // Default height for UMenuRaisedButton components.
const defaultlistComboHeight = 16.0;    // Default height for UWindowComboControl components.

const separator = ",";                  // Token used to seperate elements in a list.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new region to the content panel.
 *  $PARAM        x  Horizontal offset.
 *  $PARAM        y  Vertical offset.
 *  $PARAM        w  Width of the region.
 *  $PARAM        h  Height of the region.
 *  $REQUIRE      w >= 0 && h >= 0
 *  $ENSURE       result >= 0 ? new.regionCount = old.regionCount + 1 &&
 *                              regions[result].x = x &&
 *                              regions[result].y = y &&
 *                              regions[result].w = w &&
 *                              regions[result].h = h
 *                            : true
 *
 **************************************************************************************************/
function int addRegion(float x, float y, float w, float h) {
	local int index;

	// Check if there is room for another region.	
	if (regionCount < arrayCount(regions)) {
		// There is, add the region.
		regions[regionCount].x = x;
		regions[regionCount].y = y;
		regions[regionCount].w = w;
		regions[regionCount].h = h;
		return regionCount++;
	} else {
		// There isn't, return failure.
		return -1;
	}

}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the root region to the content panel. This region occupies the whole surface
 *                of this content panel.
 *  $REQUIRE      regionCount == 0
 *  $ENSURE       new.regionCount = old.regionCount + 1
 *
 **************************************************************************************************/
function createWindowRootRegion() {
	currRegion = addRegion(borderSize + 2.0, borderSize + 2.0,
	                       winWidth - 2.0 * borderSize - 8.0,
	                       winHeight - 2.0 * borderSize - 10.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the root region to the content panel. This region occupies the whole surface
 *                of this content panel. Use this function instead of createRootRegion() if the
 *                panel is added as a component on another panel.
 *  $REQUIRE      regionCount == 0
 *  $ENSURE       new.regionCount = old.regionCount + 1
 *
 **************************************************************************************************/
function createPanelRootRegion() {
	currRegion = addRegion(borderSize + 2.0, borderSize + 2.0,
	                       winWidth - 2.0 * borderSize - 4.0,
	                       winHeight - 2.0 * borderSize - 4.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Selects the region that is to be used.
 *  $PARAM        region  Index of the region which should be selected.
 *  $REQUIRE      0 <= region && region < regionCount
 *  $ENSURE       currRegion == region
 *
 **************************************************************************************************/
function selectRegion(int region) {
	currRegion = region;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Skips the current region and selects the next one.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *
 **************************************************************************************************/
function skipRegion() {
	currRegion++;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Merges the current region with the specified region. The merged region metrics are
 *                stored in the specified target region.
 *  $PARAM        targetRegion  The region that with with the current region is to be merged.
 *  $PARAM        bAbsolute     Whether the target region is an absolute region number. If false the
 *                              target region is considered as on offset to the current region.
 *  $REQUIRE      (bAbsolute && 0 <= targetRegion && targetRegion < regionCount) ||
 *                (!bAbsolute && 0 <= currRegion + targetRegion &&
 *                 currRegion + targetRegion < regionCount)
 *
 **************************************************************************************************/
function mergeRegion(int targetRegion, optional bool bAbsolute) {
	local float newX, newY, newW, newH;
	
	// Update target region for offsets.
	if (!bAbsolute) {
		targetRegion += currRegion;
	}
	
	// Determine new region position and size.
	newX = fmin(regions[currRegion].x, regions[targetRegion].x);
	newY = fmin(regions[currRegion].y, regions[targetRegion].y);
	newW = fmax(regions[currRegion].x + regions[currRegion].w - 1, regions[targetRegion].x + regions[targetRegion].w - 1) - newX + 1;
	newH = fmax(regions[currRegion].y + regions[currRegion].h - 1, regions[targetRegion].y + regions[targetRegion].h - 1) - newY + 1;
	
	// Store new region position and size.
	regions[targetRegion].x = newX;
	regions[targetRegion].y = newY;
	regions[targetRegion].w = newW;
	regions[targetRegion].h = newH;
	
	// Select next region.
	currRegion++;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Splits the current region in two horizontal sub regions. Once this function has
 *                been called it will automatically select the next region.
 *  $PARAM        height    Determines the location of the point where the current region is to be
 *                          split. The exact semantics of this parameter depends on the bPercent and
 *                          bBottom parameter.
 *  $PARAM        dist      Distance between the two sub regions (in pixels).
 *  $PARAM        bPercent  Indicates whether height is an absolute or relative value.
 *  $PARAM        bBottom   Whether the height parameter counts for the lower or upper sub region.
 *  $REQUIRE      (bPercent ? 0 < height && height < 100 : height > 0) && dist >= 0 &&
 *                0 <= currRegion && currRegion < regionCount
 *  $RETURN       The index of the first new sub region that was created or -1 if no region could
 *                be created. The index of the second region is: result + 1.
 *
 **************************************************************************************************/
function int splitRegionH(float height, optional int dist, optional bool bPercent,
                          optional bool bBottom) {
	local float splitPoint;
	local float region1height;
	local float region2height;
	local float region1top;
	local float region2top;
	local int index;
	
	// Determine splitpoint.
	if (bPercent) {
		if (bBottom) {
			splitPoint = int(regions[currRegion].h * (100.0 - height) / 100.0);
		} else {
			splitPoint = int(regions[currRegion].h * height / 100.0);
		}
	} else {
		if (bBottom) {
			splitPoint = regions[currRegion].h - height;
		} else {
			splitPoint = height;
		}
	}
	
	// Determine region metrics.
	region1height = fMax(splitPoint - int(dist / 2.0), minRegionSize);
	region2height = fMax(regions[currRegion].h - region1height - dist, minRegionSize);
	region1top = regions[currRegion].y;
	region2top = region1top + region1height + dist;
	
	// Add regions.
	index = addRegion(regions[currRegion].x, region1top, regions[currRegion].w, region1height);
	        addRegion(regions[currRegion].x, region2top, regions[currRegion].w, region2height);
	currRegion++; // Automatically select next region.
	
	// Return index of first created region.
	return index;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Splits the current region in two vertical sub regions. Once this function has been
 *                called it will automatically select the next region.
 *  $PARAM        width     Determines the location of the point where the current region is to be
 *                          split. The exact semantics of this parameter depends on the bPercent and
 *                          bRight parameter.
 *  $PARAM        dist      Distance between the two sub regions (in pixels).
 *  $PARAM        bPercent  Indicates whether width is an absolute or relative value.
 *  $PARAM        bRight    Whether the width parameter counts for the left or right sub region.
 *  $REQUIRE      (bPercent ? 0 < width && width < 100 : width > 0) && dist >= 0 &&
 *                0 <= currRegion && currRegion < regionCount
 *  $RETURN       The index of the first new sub region that was created or -1 if no region could
 *                be created. The index of the second region is: result + 1.
 *
 **************************************************************************************************/
function int splitRegionV(float width, optional int dist, optional bool bPercent,
                          optional bool bRight) {
	local float splitPoint;
	local float region1width;
	local float region2width;
	local float region1left;
	local float region2left;
	local int index;
	
	// Determine splitpoint.
	if (bPercent) {
		if (bRight) {
			splitPoint = int(regions[currRegion].w * (100.0 - width) / 100.0);
		} else {
			splitPoint = int(regions[currRegion].w * width / 100.0);
		}
	} else {
		if (bRight) {
			splitPoint = regions[currRegion].w - width;
		} else {
			splitPoint = width;
		}
	}
	
	// Determine region metrics.
	region1width = fMax(splitPoint - int(dist / 2.0), minRegionSize);
	region2width = fMax(regions[currRegion].w - region1width - dist, minRegionSize);
	region1left = regions[currRegion].x;
	region2left = region1left + region1width + dist;
	
	// Add regions.
	index = addRegion(region1left, regions[currRegion].y, region1width, regions[currRegion].h);
	        addRegion(region2left, regions[currRegion].y, region2width, regions[currRegion].h);
	currRegion++; // Automatically select next region.
	
	// Return index of first created region.
	return index;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Divides the current region into a specified amount of equal sized parts. The
 *                current region will be sliced using horizontal cuts. Automatically selects the
 *                next region.
 *  $PARAM        amount  Number of sub regions to create.
 *  $PARAM        dist    Distance between each created sub region (in pixels).
 *  $REQUIRE      amount >= 0 && dist >= 0 && 0 <= currRegion && currRegion < regionCount
 *  $RETURN       The index of the first new sub region that was created or -1 if no region could
 *                be created. The index of the second region is: result + 1, etc.
 *
 **************************************************************************************************/
function int divideRegionH(int amount, optional int dist) {
	local float totalRegionHeight;
	local float regionHeight;
	local float leftOver;
	local float carryOver;
	local float currHeight;
	local float currTop;
	local int index;
	local int result;
	local int count;
	
	// Determine region metrics.
	totalRegionHeight = regions[currRegion].h - (amount - 1) * dist;
	regionHeight = int(totalRegionHeight / amount);
	leftOver = (totalRegionHeight - regionHeight * amount) / amount;
	currTop = regions[currRegion].y;
	
	// Create regions.
	for (count = 0; count < amount; count++) {
		// Finish current region metrics.
		currHeight = regionHeight;
		carryOver += leftOver;
		if (carryOver >= 1) {
			carryOver = carryOver - 1.0;
			currHeight = currHeight + 1.0;
		}
		
		// Add the region.
		index = addRegion(regions[currRegion].x, currTop, regions[currRegion].w, currHeight);
		if (count == 0) {
			result = index;
		}
		
		// Update y-offset.
		currTop = currTop + currHeight + dist;
		
	}
	
	currRegion++; // Automatically select next region.
	
	// Return index of first created region.
	return result;
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Divides the current region into a specified amount of equal sized parts. The
 *                current region will be sliced using horizontal cuts. Automatically selects the
 *                next region.
 *  $PARAM        amount  Number of sub regions to create.
 *  $PARAM        dist    Distance between each created sub region (in pixels).
 *  $REQUIRE      amount >= 0 && dist >= 0 && 0 <= currRegion && currRegion < regionCount
 *  $RETURN       The index of the first new sub region that was created or -1 if no region could
 *                be created. The index of the second region is: result + 1, etc.
 *
 **************************************************************************************************/
function int divideRegionV(int amount, optional int dist) {
	local float totalRegionWidth;
	local float regionWidth;
	local float leftOver;
	local float carryOver;
	local float currWidth;
	local float currLeft;
	local int index;
	local int result;
	local int count;
	
	// Determine region metrics.
	totalRegionWidth = regions[currRegion].w - (amount - 1) * dist;
	regionWidth = int(totalRegionWidth / amount);
	leftOver = (totalRegionWidth - regionWidth * amount) / amount;
	currLeft = regions[currRegion].x;
	
	// Create regions.
	for (count = 0; count < amount; count++) {
		// Finish current region metrics.
		currWidth = regionWidth;
		carryOver += leftOver;
		if (carryOver >= 1) {
			carryOver = carryOver - 1.0;
			currWidth = currWidth + 1.0;
		}
		
		// Add the region.
		index = addRegion(currLeft, regions[currRegion].y, currWidth, regions[currRegion].h);
		if (count == 0) {
			result = index;
		}
		
		// Update y-offset.
		currLeft = currLeft + currWidth + dist;
		
	}
	
	currRegion++; // Automatically select next region.
	
	// Return index of first created region.
	return result;
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a new component and places it on the current region. Also automatically
 *                selects the next region.
 *  $PARAM        wndClass  Component type to create.
 *  $PARAM        width     Preferred width of the component. Use 0 to use all space available.
 *  $PARAM        height    Preferred height of the component. Use 0 to use all space available.
 *  $PARAM        hAlign    Horizontal alignment of the component on the region.
 *  $PARAM        vAlign    Vertical alignment of the component on the region.
 *  $REQUIRE      wndClass != none && width >= 0 && height >= 0 &&
 *                (hAlign == AL_Left || hAlign == AL_Center || hAlign == AL_Right) &&
 *                (vAlign == AL_Top || vAlign == AL_Center || vAlign == AL_Bottom) &&
 *                0 <= currRegion && currRegion < regionCount
 *  $RETURN       The component that has been created and added to the window.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UWindowWindow addComponent(class<UWindowWindow> wndClass, optional float width,
                                    optional float height, optional byte hAlign,
                                    optional byte vAlign) {
	local float x;
	local float y;
	local float w;
	local float h;
	
	// Determine horizontal metrics.
	if (width <= 0.0) {
		x = regions[currRegion].x;
		w = regions[currRegion].w;
	} else {
		w = width;
		if (hAlign == AL_Left) {
			x = regions[currRegion].x;
		} else if (hAlign == AL_Right) {
			x = regions[currRegion].x + regions[currRegion].w - width;
		} else {
			x = int(regions[currRegion].x + (regions[currRegion].w - width) / 2.0);
		}		
	}
	
	// Determine vertical metrics.
	if (height <= 0.0) {
		y = regions[currRegion].y;
		h = regions[currRegion].h;
	} else {
		h = height;
		if (vAlign == AL_Top) {
			y = regions[currRegion].y;
		} else if (vAlign == AL_Bottom) {
			y = regions[currRegion].y + regions[currRegion].h - height;
		} else {
			y = int(regions[currRegion].y + (regions[currRegion].h - height) / 2.0);
		}		
	}
	
	// Select next region.
	currRegion++; 
	
	// Create component.
	return createWindow(wndClass, x, y, w, h);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new button component to the current region.
 *  $PARAM        text    Text to display on the button.
 *  $PARAM        width   Width of the button (in pixels). Use 0 to use all space available.
 *  $PARAM        hAlign  Horizontal alignment of the button on the current region.
 *  $REQUIRE      width >= 0 && (hAlign == AL_Left || hAlign == AL_Center || hAlign == AL_Right) &&
 *                0 <= currRegion && currRegion < regionCount
 *  $RETURN       The button that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UWindowSmallButton addButton(optional string text, optional float width,
                                      optional byte hAlign) {
	local UWindowSmallButton button;
	
	button = UWindowSmallButton(addComponent(class'UWindowSmallButton', width, defaultButtonHeight,
	                                         hAlign, AL_Center));
	button.setText(text);
	button.register(self);
	
	return button;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new label component to the current region.
 *  $PARAM        text   Text displayed on the label component.
 *  $PARAM        bBold  Whether or not the text is displayed in a bold font.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The label that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UMenuLabelControl addLabel(optional coerce string text, optional bool bBold, optional TextAlign align) {
	local UMenuLabelControl label;
	
	label = UMenuLabelControl(addComponent(class'UMenuLabelControl', , defaultLabelHeight, , AL_Center));
	label.setText(text);
	if (bBold) {
		label.setFont(F_Bold);
	}
	label.align = align;
	
	return label;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new edit box component to the current region.
 *  $PARAM        text    Value of the edit box.
 *  $PARAM        width   Width of the button (in pixels). Use 0 to use all space available.
 *  $PARAM        hAlign  Horizontal alignment of the edit box on the current region.
 *  $REQUIRE      width >= 0 && (hAlign == AL_Left || hAlign == AL_Center || hAlign == AL_Right) &&
 *                0 <= currRegion && currRegion < regionCount
 *  $RETURN       The edit box that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function NexgenEditControl addEditBox(optional string text, optional float width,
                                       optional byte hAlign) {
	local NexgenEditControl editBox;
	local float editBoxWidth;
	
	if (width > 0) {
		editBoxWidth = width;
	} else {
		editBoxWidth = regions[currRegion].w;
	}
	
	editBox = NexgenEditControl(addComponent(class'NexgenEditControl', width,
	                                          defaultEditBoxHeight, hAlign, AL_Center));
	editBox.editBoxWidth = editBoxWidth;
	editBox.setValue(text);
	
	return editBox;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new check box component to the current region.
 *  $PARAM        align  Alignment of the check box.
 *  $PARAM        text   The text to display on the check box.
 *  $PARAM        bBold  Whether or not the text is displayed in a bold font.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The check box that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UWindowCheckbox addCheckBox(optional TextAlign align, optional string text, optional bool bBold) {
	local UWindowCheckbox checkBox;
	
	checkBox = UWindowCheckbox(addComponent(class'UWindowCheckbox', , defaultCheckBoxHeight, , AL_Center));
	checkBox.setText(text);
	checkBox.align = align;
	if (bBold) {
		checkBox.setFont(F_Bold);
	}
	
	return checkBox;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new raised button component to the current region.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The raised that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UMenuRaisedButton addRaisedButton() {
	local UMenuRaisedButton raisedButton;
	
	raisedButton = UMenuRaisedButton(addComponent(class'UMenuRaisedButton', ,
	                                              defaultRaisedButtonHeight, , AL_Center));
	
	return raisedButton;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new image box component to the current region.
 *  $PARAM        image     Texture to display on the component.
 *  $PARAM        bStretch  Whether or not the image should be streched.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The raised button that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function NexgenImageControl addImageBox(optional Texture image, optional bool bStretch,
                                        optional float width, optional float height) {
	local NexgenImageControl imageBox;
	
	imageBox = NexgenImageControl(addComponent(class'NexgenImageControl', width, height, AL_Center, AL_Center));
	imageBox.image = image;
	imageBox.bStretch = bStretch;
	
	return imageBox;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new component container panel to the current region.
 *  $PARAM        bgType  Panel border/background style.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The raised that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function NexgenContentPanel addContentPanel(optional EPanelBackType bgType) {
	local NexgenContentPanel contentPanel;
	
	contentPanel = NexgenContentPanel(addComponent(class'NexgenContentPanel'));
	contentPanel.panelBGType = bgType;
	contentPanel.createPanelRootRegion();
	contentPanel.parentCP = self;
	
	return contentPanel;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new combo control component to the current region.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The combo control that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UWindowComboControl addListCombo() {
	local UWindowComboControl listCombo;
	
	listCombo = UWindowComboControl(addComponent(class'UWindowComboControl', ,
	                                             defaultlistComboHeight, , AL_Center));
	listCombo.editBoxWidth = listCombo.winWidth;
	listCombo.setEditable(false);
	return listCombo;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new dynamic text area control component to the current region.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The dynamic text area control that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UWindowDynamicTextArea addDynamicTextArea() {
	local UMenuMapListFrameCW frame;
	local UWindowDynamicTextArea textArea;
	
	frame = UMenuMapListFrameCW(addComponent(class'UMenuMapListFrameCW'));
	textArea = UWindowDynamicTextArea(CreateControl(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	textArea.setTextColor(lookAndFeel.editBoxTextColor);
    textArea.bTopCentric = false;
	frame.frame.setFrame(textArea);
	
	return textArea;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new dynamic text area control component to the current region.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The dynamic text area control that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UWindowListBox addListBox(class<UWindowListBox> listBoxClass) {
	local UMenuMapListFrameCW frame;
	local UWindowListBox listBox;
	
	frame = UMenuMapListFrameCW(addComponent(class'UMenuMapListFrameCW'));
	listBox = UWindowListBox(CreateControl(listBoxClass, 0, 0, 100, 100));
	frame.frame.setFrame(listBox);
	
	return listBox;
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
function notify(UWindowDialogControl control, byte eventType) {
	super.notify(control, eventType);
	
	// Delegate events to parent.
	if (parentCP != none) {
		parentCP.notify(control, eventType);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of a key press event.
 *  $PARAM        key  The number of the key that was pressed.
 *  $PARAM        x    Unknown, x location of mouse cursor?
 *  $PARAM        y    Unknown, x location of mouse cursor?
 *  $OVERRIDE
 *
 **************************************************************************************************/
function keyDown(int key, float x, float y) {
	// Delegate events to parent.
	if (parentCP != none) {
		parentCP.keyDown(key, x, y);
	}
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
	switch (panelBGType) {
		case PBT_Beveled:
			drawUpBevel(c, 0, 0, winWidth, winHeight, getLookAndFeelTexture());
			break;
		
		case PBT_Transparent:
			// Do nothing.
			break;
			
		default:
			super.paint(c, x, y);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelBGType=PBT_Default
}