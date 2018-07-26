/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPIgnoredWeaponsSettings
 *  $VERSION      1.03 (20-6-2008 14:24)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen about control panel page.
 *
 **************************************************************************************************/
class NexgenRCPIgnoredWeaponsSettings extends NexgenPanel;

var NexgenClientCore rpci;                        // Remote Procedure Call interface.

var NexgenSimpleListBox ignoredWeaponList;
var UWindowSmallButton weapSaveButton;
var UWindowSmallButton weapRemButton;
var UWindowCheckbox ignorePrimaryFireInp;
var UWindowCheckbox ignoreAltFireInp;
var NexgenEditControl weaponClassInp;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	
	// Create layout & add components.
	createPanelRootRegion();
	
	// Ignored weapons.
	splitRegionV(256, defaultComponentDist);
	ignoredWeaponList = NexgenSimpleListBox(addListBox(class'NexgenSimpleListBox'));
	divideRegionH(4);
	addLabel(client.lng.ignoredWeaponsTxt, true, TA_Center);
	splitRegionV(96);
	divideRegionV(2, 2 * defaultComponentDist);
	splitRegionV(192);
	addLabel(client.lng.weaponClassTxt);
	weaponClassInp = addEditBox();
	ignorePrimaryFireInp = addCheckBox(TA_Left, client.lng.ignorePrimaryFireTxt);
	ignoreAltFireInp = addCheckBox(TA_Left, client.lng.ignoreAltFireTxt);
	divideRegionV(2, defaultComponentDist);
	skipRegion();
	weapSaveButton = addButton(client.lng.saveTxt);
	weapRemButton = addButton(client.lng.removeTxt);
	
	// Configure components.
	weaponClassInp.setMaxLength(64);
	loadIgnoredWeaponList();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the list of weapons ignored by the spawn protector.
 *
 **************************************************************************************************/
function loadIgnoredWeaponList() {
	local int index;
	local NexgenSimpleListItem item;
	local string weaponClass;
	local string remaining;

	// Clear list.
	ignoredWeaponList.selectedItem = none;
	ignoredWeaponList.items.clear();
	
	// Add weapon classes.
	while (index < arrayCount(client.sConf.spawnProtectExcludeWeapons) &&
	       client.sConf.spawnProtectExcludeWeapons[index] != "") {
	       
		class'NexgenUtil'.static.split(client.sConf.spawnProtectExcludeWeapons[index], weaponClass, remaining);
		
		item = NexgenSimpleListItem(ignoredWeaponList.items.append(class'NexgenSimpleListItem'));
		item.displayText = weaponClass;
		item.itemID = index;
		
		index++;
	}
	
	// Add 'add new item' option if list isn't full.
	if (index < arrayCount(client.sConf.spawnProtectExcludeWeapons)) {
		item = NexgenSimpleListItem(ignoredWeaponList.items.insert(class'NexgenSimpleListItem'));
		item.displayText = client.lng.addNewItemTxt;
		item.itemID = -1;
	}
	
	// Signal item select event.
	weaponSelected();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when an item from the ignored weapon list was selected.
 *
 **************************************************************************************************/
function weaponSelected() {
	local NexgenSimpleListItem item;
	local string weaponClass;
	local string excludedModes;
	
	// Get selected item.
	item = NexgenSimpleListItem(ignoredWeaponList.selectedItem);
	
	// Update GUI.
	weapSaveButton.bDisabled = (item == none);
	weapRemButton.bDisabled = (item == none) || (item.itemID < 0);
	ignorePrimaryFireInp.bDisabled = (item == none);
	ignoreAltFireInp.bDisabled = (item == none);
	weaponClassInp.setDisabled((item == none));
	if (item == none) {
		ignorePrimaryFireInp.bChecked = false;
		ignoreAltFireInp.bChecked = false;
		weaponClassInp.setValue("");
	} else if (item.itemID < 0) {
		ignorePrimaryFireInp.bChecked = false;
		ignoreAltFireInp.bChecked = false;
		weaponClassInp.setValue("");
	} else {
		class'NexgenUtil'.static.split(client.sConf.spawnProtectExcludeWeapons[item.itemID],
		                               weaponClass, excludedModes);
		ignorePrimaryFireInp.bChecked = (instr(excludedModes, client.sConf.IW_Fire) >= 0);
		ignoreAltFireInp.bChecked = (instr(excludedModes, client.sConf.IW_AltFire) >= 0);
		weaponClassInp.setValue(weaponClass);
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
	
	// Weapon selected?
	if (control == ignoredWeaponList && eventType == DE_Click) {
		weaponSelected();
	}
	
	// Remove weapon selected?
	if (control == weapRemButton && eventType == DE_Click && !weapRemButton.bDisabled && setRPCI()) {
		rpci.delIgnoredWeapon(NexgenSimpleListItem(ignoredWeaponList.selectedItem).itemID);
	}

	// Save weapon selected?
	if (control == weapSaveButton && eventType == DE_Click && !weapSaveButton.bDisabled && setRPCI()) {
		rpci.saveIgnoredWeapon(NexgenSimpleListItem(ignoredWeaponList.selectedItem).itemID,
		                       class'NexgenUtil'.static.trim(weaponClassInp.getValue()),
		                       ignorePrimaryFireInp.bChecked, ignoreAltFireInp.bChecked);
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
	if (configType == client.sConf.CT_ExclWeaponList) {
		loadIgnoredWeaponList();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="ignoredweaponsettings"
	panelHeight=90
}
