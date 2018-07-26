/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCLang
 *  $VERSION      1.01 (22-02-2010 12:00)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Localization support class.
 *
 **************************************************************************************************/
class NMCLang extends Info;

var NexgenController control;

const foundUpdatesMsg = "Found deferred updates, applying them now...";

const invalidCommandMsg = "Unable to parse command: %1";
const commandFailedMsg = "Failed to execute command: %1, reason: %2";
const unknownCommandMsg = "Unknown command '%1' received.";

const actionFailedErr = "action failed";
const modIDMissingErr = "mod identifier argument missing";
const netTypeMissingErr = "variable net type argument missing";
const classMissingErr = "class argument missing";
const varNameMissingErr = "variable argument missing";
const dataTypeMissingErr = "variable data type argument missing";
const inputTypeMissingErr = "variable input type argument missing";
const enumValueMissingErr = "enumeration value argument missing";
const unknownNetTypeErr = "unknown net type";
const unknownDataTypeErr = "unknown data type";
const unknownInputTypeErr = "unknown input type";

const getPropertyErr = "Failed to get property %1.%2";
const setPropertyErr = "Failed to set property %1.%2";

const blockedCmdWarning = "Blocked '%2' command from %1!";

const adminChangeVarMsg = "%1 has changed %2 to %3";



/***************************************************************************************************
 *
 *  $DESCRIPTION  Logs the specified message.
 *  $PARAM        msg  The message that is to be logged.
 *  $PARAM        arg1  Optional argument to insert in message.
 *  $PARAM        arg2  Optional argument to insert in message.
 *  $PARAM        arg3  Optional argument to insert in message.
 *  $PARAM        arg4  Optional argument to insert in message.
 *
 **************************************************************************************************/
function nmcLog(string msg, optional coerce string arg1, optional coerce string arg2, optional coerce string arg3, optional coerce string arg4) {
	if (control == none) {
		log(class'NexgenUtil'.static.format(msg, arg1, arg2, arg3, arg4), 'NMC');
	} else {
		control.nscLog("[NMC]" @ class'NexgenUtil'.static.format(msg, arg1, arg2, arg3, arg4));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Wrapper function for NexgenController.logAdminAction().
 *  $PARAM        msg           Message that describes the action performed by the administrator.
 *  $PARAM        client        The client that performed the action.
 *  $PARAM        str1          Message specific content.
 *  $PARAM        str2          Message specific content.
 *  $PARAM        str3          Message specific content.
 *  $PARAM        bNoBroadcast  Whether not to broadcast this administrator action.
 *
 **************************************************************************************************/
function logAdminAction(string msg, NexgenClient client, optional coerce string str1,
                        optional coerce string str2, optional coerce string str3, optional bool bNoBroadcast) {
	control.logAdminAction(client, msg, client.playerName, str1, str2, str3,
	                       client.player.playerReplicationInfo, bNoBroadcast);
}