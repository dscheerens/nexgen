/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPServerSettings
 *  $VERSION      1.03 (7-10-2007 13:21)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen server settings control panel page.
 *
 **************************************************************************************************/
class NexgenRCPServerSettings extends NexgenPanel;

var NexgenClientCore rpci;                        // Remote Procedure Call interface.

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;
var UWindowEditControl serverNameInp;
var UWindowEditControl shortServerNameInp;
var UWindowEditControl MOTDInp[4];
var UWindowEditControl adminNameInp;
var UWindowEditControl adminEmailInp;
var UWindowEditControl serverPasswordInp;
var UWindowEditControl adminPasswordInp;
var UWindowEditControl playerSlotsInp;
var UWindowEditControl vipSlotsInp;
var UWindowEditControl adminSlotsInp;
var UWindowEditControl specSlotsInp;
var UWindowCheckbox doUplinkInp;
var UWindowCheckbox variablePlayerSlotsInp;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local NexgenContentPanel p;
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionH(20, defaultComponentDist, , true);
	p = addContentPanel();
	splitRegionV(196, , , true);
	skipRegion();
	divideRegionV(2, defaultComponentDist);
	saveButton = addButton(client.lng.saveTxt);
	resetButton = addButton(client.lng.resetTxt);
	
	p.splitRegionH(55, , true);
	p.splitRegionV(100);
	p.splitRegionV(30, defaultComponentDist, true);
	p.divideRegionH(6);
	p.divideRegionH(6);
	p.splitRegionV(100);
	p.splitRegionV(100);
	p.addLabel(client.lng.serverNameTxt, true);
	p.addLabel(client.lng.shortServerNameTxt, true);
	p.addLabel(client.lng.format(client.lng.MOTDLineTxt, 1), true);
	p.addLabel(client.lng.format(client.lng.MOTDLineTxt, 2), true);
	p.addLabel(client.lng.format(client.lng.MOTDLineTxt, 3), true);
	p.addLabel(client.lng.format(client.lng.MOTDLineTxt, 4), true);
	serverNameInp = p.addEditBox();
	shortServerNameInp = p.addEditBox();
	MOTDInp[0] = p.addEditBox();
	MOTDInp[1] = p.addEditBox();
	MOTDInp[2] = p.addEditBox();
	MOTDInp[3] = p.addEditBox();
	
	p.divideRegionH(5);
	p.divideRegionH(5);
	p.divideRegionH(5);
	p.divideRegionH(5);
	
	p.addLabel(client.lng.playerSlotsTxt, true);
	p.addLabel(client.lng.vipSlotsTxt, true);
	p.addLabel(client.lng.adminSlotsTxt, true);
	p.addLabel(client.lng.specSlotsTxt, true);
	p.addLabel(client.lng.variablePlayerSlotsTxt, true);
	playerSlotsInp = p.addEditBox( , 48, AL_Left);
	vipSlotsInp = p.addEditBox( , 48, AL_Left);
	adminSlotsInp = p.addEditBox( , 48, AL_Left);
	specSlotsInp = p.addEditBox( , 48, AL_Left);
	variablePlayerSlotsInp = p.addCheckBox(TA_Right);

	p.addLabel(client.lng.adminNameTxt, true);
	p.addLabel(client.lng.adminEmailTxt, true);
	p.addLabel(client.lng.serverPasswordTxt, true);
	p.addLabel(client.lng.adminPasswordTxt, true);	
	p.addLabel(client.lng.advertiseTxt, true);
	adminNameInp = p.addEditBox();
	adminEmailInp = p.addEditBox();
	serverPasswordInp = p.addEditBox();
	adminPasswordInp = p.addEditBox();
	doUplinkInp = p.addCheckBox(TA_Right);

	// Configure components.
	serverNameInp.setMaxLength(128);
	shortServerNameInp.setMaxLength(32);
	MOTDInp[0].setMaxLength(192);
	MOTDInp[1].setMaxLength(192);
	MOTDInp[2].setMaxLength(192);
	MOTDInp[3].setMaxLength(192);
	adminNameInp.setMaxLength(64);
	adminEmailInp.setMaxLength(64);
	serverPasswordInp.setMaxLength(30);
	adminPasswordInp.setMaxLength(30);
	playerSlotsInp.setNumericOnly(true);
	vipSlotsInp.setNumericOnly(true);
	adminSlotsInp.setNumericOnly(true);
	specSlotsInp.setNumericOnly(true);
	playerSlotsInp.setMaxLength(3);
	vipSlotsInp.setMaxLength(3);
	adminSlotsInp.setMaxLength(3);
	specSlotsInp.setMaxLength(3);
	setValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current server settings.
 *
 **************************************************************************************************/
function setValues() {
	serverNameInp.setValue(client.sConf.serverName);
	shortServerNameInp.setValue(client.sConf.shortName);
	adminNameInp.setValue(client.sConf.adminName);
	adminEmailInp.setValue(client.sConf.adminEmail);
	serverPasswordInp.setValue(client.sConf.decode(client.sConf.CS_GlobalServerSettings, client.sConf.globalServerPassword));
	adminPasswordInp.setValue(client.sConf.decode(client.sConf.CS_GlobalServerSettings, client.sConf.globalAdminPassword));
	MOTDInp[0].setValue(client.sConf.MOTDLine[0]);
	MOTDInp[1].setValue(client.sConf.MOTDLine[1]);
	MOTDInp[2].setValue(client.sConf.MOTDLine[2]);
	MOTDInp[3].setValue(client.sConf.MOTDLine[3]);
	
	playerSlotsInp.setValue(string(client.sConf.playerSlots));
	vipSlotsInp.setValue(string(client.sConf.vipSlots));
	adminSlotsInp.setValue(string(client.sConf.adminSlots));
	specSlotsInp.setValue(string(client.sConf.spectatorSlots));
	
	doUplinkInp.bChecked = client.sConf.enableUplink;
	variablePlayerSlotsInp.bChecked = client.sConf.variablePlayerSlots;
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
	if (configType == client.sConf.CT_GlobalServerSettings) {
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
 *  $DESCRIPTION  Saves the server settings.
 *
 **************************************************************************************************/
function saveSettings() {
	local string serverName;
	local string shortServerName;
	local string MOTDLine[4];
	local string adminName;
	local string adminEmail;
	local string serverPassword;
	local string adminPassword;
	local int playerSlots;
	local int vipSlots;
	local int adminSlots;
	local int specSlots;
	local bool bEnableUplink;
	
	// Make sure the RPC interface is available.
	if (!setRPCI()) return;
	
	// Collect data from the GUI.
	serverName = serverNameInp.getValue();
	shortServerName = shortServerNameInp.getValue();
	MOTDLine[0] = MOTDInp[0].getValue();
	MOTDLine[1] = MOTDInp[1].getValue();
	MOTDLine[2] = MOTDInp[2].getValue();
	MOTDLine[3] = MOTDInp[3].getValue();
	adminName = adminNameInp.getValue();
	adminEmail = adminEmailInp.getValue();
	serverPassword = serverPasswordInp.getValue();
	adminPassword = adminPasswordInp.getValue();
	playerSlots = int(playerSlotsInp.getValue());
	vipSlots = int(vipSlotsInp.getValue());
	adminSlots = int(adminSlotsInp.getValue());
	specSlots = int(specSlotsInp.getValue());
	bEnableUplink = doUplinkInp.bChecked;
	
	// Save settings.
	rpci.setServerSettings(serverName, shortServerName, MOTDLine[0], MOTDLine[1], MOTDLine[2],
	                       MOTDLine[3], adminName, adminEmail, serverPassword, adminPassword,
	                       playerSlots, vipSlots, adminSlots, specSlots, bEnableUplink,
	                       variablePlayerSlotsInp.bChecked);

}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="serversettings"
}