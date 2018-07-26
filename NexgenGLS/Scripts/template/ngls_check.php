<?php

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

// Check login information.
$login_result = 'login_ok';
//$login_result = 'deactivated';
//$login_result = 'suspended';
//$login_result = 'banned';
//$login_result = 'unknown_user';
//$login_result = 'invalid_password';

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