/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPBanControl
 *  $VERSION      1.01 (2-11-2007 21:12)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen ban control panel page.
 *
 **************************************************************************************************/
class NexgenRCPBanControl extends NexgenPanel;

var NexgenClientCore rpci;                        // Remote Procedure Call interface. 

var NexgenSimpleListBox banList;
var NexgenSimpleListBox ipList;
var NexgenSimpleListBox idList;
var UWindowSmallButton addBanButton;
var UWindowSmallButton updateBanButton;
var UWindowSmallButton deleteBanButton;
var UWindowEditControl playerNameInp;
var UWindowEditControl banReasonInp;
var UWindowCheckbox banPeriodInp[3];
var NexgenEditControl matchCountInp;
var NexgenEditControl dateInp;
var UWindowSmallButton addIPButton;
var UWindowSmallButton delIPButton;
var UWindowSmallButton addIDButton;
var UWindowSmallButton delIDButton;
var UWindowEditControl ipAddressInp;
var UWindowEditControl clientIDInp;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local NexgenContentPanel p;
	local int region;
	local int index;
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionV(160, defaultComponentDist);
	splitRegionH(72, defaultComponentDist, , true);
	
	// Ban entry editor.
	p = addContentPanel();
	
	// Player name & ban reason.
	region = p.splitRegionH(40, defaultComponentDist) + 1;
	p.splitRegionV(96);
	p.skipRegion();
	p.divideRegionH(2);
	p.divideRegionH(2);
	p.addLabel(client.lng.playerNameTxt, true);
	p.addLabel(client.lng.banReasonTxt, true);
	playerNameInp = p.addEditBox();
	banReasonInp = p.addEditBox();
	
	// Ban period.
	p.selectRegion(region);
	p.selectRegion(p.splitRegionH(64, defaultComponentDist));
	region = p.currRegion + 1;
	p.splitRegionH(1);
	p.skipRegion();
	p.addComponent(class'NexgenDummyComponent');
	p.splitRegionV(96);
	p.divideRegionH(3);
	p.splitRegionV(96, defaultComponentDist);
	p.addLabel(client.lng.banPeriodTxt, true);
	p.skipRegion();
	p.skipRegion();
	p.divideRegionH(3);
	p.divideRegionH(3);
	banPeriodInp[0] = p.addCheckBox(TA_Left, client.lng.banForeverTxt);
	banPeriodInp[1] = p.addCheckBox(TA_Left, client.lng.banMatchesTxt);
	banPeriodInp[2] = p.addCheckBox(TA_Left, client.lng.banUntilDateTxt);
	p.skipRegion();
	matchCountInp = p.addEditBox();
	dateInp = p.addEditBox();
	
	// Banned IP's and ID's.
	p.selectRegion(region);
	p.selectRegion(p.splitRegionH(1, defaultComponentDist));
	p.addComponent(class'NexgenDummyComponent');
	p.divideRegionH(2, defaultComponentDist);
	p.splitRegionV(224, defaultComponentDist, , true);
	p.splitRegionV(224, defaultComponentDist, , true);
	p.splitRegionH(56);
	ipList = NexgenSimpleListBox(p.addListBox(class'NexgenSimpleListBox'));
	p.splitRegionH(56);
	idList = NexgenSimpleListBox(p.addListBox(class'NexgenSimpleListBox'));
	p.divideRegionH(3);
	p.skipRegion();
	p.divideRegionH(3);
	p.skipRegion();
	p.addLabel(client.lng.ipAddressesTxt, true);
	p.divideRegionV(2, defaultComponentDist);
	ipAddressInp = p.addEditBox();
	p.addLabel(client.lng.clientIDsTxt, true);
	p.divideRegionV(2, defaultComponentDist);
	clientIDInp = p.addEditBox();
	addIPButton = p.addButton(client.lng.addTxt);
	delIPButton = p.addButton(client.lng.removeTxt);
	addIDButton = p.addButton(client.lng.addTxt);
	delIDButton = p.addButton(client.lng.removeTxt);
	
	// Ban list.
	banList = NexgenSimpleListBox(addListBox(class'NexgenSimpleListBox'));
	
	// Ban list editor.
	p = addContentPanel();
	p.divideRegionH(3);
	addBanButton = p.addButton(client.lng.addBanTxt);
	updateBanButton = p.addButton(client.lng.updateBanTxt);
	deleteBanButton = p.addButton(client.lng.delBanTxt);
	
	// Configure components.
	ipAddressInp.setMaxLength(15);
	clientIDInp.setMaxLength(32);
	playerNameInp.setMaxLength(32);
	banReasonInp.setMaxLength(255);
	matchCountInp.setMaxLength(3);
	matchCountInp.setNumericOnly(true);
	dateInp.setMaxLength(24);
	banList.register(self);
	ipList.register(self);
	idList.register(self);
	addIPButton.register(self);
	delIPButton.register(self);
	addIDButton.register(self);
	delIDButton.register(self);
	addBanButton.register(self);
	updateBanButton.register(self);
	deleteBanButton.register(self);
	for (index = 0; index < arrayCount(banPeriodInp); index++) {
		banPeriodInp[index].register(self);
	}
	loadBanList();
	banPeriodInp[0].bChecked = true;
	banPeriodTypeSelected();
	delIPButton.bDisabled = true;
	delIDButton.bDisabled = true;
	dateInp.setValue(client.lng.dateFormatStr);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Load the banlist.
 *
 **************************************************************************************************/
function loadBanList() {
	local int index;
	local NexgenSimpleListItem item;
	local int numBans;
	
	// Clear list.
	banList.items.clear();
	banList.selectedItem = none;
	
	// Add bans.
	while(index < arrayCount(client.sConf.bannedName) && client.sConf.bannedName[index] != "") {
		item = NexgenSimpleListItem(banList.items.append(class'NexgenSimpleListItem'));
		item.displayText = client.sConf.bannedName[index];
		item.itemID = index;
		
		index++;
	}
	
	// Configure components.
	numBans = index;
	addBanButton.bDisabled = numBans >= arrayCount(client.sConf.bannedName);
	banSelected();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a ban entry has been selected. Loads the info for the selected ban
 *                entry & configures the components.
 *
 **************************************************************************************************/
function banSelected() {
	
	// Item selected?
	if (banList.selectedItem == none) {
		// No.
		updateBanButton.bDisabled = true;
		deleteBanButton.bDisabled = true;
	} else {
		// Yes.
		updateBanButton.bDisabled = false;
		deleteBanButton.bDisabled = false;
		loadBanInfo(NexgenSimpleListItem(banList.selectedItem).itemID);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the information for the specified ban entry.
 *  $PARAM        entryNum  The entry number in the ban list.
 *  $REQUIRE      0 <= entryNum && entryNum < arrayCount(client.sConf.bannedName) &&
 *                client.sConf.bannedName[entryNum] != ""
 *
 **************************************************************************************************/
function loadBanInfo(int entryNum) {
	local string remaining;
	local string part;
	local NexgenSimpleListItem item;
	local byte banPeriodType;
	local string banArgs;
	local int index;
	
	// Player name & ban reason.
	playerNameInp.setValue(client.sConf.bannedName[entryNum]);
	banReasonInp.setValue(client.sConf.banReason[entryNum]);
	
	// Ban period.
	client.sConf.getBanPeriodType(client.sConf.banPeriod[entryNum], banPeriodType, banArgs);
	for (index = 0; index < arrayCount(banPeriodInp); index++) {
		banPeriodInp[index].bChecked = index == banPeriodType;
	}
	if (banPeriodType == client.sConf.BP_Matches) {
		matchCountInp.setDisabled(false);
		matchCountInp.setValue(banArgs);
		dateInp.setDisabled(true);
		dateInp.setValue("");
	} else if (banPeriodType == client.sConf.BP_UntilDate) {
		matchCountInp.setDisabled(true);
		matchCountInp.setValue("");
		dateInp.setDisabled(false);
		dateInp.setValue(client.lng.getLocalizedDateStr(banArgs));
	} else {
		matchCountInp.setDisabled(true);
		matchCountInp.setValue("");
		dateInp.setDisabled(true);
		dateInp.setValue("");
	}
	
	// Load ip addresses.
	ipList.items.clear();
	ipList.selectedItem = none;
	remaining = client.sConf.bannedIPs[entryNum];
	while (remaining != "") {
		// Split head element from tail.
		index = instr(remaining, separator);
		if (index < 0) {
			part = remaining;
			remaining = "";
		} else {
			part = left(remaining, index);
			remaining = mid(remaining, index + len(separator));
		}
		
		// Add element to list.
		item = NexgenSimpleListItem(ipList.items.append(class'NexgenSimpleListItem'));
		item.displayText = part;
	}
	addIPButton.bDisabled = ipList.items.countShown() >= client.sConf.maxBanIPAddresses;
	delIPButton.bDisabled = true;
	
	// Load client id's.
	idList.items.clear();
	idList.selectedItem = none;
	remaining = client.sConf.bannedIDs[entryNum];
	while (remaining != "") {
		// Split head element from tail.
		index = instr(remaining, separator);
		if (index < 0) {
			part = remaining;
			remaining = "";
		} else {
			part = left(remaining, index);
			remaining = mid(remaining, index + len(separator));
		}
		
		// Add element to list.
		item = NexgenSimpleListItem(idList.items.append(class'NexgenSimpleListItem'));
		item.displayText = part;
	}
	addIDButton.bDisabled = idList.items.countShown() >= client.sConf.maxBanClientIDs;
	delIDButton.bDisabled = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a ban period type was selected.
 *
 **************************************************************************************************/
function banPeriodTypeSelected() {
	matchCountInp.setDisabled(!banPeriodInp[client.sConf.BP_Matches].bChecked);
	dateInp.setDisabled(!banPeriodInp[client.sConf.BP_UntilDate].bChecked);
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
	if (configType == client.sConf.CT_BanList) {
		loadBanList();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Assembles the current ban period string.
 *  $RETURN       The ban period string for the currently selected settings.
 *
 **************************************************************************************************/
function string getCurrentBanPeriod() {
	if (banPeriodInp[client.sConf.BP_Matches].bChecked) {
		return "M" $ matchCountInp.getValue();
	} else if (banPeriodInp[client.sConf.BP_UntilDate].bChecked) {
		return "U" $ client.lng.getDelocalizedDateStr(dateInp.getValue());
	} else {
		return "";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the ip addresses entered in the ip list.
 *  $RETURN       A string containing all ip addresses entered in the ip list.
 *
 **************************************************************************************************/
function string getIPList() {
	local NexgenSimpleListItem item;
	local string list;
	
	// Assemble list.
	for (item = NexgenSimpleListItem(ipList.items); item != none; item = NexgenSimpleListItem(item.next)) {
		if (item.displayText != "") {
			if (list == "") {
				list = item.displayText;
			} else {
				list = list $ separator $ item.displayText;
			}
		}
	}
	
	// Return the list.
	return list;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the client id's entered in the id list.
 *  $RETURN       A string containing all client id's entered in the id list.
 *
 **************************************************************************************************/
function string getIDList() {
	local NexgenSimpleListItem item;
	local string list;
	
	// Assemble list.
	for (item = NexgenSimpleListItem(idList.items); item != none; item = NexgenSimpleListItem(item.next)) {
		if (item.displayText != "") {
			if (list == "") {
				list = item.displayText;
			} else {
				list = list $ separator $ item.displayText;
			}
		}
	}
	
	// Return the list.
	return list;
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
	local int index;
	local int selectedIndex;
	local string value;
	local NexgenSimpleListItem item;
	local string playerName;
	
	super.notify(control, eventType);
	
	setRPCI();
	
	// Add ban entry button clicked?
	if (control == addBanButton && eventType == DE_Click && !addBanButton.bDisabled) {
		playerName = class'NexgenUtil'.static.trim(playerNameInp.getValue());
		if (playerName != "") {
			rpci.addBan(playerName, getIPList(), getIDList(),
			            class'NexgenUtil'.static.trim(banReasonInp.getValue()),
			            getCurrentBanPeriod());
		}
	}

	// Update ban entry button clicked?
	if (control == updateBanButton && eventType == DE_Click && !updateBanButton.bDisabled) {
		playerName = class'NexgenUtil'.static.trim(playerNameInp.getValue());
		if (playerName != "") {
			rpci.updateBan(NexgenSimpleListItem(banList.selectedItem).itemID,
			               playerName, getIPList(), getIDList(),
			               class'NexgenUtil'.static.trim(banReasonInp.getValue()),
			               getCurrentBanPeriod());
		}
	}
	
	// Delete ban entry button clicked?
	if (control == deleteBanButton && eventType == DE_Click && !deleteBanButton.bDisabled) {
		rpci.deleteBan(NexgenSimpleListItem(banList.selectedItem).itemID);
	}
	
	// Ban entry selected?
	if (control == banList && eventType == DE_Click) {
		banSelected();
	}
	
	// IP address selected?
	if (control == ipList && eventType == DE_Click) {
		delIPButton.bDisabled = ipList.selectedItem == none;
		if (ipList.selectedItem != none) {
			ipAddressInp.setValue(NexgenSimpleListItem(ipList.selectedItem).displayText);
		}
	}
		
	// Client ID selected?
	if (control == idList && eventType == DE_Click) {
		delIDButton.bDisabled = idList.selectedItem == none;
		if (idList.selectedItem != none) {
			clientIDInp.setValue(NexgenSimpleListItem(idList.selectedItem).displayText);
		}
	}

	// Add IP address pressed?
	if (control == addIPButton && eventType == DE_Click && !addIPButton.bDisabled) {
		value = class'NexgenUtil'.static.trim(ipAddressInp.getValue());
		if (class'NexgenUtil'.static.isValidIPAddress(value)) {
			item = NexgenSimpleListItem(ipList.items.append(class'NexgenSimpleListItem'));
			item.displayText = value;
			addIPButton.bDisabled = ipList.items.countShown() >= client.sConf.maxBanIPAddresses;
		}
	}
	
	// Del IP address pressed?
	if (control == delIPButton && eventType == DE_Click && !delIPButton.bDisabled) {
		ipList.selectedItem.remove();
		ipList.selectedItem = none;
		delIPButton.bDisabled = true;
		addIPButton.bDisabled = ipList.items.countShown() >= client.sConf.maxBanIPAddresses;
	}
	
	// Del client ID pressed?
	if (control == addIDButton && eventType == DE_Click && !addIDButton.bDisabled) {
		value = class'NexgenUtil'.static.trim(clientIDInp.getValue());
		if (class'NexgenUtil'.static.isValidClientID(value)) {
			item = NexgenSimpleListItem(idList.items.append(class'NexgenSimpleListItem'));
			item.displayText = value;
			addIDButton.bDisabled = idList.items.countShown() >= client.sConf.maxBanClientIDs;
		}
	}

	// Del client ID pressed?
	if (control == delIDButton && eventType == DE_Click && !delIDButton.bDisabled) {
		idList.selectedItem.remove();
		idList.selectedItem = none;
		delIDButton.bDisabled = true;
		addIDButton.bDisabled = idList.items.countShown() >= client.sConf.maxBanClientIDs;
	}
	
	// Ban period type selected?
	if (eventType == DE_Click && control.isA('UWindowCheckbox')) {
		// Find selected type.
		selectedIndex = -1;
		while (selectedIndex < 0 && index < arrayCount(banPeriodInp)) {
			if (control == banPeriodInp[index]) {
				selectedIndex = index;
			} else {
				index++;
			}
		}
		
		// Has a period been selected?
		if (selectedIndex >= 0) {
			// Yes, update components.
			for (index = 0; index < arrayCount(banPeriodInp); index++) {
				banPeriodInp[index].bChecked = index == selectedIndex;
			}
			banPeriodTypeSelected();
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="bancontrol"
}
