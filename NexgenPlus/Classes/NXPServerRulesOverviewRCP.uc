/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPServerRulesOverviewRCP
 *  $VERSION      1.02 (9-8-2008 12:59)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Server rules listing tab.
 *
 **************************************************************************************************/
class NXPServerRulesOverviewRCP extends NexgenPanel;

var NXPClient xClient;

var UMenuLabelControl rulesTitleLabel;
var UMenuLabelControl rules[10];
var NexgenPlayerListBox playerList;
var UWindowSmallButton showRulesButton;
var UWindowEditControl showReasonInp;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	local NexgenContentPanel p;
	local bool bShowAdminControls;
	local int index;
	
	xClient = NXPClient(client.getController(class'NXPClient'.default.ctrlID));
	
	bShowAdminControls = client.hasRight(client.R_Moderate);
	
	// Create layout & add components.
	createWindowRootRegion();
	
	if (bShowAdminControls) {
		splitRegionV(160, defaultComponentDist, , true);
		
		splitRegionH(16, defaultComponentDist, , true);
		splitRegionH(16, defaultComponentDist, , true);
		
		splitRegionH(32, defaultComponentDist);
		splitRegionV(140);
		
		playerList = NexgenPlayerListBox(addListBox(class'NexgenSimplePlayerListBox'));
		showRulesButton = addButton(xClient.lng.forceClientViewRulesTxt);
		
		p = addContentPanel();
		rulesTitleLabel = p.addLabel(xClient.lng.serverRulesTabTitle, true, TA_Center);
		p = addContentPanel();
		
		addLabel(xClient.lng.forceClientViewRulesReasonTxt, true);
		showReasonInp = addEditBox();
		showReasonInp.setMaxLength(100);
	} else {
		splitRegionH(32, defaultComponentDist);
		p = addContentPanel();
		rulesTitleLabel = p.addLabel(xClient.lng.serverRulesTabTitle, true, TA_Center);
		p = addContentPanel();
	}
	
	// Create rules panel.
	p.divideRegionH(arrayCount(rules));
	for (index = 0; index < arrayCount(rules); index++) {
		rules[index] = p.addLabel("", true);
	}
	
	// Configure components.
	if (playerList != none) {
		loadPlayerList(playerList);
	}
	setValues();
	playerSelected();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current server settings.
 *
 **************************************************************************************************/
function setValues() {
	local int index;
	local NexgenSharedDataContainer xConf;
	local string rule;
	local int ruleCount;
	
	// Get NexgenPlus configuration.
	xConf = xClient.dataSyncMgr.getDataContainer(class'NXPConfigDC'.default.containerID);
	
	// Load server rules.
	for (index = 0; index < xConf.getArraySize("serverRules"); index++) {
		rule = class'NexgenUtil'.static.trim(xConf.getString("serverRules", index));
		if (rule != "") {
			ruleCount++;
			rules[ruleCount - 1].setText(rule);
		}
	}
	for (index = ruleCount; index < arrayCount(rules); index++) {
		rules[index].setText("");
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
	 		case "serverRules": setValues(); break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player was selected from the list.
 *
 **************************************************************************************************/
function playerSelected() {
	if (showReasonInp != none && playerList != none) {
		showRulesButton.bDisabled = playerList.selectedItem == none;
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
	
	if (playerList != none) {
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
			case showRulesButton: forceClientViewRules(); break;
		}
	}
	
	// Player selected?
	if (playerList != none && control == playerList && eventType == DE_Click) {
		playerSelected();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Forces the currently selected client to view the rules.
 *
 **************************************************************************************************/
function setAdminForcedViewMessage(optional string reason) {
	local string message;
	
	// Get message.
	message = class'NexgenUtil'.static.trim(reason);
	if (message == "") {
		message = xClient.lng.serverRulesForcedTabTitle;
	}
	
	// Set message.
	rulesTitleLabel.setText(message);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Forces the currently selected client to view the rules.
 *
 **************************************************************************************************/
function forceClientViewRules() {
	xClient.adminForceClientViewRules(NexgenPlayerList(playerList.selectedItem).pNum,
	                                  class'NexgenUtil'.static.trim(showReasonInp.getValue()));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="nxp_server_rules_overview"
}

