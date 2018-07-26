/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPlayerInfo
 *  $VERSION      1.00 (20-12-2010 15:28:24)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Player info storage. This class is used to maintain a list of players at the
 *                client, so player information can be retrieved at any moment.
 *
 **************************************************************************************************/
class NexgenPlayerInfo extends Info;

var NexgenPlayerInfo nextPlayer;                  // Next player in the linked list.

var int playerNum;                                // Player num.
var string playerName;                            // Name used by the player.
var string playerTitle;                           // Title of the players account.
var string ipAddress;                             // IP Address.
var string clientID;                              // Client identification code.
var string countryCode;                           // Country code based on the IP Address.
var byte teamNum;                                 // Team number.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified player to the player list.
 *  $PARAM        player  The player info object that is to be added to the player list.
 *  $REQUIRE      player != none && getPlayer(player.playerNum) == none
 *  $ENSURE       getPlayer(player.playerNum) == player
 *
 **************************************************************************************************/
function addPlayer(NexgenPlayerInfo player) {
	if (nextPlayer == none) {
		nextPlayer = player;
	} else {
		nextPlayer.addPlayer(player);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the player with the specified player number.
 *  $PARAM        playerNum  Number of the player that is to be retrieved.
 *  $RETURN       The player info object for the specified player. In case no player with the
 *                specified number exists, none will be returned.
 *  $ENSURE       imply(result != none, result.playerNum == playerNum)
 *
 **************************************************************************************************/
function NexgenPlayerInfo getPlayer(int playerNum) {
	if (playerNum == self.playerNum) {
		return self;
	} else if (nextPlayer == none) {
		return none;
	} else {
		return nextPlayer.getPlayer(playerNum);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the player with the specified player number from the player list.
 *  $PARAM        playerNum  Number of the player that is to be removed.
 *  $ENSURE       new.getPlayer(playerNum) == none
 *
 **************************************************************************************************/
function removePlayer(int playerNum) {
	local NexgenPlayerInfo deletedPlayer;
	
	if (nextPlayer != none) {
		if (playerNum == nextPlayer.playerNum) {
			deletedPlayer = nextPlayer;
			nextPlayer = deletedPlayer.nextPlayer;
			deletedPlayer.nextPlayer = none;
			deletedPlayer.destroy();
		} else {
			nextPlayer.removePlayer(playerNum);
		}
	}
}