/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPBootControl
 *  $VERSION      1.05 (15-12-2007 15:38)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen boot control panel page.
 *
 **************************************************************************************************/
class NexgenRCPBootControl extends NexgenPanel;

var NexgenClientCore rpci;                        // Remote Procedure Call interface.

var UWindowComboControl gameTypeList;
var NexgenSimpleListBox inclMutatorList;
var NexgenSimpleListBox exclMutatorList;
var UWindowSmallButton rebootButton;
var UWindowSmallButton saveButton;
var UWindowSmallButton resetButton;
var NexgenEditControl mapPrefixInp;
var NexgenEditControl extraOptionsInp;
var NexgenEditControl commandsInp;
var UWindowCheckbox enableBootControlInp;
var UWindowCheckbox restartOnLastGameInp;
var UWindowDynamicTextArea previewBox;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local NexgenContentPanel p;
	local int region;
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionH(20, defaultComponentDist);
	divideRegionV(2);
	splitRegionH(20, defaultComponentDist, , true);
	splitRegionV(20, defaultComponentDist);
	splitRegionV(20, defaultComponentDist);
	p = addContentPanel();
	splitRegionV(196, , , true);
	enableBootControlInp = addCheckBox(TA_Right);
	addLabel(client.lng.enableBootCtrlTxt, true);
	restartOnLastGameInp = addCheckBox(TA_Right);
	addLabel(client.lng.restartOnLastGameTxt, true);
	rebootButton = addButton(client.lng.rebootTxt, 96, AL_Left);
	divideRegionV(2, defaultComponentDist);
	saveButton = addButton(client.lng.saveTxt);
	resetButton = addButton(client.lng.resetTxt);
	
	// Mutator list.
	p.splitRegionV(65, 2 * defaultComponentDist, true);
	region = p.currRegion;
	p.skipRegion();
	p.divideRegionH(2);
	p.splitRegionH(16);
	p.splitRegionH(16);
	p.addLabel(client.lng.inclMutatorsTxt, true);
	inclMutatorList = NexgenSimpleListBox(p.addListBox(class'NexgenSimpleListBox'));
	p.addLabel(client.lng.exclMutatorsTxt, true);
	exclMutatorList = NexgenSimpleListBox(p.addListBox(class'NexgenSimpleListBox'));
	
	// Server boot command line preview.
	p.selectRegion(region);
	p.selectRegion(p.splitRegionH(128, defaultComponentDist));
	region = p.currRegion;
	p.skipRegion();
	p.splitRegionH(16);
	p.addLabel(client.lng.bootCmdLineTxt, True);
	previewBox = p.addDynamicTextArea();
	
	// Server boot options.
	p.selectRegion(region);
	p.selectRegion(p.divideRegionH(4, defaultComponentDist));
	p.splitRegionV(64);
	p.splitRegionV(64);
	p.splitRegionH(16);
	p.splitRegionH(16);
	p.addLabel(client.lng.gameTypeTxt, true);
	gameTypeList = p.addListCombo();
	p.addLabel(client.lng.mapPrefixTxt, true);	
	mapPrefixInp = p.addEditBox();
	p.addLabel(client.lng.extraCmdLineOptTxt, true);
	extraOptionsInp = p.addEditBox();
	p.addLabel(client.lng.preSwitchCommandsTxt, true);
	commandsInp = p.addEditBox();
	
	// Configure components.
	mapPrefixInp.setMaxLength(8);
	extraOptionsInp.setMaxLength(255);
	commandsInp.setMaxLength(255);
	resetButton.register(self);
	inclMutatorList.register(self);
	exclMutatorList.register(self);
	gameTypeList.register(self);
	mapPrefixInp.register(self);
	extraOptionsInp.register(self);
	rebootButton.register(self);
	loadGameTypeList();
	loadMutatorList();
	loadBootControlSettings();
	previewBox.bTopCentric = true;
	inclMutatorList.bCanDrag = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the game type list.
 *
 **************************************************************************************************/
function loadGameTypeList() {
	local int index;
	local string gameClass;
	local string mapPrefix;
	local string gameName;
	
	while (index < arrayCount(client.sConf.gameTypeInfo) && client.sConf.gameTypeInfo[index] != "") {
		class'NexgenUtil'.static.split(client.sConf.gameTypeInfo[index], gameClass, mapPrefix);
		class'NexgenUtil'.static.split(mapPrefix, mapPrefix, gameName);
		
		gameTypeList.addItem(gameName, string(index));
		
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the mutator list.
 *
 **************************************************************************************************/
function loadMutatorList() {
	local int index;
	local NexgenSimpleListItem item;
	local string mutatorClass;
	local string mutatorName;
	
	while (index < arrayCount(client.sConf.mutatorInfo) && client.sConf.mutatorInfo[index] != "") {
		class'NexgenUtil'.static.split(client.sConf.mutatorInfo[index], mutatorClass, mutatorName);
		
		item = NexgenSimpleListItem(exclMutatorList.items.append(class'NexgenSimpleListItem'));
		item.displayText = mutatorName;
		item.itemID = index;
		
		index++;
	}
	
	exclMutatorList.items.sort();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the boot control settings.
 *
 **************************************************************************************************/
function loadBootControlSettings() {
	local NexgenSimpleListItem oldItem;
	local NexgenSimpleListItem newItem;
	local string remaining;
	local string mutatorIndex;
	local int index;
	
	// Select game type.
	index = client.sConf.getGameIndex(client.sConf.bootGameType);
	gameTypeList.setSelectedIndex(index);
	
	// Move all mutators to excluded list.
	for (oldItem = NexgenSimpleListItem(inclMutatorList.items); oldItem != none; oldItem = NexgenSimpleListItem(oldItem.next)) {
		if (oldItem.itemID >= 0) {
			newItem = NexgenSimpleListItem(exclMutatorList.items.append(class'NexgenSimpleListItem'));
			newItem.displayText = oldItem.displayText;
			newItem.itemID = oldItem.itemID ;
		}
	}
	inclMutatorList.items.clear();
	inclMutatorList.selectedItem = none;
	
	// Load included mutator list.
	if (exclMutatorList.selectedItem != none) {
		exclMutatorList.selectedItem.bSelected = false;
		exclMutatorList.selectedItem = none;
	}
	remaining = client.sConf.bootMutatorIndices;
	while (remaining != "") {
		class'NexgenUtil'.static.split(remaining, mutatorIndex, remaining);
		index = int(mutatorIndex);
		oldItem = exclMutatorList.getItemByID(index);
		newItem = NexgenSimpleListItem(inclMutatorList.items.append(class'NexgenSimpleListItem'));
		newItem.displayText = oldItem.displayText;
		newItem.itemID = oldItem.itemID;
		oldItem.remove();
	}
	exclMutatorList.items.sort();
	
	// Load other settings.
	mapPrefixInp.setValue(client.sConf.bootMapPrefix);
	extraOptionsInp.setValue(client.sConf.bootOptions);
	commandsInp.setValue(client.sConf.bootCommands);
	enableBootControlInp.bChecked = client.sConf.enableBootControl;
	restartOnLastGameInp.bChecked = client.sConf.restartOnLastGame;
	
	// Update preview.
	updatePreview();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the server boot command line preview.
 *
 **************************************************************************************************/
function updatePreview() {
	local string bootCmd;
	local string gameType;
	local string mutators;
	local string mutator;
	local string remaining;
	local int index;
	local NexgenSimpleListItem item;
	
	// Get game type.
	index = gameTypeList.getSelectedIndex();
	if (index >= 0) {
		class'NexgenUtil'.static.split(client.sConf.gameTypeInfo[index], gameType, remaining);
	}
	
	// Get mutators.
	for (item = NexgenSimpleListItem(inclMutatorList.items); item != none; item = NexgenSimpleListItem(item.next)) {
		if (item.itemID >= 0) {
			class'NexgenUtil'.static.split(client.sConf.mutatorInfo[item.itemID], mutator, remaining);
			if (mutators == "") {
				mutators = mutator;
			} else {
				mutators = mutators $ separator $ " " $ mutator;
			}
		}
	}
	
	// Create boot command string.
	bootCmd = class'NexgenUtil'.static.trim(mapPrefixInp.getValue()) $ "-*.unr";
	if (gameType != "") bootCmd = bootCmd $ " ?game=" $ gameType;
	if (mutators != "") bootCmd = bootCmd $ " ?mutator=" $ mutators;
	bootCmd = bootCmd  $ " " $ class'NexgenUtil'.static.trim(extraOptionsInp.getValue());
	
	// Set preview box contents.
	previewBox.clear();
	previewBox.addText(bootCmd);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically selects the map prefix for the selected game type.
 *
 **************************************************************************************************/
function updateMapPrefix() {
	local int index;
	local string gameClass;
	local string mapPrefix;
	local string remaining;
	
	// Get map prefix.
	index = gameTypeList.getSelectedIndex();
	if (index >= 0) {
		class'NexgenUtil'.static.split(client.sConf.gameTypeInfo[index], gameClass, remaining);
		class'NexgenUtil'.static.split(remaining, mapPrefix, remaining);
	} else {
		mapPrefix = "";
	}
	
	// Set map prefix.
	mapPrefixInp.setValue(mapPrefix);
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
 *  $DESCRIPTION  Sends the new boot control settings to the server.
 *  $REQUIRE      rpci != none
 *
 **************************************************************************************************/
function updateBootControl() {
	local string mutators;
	local NexgenSimpleListItem item;
	
	// Get mutators.
	for (item = NexgenSimpleListItem(inclMutatorList.items); item != none; item = NexgenSimpleListItem(item.next)) {
		if (item.itemID >= 0) {
			if (mutators == "") {
				mutators = string(item.itemID);
			} else {
				mutators = mutators $ separator $ " " $ item.itemID;
			}
		}
	}
	
	// Send new settings to the server.
	rpci.updateBootControl(enableBootControlInp.bChecked, restartOnLastGameInp.bChecked,
	                       gameTypeList.getSelectedIndex(), mutators,
	                       class'NexgenUtil'.static.trim(mapPrefixInp.getValue()),
	                       class'NexgenUtil'.static.trim(extraOptionsInp.getValue()),
	                       class'NexgenUtil'.static.trim(commandsInp.getValue()));
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
	local NexgenSimpleListItem newItem;
	
	super.notify(control, eventType);
	
	setRPCI();
	
	// Reset button pressed?
	if (control == resetButton && eventType == DE_Click) {
		loadBootControlSettings();
	}
	
	// Save button pressed?
	if (control == saveButton && eventType == DE_Click && rpci != none) {
		updateBootControl();
	}

	// Reboot button pressed?
	if (control == rebootButton && eventType == DE_Click && rpci != none) {
		rpci.rebootServer();
	}	
	
	// Mutator selected?
	if (control == inclMutatorList && eventType == DE_Click) {
		if (exclMutatorList.selectedItem != none) {
			exclMutatorList.selectedItem.bSelected = false;
			exclMutatorList.selectedItem = none;
		}
	} else if (control == exclMutatorList && eventType == DE_Click) {
		if (inclMutatorList.selectedItem != none) {
			inclMutatorList.selectedItem.bSelected = false;
			inclMutatorList.selectedItem = none;
		}
	}
	
	// Mutator double clicked?
	if (control == inclMutatorList && eventType == DE_DoubleClick && inclMutatorList.selectedItem != none) {
		newItem = NexgenSimpleListItem(exclMutatorList.items.append(class'NexgenSimpleListItem'));
		newItem.displayText = NexgenSimpleListItem(inclMutatorList.selectedItem).displayText;
		newItem.itemID = NexgenSimpleListItem(inclMutatorList.selectedItem).itemID;
		if (exclMutatorList.selectedItem != none) {
			exclMutatorList.selectedItem.bSelected = false;
		}
		exclMutatorList.selectedItem = newItem;
		newItem.bSelected = true;
		inclMutatorList.selectedItem.remove();
		inclMutatorList.selectedItem = none;
		exclMutatorList.sort();
		updatePreview();
	} else if (control == exclMutatorList && eventType == DE_DoubleClick && exclMutatorList.selectedItem != none) {
		newItem = NexgenSimpleListItem(inclMutatorList.items.append(class'NexgenSimpleListItem'));
		newItem.displayText = NexgenSimpleListItem(exclMutatorList.selectedItem).displayText;
		newItem.itemID = NexgenSimpleListItem(exclMutatorList.selectedItem).itemID;
		if (inclMutatorList.selectedItem != none) {
			inclMutatorList.selectedItem.bSelected = false;
		}
		inclMutatorList.selectedItem = newItem;
		newItem.bSelected = true;
		exclMutatorList.selectedItem.remove();
		exclMutatorList.selectedItem = none;
		updatePreview();
	}
	
	// Game type selected?
	if (control == gameTypeList && eventType == DE_Change) {
		updateMapPrefix();
		//updatePreview();
	}

	// Map prefix changed?
	if (control == mapPrefixInp && eventType == DE_Change) {
		updatePreview();
	}

	// Extra options changed?
	if (control == extraOptionsInp && eventType == DE_Change) {
		updatePreview();
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
	if (configType == client.sConf.CT_BootControl) {
		loadBootControlSettings();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="bootcontrol"
}
