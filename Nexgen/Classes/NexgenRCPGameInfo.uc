/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPGameInfo
 *  $VERSION      1.04 (6-11-2007 11:49)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen game information overview control panel page.
 *
 **************************************************************************************************/
class NexgenRCPGameInfo extends NexgenPanel;

var NexgenPlayerListBox playerList;
var NexgenSimpleListBox mutatorList;
var UMenuLabelControl timeLimitLabel;
var UMenuLabelControl fragLimitLabel;
var UMenuLabelControl teamScoreLimitLabel;
var UMenuLabelControl gameSpeedLabel;
var UWindowCheckbox enableTeamSwitchInp;
var UWindowCheckbox enableTeamBalanceInp;
var UWindowCheckbox teamsLockedInp;
var UWindowCheckbox allowNameChangeInp;
var UMenuLabelControl fileLabel;
var UMenuLabelControl titleLabel;
var UMenuLabelControl authorLabel;
var UMenuLabelControl playersLabel;



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
	divideRegionV(2, defaultComponentDist);
	splitRegionH(160, defaultComponentDist);
	splitRegionH(96, defaultComponentDist);
	splitRegionH(16);
	splitRegionH(16);
	splitRegionH(16);
	splitRegionH(16);
	
	// Game info.
	addLabel(client.player.gameReplicationInfo.gameName, true, TA_Center);
	p = addContentPanel();
	p.splitRegionV(200/3, , true);
	p.divideRegionH(8);
	p.divideRegionH(8);
	p.addLabel(client.lng.timeLimitTxt, true);
	p.addLabel(client.lng.scoreLimitTxt, true);
	p.addLabel(client.lng.teamScoreLimitTxt, true);
	p.addLabel(client.lng.gameSpeedTxt, true);
	p.addLabel(client.lng.teamSwitchEnabledTxt, true);
	p.addLabel(client.lng.teamBalanceEnabledTxt, true);
	p.addLabel(client.lng.teamsLockedTxt, true);
	p.addLabel(client.lng.nameChangeAllowedTxt, true);
	timeLimitLabel = p.addLabel();
	fragLimitLabel = p.addLabel();
	teamScoreLimitLabel = p.addLabel();
	gameSpeedLabel = p.addLabel();
	enableTeamSwitchInp = p.addCheckBox(TA_right);
	enableTeamBalanceInp = p.addCheckBox(TA_right);
	teamsLockedInp = p.addCheckBox(TA_right);
	allowNameChangeInp = p.addCheckBox(TA_right);
	
	// Mutators.
	addLabel(client.lng.mutatorsTxt, true, TA_Center);
	mutatorList = NexgenSimpleListBox(addListBox(class'NexgenSimpleListBox'));
	
	// Level info.
	addLabel(client.lng.levelTxt, true, TA_Center);
	p = addContentPanel();
	p.splitRegionV(72, defaultComponentDist);
	if (client.player.level.screenshot == none) {
		p.addComponent(class'NexgenDummyComponent', 64, 64, AL_Center, AL_Center);
	} else {
		p.addImageBox(client.player.level.screenshot, true, 64, 64);
	}
	p.splitRegionV(48);
	p.divideRegionH(4);
	p.divideRegionH(4);
	p.addLabel(client.lng.fileTxt, true);
	p.addLabel(client.lng.titleTxt, true);
	p.addLabel(client.lng.authorTxt, true);
	p.addLabel(client.lng.idealPlayerCountTxt, true);
	fileLabel = p.addLabel();
	titleLabel = p.addLabel();
	authorLabel = p.addLabel();
	playersLabel = p.addLabel();
	
	// Player info.
	addLabel(client.lng.playerListTxt, true, TA_Center);
	playerList = NexgenPlayerListBox(addListBox(class'NexgenPlayerListBox'));
	
	// Configure components.
	enableTeamSwitchInp.bDisabled = true;
	enableTeamBalanceInp.bDisabled = true;
	teamsLockedInp.bDisabled = true;
	allowNameChangeInp.bDisabled = true;
	setGameInfo();
	setLevelInfo();
	loadMutatorList();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of the game info labels.
 *
 **************************************************************************************************/
function setGameInfo() {
	local GameReplicationInfo GRI;
	local TournamentGameReplicationInfo TGRI;
	
	GRI = client.player.gameReplicationInfo;
	TGRI = TournamentGameReplicationInfo(GRI);
	
	if (TGRI != none) {
		timeLimitLabel.setText(string(TGRI.timeLimit));
		fragLimitLabel.setText(string(TGRI.fragLimit));
		teamScoreLimitLabel.setText(string(TGRI.goalTeamScore));
	}
	gameSpeedLabel.setText(int(100.0 * client.gInf.gameSpeed) $ "%");
	enableTeamSwitchInp.bChecked = !client.gInf.bNoTeamSwitch;
	enableTeamBalanceInp.bChecked = !client.gInf.bNoTeamBalance;
	teamsLockedInp.bChecked = client.gInf.bTeamsLocked;
	allowNameChangeInp.bChecked = !client.gInf.bNoNameChange;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of the level info labels.
 *
 **************************************************************************************************/
function setLevelInfo() {
	local string levelFile;
	
	levelFile = string(client);
	levelFile = left(levelFile, instr(levelFile, ".")) $ ".unr";
	fileLabel.setText(levelFile);
	titleLabel.setText(client.player.level.summary.title);
	authorLabel.setText(client.player.level.summary.author);
	playersLabel.setText(client.player.level.summary.idealPlayerCount);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the list of active mutators.
 *
 **************************************************************************************************/
function loadMutatorList() {
	local NexgenSimpleListItem item;
	local string remaining;
	local string mutatorIndex;
	local string mutatorInfo;
	local string mutatorClass;
	local string mutatorName;
	
	// For each mutator index..
	remaining = client.sConf.activeMutatorIndices;
	while (remaining != "") {
		// Get index.
		class'NexgenUtil'.static.split(remaining, mutatorIndex, remaining);
		
		// Get mutator info.
		mutatorInfo = client.sConf.mutatorInfo[int(mutatorIndex)];
		class'NexgenUtil'.static.split(mutatorInfo, mutatorClass, mutatorName);
		
		// Add mutator to the list.
		item = NexgenSimpleListItem(mutatorList.items.append(class'NexgenSimpleListItem'));
		item.displayText = mutatorName;
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
	}
	
	// Attribute changed?
	if (eventType == client.PE_AttributeChanged) {
		updatePlayerInfo(playerList, playerNum, args);
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
		setGameInfo();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="gameinfo"
}
