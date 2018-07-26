/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXRCPMapSwitch
 *  $VERSION      1.04 (6-12-2008 18:24)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen map switch control panel page.
 *
 **************************************************************************************************/
class NexgenXRCPMapSwitch extends NexgenPanel;

var NexgenXClient xClient;

var UWindowSmallButton switchButton;
var NexgenSimpleListBox mapList;
var NexgenSimpleListBox inclMutatorList;
var NexgenSimpleListBox exclMutatorList;
var UWindowComboControl gameTypeList;
var UWindowCheckbox hideBadMapsInp;

var bool bMapListAvailable;

const SSTR_HideBadMaps = "HideBadMaps";



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local NexgenContentPanel p;
	
	xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionV(192, defaultComponentDist);
	splitRegionH(20, defaultComponentDist, , true);
	splitRegionH(20, defaultComponentDist, , true);
	mapList = NexgenSimpleListBox(addListBox(class'NexgenSimpleListBox'));
	hideBadMapsInp = addCheckBox(TA_Left, xClient.lng.hideBadMapsTxt, true);
	p = addContentPanel();
	switchButton = addButton(xClient.lng.mapSwitchActionTxt, 96, AL_Right);
	p.splitRegionH(20, defaultComponentDist);
	p.splitRegionV(96);
	p.divideRegionV(2, defaultComponentDist);
	p.addLabel(client.lng.gameTypeTxt, true);
	gameTypeList = p.addListCombo();
	p.splitRegionH(16);
	p.splitRegionH(16);
	p.addLabel(client.lng.exclMutatorsTxt, true);
	exclMutatorList = NexgenSimpleListBox(p.addListBox(class'NexgenSimpleListBox'));
	p.addLabel(client.lng.inclMutatorsTxt, true);
	inclMutatorList = NexgenSimpleListBox(p.addListBox(class'NexgenSimpleListBox'));
	
	// Configure components.
	hideBadMapsInp.register(self);
	gameTypeList.register(self);
	loadGameTypeList();
	loadMutatorList();
	loadMapList();
	hideBadMapsInp.bChecked = client.gc.get(SSTR_HideBadMaps, "true") ~= "true";
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
	
	// Load available game types.
	while (index < arrayCount(client.sConf.gameTypeInfo) && client.sConf.gameTypeInfo[index] != "") {
		class'NexgenUtil'.static.split(client.sConf.gameTypeInfo[index], gameClass, mapPrefix);
		class'NexgenUtil'.static.split(mapPrefix, mapPrefix, gameName);
		
		gameTypeList.addItem(gameName, string(index));
		
		index++;
	}
	
	// Select current game type.
	gameTypeList.setSelectedIndex(client.sConf.activeGameType);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the mutator list.
 *
 **************************************************************************************************/
function loadMutatorList() {
	local int index;
	local NexgenSimpleListItem oldItem;
	local NexgenSimpleListItem newItem;
	local string mutatorClass;
	local string mutatorName;
	local string remaining;
	local string mutatorIndex;
	
	// Load available mutators.
	while (index < arrayCount(client.sConf.mutatorInfo) && client.sConf.mutatorInfo[index] != "") {
		class'NexgenUtil'.static.split(client.sConf.mutatorInfo[index], mutatorClass, mutatorName);
		
		newItem = NexgenSimpleListItem(exclMutatorList.items.append(class'NexgenSimpleListItem'));
		newItem.displayText = mutatorName;
		newItem.itemID = index;
		
		index++;
	}
	
	exclMutatorList.items.sort();
	
	// Load used mutators.
	remaining = client.sConf.activeMutatorIndices;
	while (remaining != "") {
		class'NexgenUtil'.static.split(remaining, mutatorIndex, remaining);
		index = int(mutatorIndex);
		oldItem = exclMutatorList.getItemByID(index);
		newItem = NexgenSimpleListItem(inclMutatorList.items.append(class'NexgenSimpleListItem'));
		newItem.displayText = oldItem.displayText;
		newItem.itemID = oldItem.itemID;
		oldItem.remove();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the map list.
 *
 **************************************************************************************************/
function loadMapList() {
	local int index;
	local bool bHideBadMaps;
	local string gameClass;
	local string mapPrefix;
	local string remaining;
	
	// Clear the map list.
	mapList.items.clear();
	mapList.selectedItem = none;
	mapSelected();
	
	// Check if the map list is available.
	if (!bMapListAvailable) {
		addMap(xClient.lng.recievingMapListTxt);
		return;
	}
	
	// Get map prefix.
	index = gameTypeList.getSelectedIndex();
	if (index >= 0) {
		class'NexgenUtil'.static.split(client.sConf.gameTypeInfo[index], gameClass, remaining);
		class'NexgenUtil'.static.split(remaining, mapPrefix, remaining);
	} else {
		mapPrefix = "";
	}
	
	// Load the map list.
	bHideBadMaps = hideBadMapsInp.bChecked;
	index = 0;
	while (index < xClient.mapList.numMaps && (!bHideBadMaps || mapPrefix != "")) {
		// Add map?
		if (class'NexgenUtil'.static.isValidLevel(xClient.mapList.maps[index]) &&
		    (!bHideBadMaps || left(xClient.mapList.maps[index], len(mapPrefix)) ~= mapPrefix)) {
			addMap(xClient.mapList.maps[index]);
		}
		
		// Continue with next map.
		index++;
	}
	mapList.sort();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a map was selected from the map list.
 *
 **************************************************************************************************/
function mapSelected() {
	switchButton.bDisabled = mapList.selectedItem == none;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new map to the map list.
 *  $PARAM        mapName  Name of the map that is to be added.
 *  $REQUIRE      mapName != ""
 *
 **************************************************************************************************/
function string addMap(string mapName) {
	local NexgenSimpleListItem item;
	
	item = NexgenSimpleListItem(mapList.items.append(class'NexgenSimpleListItem'));
	item.displayText = mapName;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the client has received the map list from the server.
 *
 **************************************************************************************************/
function notifyMapListAvailable() {
	bMapListAvailable = true;
	loadMapList();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the client has received a part of the map list.
 *
 **************************************************************************************************/
function notifyMapListPartRecieved() {
	local NexgenSimpleListItem item;
	local string progress;
	
	if (!bMapListAvailable) {
		progress = string(int(xClient.numMapsSend * 100.0 / xClient.mapList.numMaps + 0.5));
		
		item = NexgenSimpleListItem(mapList.items.next);
		item.displayText = client.lng.format(xClient.lng.recievingMapListProgressTxt, progress);
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
	local NexgenSimpleListItem newItem;
	
	super.notify(control, eventType);
	
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
	}
	
	// Switch map button clicked?
	if (control == switchButton && eventType == DE_Click && !switchButton.bDisabled) {
		doMapSwitch();
	}
	
	// Game type selected?
	if (control == gameTypeList && eventType == DE_Change) {
		if (hideBadMapsInp.bChecked) {
			loadMapList();
		}
	}
	
	// Map selected?
	if (control == mapList && eventType == DE_Click) {
		mapSelected();
	}
	
	// Hide bad maps checkbox changed?
	if (control == hideBadMapsInp && eventType == DE_Change) {
		// Save setting.
		client.gc.set(SSTR_HideBadMaps, string(hideBadMapsInp.bChecked));
		client.gc.saveConfig();
		
		// Reload map list.
		loadMapList();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Performs the map switch with the currently selected map, mutators and game type.
 *
 **************************************************************************************************/
function doMapSwitch() {
	local string mutators;
	local NexgenSimpleListItem item;
	
	// Check if a map and game type have been selected.
	if (!bMapListAvailable ||mapList.selectedItem == none || gameTypeList.getSelectedIndex() < 0) {
		return;
	}
	
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
	
	// Send the map switch request to the server.
	xClient.doMapSwitch(NexgenSimpleListItem(mapList.selectedItem).displayText, gameTypeList.getSelectedIndex(), mutators);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="mapswitch"
}
