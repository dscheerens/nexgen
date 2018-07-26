/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenGameInfo
 *  $VERSION      1.06 (14-6-2008 13:39)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Extended game info container class. Stores all Nexgen related game extension data.
 *
 **************************************************************************************************/
class NexgenGameInfo extends ReplicationInfo;

var int updateCount;                    // How many times the settings have been updated during the
                                        // current game. Used to detect setting changes clientside.
var bool bTeamsLocked;                  // Teams have been locked. Nobody may switch or join (as player).
var bool bNoTeamSwitch;                 // Whether team switching has been disabled. 
var bool bNoTeamBalance;                // Whether team balancing has been disabled.
var byte gameState;                     // Current state of the game.
var int countDown;                      // Countdown timer for the gamestate.
var byte matchAdminCount;               // Number of match admins logged in.
var byte maxTeams;                      // Number of teams available in the game.
var bool bMuteAll;                      // Whether all players are muted.
var float gameSpeed;                    // Game speed multiplier.
var bool bNoNameChange;                 // Whether players can't change their name during the game.
var byte rebootCountDown;               // Seconds remaining before the server will be rebooted.
var bool bTournamentMode;               // Whether tournament mode is enabled.
var byte numReady;                      // Number of players that have send a ready signal.
var byte numRequiredReady;              // Required number of players that should send a ready signal.

var class<HUD> originalHUDClass;        // Original HUD class used.

// Game states.
const GS_Waiting = 0;                   // Waiting for players.
const GS_Ready = 1;                     // Ready for launch.
const GS_Starting = 2;                  // Game is starting.
const GS_Playing = 3;                   // Game is in progress.
const GS_Ended = 4;                     // The game has ended.

// Game info change events
const IT_GlobalRights = 0;              // Global game rights.
const IT_GameSettings = 1;              // General game settings.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

	reliable if (role == ROLE_Authority)
		originalHUDClass,
		
		bTeamsLocked, bNoTeamSwitch, bNoTeamBalance, gameState, countDown, maxTeams, bMuteAll,
		gameSpeed, bNoNameChange, rebootCountDown, bTournamentMode, numReady, numRequiredReady,

		updateCount;

}