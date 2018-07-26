/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPUserAccounts
 *  $VERSION      1.03 (9-8-2008 19:28)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen user account control panel page.
 *
 **************************************************************************************************/
class NexgenRCPUserAccounts extends NexgenPanel;

var NexgenClientCore rpci;                        // Remote Procedure Call interface. 

var UWindowCheckbox rightEnableInp[18];
var NexgenPlayerACListBox playerList;
var NexgenSimpleListBox accountList;
var UWindowComboControl accountTypeList;
var NexgenEditControl accountNameInp;
var NexgenEditControl accountTitleInp;
var UWindowSmallButton addButton;
var UWindowSmallButton updateButton;
var UWindowSmallButton deleteButton;

const invalidAccountType = -1;                    // Invalid or no account type selected.
const customAccountType = 0;                      // Custom account type selected.
const defaultAccountType = 1;                     // Default account type selected.



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
	divideRegionH(2, defaultComponentDist);
	
	// User info panel.
	p = addContentPanel();
	p.splitRegionH(64);
	p.splitRegionV(96);
	p.splitRegionH(16, , , true);
	p.divideRegionH(3);
	p.divideRegionH(3);
	p.divideRegionV(2, defaultComponentDist);
	p.splitRegionV(192);
	p.addLabel(client.lng.userNameTxt, true);
	p.addLabel(client.lng.accountTypeTxt, true);
	p.addLabel(client.lng.userTitleTxt, true);
	accountNameInp = p.addEditBox();
	accountTypeList = p.addListCombo();
	accountTitleInp = p.addEditBox();
	p.divideRegionH(arraycount(rightEnableInp) / 2);
	p.divideRegionH(arraycount(rightEnableInp) / 2);
	p.divideRegionV(3, defaultComponentDist);
	p.skipRegion();
	for (index = 0; index < arraycount(rightEnableInp); index++) {
		rightDef = client.sConf.rightsDef[index];
		if (rightDef == "") {
			rightEnableInp[index] = p.addCheckBox(TA_Left, client.lng.format(client.lng.rightNotDefinedTxt, string(index + 1)));
		} else {
			rightEnableInp[index] = p.addCheckBox(TA_Left, mid(rightDef, instr(rightDef, client.sConf.separator) + 1));
		}
	}
	updateButton = p.addButton(client.lng.updateTxt);
	addButton = p.addButton(client.lng.addTxt);
	deleteButton = p.addButton(client.lng.deleteTxt);
	
	// Account / player lists.
	splitRegionH(16);
	splitRegionH(16);
	addLabel(client.lng.onlineTxt, true, TA_Center);
	playerList = NexgenPlayerACListBox(addListBox(class'NexgenPlayerACListBox'));
	addLabel(client.lng.offlineTxt, true, TA_Center);
	accountList = NexgenSimpleListBox(addListBox(class'NexgenSimpleListBox'));
	
	// Configure components.
	accountNameInp.setMaxLength(32);
	accountTitleInp.setMaxLength(24);
	accountTypeList.setEditable(false);
	playerList.register(self);
	accountList.register(self);
	updateButton.register(self);
	deleteButton.register(self);
	accountTypeList.register(self);
	loadUserAccounts();
	loadAccountTypes();
	accountSelected();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the account types.
 *
 **************************************************************************************************/
function loadAccountTypes() {
	local int index;
	
	accountTypeList.clear();
	
	accountTypeList.addItem(client.lng.customAccountTxt, string(-1));
	
	while(index < arrayCount(client.sConf.atTypeName) && client.sConf.atTypeName[index] != "") {
		accountTypeList.addItem(client.sConf.atTypeName[index], string(index));
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Load the user account list.
 *
 **************************************************************************************************/
function loadUserAccounts() {
	local int index;
	local NexgenPlayerACListItem playerItem;
	local NexgenSimpleListItem accountItem;
	
	// Clear account list.
	accountList.items.clear();
	accountList.selectedItem = none;
	
	// Load each user account.
	while (index < arrayCount(client.sConf.paPlayerID) && client.sConf.paPlayerID[index] != "") {
		playerItem = NexgenPlayerACListItem(playerList.getPlayerByID(client.sConf.paPlayerID[index]));
		
		// Client is online?
		if (playerItem == none) {
			// Nope, add to account list.
			accountItem = NexgenSimpleListItem(accountList.items.append(class'NexgenSimpleListItem'));
			accountItem.itemID = index;
			accountItem.displayText = "[" $ client.sConf.getUserAccountTitle(index) $ "] " $ client.sConf.paPlayerName[index];
		}
		
		// Continue with next user account.
		index++;
	}
	
	// Sort list.
	accountList.items.sort();
	
	// Load account info for online players.
	updatePlayerList();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client of a player event. Additional arguments to the event should be
 *                combined into one string which then can be send along with the playerEvent call.
 *  $PARAM        playerNum  Player identification number.
 *  $PARAM        eventType  Type of event that has occurred.
 *  $PARAM        args       Optional arguments.
 *  $REQUIRE      playerNum >= 0
 *
 **************************************************************************************************/
function playerEvent(int playerNum, string eventType, optional string args) {
	local NexgenPlayerACListItem playerItem;
	local NexgenSimpleListItem accountItem;
	local bool bFound;
	local int accountNum;
	
	// Player has joined the game?
	if (eventType == client.PE_PlayerJoined) {
		// Add player.
		playerItem = NexgenPlayerACListItem(addPlayerToList(playerList, playerNum, args));
		playerList.items.sort();
		
		// Check if player has an account.
		accountNum = client.sConf.getUserAccountIndex(playerItem.pClientID);
		if (accountNum >= 0) {
			// Player has an account.
			
			// Update attributes.
			playerItem.bHasAccount = true;
			playerItem.accountNum = accountNum;
			
			// Move account item to player list.
			accountItem = accountList.getItemByID(accountNum);
			if (accountList.selectedItem == accountItem) {
				playerItem.bSelected = true;
				playerList.selectedItem = playerItem;
				accountList.selectedItem = none;
			}
			accountItem.remove();
		}
	}
	
	// Player has left the game?
	if (eventType == client.PE_PlayerLeft) {
		
		// Check if player has an account.
		playerItem = NexgenPlayerACListItem(playerList.getPlayer(playerNum));
		if (playerItem != none && playerItem.bHasAccount) {
			accountItem = NexgenSimpleListItem(accountList.items.append(class'NexgenSimpleListItem'));
			accountItem.itemID = playerItem.accountNum;
			accountItem.displayText = "[" $ client.sConf.getUserAccountTitle(playerItem.accountNum) $
			                          "] " $ client.sConf.paPlayerName[playerItem.accountNum];

			accountList.items.sort();
			if (playerList.selectedItem == playerItem) {
				accountItem.bSelected = true;
				accountList.selectedItem = accountItem;
				playerList.selectedItem = none;
			}
		}
		
		// Delete from player list.
		playerList.removePlayer(playerNum);
		
	}
	
	// Attribute changed?
	if (eventType == client.PE_AttributeChanged) {
		updatePlayerInfo(playerList, playerNum, args);
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
	local string clientID;
	local string accountName;
	local int accountType;
	local string rights;
	local string title;
		
	super.notify(control, eventType);
	
	setRPCI();
	
	// Online player selected.
	if (control == playerList && eventType == DE_Click) {
		if (accountList.selectedItem != none) {
			accountList.selectedItem.bSelected = false;
			accountList.selectedItem = none;
		}
		accountSelected();
	}
	
	// Offline player selected.
	if (control == accountList && eventType == DE_Click) {
		if (playerList.selectedItem != none) {
			playerList.selectedItem.bSelected = false;
			playerList.selectedItem = none;
		}
		accountSelected();
	}
	
	// Account type selected.
	if (control == accountTypeList && eventType == DE_Change) {
		accountTypeSelected();
	}
	
	// Delete button clicked.
	if (control == deleteButton && eventType == DE_Click && !deleteButton.bDisabled && rpci != none) {
		rpci.deleteAccount(getSelectedAccountNum());
	}
	
	// Update button clicked.
	if (control == updateButton && eventType == DE_Click && !updateButton.bDisabled && rpci != none) {
		accountName = class'NexgenUtil'.static.trim(accountNameInp.getValue());
		accountType = accountTypeList.getSelectedIndex() - 1;
		if (accountType < 0) {
			rights = getCurrentRights();
			title = class'NexgenUtil'.static.trim(accountTitleInp.getValue());
		} else {
			rights = "";
			title = "";
		}
		rpci.updateAccount(getSelectedAccountNum(), accountName, accountType, rights, title);
	}
	
	// Add button clicked.
	if (control == addButton && eventType == DE_Click && !addButton.bDisabled && rpci != none) {
		clientID = NexgenPlayerACListItem(playerList.selectedItem).pClientID;
		accountName = class'NexgenUtil'.static.trim(accountNameInp.getValue());
		accountType = accountTypeList.getSelectedIndex() - 1;
		if (accountType < 0) {
			rights = getCurrentRights();
			title = class'NexgenUtil'.static.trim(accountTitleInp.getValue());
		} else {
			rights = "";
			title = "";
		}
		rpci.addAccount(clientID, accountName, accountType, rights, title);
	}
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
 *  $DESCRIPTION  Retrieves the account number of the account currently selected from the online or
 *                offline account lists.
 *  $RETURN       The account number of the currently selected account, or -1 if no account was
 *                selected.
 *
 **************************************************************************************************/
function int getSelectedAccountNum() {
	local int accountNum;
	
	// Get account number of selected online / offline account.
	if (playerList.selectedItem != none) {
		// Online account selected.
		accountNum = NexgenPlayerACListItem(playerList.selectedItem).accountNum;
	} else if (accountList.selectedItem != none) {
		// Offline account selected.
		accountNum = NexgenSimpleListItem(accountList.selectedItem).itemID;
	} else {
		// No account selected.
		accountNum = -1;
	}
	
	// Return account number.
	return accountNum;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks if the currently selected item has an user account.
 *  $RETURN       True if the currently selected item has an user account, false if not.
 *
 **************************************************************************************************/
function bool selectionHasAccount() {
	local bool bHasAccount;
	
	// Check if selected item has an account.
	if (playerList.selectedItem != none) {
		// Online account selected.
		bHasAccount = NexgenPlayerACListItem(playerList.selectedItem).bHasAccount;
	} else if (accountList.selectedItem != none) {
		// Offline account selected.
		bHasAccount = true;
	} else {
		// No account selected.
		bHasAccount = false;
	}
	
	// Return result.
	return bHasAccount;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when an user account was selected from the list.
 *
 **************************************************************************************************/
function accountSelected() {
	local bool bItemSelected;
	local bool bHasAccount;
	local int index;
	local int accountNum;
	
	// Get account number of selected online / offline account.
	accountNum = getSelectedAccountNum();
	bHasAccount = selectionHasAccount();
	
	// Account selected?
	bItemSelected = accountNum >= 0;
	accountNameInp.setDisabled(!bItemSelected);
	updateButton.bDisabled = !bItemSelected || !bHasAccount || !canEditAccount(accountNum);
	deleteButton.bDisabled = !bItemSelected || !bHasAccount || !canEditAccount(accountNum);
	addButton.bDisabled = !bItemSelected || bHasAccount;
	// $TODO  Implement UWindowComboControl class that can be disabled.
	if (bHasAccount && bItemSelected) {
		accountNameInp.setValue(client.sConf.paPlayerName[accountNum]);
		accountTypeList.setSelectedIndex(client.sConf.get_paAccountType(accountNum) + 1);
	} else if (!bHasAccount && bItemSelected) {
		accountNameInp.setValue(NexgenPlayerACListItem(playerList.selectedItem).pName);
		accountTypeList.setSelectedIndex(defaultAccountType);
	} else {
		accountNameInp.setValue("");
		accountTypeList.setSelectedIndex(invalidAccountType);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether this client can delete the specified account.
 *  $PARAM        accountNum  The number of the account for which has to be checked if it can be
 *                            deleted by this client.
 *  $REQUIRE      0 <= accountNum && accountNum < arrayCount(client.sConf.paPlayerID) &&
 *                paPlayerID[accountNum] != none
 *  $RETURN       True if account can be deleted by this client, false if not.
 *
 **************************************************************************************************/
function bool canEditAccount(int accountNum) {
	local string rights;
	
	// Get rights of target account.
	if (client.sConf.get_paAccountType(accountNum) < 0) {
		rights = client.sConf.paCustomRights[accountNum];
	} else {
		rights = client.sConf.atRights[client.sConf.get_paAccountType(accountNum)];
	}
	
	// Return result.
	return client.hasRight(client.R_ServerAdmin) || !hasRight(rights, client.R_ServerAdmin);
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
 *  $DESCRIPTION  Called when an account type was selected from the list.
 *
 **************************************************************************************************/
function accountTypeSelected() {
	local int accountTypeNum;
	local int accountNum;
	local int index;
	local string rightDef;
	local string rightStr;
	local bool bItemSelected;
	local bool bHasAccount;
	local string title;
	local bool bClientIsServerAdmin;
	
	bClientIsServerAdmin = client.hasRight(client.R_ServerAdmin);
	
	// Get currently selected account type.
	accountTypeNum = accountTypeList.getSelectedIndex();
	
	// Get account number of selected online / offline account.
	accountNum = getSelectedAccountNum();
	bItemSelected = accountNum >= 0;
	bHasAccount = selectionHasAccount();
	
	// Retieve title.
	if (accountTypeNum == invalidAccountType) {
		title = "";
	} else if (accountTypeNum == customAccountType) {
		if (bHasAccount) {
			title = client.sConf.paCustomTitle[accountNum];
		} else {
			title = client.sConf.getAccountTypeTitle(0);
		}
	} else {
		title = client.sConf.getAccountTypeTitle(accountTypeNum - 1);
	}
	
	// Update GUI.
	if (accountTypeNum == invalidAccountType) {
		addButton.bDisabled = true;
		updateButton.bDisabled = true;
	} else if (bHasAccount) {
		addButton.bDisabled = true;
		updateButton.bDisabled = !canEditAccount(accountNum) ||
		                         !bClientIsServerAdmin && !canUseAccountType(accountTypeNum);
	} else {
		addButton.bDisabled = !bClientIsServerAdmin && !canUseAccountType(accountTypeNum);
		updateButton.bDisabled = true;
	}
	
	// Update title.
	accountTitleInp.setValue(title);
	accountTitleInp.setDisabled(accountTypeNum != customAccountType);
	
	// Retrieve rights.
	if (accountTypeNum == invalidAccountType) {
		rightStr = "";
	} else if (accountTypeNum == customAccountType) {
		if (bHasAccount) {
			rightStr = client.sConf.paCustomRights[accountNum];
		} else {
			rightStr = client.sConf.atRights[0];
		}
	} else {
		rightStr = client.sConf.atRights[accountTypeNum - 1];
	}
	
	// Update rights.
	for (index = 0; index < arraycount(rightEnableInp); index++) {
		rightDef = client.sConf.rightsDef[index];
		if (rightDef == "") {
			rightEnableInp[index].bDisabled = true;
		} else {
			rightEnableInp[index].bDisabled = accountTypeNum != customAccountType || !bClientIsServerAdmin &&
			                                  !client.hasRight(left(rightDef, instr(rightDef, separator)));
			rightEnableInp[index].bChecked = hasRight(rightStr, left(rightDef, instr(rightDef, separator)));
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether this client can grant the specified account type.
 *  $PARAM        accountType  The account type that is to be checked.
 *  $REQUIRE      0 <= accountType && accountType <= arrayCount(client.atTypeName)
 *  $RETURN       True if the client can grant the specified account type, false if not.
 *
 **************************************************************************************************/
function bool canUseAccountType(int accountType) {
	return (accountType == customAccountType) ||
	       (client.hasRights(client.sConf.atRights[accountType - 1]));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the player list. Iterates over all players in the player list and resets
 *                their account attributes.
 *
 **************************************************************************************************/
function updatePlayerList() {
	local NexgenPlayerACListItem item;
	local int index;
	
	// For each player...
	for (item = NexgenPlayerACListItem(playerList.items); item != none; item = NexgenPlayerACListItem(item.next)) {
		
		// Check account...
		index = client.sConf.getUserAccountIndex(item.pClientID);
		
		// Set account info...
		if (index >= 0) {
			item.bHasAccount = true;
			item.accountNum = index;
			item.pTitle = client.sConf.getUserAccountTitle(index);
		} else {
			item.bHasAccount = false;
			item.accountNum = 0;
			item.pTitle = client.sConf.getAccountTypeTitle(0);
		}
	}
	
	// Sort list.
	playerList.items.sort();
	
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
		loadUserAccounts();
		loadAccountTypes();
		accountSelected();
	}
	
	if (configType == client.sConf.CT_UserAccounts) {
		loadUserAccounts();
		accountSelected();
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
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="useraccounts"
}
