/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NXPSettingsRCP
 *  $VERSION      1.02 (03-08-2010 16:48)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen Plus extension plugin settings control panel page.
 *
 **************************************************************************************************/
class NXPSettingsRCP extends NexgenPanel;

var NXPClient xClient;

var NexgenSharedDataContainer xConf;

var UWindowCheckbox enableMapSwitchInp;
var UWindowCheckbox cacheMapListInp;
var UWindowEditControl autoMapListCachingThresholdInp;
var UWindowCheckbox showMapSwitchAtEndOfGameInp;
var UWindowEditControl mapSwitchAutoDisplayDelayInp;
var UWindowCheckbox showDamageProtectionShieldInp;
var UWindowCheckbox colorizePlayerSkinsInp;
var UWindowCheckbox enableAKALoggingInp;
var UWindowCheckbox disableUTAntiSpamInp;
var UWindowCheckbox enableNexgenAntiSpamInp;
var UWindowCheckbox checkForNexgenUpdatesInp;

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
	
	xClient = NXPClient(client.getController(class'NXPClient'.default.ctrlID));

	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(xClient.lng.settingsPanelTitle, true, TA_Center);

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
	selectRegion(splitRegionV(65, , true));
	divideRegionH(12);
	divideRegionH(12);
	
	addLabel(xClient.lng.enableMapSwitchTxt, true, TA_Left);
	addLabel(xClient.lng.cacheMapListTxt, true, TA_Left);
	addLabel(xClient.lng.autoMapListCachingThresholdTxt, true, TA_Left);
	addLabel(xClient.lng.showMapSwitchAtEndOfGameTxt, true, TA_Left);
	addLabel(xClient.lng.mapSwitchAutoDisplayDelayTxt, true, TA_Left);
	mergeRegion(12);
	addLabel(xClient.lng.showDamageProtectionShieldTxt, true, TA_Left);
	addLabel(xClient.lng.colorizePlayerSkinsTxt, true, TA_Left);
	addLabel(xClient.lng.enableAKALoggingTxt, true, TA_Left);
	addLabel(xClient.lng.disableUTAntiSpamTxt, true, TA_Left);
	addLabel(xClient.lng.enableNexgenAntiSpamTxt, true, TA_Left);
	addLabel(xClient.lng.checkForNexgenUpdatesTxt, true, TA_Left);
	enableMapSwitchInp             = addCheckBox(TA_Right);
	cacheMapListInp                = addCheckBox(TA_Right);
	autoMapListCachingThresholdInp = addEditBox();
	showMapSwitchAtEndOfGameInp    = addCheckBox(TA_Right);
	mapSwitchAutoDisplayDelayInp   = addEditBox();
	addComponent(class'NexgenDummyComponent', , 4, , AL_Center);
	showDamageProtectionShieldInp  = addCheckBox(TA_Right);
	colorizePlayerSkinsInp         = addCheckBox(TA_Right);
	enableAKALoggingInp            = addCheckBox(TA_Right);
	disableUTAntiSpamInp           = addCheckBox(TA_Right);
	enableNexgenAntiSpamInp        = addCheckBox(TA_Right);
	checkForNexgenUpdatesInp       = addCheckBox(TA_Right);
	
	// Configure components.
	autoMapListCachingThresholdInp.setMaxLength(4);
	autoMapListCachingThresholdInp.setNumericOnly(true);
	mapSwitchAutoDisplayDelayInp.setMaxLength(3);
	mapSwitchAutoDisplayDelayInp.setNumericOnly(true);
	resetButton.bDisabled = true;
	saveButton.bDisabled = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	// Quit if configuration is not available.
	if (xConf == none) return;
	
	enableMapSwitchInp             .bChecked = xConf.getBool   ("enableMapSwitch");
	cacheMapListInp                .bChecked = xConf.getBool   ("cacheMapList");
	autoMapListCachingThresholdInp .setValue  (xConf.getString ("autoMapListCachingThreshold"));
	showMapSwitchAtEndOfGameInp    .bChecked = xConf.getBool   ("showMapSwitchAtEndOfGame");
	mapSwitchAutoDisplayDelayInp   .setValue  (xConf.getString ("mapSwitchAutoDisplayDelay"));
	showDamageProtectionShieldInp  .bChecked = xConf.getBool   ("showDamageProtectionShield");
	colorizePlayerSkinsInp         .bChecked = xConf.getBool   ("colorizePlayerSkins");
	enableAKALoggingInp            .bChecked = xConf.getBool   ("enableAKALogging");
	disableUTAntiSpamInp           .bChecked = xConf.getBool   ("disableUTAntiSpam");
	enableNexgenAntiSpamInp        .bChecked = xConf.getBool   ("enableNexgenAntiSpam");
	checkForNexgenUpdatesInp       .bChecked = xConf.getBool   ("checkForNexgenUpdates");
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
			case "enableMapSwitch":             enableMapSwitchInp             .bChecked = container.getBool(varName);    break;
			case "cacheMapList":                cacheMapListInp                .bChecked = container.getBool(varName);    break;
			case "autoMapListCachingThreshold": autoMapListCachingThresholdInp .setValue  (container.getString(varName)); break;
			case "showMapSwitchAtEndOfGame":    showMapSwitchAtEndOfGameInp    .bChecked = container.getBool(varName);    break;
			case "mapSwitchAutoDisplayDelay":   mapSwitchAutoDisplayDelayInp   .setValue  (container.getString(varName)); break;
			case "showDamageProtectionShield":  showDamageProtectionShieldInp  .bChecked = container.getBool(varName);    break;
			case "colorizePlayerSkins":         colorizePlayerSkinsInp         .bChecked = container.getBool(varName);    break;
			case "enableAKALogging":            enableAKALoggingInp            .bChecked = container.getBool(varName);    break;
			case "disableUTAntiSpam":           disableUTAntiSpamInp           .bChecked = container.getBool(varName);    break;
			case "enableNexgenAntiSpam":        enableNexgenAntiSpamInp        .bChecked = container.getBool(varName);    break;
			case "checkForNexgenUpdates":       checkForNexgenUpdatesInp       .bChecked = container.getBool(varName);    break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {
	xClient.setVar("nxp_config", "enableMapSwitch",             enableMapSwitchInp             .bChecked);
	xClient.setVar("nxp_config", "cacheMapList",                cacheMapListInp                .bChecked);
	xClient.setVar("nxp_config", "autoMapListCachingThreshold", autoMapListCachingThresholdInp .getValue());
	xClient.setVar("nxp_config", "showMapSwitchAtEndOfGame",    showMapSwitchAtEndOfGameInp    .bChecked);
	xClient.setVar("nxp_config", "mapSwitchAutoDisplayDelay",   mapSwitchAutoDisplayDelayInp   .getValue());
	xClient.setVar("nxp_config", "showDamageProtectionShield",  showDamageProtectionShieldInp  .bChecked);
	xClient.setVar("nxp_config", "colorizePlayerSkins",         colorizePlayerSkinsInp         .bChecked);
	xClient.setVar("nxp_config", "enableAKALogging",            enableAKALoggingInp            .bChecked);
	xClient.setVar("nxp_config", "disableUTAntiSpam",           disableUTAntiSpamInp           .bChecked);
	xClient.setVar("nxp_config", "enableNexgenAntiSpam",        enableNexgenAntiSpamInp        .bChecked);
	xClient.setVar("nxp_config", "checkForNexgenUpdates",       checkForNexgenUpdatesInp       .bChecked);
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
	panelIdentifier="nexgenplussettings"
	panelHeight=250
}