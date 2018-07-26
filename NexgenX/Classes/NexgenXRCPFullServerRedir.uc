/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXRCPFullServerRedir
 *  $VERSION      1.01 (14-3-2008 21:15)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen extension plugin settings control panel page.
 *
 **************************************************************************************************/
class NexgenXRCPFullServerRedir extends NexgenPanel;

var NexgenXClient xClient;

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;

var UWindowCheckbox enableFullServerRedirectInp;
var UWindowCheckbox enableAutoRedirectInp;
var UWindowEditControl fullServerRedirectMsgInp;
var UWindowEditControl redirectServerNameInp[3];
var UWindowEditControl redirectURLInp[3];



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local int region;
	local int index;
	
	xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
	
	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(xClient.lng.fullServerRedirPanelTitle, true, TA_Center);

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
	selectRegion(divideRegionH(6));
	enableFullServerRedirectInp = addCheckBox(TA_Left, xClient.lng.enableFullServerRedirTxt, true);
	enableAutoRedirectInp = addCheckBox(TA_Left, xClient.lng.enableAutoRedirectTxt, true);
	splitRegionV(64);
	splitRegionV(192, 2 * defaultComponentDist);
	splitRegionV(192, 2 * defaultComponentDist);
	splitRegionV(192, 2 * defaultComponentDist);
	addLabel(xClient.lng.messageTxt, true);
	fullServerRedirectMsgInp = addEditBox();
	splitRegionV(64);
	splitRegionV(64);
	splitRegionV(64);
	splitRegionV(64);
	splitRegionV(64);
	splitRegionV(64);
	
	for (index = 0; index < arrayCount(redirectServerNameInp); index++) {
		addLabel(client.lng.format(xClient.lng.serverEntryTxt, index + 1), true);
		redirectServerNameInp[index] = addEditBox();
		addLabel(xClient.lng.urlTxt, true);
		redirectURLInp[index] = addEditBox();
		redirectServerNameInp[index].setMaxLength(24);
		redirectURLInp[index].setMaxLength(64);
	}
	
	// Configure components.
	fullServerRedirectMsgInp.setMaxLength(250);
	setValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	local int index;
	
	enableFullServerRedirectInp.bChecked = xClient.xConf.enableFullServerRedirect;
	enableAutoRedirectInp.bChecked = xClient.xConf.enableAutoRedirect;
	fullServerRedirectMsgInp.setValue(xClient.xConf.fullServerRedirectMsg);
	
	for (index = 0; index < arrayCount(redirectServerNameInp); index++) {
		redirectServerNameInp[index].setValue(xClient.xConf.redirectServerName[index]);
		redirectURLInp[index].setValue(xClient.xConf.redirectURL[index]);
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
	if (type ~= xClient.xConf.EVENT_NexgenXConfigChanged && byte(arguments) == xClient.xConf.CT_FullServerRedirect) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {
	xClient.setFullServerRedirSettings(enableFullServerRedirectInp.bChecked,
	                                   fullServerRedirectMsgInp.getValue(),
	                                   redirectServerNameInp[0].getValue(),
	                                   redirectServerNameInp[1].getValue(),
	                                   redirectServerNameInp[2].getValue(),
	                                   redirectURLInp[0].getValue(),
	                                   redirectURLInp[1].getValue(),
	                                   redirectURLInp[2].getValue(),
	                                   enableAutoRedirectInp.bChecked);
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
	panelIdentifier="nexgenxfullserverredirectsettings"
	panelHeight=168
}
