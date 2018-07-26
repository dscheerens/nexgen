/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenClientCore
 *  $VERSION      1.42 (05-12-2010 19:35:50)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Core client controller class that takes care of the basic Nexgen functionality.
 *
 **************************************************************************************************/
class NexgenClientCore extends NexgenClientController;

var string blockedPlayers[32];          // List containing all clientIDs of blocked players.
var bool bBlockAll;                     // Whether the client doesn't want to receive PMs at all.
var float lastFailedAdminLoginTime;     // Time between last failed admin login request.
var int adminLoginAttemptCount;         // Number of times the client has tried to login as an admin.

// Misc constants.
const openURLCommand = "open";          // Console command for opening an URL.
const restartURL = "?restart";          // Server URL for restarting the server.
const separator = ",";                  // Character used to seperate elements in a list.
const textNewLineToken = "\\n";         // Token used to detect new lines in texts.

// Settings.
const rebootDelay = 10;                 // Delay in seconds before the server will be rebooted.
const minAdminLoginInterval = 10.0;     // Minimal interval between admin login requests.
const maxAdminLoginAttempts = 3;        // Maximum number of admin login login attempts.


/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {
	reliable if (role == ROLE_Authority) // Replicate to client...
		receivePM, receivePassword;
		
	reliable if (role == ROLE_SimulatedProxy) // Replicate to server...
		setServerSettings, sendPM, addAccountType, updateAccountType ,deleteAccountType,
		moveAccountType, deleteAccount, updateAccount, addAccount, pauseGame, endGame, restartGame,
		setPlayerTeam, toggleTeamSwitch, reconnectPlayer, sendPlayerToURL, toggleGlobalTeamSwitch,
		toggleGlobalTeamBalance, toggleLockedTeams, adminLogin, deleteBan, addBan, updateBan,
		updateBootControl, separatePlayers, sendPassword, updateMatchSettings, toggleMatchMode,
		togglePlayerMute, setPlayerName, kickPlayer, showAdminMessage, toggleGlobalMute,
		toggleGlobalNameChange, banPlayer, setServerSettingsExt1, setServerSettingsExt2,
		rebootServer, delIgnoredWeapon, saveIgnoredWeapon, toggleGlobalTournamentMode,
		setLogSettings, forceStartGame;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function preBeginPlay() {
	
	// Execute server side actions.
	if (role == ROLE_Authority) {
		lastFailedAdminLoginTime = -minAdminLoginInterval;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is blocked by this player. Blocked players
 *                will not be able to send private messages to this client.
 *  $PARAM        clientID  The identification string of the player which is to be checked.
 *  $REQUIRE      clientID != ""
 *  $RETURN       True if the specified client is blocked, false if not.
 *
 **************************************************************************************************/
simulated function bool isBlocked(string clientID) {
	local int index;
	local bool bBlocked;
	
	while (!bBlocked && index < arrayCount(blockedPlayers)) {
		if (blockedPlayers[index] ~= clientID) {
			bBlocked = true;
		} else {
			index++;
		}
	}
	
	return bBlocked;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Blocks the specified player.
 *  $PARAM        clientID  The identification string of the player which is to be blocked.
 *  $REQUIRE      clientID != ""
 *
 **************************************************************************************************/
simulated function blockPlayer(string clientID) {
	local int index;
	local bool bFound;
	
	// Cancel if player is blocked already.
	if (isBlocked(clientID)) {
		return;
	}
	
	// Find a free slot.
	while (!bFound && index < arrayCount(blockedPlayers)) {
		if (blockedPlayers[index] == "") {
			bFound = true;
			blockedPlayers[index] = clientID;
		} else {
			index++;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Unblocks the specified player.
 *  $PARAM        clientID  The identification string of the player which is to be unblocked.
 *  $REQUIRE      clientID != ""
 *
 **************************************************************************************************/
simulated function unblockPlayer(string clientID) {
	local int index;
	local bool bFound;
	
	// Find a free slot.
	while (!bFound && index < arrayCount(blockedPlayers)) {
		if (blockedPlayers[index] ~= clientID) {
			bFound = true;
			blockedPlayers[index] = "";
		} else {
			index++;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Modifies the setup of the Nexgen remote control panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function setupControlPanel() {
	// Client.
	client.mainWindow.mainPanel.addPanel(client.lng.clientTabTxt, class'NexgenPanelContainer', "client");
	client.mainWindow.mainPanel.addPanel(client.lng.homeTabTxt, class'NexgenRCPHome', , "client");
	client.addPluginClientConfigPanel(class'NexgenRCPClientConfig');
	client.mainWindow.mainPanel.addPanel(client.lng.privateMessageTabTxt, class'NexgenRCPPrivateMsg', , "client");
	
	// Match.
	client.mainWindow.mainPanel.addPanel(client.lng.gameTabTxt, class'NexgenPanelContainer', "game");
	if (client.sConf.gameInfoPanelClass != none) {
		client.mainWindow.mainPanel.addPanel(client.lng.infoTabTxt, client.sConf.gameInfoPanelClass, , "game");
	}
	if (client.hasRight(client.R_Moderate)) {
		client.mainWindow.mainPanel.addPanel(client.lng.moderatorTabTxt, class'NexgenRCPModerate', , "game");
	}
	if (client.hasRight(client.R_MatchAdmin) && client.sConf.matchControlPanelClass != none) {
		client.mainWindow.mainPanel.addPanel(client.lng.matchControlTabTxt, client.sConf.matchControlPanelClass, , "game");
	}
	if (client.hasRight(client.R_MatchSet)) {
		client.mainWindow.mainPanel.addPanel(client.lng.matchSetupTabTxt, class'NexgenRCPMatchSet', , "game");
	}
	
	// Server.
	client.mainWindow.mainPanel.addPanel(client.lng.serverTabTxt, class'NexgenPanelContainer', "server");
	if (client.sConf.serverInfoPanelClass != none) {
		client.mainWindow.mainPanel.addPanel(client.lng.infoTabTxt, client.sConf.serverInfoPanelClass, , "server");
	}
	if (client.hasRight(client.R_BanOperator)) {
		client.mainWindow.mainPanel.addPanel(client.lng.banControlTabTxt, class'NexgenRCPBanControl', , "server");
	}
	if (client.hasRight(client.R_AccountManager)) {
		client.mainWindow.mainPanel.addPanel(client.lng.accountsTabTxt, class'NexgenRCPUserAccounts', , "server");
	}
	if (client.hasRight(client.R_ServerAdmin)) {
		client.mainWindow.mainPanel.addPanel(client.lng.accountTypesTabTxt, class'NexgenRCPAccountTypes', , "server");
		client.mainWindow.mainPanel.addPanel(client.lng.settingsTabTxt, class'NexgenPanelContainer', "serversettings", "server");
		client.mainWindow.mainPanel.addPanel(client.lng.basicSettingsTabTxt, class'NexgenRCPServerSettings', , "server,serversettings");
		client.mainWindow.mainPanel.addPanel(client.lng.nexgenSettingsTabTxt, class'NexgenScrollPanelContainer', "nexgensettings", "server,serversettings");
		client.mainWindow.mainPanel.addPanel("", class'NexgenRCPMiscNexgenSettings', , "server,serversettings,nexgensettings");
		client.mainWindow.mainPanel.addPanel("", class'NexgenRCPLogSettings', , "server,serversettings,nexgensettings");
		client.mainWindow.mainPanel.addPanel("", class'NexgenRCPIgnoredWeaponsSettings', , "server,serversettings,nexgensettings");
		client.mainWindow.mainPanel.addPanel(client.lng.bootTabTxt, class'NexgenRCPBootControl', , "server,serversettings");
	}
	
	// About.
	client.mainWindow.mainPanel.addPanel(client.lng.aboutTabTxt, class'NexgenRCPAbout');
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the global server settings & notifies the other clients.
 *  $PARAM        serverName           Name of the server.
 *  $PARAM        shortServerName      Short name of the server.
 *  $PARAM        MOTD1                Message of the day line 1.
 *  $PARAM        MOTD2                Message of the day line 2.
 *  $PARAM        MOTD3                Message of the day line 3.
 *  $PARAM        MOTD4                Message of the day line 4.
 *  $PARAM        adminName            Name of the server administrator.
 *  $PARAM        adminEmail           E-Mail address of the server administrator.
 *  $PARAM        serverPassword       Password for entering the server.
 *  $PARAM        adminPassword        Password needed to login as server administrator.
 *  $PARAM        playerSlots          Number of players allowed.
 *  $PARAM        vipSlots             Amount of extra slots available reserved for VIPs.
 *  $PARAM        adminSlots           Amount of extra slots available reserved for admins.
 *  $PARAM        specSlots            How many spectators are allowed during the game.
 *  $PARAM        bEnableUplink        Indicates if the server should connect to the master server.
 *  $PARAM        variablePlayerSlots  Use variable amount of player slots.
 *
 **************************************************************************************************/
function setServerSettings(string serverName, string shortServerName, string MOTD1, string MOTD2,
                           string MOTD3, string MOTD4, string adminName, string adminEmail,
                           string serverPassword, string adminPassword, int playerSlots,
                           int vipSlots, int adminSlots, int specSlots, bool bEnableUplink,
                           bool variablePlayerSlots) {
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Check values.
	if (serverName == "") serverName = control.sConf.serverName;
	if (playerSlots < 0) playerSlots = 0;
	if (vipSlots < 0) vipSlots = 0;
	if (adminSlots < 0) adminSlots = 0;
	if (specSlots < 0) specSlots = 0;
	if (playerSlots > 32) playerSlots = 32;
	if (vipSlots > 16) vipSlots = 16;
	if (adminSlots > 16) adminSlots = 16;
	if (specSlots > 16) specSlots = 16;
	if (playerSlots + vipSlots + adminSlots <= 0) playerSlots = 16;
	
	// Save settings.
	control.sConf.serverName = serverName;
	control.sConf.shortName = shortServerName;
	control.sConf.MOTDLine[0] = MOTD1;
	control.sConf.MOTDLine[1] = MOTD2;
	control.sConf.MOTDLine[2] = MOTD3;
	control.sConf.MOTDLine[3] = MOTD4;
	control.sConf.adminName = adminName;
	control.sConf.adminEmail = adminEmail;
	control.sConf.globalServerPassword = control.sConf.encode(control.sConf.CS_GlobalServerSettings, serverPassword);
	control.sConf.globalAdminPassword = control.sConf.encode(control.sConf.CS_GlobalServerSettings, adminPassword);
	control.sConf.playerSlots = playerSlots;
	control.sConf.vipSlots = vipSlots;
	control.sConf.adminSlots = adminSlots;
	control.sConf.spectatorSlots = specSlots;
	control.sConf.enableUplink = bEnableUplink;
	control.sConf.variablePlayerSlots = variablePlayerSlots;
	control.sConf.saveConfig();
	
	// Apply settings.
	level.game.gameReplicationInfo.serverName = serverName;
	level.game.gameReplicationInfo.shortName = shortServerName;
	level.game.gameReplicationInfo.MOTDLine1 = MOTD1;
	level.game.gameReplicationInfo.MOTDLine2 = MOTD2;
	level.game.gameReplicationInfo.MOTDLine3 = MOTD3;
	level.game.gameReplicationInfo.MOTDLine4 = MOTD4;
	level.game.gameReplicationInfo.adminName = adminName;
	level.game.gameReplicationInfo.adminEmail = adminEmail;
	consoleCommand("set Engine.GameInfo GamePassword" @ serverPassword);
	consoleCommand("set Engine.GameInfo AdminPassword" @ adminPassword);
	if (variablePlayerSlots) {
		level.game.maxPlayers = playerSlots;
	} else {
		level.game.maxPlayers = playerSlots + vipSlots + adminSlots;
	}
	level.game.maxSpectators = specSlots;
	if (bEnableUplink) {
		consoleCommand("set IpServer.UdpServerUplink DoUplink True");
	} else {
		consoleCommand("set IpServer.UdpServerUplink DoUplink False");
	}
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_GlobalServerSettings);
	client.showMsg(control.lng.settingsSavedMsg);
	
	// Log action.
	logAdminAction(control.lng.adminUpdateGlobalServerSettings);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Send a private message to the player with the specified player code. Note that the
 *                message may not be send if the client isn't allowed to, e.g. he/she is muted.
 *  $PARAM        playerNum  Player code of the player that should receive the message.
 *  $PARAM        msg        The message to send.
 *  $PARAM        bWindowed  Whether the message to send should popup in a window.
 *  $REQUIRE      playerNum >= 0
 *
 **************************************************************************************************/
function sendPM(int playerNum, string msg, optional bool bWindowed) {
	local NexgenClient target;
	local NexgenClientCore targetCtrl;
	local string senderTitle;
	local Pawn p;
	local int count;
	local string lines, line;
	local string sender, receiver;
	local string args;
	
	// Check for abuse.
	if (!client.hasRight(client.R_Moderate) && (client.isMuted() || bWindowed)) {
		return;
	}
	
	// Locate target player.
	target = control.getClientByNum(playerNum);
	
	// Check if player is allowed to send message when in match mode. Not allowed if:
	    // - match mode is activated and spectators are muted during the match...
	if (control.sConf.matchModeActivated && control.sConf.muteSpectatorsDuringMatch &&
		// - AND the match is in progress...
		control.gInf.gameState == control.gInf.GS_Playing &&
		// - AND the player is a spectator and the target player isn't..
	    client.bSpectator && !target.bSpectator &&
	    // - AND the player isn't a moderator or match admin.
	    !client.hasRight(client.R_MatchAdmin) && !client.hasRight(client.R_Moderate)) {
		return;
	}
	
	// Get sender title.
	if (client.bHasAccount) {
		senderTitle = client.title;
	}
	
	// Send private message.
	if (target != none) {
		targetCtrl = NexgenClientCore(target.getController(ctrlID));
		targetCtrl.receivePM(client.playerID, client.player.playerReplicationInfo,
		                     msg, bWindowed, client.hasRight(client.R_Moderate), senderTitle);
		
		// Log the message.
		control.nscLog(client.playerName $ " -> " $ target.playerName $ ": " $ msg, control.LT_PrivateMsg);

		// Announce private message to messaging spectators if desired.
		if (control.sConf.sendPrivateMessagesToMsgSpecs) {
			for (p = level.pawnList; p != none; p = p.nextPawn) {
				if (p.isA('MessagingSpectator')) {
					// Log sender and receiver info.
					sender = control.lng.format(control.lng.accouncePMToMsgSpecPlayer,
					                            client.playerName,
					                            client.ipAddress,
					                            client.playerID);
					receiver = control.lng.format(control.lng.accouncePMToMsgSpecPlayer,
					                              target.playerName,
					                              target.ipAddress,
					                              target.playerID);
					p.clientMessage(control.lng.format(control.lng.accouncePMToMsgSpecMsg, sender, receiver), '');
					
					// Log message contents.
					lines = msg;
					while (lines != "") {
						count++;
						class'NexgenUtil'.static.split2(lines, line, lines, textNewLineToken);
						p.clientMessage(control.lng.format(control.lng.accouncePMToMsgSpecLine, count, line), '');
					}
				}
			}
		}
		
		// Signal event.
		class'NexgenUtil'.static.addProperty(args, "sender", client.playerNum);
		class'NexgenUtil'.static.addProperty(args, "receiver", target.playerNum);
		class'NexgenUtil'.static.addProperty(args, "message", msg);
		class'NexgenUtil'.static.addProperty(args, "windowed", bWindowed);
		control.signalEvent("pm_send", args, true);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Send a private message to the player with the specified player code. Note that the
 *                message may not be send if the client isn't allowed to, e.g. he/she is muted.
 *  $PARAM        senderID     Client ID of the player that has send the message.
 *  $PARAM        pri          The player replication info actor of the sending player.
 *  $PARAM        msg          The message that was received.
 *  $PARAM        bWindowed    Whether the received message should popup in a window.
 *  $PARAM        bForced      Indicates if the message should be forced (i.e. can't be blocked).
 *  $PARAM        senderTitle  Title of the player that has send the message.
 *  $REQUIRE      senderID != "" && pri != none
 *
 **************************************************************************************************/
simulated function receivePM(string senderID, PlayerReplicationInfo pri, string msg,
                             optional bool bWindowed, optional bool bForced,
                             optional string senderTitle) {
	local NexgenRCPPrivateMsg pmPanel;
	
	// Check if message is blocked.
	if (!bForced && (bBlockAll || isBlocked(senderID))) {
		return;
	}
	
	// Play PM receive sound.
	if (client.gc.get(client.SSTR_PlayPMSound, "true") ~= "true") {
		//client.player.playSound(sound'UnrealShare.TransA3', SLOT_Misc);
		client.player.clientPlaySound(sound'UnrealShare.TransA3', , true);
	}
	
	// Display message.
	pmPanel = NexgenRCPPrivateMsg(client.mainWindow.mainPanel.getPanel(class'NexgenRCPPrivateMsg'.default.panelIdentifier));
	if (pmPanel != none) {
		pmPanel.receiveMessage(msg, pri);
	}
	
	if (bWindowed) {
		client.showPopup("NexgenPrivateMsgDialog", msg, pri.playerName);
	} else {
		client.showMsg(client.lng.format(client.lng.receivedPMMsg, pri.playerName, msg, senderTitle), pri);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified account type to the list.
 *  $PARAM        atTypeName  Name of the account type to add.
 *  $PARAM        atRights    Rights assigned to the account type.
 *  $PARAM        atTitle     Display title of the account type.
 *  $PARAM        atPassword  Password for the account type.
 *
 **************************************************************************************************/
function addAccountType(string atTypeName, string atRights, string atTitle, string atPassword) {
	local int index;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_ServerAdmin) ||
	    control.sConf.atTypeName[arrayCount(control.sConf.atTypeName) - 1] != "") {
		return;
	}
	
	// Locate a free entry.
	while (control.sConf.atTypeName[index] != "") {
		index++;
	}
	
	// Store the account type.
	if (atTypeName == "") {
		control.sConf.atTypeName[index] = control.lng.format(control.lng.accountTypeNameStr, index + 1);
	} else {
		control.sConf.atTypeName[index] = class'NexgenUtil'.static.trim(atTypeName);
	}
	control.sConf.atRights[index] = atRights;
	control.sConf.atTitle[index] = class'NexgenUtil'.static.trim(atTitle);
	control.sConf.atPassword[index] = control.sConf.encode(control.sConf.CS_AccountTypes, atPassword);
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_AccountTypes);
	
	// Log action.
	logAdminAction(control.lng.adminAddAccountType, atTypeName, , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the account type info for the specified account type.
 *  $PARAM        accountTypeNum  The index of the account type that is to be updated.
 *  $PARAM        atTypeName      Name of the account type to update.
 *  $PARAM        atRights        Rights assigned to the account type.
 *  $PARAM        atTitle         Display title of the account type.
 *  $PARAM        atPassword      Password for the account type.
 *
 **************************************************************************************************/
function updateAccountType(byte accountTypeNum, string atTypeName, string atRights, string atTitle,
                           string atPassword) {
	
	// Preliminary checks.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
		
	// Store the account type.
	if (atTypeName != "") {
		control.sConf.atTypeName[accountTypeNum] = class'NexgenUtil'.static.trim(atTypeName);
	}
	control.sConf.atRights[accountTypeNum] = atRights;
	control.sConf.atTitle[accountTypeNum] = class'NexgenUtil'.static.trim(atTitle);
	control.sConf.atPassword[accountTypeNum] = control.sConf.encode(control.sConf.CS_AccountTypes, atPassword);
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_AccountTypes);
	updatePlayerTitles();
	
	// Log action.
	logAdminAction(control.lng.adminUpdateAccountType, atTypeName, , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the titles of each player. Iterates over the player list and checks
 *                whether the title of a player has changed. In case it has changed all players
 *                will be notified.
 *
 **************************************************************************************************/
function updatePlayerTitles() {
	local NexgenClient c;
	local string newTitle;
	local int accountNum;
	
	// For each client...
	for (c = control.clientList; c != none; c = c.nextClient) {
		
		// Get new title...
		accountNum = control.sConf.getUserAccountIndex(c.playerID);
		if (accountNum < 0) {
			if (c.bSpectator) {
				newTitle = control.lng.specTitle;
			} else {
				newTitle = control.sConf.getAccountTypeTitle(0);
			}
		} else {
			newTitle = control.sConf.getUserAccountTitle(accountNum);
		}
		
		// Compare with old title & update if necessary.
		if (c.title != newTitle) {
			c.title = newTitle;
			control.announcePlayerAttrChange(c, c.PA_Title, newTitle);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deletes the specified account type from the list.
 *  $PARAM        accountTypeNum  The index of the account type that is to be deleted.
 *
 **************************************************************************************************/
function deleteAccountType(byte accountTypeNum) {
	local bool userAccountsChanged;
	local int index;
	local string removedAccountType;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_ServerAdmin) ||
	    accountTypeNum >= arrayCount(control.sConf.atTypeName) || accountTypeNum < 1 ||
	    control.sConf.atTypeName[accountTypeNum] == "") {
		return;
	}
	
	// Update user account entries.
	while (index < arrayCount(control.sConf.paPlayerID) && control.sConf.paPlayerID[index] != "") {
		// Update account info?
		if (control.sConf.get_paAccountType(index) == accountTypeNum) {
			// User has the deleted account type, give him/her the default account.
			control.sConf.set_paAccountType(index, 0);
			userAccountsChanged = true;
		} else if (control.sConf.get_paAccountType(index) >= accountTypeNum) {
			// User has an account type num above the deleted account, update account type num.
			control.sConf.set_paAccountType(index, control.sConf.get_paAccountType(index) - 1);
			userAccountsChanged = true;
		}
		
		// Continue with next account.
		index++;
	}
	
	// Copy name of account type to be deleted.
	removedAccountType = control.sConf.atTypeName[accountTypeNum];
	
	// Update account type entries.
	index = accountTypeNum;
	while (index < arrayCount(control.sConf.atTypeName) && control.sConf.atTypeName[index] != "") {
		// Last entry?
		if (index + 1 == arrayCount(control.sConf.atTypeName)) {
			// Yes, clear all fields.
			control.sConf.atTypeName[index] = "";
			control.sConf.atRights[index] = "";
			control.sConf.atTitle[index] = "";
			control.sConf.atPassword[index] = "";
		} else {
			// No, copy from next entry.
			control.sConf.atTypeName[index] = control.sConf.atTypeName[index + 1];
			control.sConf.atRights[index] = control.sConf.atRights[index + 1];
			control.sConf.atTitle[index] = control.sConf.atTitle[index + 1];
			control.sConf.atPassword[index] = control.sConf.atPassword[index + 1];
		}
		
		// Continue with next account type.
		index++;
	}
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_AccountTypes);
	if (userAccountsChanged) {
		control.signalConfigUpdate(control.sConf.CT_UserAccounts);
	}
	
	// Log action.
	logAdminAction(control.lng.adminRemoveAccountType, removedAccountType, , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Moves the specified account type one position in the list.
 *  $PARAM        accountTypeNum  The index of the account type that is to be moved.
 *  $PARAM        bDown           Whether the item is to be moved up or down.
 *
 **************************************************************************************************/
function moveAccountType(byte accountTypeNum, bool bDown) {
	local int index;
	local bool userAccountsChanged;
	local int oldPosition;
	local int newPosition;
	local string temp;
	local string movedAccountType;
	
	// Preliminary checks. Fails if:
		// - The client doesn't have the rights to manage to accounts.
	if (!client.hasRight(client.R_ServerAdmin) ||
	
		// - accountTypeNum higher then the size of the list
	    accountTypeNum >= arrayCount(control.sConf.atTypeName) ||
	    
		// - There is no account type stored at the specified index.
	    control.sConf.atTypeName[accountTypeNum] == "" ||
	    
		// - The account type is moved down, but it already is the last used entry.
	    bDown && (control.sConf.atTypeName[accountTypeNum + 1] == "" ||
	              accountTypeNum + 1 >= arrayCount(control.sConf.atTypeName)) ||
	              
		// - The account type is moved up, but it is either the first or second entry.
	    !bDown && accountTypeNum < 2) {
	    
		return;
	}
	
	// Determine positions.
	oldPosition = accountTypeNum;
	if (bDown) {
		newPosition = accountTypeNum + 1;
	} else {
		newPosition = accountTypeNum - 1;
	}
	
	// Update user account entries.
	while (index < arrayCount(control.sConf.paPlayerID) && control.sConf.paPlayerID[index] != "") {
		// Check if account type number should be changed.
		if (control.sConf.get_paAccountType(index) == oldPosition) {
			control.sConf.set_paAccountType(index, newPosition);
			userAccountsChanged = true;
		} else if (control.sConf.get_paAccountType(index) == newPosition) {
			control.sConf.set_paAccountType(index, oldPosition);
			userAccountsChanged = true;
		}
		
		// Continue with next account.
		index++;
	}
	
	// Copy name of account type to move.
	movedAccountType = control.sConf.atTypeName[accountTypeNum];
	
	// Update account type entries.
	temp = control.sConf.atTypeName[oldPosition];
	control.sConf.atTypeName[oldPosition] = control.sConf.atTypeName[newPosition];
	control.sConf.atTypeName[newPosition] = temp;

	temp = control.sConf.atRights[oldPosition];
	control.sConf.atRights[oldPosition] = control.sConf.atRights[newPosition];
	control.sConf.atRights[newPosition] = temp;
	
	temp = control.sConf.atTitle[oldPosition];
	control.sConf.atTitle[oldPosition] = control.sConf.atTitle[newPosition];
	control.sConf.atTitle[newPosition] = temp;

	temp = control.sConf.atPassword[oldPosition];
	control.sConf.atPassword[oldPosition] = control.sConf.atPassword[newPosition];
	control.sConf.atPassword[newPosition] = temp;
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_AccountTypes);
	if (userAccountsChanged) {
		control.signalConfigUpdate(control.sConf.CT_UserAccounts);
	}
	
	// Log action.
	logAdminAction(control.lng.adminMoveAccountType, movedAccountType, , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deletes the specified account.
 *  $PARAM        accountNum  The index number of the account to delete.
 *
 **************************************************************************************************/
function deleteAccount(byte accountNum) {
	local int index;
	local NexgenClient c;
	local string removedAccount;
	local string removedAccountTitle;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_AccountManager) ||
	    accountNum < 0 || accountNum >= arrayCount(control.sConf.paPlayerID) ||
	    control.sConf.paPlayerID[accountNum] == "") {
		return;
	}
	
	// Kill the players client if he/she is online.
	c = control.getClientByID(control.sConf.paPlayerID[accountNum]);
	if (c != none) {
		c.showPopup("NexgenAccountUpdatedDialog");
		c.player.destroy();
	}
	
	// Backup account info.
	removedAccount = control.sConf.paPlayerName[accountNum];
	removedAccountTitle = control.sConf.getUserAccountTitle(accountNum);
	
	// Update user account entries.
	for (index = accountNum; index < arrayCount(control.sConf.paPlayerID); index++) {
		// Last entry?
		if (index + 1 == arrayCount(control.sConf.paPlayerID)) {
			// Yes, clear all fields.
			control.sConf.paPlayerID[index] = "";
			control.sConf.paPlayerName[index] = "";
			control.sConf.set_paAccountType(index, 0);
			control.sConf.paCustomRights[index] = "";
			control.sConf.paCustomTitle[index] = "";
		} else {
			control.sConf.paPlayerID[index] = control.sConf.paPlayerID[index + 1];
			control.sConf.paPlayerName[index] = control.sConf.paPlayerName[index + 1];
			control.sConf.set_paAccountType(index, control.sConf.get_paAccountType(index + 1));
			control.sConf.paCustomRights[index] = control.sConf.paCustomRights[index + 1];
			control.sConf.paCustomTitle[index] = control.sConf.paCustomTitle[index + 1];
		}
	}
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_UserAccounts);
	
	// Log action.
	logAdminAction(control.lng.adminRemoveAccount, removedAccount, removedAccountTitle, , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the specified account.
 *  $PARAM        accountNum    The index number of the account to update.
 *  $PARAM        accountName   Name of the account user.
 *  $PARAM        accountType   The type of account assigned to the user.
 *  $PARAM        customRights  Rights string for a custom account type.
 *  $PARAM        customTitle   Custom account title.
 *
 **************************************************************************************************/
function updateAccount(byte accountNum, string accountName, int accountType, string customRights,
                       string customTitle) {
	local NexgenClient c;
	
	// Preliminary checks. Fails if:
		// - The client doesn't have the rights to manage to accounts.
	if (!client.hasRight(client.R_AccountManager) ||
	    
	    // - An invalid account number is specified.
	    accountNum < 0 || accountNum >= arrayCount(control.sConf.paPlayerID) ||
	    
	    // - The account doesn't exist.
	    control.sConf.paPlayerID[accountNum] == "" ||
	    
	    // - No account name was specified.
	    class'NexgenUtil'.static.trim(accountName) == "" ||
	    
	    // - An invalid account type number is specified.
	    accountType < -1 || accountType >= arrayCount(control.sConf.atTypeName) ||
	    
	    // - The account type isn't used.
	    accountType != -1 && control.sConf.atTypeName[accountType] == "" ||
	    
	    // - A custom account is used, but no custom title was set.
	    accountType == -1 && class'NexgenUtil'.static.trim(customTitle) == "") {
		return;
	}
	
	// Kill the players client if he/she is online.
	c = control.getClientByID(control.sConf.paPlayerID[accountNum]);
	if (c != none) {
		c.showPopup("NexgenAccountUpdatedDialog");
		c.player.destroy();
	}
	
	// Update account.
	control.sConf.paPlayerName[accountNum] = class'NexgenUtil'.static.trim(accountName);
	control.sConf.set_paAccountType(accountNum, accountType);
	if (accountType < 0) {
		control.sConf.paCustomRights[accountNum] = customRights;
		control.sConf.paCustomTitle[accountNum] = customTitle;
	} else {
		control.sConf.paCustomRights[accountNum] = "";
		control.sConf.paCustomTitle[accountNum] = "";
	}
		
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_UserAccounts);
	
	// Log action.
	logAdminAction(control.lng.adminUpdateAccount, accountName, , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a new user account.
 *  $PARAM        accountNum    The index number of the account to update.
 *  $PARAM        accountName   Name of the account user.
 *  $PARAM        accountType   The type of account assigned to the user.
 *  $PARAM        customRights  Rights string for a custom account type.
 *  $PARAM        customTitle   Custom account title.
 *
 **************************************************************************************************/
function addAccount(string clientID, string accountName, int accountType, string customRights,
                    string customTitle) {
	local NexgenClient c;
	local int index;
	local bool bFound;
	local bool bAlreadyHasAccount;
	local string accountTitle;
	
	// Preliminary checks. Fails if:
		// - The client doesn't have the rights to manage to accounts.
	if (!client.hasRight(client.R_AccountManager) ||
	    
	    // - No account name was specified.
	    class'NexgenUtil'.static.trim(accountName) == "" ||
	    
	    // - An invalid account type number is specified.
	    accountType < -1 || accountType >= arrayCount(control.sConf.atTypeName) ||
	    
	    // - The account type isn't used.
	    accountType != -1 && control.sConf.atTypeName[accountType] == "" ||
	    
	    // - A custom account is used, but no custom title was set.
	    accountType == -1 && class'NexgenUtil'.static.trim(customTitle) == "") {
		return;
	}
	
	// Get free user account slot.
	while (!bFound && !bAlreadyHasAccount && index < arrayCount(control.sConf.paPlayerID)) {
		if (control.sConf.paPlayerID[index] == "") {
			bFound = true;
		} else if (control.sConf.paPlayerID[index] ~= clientID) {
			bAlreadyHasAccount = true;
		} else {
			index++;
		}
	}
	
	// Cancel on error.
	if (!bFound || bAlreadyHasAccount) {
		return;
	}
	
	// Kill the players client if he/she is online.
	c = control.getClientByID(clientID);
	if (c != none) {
		c.showPopup("NexgenAccountUpdatedDialog");
		c.player.destroy();
	}
	
	// Add account.
	control.sConf.paPlayerID[index] = clientID;
	control.sConf.paPlayerName[index] = accountName;
	control.sConf.set_paAccountType(index, accountType);
	if (accountType < 0) {
		control.sConf.paCustomRights[index] = customRights;
		control.sConf.paCustomTitle[index] = customTitle;
	}
	accountTitle = control.sConf.getUserAccountTitle(index);
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_UserAccounts);
	
	// Log action.
	logAdminAction(control.lng.adminAddAccount, accountName, accountTitle, , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Pauses the game. If the game is already paused when this function is called the
 *                game will be resumed.
 *
 **************************************************************************************************/
function pauseGame() {
	local bool bGameIsPaused;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin) ||
	    control.gInf.gameState != control.gInf.GS_Playing) {
		return;
	}
	
	// Check if game is currently paused.
	bGameIsPaused = level.pauser != "";
	
	// Pause / resume game.
	if (bGameIsPaused) {
		level.pauser = "";
	} else {
		level.pauser = client.playerName;
	}
	bGameIsPaused = !bGameIsPaused;
	
	// Announce event.
	if (bGameIsPaused) {
		logAdminAction(control.lng.adminPauseGameMsg);
	} else {
		logAdminAction(control.lng.adminResumeGameMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Ends the current game.
 *
 **************************************************************************************************/
function endGame() {
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin) ||
	    control.gInf.gameState != control.gInf.GS_Playing) {
		return;
	}
	
	// End the game.
	level.pauser = ""; // Make sure the game doesn't remain paused.
	control.forceEndGame();
	
	// Announce event.
	logAdminAction(control.lng.adminStopGameMsg);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Restarts the current game.
 *
 **************************************************************************************************/
function restartGame() {
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin)) {
		return;
	}
	
	// Restart.
	level.serverTravel(restartURL, false);
	
	// Announce event.
	logAdminAction(control.lng.adminRestartGameMsg);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the team of the specified player.
 *  $PARAM        playerNum  The player that is to be switched to another team.
 *  $PARAM        newTeam    The number of the team where to player should be switched to.
 *
 **************************************************************************************************/
function setPlayerTeam(int playerNum, int newTeam) {
	local NexgenClient target;
	
	// Get target client handler.
	target = control.getClientByNum(playerNum);
	
	// Preliminary checks. Fails if:
	    // - The player doesn't have match admin rights.
	if (!client.hasRight(client.R_MatchAdmin) ||
	    
	    // - An invalid player number was specified.
	    target == none ||
	    
	    // - The game isn't a team game.
	    !level.game.gameReplicationInfo.bTeamGame ||
	    
	    // - An invalid team number was specified.
	    newTeam < 0 || newTeam >= 4 ||
	    
	    // - A non existing team was specified.
	    level.game.isA('TeamGamePlus') && newTeam >= TeamGamePlus(level.game).maxTeams ||
	    
	    // - The target player is already on the specified team.
	    target.team == newTeam) {
		return;
	}
	
	// Switch player.
	target.setTeam(newTeam);
	
	// Announce event.
	logAdminAction(control.lng.adminTeamSwitchMsg, target.playerName, control.lng.getTeamName(newTeam));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Enables or disables team switching for the specified player.
 *  $PARAM        playerNum  The player code of the player whose team switch right is to be changed.
 *
 **************************************************************************************************/
function toggleTeamSwitch(int playerNum) {
	local NexgenClient target;
	
	// Get target client handler.
	target = control.getClientByNum(playerNum);
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin) || target == none) {
		return;
	}
	
	// Toggle team switch on or off.
	target.bNoTeamSwitch = !target.bNoTeamSwitch;
	
	// Announce event.
	if (target.bNoTeamSwitch) {
		logAdminAction(control.lng.adminPlayerTeamSwitchDisableMsg, target.playerName);
	} else {
		logAdminAction(control.lng.adminPlayerTeamSwitchEnableMsg, target.playerName);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reconnects the specified player.
 *  $PARAM        playerNum  The player code of the player that is to be reconnected.
 *  $PARAM        bSpec      Whether the player should be reconnected as spectator.
 *
 **************************************************************************************************/
function reconnectPlayer(int playerNum, bool bSpec) {
	local NexgenClient target;
	
	// Get target client handler.
	target = control.getClientByNum(playerNum);
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin) || target == none || target.bSpectator == bSpec) {
		return;
	}
	
	// Reconnect player.
	if (bSpec) {
		target.reconnect(target.RCN_ReconnectAsSpec);
	} else {
		control.giveJoinOverrideCode(target);
		target.reconnect(target.RCN_ReconnectAsPlayer);
	}
	
	// Announce event.
	if (bSpec) {
		logAdminAction(control.lng.adminReconnectAsSpecMsg, target.playerName);
	} else {
		logAdminAction(control.lng.adminReconnectAsPlayerMsg, target.playerName);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the specified player to the target URL.
 *  $PARAM        playerNum  The player which is to be send to the specified URL.
 *  $PARAM        url        The target url string.
 *
 **************************************************************************************************/
function sendPlayerToURL(int playerNum, string url) {
	local NexgenClient target;
	local string fURL;
	
	// Format parameter.
	fURL = class'NexgenUtil'.static.trim(url);
	
	// Get target client handler.
	target = control.getClientByNum(playerNum);
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin) || target == none || fURL == "") {
		return;
	}
	
	// Send to url.
	target.clientCommand(openURLCommand @ fURL);
	
	// Announce event.
	logAdminAction(control.lng.adminSendToURLMsg, target.playerName, fURL);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Enables / disables team switching for all players in the current game.
 *
 **************************************************************************************************/
function toggleGlobalTeamSwitch() {
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin)) {
		return;
	}
	
	// Update setting.
	control.gInf.bNoTeamSwitch = !control.gInf.bNoTeamSwitch;
	
	// Announce event.
	control.signalGameInfoUpdate(control.gInf.IT_GlobalRights);
	if (control.gInf.bNoTeamSwitch) {
		logAdminAction(control.lng.adminDisableTeamSwitchMsg);
	} else {
		logAdminAction(control.lng.adminEnableTeamSwitchMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Enables / disables team balancing for all players in the current game.
 *
 **************************************************************************************************/
function toggleGlobalTeamBalance() {
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin)) {
		return;
	}
	
	// Update setting.
	control.gInf.bNoTeamBalance = !control.gInf.bNoTeamBalance;
	
	// Announce event.
	control.signalGameInfoUpdate(control.gInf.IT_GlobalRights);
	if (control.gInf.bNoTeamBalance) {
		logAdminAction(control.lng.adminDisableTeamBalanceMsg);
	} else {
		logAdminAction(control.lng.adminEnableTeamBalanceMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locks / unlocks the teams for the current game.
 *
 **************************************************************************************************/
function toggleLockedTeams() {
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin)) {
		return;
	}
	
	// Update setting.
	control.gInf.bTeamsLocked = !control.gInf.bTeamsLocked;
	
	// Announce event.
	control.signalGameInfoUpdate(control.gInf.IT_GlobalRights);
	if (control.gInf.bTeamsLocked) {
		logAdminAction(control.lng.adminLockTeamsMsg);
	} else {
		logAdminAction(control.lng.adminUnlockTeamsMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attempts to give the player an account. The account given to the player depends on
 *                the password that was specified. It can either be the server admin password
 *                (Engine.GameInfo.AdminPassword) or one of the nexgen account type passwords.
 *  $PARAM        password  The administrator password.
 *
 **************************************************************************************************/
function adminLogin(string password) {
	local bool bValidPassword;
	local bool bRootAdmin;
	local int index;
	local byte accountType;
	
	// Check if action is disabled.
	if ((client.timeSeconds - lastFailedAdminLoginTime < minAdminLoginInterval) ||
	    adminLoginAttemptCount >= maxAdminLoginAttempts) {
		return;
	}
	
	adminLoginAttemptCount++;
	
	// Check password.
	if (password == "") {
		// You wish it was that easy!
		
	} else if (password == control.sConf.decode(control.sConf.CS_GlobalServerSettings, control.sConf.globalAdminPassword)) {
		// Server root admin password.
		bValidPassword = true;
		bRootAdmin = true;
		
	} else {
		// Check with account types.
		while (!bValidPassword && index < arrayCount(control.sConf.atTypeName) &&
		       control.sConf.atTypeName[index] != "") {
			if (control.sConf.atPassword[index] != "" &&
			    control.sConf.decode(control.sConf.CS_AccountTypes, control.sConf.atPassword[index]) == password) {
				// Account type password match.
				bValidPassword = true;
				accountType = index;
			} else {
				// Passwords do not match, continue with next account type.
				index++;
			}
		}
	}
	
	// Valid password entered?
	if (bValidPassword) {
		// Yes, add / update user account.
		if (bRootAdmin) {
			index = control.sConf.addUserAccount(client.playerID, client.playerName, -1,
			                                     control.sConf.getAllRights(true),
			                                     control.lng.rootAdminTitle);
		} else {
			index = control.sConf.addUserAccount(client.playerID, client.playerName, accountType);
		}
		
		// Account successfully created / updated?
		if (index >= 0) { // Yes.
			// Announce event.
			control.broadcastMsg(control.lng.adminLoginMsg, client.playerName,
			                     control.sConf.getUserAccountTitle(index), , ,
			                     client.player.playerReplicationInfo);
			
			// Disconnect client.
			client.showPopup("NexgenAccountUpdatedDialog");
			client.player.destroy();

			// Save changes.
			control.sConf.saveConfig();
			
			// Notify clients.
			control.signalConfigUpdate(control.sConf.CT_UserAccounts);
		}
		
	} else {
		lastFailedAdminLoginTime = client.timeSeconds;
		
		// No, notify client.
		client.showMsg(control.lng.invalidPasswordMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deletes the specified entry from the banlist.
 *  $PARAM        entryNum  Entry number of the ban to delete.
 *
 **************************************************************************************************/
function deleteBan(byte entryNum) {
	local string deletedBan;
	local int index;
		
	// Preliminary checks.
	if (!client.hasRight(client.R_BanOperator) ||
	    entryNum >= arrayCount(control.sConf.bannedName) ||
	    control.sConf.bannedName[entryNum] == "") {
		return;
	}
	
	// Remove ban.
	deletedBan = control.sConf.bannedName[entryNum];
	control.sConf.removeBan(entryNum);
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_BanList);
	
	// Log action.
	logAdminAction(control.lng.adminDeleteBanMsg, deletedBan, , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds specified ban to the banlist.
 *  $PARAM        playerName  Name of the player that is banned.
 *  $PARAM        ipList      List of banned ip addresses.
 *  $PARAM        idList      List of banned client id's.
 *  $PARAM        banReason   The reason why this player was banned.
 *  $PARAM        banPeriod   Describes the period for which the player is banned.
 *
 **************************************************************************************************/
function addBan(string playerName, string ipList, string idList, string banReason, string banPeriod) {
	local byte entryNum;
	local bool bFound;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_BanOperator) ||
	    class'NexgenUtil'.static.trim(playerName) == "") {
		return;
	}
	
	// Find a free slot.
	while (!bFound && entryNum < arrayCount(control.sConf.bannedName)) {
		if (control.sConf.bannedName[entryNum] == "") {
			bFound = true;
		} else {
			entryNum++;
		}
	}
	
	// Cancel on error.
	if (!bFound) {
		return;
	}
	
	// Store ban.
	control.sConf.bannedName[entryNum] = playerName;
	control.sConf.bannedIPs[entryNum] = ipList;
	control.sConf.bannedIDs[entryNum] = idList;
	control.sConf.banReason[entryNum] = banReason;
	control.sConf.banPeriod[entryNum] = banPeriod;
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_BanList);
	
	// Log action.
	logAdminAction(control.lng.adminAddBanMsg, playerName, , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the specified ban entry.
 *  $PARAM        entryNum    The entry in the banlist that is to be updated.
 *  $PARAM        playerName  Name of the player that is banned.
 *  $PARAM        ipList      List of banned ip addresses.
 *  $PARAM        idList      List of banned client id's.
 *  $PARAM        banReason   The reason why this player was banned.
 *  $PARAM        banPeriod   Describes the period for which the player is banned.
 *
 **************************************************************************************************/
function updateBan(byte entryNum, string playerName, string ipList, string idList, string banReason,
                   string banPeriod) {
	// Preliminary checks.
	if (!client.hasRight(client.R_BanOperator) ||
	    class'NexgenUtil'.static.trim(playerName) == "" ||
	    entryNum >= arrayCount(control.sConf.bannedName) ||
	    control.sConf.bannedName[entryNum] == "") {
		return;
	}
	
	// Store ban.
	control.sConf.bannedName[entryNum] = playerName;
	control.sConf.bannedIPs[entryNum] = ipList;
	control.sConf.bannedIDs[entryNum] = idList;
	control.sConf.banReason[entryNum] = banReason;
	control.sConf.banPeriod[entryNum] = banPeriod;
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_BanList);
	
	// Log action.
	logAdminAction(control.lng.adminUpdateBanMsg, playerName, , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the boot control settings.
 *  $PARAM        bEnable       Whether nexgen boot control should be used.
 *  $PARAM        bLoadLastMap  Indicates if the game before the crash/reboot is to be loaded.
 *  $PARAM        gameType      The class of the game type used to boot the server with.
 *  $PARAM        mutators      List of mutator classes that are loaded when the server gets booted.
 *  $PARAM        mapPrefix     Map prefix of the levels to load.
 *  $PARAM        extraOptions  Extra command line options for the nexgen server boot.
 *  $PARAM        bootCommands  Console commands to execute before the server is booted.
 *
 **************************************************************************************************/
function updateBootControl(bool bEnable, bool bLoadLastMap, int gameType, string mutators,
                           string mapPrefix, string extraOptions, string bootCommands) {
	local string gameClass;
	local string mutatorClass;
	local string remaining;
	local string indexStr;
	local string temp;
	local int index;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Store new settings.
	control.sConf.enableBootControl = bEnable;
	control.sConf.restartOnLastGame = bLoadLastMap;
	if (0 <= gameType && gameType < arrayCount(client.sConf.gameTypeInfo)) {
		class'NexgenUtil'.static.split(client.sConf.gameTypeInfo[gameType], gameClass, remaining);
		control.sConf.bootGameType = gameClass;
	} else {
		control.sConf.bootGameType = "";
	}
	control.sConf.bootMapPrefix = mapPrefix;
	control.sConf.bootMutatorIndices = mutators;
	control.sConf.bootMutators = "";
	remaining = mutators;
	while (remaining != "") {
		class'NexgenUtil'.static.split(remaining, indexStr, remaining);
		index = int(indexStr);
		if (0 <= index && index < arrayCount(client.sConf.mutatorInfo)) {
			class'NexgenUtil'.static.split(client.sConf.mutatorInfo[index], mutatorClass, temp);
			if (control.sConf.bootMutators == "") {
				control.sConf.bootMutators = mutatorClass;
			} else {
				control.sConf.bootMutators = control.sConf.bootMutators $ separator $ mutatorClass;
			}
		}
	}
	control.sConf.bootOptions = extraOptions;
	control.sConf.bootCommands = bootCommands;
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_BootControl);
	client.showMsg(control.lng.settingsSavedMsg);
	
	// Log action.
	logAdminAction(control.lng.adminUpdateBootControl, , , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Separates players by the specified tags.
 *  $PARAM        teamTag1  Tag of the first team.
 *  $PARAM        teamTag2  Tag of the second team.
 *  $PARAM        teamTag3  Tag of the third team.
 *  $PARAM        teamTag4  Tag of the forth team.
 *
 **************************************************************************************************/
function separatePlayers(string teamTag1, string teamTag2, string teamTag3, string teamTag4) {
	local NexgenClient c;
	local int index;
	local bool bFound;
	local string teamTags[4];
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin) ||
	    !level.game.isA('TeamGamePlus')) {
		return;
	}
	
	// Convert teamTag parameters to an array.
	teamTags[0] = teamTag1;
	teamTags[1] = teamTag2;
	teamTags[2] = teamTag3;
	teamTags[3] = teamTag4;
	
	// Switch players.
	for (c = control.clientList; c != none; c = c.nextClient) {
		if (!c.bSpectator) {
			index = 0;
			bFound = false;
			while (!bFound && index < arrayCount(teamTags) &&
			       index < TeamGamePlus(level.game).maxTeams) {
				// Check if player has a tag that separates him/her.
				if (teamTags[index] != "" && instr(caps(c.playerName), caps(teamTags[index])) >= 0) {
					bFound = true;
					if (c.player.playerReplicationInfo.team != index) {
						c.setTeam(index);
					}
				} else {
					index++;
				}
			}
		}
	}
	
	// Log action.
	logAdminAction(control.lng.adminSeparateByTag, , , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the match password to the specified player.
 *  $PARAM        targetPlayer  Player code of the player that is to receive the password. In case
 *                              -1 is passed the password will be send to all players.
 *  $PARAM        password      The match password that is to be send.
 *
 **************************************************************************************************/
function sendPassword(int targetPlayer, optional string password) {
	local string pwToSend;
	local NexgenClient target;
	local NexgenClientCore targetCtrl;
	local string pwReceivedMsg;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin)) {
		return;
	}
	
	// Get password.
	if (password == "") {
		pwToSend = control.sConf.decode(control.sConf.CS_MatchSettings, control.sConf.serverPassword);
	} else {
		pwToSend = password;
	}
	
	// Send password.
	if (targetPlayer >= 0) {
		target = control.getClientByNum(targetPlayer);
		targetCtrl = NexgenClientCore(target.getController(ctrlID));
		targetCtrl.receivePassword(pwToSend);
	} else {
		for (target = control.clientList; target != none; target = target.nextClient) {
			targetCtrl = NexgenClientCore(target.getController(ctrlID));
			targetCtrl.receivePassword(pwToSend);
		}
	}
	
	// Send feedback to client. 
	client.showMsg(control.lng.passwordSendMsg);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Send the specified match password to the client.
 *  $PARAM        password  The password to send.
 *
 **************************************************************************************************/
simulated function receivePassword(string password) {
	client.sc.visitServer(client.serverID);
	client.sc.set(client.serverID, client.SSTR_ServerPassword, password);
	client.sc.saveConfig();
	client.showMsg(client.lng.format(client.lng.receivedPWMsg, password));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the match settings
 *  $PARAM        matchesToPlay              Number of matches to play.
 *  $PARAM        currentMatch               Current match number.
 *  $PARAM        serverPassword             The password needed to enter the match.
 *  $PARAM        spectatorsNeedPassword     Whether spectators need to enter the password.
 *  $PARAM        muteSpectatorsDuringMatch  Are spectators allowed to chat during the match?
 *  $PARAM        enableMatchBootControl     Use Nexgen boot control during the match.
 *  $PARAM        matchAutoLockTeams         Whether the teams are automatically locked when the
 *                                           match begins.
 *  $PARAM        matchAutoPause             Automatically pause the game when a player leaves?
 *  $PARAM        matchAutoSeparate          Automatically separate players in teams?
 *  $PARAM        teamTags                   The tags used to separate players in teams.
 *
 **************************************************************************************************/
function updateMatchSettings(int matchesToPlay, int currentMatch, string serverPassword,
                             bool spectatorsNeedPassword,  bool muteSpectatorsDuringMatch,
                             bool enableMatchBootControl, bool matchAutoLockTeams,
                             bool matchAutoPause, bool matchAutoSeparate, string teamTag0,
                             string teamTag1, string teamTag2, string teamTag3) {
	local int index;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin)) {
		return;
	}
	
	// Validate parameters.
	matchesToPlay = max(1, matchesToPlay);
	currentMatch = clamp(currentMatch, 1, matchesToPlay);
	
	// Save settings.
	control.sConf.matchesToPlay = matchesToPlay;
	control.sConf.currentMatch = currentMatch;
	control.sConf.serverPassword = control.sConf.encode(control.sConf.CS_MatchSettings, serverPassword);
	control.sConf.spectatorsNeedPassword = spectatorsNeedPassword;
	control.sConf.muteSpectatorsDuringMatch = muteSpectatorsDuringMatch;
	control.sConf.enableMatchBootControl = enableMatchBootControl;
	control.sConf.matchAutoLockTeams = matchAutoLockTeams;
	control.sConf.matchAutoPause = matchAutoPause;
	control.sConf.matchAutoSeparate = matchAutoSeparate;
	/* lame... looks like another replication issue
	for (index = 0; index < arrayCount(teamTags); index++) {
		control.sConf.tagsToSeparate[index] = teamTags[index];
	}
	*/
	control.sConf.tagsToSeparate[0] = teamTag0;
	control.sConf.tagsToSeparate[1] = teamTag1;
	control.sConf.tagsToSeparate[2] = teamTag2;
	control.sConf.tagsToSeparate[3] = teamTag3;
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_MatchSettings);
	client.showMsg(control.lng.settingsSavedMsg);
	
	// Log action.
	logAdminAction(control.lng.adminUpdateMatchSettings, , , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Turns the match mode on or off.
 *
 **************************************************************************************************/
function toggleMatchMode() {
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin)) {
		return;
	}
	
	// Save settings.
	control.sConf.matchModeActivated = !control.sConf.matchModeActivated;
	control.sConf.saveConfig();
	
	// (Un)lock teams?
	if (control.sConf.matchAutoLockTeams && control.gInf.gameState == control.gInf.GS_Playing && 
	    control.gInf.bTeamsLocked != control.sConf.matchModeActivated) {
		
		control.gInf.bTeamsLocked = control.sConf.matchModeActivated;
		control.signalGameInfoUpdate(control.gInf.IT_GlobalRights);
	}

	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_MatchSettings);
	if (control.sConf.matchModeActivated) {
		logAdminAction(control.lng.adminEnableMatchModeMsg);
	} else {
		logAdminAction(control.lng.adminDisableMatchModeMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Mutes / unmutes the specified player.
 *  $PARAM        playerNum  The player code of the player that is to be (un)muted.
 *
 **************************************************************************************************/
function togglePlayerMute(int playerNum) {
	local NexgenClient target;
	local string args;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_Moderate)) {
		return;
	}
	
	// Get target client.
	target = control.getClientByNum(playerNum);
	if (target == none) return;
	
	// Mute target player.
	target.bMuted = !target.bMuted;
	
	// Announce event.
	if (target.bMuted) {
		logAdminAction(control.lng.adminMutePlayerMsg, target.playerName);
	} else {
		logAdminAction(control.lng.adminUnmutePlayerMsg, target.playerName);
	}
	
	// Signal event.
	class'NexgenUtil'.static.addProperty(args, "client", client.playerNum);
	class'NexgenUtil'.static.addProperty(args, "target", target.playerNum);
	class'NexgenUtil'.static.addProperty(args, "muted", target.bMuted);
	control.signalEvent("player_muted", args, true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the name of the specified player.
 *  $PARAM        playerNum  The player code of the player whose name is to be changed.
 *  $PARAM        newName    New name for the player.
 *
 **************************************************************************************************/
function setPlayerName(int playerNum, string newName) {
	local NexgenClient target;
	local string oldName;
	local string args;
	
	newName = class'NexgenUtil'.static.trim(newName);
	
	// Preliminary checks.
	if (!client.hasRight(client.R_Moderate) || newName == "") {
		return;
	}
	
	// Get target client.
	target = control.getClientByNum(playerNum);
	if (target == none) return;
	
	// Change name.
	oldName = target.playerName;
	target.changeName(newName);
	
	// Announce event.
	logAdminAction(control.lng.adminSetNameMsg, oldName, newName);
	
	// Signal event.
	class'NexgenUtil'.static.addProperty(args, "client", client.playerNum);
	class'NexgenUtil'.static.addProperty(args, "target", target.playerNum);
	class'NexgenUtil'.static.addProperty(args, "oldName", oldName);
	class'NexgenUtil'.static.addProperty(args, "newName", newName);
	control.signalEvent("player_name_set", args, true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Kicks the specified player from the server.
 *  $PARAM        playerNum  The player code of the player the player that is to be kicked.
 *  $PARAM        reason     Description of why the player was kicked.
 *
 **************************************************************************************************/
function kickPlayer(int playerNum, string reason) {
	local NexgenClient target;
	local string args;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_Moderate)) {
		return;
	}
	
	// Get target client.
	target = control.getClientByNum(playerNum);
	if (target == none) return;
	
	// Check if player can kick/ban players that have an account on the server.
	if (target.bHasAccount && !client.hasRight(client.R_BanAccounts)) {
		client.showMsg(control.lng.noBanAccountRightMsg);
		return;
	}
	
	// Kick player.
	target.showPopup("NexgenJustBannedDialog", reason, "-");
	target.player.destroy();
	
	// Announce event.
	logAdminAction(control.lng.adminKickPlayerMsg, target.playerName);
	
	// Signal event.
	class'NexgenUtil'.static.addProperty(args, "client", client.playerNum);
	class'NexgenUtil'.static.addProperty(args, "target", target.playerNum);
	class'NexgenUtil'.static.addProperty(args, "reason", reason);
	control.signalEvent("player_kicked", args, true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Bans the specified player from the server.
 *  $PARAM        playerNum      The player code of the player the player that is to be banned.
 *  $PARAM        banPeriodType  The type of period for which the player is banned. 1 means x
 *                               matches and 2 means x days, where x is specified by the
 *                               banPeriodArgs argument. Any other value means the player is banned
 *                               forever.
 *  $PARAM        banPeriodArgs  Optional argument for the ban period type.
 *  $PARAM        reason         Description of why the player was banned.
 *
 **************************************************************************************************/
function banPlayer(int playerNum, byte banPeriodType, int banPeriodArgs, string reason) {
	local NexgenClient target;
	local string banPeriod;
	local string banPeriodDesc;
	local int year, month, day, hour, minute;
	local int entryNum;
	local bool bFound;
	local bool bHasExistingBanEntry;
	local string args;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_Moderate) || !client.hasRight(client.R_BanOperator)) {
		return;
	}
	
	// Get target client.
	target = control.getClientByNum(playerNum);
	if (target == none) return;
	
	// Check if player can kick/ban players that have an account on the server.
	if (target.bHasAccount && !client.hasRight(client.R_BanAccounts)) {
		client.showMsg(control.lng.noBanAccountRightMsg);
		return;
	}
	
	// Get ban period.
	if (banPeriodType == control.sConf.BP_Matches) {
		banPeriod = "M" $ max(1, banPeriodArgs);
	} else if (banPeriodType == control.sConf.BP_UntilDate) {
		year = level.year;
		month = level.month;
		day = level.day;
		hour = level.hour;
		minute = level.minute;
		class'NexgenUtil'.static.computeDate(max(1, banPeriodArgs), year, month, day);
		banPeriod = "U" $ class'NexgenUtil'.static.serializeDate(year, month, day, hour, minute);
	}
	banPeriodDesc = control.lng.getBanPeriodDescription(banPeriod);
	
	// Kick player from the server.
	target.showPopup("NexgenJustBannedDialog", reason, banPeriodDesc);
	target.player.destroy();

	// Announce event.
	logAdminAction(control.lng.adminBanPlayerMsg, target.playerName);
	                     
	// Check if player already has an entry in the banlist.
	entryNum = control.sConf.getBanIndex("", target.ipAddress, target.playerID);
	if (entryNum >= 0) {
		bFound = true;
		bHasExistingBanEntry = true;
	} else {
		entryNum = 0;
	}
	
	// Find a free slot in the ban list.
	while (!bFound && entryNum < arrayCount(control.sConf.bannedName)) {
		if (control.sConf.bannedName[entryNum] == "") {
			bFound = true;
		} else {
			entryNum++;
		}
	}
	
	// Cancel on error.
	if (!bFound) {
		return;
	}
	
	// Store ban.
	control.sConf.bannedName[entryNum] = target.playerName;
	if (bHasExistingBanEntry) {
		control.sConf.updateBan(entryNum, target.ipAddress, target.playerID);
	} else {
		control.sConf.bannedIPs[entryNum] = target.ipAddress;
		control.sConf.bannedIDs[entryNum] = target.playerID;
	}
	control.sConf.banReason[entryNum] = reason;
	control.sConf.banPeriod[entryNum] = banPeriod;
	
	// Save changes.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_BanList);	
	
	// Signal event.
	class'NexgenUtil'.static.addProperty(args, "client", client.playerNum);
	class'NexgenUtil'.static.addProperty(args, "target", target.playerNum);
	class'NexgenUtil'.static.addProperty(args, "period", banPeriodDesc);
	class'NexgenUtil'.static.addProperty(args, "reason", reason);
	class'NexgenUtil'.static.addProperty(args, "ban_index", entryNum);
	control.signalEvent("player_banned", args, true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Shows a special administrator message.
 *  $PARAM        msg  The message to display.
 *
 **************************************************************************************************/
function showAdminMessage(string msg) {
	local Pawn p;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_Moderate)) {
		return;
	}
	
	// Show message.
	for (p = level.pawnList; p != none; p = p.nextPawn) {
		if(p.isA('PlayerPawn')) {
			PlayerPawn(p).clearProgressMessages();
			PlayerPawn(p).setProgressTime(6);
			PlayerPawn(p).setProgressMessage(msg, 0);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Enables / disables team switching for all players in the current game.
 *
 **************************************************************************************************/
function toggleGlobalMute() {
	// Preliminary checks.
	if (!client.hasRight(client.R_Moderate)) {
		return;
	}
	
	// Update setting.
	control.gInf.bMuteAll = !control.gInf.bMuteAll;
	
	// Announce event.
	control.signalGameInfoUpdate(control.gInf.IT_GlobalRights);
	if (control.gInf.bMuteAll) {
		logAdminAction(control.lng.adminMuteAllMsg);
	} else {
		logAdminAction(control.lng.adminUnmuteAllMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Enables / disables team switching for all players in the current game.
 *
 **************************************************************************************************/
function toggleGlobalNameChange() {
	// Preliminary checks.
	if (!client.hasRight(client.R_Moderate)) {
		return;
	}
	
	// Update setting.
	control.gInf.bNoNameChange = !control.gInf.bNoNameChange;
	
	// Announce event.
	control.signalGameInfoUpdate(control.gInf.IT_GlobalRights);
	if (control.gInf.bNoNameChange) {
		logAdminAction(control.lng.adminDisableNameChangeMsg);
	} else {
		logAdminAction(control.lng.adminEnableNameChangeMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the first part of the extra server settings.
 *  $PARAM        autoUpdateBans             Automatically update ban entries?
 *  $PARAM        removeExpiredBans          Automatically remove expired ban entries?
 *  $PARAM        broadcastAdminActions      Show the actions of administrators to all players?
 *  $PARAM        broadcastTeamKillAttempts  Whether or not to show team kill messages.
 *  $PARAM        useNexgenMessageHUD        Enable the Nexgen message HUD on this server?
 *  $PARAM        enableNexgenStartControl   Allow Nexgen to control the game start.
 *  $PARAM        enableAdminStartControl    Only allow match admins to start the game.
 *  $PARAM        restoreScoreOnTeamSwitch   Restore a players score when swichted to another team?
 *  $PARAM        allowTeamSwitch            Whether team switching is allowed by default.
 *  $PARAM        allowTeamBalance           Whether team balancing is allowed by default.
 *  $PARAM        allowNameChange            Whether name changing is allowed by default.
 *  $PARAM        autoRegisterServer         Automatically register server in Nexgen database?
 *
 **************************************************************************************************/
function setServerSettingsExt1(bool autoUpdateBans, bool removeExpiredBans,
                               bool broadcastAdminActions, bool broadcastTeamKillAttempts,
                               bool useNexgenHUD, bool enableNexgenStartControl,
                               bool enableAdminStartControl, bool restoreScoreOnTeamSwitch,
                               bool allowTeamSwitch, bool allowTeamBalance, bool allowNameChange,
                               bool autoRegisterServer) {
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Save settings.
	control.sConf.autoUpdateBans = autoUpdateBans;
	control.sConf.removeExpiredBans = removeExpiredBans;
	control.sConf.broadcastAdminActions = broadcastAdminActions;
	control.sConf.broadcastTeamKillAttempts = broadcastTeamKillAttempts;
	control.sConf.useNexgenHUD = useNexgenHUD;
	control.sConf.enableNexgenStartControl = enableNexgenStartControl;
	control.sConf.enableAdminStartControl = enableAdminStartControl;
	control.sConf.restoreScoreOnTeamSwitch = restoreScoreOnTeamSwitch;
	control.sConf.allowTeamSwitch = allowTeamSwitch;
	control.sConf.allowTeamBalance = allowTeamBalance;
	control.sConf.allowNameChange = allowNameChange;
	control.sConf.autoRegisterServer = autoRegisterServer;
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_ExtraServerSettings);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the second part of the extra server settings.
 *  $PARAM        waitTime                      Time to wait before the game can be started.
 *  $PARAM        startTime                     Game starting countdown time.
 *  $PARAM        autoReconnectTime             Time to wait before automatically reconnecting.
 *  $PARAM        maxIdleTime                   Maximum time a player can be idle on the server.
 *  $PARAM        spawnProtectionTime           How long the player remains protected after spawning.
 *  $PARAM        teamKillDamageProtectionTime  How long the player remains damage protected after a tk.
 *  $PARAM        teamKillPushProtectionTime    How long the player remains push protected after a tk.
 *  $PARAM        autoDisableMatchTime          Time to wait before disabling match mode.
 *
 **************************************************************************************************/
function setServerSettingsExt2(byte waitTime, byte startTime, byte autoReconnectTime,
                               int maxIdleTime, int maxIdleTimeCP, byte spawnProtectionTime,
                               byte teamKillDamageProtectionTime, byte teamKillPushProtectionTime,
                               byte autoDisableMatchTime) {
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Check values.
	waitTime                     = clamp(waitTime,                     0,   60);
	startTime                    = clamp(startTime,                    0,   30);
	autoReconnectTime            = clamp(autoReconnectTime,            0,   60);
	maxIdleTime                  = clamp(maxIdleTime,                  0, 9999);
	maxIdleTimeCP                = clamp(maxIdleTimeCP,                0, 9999);
	spawnProtectionTime          = clamp(spawnProtectionTime,          0,   60);
	teamKillDamageProtectionTime = clamp(teamKillDamageProtectionTime, 0,   30);
	teamKillPushProtectionTime   = clamp(teamKillPushProtectionTime,   0,   60);
	autoDisableMatchTime         = clamp(autoDisableMatchTime,         0,  120);
	
	// Save settings.
	control.sConf.waitTime = waitTime;
	control.sConf.startTime = startTime;
	control.sConf.autoReconnectTime = autoReconnectTime;
	control.sConf.maxIdleTime = maxIdleTime;
	control.sConf.maxIdleTimeCP = maxIdleTimeCP;
	control.sConf.spawnProtectionTime = spawnProtectionTime;
	control.sConf.teamKillDamageProtectionTime = teamKillDamageProtectionTime;
	control.sConf.teamKillPushProtectionTime = teamKillPushProtectionTime;
	control.sConf.autoDisableMatchTime = autoDisableMatchTime;
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_ExtraServerSettings);
	client.showMsg(control.lng.settingsSavedMsg);
	
	// Log action.
	logAdminAction(control.lng.adminUpdateMiscNexgenSettings);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reboots the server.
 *
 **************************************************************************************************/
function rebootServer() {
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Announce event.
	logAdminAction(control.lng.adminRebootServerMsg);
	
	// Reboot the server.
	control.gInf.rebootCountDown = rebootDelay;
	//consoleCommand(rebootCommand);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deletes the weapon in the spawn protect ignored weapon list at the specified index.
 *  $PARAM        index  Index of the weapon that is to be deleted.
 *
 **************************************************************************************************/
function delIgnoredWeapon(byte index) {
	local int currIndex;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_ServerAdmin) ||
	    index < 0 || index >= arrayCount(control.sConf.spawnProtectExcludeWeapons)) {
		return;
	}
	
	// Delete weapon.
	for (currIndex = index; currIndex < arrayCount(control.sConf.spawnProtectExcludeWeapons) - 1; currIndex++) {
		control.sConf.spawnProtectExcludeWeapons[currIndex] = control.sConf.spawnProtectExcludeWeapons[currIndex + 1];
	}
	control.sConf.spawnProtectExcludeWeapons[arrayCount(control.sConf.spawnProtectExcludeWeapons) - 1] = "";
	
	// Save settings.
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_ExclWeaponList);
	
	// Log action.
	logAdminAction(control.lng.adminUpdateIgnoredWeaponList, , , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the spawn protect ignore settings for the specified weapon.
 *  $PARAM        index              Position in the list where the settings are to be stored. A
 *                                   value below zero indicates that a free slot is to be used.
 *  $PARAM        weaponClass        Class of the weapon type that is to be added / saved.
 *  $PARAM        ignorePrimaryFire  Whether primary fire is ignored by the spawn protector.
 *  $PARAM        ignoreAltFire      Whether alternate fire is ignored by the spawn protector.
 *
 **************************************************************************************************/
function saveIgnoredWeapon(int index, string weaponClass, bool ignorePrimaryFire, bool ignoreAltFire) {
	local string weaponConfigStr;
	
	// Preliminary checks.
	if (!client.hasRight(client.R_ServerAdmin) ||
	    index >= arrayCount(control.sConf.spawnProtectExcludeWeapons) ||
	    class'NexgenUtil'.static.trim(weaponClass) == "") {
		return;
	}
	
	// Find index if weapon is to be added.
	if (index < 0) {
		index = 0;
		while (index < arrayCount(control.sConf.spawnProtectExcludeWeapons) &&
		       control.sConf.spawnProtectExcludeWeapons[index] != "") {
			index++;
		}
		
		// Valid index?
		if (index >= arrayCount(control.sConf.spawnProtectExcludeWeapons)) {
			// Nope, cancel action.
			return;
		}
	}
	
	// Save settings.
	weaponConfigStr = class'NexgenUtil'.static.trim(weaponClass) $ separator;
	if (ignorePrimaryFire) weaponConfigStr = weaponConfigStr $ control.sConf.IW_Fire;
	if (ignoreAltFire) weaponConfigStr = weaponConfigStr $ control.sConf.IW_AltFire;
	control.sConf.spawnProtectExcludeWeapons[index] = weaponConfigStr;
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_ExclWeaponList);
	
	// Log action.
	logAdminAction(control.lng.adminUpdateIgnoredWeaponList, , , , true);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Enables / disables tournament mode for the current game.
 *
 **************************************************************************************************/
function toggleGlobalTournamentMode() {
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin)) {
		return;
	}
	
	// Update setting.
	control.gInf.bTournamentMode = !control.gInf.bTournamentMode;
	DeathMatchPlus(level.game).bTournament = control.gInf.bTournamentMode;
	consoleCommand("set Botpack.DeathMatchPlus bTournament" @ control.gInf.bTournamentMode);
	if (control.sConf.enableNexgenStartControl && control.gInf.bTournamentMode &&
	    control.gInf.gameState == control.gInf.GS_Ready) {
		control.clearReadySignals();
		control.doTournamentModeReadySignalCheck();
	} else if (!control.sConf.enableNexgenStartControl) {
		DeathMatchPlus(level.game).bNetReady = !control.gInf.bTournamentMode;
	}
	
	// Announce event.
	control.signalGameInfoUpdate(control.gInf.IT_GameSettings);
	if (control.gInf.bTournamentMode) {
		logAdminAction(control.lng.adminEnableTournamentModeMsg);
	} else {
		logAdminAction(control.lng.adminDisableTournamentModeMsg);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the log and notifies the other clients.
 *  $PARAM        logEvents                      Include events in the log.
 *  $PARAM        logSystemMessages              Include system messages in the log.
 *  $PARAM        logChatMessages                Include chat messages in the log.
 *  $PARAM        logPrivateMessages             Include private messages in the log.
 *  $PARAM        logAdminActions                Include the actions of administrators in the log.
 *  $PARAM        logToConsole                   Write log messages to the console.
 *  $PARAM        logToFile                      Whether or not to create log files.
 *  $PARAM        logPath                        Path where the log files should be stored.
 *  $PARAM        logFileExtension               Extension of the log files.
 *  $PARAM        logFileNameFormat              Log file name format.
 *  $PARAM        logFileTimeStampFormat         Format of the time stamps in the log file.
 *  $PARAM        sendPrivateMessagesToMsgSpecs  Announce private message to message spectators.
 *
 **************************************************************************************************/
function setLogSettings(bool logEvents, bool logSystemMessages, bool logChatMessages,
                        bool logPrivateMessages, bool logAdminActions, bool logToConsole,
                        bool logToFile, string logPath, string logFileExtension,
                        string logFileNameFormat, string logFileTimeStampFormat,
                        bool sendPrivateMessagesToMsgSpecs) {
	// Check rights.
	if (!client.hasRight(client.R_ServerAdmin)) {
		return;
	}
	
	// Check values.
	if (class'NexgenUtil'.static.trim(logFileNameFormat) == "") {
		logFileNameFormat = control.lng.defaultLogFileNameFormat;
	}
	
	// Save settings.
	control.sConf.logEvents = logEvents;
	control.sConf.logSystemMessages = logSystemMessages;
	control.sConf.logChatMessages = logChatMessages;
	control.sConf.logPrivateMessages = logPrivateMessages;
	control.sConf.logAdminActions = logAdminActions;
	control.sConf.logToConsole = logToConsole;
	control.sConf.logToFile = logToFile;
	control.sConf.logPath = logPath;
	control.sConf.logFileExtension = logFileExtension;
	control.sConf.logFileNameFormat = logFileNameFormat;
	control.sConf.logFileTimeStampFormat = logFileTimeStampFormat;
	control.sConf.sendPrivateMessagesToMsgSpecs = sendPrivateMessagesToMsgSpecs;
	control.sConf.saveConfig();
	
	// Notify clients.
	control.signalConfigUpdate(control.sConf.CT_LogSettings);
	client.showMsg(control.lng.settingsSavedMsg);
	
	// Log action.
	logAdminAction(control.lng.adminUpdateLogServerSettings);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Forces the game start.
 *
 **************************************************************************************************/
function forceStartGame() {
	// Preliminary checks.
	if (!client.hasRight(client.R_MatchAdmin) ||
	    !(control.gInf.gameState == control.gInf.GS_Waiting ||
	    control.gInf.gameState == control.gInf.GS_Ready)) {
		return;
	}
	
	// End the game.
	control.startGame(true);
	
	// Announce event.
	logAdminAction(control.lng.adminForceGameStart);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	ctrlID="ClientCore"
}