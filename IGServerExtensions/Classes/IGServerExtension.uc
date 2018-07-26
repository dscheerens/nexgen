/***************************************************************************************************
 *
 *  IGSRVEXT. IG Generation 3 server extension by Zeropoint.
 *
 *  $CLASS        IGServerExtension
 *  $VERSION      1.01 (16-3-2008 15:48)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  IG server extension Nexgen plugin.
 *
 **************************************************************************************************/
class IGServerExtension extends NexgenPlugin;

var SmartCTFGameReplicationInfo SCTFGame;

// Extra player attributes.
const PA_Captures = "captures";
const PA_Assists = "assists";
const PA_Grabs = "grabs";
const PA_Covers = "covers";
const PA_Seals = "seals";
const PA_FlagKills = "flagKills";
const PA_DefKills = "defKills";
const PA_Frags = "frags";
const PA_HeadShots = "headShots";

// Misc settings.
const maxMultiScoreInterval = 3.0;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {
	
	control.sConf.serverInfoPanelClass = class'IGSXRCPServerInfo';
	
	foreach allActors(class'SmartCTFGameReplicationInfo', SCTFGame) {
		break;
	}
	
	return true;
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
	client.addController(class'IGSXClient', self);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a player has joined the game (after its login has been accepted).
 *  $PARAM        client  The player that has joined the game.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerJoined(NexgenClient client) {
	local SmartCTFPlayerReplicationInfo pri;
	
	// Restore saved player data.
	if (SCTFGame != none) {
		pri = SCTFGame.getStats(client.player);
		if (pri != none) {
			pri.captures  = client.pDat.getInt(PA_Captures,  pri.captures);
			pri.assists   = client.pDat.getInt(PA_Assists,   pri.assists);
			pri.grabs     = client.pDat.getInt(PA_Grabs,     pri.grabs);
			pri.covers    = client.pDat.getInt(PA_Covers,    pri.covers);
			pri.seals     = client.pDat.getInt(PA_Seals,     pri.seals);
			pri.flagKills = client.pDat.getInt(PA_FlagKills, pri.flagKills);
			pri.defKills  = client.pDat.getInt(PA_DefKills,  pri.defKills);
			pri.frags     = client.pDat.getInt(PA_Frags,     pri.frags);
			pri.headShots = client.pDat.getInt(PA_HeadShots, pri.headShots);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called if a player has left the server.
 *  $PARAM        client  The player that has left the game.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerLeft(NexgenClient client) {
	local SmartCTFPlayerReplicationInfo pri, cPRI;
	
	// Store saved player data.
	if (SCTFGame != none) {
		//pri = SCTFGame.getStats(client.player);
		foreach allActors(class'SmartCTFPlayerReplicationInfo', cPRI) {
			if (cPRI.owner == none) {
				if (pri == none) {
					pri = cPRI;
				} else {
					// Multiple pri's without owner, can't find player relations.
					pri = none;
					break;
				}
			}
		}
		
		if (pri != none) {
			client.pDat.set(PA_Captures,  pri.captures);
			client.pDat.set(PA_Assists,   pri.assists);
			client.pDat.set(PA_Grabs,     pri.grabs);
			client.pDat.set(PA_Covers,    pri.covers);
			client.pDat.set(PA_Seals,     pri.seals);
			client.pDat.set(PA_FlagKills, pri.flagKills);
			client.pDat.set(PA_DefKills,  pri.defKills);
			client.pDat.set(PA_Frags,     pri.frags);
			client.pDat.set(PA_HeadShots, pri.headShots);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player was killed by another player.
 *  $PARAM        killer  The pawn that killed the other pawn. Might be none.
 *  $PARAM        victim  Pawn that was the victim.
 *
 **************************************************************************************************/
function scoreKill(Pawn killer, Pawn victim) {
	local NexgenClient client;
	local IGSXClient xClient;
	
	if (killer != none && victim != none && killer != victim) {
		// Get extended client controller.
		client = control.getClient(killer);
		if (client != none) {
			xClient = IGSXClient(client.getController(class'IGSXClient'.default.ctrlID));
		}
		
		if (xClient != none) {
			// Check for double, multi, ultra and monsterrrrrrrr kills.
			if (level.timeSeconds - xClient.lastKillTime < maxMultiScoreInterval) {
				xClient.multiLevel++;
				level.game.broadcastLocalizedMessage(class'IGSXMultiKillMessage', xClient.multiLevel, killer.playerReplicationInfo);
			} else {
				xClient.multiLevel = 0;
			}
			
			// Update last kill time.
			xClient.lastKillTime = level.timeSeconds;
		}
		
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	pluginName="IG 3 server extensions"
	pluginAuthor="Zeropoint"
	pluginVersion="1.06 build 1014"
}

