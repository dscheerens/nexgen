/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPMiscNexgenSettings
 *  $VERSION      1.08 (05-12-2010 19:14:13)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen extra server settings control panel page.
 *
 **************************************************************************************************/
class NexgenRCPMiscNexgenSettings extends NexgenPanel;

var NexgenClientCore rpci;                        // Remote Procedure Call interface.

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;

var UWindowCheckbox autoUpdateBansInp;
var UWindowCheckbox autoDelExpiredBansInp;
var UWindowCheckbox broadcastAdminActionsInp;
var UWindowCheckbox announceTeamKillsInp;
var UWindowCheckbox useNexgenHUDInp;
var UWindowCheckbox enableNexgenStartControlInp;
var UWindowCheckbox enableAdminStartControlInp;
var UWindowCheckbox restoreScoreOnTeamSwitchInp;
var UWindowCheckbox defaultAllowTeamSwitchInp;
var UWindowCheckbox defaultAllowTeamBalanceInp;
var UWindowCheckbox defaultAllowNameChangeInp;
var UWindowCheckbox autoRegisterServerInp;

var UWindowEditControl gameWaitTimeInp;
var UWindowEditControl gameStartDelayInp;
var UWindowEditControl autoReconnectTimeInp;
var UWindowEditControl maxIdleTimeInp;
var UWindowEditControl maxIdleTimeCPInp;
var UWindowEditControl spawnProtectTimeInp;
var UWindowEditControl teamKillDmgProtectInp;
var UWindowEditControl teamKillPushProtectInp;
var UWindowEditControl autoDisableMatchTimeInp;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	
	// Create layout & add components.
	createPanelRootRegion();
	
	splitRegionH(12, defaultComponentDist);
	addLabel(client.lng.nexgenMiscSettingsPanelTitle, true, TA_Center);

	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');
	
	divideRegionV(2, 2 * defaultComponentDist);
	divideRegionH(12);
	divideRegionH(12);
	
	autoUpdateBansInp           = addCheckBox(TA_Left, client.lng.autoUpdateBansTxt, true);
	autoDelExpiredBansInp       = addCheckBox(TA_Left, client.lng.autoDelExpiredBansTxt, true);
	broadcastAdminActionsInp    = addCheckBox(TA_Left, client.lng.broadcastAdminActionsTxt, true);
	announceTeamKillsInp        = addCheckBox(TA_Left, client.lng.announceTeamKillsTxt, true);
	useNexgenHUDInp             = addCheckBox(TA_Left, client.lng.useNexgenHUDTxt, true);
	enableNexgenStartControlInp = addCheckBox(TA_Left, client.lng.enableNexgenStartControlTxt, true);
	enableAdminStartControlInp  = addCheckBox(TA_Left, client.lng.enableAdminStartControlTxt, true);
	restoreScoreOnTeamSwitchInp = addCheckBox(TA_Left, client.lng.restoreScoreOnTeamSwitchTxt, true);
	defaultAllowTeamSwitchInp   = addCheckBox(TA_Left, client.lng.defaultAllowTeamSwitchTxt, true);
	defaultAllowTeamBalanceInp  = addCheckBox(TA_Left, client.lng.defaultAllowTeamBalanceTxt, true);
	defaultAllowNameChangeInp   = addCheckBox(TA_Left, client.lng.defaultAllowNameChangeTxt, true);
	autoRegisterServerInp       = addCheckBox(TA_Left, client.lng.autoRegisterServerTxt, true);
	
	splitRegionV(64, , , true);
	splitRegionV(64, , , true);
	splitRegionV(64, , , true);
	splitRegionV(64, , , true);
	splitRegionV(64, , , true);
	splitRegionV(64, , , true);
	splitRegionV(64, , , true);
	splitRegionV(64, , , true);
	splitRegionV(64, , , true);
	skipRegion();
	skipRegion();
	splitRegionV(196, , , true);

	addLabel(client.lng.gameWaitTimeTxt, true);          gameWaitTimeInp         = addEditBox();
	addLabel(client.lng.gameStartDelayTxt, true);        gameStartDelayInp       = addEditBox();
	addLabel(client.lng.autoReconnectTimeTxt, true);     autoReconnectTimeInp    = addEditBox();
	addLabel(client.lng.maxIdleTimeTxt, true);           maxIdleTimeInp          = addEditBox();
	addLabel(client.lng.maxIdleTimeCPTxt, true);         maxIdleTimeCPInp        = addEditBox();
	addLabel(client.lng.spawnProtectTimeTxt, true);      spawnProtectTimeInp     = addEditBox();
	addLabel(client.lng.teamKillDmgProtectTxt, true);    teamKillDmgProtectInp   = addEditBox();
	addLabel(client.lng.teamKillPushProtectTxt, true);   teamKillPushProtectInp  = addEditBox();
	addLabel(client.lng.autoDisableMatchTimeTxt, true);  autoDisableMatchTimeInp = addEditBox();
	skipRegion();
	
	divideRegionV(2, defaultComponentDist);
	saveButton = addButton(client.lng.saveTxt);
	resetButton = addButton(client.lng.resetTxt);
	
	// Configure components.
	gameWaitTimeInp.setMaxLength(2);
	gameStartDelayInp.setMaxLength(2);
	autoReconnectTimeInp.setMaxLength(2);
	maxIdleTimeInp.setMaxLength(3);
	maxIdleTimeCPInp.setMaxLength(3);
	spawnProtectTimeInp.setMaxLength(2);
	teamKillDmgProtectInp.setMaxLength(2);
	teamKillPushProtectInp.setMaxLength(2);
	autoDisableMatchTimeInp.setMaxLength(2);
	
	gameWaitTimeInp.setNumericOnly(true);
	gameStartDelayInp.setNumericOnly(true);
	autoReconnectTimeInp.setNumericOnly(true);
	maxIdleTimeInp.setNumericOnly(true);
	maxIdleTimeCPInp.setNumericOnly(true);
	spawnProtectTimeInp.setNumericOnly(true);
	teamKillDmgProtectInp.setNumericOnly(true);
	teamKillPushProtectInp.setNumericOnly(true);
	autoDisableMatchTimeInp.setNumericOnly(true);
	
	setValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current server settings.
 *
 **************************************************************************************************/
function setValues() {
	autoUpdateBansInp.bChecked = client.sConf.autoUpdateBans;
	autoDelExpiredBansInp.bChecked = client.sConf.removeExpiredBans;
	broadcastAdminActionsInp.bChecked = client.sConf.broadcastAdminActions;
	announceTeamKillsInp.bChecked = client.sConf.broadcastTeamKillAttempts;
	useNexgenHUDInp.bChecked = client.sConf.useNexgenHUD;
	enableNexgenStartControlInp.bChecked = client.sConf.enableNexgenStartControl;
	enableAdminStartControlInp.bChecked = client.sConf.enableAdminStartControl;
	restoreScoreOnTeamSwitchInp.bChecked = client.sConf.restoreScoreOnTeamSwitch;
	defaultAllowTeamSwitchInp.bChecked = client.sConf.allowTeamSwitch;
	defaultAllowTeamBalanceInp.bChecked = client.sConf.allowTeamBalance;
	defaultAllowNameChangeInp.bChecked = client.sConf.allowNameChange;
	autoRegisterServerInp.bChecked = client.sConf.autoRegisterServer;
	
	gameWaitTimeInp.setValue(string(client.sConf.waitTime));
	gameStartDelayInp.setValue(string(client.sConf.startTime));
	autoReconnectTimeInp.setValue(string(client.sConf.autoReconnectTime));
	maxIdleTimeInp.setValue(string(client.sConf.maxIdleTime));
	maxIdleTimeCPInp.setValue(string(client.sConf.maxIdleTimeCP));
	spawnProtectTimeInp.setValue(string(client.sConf.spawnProtectionTime));
	teamKillDmgProtectInp.setValue(string(client.sConf.teamKillDamageProtectionTime));
	teamKillPushProtectInp.setValue(string(client.sConf.teamKillPushProtectionTime));
	autoDisableMatchTimeInp.setValue(string(client.sConf.autoDisableMatchTime));
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
	if (configType == client.sConf.CT_ExtraServerSettings) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attemps to locate the RPC interface for this control panel.
 *  $REQUIRE      client != none
 *  $RETURN       True if the RPC interface has been set, false if not.
 *  $ENSURE       result == true ? rcpi != none : true
 *
 **************************************************************************************************/
function bool setRPCI() {
	
	// Check if RPC interface is already set.
	if (rpci == none) {
		// Attempt to get the RPC interface.
		rpci = NexgenClientCore(client.getController(class'NexgenClientCore'.default.ctrlID));
		return rpci != none;
		
	} else {
		// It is.
		return true;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the server settings.
 *
 **************************************************************************************************/
function saveSettings() {
	// Make sure the RPC interface is available.
	if (!setRPCI()) return;

	// Save settings.
	rpci.setServerSettingsExt1(autoUpdateBansInp.bChecked,
	                           autoDelExpiredBansInp.bChecked,
	                           broadcastAdminActionsInp.bChecked,
	                           announceTeamKillsInp.bChecked,
	                           useNexgenHUDInp.bChecked,
	                           enableNexgenStartControlInp.bChecked,
	                           enableAdminStartControlInp.bChecked,
	                           restoreScoreOnTeamSwitchInp.bChecked,
	                           defaultAllowTeamSwitchInp.bChecked,
	                           defaultAllowTeamBalanceInp.bChecked,
	                           defaultAllowNameChangeInp.bChecked,
	                           autoRegisterServerInp.bChecked);
	                          
	rpci.setServerSettingsExt2(int(gameWaitTimeInp.getValue()),
	                           int(gameStartDelayInp.getValue()),
	                           int(autoReconnectTimeInp.getValue()),
	                           int(maxIdleTimeInp.getValue()),
	                           int(maxIdleTimeCPInp.getValue()),
	                           int(spawnProtectTimeInp.getValue()),
	                           int(teamKillDmgProtectInp.getValue()),
	                           int(teamKillPushProtectInp.getValue()),
	                           int(autoDisableMatchTimeInp.getValue()));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="miscnexgensettings"
	panelHeight=250
}
