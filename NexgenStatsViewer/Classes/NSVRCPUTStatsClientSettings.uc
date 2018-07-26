/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $CLASS        NSVRCPUTStatsClientSettings
 *  $VERSION      1.01 (23-6-2008 23:01)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  UTStats client settings control panel page.
 *
 **************************************************************************************************/
class NSVRCPUTStatsClientSettings extends NexgenPanel;

var NSVClient xClient;

var UWindowCheckbox enableUTStatsClientInp;
var UWindowEditControl utStatsHostInp;
var UWindowEditControl utStatsPortInp;
var UWindowEditControl utStatsPathInp;

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
	
	xClient = NSVClient(client.getController(class'NSVClient'.default.ctrlID));
	
	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(xClient.lng.utstatsClientSettingsPanelTitle, true, TA_Center);

	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');
	
	divideRegionV(2, 2 * defaultComponentDist);
	divideRegionH(3);
	divideRegionH(3);
	splitRegionV(64);
	splitRegionV(64);
	splitRegionV(64);
	enableUTStatsClientInp = addCheckBox(TA_Left, xClient.lng.enableUTStatsClientTxt, true);
	skipRegion();
	splitRegionV(196, , , true);
	addLabel(xClient.lng.utStatsHostMsg, true);
	utStatsHostInp = addEditBox();
	addLabel(xClient.lng.utStatsPortMsg, true);
	utStatsPortInp = addEditBox();
	addLabel(xClient.lng.utStatsPathMsg, true);
	utStatsPathInp = addEditBox();
	
	skipRegion();
	divideRegionV(2, defaultComponentDist);
	saveButton = addButton(client.lng.saveTxt);
	resetButton = addButton(client.lng.resetTxt);
		
	// Configure components.
	utStatsHostInp.setMaxLength(50);
	utStatsPortInp.setMaxLength(5);
	utStatsPathInp.setMaxLength(250);
	utStatsPortInp.setNumericOnly(true);
	setValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	enableUTStatsClientInp.bChecked = xClient.conf.enableUTStatsClient;
	utStatsHostInp.setValue(xClient.conf.utStatsHost);
	utStatsPortInp.setValue(string(xClient.conf.utStatsPort));
	utStatsPathInp.setValue(xClient.conf.utStatsPath);
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
	if (type ~= xClient.conf.EVENT_NexgenStatsViewerConfigChanged && byte(arguments) == xClient.conf.CT_UTStatsClientSettings) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {
	xClient.setUTStatsClientSettings(enableUTStatsClientInp.bChecked,
	                                 utStatsHostInp.getValue(),
	                                 int(utStatsPortInp.getValue()),
	                                 utStatsPathInp.getValue());
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
	panelIdentifier="nsvutstatsclientsettings"
	panelHeight=96
}
