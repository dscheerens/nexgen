/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPLang
 *  $VERSION      1.06 (05-12-2010 18:56:16)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Localization support class.
 *
 **************************************************************************************************/
class NXPLang extends Info;

const updateAvailableMsg = "A new version of Nexgen is available. Check www.unrealadmin.org.";

const protectedTagLoginRejectMsg = "Attempt to use protected tag.";

const adminMapSwitchMsg = "<C07>%1 has changed the game to %2.";
const adminChangeTimeLimitMsg = "<C07>%1 has changed the time limit to %2.";
const adminChangeScoreLimitMsg = "<C07>%1 has changed the score limit to %2.";
const adminChangeTeamScoreLimitMsg = "<C07>%1 has changed the team score limit to %2.";
const adminChangeGameSpeedMsg = "<C07>%1 has changed the game speed to %2%.";
const adminChangeTimeRemainingMsg = "<C07>%1 has set the remaining time to %2.";
const adminChangeConfigVarMsg = "<C07>%1 has set %2.%3 to \"%4\".";
const adminForceClientViewRulesMsg = "<C07>%1 has forced %2 to read the server rules. Reason: %3.";

const tagNotAllowedMsg = "<C00>Failed to change name, you are not allowed to use the %1 tag.";

const viewRulesClientMsg = "<C07>To view the rules of this server use the !rules command.";

const noReasonGivenMsg = "(no reason given)";

const mapSwitchTabTxt = "Map switch";
const mapSwitchActionTxt = "Switch";
const hideBadMapsTxt = "Hide incompatible maps";
const recievingMapListTxt = "Receiving map list...";
const reloadMapListTxt = "Reload map list";
const mapListReloadingMsg = "<C07>The map list will be reloaded when the next game starts.";

const settingsPanelTitle = "NexgenPlus - General settings";
const enableMapSwitchTxt = "Enable map switch tab for match admins";
const cacheMapListTxt = "Load map list from cache (admin reloads map list manually)";
const autoMapListCachingThresholdTxt = "Auto map list caching activation threshold";
const showMapSwitchAtEndOfGameTxt = "Open map switch tab for match admins at end of game";
const mapSwitchAutoDisplayDelayTxt = "Delay before automatically opening map switch at end of game";
const showDamageProtectionShieldTxt = "Display a shield around players that are damage protected";
const colorizePlayerSkinsTxt = "Colorize the player skins with team colors";
const enableAKALoggingTxt = "Integrate with AKA logger (log client IDs)";
const disableUTAntiSpamTxt = "Disable UTs buildin anti message spam system";
const enableNexgenAntiSpamTxt = "Enable Nexgens anti message spam system";
const checkForNexgenUpdatesTxt = "Automatically check for new Nexgen versions";

const fullServerRedirectPanelTitle = "NexgenPlus - Full server redirect settings";
const enableFullServerRedirectTxt = "Enable player redirect to alternate servers when server is full";
const autoFullServerRedirectTxt = "Automatically redirect player to the a random alternate server";
const serverEntryTxt = "Server %1";
const urlTxt = "URL";

const tagProtectionPanelTitle = "NexgenPlus - Tag protection";
const enableTagProtectionTxt = "Only allow registered players to use protected tags.";
const protectedTagsTxt = "Protected tags:";

const serverRulesSettingsPanelTitle = "NexgenPlus - Server rules";
const showServerRulesTabTxt = "Show server rules tab in the Nexgen control panel";
const showServerRulesInHUDTxt = "Display the server rules on the players HUD after joining";
const serverRulesHUDAnchorPointLocHTxt = "Horizontal rules HUD window anchor location";
const serverRulesHUDAnchorPointLocVTxt = "Vertical rules HUD window anchor location";
const serverRulesHUDPosXTxt = "X coordinate of rules HUD window anchor point";
const serverRulesHUDPosYTxt = "Y coordinate of rules HUD window anchor point";

const serverRulesTabTxt = "Rules";
const serverRulesTabTitle = "The rules of this server are:";
const serverRulesForcedTabTitle = "An administrator has forced you to view the server rules!";
const forceClientViewRulesTxt = "Show rules";
const forceClientViewRulesReasonTxt = "Reason for showing rules:";

const clientConfigTitle = "NexgenPlus settings";
const enableStartAnnouncerTxt = "Enable game start announcer";
const showPingStatusBoxTxt = "Display ping status box";
const showTimeStatusBoxTxt = "Display remaining / elapsed time status box";

const remainingTimeTxt = "Remaining time";
const setButtonTxt = "set";

const antiSpamMutedState = "Muted (spam)";



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