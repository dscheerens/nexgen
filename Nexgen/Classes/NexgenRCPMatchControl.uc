/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPMatchControl
 *  $VERSION      1.05 (15-03-2010 12:57)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen match control panel page.
 *
 **************************************************************************************************/
class NexgenRCPMatchControl extends NexgenPanel;

var NexgenClientCore rpci;                        // Remote Procedure Call interface.

var NexgenPlayerListBox playerList;
var UWindowSmallButton teamButtons[4];
var UWindowSmallButton startButton;
var UWindowSmallButton pauseButton;
var UWindowSmallButton endButton;
var UWindowSmallButton restartButton;
var UWindowSmallButton sendToURLButton;
var UWindowSmallButton reconnectAsPlayerButton;
var UWindowSmallButton reconnectAsSpecButton;
var UWindowSmallButton disableTeamSwitchButton;
var UWindowEditControl urlInp;
var UWindowCheckbox allowTeamSwitchInp;
var UWindowCheckbox allowTeamBalanceInp;
var UWindowCheckbox lockTeamsInp;
var UWindowCheckbox tournamentModeInp;
var UWindowComboControl favouritesList;

var color teamColor[4];
var color defaultButtonColor;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local NexgenContentPanel p;
	local int index;
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionV(192, defaultComponentDist);
	playerList = NexgenPlayerListBox(addListBox(class'NexgenPlayerListBox'));
	splitRegionH(184, defaultComponentDist);
	
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
	
	// Global match controls.
	splitRegionV(140, defaultComponentDist);
	
	p = addContentPanel();
	p.divideRegionH(4);
	startButton = p.addButton(client.lng.startTxt);
	pauseButton = p.addButton(client.lng.pauseGameTxt);
	endButton = p.addButton(client.lng.endGameTxt);
	restartButton = p.addButton(client.lng.restartGameTxt);
	
	p = addContentPanel();
	p.divideRegionH(4);
	allowTeamSwitchInp = p.addCheckBox(TA_Left, client.lng.allowTeamSwitchTxt);
	allowTeamBalanceInp = p.addCheckBox(TA_Left, client.lng.allowTeamBalanceTxt);
	lockTeamsInp = p.addCheckBox(TA_Left, client.lng.lockTeamsTxt);
	tournamentModeInp = p.addCheckBox(TA_Left, client.lng.tournamentModeTxt);
	
	// Configure components.
	urlInp.setMaxLength(128);
	playerList.register(self);
	allowTeamSwitchInp.register(self);
	allowTeamBalanceInp.register(self);
	lockTeamsInp.register(self);
	tournamentModeInp.register(self);
	favouritesList.register(self);
	allowTeamSwitchInp.bDisabled = !client.player.gameReplicationInfo.bTeamGame;
	allowTeamBalanceInp.bDisabled = !client.player.gameReplicationInfo.bTeamGame;
	startButton.bDisabled = client.gInf.gameState > client.gInf.GS_Ready;
	playerSelected();
	setValues();
	loadFavourites();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current game info settings.
 *
 **************************************************************************************************/
function setValues() {
	allowTeamSwitchInp.bChecked = !client.gInf.bNoTeamSwitch;
	allowTeamBalanceInp.bChecked = !client.gInf.bNoTeamBalance;
	lockTeamsInp.bChecked = client.gInf.bTeamsLocked;
	tournamentModeInp.bChecked = client.gInf.bTournamentMode;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies this panel that the extended game info has been updated.
 *  $PARAM        infoType  Type of information that has been changed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function gameInfoChanged(byte infoType) {
	if (infoType == client.gInf.IT_GlobalRights ||
	    infoType == client.gInf.IT_GameSettings) {
		setValues();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player was selected from the list.
 *
 **************************************************************************************************/
function playerSelected() {
	local NexgenPlayerList player;
	local int index;
	local bool bTeamGame;
	
	// Get selected player.
	player = NexgenPlayerList(playerList.selectedItem);
	
	// Determine which buttons can be used.
	bTeamGame = client.player.gameReplicationInfo.bTeamGame;
	if (player == none) {
		for (index = 0; index < arrayCount(teamButtons); index++) {
			teamButtons[index].bDisabled = true;
			teamButtons[index].setTextColor(defaultButtonColor);
		}
		sendToURLButton.bDisabled = true;
		reconnectAsPlayerButton.bDisabled = true;
		reconnectAsSpecButton.bDisabled = true;
		disableTeamSwitchButton.bDisabled = true;
	} else {
		for (index = 0; index < arrayCount(teamButtons); index++) {
			teamButtons[index].bDisabled = !bTeamGame || player.isSpectator() || 
			                               index == player.pTeam || index >= client.gInf.maxTeams;
			if (teamButtons[index].bDisabled) {
				teamButtons[index].setTextColor(defaultButtonColor);
			} else {
				teamButtons[index].setTextColor(teamColor[index]);
			}
		}
		sendToURLButton.bDisabled = false;
		reconnectAsPlayerButton.bDisabled = !player.isSpectator();
		reconnectAsSpecButton.bDisabled = player.isSpectator();
		disableTeamSwitchButton.bDisabled = player.isSpectator() || !bTeamGame;
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
	
	setRPCI();
	
	// Button pressed?
	if (control != none && eventType == DE_Click && control.isA('UWindowSmallButton') &&
	    !UWindowSmallButton(control).bDisabled && rpci != none) {
	
		switch (control) {
			case startButton:
				rpci.forceStartGame();
				break;
				
			case pauseButton:
				rpci.pauseGame();
				break;
				
			case endButton:
				rpci.endGame();
				break;
				
			case restartButton:
				rpci.restartGame();
				break;
				
			case teamButtons[0]:
				rpci.setPlayerTeam(NexgenPlayerList(playerList.selectedItem).pNum, 0);
				break;
				
			case teamButtons[1]:
				rpci.setPlayerTeam(NexgenPlayerList(playerList.selectedItem).pNum, 1);
				break;
				
			case teamButtons[2]:
				rpci.setPlayerTeam(NexgenPlayerList(playerList.selectedItem).pNum, 2);
				break;
				
			case teamButtons[3]:
				rpci.setPlayerTeam(NexgenPlayerList(playerList.selectedItem).pNum, 3);
				break;
			
			case disableTeamSwitchButton:
				rpci.toggleTeamSwitch(NexgenPlayerList(playerList.selectedItem).pNum);
				break;
			
			case reconnectAsPlayerButton:
				rpci.reconnectPlayer(NexgenPlayerList(playerList.selectedItem).pNum, false);
				break;
				
			case reconnectAsSpecButton:
				rpci.reconnectPlayer(NexgenPlayerList(playerList.selectedItem).pNum, true);
				break;
			
			case sendToURLButton:
				rpci.sendPlayerToURL(NexgenPlayerList(playerList.selectedItem).pNum,
				                     class'NexgenUtil'.static.trim(urlInp.getValue()));
				break;
		}
	}
	
	// Checkbox pressed?
	if (control != none && eventType == DE_Click && control.isA('UWindowCheckbox') &&
	    !UWindowCheckbox(control).bDisabled && rpci != none) {
		
		switch (control) {
			case allowTeamSwitchInp:
				rpci.toggleGlobalTeamSwitch();
				break;

			case allowTeamBalanceInp:
				rpci.toggleGlobalTeamBalance();
				break;
				
			case lockTeamsInp:
				rpci.toggleLockedTeams();
				break;
				
			case tournamentModeInp:
				rpci.toggleGlobalTournamentMode();
				break;
		}
	}
	
	// Player selected?
	if (control == playerList && eventType == DE_Click) {
		playerSelected();
	}
	
	// Server selected?
	if (control == favouritesList && eventType == DE_Change) {
		serverSelected();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Load the favourites from this client.
 *
 **************************************************************************************************/
function loadFavourites() {
	local int index;
	local int favsCount;
	local string favStr;
	local string serverName;
	local string serverIP;
	local string serverPort;
	
	// Get current favorites.
	favsCount = class'UBrowserFavoritesFact'.default.favoriteCount;
	for (index = 0; index < favsCount; index++) {
		favStr = class'UBrowserFavoritesFact'.default.favorites[index];
		class'NexgenUtil'.static.split2(favStr, serverName, favStr, "\\");
		class'NexgenUtil'.static.split2(favStr, serverIP, favStr, "\\");
		class'NexgenUtil'.static.split2(favStr, serverPort, favStr, "\\");
		serverName = class'NexgenUtil'.static.trim(serverName);
		if (serverName != "") {
			favouritesList.addItem(serverName, "unreal://" $ serverIP $ ":" $ (int(serverPort) - 1));
		}
	}
	favouritesList.addItem("", "");
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a server has been selected from the favourites list..
 *
 **************************************************************************************************/
function serverSelected() {
	urlInp.setValue(favouritesList.getValue2());
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	teamColor(0)=(r=200,g=000,b=000)
	teamColor(1)=(r=000,g=000,b=200)
	teamColor(2)=(r=000,g=100,b=000)
	teamColor(3)=(r=250,g=250,b=000)
	defaultButtonColor=(r=000,g=000,b=000)
	panelIdentifier="matchcontrol"
}
