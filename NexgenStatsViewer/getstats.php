<?php

/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $FILE         getstats.php
 *  $VERSION      1.01 (27-6-2008 18:36)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  The server side script that provides an interface for the Nexgen statistics viewer
 *                plugin and UTStats.
 *
 **************************************************************************************************/

/***** CONSTANTS *****/
define('MAX_NUMBER_OF_LISTS', 5);
define('MAX_NUMBER_OF_PLAYERS', 30);



/***** CONFIG *****/

// List settings.
add_player_list('db_host1', 'db_name1', 'db_user1', 'db_password1', 'Tournament DeathMatch', 5, 'Top DM players');
//add_player_list('db_host2', 'db_name2', 'db_user2', 'db_password2', 'Capture the Flag', 5, 'Top CTF players');
//add_player_list('db_host3', 'db_name3', 'db_user3', 'db_password3', 'Assault', 5, 'Top AS players');




/***** MAIN *****/

// Initialze.
$last_db_host = '';
$last_db_name = '';
$last_db_user = '';
$db_link = false;

// For each player list...
$player_list_index = 0;
$player_count = 0;
while ($player_list_index < sizeof($player_lists) &&
       $player_list_index < MAX_NUMBER_OF_LISTS &&
       $player_count < MAX_NUMBER_OF_PLAYERS) {
	
	// Connect to database.
	$curr_db_host = $player_lists[$player_list_index]['db_host'];
	$curr_db_name = $player_lists[$player_list_index]['db_name'];
	$curr_db_user = $player_lists[$player_list_index]['db_user'];
	$curr_db_password = $player_lists[$player_list_index]['db_password'];
	if ($curr_db_host != $last_db_host ||
	    $curr_db_user != $last_db_user) {
		if ($db_link) {
			mysql_close($db_link);
		}
		$db_link = mysql_connect($curr_db_host, $curr_db_user, $curr_db_password) or die('unable to connect to database, '.mysql_error());
		mysql_select_db($curr_db_name) or die('could not select database, '.mysql_error());
	} else if ($curr_db_name != $curr_db_host) {
		mysql_select_db($curr_db_name) or die('could not select database, '.mysql_error());
	}
	$last_db_host = $curr_db_host;
	$last_db_name = $curr_db_name;
	$last_db_user = $curr_db_user;
	
	// Get list details.
	$game_name = $player_lists[$player_list_index]['game_name'];
	$num_players = $player_lists[$player_list_index]['num_players'];
	$list_title = $player_lists[$player_list_index]['list_title'];
	
	// Retrieve game id.
	$query = "select id from uts_games where name = '".mysql_real_escape_string($game_name)."' limit 1";
	$result = mysql_query($query);
	if ($r = mysql_fetch_array($result)) {
		$game_id = $r['id'];
	} else {
		$game_id = 0;
	}
	
	// Get player list.
	if ($game_id > 0) {
		$query = "select pid, rank, prevrank from uts_rank where gid = $game_id order by rank desc limit $num_players";
		$result = mysql_query($query);
		if (mysql_num_rows($result) > 0) {
			println('beginlist "'.str_replace('"', '\\"', $list_title).'"');
		}
		while (($r = mysql_fetch_array($result)) && $player_count < MAX_NUMBER_OF_PLAYERS) {
			// Get player rank info.
			$player_id = $r['pid'];
			$rank = $r['rank'];
			$previous_rank = $r['prevrank'];
			
			// Get player info.
			$query = "select name, country from uts_pinfo where id = $player_id limit 1";
			$result2 = mysql_query($query);
			$r2 = mysql_fetch_array($result2);
			$player_name = $r2['name'];
			$player_country = $r2['country'];
			mysql_free_result($result2);
			if (substr($player_name, -1) == '\\') {
				$player_name .= ' ';
			}
			
			// Process data.
			if ($rank > $previous_rank) {
				$rank_change = 'up';
			} else if ($rank < $previous_rank) {
				$rank_change = 'down';
			} else {
				$rank_change = 'nc';
			}
			
			// Echo player info.
			println('addplayer "'.str_replace('"', '\\"', $player_name).'" '.round($rank).' '.$player_country.' '.$rank_change);
			
			// Continue with next player.
			$player_count++;
		}
		
		mysql_free_result($result);
	}
	
	// Continue with next list.
	$player_list_index++;
}

// End of execution, no more output is desired!
die();



/***** FUNCTIONS *****/

/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new player list that will be displayed on the server.
 *  $PARAM        $game_name    The name of the game type.
 *  $PARAM        $num_players  Number of players to display in the list.
 *  $PARAM        $list_title   Display title of the list on server.
 *
 **************************************************************************************************/
function add_player_list($db_host, $db_name, $db_user, $db_password, $game_name, $num_players = 10, $list_title = '') {
	global $player_lists;
	
	if (trim($list_title) == '') {
		$list_title = $game_name;
	}
	
	$player_lists[] = array('game_name' => $game_name,
	                        'num_players' => $num_players,
	                        'list_title' => $list_title,
	                        'db_host' => $db_host,
	                        'db_name' => $db_name,
	                        'db_user' => $db_user,
	                        'db_password' => $db_password);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Writes a line to the output.
 *  $PARAM        $text  The text that is to be written.
 *
 **************************************************************************************************/
function println($text) {
	echo $text."\r\n";
}
?>