/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPTagProtectionRCP
 *  $VERSION      1.00 (05-12-2010 17:25:36)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Tag protection settings control panel page.
 *
 **************************************************************************************************/
class NXPTagProtectionRCP extends NexgenPanel;

var NXPClient xClient;
var NexgenSharedDataContainer xConf;

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
	
	xClient = NXPClient(client.getController(class'NXPClient'.default.ctrlID));
	
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
	resetButton.bDisabled = true;
	saveButton.bDisabled = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	local int index;
	
	// Quit if configuration is not available.
	if (xConf == none) return;
	
	enableTagProtectionInp.bChecked = xConf.getBool("enableTagProtection");
	
	for (index = 0; index < arrayCount(protectedTagsInp); index++) {
		protectedTagsInp[index].setValue(xConf.getString("tagsToProtect", index));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization of the given shared data container is
 *                done. After this has happend the client may query its variables and receive valid
 *                results (assuming the client is allowed to read those variables).
 *  $PARAM        container  The shared data container that has become available for use.
 *  $REQUIRE      container != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function dataContainerAvailable(NexgenSharedDataContainer container) {
	if (container.containerID == class'NXPConfigDC'.default.containerID) {
		xConf = container;
		setValues();
		resetButton.bDisabled = false;
		saveButton.bDisabled = false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *  $OVERRIDE
 *
 **************************************************************************************************/
function varChanged(NexgenSharedDataContainer container, string varName, optional int index) {
	if (container.containerID ~= class'NXPConfigDC'.default.containerID) {
		switch (varName) {
			case "enableTagProtection": enableTagProtectionInp  .bChecked = container.getBool(varName);           break;
			case "tagsToProtect":       protectedTagsInp[index] .setValue  (container.getString(varName, index)); break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {
	local int index;
	
	xClient.setVar("nxp_config", "enableTagProtection", enableTagProtectionInp  .bChecked);
	for (index = 0; index < arrayCount(protectedTagsInp); index++) {
	xClient.setVar("nxp_config", "tagsToProtect",       protectedTagsInp[index] .getValue(), index);
	}
	xClient.saveSharedData("nxp_config");
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
	panelIdentifier="nxp_tag_protection_settings"
	panelHeight=106
}
