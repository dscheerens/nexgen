/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPModerate
 *  $VERSION      1.01 (1-8-2008 20:50)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen moderator control panel page.
 *
 **************************************************************************************************/
class NexgenRCPModerate extends NexgenPanel;

var NexgenClientCore rpci;                        // Remote Procedure Call interface.

var NexgenPlayerListBox playerList;
var UMenuLabelControl ipAddressLabel;
var UMenuLabelControl clientIDLabel;
var UWindowSmallButton copyIPAddressButton;
var UWindowSmallButton copyClientIDButton;
var UWindowSmallButton muteToggleButton;
var UWindowSmallButton setNameButton;
var UWindowSmallButton kickButton;
var UWindowSmallButton banButton;
var UWindowSmallButton showMsgButton;
var UWindowEditControl playerNameInp;
var UWindowEditControl banReasonInp;
var NexgenEditControl numMatchesInp;
var NexgenEditControl numDaysInp;
var UWindowEditControl messageInp;
var UWindowCheckbox banForeverInp;
var UWindowCheckbox banMatchesInp;
var UWindowCheckbox banDaysInp;
var UWindowCheckbox muteAllInp;
var UWindowCheckbox allowNameChangeInp;



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
	splitRegionV(192, defaultComponentDist);
	playerList = NexgenPlayerListBox(addListBox(class'NexgenPlayerListBox'));
	
	// Player info.
	splitRegionH(49, defaultComponentDist);
	p = addContentPanel();
	p.divideRegionH(2);
	p.splitRegionV(64);
	p.splitRegionV(64);
	p.addLabel(client.lng.ipAddressTxt, true);
	p.splitRegionV(48, , , true);
	p.addLabel(client.lng.clientIDTxt, true);
	p.splitRegionV(48, , , true);
	ipAddressLabel = p.addLabel();
	copyIPAddressButton = p.addButton(client.lng.copyTxt);
	clientIDLabel = p.addLabel();
	copyClientIDButton = p.addButton(client.lng.copyTxt);
	
	// Player controller.
	splitRegionH(51, defaultComponentDist);
	p = addContentPanel();
	p.divideRegionH(2);
	p.splitRegionV(96, defaultComponentDist);
	p.splitRegionV(96, defaultComponentDist);
	muteToggleButton = p.addButton(client.lng.muteToggleTxt);
	p.skipRegion();
	setNameButton = p.addButton(client.lng.setPlayerNameTxt);
	playerNameInp = p.addEditBox();
	
	// Ban controller.
	splitRegionH(107, defaultComponentDist);
	p = addContentPanel();
	p.divideRegionH(5);
	p.splitRegionV(96, defaultComponentDist);
	p.splitRegionV(96, defaultComponentDist);
	p.splitRegionV(96, defaultComponentDist);
	p.splitRegionV(96, defaultComponentDist);
	p.splitRegionV(96, defaultComponentDist);
	p.addLabel(client.lng.banReasonTxt);
	banReasonInp = p.addEditBox();
	kickButton = p.addButton(client.lng.kickPlayerTxt);
	p.skipRegion();
	banButton = p.addButton(client.lng.banPlayerTxt);
	p.splitRegionV(96, defaultComponentDist);
	p.skipRegion();
	p.splitRegionV(96, defaultComponentDist);
	p.skipRegion();
	p.splitRegionV(96, defaultComponentDist);
	banForeverInp = p.addCheckBox(TA_Left, client.lng.banForeverTxt);
	p.skipRegion();
	banMatchesInp = p.addCheckBox(TA_Left, client.lng.banMatchesTxt);
	numMatchesInp = p.addEditBox();
	banDaysInp = p.addCheckBox(TA_Left, client.lng.banDaysTxt);
	numDaysInp = p.addEditBox();
	
	// Game controller.
	splitRegionH(65);
	p = addContentPanel();
	p.divideRegionH(3);
	muteAllInp = p.addCheckBox(TA_Left, client.lng.muteAllTxt);
	allowNameChangeInp = p.addCheckBox(TA_Left, client.lng.allowNameChangeTxt);
	p.splitRegionV(96, defaultComponentDist);
	showMsgButton = p.addButton(client.lng.showAdminMessageTxt);
	messageInp = p.addEditBox();
	
	// Configure components.
	playerNameInp.setMaxLength(32);
	banReasonInp.setMaxLength(250);
	numMatchesInp.setMaxLength(4);
	numMatchesInp.setNumericOnly(true);
	numDaysInp.setMaxLength(4);
	numDaysInp.setNumericOnly(true);
	messageInp.setMaxLength(250);
	playerList.register(self);
	muteToggleButton.register(self);
	setNameButton.register(self);
	kickButton.register(self);
	banButton.register(self);
	showMsgButton.register(self);
	banForeverInp.register(self);
	banMatchesInp.register(self);
	banDaysInp.register(self);
	muteAllInp.register(self);
	allowNameChangeInp.register(self);
	banMatchesInp.bChecked = true;
	numMatchesInp.setValue("3");
	numDaysInp.setValue("7");
	playerSelected();
	banPeriodSelected();
	setValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current game info settings.
 *
 **************************************************************************************************/
function setValues() {
	muteAllInp.bChecked = client.gInf.bMuteAll;
	allowNameChangeInp.bChecked = !client.gInf.bNoNameChange;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player was selected from the list.
 *
 **************************************************************************************************/
function playerSelected() {
	local NexgenPlayerList item;
	
	item = NexgenPlayerList(playerList.selectedItem);
	
	muteToggleButton.bDisabled = (item == none);
	setNameButton.bDisabled = (item == none);
	kickButton.bDisabled = (item == none);
	banButton.bDisabled = (item == none || !client.hasRight(client.R_BanOperator));
	copyIPAddressButton.bDisabled = (item == none);
	copyClientIDButton.bDisabled = (item == none);
	if (item == none) {
		playerNameInp.setValue("");
		ipAddressLabel.setText("");
		clientIDLabel.setText("");
	} else {
		playerNameInp.setValue(item.pName);
		ipAddressLabel.setText(item.pIPAddress);
		clientIDLabel.setText(item.pClientID);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a ban period was selected from the list.
 *
 **************************************************************************************************/
function banPeriodSelected() {
	numMatchesInp.setDisabled(!banMatchesInp.bChecked);
	numDaysInp.setDisabled(!banDaysInp.bChecked);
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
 *  $DESCRIPTION  Bans the currently selected player.
 *
 **************************************************************************************************/
function banPlayer() {
	local byte banPeriodType;
	local int banPeriodArgs;
	
	if (banMatchesInp.bChecked) {
		banPeriodType = client.sConf.BP_Matches;
		banPeriodArgs = int(class'NexgenUtil'.static.trim(numMatchesInp.getValue()));
	} else if (banDaysInp.bChecked) {
		banPeriodType = client.sConf.BP_UntilDate;
		banPeriodArgs = int(class'NexgenUtil'.static.trim(numDaysInp.getValue()));
	} else {
		banPeriodType = client.sConf.BP_Forever;
	}
	
	rpci.banPlayer(NexgenPlayerList(playerList.selectedItem).pNum, banPeriodType, banPeriodArgs,
	               class'NexgenUtil'.static.trim(banReasonInp.getValue()));
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
	local NexgenPlayerList item;
	
	super.notify(control, eventType);
	
	setRPCI();

	// Button pressed?
	if (control != none && eventType == DE_Click && control.isA('UWindowSmallButton') &&
	    !UWindowSmallButton(control).bDisabled && rpci != none) {
	
		switch (control) {
			case muteToggleButton:
				rpci.togglePlayerMute(NexgenPlayerList(playerList.selectedItem).pNum);
				break;
				
			case setNameButton:
				rpci.setPlayerName(NexgenPlayerList(playerList.selectedItem).pNum,
				                   class'NexgenUtil'.static.trim(playerNameInp.getValue()));
				break;
				
			case kickButton:
				rpci.kickPlayer(NexgenPlayerList(playerList.selectedItem).pNum,
				                class'NexgenUtil'.static.trim(banReasonInp.getValue()));
				break;
				
			case banButton:
				banPlayer();
				break;
				
			case showMsgButton:
				rpci.showAdminMessage(class'NexgenUtil'.static.trim(messageInp.getValue()));
				break;
			
			case copyIPAddressButton:
				item = NexgenPlayerList(playerList.selectedItem);
				if (item != none) {
					getPlayerOwner().copyToClipboard(item.pIPAddress);
				}
				break;
			
			case copyClientIDButton:
				item = NexgenPlayerList(playerList.selectedItem);
				if (item != none) {
					getPlayerOwner().copyToClipboard(item.pClientID);
				}
				break;
		}
	}

	// Player selected?
	if (control == playerList && eventType == DE_Click) {
		playerSelected();
	}
	
	// Ban period selected?
	if (control == banForeverInp && eventType == DE_Click) {
		banForeverInp.bChecked = true;
		banMatchesInp.bChecked = false;
		banDaysInp.bChecked = false;
		banPeriodSelected();
	} else if (control == banMatchesInp && eventType == DE_Click) {
		banForeverInp.bChecked = false;
		banMatchesInp.bChecked = true;
		banDaysInp.bChecked = false;
		banPeriodSelected();
	} else if (control == banDaysInp && eventType == DE_Click) {
		banForeverInp.bChecked = false;
		banMatchesInp.bChecked = false;
		banDaysInp.bChecked = true;
		banPeriodSelected();
	}
	
	// Toggle mute all clicked?
	if (control == muteAllInp && eventType == DE_Click && rpci != none) {
		rpci.toggleGlobalMute();
	}
	
	// Toggle allow name change clicked?
	if (control == allowNameChangeInp && eventType == DE_Click && rpci != none) {
		rpci.toggleGlobalNameChange();
	}
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
	
	// Player has joined the game?
	if (eventType == client.PE_PlayerJoined) {
		addPlayerToList(playerList, playerNum, args);
	}
	
	// Player has left the game?
	if (eventType == client.PE_PlayerLeft) {
		playerList.removePlayer(playerNum);
		playerSelected();
	}
	
	// Attribute changed?
	if (eventType == client.PE_AttributeChanged) {
		updatePlayerInfo(playerList, playerNum, args);
		playerSelected();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies this panel that the extended game info has been updated.
 *  $PARAM        infoType  Type of information that has been changed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function gameInfoChanged(byte infoType) {
	if (infoType == client.gInf.IT_GlobalRights) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="moderate"
}
