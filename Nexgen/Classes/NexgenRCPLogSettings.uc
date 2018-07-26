/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPLogSettings
 *  $VERSION      1.02 (2-12-2008 23:29)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen log settings control panel page.
 *
 **************************************************************************************************/
class NexgenRCPLogSettings extends NexgenPanel;

var NexgenClientCore rpci;

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;

var UWindowCheckbox logToConsoleInp;
var UWindowCheckbox logEventsInp;
var UWindowCheckbox logMessagesInp;
var UWindowCheckbox logChatMessagesInp;
var UWindowCheckbox logPrivateMessagesInp;
var UWindowCheckbox logAdminActionsInp;
var UWindowCheckbox sendPrivateMessagesToMsgSpecsInp;

var UWindowCheckbox logToFileInp;
var UWindowEditControl logFilePathInp;
var UWindowEditControl logFileExtensionInp;
var UWindowEditControl logFileNameFormatInp;
var UWindowEditControl logTimeStampFormatInp;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local int region;
	
	rpci = NexgenClientCore(client.getController(class'NexgenClientCore'.default.ctrlID));
	
	// Create layout & add components.
	createPanelRootRegion();
	
	splitRegionH(12, defaultComponentDist);
	addLabel(client.lng.logSettingsPanelTitle, true, TA_Center);

	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');
	
	divideRegionV(2, 2 * defaultComponentDist);
	divideRegionH(7);
	divideRegionH(7);
	
	logToConsoleInp = addCheckBox(TA_Left, client.lng.logToConsoleTxt, true);
	logEventsInp          = addCheckBox(TA_Left, client.lng.logEventsTxt, true);
	logMessagesInp        = addCheckBox(TA_Left, client.lng.logMessagesTxt, true);
	logChatMessagesInp    = addCheckBox(TA_Left, client.lng.logChatMessagesTxt, true);
	logPrivateMessagesInp = addCheckBox(TA_Left, client.lng.logPrivateMessagesTxt, true);
	logAdminActionsInp    = addCheckBox(TA_Left, client.lng.logAdminActionsTxt, true);
	sendPrivateMessagesToMsgSpecsInp = addCheckBox(TA_Left, client.lng.sendPrivateMessagesToMsgSpecsTxt, true);
	
	logToFileInp = addCheckBox(TA_Left, client.lng.logToFileTxt, true);
	splitRegionV(80);
	splitRegionV(80);
	splitRegionV(80);
	splitRegionV(80);
	skipRegion();
	splitRegionV(196, , , true);
	
	addLabel(client.lng.logFilePathTxt, true);
	logFilePathInp = addEditBox();
	
	addLabel(client.lng.logFileExtensionTxt, true);
	logFileExtensionInp = addEditBox();
	
	addLabel(client.lng.logFileNameFormatTxt, true);
	logFileNameFormatInp = addEditBox();
	
	addLabel(client.lng.logTimeStampFormatTxt, true);
	logTimeStampFormatInp = addEditBox();
	
	skipRegion();
	divideRegionV(2, defaultComponentDist);
	saveButton = addButton(client.lng.saveTxt);
	resetButton = addButton(client.lng.resetTxt);
	
	// Configure components.
	logFilePathInp.setMaxLength(200);
	logFileExtensionInp.setMaxLength(10);
	logFileNameFormatInp.setMaxLength(100);
	logTimeStampFormatInp.setMaxLength(100);
	setValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	logToConsoleInp.bChecked = client.sConf.logToConsole;
	logEventsInp.bChecked = client.sConf.logEvents;
	logMessagesInp.bChecked = client.sConf.logSystemMessages;
	logChatMessagesInp.bChecked = client.sConf.logChatMessages;
	logPrivateMessagesInp.bChecked = client.sConf.logPrivateMessages;
	logAdminActionsInp.bChecked = client.sConf.logAdminActions;
	logToFileInp.bChecked = client.sConf.logToFile;
	sendPrivateMessagesToMsgSpecsInp.bChecked = client.sConf.sendPrivateMessagesToMsgSpecs;

	logFilePathInp.setValue(client.sConf.logPath);
	logFileExtensionInp.setValue(client.sConf.logFileExtension);
	logFileNameFormatInp.setValue(client.sConf.logFileNameFormat);
	logTimeStampFormatInp.setValue(client.sConf.logFileTimeStampFormat);
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
 *  $DESCRIPTION  Notifies this panel that the server configuration has been updated.
 *  $PARAM        configType  Type of settings that have been changed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function configChanged(byte configType) {
	
	// Relevant settings for this panel?
	if (configType == client.sConf.CT_LogSettings) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the server settings.
 *
 **************************************************************************************************/
function saveSettings() {
	rpci.setLogSettings(logEventsInp.bChecked,
	                    logMessagesInp.bChecked,
	                    logChatMessagesInp.bChecked,
	                    logPrivateMessagesInp.bChecked,
	                    logAdminActionsInp.bChecked,
	                    logToConsoleInp.bChecked,
	                    logToFileInp.bChecked,
	                    logFilePathInp.getValue(),
	                    logFileExtensionInp.getValue(),
	                    logFileNameFormatInp.getValue(),
	                    logTimeStampFormatInp.getValue(),
	                    sendPrivateMessagesToMsgSpecsInp.bChecked);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="nexgenlogsettings"
	panelHeight=160
}