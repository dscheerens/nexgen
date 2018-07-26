/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPHome
 *  $VERSION      1.04 (27-11-2007 23:11)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen client start/home control panel page.
 *
 **************************************************************************************************/
class NexgenRCPHome extends NexgenPanel;

var UWindowSmallButton teamBalanceButton;
var UWindowSmallButton teamButton[4];
var UWindowSmallButton playSpecButton;
var UWindowSmallButton reconnectButton;
var UWindowSmallButton disconnectButton;
var UWindowSmallButton exitButton;
var UWindowSmallButton mapVoteButton;
var UWindowSmallButton startButton;
var UWindowSmallButton loginButton;

var UMenuLabelControl serverTitleLabel;

var color teamColor[4];
var color rightGranted;
var color rightDenied;
var color rightNotDefined;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local NexgenContentPanel p;
	local NexgenContentPanel rightPanel;
	local UMenuLabelControl l;
	local int index;
	local string rightDef;
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionV(96, defaultComponentDist, , true);
	splitRegionH(32, defaultComponentDist);
	divideRegionH(14);
	
	// Title.
	p = addContentPanel();
	serverTitleLabel = p.addLabel(client.sConf.serverName, true, TA_Center);
	
	// Rights overview.
	p = addContentPanel();
	p.splitRegionH(32, defaultComponentDist);
	p.divideRegionH(2);
	p.divideRegionV(2, defaultComponentDist);
	p.addLabel(client.lng.format(client.lng.welcomeTxt, client.playerName, client.title), true);
	p.addLabel(client.lng.rightsOverviewTxt);
	p.divideRegionH(arraycount(client.sConf.rightsDef) / 2, defaultComponentDist);
	p.divideRegionH(arraycount(client.sConf.rightsDef) / 2, defaultComponentDist);
	for (index = 0; index < arraycount(client.sConf.rightsDef); index++) {
		rightPanel = p.addContentPanel(PBT_Transparent);
		l = rightPanel.addLabel("", true, TA_Center);
		rightDef = client.sConf.rightsDef[index];
		if (rightDef == "") {
			l.setText(client.lng.format(client.lng.rightNotDefinedTxt, string(index + 1)));
			l.setTextColor(rightNotDefined);
		} else {
			l.setText(mid(rightDef, instr(rightDef, client.sConf.separator) + 1));
			if (client.hasRight(left(rightDef, instr(rightDef, client.sConf.separator)))) {
				l.setTextColor(rightGranted);
				rightPanel.panelBGType = PBT_Default;
			} else {
				l.setTextColor(rightDenied);
			}
		}
	}
	
	// Sidebar buttons.
	teamBalanceButton = addButton(client.lng.teamBalanceTxt);
	teamButton[0] = addButton(client.lng.redTeamTxt);
	teamButton[1] = addButton(client.lng.blueTeamTxt);
	teamButton[2] = addButton(client.lng.greenTeamTxt);
	teamButton[3] = addButton(client.lng.goldTeamTxt);
	skipRegion();
	playSpecButton = addButton();
	reconnectButton = addButton(client.lng.reconnectTxt);
	disconnectButton = addButton(client.lng.disconnectTxt);
	exitButton = addButton(client.lng.exitTxt);
	skipRegion();
	mapVoteButton = addButton(client.lng.mapVoteTxt);
	startButton = addButton(client.lng.startTxt);
	loginButton = addButton(client.lng.loginTxt);
	
	// Configure components.
	if (client.bSpectator) {
		playSpecButton.setText(client.lng.playTxt);
	} else {
		playSpecButton.setText(client.lng.spectateTxt);
	}
	setupTeamButtons();
	if (client.gInf.gameState > client.gInf.GS_Ready) {
		startButton.bDisabled = true;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the properties of the team control buttons.
 *
 **************************************************************************************************/
function setupTeamButtons() {
	local TournamentGameReplicationInfo gri;
	local int index;
	
	// Check which buttons should be disabled.
	if (client.bSpectator || !client.player.gameReplicationInfo.bTeamGame) {

		if (!client.player.gameReplicationInfo.bTeamGame) {
			teamBalanceButton.bDisabled = true;
		}
		
		for (index = 0; index < arrayCount(teamButton); index++) {
			teamButton[index].bDisabled = true;
		}

	} else {
		
		for (index = 0; index < arrayCount(teamButton); index++) {
			teamButton[index].bDisabled = index >= client.gInf.maxTeams;
		}
	}
	
	// Set button colors.
	for (index = 0; index < arrayCount(teamButton); index++) {
		if (!teamButton[index].bDisabled) {
			teamButton[index].setTextColor(teamColor[index]);
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
			case teamBalanceButton: client.player.consoleCommand("mutate nsc balanceteams"); break;
			case teamButton[0]: client.player.consoleCommand("mutate nsc setteam 0"); break;
			case teamButton[1]: client.player.consoleCommand("mutate nsc setteam 1"); break;
			case teamButton[2]: client.player.consoleCommand("mutate nsc setteam 2"); break;
			case teamButton[3]: client.player.consoleCommand("mutate nsc setteam 3"); break;
			case playSpecButton:
				if (client.bSpectator) {
					client.player.consoleCommand("mutate nsc play");
				} else {
					client.player.consoleCommand("mutate nsc spectate");
				}
				UWindowFramedWindow(getParent(class'UWindowFramedWindow')).close();
				break;
			case reconnectButton:
				 client.player.consoleCommand("reconnect");
				 UWindowFramedWindow(getParent(class'UWindowFramedWindow')).close();
				 break;
			case disconnectButton:
				client.player.consoleCommand("disconnect");
				UWindowFramedWindow(getParent(class'UWindowFramedWindow')).close();
				break;
			case exitButton: client.player.consoleCommand("exit"); break;
			case mapVoteButton:
				client.player.consoleCommand("mutate nsc openvote");
				UWindowFramedWindow(getParent(class'UWindowFramedWindow')).close();
				break;
			case startButton: client.player.consoleCommand("mutate nsc start"); break;
			case loginButton: client.showPopup("NexgenAdminLoginDialog"); break;
		}
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
	if (configType == client.sConf.CT_GlobalServerSettings) {
		serverTitleLabel.setText(client.sConf.serverName);
	}
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
	rightGranted=(r=000,g=96,b=000)
	rightDenied=(r=96,g=000,b=000)
	rightNotDefined=(r=64,g=64,b=64)
	panelIdentifier="startpage"
}