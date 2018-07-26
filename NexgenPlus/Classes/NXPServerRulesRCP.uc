/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPServerRulesRCP
 *  $VERSION      1.01 (19-12-2010 22:49:57)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Server rules settings control panel page.
 *
 **************************************************************************************************/
class NXPServerRulesRCP extends NexgenPanel;

var NXPClient xClient;
var NexgenSharedDataContainer xConf;

var UWindowEditControl serverRulesInp[10];
var UWindowCheckbox showServerRulesTabInp;
var UWindowCheckbox showServerRulesInHUDInp;
var UWindowComboControl serverRulesHUDAnchorPointLocHInp;
var UWindowComboControl serverRulesHUDAnchorPointLocVInp;
var UWindowEditControl serverRulesHUDPosXInp;
var UWindowEditControl serverRulesHUDPosYInp;
var UWindowComboControl serverRulesHUDPosXUnitsInp;
var UWindowComboControl serverRulesHUDPosYUnitsInp;

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;

const rulesPerRow = 2;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local int region;
	local int row;
	local int column;
	local int index;
	local NexgenContentPanel p;
	local int numRows;
	
	xClient = NXPClient(client.getController(class'NXPClient'.default.ctrlID));
	
	// Compute number of rows needed.
	numRows = arrayCount(serverRulesInp) / rulesPerRow;
	if (arrayCount(serverRulesInp) % rulesPerRow > 0) {
		numRows++;
	}
	
	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(xClient.lng.serverRulesSettingsPanelTitle, true, TA_Center);

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
	selectRegion(splitRegionH(120));
	
	splitRegionV(65, , true);
	divideRegionV(rulesPerRow, defaultComponentDist);
	divideRegionH(6);
	divideRegionH(6);
	for (column = 0; column < rulesPerRow; column++) {
		divideRegionH(numRows);
	}
	addLabel(xClient.lng.showServerRulesTabTxt, true, TA_Left);
	addLabel(xClient.lng.showServerRulesInHUDTxt, true, TA_Left);
	addLabel(xClient.lng.serverRulesHUDAnchorPointLocHTxt, true, TA_Left);
	addLabel(xClient.lng.serverRulesHUDAnchorPointLocVTxt, true, TA_Left);
	addLabel(xClient.lng.serverRulesHUDPosXTxt, true, TA_Left);
	addLabel(xClient.lng.serverRulesHUDPosYTxt, true, TA_Left);
	showServerRulesTabInp = addCheckBox(TA_Right);
	showServerRulesInHUDInp = addCheckBox(TA_Right);
	serverRulesHUDAnchorPointLocHInp = addListCombo();
	serverRulesHUDAnchorPointLocVInp = addListCombo();
	divideRegionV(2, defaultComponentDist);
	divideRegionV(2, defaultComponentDist);
	
	for (column = 0; column < rulesPerRow; column++) {
		for (row = 0; row < numRows; row++) {
			splitRegionV(15);
		}
	}
	
	serverRulesHUDPosXInp = addEditBox();
	serverRulesHUDPosXUnitsInp = addListCombo();
	serverRulesHUDPosYInp = addEditBox();
	serverRulesHUDPosYUnitsInp = addListCombo();
	
	for (index = 0; index < arrayCount(serverRulesInp); index++) {
		addLabel(string(index + 1), true, TA_CENTER);
		serverRulesInp[index] = addEditBox();
		serverRulesInp[index].setMaxLength(200);
	}
	
	// Configure components.
	resetButton.bDisabled = true;
	saveButton.bDisabled = true;
	serverRulesHUDAnchorPointLocHInp.addItem("Left", string(xClient.APH_Left));
	serverRulesHUDAnchorPointLocHInp.addItem("Middle", string(xClient.APH_Middle));
	serverRulesHUDAnchorPointLocHInp.addItem("Right", string(xClient.APH_Right));
	serverRulesHUDAnchorPointLocVInp.addItem("Top", string(xClient.APV_Top));
	serverRulesHUDAnchorPointLocVInp.addItem("Middle", string(xClient.APV_Middle));
	serverRulesHUDAnchorPointLocVInp.addItem("Bottom", string(xClient.APV_Bottom));
	serverRulesHUDPosXUnitsInp.addItem("Pixels", string(xClient.UNIT_Pixels));
	serverRulesHUDPosXUnitsInp.addItem("Percentage", string(xClient.UNIT_Percentage));
	serverRulesHUDPosYUnitsInp.addItem("Pixels", string(xClient.UNIT_Pixels));
	serverRulesHUDPosYUnitsInp.addItem("Percentage", string(xClient.UNIT_Percentage));
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
	showServerRulesTabInp            .bChecked        = xConf.getBool   ("showServerRulesTab");
	showServerRulesInHUDInp          .bChecked        = xConf.getBool   ("showServerRulesInHUD");
	serverRulesHUDAnchorPointLocHInp .setSelectedIndex (xConf.getInt    ("serverRulesHUDAnchorPointLocH") - 1);
	serverRulesHUDAnchorPointLocVInp .setSelectedIndex (xConf.getInt    ("serverRulesHUDAnchorPointLocV") - 1);
	serverRulesHUDPosXInp            .setValue         (xConf.getString ("serverRulesHUDPosX"));
	serverRulesHUDPosYInp            .setValue         (xConf.getString ("serverRulesHUDPosY"));
	serverRulesHUDPosXUnitsInp       .setSelectedIndex (xConf.getInt    ("serverRulesHUDPosXUnits") - 1);
	serverRulesHUDPosYUnitsInp       .setSelectedIndex (xConf.getInt    ("serverRulesHUDPosYUnits") - 1);
	for (index = 0; index < arrayCount(serverRulesInp); index++)
	serverRulesInp[index]            .setValue         (xConf.getString ("serverRules", index));
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
	 		case "showServerRulesTab":            showServerRulesTabInp            .bChecked        = container.getBool   (varName);         break;
	 		case "showServerRulesInHUD":          showServerRulesInHUDInp          .bChecked        = container.getBool   (varName);         break;
	 		case "serverRulesHUDAnchorPointLocH": serverRulesHUDAnchorPointLocHInp .setSelectedIndex (container.getInt    (varName) - 1);    break;
	 		case "serverRulesHUDAnchorPointLocV": serverRulesHUDAnchorPointLocVInp .setSelectedIndex (container.getInt    (varName) - 1);    break;
	 		case "serverRulesHUDPosX":            serverRulesHUDPosXInp            .setValue         (container.getString (varName));        break;
	 		case "serverRulesHUDPosY":            serverRulesHUDPosYInp            .setValue         (container.getString (varName));        break;
	 		case "serverRulesHUDPosXUnits":       serverRulesHUDPosXUnitsInp       .setSelectedIndex (container.getInt    (varName) - 1);    break;
	 		case "serverRulesHUDPosYUnits":       serverRulesHUDPosYUnitsInp       .setSelectedIndex (container.getInt    (varName) - 1);    break;
	 		case "serverRules":                   serverRulesInp[index]            .setValue         (container.getString (varName, index)); break;
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
	
	xClient.setVar("nxp_config", "showServerRulesTab",            showServerRulesTabInp            .bChecked);
	xClient.setVar("nxp_config", "showServerRulesInHUD",          showServerRulesInHUDInp          .bChecked);
	xClient.setVar("nxp_config", "serverRulesHUDAnchorPointLocH", serverRulesHUDAnchorPointLocHInp .getSelectedIndex() + 1);
	xClient.setVar("nxp_config", "serverRulesHUDAnchorPointLocV", serverRulesHUDAnchorPointLocVInp .getSelectedIndex() + 1);
	xClient.setVar("nxp_config", "serverRulesHUDPosX",            serverRulesHUDPosXInp            .getValue());
	xClient.setVar("nxp_config", "serverRulesHUDPosY",            serverRulesHUDPosYInp            .getValue());
	xClient.setVar("nxp_config", "serverRulesHUDPosXUnits",       serverRulesHUDPosXUnitsInp       .getSelectedIndex() + 1);
	xClient.setVar("nxp_config", "serverRulesHUDPosYUnits",       serverRulesHUDPosYUnitsInp       .getSelectedIndex() + 1);
	for (index = 0; index < arrayCount(serverRulesInp); index++)
	xClient.setVar("nxp_config", "serverRules",                   serverRulesInp[index]            .getValue(), index);
	
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
	panelIdentifier="nxp_server_rules_settings"
	panelHeight=270
}
