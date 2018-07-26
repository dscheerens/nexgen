/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPMatchSet
 *  $VERSION      1.05 (01-03-2010 13:23)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen match setup control panel page.
 *
 **************************************************************************************************/
class NexgenRCPMatchSet extends NexgenPanel;

var NexgenClientCore rpci;                        // Remote Procedure Call interface. 

var UWindowSmallButton saveButton;
var UWindowSmallButton startStopButton;
var UWindowSmallButton resetButton;
var NexgenPlayerListBox playerList;
var UWindowEditControl tagInp[4];
var UWindowEditControl numGamesInp;
var UWindowEditControl currGameInp;
var UWindowEditControl passwordInp;
var UWindowCheckbox specNeedNoPWInp;
var UWindowCheckbox muteSpecsInp;
var UWindowCheckbox enableBootControlInp;
var UWindowCheckbox autoLockInp;
var UWindowCheckbox autoPauseInp;
var UWindowCheckbox autoSeperateInp;
var UWindowSmallButton separateButton;
var UWindowSmallButton sendPasswordButton;

const numTeams = 4;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local NexgenPlayerList playerItem;
	local NexgenContentPanel p;
	local int region;
	local int index;
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionV(192, defaultComponentDist, , true);
	p = addContentPanel();
	
	// Match settings.
	p.splitRegionH(144, defaultComponentDist);
	p.splitRegionH(16);
	region = p.currRegion;
	p.skipRegion();
	p.addLabel(client.lng.matchSettingsTxt, true, TA_Center);
	p.divideRegionH(7);
	p.divideRegionV(2);
	p.splitRegionV(96);
	specNeedNoPWInp = p.addCheckBox(, client.lng.matchSpecNoPassTxt);
	muteSpecsInp = p.addCheckBox(, client.lng.matchMuteSpecsTxt);
	enableBootControlInp = p.addCheckBox(, client.lng.matchBootControlTxt);
	autoLockInp = p.addCheckBox(, client.lng.matchAutoLockTeamsTxt);
	autoPauseInp = p.addCheckBox(, client.lng.matchAutoPauseTxt);
	//p.addCheckBox(, "Automatically take a screenshot at the end of each game"); // Should be a client option!
	p.splitRegionV(96);
	p.splitRegionV(96);
	p.addLabel(client.lng.passwordTxt);
	passwordInp = p.addEditBox();
	p.addLabel(client.lng.matchNumOfGamesTxt);
	numGamesInp = p.addEditBox(, 48, AL_Left);
	p.addLabel(client.lng.matchCurrGameNumTxt);
	currGameInp = p.addEditBox(, 48, AL_Left);
	
	// Separate by tag settings.
	p.selectRegion(region);
	p.selectRegion(p.splitRegionH(72, defaultComponentDist));
	p.splitRegionH(1);
	region = p.currRegion;
	p.skipRegion();
	p.addComponent(class'NexgenDummyComponent');
	p.splitRegionH(16);
	p.addLabel(client.lng.matchSeparateByTagTxt, true, TA_Center);
	p.splitRegionH(16, defaultComponentDist, , true);
	p.divideRegionH(2);
	p.splitRegionV(20);
	p.divideRegionV(numTeams);
	p.divideRegionV(numTeams);
	autoSeperateInp = p.addCheckBox(TA_Right);
	p.splitRegionV(192);
	for (index = 0; index < numTeams; index++) {
		p.addLabel(client.lng.getTeamName(index), , TA_Center);
	}
	for (index = 0; index < numTeams; index++) {
		tagInp[index] = p.addEditBox(, 64, AL_Center);
		tagInp[index].setMaxLength(16);
	}
	p.addLabel(client.lng.matchAutoTagSeparateTxt);
	p.splitRegionV(80, , , true);
	p.skipRegion();
	separateButton = p.addButton(client.lng.matchDoSeparateTxt);
	
	// Match setup control buttons.
	p.selectRegion(region);
	p.selectRegion(p.splitRegionH(1));
	p.addComponent(class'NexgenDummyComponent');
	p.splitRegionH(16, , , true);
	p.skipRegion();
	p.divideRegionV(3, defaultComponentDist);
	saveButton = p.addButton(client.lng.saveTxt);
	startStopButton = p.addButton();
	resetButton = p.addButton(client.lng.resetTxt);
	
	// Send password to.
	splitRegionH(16, defaultComponentDist, , true);
	playerList = NexgenPlayerListBox(addListBox(class'NexgenSimplePlayerListBox'));
	sendPasswordButton = addButton(client.lng.sendPasswordTxt);
	
	// Configure components.
	numGamesInp.setNumericOnly(true);
	numGamesInp.setMaxLength(2);
	currGameInp.setNumericOnly(true);
	currGameInp.setMaxLength(2);
	passwordInp.setMaxLength(32);
	playerItem = playerList.addPlayer();
	playerItem.pNum = -1;
	playerItem.pName = client.lng.allPlayersTxt;
	playerItem.pTeam = 4;
	separateButton.bDisabled = !client.player.gameReplicationInfo.bTeamGame;
	saveButton.register(self);
	startStopButton.register(self);
	resetButton.register(self);
	separateButton.register(self);
	playerList.register(self);
	sendPasswordButton.register(self);
	numGamesInp.register(self);
	currGameInp.register(self);
	passwordInp.register(self);
	specNeedNoPWInp.register(self);
	muteSpecsInp.register(self);
	enableBootControlInp.register(self);
	autoLockInp.register(self);
	autoPauseInp.register(self);
	autoSeperateInp.register(self);
	for (index = 0; index < numTeams; index++) {
		tagInp[index].register(self);
	}
	loadMatchSettings();
	playerSelected();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the match settings.
 *
 **************************************************************************************************/
function loadMatchSettings() {
	local int index;
	
	numGamesInp.setValue(string(client.sConf.matchesToPlay));
	currGameInp.setValue(string(client.sConf.currentMatch));
	passwordInp.setValue(client.sConf.decode(client.sConf.CS_MatchSettings, client.sConf.serverPassword));
	specNeedNoPWInp.bChecked = !client.sConf.spectatorsNeedPassword;
	muteSpecsInp.bChecked = client.sConf.muteSpectatorsDuringMatch;
	enableBootControlInp.bChecked = client.sConf.enableMatchBootControl;
	autoLockInp.bChecked = client.sConf.matchAutoLockTeams;
	autoPauseInp.bChecked = client.sConf.matchAutoPause;
	autoSeperateInp.bChecked = client.sConf.matchAutoSeparate;
	for (index = 0; index < numTeams; index++) {
		tagInp[index].setValue(client.sConf.tagsToSeparate[index]);
	}
	if (client.sConf.matchModeActivated) {
		startStopButton.setText(client.lng.stopMatchTxt);
	} else {
		startStopButton.setText(client.lng.startMatchTxt);
	}
	startStopButton.bDisabled = false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player was selected from the list.
 *
 **************************************************************************************************/
function playerSelected() {
	sendPasswordButton.bDisabled = playerList.selectedItem == none;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Separates the players by the currently entered tags.
 *
 **************************************************************************************************/
function separatePlayers() {
	// Make sure the RPC interface is available.
	if (!setRPCI()) return;
	
	// Separate players.
	rpci.separatePlayers(class'NexgenUtil'.static.trim(tagInp[0].getValue()),
	                     class'NexgenUtil'.static.trim(tagInp[1].getValue()),
	                     class'NexgenUtil'.static.trim(tagInp[2].getValue()),
	                     class'NexgenUtil'.static.trim(tagInp[3].getValue()));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the password to the currently selected player.
 *
 **************************************************************************************************/
function sendPassword() {
	// Make sure the RPC interface is available.
	if (!setRPCI()) return;
	
	// Send password.
	rpci.sendPassword(NexgenPlayerList(playerList.selectedItem).pNum,
	                  class'NexgenUtil'.static.trim(passwordInp.getValue()));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the current match settings to the server.
 *
 **************************************************************************************************/
function saveSettings() {
	local string teamTags[4];
	local int index;
	
	// Make sure the RPC interface is available.
	if (!setRPCI()) return;
	
	// Get tags.
	for (index = 0; index < numTeams; index++) {
		teamTags[index] = class'NexgenUtil'.static.trim(tagInp[index].getValue());
	}
	
	// Update settings.
	rpci.updateMatchSettings(int(numGamesInp.getValue()), int(currGameInp.getValue()),
	                         passwordInp.getValue(), !specNeedNoPWInp.bChecked,
	                         muteSpecsInp.bChecked, enableBootControlInp.bChecked,
	                         autoLockInp.bChecked, autoPauseInp.bChecked, autoSeperateInp.bChecked,
	                         teamTags[0], teamTags[1], teamTags[2], teamTags[3]);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Starts / stops the match.
 *
 **************************************************************************************************/
function toggleMatchMode() {
	// Make sure the RPC interface is available.
	if (!setRPCI()) return;
	
	// Start / stop match.
	rpci.toggleMatchMode();
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
			case resetButton: loadMatchSettings(); break;
			case saveButton: saveSettings(); break;
			case separateButton: separatePlayers(); break;
			case sendPasswordButton: sendPassword(); break;
			case startStopButton: toggleMatchMode(); break;
		}
	}
	
	// Player selected?
	if (control == playerList && eventType == DE_Click) {
		playerSelected();
	}
	
	// Check if some settings were changed.
	if (eventType == DE_Change && !client.sConf.matchModeActivated && control != none &&
	    (control.isA('UWindowEditControl') || control.isA('UWindowCheckbox'))) {
		startStopButton.bDisabled = true;
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
	if (configType == client.sConf.CT_MatchSettings) {
		loadMatchSettings();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="matchsetup"
}
