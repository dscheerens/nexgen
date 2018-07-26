/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $CLASS        NGLSRCPSettings
 *  $VERSION      1.00 (6-9-2008 18:50)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  The Nexgen Global Login System settings control panel.
 *
 **************************************************************************************************/
class NGLSRCPSettings extends NexgenPanel;

var NGLSClient xClient;

var UWindowEditControl nglsServerHostInp;
var UWindowEditControl nglsServerPortInp;
var UWindowEditControl nglsServerPathInp;
var UWindowEditControl loginTimeoutInp;
var UWindowEditControl registerURLInp;

var UWindowCheckbox enableNGLSInp;
var UWindowCheckbox acceptLocalAccountsInp;
var UWindowCheckbox allowUnregisteredSpecsInp;
var UWindowCheckbox disconnectClientWhenVerifyFailsInp;

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local int region;
	
	xClient = NGLSClient(client.getController(class'NGLSClient'.default.ctrlID));
	
	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(xClient.lng.nglsSettingsPanelTitle, true, TA_Center);

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
	selectRegion(divideRegionV(2, 2 * defaultComponentDist));
	divideRegionH(5);
	divideRegionH(5);

	splitRegionV(96);
	splitRegionV(96);
	splitRegionV(96);
	splitRegionV(96);
	splitRegionV(96);

	enableNGLSInp = addCheckBox(TA_Left, xClient.lng.enableNGLSTxt, true);
	acceptLocalAccountsInp = addCheckBox(TA_Left, xClient.lng.acceptLocalAccountsTxt, true);
	allowUnregisteredSpecsInp = addCheckBox(TA_Left, xClient.lng.allowUnregisteredSpecsTxt, true);
	disconnectClientWhenVerifyFailsInp = addCheckBox(TA_Left, xClient.lng.disconnectClientWhenVerifyFailsTxt, true);
	skipRegion();
	addLabel(xClient.lng.nglsServerHostTxt, true);
	nglsServerHostInp = addEditBox();
	addLabel(xClient.lng.nglsServerPortTxt, true);
	nglsServerPortInp = addEditBox();
	addLabel(xClient.lng.nglsServerPathTxt, true);
	nglsServerPathInp = addEditBox();
	addLabel(xClient.lng.loginTimeoutTxt, true);
	loginTimeoutInp = addEditBox();
	addLabel(xClient.lng.registerURLTxt, true);
	registerURLInp = addEditBox();
			
	// Configure components.
	nglsServerHostInp.setMaxLength(50);
	nglsServerPortInp.setMaxLength(5);
	nglsServerPathInp.setMaxLength(250);
	loginTimeoutInp.setMaxLength(3);
	registerURLInp.setMaxLength(150);
	nglsServerPortInp.setNumericOnly(true);
	loginTimeoutInp.setNumericOnly(true);
	setValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	nglsServerHostInp.setValue(xClient.xConf.nglsServerHost);
	nglsServerPortInp.setValue(string(xClient.xConf.nglsServerPort));
	nglsServerPathInp.setValue(xClient.xConf.nglsServerPath);
	loginTimeoutInp.setValue(string(xClient.xConf.loginTimeout));
	registerURLInp.setValue(xClient.xConf.registerURL);
	enableNGLSInp.bChecked = xClient.xConf.enableNGLS;
	acceptLocalAccountsInp.bChecked = xClient.xConf.acceptLocalAccounts;
	allowUnregisteredSpecsInp.bChecked = xClient.xConf.allowUnregisteredSpecs;
	disconnectClientWhenVerifyFailsInp.bChecked = xClient.xConf.disconnectClientWhenVerifyFails;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notifyEvent(string type, optional string arguments) {
	if (type ~= xClient.xConf.EVENT_NexgenGLSConfigChanged && byte(arguments) == xClient.xConf.CT_GeneralSettings) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {
	xClient.setGeneralSettings(enableNGLSInp.bChecked,
	                           int(loginTimeoutInp.getValue()),
	                           acceptLocalAccountsInp.bChecked,
	                           allowUnregisteredSpecsInp.bChecked,
	                           registerURLInp.getValue(),
	                           disconnectClientWhenVerifyFailsInp.bChecked,
	                           nglsServerHostInp.getValue(),
	                           int(nglsServerPortInp.getValue()),
	                           nglsServerPathInp.getValue());
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
	panelIdentifier="nglssettings"
	panelHeight=150
}
