/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenCorePlugin
 *  $VERSION      1.07 (25-02-2010 12:26)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Base Nexgen controller plugin.
 *
 **************************************************************************************************/
class NexgenCorePlugin extends NexgenPlugin;

var Actor ipToCountry;                            // IpToCountry actor.

// Controller settings.
const timerFreq = 2.0;                            // Timer tick frequency.

// Extra player attributes.
const PA_Muted = "muted";                         // Whether the player is muted.
const PA_NoTeamSwitch = "noTeamSwitch";           // Whether the player is not allowed to switch to
                                                  // another team.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {
	// Set panel classes.
	control.sConf.serverInfoPanelClass = class'NexgenRCPServerInfo';
	control.sConf.gameInfoPanelClass = class'NexgenRCPGameInfo';
	control.sConf.matchControlPanelClass = class'NexgenRCPMatchControl';
	
	// Set timer.
	setTimer(1.0 / timerFreq, true);
	
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Plugin main loop.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function timer() {
	// Update client country codes.
	if (ipToCountry != none) {
		updateCountryCodes();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the country codes for players that don't have a country code set.
 *
 **************************************************************************************************/
function updateCountryCodes() {
	local NexgenClient client;
	local bool bCancelled;
	local string ipInfo;
	
	// Search for clients with no country codes.
	client = control.clientList;
	while (client != none && !bCancelled) {
		// Country not set?
		if (client.country == "") {
			// Get ip info.
			ipInfo = ipToCountry.getItemName(client.ipAddress);
			
			// Parse ip info string.
			if (left(ipInfo, 1) == "!") {
				// Status code returned.
				switch (caps(ipInfo)) {
					//case "!ADDED TO QUEUE": break
					//case "!WAITING IN QUEUE": break
					//case "!RESOLVING NOW": break
					//case "!AOL - TRYING TO CLARIFY": break
					case "!BAD INPUT": client.country = "none"; break;
					//case "!QUEUE FULL": break
					case "!DISABLED": bCancelled = true; break;
				}
			} else if (ipInfo != "") {
				// Ip information received.
				if (right(ipInfo, 4) ~= "none") {
					client.country = "none";
				} else {
					client.country = right(ipInfo, 2);
					control.announcePlayerAttrChange(client, client.PA_Country, client.country);
				}
			}
		}
		
		// Continue with next client.
		client = client.nextClient;
	}
	
	// Disable IpToCountry support in case of errors.
	if (bCancelled) {
		ipToCountry = none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a new client has been created. Use this function to setup the new
 *                client with your own extensions (in order to support the plugin).
 *  $PARAM        client  The client that was just created.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function clientCreated(NexgenClient client) {
	client.addController(class'NexgenClientCore');
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a player has joined the game (after its login has been accepted).
 *  $PARAM        newClient  The player that has joined the game.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerJoined(NexgenClient newClient) {
	local NexgenClient client;
	local string args;
	local string playerName;
	
	// Signal player join events, step 1: new client to all others.
	args = getPlayerJoinEventArgs(newClient);
	for (client = control.clientList; client != none; client = client.nextClient) {
		// Cannot send to itself yet, client has to be initialized first. This can be safely done
		// in step 2 (see clientInitialized).
		if (client != newClient) {
			client.playerEvent(newClient.playerNum, client.PE_PlayerJoined, args);
		}
	}
	
	// Restore saved player data.
	playerName = class'NexgenUtil'.static.trim(newClient.pDat.get(newClient.PA_Name));
	if (control.gInf.bNoNameChange && playerName != "" && playerName != newClient.playerName) {
		newClient.changeName(playerName);
	}
	newClient.bMuted = newClient.pDat.getBool(PA_Muted);
	newClient.bNoTeamSwitch = newClient.pDat.getBool(PA_NoTeamSwitch);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a client has finished its initialisation process. During this
 *                process things such as the remote control window are created. So only after the
 *                client is fully initialized all functions can be safely called.
 *  $PARAM        client  The client that has finished initializing.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function clientInitialized(NexgenClient newClient) {
	local NexgenClient client;
	local string args;
	
	// Signal player join events, step 2: all others to new client.
	for (client = control.clientList; client != none; client = client.nextClient) {
		args = getPlayerJoinEventArgs(client);
		newClient.playerEvent(client.playerNum, client.PE_PlayerJoined, args);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Generates a string containing the relevant arguments for a player join event.
 *  $PARAM        client  The player that has joned the game.
 *  $REQUIRE      client != none
 *  $RETURN       A string representation of the arguments.
 *  $ENSURE       result != ""
 *
 **************************************************************************************************/
function string getPlayerJoinEventArgs(NexgenClient client) {
	local string args;
	local int teamNum;
	
	teamNum = client.team;
	if (client.bSpectator) {
		teamNum = 5;
	} else if (teamNum < 0 || teamNum > 3) {
		teamNum = 4;
	}
	
	class'NexgenUtil'.static.addProperty(args, client.PA_ClientID, client.playerID);
	class'NexgenUtil'.static.addProperty(args, client.PA_IPAddress, client.ipAddress);
	class'NexgenUtil'.static.addProperty(args, client.PA_Name, client.playerName);
	class'NexgenUtil'.static.addProperty(args, client.PA_Title, client.title);
	class'NexgenUtil'.static.addProperty(args, client.PA_Team, teamNum);
	class'NexgenUtil'.static.addProperty(args, client.PA_Country, client.country);
	
	return args;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called if a player has left the server.
 *  $PARAM        oldClient  The player that has left the game.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerLeft(NexgenClient oldClient) {
	local NexgenClient client;
		
	// Signal player left events.
	for (client = control.clientList; client != none; client = client.nextClient) {
		client.playerEvent(oldClient.playerNum, client.PE_PlayerLeft);
	}
	
	// Store saved player data.
	oldClient.pDat.set(oldClient.PA_Name, oldClient.playerName);
	oldClient.pDat.set(PA_Muted, oldClient.bMuted);
	oldClient.pDat.set(PA_NoTeamSwitch, oldClient.bNoTeamSwitch);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deals with a client that has switched to another team.
 *  $PARAM        client  The client that has changed team.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerTeamChanged(NexgenClient client) {
	control.announcePlayerAttrChange(client, client.PA_Team, client.team);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deals with a client that has changed his or her name.
 *  $PARAM        client             The client that has changed name.
 *  $PARAM        oldName            The old name of the player.
 *  $PARAM        bWasForcedChanged  Whether the name change was forced by the controller.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerNameChanged(NexgenClient client, string oldName, bool bWasForcedChanged) {
	control.announcePlayerAttrChange(client, client.PA_Name, client.playerName);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game is executing it's first tick.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function firstTick() {
	// Get IP-to-country actor.
	foreach allActors(class'Actor', ipToCountry, 'IpToCountry') {
		break;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	pluginName="Nexgen core controller"
	pluginAuthor="Zeropoint"
	pluginVersion="1.12 build 1154"
}