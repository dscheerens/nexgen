/***************************************************************************************************
 *
 *  IGSRVEXT. IG Generation 3 server extension by Zeropoint.
 *
 *  $CLASS        IGSXMultiKillMessage
 *  $VERSION      1.00 (16-3-2008 15:45)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Multi kill message class. This localized message is broadcasted to all players
 *                if someone has a double, multi, ultra or monster kill.
 *
 **************************************************************************************************/
class IGSXMultiKillMessage extends LocalMessagePlus;

var localized string multiKillMessage[5];         // Multi kill message strings.
var localized string cheaterMessage;              // Message for extreme players.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the string for this localized message.
 *  $PARAM        switch          Optional message switch.
 *  $PARAM        pri1            Replication info of the first player involved with the message.
 *  $PARAM        pri1            Replication info of the second player involved with the message.
 *  $PARAM        optionalObject  Extra object related to the message.
 *  $RETURN       The message string.
 *
 **************************************************************************************************/
static function string getString(optional int switch, optional PlayerReplicationInfo pri1,
                                 optional PlayerReplicationInfo pri2, optional Object optionalObject) {
	local string msg;
	
	if (pri1 != none) {
		if (1 <= switch) {
			if (switch == 10) {
				msg = class'NexgenUtil'.static.format(default.cheaterMessage, pri1.playerName);;
			} else if (switch > arrayCount(default.multiKillMessage)) {
				msg = class'NexgenUtil'.static.format(default.multiKillMessage[arrayCount(default.multiKillMessage) - 1], pri1.playerName);
			} else {
				msg = class'NexgenUtil'.static.format(default.multiKillMessage[switch - 1], pri1.playerName);
			}
		}
	}
	
	return msg;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	multiKillMessage(0)="%1 had a double kill."
	multiKillMessage(1)="%1 had a multi kill!"
	multiKillMessage(2)="%1 had an ULTRA KILL!"
	multiKillMessage(3)="%1 had a MONSTER KILL!!!"
	multiKillMessage(4)="%1 had another MONSTER KILL!!!"
	cheaterMessage="Someone better be checking %1 for cheats!"
}