/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPMapSwitchRCP
 *  $VERSION      1.02 (04-12-2010 15:16:30)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen map switch control panel page.
 *
 **************************************************************************************************/
class NXPMapSwitchRCP extends NexgenPanel;

var NXPClient xClient;

var UWindowSmallButton switchButton;
var UWindowSmallButton reloadMapListButton;
var NexgenSimpleListBox mapList;
var NexgenSimpleListBox inclMutatorList;
var NexgenSimpleListBox exclMutatorList;
var UWindowComboControl gameTypeList;
var UWindowCheckbox hideBadMapsInp;

var NexgenSharedDataContainer mapListData;

var string lastSelectedMap;

const SSTR_HideBadMaps = "HideBadMaps";



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local NexgenContentPanel p;
	
	xClient = NXPClient(client.getController(class'NXPClient'.default.ctrlID));
	lastSelectedMap = class'NexgenUtil'.static.getLevelFileName(client.level);
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionV(192, defaultComponentDist);
	splitRegionH(20, defaultComponentDist, , true);
	splitRegionH(20, defaultComponentDist, , true);
	mapList = NexgenSimpleListBox(addListBox(class'NexgenSimpleListBox'));
	hideBadMapsInp = addCheckBox(TA_Left, xClient.lng.hideBadMapsTxt, true);
	p = addContentPanel();
	splitRegionV(192, defaultComponentDist, , true);
	skipRegion();
	divideRegionV(2, defaultComponentDist);
	if (client.hasRight(client.R_ServerAdmin)) {
		reloadMapListButton = addButton(xClient.lng.reloadMapListTxt);
	} else {
		skipRegion();
	}
	switchButton = addButton(xClient.lng.mapSwitchActionTxt);
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
	if (reloadMapListButton != none) {
		reloadMapListButton.bDisabled = !xClient.dataSyncMgr.getBool(class'NXPConfigDC'.default.containerID, "cacheMapList");
	}
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
	local int numMaps;
	local string mapName;

	// Clear the map list.
	mapList.items.clear();
	mapList.selectedItem = none;
	mapSelected();
	
	// Check if the map list is available.
	if (mapListData == none) {
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
	numMaps = mapListData.getInt("numMaps");
	if (!bHideBadMaps || mapPrefix != "") {
		for (index = 0; index < numMaps; index++) {
			mapName = mapListData.getString("maps", index);
			
			// Add map?
			if (class'NexgenUtil'.static.isValidLevel(mapName) && (!bHideBadMaps || left(mapName, len(mapPrefix)) ~= mapPrefix)) {
				addMap(mapName, mapName ~= lastSelectedMap);
			}
		}
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
	if (mapList.selectedItem != none) {
		lastSelectedMap = NexgenSimpleListItem(mapList.selectedItem).displayText;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new map to the map list.
 *  $PARAM        mapName  Name of the map that is to be added.
 *  $REQUIRE      mapName != ""
 *
 **************************************************************************************************/
function string addMap(string mapName, optional bool selected) {
	local NexgenSimpleListItem item;
	
	item = NexgenSimpleListItem(mapList.items.append(class'NexgenSimpleListItem'));
	item.displayText = mapName;
	if (selected) {
		mapList.setSelectedItem(item);
	}
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
	if (container.containerID == class'NXPMapListDC'.default.containerID) {
		mapListData = container;
		loadMapList();
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
			case "cacheMapList":
				if (reloadMapListButton != none) {
					reloadMapListButton.bDisabled = !container.getBool(varName);
				}
				break;
		}
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
	
	// Reload map list button clicked?
	if (reloadMapListButton != none && control == reloadMapListButton&& eventType == DE_Click && !reloadMapListButton.bDisabled) {
		client.showMsg(xClient.lng.mapListReloadingMsg);
		xClient.setVar("nxp_config", "reloadMapList", true);
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
	if (mapListData == none || mapList.selectedItem == none || gameTypeList.getSelectedIndex() < 0) {
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