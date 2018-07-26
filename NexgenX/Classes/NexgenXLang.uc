/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXLang
 *  $VERSION      1.07 (15-03-2010 13:42)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Localization support class.
 *
 **************************************************************************************************/
class NexgenXLang extends Info;

const invalidConfigMsg = "NexgenX configuration file was corrupt and has been repaired.";
const updateCheckFailedMsg = "Failed to check for updates, error returned: %1";
const updateAvailableMsg = "A new version of Nexgen is available. Check www.unrealadmin.org.";

const protectedTagLoginRejectMsg = "Attempt to use protected tag.";

const adminMapSwitchMsg = "<C07>%1 has changed the game to %2.";
const adminUpdateGeneralSettingsMsg = "<C07>%1 has modified the NexgenX settings.";
const adminFullServerRedirSettingsMsg = "<C07>%1 has modified the full server redirect settings.";
const adminAddBotsMsg = "<C07>%1 has added %2 bot%3 to the game.";
const adminRemoveBotsMsg = "<C07>%1 has removed %2 bot%3 from the game.";
const adminChangeTimeLimitMsg = "<C07>%1 has changed the time limit to %2.";
const adminChangeScoreLimitMsg = "<C07>%1 has changed the score limit to %2.";
const adminChangeTeamScoreLimitMsg = "<C07>%1 has changed the team score limit to %2.";
const adminChangeGameSpeedMsg = "<C07>%1 has changed the game speed to %2%.";
const adminChangeTimeRemainingMsg = "<C07>%1 has set the remaining time to %2.";
const adminUpdateTagProtectionSettingsMsg = "<C07>%1 has modified the tag protection settings.";
const adminUpdateServerRulesSettingsMsg = "<C07>%1 has modified the server rules settings.";
const adminForceClientViewRulesMsg = "<C07>%1 has forced %2 to read the server rules. Reason: %3.";

const gameRestartRequiredMsg = "<C07>You have to restart the game in order to apply the changes!";

const tagNotAllowedMsg = "<C00>Failed to change name, you are not allowed to use the %1 tag.";

const viewRulesClientMsg = "<C07>To view the rules of this server use the !rules command.";

const noReasonGivenMsg = "(no reason given)";

const mapSwitchTabTxt = "Map switch";
const mapSwitchActionTxt = "Switch";
const hideBadMapsTxt = "Hide incompatible maps";
const recievingMapListTxt = "Receiving map list...";
const recievingMapListProgressTxt = "Receiving map list (%1 %)...";

const settingsPanelTitle = "NexgenX - General settings";
const enableOverlaySkinTxt = "Enable player overlay skin effect";
const enableMapSwitchTabTxt = "Enable map switch tab for match controllers";
const enableStartAnnouncerTxt = "Enable game start announcer";
const enableAntiSpamTxt = "Enable anti message spam";
const enableClientIDAKALogTxt = "Enable AKA client ID logging";
const checkForUpdatesTxt = "Automatically check for Nexgen updates";
const disableUTAntiSpamTxt = "Disable UTs buildin anti message spam";
const enablePerformanceOptimizerTxt = "Enable server performance optimizer";

const fullServerRedirPanelTitle = "NexgenX - Full server redirect settings";
const enableFullServerRedirTxt = "Enable player redirect to alternate servers when server is full";
const enableAutoRedirectTxt = "Automatically redirect player to the first alternate server";
const messageTxt = "Message";
const defaultFullServerRedirMsg = "The server you have tried to enter has no more player slots available. You can try again in a few minutes or reconnect immediately as a spectator. If you wish to play immediately you can connect to one of the alternate servers.";
const serverEntryTxt = "Server %1";
const urlTxt = "URL";

const remainingTimeTxt = "Remaining time";
const setButtonTxt = "set";
const addBotsTxt = "Add bots";
const removeBotsTxt = "Remove bots";

const tagProtectionPanelTitle = "NexgenX - Clan tag protection";
const enableTagProtectionTxt = "Only allow registered players to use protected clan tags.";
const protectedTagsTxt = "Protected tags:";

const serverRulesPanelTitle = "NexgenX - Server rules settings";
const enableServerRulesTxt = "Show a server rules tab in the Nexgen control panel.";
const serverRulesCaptionTxt = "Rules to display:";

const antiSpamMutedState = "Muted (spam)";

const serverRulesTabTxt = "Rules";
const serverRulesTabTitle = "The rules of this server are:";
const serverRulesForcedTabTitle = "An administrator has forced you to view the server rules!";
const forceClientViewRulesTxt = "Show rules";
const forceClientViewRulesReasonTxt = "Reason for showing rules:";

const clientConfigTitle = "NexgenX settings";
const showPingStatusBoxTxt = "Display ping status box";
const showTimeStatusBoxTxt = "Display remaining / elapsed time status box";

const botControlTabTxt = "Bots";


/***************************************************************************************************
 *
 *  $DESCRIPTION  Get a textual description of the specified time.
 *  $PARAM        seconds  The number of seconds.
 *  $RETURN       A textual description of the specified amount of time.
 *
 **************************************************************************************************/
function string getLongTimeDescription(int seconds) {
	local int hours;
	local int minutes;
	local string output;
	
	// Split number of seconds in hours, minutes and seconds.
	hours = seconds / 3600;
	seconds = seconds - hours * 3600;
	minutes = seconds / 60;
	seconds = seconds - minutes * 60;
	
	// Add hours.
	if (hours != 0) {
		output = hours @ "hour";
		if (hours != 1) output = output $ "s";
	}
	
	// Add minutes.
	if (minutes != 0) {
		if (hours != 0) {
			if (seconds != 0) {
				output = output $ ", ";
			} else {
				output = output $ " and ";
			}
		}
		output = output $ minutes @ "minute";
		if (minutes != 1) output = output $ "s";
	}
	
	// Add seconds.
	if (seconds != 0 || output == "") {
		if (minutes != 0 || hours != 0) {
			output = output $ " and ";
		}
		output = output $ seconds @ "second";
		if (seconds != 1) output = output $ "s";
	}
	
	// Return result.
	return output;
}