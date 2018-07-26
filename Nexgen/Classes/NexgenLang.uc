/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenLang
 *  $VERSION      1.42 (14-05-2010 15:11)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Localization support class. Provides the language dependant functionality of the
 *                Nexgen server controller.
 *
 **************************************************************************************************/
class NexgenLang extends Info;

const dateFormatStr = "dd/mm/yyyy hh:mm";

const defaultLogFileNameFormat = "nsc_%Y_%m_%d_%H_%i_%s";
const defaultLogFileTimeStampFormat = "[%d/%m/%Y %H:%i:%s]";
const longDateTimeFormat = "%l, %F %j, %Y, %H:%i:%s";

const startingControllerMsg = "Starting Nexgen Server Controller...";
const noDedicatedServerMsg = "Failed, your server should be dedicated.";
const compatibilityModeMsg = "%1 has been detected, entering compatibility mode...";
const autoInstallMsg = "First time run, executing default installation...";
const autoUpdateMsg = "Updating Nexgen configuration to version %1...";
const invalidConfigMsg = "Configuration file has been automatically repaired.";
const attrServerIDMsg = "ServerID = %1";
const nexgenBootMsg = "Server crash/reboot detected, executing Nexgen boot sequence...";
const nexgenMapLoadFailMsg = "Warning, attempt to load %1 has failed!";
const nexgenBootFailMsg = "Nexgen boot sequence failed, resuming to normal mode.";
const execCommandMsg = "EXEC %1";
const bootLevelSwitchMsg = "Restarting server on %1";
const nexgenActiveMsg = "Nexgen Server Controller is active.";
const logFileCreateFailed = "Failed to create log file: %1";
const logFileCreated = "Log file created, logging to: %1";

const loadingPluginMsg = "Loading %1 %2...";
const initFailedMsg = "Failed to initialize %1, destroying...";
const regFailedMsg = "Failed to register %1, destroying...";

const pluginConfigFailedMsg = "Unable to load configuration for %1";
const pluginConfigRepairedMsg = "%1 configuration file was corrupt and has been repaired.";

const loginRequestMsg = "Login request for %1";
const attrClientIPMsg = "IP       = %1";
const attrClientIDMsg = "ClientID = %1";
const attrPasswordMsg = "Password = %1";
const illegalLoginParametersMsg = "Illegal login parameters (possible hack).";
const duplicateIDMsg = "Client ID already in use.";
const bannedMsg = "Kicked/banned from the server.";
const invalidPassMsg = "Invalid password.";
const serverCapacityMsg = "Server is full.";
const noPlayRightMsg = "No playing rights.";
const loginAcceptedMsg = "Login accepted.";
const loginRejectedMsg = "Login denied. Reason: %1";

const logFileTitle = "NEXGEN LOG FILE";	
const logFileEngineVersion = "engine-version: %1";
const logFileNexgenVersion = "nexgen-version: %1";
const logFileServerID = "server-id     : %1";
const logFileServerName = "server-name   : %1";
const logFileServerPort = "server-port   : %1";
const logFileGameClass = "game-class    : %1";
const logFileLevelName = "level-name    : %1";
const logFileLevelTitle = "level-title   : %1";
const logFileStart = "Log started at %1";
const logFileClose = "Log closed at %1";

const gameStartedMsg = "The game has started.";
const gameEndedMsg = "The game has ended after %1 sec.";
		
const playerJoinMsg = "<C07>(+%2) %1";
const playerLeaveMsg = "<C04>(-%2) %1";
const playerNameChangeMsg = "<C07>%1 has changed his/her name to %2.";
const playerLeaveLogMsg = "%1 has left the server.";
const teamSwitchFailMsg = "<C00>Failed to switch team, %1.";
const teamsLockedMsg = "the teams are locked";
const nameChangeFailMsg = "<C00>Failed to change name, %1.";
const nameChangeDisabled = "name change has been disabled";

const invalidCommandMsg = "<C00>Invalid Nexgen command or parameters.";
const commandFailedMsg = "<C00>Failed to execute command, %1.";
const internalErrorMsg = "internal error";
const teamSwitchFailedMsg = "<C00>Failed to switch team, %1.";
const specTeamSwitchMsg = "spectators can't switch team";
const teamSwitchDisabledMsg = "team switching is disabled on this server";
const playerTeamSwitchDisabledMsg = "you are not allowed to change from team";
const invalidTeamMsg = "team doesn't exist";
const sameTeamMsg = "you are already on %1";
const noSpecsAllowedMsg = "this server doesn't allow spectators";
const noMoreSpecSlotsMsg = "all spectator slots are taken";
const noPlayingRightsMsg = "you do not have playing rights on this server";
const noMorePlayerSlotsMsg = "all player slots are taken";
const teamBalanceFailedMsg = "<C00>Failed to balance teams, %1.";
const notATeamGameMsg = "this command is only available for team games";
const teamBalanceDisabledMsg = "team balancing is disabled";
const teamsAlreadyBalancedMsg = "the teams are already balanced";
const balanceMsg = "<C07>%1 has balanced the teams.";
const launchMsg = "<C07>%1 has started the game.";
const playerReadyMsg = "<C07>%1 is READY!";

const forcedEndMsg = "The game has been forced to an end.";

const rootAdminTitle = "Root Admin";
const specTitle = "Spectator";

const deathPreventedMsg = "The server has prevented you from dying.";

const mutedReminderMsg = "<C07>Unable to send message, you are muted.";

const accountTypeNameStr = "Account type %1";

const teamKillAttemptMsg = "%1 had a team kill attempt against %2.";

const httpClientErrorMsg = "HTTP client error: %1";

const accouncePMToMsgSpecMsg = "[NSC Private Message][%1] to [%2]";
const accouncePMToMsgSpecPlayer = "%1/%2/%3";
const accouncePMToMsgSpecLine = "[NSC Private Message][Line %1] %2";

const controllerSystemLogTag = "[NSC-SYS]";
const eventLogTag = "[ EVENT ]";
const messageLogTag = "[MESSAGE]";
const chatMessageLogTag = "[  SAY  ]";
const teamSayMessageLogTag = "[TEAMSAY]";
const privateMessageLogTag = "[ PMSAY ]";
const adminActionLogTag = "[ ADMIN ]";

const allowedToPlayRightDesc = "Allowed to play on server.";
const vipSlotAccessRightDesc = "VIP slot access.";
const adminSlotAccessRightDesc = "Admin slot access.";
const needsNoPWRightDesc = "Password immune.";
const canBeIdleRightDesc = "Can be idle.";
const matchAdminRightDesc = "Game supervisor.";
const matchSetRightDesc = "Setup matches.";
const moderatorRightDesc = "Moderate.";
const banOpRightDesc = "Ban operator.";
const accountMngrRightDesc = "Manage accounts.";
const serverAdminRightDesc = "Server administrator.";
const canBanAccountsRightDesc = "Ban registered players.";
const hiddenAdminRightDesc = "Hidden admin.";

const launchGameMsg = "<C07>Press [Fire] to start the game.";
const adminLaunchGameMsg = "<C07>Please wait, an administrator is going to start the game.";
const tournamentLaunchGameMsg = "<C07>Waiting for ready signals, press [Fire] to send your ready signal!";

const serverCrashedClientMsg = "<C00>The server has crashed and has been reloaded!";
const bootFailedClientMsg = "<C00>The Nexgen boot sequence has failed, please contact the server administrator!";
const serverAdminRebootClientMsg = "<C07>The server was restarted by an administrator and has been reloaded!";

const welcomeMsg = "<C07>Welcome to Nexgen, type !open to open the control panel.";

const settingsSavedMsg = "<C07>New settings have been saved.";

const receivedPMMsg = "<C04>[PM] %3 %1: %2";

const receivedPWMsg = "<C07>Match password received: '%1'";

const passwordSendMsg = "<C07>The password has been send.";

const noBanAccountRightMsg = "<C07>You are not allowed to kick or ban players that have an account on this server.";

const adminTeamSwitchMsg = "<C07>%1 has moved %2 to %3.";
const adminPauseGameMsg = "<C07>%1 has paused the game.";
const adminResumeGameMsg = "<C07>%1 has resumed the game.";
const adminRestartGameMsg = "<C07>%1 has restarted the game.";
const adminStopGameMsg = "<C07>%1 has stopped the game.";
const adminPlayerTeamSwitchDisableMsg = "<C07>%1 has disabled team switching for %2.";
const adminPlayerTeamSwitchEnableMsg = "<C07>%1 has enabled team switching for %2.";
const adminReconnectAsPlayerMsg = "<C07>%1 has reconnected %2 as player.";
const adminReconnectAsSpecMsg = "<C07>%1 has reconnected %2 as spectator.";
const adminSendToURLMsg = "<C07>%1 has send %2 to %3.";
const adminDisableTeamSwitchMsg = "<C07>%1 has disabled team switching.";
const adminEnableTeamSwitchMsg = "<C07>%1 has enabled team switching.";
const adminDisableTeamBalanceMsg = "<C07>%1 has disabled team balancing.";
const adminEnableTeamBalanceMsg = "<C07>%1 has enabled team balancing.";
const adminLockTeamsMsg = "<C07>%1 has locked the teams.";
const adminUnlockTeamsMsg = "<C07>%1 has unlocked the teams.";
const adminAddBanMsg = "<C07>%1 has added %2 to the banlist.";
const adminDeleteBanMsg = "<C07>%1 has removed %2 from the banlist.";
const adminEnableMatchModeMsg = "<C07>%1 has set the server in match mode.";
const adminDisableMatchModeMsg = "<C07>%1 has reset the server in normal mode.";
const adminMutePlayerMsg = "<C07>%1 has muted %2.";
const adminUnmutePlayerMsg = "<C07>%1 has unmuted %2.";
const adminSetNameMsg = "<C07>%1 has renamed %2 to %3.";
const adminKickPlayerMsg = "<C07>%1 has kicked %2 from the server.";
const adminBanPlayerMsg = "<C07>%1 has banned %2 from the server.";
const adminMuteAllMsg = "<C07>%1 has muted all players.";
const adminUnmuteAllMsg = "<C07>%1 has unmuted all players.";
const adminEnableNameChangeMsg = "<C07>%1 has allowed nickname changing on the server.";
const adminDisableNameChangeMsg = "<C07>%1 has disabled nickname changing on the server.";
const adminRebootServerMsg = "<C07>%1 has rebooted the server.";
const adminEnableTournamentModeMsg = "<C07>%1 has enabled tournament mode.";
const adminDisableTournamentModeMsg = "<C07>%1 has disabled tournament mode.";
const adminForceGameStart = "<C07>%1 has forced the game to start.";

const adminAddAccountType = "<C07>%1 has created a new account type named: %2.";
const adminUpdateAccountType = "<C07>%1 has modified the %2 account type.";
const adminRemoveAccountType = "<C07>%1 has removed the %2 account type.";
const adminMoveAccountType = "<C07>%1 has repositioned the %2 account type.";
const adminRemoveAccount = "<C07>%1 has deleted the account %3 for %2.";
const adminUpdateAccount = "<C07>%1 has modified the account for %2.";
const adminAddAccount = "<C07>%1 has created a new %3 account for %2.";
const adminUpdateBanMsg = "<C07>%1 has modified the ban entry for %2.";
const adminUpdateBootControl = "<C07>%1 has modified the boot control settings.";
const adminSeparateByTag = "<C07>%1 has separated the players by their tag.";
const adminUpdateMatchSettings = "<C07>%1 has modified the match settings.";
const adminUpdateIgnoredWeaponList = "<C07>%1 has modified the spawn protect ignored weapon list.";
const adminUpdateGlobalServerSettings = "<C07>%1 has modified the basic server settings.";
const adminUpdateMiscNexgenSettings = "<C07>%1 has modified the general Nexgen settings.";
const adminUpdateLogServerSettings = "<C07>%1 has modified the log settings.";

const invalidPasswordMsg = "<C07>Unable to login as administrator, invalid password.";
const adminLoginMsg = "<C07>%1 has logged in as %2.";

const autoReconnectAlert = "Connection lost!\\nReconnecting in %1...";
const reconnectingAlert = "Connection lost!\\nReconnecting now...";
const rebootAlert = "Warning, reboot sequence activated!\\nRebooting server in %1...";
const idleAlert = "Idle / camper detection activated!\\nMove or be kicked in %1...";

const waitingState = "Waiting [%1]";
const waitingStateUnknownTime = "Waiting...";
const readyState = "Ready...";
const readySignalWaitState = "Ready [%1/%2]";
const startingState = "Starting [%1]";
const onlineState = "Online [%1]";
const offlineState = "Offline";
const offlineStateRCN = "Offline [%1]";
const endedState = "Ended";
const pausedState = "Paused";
const loginState = "Logging in";
const idleState = "Idle [%1]";
const mutedState = "Muted";
const protectedState = "Protected [%1]";
const deadState = "Dead";
const matchState = "Match [%1]";
const loadingState = "Loading...";

const clientTabTxt = "Client";
const homeTabTxt = "Home";
const settingsTabTxt = "Settings";
const privateMessageTabTxt = "Private message";
const gameTabTxt = "Game";
const playersTabTxt = "Players";
const moderatorTabTxt = "Moderator";
const matchControlTabTxt = "Match control";
const matchSetupTabTxt = "Match setup";
const serverTabTxt = "Server";
const infoTabTxt = "Info";
const banControlTabTxt = "Ban control";
const accountsTabTxt = "Accounts";
const accountTypesTabTxt = "Account types";
const basicSettingsTabTxt = "Basic";
const nexgenSettingsTabTxt = "Nexgen";
const bootTabTxt = "Boot control";
const pluginsTabTxt = "Plugins";
const aboutTabTxt = "About";

const welcomeTxt = "Welcome %1, you are logged in as %2.";
const rightsOverviewTxt = "The following privileges / rights are available to you on this server:";
const rightNotDefinedTxt = "Privilege %1 (not defined).";
const teamBalanceTxt = "Team balance";
const redTeamTxt = "Red";
const blueTeamTxt = "Blue";
const greenTeamTxt = "Green";
const goldTeamTxt = "Yellow";
const playTxt = "Play";
const spectateTxt = "Spectate";
const reconnectTxt = "Reconnect";
const disconnectTxt = "Disconnect";
const exitTxt = "Exit";
const mapVoteTxt = "Open mapvote";
const startTxt = "Start game";
const loginTxt = "Admin login";

const serverNameTxt = "Server name:";
const shortServerNameTxt = "Short server name:";
const MOTDLineTxt = "MOTD line %1";
const adminNameTxt = "Admin name:";
const adminEmailTxt = "Admin email:";
const serverPasswordTxt = "Server password:";
const adminPasswordTxt = "Admin password:";
const playerSlotsTxt = "Player slots:";
const vipSlotsTxt = "VIP slots:";
const adminSlotsTxt = "Admin slots:";
const specSlotsTxt = "Spectator slots:";
const variablePlayerSlotsTxt = "Variable slots:";
const advertiseTxt = "Advertise server:";
const resetTxt = "Reset";
const saveTxt = "Save";

const keyBindsTxt = "Keybinds";
const balanceBindTxt = "Balance teams";
const switchRedBindTxt = "Switch to red";
const switchBlueBindTxt = "Switch to blue";
const switchGreenBindTxt = "Switch to green";
const switchGoldBindTxt = "Switch to yellow";
const suicideBindTxt = "Suicide";
const openMapVoteBindTxt = "Open map vote";
const openCPBindTxt = "Open control panel";
const pauseGameBindTxt = "Pause game";
const UISettingsTxt = "User interface";
const enableMsgHUDTxt = "Enable Nexgen message HUD";
const msgFlashEffectTxt = "Enable message 'flash' effect";
const showPlayerLocationTxt = "Show player location on teamsay messages";
const pmSoundTxt = "Play a sound when a private message arrives";
const miscSettingsTxt = "Miscellaneous settings";
const autoSSNormalGameTxt = "Auto screenshot at the end of normal games";
const autoSSMatchTxt = "Auto screenshot at the end of matches";

const playerListTxt = "Players";
const blockedListTxt = "Blocked";
const blockToggleTxt = "Block / Unblock";
const blockAllPMsTxt = "Block all private messages";
const messageTxt = "Message";
const sendNormalPMTxt = "Send normal PM";
const sendWindowedPMTxt = "Send windowed PM";
const historyTxt = "History";
const blockMsg = "%1 has been blocked.";
const unblockMsg = "%1 has been unblocked.";
const sendMsgTxt = "Send to %1: %2";
const receivedMsgTxt = "%1: %2";

const accountNameTxt = "Account name";
const accountTitleTxt = "Account title";
const passwordTxt = "Password";
const addAccountTypeTxt = "Add account type";
const delAccountTypeTxt = "Delete account type";
const moveUpTxt = "Move up";
const moveDownTxt = "Move down";

const userNameTxt = "User name";
const accountTypeTxt = "Account type";
const userTitleTxt = "User title";
const onlineTxt = "Online";
const offlineTxt = "Offline";
const updateTxt = "Update";
const addTxt = "Add";
const deleteTxt = "Delete";
const customAccountTxt = "<Custom>";

const switchToTeamTxt = "Switch to %1";
const sendToURLTxt = "Send to URL";
const reconnectAsPlayerTxt = "Reconnect as player";
const reconnectAsSpecTxt = "Reconnect as spectator";
const disableTeamSwitchTxt = "(Dis)allow team switch";
const pauseGameTxt = "Pause game";
const endGameTxt = "End game";
const restartGameTxt = "Restart game";
const allowTeamSwitchTxt = "Allow team switching";
const allowTeamBalanceTxt = "Allow team balancing";
const lockTeamsTxt = "Lock the game";
const tournamentModeTxt = "Tournament mode";

const playerNameTxt = "Player name";
const banReasonTxt = "Ban/kick reason";
const banPeriodTxt = "Ban period";
const banForeverTxt = "Forever";
const banMatchesTxt = "'x' matches";
const banDaysTxt = "'x' days";
const banUntilDateTxt = "Until 'date'";
const ipAddressesTxt = "IP addresses";
const clientIDsTxt = "Client IDs";
const addBanTxt = "Create new ban";
const updateBanTxt = "Update ban";
const delBanTxt = "Remove ban";
const removeTxt = "Remove";

const enableBootCtrlTxt = "Enable Nexgen boot control";
const restartOnLastGameTxt = "Restart game on last map";
const inclMutatorsTxt = "Mutators used";
const exclMutatorsTxt = "Mutators not used";
const bootCmdLineTxt = "Server boot command line";
const gameTypeTxt = "Game type";
const mapPrefixTxt = "Map prefix";
const extraCmdLineOptTxt = "Additional command line options";
const preSwitchCommandsTxt = "Pre switch server console commands";
const rebootTxt = "Reboot";

const administratorTxt = "Administrator";
const contactAddrTxt = "Contact address";
const msgOfTheDayTxt = "Message of the day";
const serverIDTxt = "Server ID";
const statisticsTxt = "Stats";
const totalGamesTxt = "Games hosted";
const totalFragsTxt = "Total frags";
const totalDeathsTxt = "Total deaths";
const totalFlagsTxt = "Total caps";
const bestPlayersTxt = "Top players";
const FPHTxt = "FPH";
const recordSetTxt = "Date";

const timeLimitTxt = "Time limit";
const scoreLimitTxt = "Score limit";
const teamScoreLimitTxt = "Team score limit";
const gameSpeedTxt = "Game speed";
const teamSwitchEnabledTxt = "Team switch enabled";
const teamBalanceEnabledTxt = "Team balancing enabled";
const teamsLockedTxt = "Teams are locked";
const nameChangeAllowedTxt = "Name change allowed";
const mutatorsTxt = "Mutators";
const levelTxt = "Level";
const fileTxt = "File";
const titleTxt = "Title";
const authorTxt = "Author";
const idealPlayerCountTxt = "Players";

const matchSettingsTxt = "Match settings";
const matchNumOfGamesTxt = "Number of games";
const matchCurrGameNumTxt = "Current game";
const matchSpecNoPassTxt = "Allow spectators to enter the game without a password";
const matchMuteSpecsTxt = "Mute spectators during the game";
const matchBootControlTxt = "Switch back to last map when the server has crashed";
const matchAutoLockTeamsTxt = "Automatically lock teams at the beginning of each game";
const matchAutoPauseTxt = "Automatically pause the game when a player leaves";
const matchSeparateByTagTxt = "Separate players by tag";
const matchAutoTagSeparateTxt = "Automatically separate by tag";
const matchDoSeparateTxt = "Separate now";
const startMatchTxt = "Start match";
const stopMatchTxt = "Stop match";
const sendPasswordTxt = "Send password";
const allPlayersTxt = "<All players>";

const clientIDTxt = "Client ID";
const ipAddressTxt = "IP address";
const muteToggleTxt = "(Un)mute";
const setPlayerNameTxt = "Set name";
const kickPlayerTxt = "Kick";
const banPlayerTxt = "Ban";
const muteAllTxt = "Mute all players";
const allowNameChangeTxt = "Allow players to change their name";
const showAdminMessageTxt = "Show message";
const copyTxt = "Copy";

const nexgenMiscSettingsPanelTitle = "General Nexgen settings";
const autoUpdateBansTxt = "Automatically update ban entries";
const autoDelExpiredBansTxt = "Automatically remove expired ban entries";
const announceTeamKillsTxt = "Broadcast team kill attempts";
const restoreScoreOnTeamSwitchTxt = "Don't decrease score on team switch";
const enableNexgenStartControlTxt = "Let Nexgen handle the game start";
const enableAdminStartControlTxt = "Game can only be started by match admins";
const broadcastAdminActionsTxt = "Broadcast administrator actions to all players";
const useNexgenHUDTxt = "Enable Nexgen HUD extensions";
const defaultAllowTeamSwitchTxt = "Team switch allowed by default";
const defaultAllowTeamBalanceTxt = "Team balance allowed by default";
const defaultAllowNameChangeTxt = "Name change allowed by default";
const autoRegisterServerTxt = "Register server in Nexgen database";
const gameWaitTimeTxt = "Game wait time (sec)";
const gameStartDelayTxt = "Game start delay (sec)";
const autoReconnectTimeTxt = "Auto reconnect time (sec)";
const maxIdleTimeTxt = "Max idle time (sec)";
const maxIdleTimeCPTxt = "Max idle time in control panel (sec)";
const spawnProtectTimeTxt = "Spawn protect time (sec)";
const teamKillDmgProtectTxt = "Team kill damage protect time (sec)";
const teamKillPushProtectTxt = "Team kill push protect time (sec)";
const autoDisableMatchTimeTxt = "Auto disable match mode time (min)";

const ignoredWeaponsTxt = "Weapons ignored by spawn protector.";
const weaponClassTxt = "Weapon class";
const ignorePrimaryFireTxt = "Ignore primary fire";
const ignoreAltFireTxt = "Ignore alternate fire";
const addNewItemTxt = "<Add new item>";

const logSettingsPanelTitle = "Log settings";
const logToConsoleTxt = "Write log messages to console (stdout)";
const logToFileTxt = "Write log messages to file";
const logEventsTxt = "Write Nexgen events to the server log";
const logFilePathTxt = "Log path";
const logFileExtensionTxt = "Log extension";
const logFileNameFormatTxt = "Log file name";
const logTimeStampFormatTxt = "Time format";
const logMessagesTxt = "Write system messages to the server log";
const logChatMessagesTxt = "Write chat messages to the server log";
const logPrivateMessagesTxt = "Write private messages to the server log";
const logAdminActionsTxt = "Write administrator actions to the server log";
const sendPrivateMessagesToMsgSpecsTxt = "Send private messages to message specators";



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the name of the team specified by the given number.
 *  $PARAM        team  Number of the team whose name is to be returned.
 *  $RETURN       The name of the team, or ? if an invalid team is specified.
 *
 **************************************************************************************************/
static function string getTeamName(int team) {
	switch (team) {
		case 0: return "red";
		case 1: return "blue";
		case 2: return "green";
		case 3: return "yellow";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Formats the given string by inserting the specified strings into the proper
 *                positions. The positions are indicated by the "%n" tags, where n is number of the
 *                string to insert.
 *  $PARAM        source  The string that is to be formatted.
 *  $PARAM        str1    String number 1 to insert.
 *  $PARAM        str2    String number 2 to insert.
 *  $PARAM        str3    String number 3 to insert.
 *  $PARAM        str4    String number 4 to insert.
 *  $RETURN       The formatted string.
 *
 **************************************************************************************************/
static function string format(string source, optional coerce string str1, optional coerce string str2,
                              optional coerce string str3, optional coerce string str4) {
	return class'NexgenUtil'.static.format(source, str1, str2, str3, str4);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts a ban period string into a human readable format.
 *  $PARAM        banPeriodStr  The string describing the ban period.
 *  $RETURN       A string describing (in words) how long the ban lasts.
 *
 **************************************************************************************************/
function string getBanPeriodDescription(string banPeriodStr) {
	local string description;
	
	if (banPeriodStr == "") {
		description = "forever";
	} else if (left(banPeriodStr, 1) ~= "M") {
		description = "for" @ mid(banPeriodStr, 1) @ "matches";
	} else if (left(banPeriodStr, 1) ~= "U") {
		description = "until" @ getLocalizedDateStr(mid(banPeriodStr, 1));
	} else {
		description = "forever";
	}
	
	return description;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns a compact date description string for the specified date.
 *  $PARAM        year    Year of the specified date.
 *  $PARAM        month   Month of the specified date.
 *  $PARAM        day     Day of the specified date.
 *  $PARAM        hour    Hour of the specified date.
 *  $PARAM        minute  Minute of the specified date.
 *  $REQUIRE      (1 <= month && moth <= 12) && (1 <= day && day <= 31) &&
 *                (0 <= hour && hour <= 23) && (0 <= minute && minute <= 59)
 *  $RETURN       The date description string for the given date.
 *
 **************************************************************************************************/
static function string getCompactDateStr(int year, int month, int day, int hour, int minute) {
	return class'NexgenUtil'.static.lfill(day, 2, "0") $ "/" $
	       class'NexgenUtil'.static.lfill(month, 2, "0") $ "/" $
	       class'NexgenUtil'.static.lfill(year, 4, "0") $ " " $
	       class'NexgenUtil'.static.lfill(hour, 2, "0") $ ":" $
	       class'NexgenUtil'.static.lfill(minute, 2, "0");
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Parses the given date string.
 *  $PARAM        dateStr  The date string to parse.
 *  $PARAM        year     Year of the specified date.
 *  $PARAM        month    Month of the specified date.
 *  $PARAM        day      Day of the specified date.
 *  $PARAM        hour     Hour of the specified date.
 *  $PARAM        minute   Minute of the specified date.
 *  $REQUIRE      'dateStr follows dateFormatStr'
 *  $RETURN       True if the specified date string was valid, false if not. When false is returned
 *                the outcome (the date) should be ignored.
 *
 **************************************************************************************************/
static function bool parseDate(string dateStr, out int year, out int month, out int day,
                               out int hour, out int minute) {
	local bool bValid;
	local string remaining;
	local int index;
	
	bValid = true;
	remaining = class'NexgenUtil'.static.trim(dateStr);
	
	// Parse day.
	index = instr(remaining, "/");
	if (index >= 0) {
		day = int(left(remaining, index));
		remaining = mid(remaining, index + 1);
	} else {
		bValid = false;
	}
	
	// Parse month.
	if (bValid) {
		index = instr(remaining, "/");
		if (index >= 0) {
			month = int(left(remaining, index));
			remaining = class'NexgenUtil'.static.trim(mid(remaining, index + 1));
		} else {
			bValid = false;
		}
	}
	
	// Parse year.
	if (bValid) {
		index = instr(remaining, " ");
		if (index >= 0) {
			year = int(left(remaining, index));
			remaining = mid(remaining, index + 1);
		} else {
			bValid = false;
		}
	}
	
	// Parse hour.
	if (bValid) {
		index = instr(remaining, ":");
		if (index >= 0) {
			hour = int(left(remaining, index));
			remaining = mid(remaining, index + 1);
		} else {
			bValid = false;
		}
	}
	
	// Parse minute.
	if (bValid) {
		minute = int(remaining);
	}
	
	// Return result.
	return bValid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the given date string into a localized format.
 *  $PARAM        dateStr  The date string to convert.
 *  $RETURN       The converted date into a localized format.
 *
 **************************************************************************************************/
function string getLocalizedDateStr(string dateStr) {
	local bool bValid;
	local int year, month, day, hour, minute;
	
	bValid = class'NexgenUtil'.static.readDate(dateStr, year, month, day, hour, minute);
	if (bValid) {
		return getCompactDateStr(year, month, day, hour, minute);
	} else {
		return dateStr;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the given localized date string into a standard format.
 *  $PARAM        dateStr  The date string to convert.
 *  $RETURN       The converted date into a standard format.
 *
 **************************************************************************************************/
function string getDelocalizedDateStr(string dateStr) {
	local bool bValid;
	local int year, month, day, hour, minute;
	
	bValid = parseDate(dateStr, year, month, day, hour, minute);
	if (bValid) {
		return class'NexgenUtil'.static.serializeDate(year, month, day, hour, minute);
	} else {
		return dateStr;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the current date in the specified format.
 *  $PARAM        The format of the date.
 *  $RETURN       The current date in the the specified format.
 *
 **************************************************************************************************/
function string getCurrentDate(string format) {
	return getDate(format,
	               level.year,
	               level.month,
	               level.day,
	               level.dayOfWeek,
	               level.hour,
	               level.minute,
	               level.second);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns given date in the specified format.
 *  $PARAM        The format of the date.
 *  $RETURN       The given date in the the specified format.
 *
 **************************************************************************************************/
static function string getDate(string format, int year, int month, int day, int dayOfWeek,
                               int hour, int minute, int second) {
	local string dateStr;
	local int value;
	local string strValue;
	
	dateStr = format;
	
	// Year.
	if (instr(dateStr, "%Y") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%Y", class'NexgenUtil'.static.lfill(year, 4, "0"));
	}
	
	if (instr(dateStr, "%y") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%y", class'NexgenUtil'.static.lfill(year, 2, "0", 2));
	}
	
	if (instr(dateStr, "%L") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%L", byte(class'NexgenUtil'.static.isLeapYear(year)));
	}

	// Month.
	if (instr(dateStr, "%m") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%m", class'NexgenUtil'.static.lfill(month, 2, "0"));
	}
	
	if (instr(dateStr, "%n") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%n", month);
	}
	
	if (instr(dateStr, "%F") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%F", getMonthName(month));
	}
	
	if (instr(dateStr, "%M") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%M", getShortMonthName(month));
	}
	
	if (instr(dateStr, "%t") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%t", class'NexgenUtil'.static.daysInMonth(year, month));
	}
	
	// Day.
	if (instr(dateStr, "%d") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%d", class'NexgenUtil'.static.lfill(day, 2, "0"));
	}
	
	if (instr(dateStr, "%j") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%j", day);
	}
	
	if (instr(dateStr, "%w") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%w", dayOfWeek);
	}
	
	if (instr(dateStr, "%N") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%N", (dayOfWeek + 1));
	}
	
	if (instr(dateStr, "%l") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%l", getDayName(dayOfWeek));
	}
	
	if (instr(dateStr, "%D") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%D", getShortDayName(dayOfWeek));
	}
	
	// Hour.
	if (instr(dateStr, "%H") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%H", class'NexgenUtil'.static.lfill(hour, 2, "0"));
	}
	
	if (instr(dateStr, "%h") >= 0) {
		value = hour % 12;
		if (value == 0) value = 12;
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%h", class'NexgenUtil'.static.lfill(value, 2, "0"));
	}
	
	if (instr(dateStr, "%G") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%G", hour);
	}
	
	if (instr(dateStr, "%g") >= 0) {
		value = hour % 12;
		if (value == 0) value = 12;
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%g", value);
	}
	
	if (instr(dateStr, "%a") >= 0) {
		if (hour == 0 || hour > 12) {
			strValue = "am";
		} else {
			strValue = "pm";
		}
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%a", strValue);
	}
	
	if (instr(dateStr, "%A") >= 0) {
		if (hour == 0 || hour > 12) {
			strValue = "AM";
		} else {
			strValue = "PM";
		}
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%A", strValue);
	}
	
	// Minute.
	if (instr(dateStr, "%i") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%i", class'NexgenUtil'.static.lfill(minute, 2, "0"));
	}
	
	// Second.
	if (instr(dateStr, "%s") >= 0) {
		dateStr = class'NexgenUtil'.static.replace(dateStr, "%s", class'NexgenUtil'.static.lfill(second, 2, "0"));
	}
	
	return dateStr;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the full textual representation of the specified day of the week.
 *  $PARAM        day  The number of day of the week whose name is to be retrieved.
 *  $REQUIRE      0 <= day && day <= 6
 *  $RETURN       A full textual representation of the day of the week.
 *  $ENSURE       result != ""
 *
 **************************************************************************************************/
static function string getDayName(int day) {
	switch (day) {
		case  0: return "Sunday";
		case  1: return "Monday";
		case  2: return "Tuesday";
		case  3: return "Wednesday";
		case  4: return "Thursday";
		case  5: return "Friday";
		case  6: return "Saturday";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the short textual representation of the specified day of the week, three
 *                letters.
 *  $PARAM        day  The number of day of the week whose name is to be retrieved.
 *  $REQUIRE      0 <= day && day <= 6
 *  $RETURN       A short textual representation of the day of the week.
 *  $ENSURE       len(result) == 3
 *
 **************************************************************************************************/
static function string getShortDayName(int day) {
	switch (day) {
		case  0: return "Sun";
		case  1: return "Mon";
		case  2: return "Tue";
		case  3: return "Wed";
		case  4: return "Thu";
		case  5: return "Fri";
		case  6: return "Sat";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the full textual representation of the specified month, such as January
 *                or March.
 *  $PARAM        month  The number of the month whose name is to be retrieved.
 *  $REQUIRE      1 <= month && month <= 12
 *  $RETURN       A full textual representation of the specified month.
 *  $ENSURE       result != ""
 *
 **************************************************************************************************/
static function string getMonthName(int month) {
	switch (month) {
		case  1: return "January";
		case  2: return "February";
		case  3: return "March";
		case  4: return "April";
		case  5: return "May";
		case  6: return "June";
		case  7: return "July";
		case  8: return "August";
		case  9: return "September";
		case 10: return "October";
		case 11: return "November";
		case 12: return "December";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the short textual representation of the specified month, three letters.
 *  $PARAM        month  The number of the month whose short name is to be retrieved.
 *  $REQUIRE      1 <= month && month <= 12
 *  $RETURN       A short textual representation of the specified month.
 *  $ENSURE       len(result) == 3
 *
 **************************************************************************************************/
static function string getShortMonthName(int month) {
	switch (month) {
		case  1: return "Jan";
		case  2: return "Feb";
		case  3: return "Mar";
		case  4: return "Apr";
		case  5: return "May";
		case  6: return "Jun";
		case  7: return "Jul";
		case  8: return "Aug";
		case  9: return "Sep";
		case 10: return "Oct";
		case 11: return "Nov";
		case 12: return "Dec";
	}
}
