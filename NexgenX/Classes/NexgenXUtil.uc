/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXUtil
 *  $VERSION      1.01 (10-8-2008 11:12)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Utility class. Contains some usefull general purpose functions.
 *
 **************************************************************************************************/
class NexgenXUtil extends Object;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the number of seconds denoted by the specified string.
 *  $PARAM        timeStr  The string that is to be converted.
 *  $PARAM        seconds  The number of seconds that are represented by the specified string.
 *  $RETURN       True if the given string was valid, false if not. In case the result is false, the
 *                value stored in seconds should be ignored.
 *
 **************************************************************************************************/
static function bool getTimeInSeconds(string timeStr, out int seconds) {
	local string minutesStr;
	local string secondsStr;
	local int index;
	
	// Remove spaces.
	timeStr = class'NexgenUtil'.static.trim(timeStr);
	
	// Check for empty string.
	if (timeStr == "") return false;
	
	// Get minutes and seconds strings.
	class'NexgenUtil'.static.split2(timeStr, minutesStr, secondsStr, ":");
	
	// Check minutes and seconds strings.
	if (!isNumeric(minutesStr) || !isNumeric(secondsStr)) {
		return false;
	}
	
	// Return result
	seconds = int(minutesStr) * 60 + int(secondsStr);
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks wether the specified string does only contain numeric characters.
 *  $PARAM        str  The string that is to be checked.
 *  $RETURN       True if the given string is numeric, false if it isn't.
 *
 **************************************************************************************************/
static function bool isNumeric(string str) {
	local int index;
	local bool bIsNumeric;
	local string currentChar;
	
	bIsNumeric = true;
	while (bIsNumeric && index < len(str)) {
		currentChar = mid(str, index, 1);
		if (currentChar < "0" || currentChar > "9") {
			bIsNumeric = false;
		} else {
			index++;
		}
	}
	
	return bIsNumeric;
}
