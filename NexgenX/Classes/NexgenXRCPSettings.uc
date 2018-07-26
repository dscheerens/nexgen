/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXRCPSettings
 *  $VERSION      1.03 (7-12-2008 15:56)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen extension plugin settings control panel page.
 *
 **************************************************************************************************/
class NexgenXRCPSettings extends NexgenPanel;

var NexgenXClient xClient;

var UWindowCheckbox enableOverlaySkinInp;
var UWindowCheckbox enableMapSwitchTabInp;
var UWindowCheckbox enableStartAnnouncerInp;
var UWindowCheckbox enableAntiSpamInp;
var UWindowCheckbox enableClientIDAKALogInp;
var UWindowCheckbox checkForUpdatesInp;
var UWindowCheckbox disableUTAntiSpamInp;
var UWindowCheckbox enablePerformanceOptimizerInp;

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
	xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
	
	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(xClient.lng.settingsPanelTitle, true, TA_Center);

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
	divideRegionH(4);
	divideRegionH(4);
	enableOverlaySkinInp = addCheckBox(TA_Left, xClient.lng.enableOverlaySkinTxt, true);
	enableMapSwitchTabInp = addCheckBox(TA_Left, xClient.lng.enableMapSwitchTabTxt, true);
	enableStartAnnouncerInp = addCheckBox(TA_Left, xClient.lng.enableStartAnnouncerTxt, true);
	enableAntiSpamInp = addCheckBox(TA_Left, xClient.lng.enableAntiSpamTxt, true);
	enableClientIDAKALogInp = addCheckBox(TA_Left, xClient.lng.enableClientIDAKALogTxt, true);
	checkForUpdatesInp = addCheckBox(TA_Left, xClient.lng.checkForUpdatesTxt, true);
	disableUTAntiSpamInp = addCheckBox(TA_Left, xClient.lng.disableUTAntiSpamTxt, true);
	enablePerformanceOptimizerInp = addCheckBox(TA_Left, xClient.lng.enablePerformanceOptimizerTxt, true);
	
	// Configure components.
	setValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	enableOverlaySkinInp.bChecked = xClient.xConf.enableOverlaySkin;
	enableMapSwitchTabInp.bChecked = xClient.xConf.enableMapSwitch;
	enableStartAnnouncerInp.bChecked = xClient.xConf.enableStartAnnouncer;
	enableAntiSpamInp.bChecked = xClient.xConf.enableAntiSpam;
	enableClientIDAKALogInp.bChecked = xClient.xConf.enableClientIDAKALog;
	checkForUpdatesInp.bChecked = xClient.xConf.checkForUpdates;
	disableUTAntiSpamInp.bChecked = xClient.xConf.disableUTAntiSpam;
	enablePerformanceOptimizerInp.bChecked = xClient.xConf.enablePerformanceOptimizer;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *
 **************************************************************************************************/
function notifyEvent(string type, optional string arguments) {
	if (type ~= xClient.xConf.EVENT_NexgenXConfigChanged && byte(arguments) == xClient.xConf.CT_GeneralSettings) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {
	xClient.setGeneralSettings(enableOverlaySkinInp.bChecked,
	                           enableMapSwitchTabInp.bChecked,
	                           enableStartAnnouncerInp.bChecked,
	                           enableAntiSpamInp.bChecked,
	                           enableClientIDAKALogInp.bChecked,
	                           checkForUpdatesInp.bChecked,
	                           disableUTAntiSpamInp.bChecked,
	                           enablePerformanceOptimizerInp.bChecked);
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
	panelIdentifier="nexgenxsettings"
	panelHeight=124
}
