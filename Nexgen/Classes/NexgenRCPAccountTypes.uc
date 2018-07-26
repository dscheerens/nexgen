/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPAccountTypes
 *  $VERSION      1.01 (20-10-2007 10:50)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen account type manager control panel page.
 *
 **************************************************************************************************/
class NexgenRCPAccountTypes extends NexgenPanel;

var int numAccountTypes;
var NexgenClientCore rpci;                        // Remote Procedure Call interface. 

var NexgenSimpleListBox accountTypeList;
var UWindowSmallButton addAccountTypeButton;
var UWindowSmallButton deleteAccountTypeButton;
var UWindowSmallButton moveUpButton;
var UWindowSmallButton moveDownButton;
var UWindowEditControl accountNameInp;
var UWindowEditControl accountTitleInp;
var UWindowEditControl accountPasswordInp;
var UWindowCheckbox rightEnableInp[18];
var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local NexgenContentPanel p;
	local int index;
	local string rightDef;
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionV(192, defaultComponentDist);
	splitRegionH(96, defaultComponentDist, , true);
	
	// Account info panel.
	p = addContentPanel();
	p.splitRegionH(64);
	p.splitRegionV(96);
	p.splitRegionH(16, , , true);
	p.divideRegionH(3);
	p.divideRegionH(3);
	p.divideRegionV(2, defaultComponentDist);
	p.splitRegionV(182);
	p.addLabel(client.lng.accountNameTxt, true);
	p.addLabel(client.lng.accountTitleTxt, true);
	p.addLabel(client.lng.passwordTxt, true);
	accountNameInp = p.addEditBox();
	accountTitleInp = p.addEditBox();
	accountPasswordInp = p.addEditBox();
	p.divideRegionH(arraycount(rightEnableInp) / 2);
	p.divideRegionH(arraycount(rightEnableInp) / 2);
	p.divideRegionV(2, defaultComponentDist);
	p.skipRegion();
	for (index = 0; index < arraycount(rightEnableInp); index++) {
		rightDef = client.sConf.rightsDef[index];
		if (rightDef == "") {
			rightEnableInp[index] = p.addCheckBox(TA_Left, client.lng.format(client.lng.rightNotDefinedTxt, string(index + 1)));
			rightEnableInp[index].bDisabled = true;
		} else {
			rightEnableInp[index] = p.addCheckBox(TA_Left, mid(rightDef, instr(rightDef, client.sConf.separator) + 1));
		}
	}
	saveButton = p.addButton(client.lng.saveTxt);
	resetButton = p.addButton(client.lng.resetTxt);

	// Account type list.
	accountTypeList = NexgenSimpleListBox(addListBox(class'NexgenSimpleListBox'));
	
	// Account type controls.
	p = addContentPanel();
	p.divideRegionH(4);
	addAccountTypeButton = p.addButton(client.lng.addAccountTypeTxt);
	deleteAccountTypeButton = p.addButton(client.lng.delAccountTypeTxt);
	moveUpButton = p.addButton(client.lng.moveUpTxt);
	moveDownButton = p.addButton(client.lng.moveDownTxt);
	
	// Configure components.
	accountNameInp.setMaxLength(24);
	accountTitleInp.setMaxLength(24);
	accountPasswordInp.setMaxLength(32);
	accountTypeList.register(self);
	addAccountTypeButton.register(self);
	deleteAccountTypeButton.register(self);
	moveUpButton.register(self);
	moveDownButton.register(self);
	resetButton.register(self);
	saveButton.register(self);
	loadAccountTypes();
	accountTypeSelected();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the account types.
 *
 **************************************************************************************************/
function loadAccountTypes() {
	local int index;
	local NexgenSimpleListItem item;
	
	accountTypeList.items.clear();
	accountTypeList.selectedItem = none;
	
	while(index < arrayCount(client.sConf.atTypeName) && client.sConf.atTypeName[index] != "") {
		item = NexgenSimpleListItem(accountTypeList.items.append(class'NexgenSimpleListItem'));
		item.displayText = client.sConf.atTypeName[index];
		item.itemID = index;
		
		index++;
	}
	
	numAccountTypes = index;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the settings for the specified account type.
 *  $PARAM        accountTypeNum  The ID number of the account type to load.
 *  $REQUIRE      0 <= accountTypeNum && accountTypeNum <= arrayCount(client.sConf.atTypeName)
 *
 **************************************************************************************************/
function loadAccountTypeInfo(int accountTypeNum) {
	local int index;
	local string accountRights;
	local string rightDef;
	local string rightID;
	
	// Cancel on error. In theory this should not happen.
	if (client.sConf.atTypeName[accountTypeNum] == "") {
		return;
	}
	
	// Load general info.
	accountNameInp.setValue(client.sConf.atTypeName[accountTypeNum]);
	accountTitleInp.setValue(client.sConf.atTitle[accountTypeNum]);
	accountPasswordInp.setValue(client.sConf.decode(client.sConf.CS_AccountTypes, client.sConf.atPassword[accountTypeNum]));
	
	// Load right assignment.
	accountRights = client.sConf.atRights[accountTypeNum];
	for (index = 0; index < arraycount(rightEnableInp); index++) {
		rightDef = client.sConf.rightsDef[index];
		if (rightDef == "") {
			// Right isn't defined.
			rightEnableInp[index].bChecked = false;
		} else {
			rightID = left(rightDef, instr(rightDef, separator));
			rightEnableInp[index].bChecked = hasRight(accountRights, rightID);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when an account type was selected from the list.
 *
 **************************************************************************************************/
function accountTypeSelected() {
	local NexgenSimpleListItem selected;
	
	// Check which buttons should be enabled / disabled.
	if (accountTypeList.selectedItem == none) {
		// No item selected.
		deleteAccountTypeButton.bDisabled = true;
		moveUpButton.bDisabled = true;
		moveDownButton.bDisabled = true;
		resetButton.bDisabled = true;
		saveButton.bDisabled = true;
	} else {
		// Other account type selected.
		selected = NexgenSimpleListItem(accountTypeList.selectedItem);
		deleteAccountTypeButton.bDisabled = selected.itemID < 1;
		moveUpButton.bDisabled = selected.itemID < 2;
		moveDownButton.bDisabled = selected.itemID < 1 || selected.itemID + 1 == numAccountTypes;
		resetButton.bDisabled = false;
		saveButton.bDisabled = false;
	}
	
	// Load account info.
	if (accountTypeList.selectedItem != none) {
		loadAccountTypeInfo(NexgenSimpleListItem(accountTypeList.selectedItem).itemID);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified right is included in the given right string.
 *  $PARAM        rights   The rights specifier string.
 *  $PARAM        rightID  String identifier of the client right.
 *  $REQUIRE      rightID != ""
 *  $RETURN       True if the right is included, false if not.
 *
 **************************************************************************************************/
function bool hasRight(string rights, string rightID) {
	return instr(rights $ separator, rightID $ separator) >= 0;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns a string containing the currently selected rights.
 *  $RETURN       A string containing the rights currently selected.
 *
 **************************************************************************************************/
function string getCurrentRights() {
	local string rights;
	local string rightDef;
	local int index;
	
	// Check for each right if it is selected.
	for (index = 0; index < arraycount(rightEnableInp); index++) {
		rightDef = client.sConf.rightsDef[index];
		if (rightEnableInp[index].bChecked && rightDef != "") {
			if (rights == "") {
				rights = left(rightDef, instr(rightDef, separator));
			} else {
				rights = rights $ separator $ left(rightDef, instr(rightDef, separator));
			}
		}
	}
	
	// Return result.
	return rights;
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
	
	setRPCI();
	
	// Account type selected.
	if (control == accountTypeList && eventType == DE_Click) {
		accountTypeSelected();
	}

	// Reset account type info.
	if (control == resetButton && !resetButton.bDisabled && eventType == DE_Click) {
		loadAccountTypeInfo(NexgenSimpleListItem(accountTypeList.selectedItem).itemID);
	}
	
	// Save account type info.
	if (control == saveButton && !saveButton.bDisabled && eventType == DE_Click && rpci != none) {
		rpci.updateAccountType(NexgenSimpleListItem(accountTypeList.selectedItem).itemID,
		                       accountNameInp.getValue(), getCurrentRights(),
		                       accountTitleInp.getValue(), accountPasswordInp.getValue());
	}

	// Add account type.
	if (control == addAccountTypeButton && !addAccountTypeButton.bDisabled && eventType == DE_Click && rpci != none) {
		rpci.addAccountType(accountNameInp.getValue(), getCurrentRights(),
		                    accountTitleInp.getValue(), accountPasswordInp.getValue());
	}
	
	// Delete account type.
	if (control == deleteAccountTypeButton && !deleteAccountTypeButton.bDisabled && eventType == DE_Click && rpci != none) {
		rpci.deleteAccountType(NexgenSimpleListItem(accountTypeList.selectedItem).itemID);
	}
	
	// Move account type up.
	if (control == moveUpButton && !moveUpButton.bDisabled && eventType == DE_Click && rpci != none) {
		rpci.moveAccountType(NexgenSimpleListItem(accountTypeList.selectedItem).itemID, false);
	}
	
	// Move account type down.
	if (control == moveDownButton && !moveDownButton.bDisabled && eventType == DE_Click && rpci != none) {
		rpci.moveAccountType(NexgenSimpleListItem(accountTypeList.selectedItem).itemID, true);
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
 *  $DESCRIPTION  Notifies this panel that the server configuration has been updated.
 *  $PARAM        configType  Type of settings that have been changed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function configChanged(byte configType) {
	// Relevant settings for this panel?
	if (configType == client.sConf.CT_AccountTypes) {
		loadAccountTypes();
		accountTypeSelected();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="accounttypes"
}
