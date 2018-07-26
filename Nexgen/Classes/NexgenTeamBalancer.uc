/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenTeamBalancer
 *  $VERSION      1.03 (28-12-2007 21:16)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Team balancing support class. The sole purpose of this class is to provide team
 *                balancing support. This support has been put in a separate class so plugins can
 *                change the default team balancing routine to a custom routine.
 *
 **************************************************************************************************/
class NexgenTeamBalancer extends Info;

var NexgenController control;           // The Nexgen controller.

const maxTeamCount = 4;                 // Maximum number of teams supported.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the team balancer.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	
	// Check owner.
	if (owner == none || !owner.isA('NexgenController')) {
		destroy();
		return;
	}
	
	// Set controller.
	control = NexgenController(owner);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attempts to balance the current teams.
 *  $RETURN       True if the teams have been balanced, false if they are already balanced.
 *
 **************************************************************************************************/
function bool balanceTeams() {
	local NexgenClient client;
	local int teamSize[4];
	local int totalPlayers;
	local int numTeams;
	local int minPlayersPerTeam;
	local int index;
	local int targetTeam;
	local NexgenClient preferredSwitchers[32]; // Assume the game has at most 32 players.
	local int prefSwitchTeamOffsets[4];
	local int switchedCount[4];
	
	// Get number of teams.
	if (level.game.isA('TeamGamePlus')) {
		numTeams = TeamGamePlus(level.game).maxTeams;
	} else {
		// Not a team game, so we're unable to balance the teams.
		return false;
	}
	
	// Get current team sizes.
	for (client = control.clientList; client != none; client = client.nextClient) {
		if (!client.bSpectator && 0 <= client.team && client.team < maxTeamCount) {
			teamSize[client.team]++;
			totalPlayers++;
		}
	}
	
	// Check if teams are already balanced.
	if (teamSize[getLargestTeam(teamSize, numTeams)] - teamSize[getSmallestTeam(teamSize, numTeams)] < 2) {
		return false;
	}
	
	// Calculate minimum players per team.
	minPlayersPerTeam = totalPlayers / numTeams;
	
	// Get player switch desirability rankings.
	initPreferredSwitchers(preferredSwitchers, prefSwitchTeamOffsets);
	
	// Determine rebalance actions. 
	for (index = 0; index < numTeams; index++) {
		while(teamSize[index] < minPlayersPerTeam || teamSize[index] > minPlayersPerTeam + 1) {
			// Switch a player.
			if (teamSize[index] < minPlayersPerTeam) {
				// Too few players, steal one from the largest team.
				targetTeam = getLargestTeam(teamSize, numTeams);
				teamSize[index]++;
				teamSize[targetTeam]--;
				switchPreferredPlayer(targetTeam, index, preferredSwitchers, prefSwitchTeamOffsets, switchedCount);
			} else {
				// Too many players, dump one at the smallest team.
				targetTeam = getSmallestTeam(teamSize, numTeams);
				teamSize[index]--;
				teamSize[targetTeam]++;
				switchPreferredPlayer(index, targetTeam, preferredSwitchers, prefSwitchTeamOffsets, switchedCount);
			}
		}
	}
	
	// Team balance complete.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the index of the team with the most players.
 *  $PARAM        teamSize  The current team sizes.
 *  $PARAM        numTeams  The number of teams available in the current game.
 *  $REQUIRE      0 < numTeams && numTeams <= maxTeamCount
 *  $RETURN       The team number of the biggest team.
 *  $ENSURE       0 <= result && result < numTeams
 *
 **************************************************************************************************/
function int getLargestTeam(int teamSize[4], int numTeams) {
	local int largest;
	local int index;
	
	// Find largest team.
	for (index = 1; index < numTeams; index++) {
		if (teamSize[index] > teamSize[largest]) {
			largest = index;
		}
	}
	
	// Return result.
	return largest;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the index of the team with the least players.
 *  $PARAM        teamSize  The current team sizes.
 *  $PARAM        numTeams  The number of teams available in the current game.
 *  $REQUIRE      0 < numTeams && numTeams <= maxTeamCount
 *  $RETURN       The team number of the smallest team.
 *  $ENSURE       0 <= result && result < numTeams
 *
 **************************************************************************************************/
function int getSmallestTeam(int teamSize[4], int numTeams) {
	local int smallest;
	local int index;
	
	// Find smallest team.
	for (index = 1; index < numTeams; index++) {
		if (teamSize[index] < teamSize[smallest]) {
			smallest = index;
		}
	}
	
	// Return result.
	return smallest;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the list containing the players with the highest switch desirability.
 *  $PARAM        preferredSwitchers     List containing the most preferred players for team
 *                                       switching per team. Sorted in descending order.
 *  $PARAM        prefSwitchTeamOffsets  Starting offsets in the preferredSwitchers array for each team.
 *
 **************************************************************************************************/ 
function initPreferredSwitchers(out NexgenClient preferredSwitchers[32],
                                out int prefSwitchTeamOffsets[4]) {
	local int team;
	local int nextOffset;
	local NexgenClient client;
	local NexgenClient tempClient;
	local bool bSorted;
	local int index;
	
	// Add preferred players for each team.
	for (team = 0; team < maxTeamCount; team++) {
		prefSwitchTeamOffsets[team] = nextOffset;
		
		// Add each player belonging to this team.
		for (client = control.clientList; client != none; client = client.nextClient) {
			if (client.team == team && nextOffset < arrayCount(preferredSwitchers)) {
				// Add to end of list.
				preferredSwitchers[nextOffset] = client;
				
				// Sort list.
				bSorted = false;
				index = nextOffset - 1;
				while (!bSorted && index >= prefSwitchTeamOffsets[team]) {
					// Player is correctly positioned in the list?
					if (compareSwitchDesirability(preferredSwitchers[index],
					                              preferredSwitchers[index + 1]) >= 0) {
						// Yes, list sort done.
						bSorted = true;
					} else {
						// No, switch players.
						tempClient = preferredSwitchers[index];
						preferredSwitchers[index] = preferredSwitchers[index + 1];
						preferredSwitchers[index + 1] = tempClient;
						index--;
					}
				}
				
				// Update next player offset.
				nextOffset++; 
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Switches the next preferred player from team oldTeam to newTeam.
 *  $PARAM        oldTeam                The team from which a player is to be switched.
 *  $PARAM        newTeam                Target team for the player.
 *  $PARAM        preferredSwitchers     List containing the most preferred players for team
 *                                       switching per team. Sorted in descending order.
 *  $PARAM        prefSwitchTeamOffsets  Starting offsets in the preferredSwitchers array for each team.
 *  $PARAM        switchedCount          Number of players that already have been switched for each team.
 *  $REQUIRE      0 <= oldTeam && oldTeam <= maxTeamCount &&
 *                0 <= newTeam && newTeam <= maxTeamCount &&
 *                oldTeam != newTeam
 *  $ENSURE       old.switchedCount[oldTeam] = old.switchedCount[oldTeam] + 1
 *
 **************************************************************************************************/ 
function switchPreferredPlayer(int oldTeam, int newTeam, NexgenClient preferredSwitchers[32],
                               int prefSwitchTeamOffsets[4], out int switchedCount[4]) {
	local NexgenClient preferred;
	
	// Get preferred player.
	preferred = preferredSwitchers[prefSwitchTeamOffsets[oldTeam] + switchedCount[oldTeam]];
	
	// Switch the player.
	switchedCount[oldTeam]++;
	preferred.setTeam(newTeam);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Compares the switch desirability of two players.
 *  $PARAM        client1  The client of the first player.
 *  $PARAM        client2  The client of the second player.
 *  $REQUIRE      client1 != none && client2 != none && client1.team == client2.team
 *  $RETURN       -1 if the switch desirability of the first player is lower then the switch
 *                desirability of the second player, 1 if it is higher and 0 if they are equal.
 *  $ENSURE       result == -1 || result == 0 || result == 1
 *
 **************************************************************************************************/
function int compareSwitchDesirability(NexgenClient client1, NexgenClient client2) {
	if (client1.lastSwitchTime < client2.lastSwitchTime &&
	    client2.player.playerReplicationInfo.hasFlag == none ||
	    client1.player.playerReplicationInfo.hasFlag != none) {
		return -1;
	} else {
		return 1;
	}
}


