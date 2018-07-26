/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenCommandHandler
 *  $VERSION      1.09 (05-12-2010 19:44:10)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Handles the nexgen commands issued via the mutate command in the console. The
 *                command handling has been placed into this class because it gets rather lengthy.
 *                This saves the NexgenController class from becoming one huge unreadable monster.
 *
 **************************************************************************************************/
class NexgenCommandHandler extends info;

var NexgenController control;                     // Server controller.
var NexgenLang lng;                               // Language instance to support localization.

const openMapVoteCommand = "BDBMAPVOTE VOTEMENU"; // Mutate command to open the mapvote window.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the command handler.
 *  $REQUIRE      owner != none && owner.isA('NexgenController')
 *  $ENSURE       control != none && lng != none
 *
 **************************************************************************************************/
function preBeginPlay() {	
	control = NexgenController(owner);
	lng = control.lng;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes the given command.
 *  $PARAM        client  The client that has issued the command.
 *  $PARAM        cmd     Name of the command to execute.
 *  $PARAM        args    Arguments for the command to execute.
 *  $REQUIRE      sender != none
 *
 **************************************************************************************************/
function execCommand(NexgenClient client, string cmd, string args[10]) {
	local bool bInvalidCommand;
	local bool bSuccess;
	local string failMessage;
	local string reason;
	
	// Determine action.
	failMessage = lng.commandFailedMsg;
	reason = lng.internalErrorMsg;
	switch (caps(cmd)) {
		case control.CMD_SwitchTeam:
			bSuccess = execSwitchTeam(client, int(args[0]), reason);
			failMessage = lng.teamSwitchFailedMsg;
			break;
			
		case control.CMD_BalanceTeams:
			bSuccess = execBalanceTeams(client, reason);
			failMessage = lng.teamBalanceFailedMsg;
			break;
			
		case control.CMD_Play:
			bSuccess = execJoinAsPlayer(client, reason);
			break;
			
		case control.CMD_Spectate:
			bSuccess = execJoinAsSpec(client, reason);
			break;
			
		case control.CMD_StartGame:
			bSuccess = execStartGame(client, reason);
			break;
		
		case control.CMD_Pause:
			bSuccess = execPauseGame(client, reason);
			break;
			
		case control.CMD_Exit:
			bSuccess = true;
			client.clientCommand(client.exitCommand);
			break;
			
		case control.CMD_Disconnect:
			bSuccess = true;
			client.clientCommand(client.disconnectCommand);
			break;
			
		case control.CMD_Open:
			bSuccess = true;
			client.showPanel();
			break;
			
		case control.CMD_OpenVote:
			bSuccess = true;
			level.game.baseMutator.mutate(openMapVoteCommand, client.player);
			break;
		
		default:
			bInvalidCommand = true;
	}
	
	// Check outcome.
	if (bInvalidCommand) {
		client.showMsg(lng.invalidCommandMsg);
	} else if (!bSuccess) {
		client.showMsg(lng.format(failMessage, reason));
	}

}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a team switch command.
 *  $PARAM        client   The client that has issued the command.
 *  $PARAM        newTeam  The team where the player wants to switch to.
 *  $PARAM        reason   Reason why the command has failed to execute.
 *  $REQUIRE      client != none
 *  $RETURN       True if the command has been executed, false if it failed to execute.
 *
 **************************************************************************************************/
function bool execSwitchTeam(NexgenClient client, int newTeam, out string reason) {
	local bool bAllowed;
	
	// Check if the player is allowed to switch.
	if (client.bSpectator) {
		reason = lng.specTeamSwitchMsg;
	} else if (control.gInf.bNoTeamSwitch) {
		reason = lng.teamSwitchDisabledMsg;
	/*
	} else if ('player has switched too much') {
		reason = lng.switchLimitReachedMsg;
	*/
	} else if (client.bNoTeamSwitch) {
		reason = lng.playerTeamSwitchDisabledMsg;
	} else if (control.gInf.bTeamsLocked) {
		reason = lng.teamsLockedMsg;
	} else if ((newTeam < 0) ||
	           (level.game.isA('TeamGamePlus') && newTeam >= TeamGamePlus(level.game).maxTeams) ||
	           (newTeam > 3)) {
		reason = lng.invalidTeamMsg;
	} else if (newTeam == client.player.playerReplicationInfo.team) {
		reason = lng.format(lng.sameTeamMsg, lng.getTeamName(newTeam));
	} else {
		// All seems to be ok.
		bAllowed = true;
	}
	
	// Switch team if allowed.
	if (bAllowed) {
		client.setTeam(newTeam);
	}
	
	return bAllowed;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a reconnect as spectator command.
 *  $PARAM        reason  Reason why the command has failed to execute.
 *  $REQUIRE      client != none
 *  $RETURN       True if the command has been executed, false if it failed to execute.
 *
 **************************************************************************************************/
function bool execJoinAsSpec(NexgenClient client, out string reason) {
	local bool bAllowed;
	local int numSpecs;
	local NexgenClient currClient;
	
	// Count spectators.
	currClient = control.clientList;
	while (currClient != none) {
		if (currClient.bSpectator) {
			numSpecs++;
		}
		currClient = currClient.nextClient;
	}

	// Check if the player is allowed to join as a spectator.
	if (control.sConf.spectatorSlots == 0) {
		reason = lng.noSpecsAllowedMsg;
	} else if (numSpecs >= control.sConf.spectatorSlots && !client.bSpectator) {
		reason = lng.noMoreSpecSlotsMsg;
	} else {
		bAllowed = true;
	}

	// Reconnect as spectator if allowed.
	if (bAllowed) {
		client.reconnect(client.RCN_ReconnectAsSpec);
	}
	
	return bAllowed;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a reconnect as player command.
 *  $PARAM        reason  Reason why the command has failed to execute.
 *  $REQUIRE      client != none
 *  $RETURN       True if the command has been executed, false if it failed to execute.
 *
 **************************************************************************************************/
function bool execJoinAsPlayer(NexgenClient client, out string reason) {
	local bool bAllowed;
	
	// Check if the player is allowed to join as a player.
	if (!client.hasRight(client.R_MayPlay)) {
		reason = lng.noPlayingRightsMsg;
	} else if (client.bSpectator && !control.canGetSlot(client)) {
		reason = lng.noMorePlayerSlotsMsg;		
	} else if (control.gInf.bTeamsLocked) {
		reason = lng.teamsLockedMsg;
	} else {
		bAllowed = true;
	}
	
	// Reconnect as player if allowed.
	if (bAllowed) {
		client.reconnect(client.RCN_ReconnectAsPlayer);
	}
	
	return bAllowed;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a balance team command.
 *  $PARAM        reason  Reason why the command has failed to execute.
 *  $REQUIRE      client != none
 *  $RETURN       True if the command has been executed, false if it failed to execute.
 *
 **************************************************************************************************/
function bool execBalanceTeams(NexgenClient client, out string reason) {
	local bool bAllowed;
	local bool bSuccess;
	
	// Check if the player is allowed to balance the teams.
	if (!level.game.isA('TeamGamePlus')) {
		reason = lng.notATeamGameMsg;
	} else if (client.hasRight(client.R_MatchAdmin)) {
		bAllowed = true;
	} else if (control.gInf.bTeamsLocked) {
		reason = lng.teamsLockedMsg;
	} else if (control.gInf.bNoTeamBalance) {
		reason = lng.teamBalanceDisabledMsg;
	} else {
		bAllowed = true;
	}
	
	// Balance teams if allowed.
	if (bAllowed) {
		bSuccess = control.balanceTeams();
		if (bSuccess) {
			control.broadcastMsg(lng.balanceMsg, client.playerName, , , , client.player.playerReplicationInfo);
		} else {
			reason = lng.teamsAlreadyBalancedMsg;
		}
	}
	
	return bAllowed && bSuccess;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a start game command.
 *  $PARAM        reason  Reason why the command has failed to execute.
 *  $REQUIRE      client != none
 *  $RETURN       True if the command has been executed, false if it failed to execute.
 *
 **************************************************************************************************/
function bool execStartGame(NexgenClient client, out string reason) {
	local bool bAllowed;
	
	if (!control.sConf.enableNexgenStartControl) {
		// bAllowed = false;
	} else if (control.gInf.gameState != control.gInf.GS_Ready) {
		// bAllowed = false;
	} else if ((control.sConf.enableAdminStartControl || control.sConf.matchModeActivated) &&
	           control.gInf.matchAdminCount > 0 && !client.hasRight(client.R_MatchAdmin) &&
	           !control.gInf.bTournamentMode) {
		// bAllowed = false;
	} else {
		bAllowed = true;
	}
	
	if (bAllowed) {
		if (control.gInf.bTournamentMode) {
			if (!client.bSpectator && !client.bIsReadyToPlay) {
				client.bIsReadyToPlay = true;
				control.broadcastMsg(lng.playerReadyMsg, client.playerName, , , , client.player.playerReplicationInfo);
				control.doTournamentModeReadySignalCheck();
			}
		} else {
			control.startGame();
			control.broadcastMsg(lng.launchMsg, client.playerName, , , , client.player.playerReplicationInfo);
		}
	}
	
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a pause game command.
 *  $PARAM        reason  Reason why the command has failed to execute.
 *  $REQUIRE      client != none
 *  $RETURN       True if the command has been executed, false if it failed to execute.
 *
 **************************************************************************************************/
function bool execPauseGame(NexgenClient client, out string reason) {
	NexgenClientCore(client.getController(class'NexgenClientCore'.default.ctrlID)).pauseGame();
	return true;
}