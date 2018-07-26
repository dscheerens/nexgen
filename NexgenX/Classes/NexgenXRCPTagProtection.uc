/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXRCPTagProtection
 *  $VERSION      1.00 (22-6-2008 10:27)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen extension plugin settings control panel page.
 *
 **************************************************************************************************/
class NexgenXRCPTagProtection extends NexgenPanel;

var NexgenXClient xClient;

var UWindowCheckbox enableTagProtectionInp;
var UWindowEditControl protectedTagsInp[6];

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;

const maxTagsPerRow = 6;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local int region;
	local int numRows;
	local int index;
	
	xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
	
	// Compute number of rows.
	numRows = arrayCount(protectedTagsInp) / maxTagsPerRow;
	if (arrayCount(protectedTagsInp) % maxTagsPerRow > 0) {
		numRows++;
	}
	
	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(xClient.lng.tagProtectionPanelTitle, true, TA_Center);

	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');
	
	splitRegionH(20, defaultComponentDist, , true);
	region = currRegion;
	skipRegion();
	splitRegionV(196, , , true);
	skipRegion();
	divideRegionV(2, defaultComponentDist);
	saveButton = addButton(client.lng.saveTxt);
	resetButton = addButton(client.lng.resetTxt);
	
	selectRegion(region);
	selectRegion(splitRegionH(20));
	enableTagProtectionInp = addCheckBox(TA_Left, xClient.lng.enableTagProtectionTxt, true);
	selectRegion(splitRegionH(20));
	addLabel(xClient.lng.protectedTagsTxt, true);
	divideRegionH(numRows);
	for (index = 0; index < numRows; index++) {
		divideRegionV(maxTagsPerRow, defaultComponentDist);
	}
	for (index = 0; index < arrayCount(protectedTagsInp); index++) {
		protectedTagsInp[index] = addEditBox();
		protectedTagsInp[index].setMaxLength(10);
	}
	
	// Configure components.
	setValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	local int index;
	
	enableTagProtectionInp.bChecked = xClient.xConf.enableTagProtection;
	
	for (index = 0; index < arrayCount(protectedTagsInp); index++) {
		protectedTagsInp[index].setValue(xClient.xConf.tagsToProtect[index]);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *
 **************************************************************************************************/
function notifyEvent(string type, optional string arguments) {
	if (type ~= xClient.xConf.EVENT_NexgenXConfigChanged && byte(arguments) == xClient.xConf.CT_TagProtectionSettings) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {
	xClient.setTagProtectionSettings(enableTagProtectionInp.bChecked,
	                                 protectedTagsInp[0].getValue(),
	                                 protectedTagsInp[1].getValue(),
	                                 protectedTagsInp[2].getValue(),
	                                 protectedTagsInp[3].getValue(),
	                                 protectedTagsInp[4].getValue(),
	                                 protectedTagsInp[5].getValue());
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
	
	// Button pressed?
	if (control != none && eventType == DE_Click && control.isA('UWindowSmallButton') &&
	    !UWindowSmallButton(control).bDisabled) {
	
		switch (control) {
			case resetButton: setValues(); break;
			case saveButton: saveSettings(); break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="nexgenxtagprotectionsettings"
	panelHeight=106
}
