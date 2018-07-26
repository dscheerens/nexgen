/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXRCPMatchControl
 *  $VERSION      1.05 (15-03-2010 13:15)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen match control panel page.
 *
 **************************************************************************************************/
class NexgenXRCPMatchControl extends NexgenRCPMatchControl;

var NexgenXClient xClient;

var NexgenEditControl timeLimitInp;
var NexgenEditControl scoreLimitInp;
var NexgenEditControl teamScoreLimitInp;
var NexgenEditControl gameSpeedInp;
var NexgenEditControl remainingTimeInp;

var UWindowSmallButton setTimeLimitButton;
var UWindowSmallButton setScoreLimitButton;
var UWindowSmallButton setTeamScoreLimitButton;
var UWindowSmallButton setGameSpeedButton;
var UWindowSmallButton setRemainingTimeButton;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local NexgenContentPanel p;
	local int index;
	
	xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionH(170, defaultComponentDist);
	splitRegionV(192, defaultComponentDist);
	divideRegionV(3, defaultComponentDist);
	
	// Player list.
	playerList = NexgenPlayerListBox(addListBox(class'NexgenPlayerListBox'));
	
	// Player controls.
	p = addContentPanel();
	p.splitRegionV(128, defaultComponentDist);
	p.divideRegionH(8);
	p.divideRegionH(8);
	for (index = 0; index < arrayCount(teamButtons); index++) {
		teamButtons[index] = p.addButton(client.lng.format(client.lng.switchToTeamTxt, client.lng.getTeamName(index)));
	}
	sendToURLButton = p.addButton(client.lng.sendToURLTxt);
	reconnectAsPlayerButton = p.addButton(client.lng.reconnectAsPlayerTxt);
	reconnectAsSpecButton = p.addButton(client.lng.reconnectAsSpecTxt);
	disableTeamSwitchButton = p.addButton(client.lng.disableTeamSwitchTxt);
	p.skipRegion();
	p.skipRegion();
	p.skipRegion();
	favouritesList = p.addListCombo();
	urlInp = p.addEditBox();
	
	// Match controls 1.
	p = addContentPanel();
	p.splitRegionV(80, , , true);
	p.divideRegionH(5);
	p.splitRegionV(40, defaultComponentDist);
	p.addLabel(client.lng.timeLimitTxt);
	p.addLabel(client.lng.scoreLimitTxt);
	p.addLabel(client.lng.teamScoreLimitTxt);
	p.addLabel(client.lng.gameSpeedTxt);
	p.addLabel(xClient.lng.remainingTimeTxt);
	p.divideRegionH(5);
	p.divideRegionH(5);
	timeLimitInp = p.addEditBox();
	scoreLimitInp = p.addEditBox();
	teamScoreLimitInp = p.addEditBox();
	gameSpeedInp = p.addEditBox();
	remainingTimeInp = p.addEditBox();
	setTimeLimitButton = p.addButton(xClient.lng.setButtonTxt);
	setScoreLimitButton = p.addButton(xClient.lng.setButtonTxt);
	setTeamScoreLimitButton = p.addButton(xClient.lng.setButtonTxt);
	setGameSpeedButton = p.addButton(xClient.lng.setButtonTxt);
	setRemainingTimeButton = p.addButton(xClient.lng.setButtonTxt);
	
	// Match controls 2.
	p = addContentPanel();
	p.divideRegionH(5);
	startButton = p.addButton(client.lng.startTxt);
	pauseButton = p.addButton(client.lng.pauseGameTxt);
	endButton = p.addButton(client.lng.endGameTxt);
	restartButton = p.addButton(client.lng.restartGameTxt);
	
	// Match controls 3.
	p = addContentPanel();
	p.divideRegionH(5);
	allowTeamSwitchInp = p.addCheckBox(TA_Left, client.lng.allowTeamSwitchTxt);
	allowTeamBalanceInp = p.addCheckBox(TA_Left, client.lng.allowTeamBalanceTxt);
	lockTeamsInp = p.addCheckBox(TA_Left, client.lng.lockTeamsTxt);
	tournamentModeInp = p.addCheckBox(TA_Left, client.lng.tournamentModeTxt);
	
	// Configure components.
	timeLimitInp.setNumericOnly(true);
	scoreLimitInp.setNumericOnly(true);
	teamScoreLimitInp.setNumericOnly(true);
	gameSpeedInp.setNumericOnly(true);
	
	timeLimitInp.setMaxLength(3);
	scoreLimitInp.setMaxLength(5);
	teamScoreLimitInp.setMaxLength(5);
	gameSpeedInp.setMaxLength(3);
	remainingTimeInp.setMaxLength(5);
	
	remainingTimeInp.setValue("5:00");

	urlInp.setMaxLength(128);
	playerList.register(self);
	allowTeamSwitchInp.register(self);
	allowTeamBalanceInp.register(self);
	lockTeamsInp.register(self);
	tournamentModeInp.register(self);
	favouritesList.register(self);
	allowTeamSwitchInp.bDisabled = !client.player.gameReplicationInfo.bTeamGame;
	allowTeamBalanceInp.bDisabled = !client.player.gameReplicationInfo.bTeamGame;
	playerSelected();
	setValues();
	setGameInfo();
	loadFavourites();
	if (!client.hasRight(client.R_MatchSet)) {
		disableSpecialMatchControls();
	}
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
		timeLimitInp.setValue(string(TGRI.timeLimit));
		scoreLimitInp.setValue(string(TGRI.fragLimit));
		teamScoreLimitInp.setValue(string(TGRI.goalTeamScore));
	}
	gameSpeedInp.setValue(string(int(100.0 * client.gInf.gameSpeed)));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Disables the special match controls, which are only available to certain admins.
 *
 **************************************************************************************************/
function disableSpecialMatchControls() {
	timeLimitInp.setDisabled(true);
	scoreLimitInp.setDisabled(true);
	teamScoreLimitInp.setDisabled(true);
	gameSpeedInp.setDisabled(true);
	
	setTimeLimitButton.bDisabled = true;
	setScoreLimitButton.bDisabled = true;
	setTeamScoreLimitButton.bDisabled = true;
	setGameSpeedButton.bDisabled = true;
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
			case setTimeLimitButton:
				xClient.setTimeLimit(int(timeLimitInp.getValue()));
				break;

			case setScoreLimitButton:
				xClient.setScoreLimit(int(scoreLimitInp.getValue()));
				break;
				
			case setTeamScoreLimitButton:
				xClient.setTeamScoreLimit(int(teamScoreLimitInp.getValue()));
				break;
				
			case setGameSpeedButton:
				xClient.setGameSpeed(int(gameSpeedInp.getValue()));
				break;
				
			case setRemainingTimeButton:
				xClient.setRemainingTime(remainingTimeInp.getValue());
				break;
		}
	}
}