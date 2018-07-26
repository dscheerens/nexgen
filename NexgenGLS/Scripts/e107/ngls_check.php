<?php

// Database settings.
$db_host = 'localhost';
$db_name = 'database_name';
$db_user = 'username';
$db_password = 'password';

// Get request parameters.
$player_num	= get_request_value('checkplayer');
$game_id	= get_request_value('gameid');
$username	= get_request_value('username');
$password	= get_request_value('password');

// Check request parameters.
if (trim($player_num) == '' || trim($game_id) == '' ||
    trim($username) == '' || trim($password) == '') {
	die('invalid request');
}

// Connect to database.
$db_link = mysql_connect($db_host, $db_user, $db_password) or die('could not connect to database');
mysql_select_db($db_name) or die('could not select database');

// Check login information.
$query = 'select user_password as pw_hash, user_ban from e107_user where strcmp(user_loginname, \''.mysql_real_escape_string($username).'\') = 0 limit 1';
$result = mysql_query($query) or die('query failed');
if ($r = mysql_fetch_assoc($result)) {
	if (strtoupper($r['pw_hash']) != strtoupper($password)) {
		$login_result = 'invalid_password';
	} elseif ($r['user_ban'] > 0) {
		$login_result = 'banned';
	} else {
		$login_result = 'login_ok';
	}
} else {
	$login_result = 'unknown_user';
}
mysql_free_result($result);

// Close database connection.
mysql_close($db_link);

// Send answer back to UT server.
if ($login_result == 'login_ok') {
	die('ACCEPT '.$game_id.' '.$player_num);
} else {
	die('REJECT '.$game_id.' '.$player_num.' '.$login_result);
}

function get_request_value($key, $default_value = '') {
	return (array_key_exists($key, $_REQUEST) ? $_REQUEST[$key] : $default_value);
}

?>