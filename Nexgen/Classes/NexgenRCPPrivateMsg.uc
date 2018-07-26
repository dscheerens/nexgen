/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPPrivateMsg
 *  $VERSION      1.03 (21-10-2007 14:38)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen private message system control panel page.
 *
 **************************************************************************************************/
class NexgenRCPPrivateMsg extends NexgenPanel;

var NexgenClientCore rpci;

var UWindowDynamicTextArea history;
var NexgenSimplePlayerListBox playerList;
var NexgenSimplePlayerListBox blockedPlayerList;
var UWindowSmallButton blockToggleButton;
var UWindowSmallButton sendNormalButton;
var UWindowSmallButton sendWindowedButton;
var UWindowEditControl msgInp;
var UWindowCheckbox blockAllInp;


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
	
	// Player / blocked player list.
	p = addContentPanel();
	p.divideRegionH(2, defaultComponentDist);
	p.splitRegionH(16);
	p.splitRegionH(16);
	p.addLabel(client.lng.playerListTxt, true, TA_Center);
	playerList = NexgenSimplePlayerListBox(p.addListBox(class'NexgenSimplePlayerListBox'));
	p.addLabel(client.lng.blockedListTxt, true, TA_Center);
	p.splitRegionH(32, defaultComponentDist, , true);
	blockedPlayerList = NexgenSimplePlayerListBox(p.addListBox(class'NexgenSimplePlayerListBox'));
	p.divideRegionH(2);
	blockToggleButton = p.addButton(client.lng.blockToggleTxt);
	blockAllInp = p.addCheckBox(TA_Left, client.lng.blockAllPMsTxt);
	
	// 'Say' panel.
	splitRegionH(64, defaultComponentDist);
	p = addContentPanel();
	p.divideRegionH(3, defaultComponentDist);
	p.addLabel(client.lng.messageTxt, true, TA_Center);
	msgInp = p.addEditbox();
	p.splitRegionV(256);
	p.divideRegionV(2, defaultComponentDist);
	p.skipRegion();
	sendNormalButton = p.addButton(client.lng.sendNormalPMTxt);
	sendWindowedButton = p.addButton(client.lng.sendWindowedPMTxt);

	// History panel.
	p = addContentPanel();
	p.splitRegionH(16);
	p.addLabel(client.lng.historyTxt, true, TA_Center);
	history = p.addDynamicTextArea();
	
	// Configure components.
	playerList.register(self);
	blockedPlayerList.register(self);
	blockToggleButton.register(self);
	blockAllInp.register(self);
	sendNormalButton.register(self);
	sendWindowedButton.register(self);
	sendWindowedButton.bDisabled = !client.hasRight(client.R_Moderate);
	msgInp.register(self);
	msgInp.setMaxLength(255);
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
 *  $DESCRIPTION  Notifies the client of a player event. Additional arguments to the event should be
 *                combined into one string which then can be send along with the playerEvent call.
 *  $PARAM        playerNum  Player identification number.
 *  $PARAM        eventType  Type of event that has occurred.
 *  $PARAM        args       Optional arguments.
 *  $REQUIRE      playerNum >= 0
 *
 **************************************************************************************************/
function playerEvent(int playerNum, string eventType, optional string args) {
	
	// Make sure the RPC interface is available.
	setRPCI();
	
	// Player has joined the game?
	if (eventType == client.PE_PlayerJoined) {
		if (rpci != none && rpci.isBlocked(class'NexgenUtil'.static.getProperty(args, client.PA_ClientID))) {
			addPlayerToList(blockedPlayerList, playerNum, args);
		} else {
			addPlayerToList(playerList, playerNum, args);
		}
	}
	
	// Player has left the game?
	if (eventType == client.PE_PlayerLeft) {
		playerList.removePlayer(playerNum);
		blockedPlayerList.removePlayer(playerNum);
	}
	
	// Attribute changed?
	if (eventType == client.PE_AttributeChanged) {
		updatePlayerInfo(playerList, playerNum, args);
		updatePlayerInfo(blockedPlayerList, playerNum, args);
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
	local NexgenPlayerList selected;
	
	setRPCI();
	
	// Block all clicked.
	if (control == blockAllInp && eventType == DE_Click && rpci != none) {
		rpci.bBlockAll = blockAllInp.bChecked;
	}
	
	// Send normal clicked.
	if (control == sendNormalButton && eventType == DE_Click) {
		sendMessage(false);
	}

	// Enter button pressed on message edit box.
	if (control == msgInp && eventType == DE_EnterPressed) {
		sendMessage(false);
	}	
	
	// Send windowed clicked.
	if (control == sendWindowedButton && eventType == DE_Click && !sendWindowedButton.bDisabled) {
		sendMessage(true);
	}
	
	// Block / Unblock clicked.
	if (control == blockToggleButton && eventType == DE_Click && rpci != none) {
		if (playerList.selectedItem != none) {
			selected = NexgenPlayerList(playerList.selectedItem);
			rpci.blockPlayer(selected.pClientID);
			addHistoryMsg(client.lng.format(client.lng.blockMsg, selected.pName));
			playerList.moveSelectedPlayerTo(blockedPlayerList);
		} else if (blockedPlayerList.selectedItem != none) {
			selected = NexgenPlayerList(blockedPlayerList.selectedItem);
			rpci.unblockPlayer(selected.pClientID);
			addHistoryMsg(client.lng.format(client.lng.unblockMsg, selected.pName));
			blockedPlayerList.moveSelectedPlayerTo(playerList);
		}
	}
	
	// Unblocked player selected.
	if (control == playerList && eventType == DE_Click) {
		if (blockedPlayerList.selectedItem != none) {
			blockedPlayerList.selectedItem.bSelected = false;
			blockedPlayerList.selectedItem = none;
		}
	}
	
	// Blocked player selected.
	if (control == blockedPlayerList && eventType == DE_Click) {
		if (playerList.selectedItem != none) {
			playerList.selectedItem.bSelected = false;
			playerList.selectedItem = none;
		}
	}
	
	// Double click on unblocked player -> block that player.
	if (control == playerList && eventType == DE_DoubleClick && playerList.selectedItem != none && rpci != none) {
		selected = NexgenPlayerList(playerList.selectedItem);
		rpci.blockPlayer(selected.pClientID);
		addHistoryMsg(client.lng.format(client.lng.blockMsg, selected.pName));
		playerList.moveSelectedPlayerTo(blockedPlayerList);
	}
	
	// Double click on blocked player -> unblock that player.
	if (control == blockedPlayerList && eventType == DE_DoubleClick && blockedPlayerList.selectedItem != none && rpci != none) {
		selected = NexgenPlayerList(blockedPlayerList.selectedItem);
		rpci.unblockPlayer(selected.pClientID);
		addHistoryMsg(client.lng.format(client.lng.unblockMsg, selected.pName));
		blockedPlayerList.moveSelectedPlayerTo(playerList);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new message to the to message history box.
 *  $PARAM        msg  The message to add.
 *
 **************************************************************************************************/
function addHistoryMsg(string msg) {
	local string timeStamp;
	
	timeStamp = "[" $ right("0" $ client.level.hour, 2) $ ":" $ right("0" $ client.level.minute, 2) $ "]";
	history.addText(timeStamp @ msg);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Send the currently enterted message to the selected player.
 *  $PARAM        bWindowed  Whether the message to send should popup in a window.
 *
 **************************************************************************************************/
function sendMessage(optional bool bWindowed) {
	local NexgenPlayerList selectedPlayer;
	
	// Make sure the RPC interface is available.
	if (rpci == none) return;
	
	// Get selected player.
	if (playerList.selectedItem != none) {
		selectedPlayer = NexgenPlayerList(playerList.selectedItem);
	} else if (blockedPlayerList.selectedItem != none) {
		selectedPlayer = NexgenPlayerList(blockedPlayerList.selectedItem);
	}
	
	// Send message.
	if (selectedPlayer != none && msgInp.getValue() != "" && !client.isMuted() &&
	    
	    !( // Spectators muted during matches?
	    client.sConf.matchModeActivated && client.sConf.muteSpectatorsDuringMatch &&
	    client.gInf.gameState == client.gInf.GS_Playing &&
	    client.bSpectator && !selectedPlayer.isSpectator() &&
	    !client.hasRight(client.R_MatchAdmin) && !client.hasRight(client.R_Moderate)
	    )
	    
	    ) {
	    	
		addHistoryMsg(client.lng.format(client.lng.sendMsgTxt, selectedPlayer.pName, msgInp.getValue()));
		rpci.sendPM(selectedPlayer.pNum, msgInp.getValue(), bWindowed);
		msgInp.setValue("");
	}
	
	// $TODO Play sound on error.
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a new private message was received. Adds the received message to the
 *                chat history.
 *  $PARAM        msg  The message that was received.
 *  $PARAM        pri  Player replication info actor of the player that has send the message.
 *  $REQUIRE      pri != none
 *
 **************************************************************************************************/
function receiveMessage(string msg, PlayerReplicationInfo pri) {
	addHistoryMsg(client.lng.format(client.lng.receivedMsgTxt, pri.playerName, msg));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="privatemsg"
}
