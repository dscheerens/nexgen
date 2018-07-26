/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXRCPServerRules
 *  $VERSION      1.01 (13-12-2008 18:42)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen extension plugin settings control panel page.
 *
 **************************************************************************************************/
class NexgenXRCPServerRules extends NexgenPanel;

var NexgenXClient xClient;

var UWindowCheckbox enableServerRulesInp;
var UWindowEditControl serverRulesInp[10];

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
	local int index;
	
	xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));

	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(xClient.lng.serverRulesPanelTitle, true, TA_Center);

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
	enableServerRulesInp = addCheckBox(TA_Left, xClient.lng.enableServerRulesTxt, true);
	selectRegion(splitRegionH(20));
	addLabel(xClient.lng.serverRulesCaptionTxt, true);
	divideRegionV(2, 2 * defaultComponentDist);
	divideRegionH(arrayCount(serverRulesInp) / 2);
	divideRegionH(arrayCount(serverRulesInp) / 2);
	
	for (index = 0; index < arrayCount(serverRulesInp); index++) {
		splitRegionV(15);
	}
	for (index = 0; index < arrayCount(serverRulesInp); index++) {
		addLabel(string(index + 1), true, TA_CENTER);
		serverRulesInp[index] = addEditBox();
		serverRulesInp[index].setMaxLength(200);
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
	
	enableServerRulesInp.bChecked = xClient.xConf.enableServerRules;
	
	for (index = 0; index < arrayCount(serverRulesInp); index++) {
		serverRulesInp[index].setValue(xClient.xConf.serverRules[index]);
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
	if (type ~= xClient.xConf.EVENT_NexgenXConfigChanged && byte(arguments) == xClient.xConf.CT_ServerRulesSettings) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {
	local int index;
	
	for (index = 0; index < arrayCount(serverRulesInp); index++) {
		xClient.setServerRule(index, serverRulesInp[index].getValue());
	}
	
	xClient.setServerRulesSettings(enableServerRulesInp.bChecked);
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
	panelIdentifier="nexgenxserverrulessettings"
	panelHeight=192
}