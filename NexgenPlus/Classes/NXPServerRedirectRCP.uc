/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPServerRedirectRCP
 *  $VERSION      1.00 (06-09-2010 11:56)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Full server redirect settings control panel page.
 *
 **************************************************************************************************/
class NXPServerRedirectRCP extends NexgenPanel;

var NXPClient xClient;
var NexgenSharedDataContainer xConf;

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;

var UWindowCheckbox enableFullServerRedirectInp;
var UWindowCheckbox autoFullServerRedirectInp;
var UWindowEditControl altServerNameInp[3];
var UWindowEditControl altServerAddressInp[3];



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local int region;
	local int index;
	
	xClient = NXPClient(client.getController(class'NXPClient'.default.ctrlID));

	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(xClient.lng.fullServerRedirectPanelTitle, true, TA_Center);

	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');
	
	splitRegionH(20, defaultComponentDist, , true);
	region = currRegion;
	skipRegion();
	splitRegionV(65, , true);
	skipRegion();
	divideRegionV(2, defaultComponentDist);
	saveButton = addButton(client.lng.saveTxt);
	resetButton = addButton(client.lng.resetTxt);

	selectRegion(region);
	selectRegion(divideRegionH(5));
	splitRegionV(65, , true);
	splitRegionV(65, , true);
	for (index = 0; index < arrayCount(altServerNameInp); index++) {
		splitRegionV(192, 2 * defaultComponentDist);
	}
	addLabel(xClient.lng.enableFullServerRedirectTxt, true, TA_Left);
	enableFullServerRedirectInp = addCheckBox(TA_Right);
	addLabel(xClient.lng.autoFullServerRedirectTxt, true, TA_Left);
	autoFullServerRedirectInp = addCheckBox(TA_Right);
	for (index = 0; index < arrayCount(altServerNameInp); index++) {
		splitRegionV(64);
		splitRegionV(64);
	}
	for (index = 0; index < arrayCount(altServerNameInp); index++) {
		addLabel(client.lng.format(xClient.lng.serverEntryTxt, index + 1), true);
		altServerNameInp[index] = addEditBox();
		addLabel(xClient.lng.urlTxt, true);
		altServerAddressInp[index] = addEditBox();
		altServerNameInp[index].setMaxLength(24);
		altServerAddressInp[index].setMaxLength(64);
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
	
	enableFullServerRedirectInp    .bChecked = xConf.getBool   ("enableFullServerRedirect");
	autoFullServerRedirectInp      .bChecked = xConf.getBool   ("autoFullServerRedirect");
	for (index = 0; index < arrayCount(altServerNameInp); index++) {
	altServerNameInp[index]        .setValue  (xConf.getString ("altServerName", index));
	altServerAddressInp[index]     .setValue  (xConf.getString ("altServerAddress", index));
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
			case "enableFullServerRedirect": enableFullServerRedirectInp .bChecked = container.getBool(varName);           break;
			case "autoFullServerRedirect":   autoFullServerRedirectInp   .bChecked = container.getBool(varName);           break;
			case "altServerName":            altServerNameInp[index]     .setValue  (container.getString(varName, index)); break;
			case "altServerAddress":         altServerAddressInp[index]  .setValue  (container.getString(varName, index)); break;
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
	
	xClient.setVar("nxp_config", "enableFullServerRedirect", enableFullServerRedirectInp .bChecked);
	xClient.setVar("nxp_config", "autoFullServerRedirect",   autoFullServerRedirectInp   .bChecked);
	for (index = 0; index < arrayCount(altServerNameInp); index++) {
	xClient.setVar("nxp_config", "altServerName",            altServerNameInp[index]     .getValue(), index);
	xClient.setVar("nxp_config", "altServerAddress",         altServerAddressInp[index]  .getValue(), index);
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
	panelIdentifier="nxp_full_server_redirect_settings"
	panelHeight=150
}