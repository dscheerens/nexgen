/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenUtil
 *  $VERSION      1.20 (21-12-2010 14:12:09)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Utility class. Contains some usefull general purpose functions.
 *
 **************************************************************************************************/
class NexgenUtil extends Object;

var float version;            // Nexgen version number.
var int versionCode;          // Internal version number.
var int internalVersion;      // Internal version number.
var string packageName;       // Name of the Nexgen package. 
var string countryFlagsPkg;   // Package containing the flag textures.

const keyChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
const keyFormat = "5-5-5-5-5-5-4";
const nexgenCommand = "NSC";
const separator = ",";
const assignment = "=";
const escapeToken = "\\";
const illegalFileNameChars = "\\/*?:<>\"|";
const hexChars = "0123456789ABCDEF";



/***************************************************************************************************
 *
 *  $DESCRIPTION  Generates a new unique key.
 *  $RETURN       A string containing a new unique key.
 *
 **************************************************************************************************/
static function string makeKey() {
	local string key;
	local int index;
	local string cs;
	local int size;
	local int count;
	
	for (index = 0; index < len(keyFormat); index++) {
		cs = mid(keyFormat, index, 1);
		if ("0" <= cs && cs <= "9") {
			size = int(cs);
			for (count = 0; count < size; count++) {
				key = key $ mid(keyChars, rand(len(keyChars)), 1);
			}
		} else {
			key = key $ cs;
		}
	}
	
	return key;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replaces a specified substring in a string with another substring.
 *  $PARAM        source  The original string, which is to be filtered.
 *  $PARAM        oldStr  Substring in the original string that is to be replaced.
 *  $PARAM        newStr  Replacement for the substring to be replaced.
 *  $RETURN       The specified string where all occurrences of oldStr are replaced with newStr.
 *
 **************************************************************************************************/
static function string replace(coerce string source, coerce string oldStr, coerce string newStr) {
	local bool bDone;
	local int subStrIndex;
	local string result;
	local string strLeft;
	
	strLeft = source;
	
	// Replace each occurrence of oldStr with newStr.
	while (!bDone) {
		
		// Find index of oldStr in the part not examined yet.
		subStrIndex = instr(strLeft, oldStr);
		
		// Update examined and unexamined parts.
		if (subStrIndex < 0) {
			bDone = true;
			result = result $ strLeft;
		} else {
			result = result $ left(strLeft, subStrIndex) $ newStr;
			strLeft = mid(strLeft, subStrIndex + len(oldStr));
		}
	}
	
	// Return the filtered string.
	return result;
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
static function string format(string source, optional coerce string str1,
                              optional coerce string str2, optional coerce string str3,
                              optional coerce string str4) {
	local string formattedStr;
	
	formattedStr = replace(source, "%1", str1);
	formattedStr = replace(formattedStr, "%2", str2);
	formattedStr = replace(formattedStr, "%3", str3);
	formattedStr = replace(formattedStr, "%4", str4);
	
	return formattedStr;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes leading and trailing spaces from the given string.
 *  $PARAM        source  The string for which the leading and trailing spaces are to be removed.
 *  $RETURN       The original string with all spaces removed from the front and back of the string.
 *  $ENSURE       len(result) > 0 ? left(result, 1) != " " && right(result, 1) != " " : true
 *
 **************************************************************************************************/
static function string trim(string source) {
	local int index;
	local string result;
	
	// Remove leading spaces.
	result = source;
	while (index < len(result) && mid(result, index, 1) == " ") {
		index++;
	}
	result = mid(result, index);
	
	// Remove trailing spaces.
	index = len(result) - 1;
	while (index >= 0 && mid(result, index, 1) == " ") {
		index--;
	}
	result = left(result, index + 1);
	
	// Return new string.
	return result;	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fills the given string from the left until it has a minimum length. 
 *  $PARAM        source     The original string.
 *  $PARAM        minLength  Minimum length of the string.
 *  $PARAM        fillStr    String used to fill up the original string.
 *  $PARAM        maxLength  Maximum length of the string.
 *  $REQUIRE      minLength >= 0 && len(fillStr) > 0
 *  $RETURN       The original string filled to a minimum length.
 *  $ENSURE       minLength <= len(result) && (maxLength >= minLength? len(result) <= maxLength : true)
 *
 **************************************************************************************************/
static function string lfill(coerce string source, int minLength, string fillStr, optional int maxLength) {
	local string result;
	
	// Add leading string until minLength is reached.
	result = source;
	while (len(result) < minLength) {
		result = fillStr $ result;
	}
	
	// Cut off.
	if (maxLength >= minLength && len(result) > maxLength) {
		result = right(result, maxLength);
	}
	
	// Return string.
	return result;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fills the given string from the left until it has a minimum length. 
 *  $PARAM        source     The original string.
 *  $PARAM        minLength  Minimum length of the string.
 *  $PARAM        fillStr    String used to fill up the original string.
 *  $PARAM        maxLength  Maximum length of the string.
 *  $REQUIRE      minLength >= 0 && len(fillStr) > 0
 *  $RETURN       The original string filled to a minimum length.
 *  $ENSURE       minLength <= len(result) && (maxLength >= minLength? len(result) <= maxLength : true)
 *
 **************************************************************************************************/
static function string rfill(coerce string source, int minLength, string fillStr, optional int maxLength) {
	local string result;
	
	// Add trailing string until minLength is reached.
	result = source;
	while (len(result) < minLength) {
		result = result $ fillStr;
	}
	
	// Cut off.
	if (maxLength >= minLength && len(result) > maxLength) {
		result = left(result, maxLength);
	}
	
	// Return string.
	return result;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Parses the given command string.
 *  $PARAM        cmdStr    The string containing the command and parameters.
 *  $PARAM        cmdName   Name of the parsed command.
 *  $PARAM        argCount  Number of arguments that were parsed.
 *  $PARAM        args      Arguments of the parsed command.
 *  $PARAM        prefix    Optional prefix that should be present if the command is to be
 *                          considered a valid command.
 *  $RETURN       True if the command is a valid command and it has been parsed, false if not.
 *  $ENSURE       imply(result == true, cmdName != "" && 0 <= argCount && argCount <= arrayCount(args))
 *
 **************************************************************************************************/
static function bool parseCmd(string cmdStr, out string cmdName, out string args[10], optional out int argCount, optional string prefix) {
	local string cmd;
	local int index;
	local string currentChar;
	local bool bRecording;
	local bool bFullTextRecording;
	local bool bEscaped;
	
	// First check command prefix if there is one.
	cmd = trim(cmdStr);
	if (prefix != "") {
		if (left(cmd, len(prefix) + 1) ~= (prefix $ " ")) {
			cmd = trim(mid(cmd, len(prefix) + 1));
		} else {
			// Prefix does not match, not a valid command.
			return false;
		}
	}
	
	// Get command name.
	index = instr(cmd, " ");
	if (index < 0) {
		// There are no arguments, but it still is a valid command.
		cmdName = cmd;
		return true;
	} else {
		cmdName = left(cmd, index);
		cmd = mid(cmd, index + 1);
	}
	
	// Get command arguments.
	index = 0;
	while (index < len(cmd) && argCount <= arrayCount(args)) {
		// Fetch current character.
		currentChar = mid(cmd, index, 1);
		
		// Handle current character.
		if (bRecording && bEscaped) {
			// Escaped character, always store but possibly needs conversion first.
			switch (currentChar) {
				case "t": currentChar = chr(0x09); break;
				case "n": currentChar = chr(0x0A); break;
				case "r": currentChar = chr(0x0D); break;
			}
			args[argCount - 1] = args[argCount - 1] $ currentChar;
			bEscaped = false;
			
		} else if (currentChar == " ") {
			// Space character, store if currently recording full text otherwise end recording.
			if (bFullTextRecording) {
				args[argCount - 1] = args[argCount - 1] $ currentChar;
			} else if (bRecording) {
				bRecording = false;
			}
			
		} else if (currentChar == "\\") {
			// Escape character, don't store and enable recording.
			bEscaped = true;
			if (!bRecording) {
				bRecording = true;
				argCount++;
			}
		
		} else if (currentChar == "\"") {
			// Start/end full text recording character, don't store.
			if (bFullTextRecording) {
				bFullTextRecording = false;
				bRecording = false;
			} else if (bRecording) {
				bFullTextRecording = true;
				argCount++;
			} else {
				bFullTextRecording = true;
				bRecording = true;
				argCount++;
			}
			
		} else {
			// Other character, always store, start recording.
			if (!bRecording) {
				bRecording = true;
				if (++argCount <= arrayCount(args)) {
					args[argCount - 1] = args[argCount - 1] $ currentChar;
				}
			} else {
				args[argCount - 1] = args[argCount - 1] $ currentChar;
			}
		}
		
		// Continue with next character.
		index++;
	}
	
	// Check if argument count has not overflowed the argument list capacity.
	if (argCount > arrayCount(args)) {
		argCount = arrayCount(args);
	}
	
	// The command was valid.
	return true;
	
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Parses the given command string.
 *  $PARAM        cmdStr   The string containing the command and parameters.
 *  $PARAM        cmdName  Name of the parsed command.
 *  $PARAM        args     Arguments of the parsed command.
 *  $RETURN       True if the command is a Nexgen command, false if not.
 *  $DEPRECATED   Use the parseCmd() function instead.
 *
 **************************************************************************************************/
static function bool parseCommandStr(string cmdStr, out string cmdName, out string args[10]) {
	return parseCmd(cmdStr, cmdName, args, , nexgenCommand);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a property to the given properties string.
 *  $PARAM        propStr    The string where the property is to be added to.
 *  $PARAM        propName   Name of the property to add.
 *  $PARAM        propValue  The value of the property that is to be added.
 *  $REQUIRE      propName != ""
 *  $ENSURE       new.getProperty(propStr, propName) == propValue
 *
 **************************************************************************************************/
static function addProperty(out string propStr, string propName, coerce string propValue) {
	local string formattedValue;
	
	// Format value (in case it includes the separator tokens or ends with an escape token).
	formattedValue = replace(propValue, separator, escapeToken $ separator);
	if (len(formattedValue) >= len(len(escapeToken)) &&
	    right(formattedValue, len(escapeToken)) == escapeToken) {
		formattedValue = formattedValue $ " ";
	}
	
	// Update property string.
	if (propStr == "") {
		propStr = propName $ assignment $ formattedValue;
	} else {
		propStr = propStr $ separator $ propName $ assignment $ formattedValue;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads a property from the given properties string.
 *  $PARAM        propStr           The string where the property is to be read from.
 *  $PARAM        propName          Name of the property to read.
 *  $PARAM        propDefaultValue  The default value of the property to return if the property
 *                                  string doesn't contain the specified property.
 *  $REQUIRE      propName != ""
 *  $RETURN       The value of the specified property in the given property string.
 *
 **************************************************************************************************/
static function string getProperty(string propStr, string propName, optional string propDefaultValue) {
	local int index;
	local bool bFound;
	local string remaining;
	local string saved;
	
	// Search until property is found or there are no properties left.
	remaining = propStr $ separator;
	index = instr(remaining, separator);
	while (!bFound && index >= 0) {
		// Check if the separator is preceeded by a escape token, i.e. a formatted value.
		if (index - len(escapeToken) >= 0 &&
		    mid(remaining, index - len(escapeToken), len(escapeToken)) == escapeToken) {
		    // Escape token found, continue with next separator token.
		    saved = saved $ left(remaining, index - len(escapeToken)) $ separator;
		    remaining = mid(remaining, index + len(separator));
		    index = instr(remaining, separator);
		} else {
			// Property separator found, check name.
			saved = saved $ left(remaining, index);
			if (left(saved, len(propName) + len(assignment)) ~= (propName $ assignment)) {
				// Property found.
				bFound = true;
			} else {
				// Property name does not match continue search.
				saved = "";
				remaining = mid(remaining, index + len(separator));
				index = instr(remaining, separator);
			}
		}
	}
	
	// Return result.
	if (bFound) {
		return mid(saved, len(propName) + len(assignment));
	} else {
		return propDefaultValue;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Computes the date 'daysToCount' days after the specified date.
 *  $PARAM        daysToCount  Number of days after the specified date.
 *  $PARAM        year         Year of the starting date.
 *  $PARAM        month        Month of the starting date.
 *  $PARAM        day          Day of the starting date.
 *
 **************************************************************************************************/
static function computeDate(int daysToCount, out int year, out int month, out int day) {
	local int daysRemaining;
	
	daysRemaining = daysToCount;
	
	// Add years.
	while (daysRemaining > daysInYear(year)) {
		daysRemaining -= daysInYear(year);
		year++;
	}
	
	// Add months.
	while (daysRemaining > daysInMonth(year, month)) {
		daysRemaining -= daysInMonth(year, month);
		if (++month > 12) {
			month = 1;
			year++;
		}
		
	}	
	
	// Add days.
	if (daysRemaining > daysInMonth(year, month) - day) {
		day = daysRemaining - daysInMonth(year, month) + day;
		if (++month > 12) {
			month = 1;
			year++;
		}
	} else {
		day += daysRemaining;
	}

}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Gives the number of days in the specified year.
 *  $PARAM        Year  The year for which the number of days has to be returned.
 *  $RETURN       The number of days in the specified year.
 *  $ENSURE       result == isLeapYear(year) ? 366 : 365
 *
 **************************************************************************************************/
static function int daysInYear(int year) {
	if (isLeapYear(year)) {
		return 366;
	} else {
		return 365;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Gives the number of days in the specified year and month.
 *  $PARAM        Year   The year for which the number of days has to be returned.
 *  $PARAM        Month  The month for which the number of days has to be returned.
 *  $RETURN       The number of days in the specified year and month.
 *  $ENSURE       28 <= result && result <= 31
 *
 **************************************************************************************************/
static function int daysInMonth(int year, int month) {
	switch (month) {		
		case  1: return 31; // January
		case  2: if (isLeapYear(year)) return 29; else return 28; // February
		case  3: return 31; // March
		case  4: return 30; // April
		case  5: return 31; // May
		case  6: return 30; // June
		case  7: return 31; // July
		case  8: return 31; // August
		case  9: return 30; // September
		case 10: return 31; // October
		case 11: return 30; // November
		case 12: return 31; // December
	};
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the given year is a leap year.
 *  $PARAM        year  The year for which has to be checked if it is a leap year or not.
 *  $RETUN        True if the specified year is a leap year, false if not.
 *
 **************************************************************************************************/
static function bool isLeapYear(int year) {
	return (year % 400 == 0) || (year % 4 == 0) && (year % 100 != 0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the given IP address is valid.
 *  $PARAM        ipAddress  The IP address that is to be checked.
 *  $RETURN       True if the specified IP address is valid, false if not.
 *
 **************************************************************************************************/
static function bool isValidIPAddress(string ipAddress) {
	local bool bValid;
	local string remaining;
	local int index;
	local int currentSection;
	local string section;
	local int char;
	
	// Check each section.
	bValid = true;
	currentSection = 1;
	remaining = ipAddress;
	while (bValid && currentSection <= 4) {
		// Get section split point.
		index = instr(remaining, ".");
		
		// Split head section from tail.
		if (currentSection == 4 && index > 0) {
			// Already at byte 4, but still some sections remaining.
			bValid = false;
		} else if (index < 0 && currentSection != 4) {
			// Premature end of address.
			bValid = false;
		} else if (index > 0) {
			section = left(remaining, index);
			remaining = mid(remaining, index + 1);
		} else {
			section = remaining;
			remaining = "";
		}
		
		// Check section.
		if (bValid) {
			
			// Check section length.
			bValid = section != "" && len(section) <= 3;
			
			// Check section characters.
			index = 0;
			while (bValid && index < len(section)) {
				char = asc(caps(mid(section, index, 1)));
				bValid = asc("0") <= char && char <= asc("9");
				index++;
			}
			
			// Check section value.
			bValid = bValid && int(section) < 256;
			
			// Section check completed.
			currentSection++;
		}
	}
	
	// Return result.
	return bValid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the given client ID is valid.
 *  $PARAM        clientID  The client ID that is to be checked.
 *  $RETURN       True if the specified client ID is valid, false if not.
 *
 **************************************************************************************************/
static function bool isValidClientID(string clientID) {
	local bool bValid;
	local int index;
	local int char;
	
	// Check length.
	bValid = len(clientID) == 32;
	
	// Check characters.
	while (bValid && index < 32) {
		char = asc(caps(mid(clientID, index, 1)));
		if (!(asc("0") <= char && char <= asc("9")) && !(asc("A") <= char && char <= asc("F"))) {
			bValid = false;
		} else {
			index++;
		}
	}
	
	// Return result.
	return bValid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified key is valid.
 *  $PARAM        key  The key that is to be checked.
 *  $RETURN       True if the specified key is valid, false if not.
 *
 **************************************************************************************************/
static function bool isValidKey(string key) {
	local bool bValid;
	local int formatIndex;
	local int keyIndex;
	local int size;
	local int count;
	local string cs;
	
	bValid = true;
	
	// Check format.
	while (bValid && formatIndex < len(keyFormat)) {
		cs = mid(keyFormat, formatIndex, 1);

		// Check format token.
		if ("0" <= cs && cs <= "9") {
			// Check key characters.
			size = int(cs);
			count = 0;
			while (bValid && count < size && keyIndex < len(key)) {
				if (instr(keyChars, mid(key, keyIndex, 1)) < 0) {
					bValid = false;
				} else {
					count++;
					keyIndex++;
				}
			}
			
		} else {
			// Check literal token.
			if (mid(key, keyIndex, 1) != cs) {
				bValid = false;
			} else {
				keyIndex++;
			}
		}
		
		// Continue with next format token.
		formatIndex++;
	}
	
	// Return result.
	return bValid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Serializes the specified date to a compact date description string.
 *  $PARAM        year    Year of the specified date.
 *  $PARAM        month   Month of the specified date.
 *  $PARAM        day     Day of the specified date.
 *  $PARAM        hour    Hour of the specified date.
 *  $PARAM        minute  Minute of the specified date.
 *  $REQUIRE      (1 <= month && moth <= 12) && (1 <= day && day <= 31) &&
 *                (0 <= hour && hour <= 23) && (0 <= minute && minute <= 59)
 *  $RETURN       A description string of the serialized date.
 *
 **************************************************************************************************/
static function string serializeDate(int year, int month, int day, int hour, int minute) {
	return lfill(year, 4, "0") $ "_" $
	       lfill(month, 2, "0") $ "_" $
	       lfill(day, 2, "0") $ "_" $
	       lfill(hour, 2, "0") $ "_" $
	       lfill(minute, 2, "0");
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
 *  $RETURN       True if the specified date string was valid, false if not. When false is returned
 *                the outcome (the date) should be ignored.
 *
 **************************************************************************************************/
static function bool readDate(string dateStr, out int year, out int month, out int day,
                              out int hour, out int minute) {
	local bool bValid;
	local string remaining;
	local int index;
	
	bValid = true;
	remaining = class'NexgenUtil'.static.trim(dateStr);
	
	// Parse year.
	index = instr(remaining, "_");
	if (index >= 0) {
		year = int(left(remaining, index));
		remaining = mid(remaining, index + 1);
	} else {
		bValid = false;
	}
	
	// Parse month.
	if (bValid) {
		index = instr(remaining, "_");
		if (index >= 0) {
			month = int(left(remaining, index));
			remaining = class'NexgenUtil'.static.trim(mid(remaining, index + 1));
		} else {
			bValid = false;
		}
	}
	
	// Parse day.
	if (bValid) {
		index = instr(remaining, "_");
		if (index >= 0) {
			day = int(left(remaining, index));
			remaining = mid(remaining, index + 1);
		} else {
			bValid = false;
		}
	}
	
	// Parse hour.
	if (bValid) {
		index = instr(remaining, "_");
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
 *  $DESCRIPTION  Splits the head element for the tail in given string list. Elements are separated
 *                by the separator token.
 *  $PARAM        list  The list that is to be split.
 *  $PARAM        head  The first element in the list.
 *  $PARAM        tail  The remaining elements in the list.
 *
 **************************************************************************************************/
static function split(string list, out string head, out string tail) {
	local int index;
	
	index = instr(list, separator);
	if (index < 0) {
		head = list;
		tail = "";
	} else {
		head = left(list, index);
		tail = mid(list, index + len(separator));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Splits the head element for the tail in given string list. Elements are separated
 *                by the separator token.
 *  $PARAM        list       The list that is to be split.
 *  $PARAM        head       The first element in the list.
 *  $PARAM        tail       The remaining elements in the list.
 *  $PARAM        separator  The separator token to split on.
 *
 **************************************************************************************************/
static function split2(string list, out string head, out string tail, string separator) {
	local int index;
	
	index = instr(list, separator);
	if (index < 0) {
		head = list;
		tail = "";
	} else {
		head = left(list, index);
		tail = mid(list, index + len(separator));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Gives the formatted GUID string of the raw GUID.
 *  $PARAM        rawGUIDStr  The raw GUID string.
 *  $REQUIRE      len(rawGUIDStr) == 32
 *  $RETURN       The formatted GUID string.
 *  $ENSURE       len(result) == 36
 *
 **************************************************************************************************/
static function string formatGUID(string rawGUIDStr) {
	return left(rawGUIDStr, 8) $ "-" $
	       mid(rawGUIDStr, 8, 4) $ "-" $
	       mid(rawGUIDStr, 12, 4) $ "-" $
	       mid(rawGUIDStr, 16, 4) $ "-" $
	       mid(rawGUIDStr, 20, 12);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the leading color tag from the specified message.
 *  $PARAM        msg  The message for which the color tag has to be removed.
 *  $RETURN       The original message without a leading color tag.
 *
 **************************************************************************************************/
static function string removeMessageColorTag(string msg) {
	if (left(msg, 2) ~= "<C" && mid(msg, 4, 1) == ">") {
		return mid(msg, 5);
	} else {
		return msg;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the base color of the message.
 *  $PARAM        msg  The message for which the base color is be determined.
 *  $RETURN       The base color of the message based on the leading color tag, or -1 if none is
 *                present.
 *
 **************************************************************************************************/
static function int getMessageColor(string msg) {
	if (left(msg, 2) ~= "<C" && mid(msg, 4, 1) == ">") {
		return int(mid(msg, 2, 2));
	} else {
		return -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Gives the integer hash value of a string.
 *  $PARAM        str  The string that is to be hashed.
 *  $RETURN       The hash value of the given string.
 *
 **************************************************************************************************/
static function int stringHash(coerce string str) {
	local int hash;
	local int index;
	
	for (index = 0; index < len(str); index++) {
		hash = 31 * hash + asc(mid(str, index, 1));
	}
	
	return hash;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Auto formats the specified string by inserting the values into the placeholders.
 *  $PARAM        control  The Nexgen controller.
 *  $PARAM        msg      The message that is to be auto formatted.
 *  $REQUIRE      control != none
 *  $RETURN       The auto formatted string.
 *
 **************************************************************************************************/
static function string autoFormat(NexgenController control, string msg) {
	local string output;
	
	output = msg;
	
	if (instr(output, "%port%") >= 0) {
		output = replace(output, "%port%", control.level.game.getServerPort());
	}
	
	if (instr(output, "%name%") >= 0 && control.sConf != none) {
		output = replace(output, "%name%", control.sConf.serverName);
	}
	
	if (instr(output, "%admin%") >= 0 && control.sConf != none) {
		output = replace(output, "%admin%", control.sConf.adminName);
	}
	
	if (instr(output, "%serverid%") >= 0 && control.sConf != none) {
		output = replace(output, "%serverid%", control.sConf.serverID);
	}
	
	output = control.lng.getCurrentDate(output);
	
	return output;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the file name of the specified level.
 *  $RETURN       The filename of the specified level.
 *
 **************************************************************************************************/
static function string getLevelFileName(LevelInfo lvl) {
	local string levelFile;
	
	levelFile = string(lvl);
	levelFile = left(levelFile, instr(levelFile, ".")) $ ".unr";
	
	return levelFile;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the specified file name by replacing the illegal characters with a
 *                valid character.
 *  $PARAM        fileName  name of the file that is to be validated.
 *  $RETURN       A valid file name.
 *  $ENSURE       foreach(char in illegalFileNameChars) instr(result, char) < 0
 *
 **************************************************************************************************/
static function string validateFileName(string fileName) {
	local int index;
	local string output;
	
	output = fileName;

	for (index = 0; index < len(illegalFileNameChars); index++) {
		output = replace(output, mid(illegalFileNameChars, index, 1), "_");
	}
	
	return output;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified level is a valid game map. Use this function to
 *                filter the Unreal Tournament system and tutorial maps from a list.
 *  $PARAM        levelFile  File name of the level which is to be checked. In case no extension is
 *                           specified, the file name will be appended with ".unr"
 *  $RETURN       True if the specified level is valid for play, false if not.
 *
 **************************************************************************************************/
static function bool isValidLevel(string levelFile) {
	local string mapName;
	local bool bInvalidMap;
	
	// Get map name.
	mapName = levelFile;
	if (instr(mapName, ".") < 0) {
		mapName = mapName $ ".unr";
	}
	
	// Check if the map is invalid.
	bInvalidMap = mapName ~= "CityIntro.unr"   ||
	              mapName ~= "AutoPlay.unr"    ||
	              mapName ~= "Entry.unr"       ||
	              mapName ~= "UTCredits.unr"   ||
	              mapName ~= "UT-Logo-Map.unr" ||
	              instr(caps(mapName), separator)  >= 0 ||
	              instr(caps(mapName), "EOL_")     >= 0 ||
	              instr(caps(mapName), "TUTORIAL") >= 0;
	
	// Return result.
	return !bInvalidMap;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Encodes the specified string as if it is an URL.
 *  $PARAM        url  The string that is to be encoded as an URL.
 *  $PARAM        maxLength  The maximum length of the output. A value below 1 means the length of
 *                           the output won't be limited.
 *  $RETURN       Returns a string in which all non-alphanumeric characters except -_. have been
 *                replaced with a percent (%) sign followed by two hex digits and spaces encoded as
 *                plus (+) signs.
 *
 **************************************************************************************************/
static function string urlEncode(string url, optional int maxLength) {
	local int index;
	local string cs;
	local string ns;
	local string output;
	local bool bMaxOutputLengthReached;
	
	// Encode each character in the url string.
	while (!bMaxOutputLengthReached && index < len(url)) {
		// Retrieve character to encode.
		cs = mid(url, index, 1);
		
		// Encode character.
		if (("0" <= cs && cs <= "9") || ("a" <= cs && cs <= "z") || ("A" <= cs && cs <= "Z") ||
		    (cs == "-") || (cs == "_") || (cs == ".")) {
		    ns = cs;
		} else if (cs == " ") {
			ns = "+";
		} else {
			ns = "%" $ class'MD5Hash'.static.decToHex(asc(cs), 1);
		}
		
		// Add character if it doesn't exceed the maximum length of the output string.
		if ((maxLength > 0) && (len(output) + len(ns) > maxLength)) {
			bMaxOutputLengthReached = true;
		} else {
			output = output $ ns;
			index++;
		}
	}
	
	// Return URL encoded string
	return output;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Splits the given string in two parts: the first line and the rest.
 *  $PARAM        str  The string that should be splitted.
 *  $RETURN       The first line in the given string.
 *
 **************************************************************************************************/
static function string getNextLine(out string str) {
	local string line;
	local int indexCRLF;
	local int indexCR;
	local int indexLF;
	
	// Get location of newline token.
	indexCRLF = instr(str, chr(13) $ chr(10));
	indexCR = instr(str, chr(13));
	indexLF = instr(str, chr(10));
	
	// Split data.
	if (indexCRLF >= 0) {
		line = left(str, indexCRLF);
		str = mid(str, indexCRLF + 2);
	} else if (indexCR >= 0) {
		line = left(str, indexCR);
		str = mid(str, indexCR + 1);
	} else if (indexLF >= 0) {
		line = left(str, indexLF);
		str = mid(str, indexLF + 1);
	} else {
		line = str;
		str = "";
	}
	
	// Return result.
	return line;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Formats the specified string so that it can safely be added to a command string as
 *                an argument of that command.
 *  $PARAM        arg  The argument string that is to be formatted.
 *  $RETURN       The properly formatted argument string.
 *
 **************************************************************************************************/
static function string formatCmdArg(coerce string arg) {
	local string result;
	
	result = arg;
	
	// Escape argument if necessary.
	if (arg == "") {
		arg = "\"\"";
	} else {
		result = arg;
		result = class'NexgenUtil'.static.replace(result, "\\", "\\\\");
		result = class'NexgenUtil'.static.replace(result, "\"", "\\\"");
		result = class'NexgenUtil'.static.replace(result, chr(0x09), "\\t");
		result = class'NexgenUtil'.static.replace(result, chr(0x0A), "\\n");
		result = class'NexgenUtil'.static.replace(result, chr(0x0D), "\\r");
		
		if (instr(arg, " ") > 0) {
			result = "\"" $ result $ "\"";
		}
	}
	
	// Return result.
	return result;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the given hexadecimal string to a decimal value.
 *  $PARAM        str  The hexadecimal string that is to be converted.
 *  $PARAM        dec  Integer value of the given hexadecimal.
 *  $RETURN       True if the given input string was valid, false if it could not be converted.
 *
 **************************************************************************************************/
static function bool hexToDec(string str, out int dec) {
	local int index;
	local int hexVal;
	
	for (index = 0; index < len(str); index++) {
		dec = dec << 4;
		hexVal = instr(hexChars, caps(mid(str, index, 1)));
		if (hexVal < 0) {
			return false;
		} else {
			dec += hexVal;
		}
	}
	
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the given string to boolean value.
 *  $PARAM        str  The string that is to be converted.
 *  $RETURN       True if the given input string valid is considered as the boolean value true,
 *                false otherwise.
 *
 **************************************************************************************************/
static function bool str2bool(coerce string str) {
	return !(
		   str == ""
		|| str ~= string(false)
		|| str == "0"
		|| str == string(0.0)
	);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the package name that contains the class of the specified object.
 *  $PARAM        o  The object whose package name is to be returned.
 *  $RETURN       Name of the package that contains the class of the specified object.
 *
 **************************************************************************************************/
static function string getObjectPackage(Object o) {
	local string result;
	local int index;
	
	if (o != none) {
		result = string(o.class);
		index = instr(result, ".");
		if (index >= 0) {
			result = left(result, index);
		}
	}
	
	return result;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the class name of the specified object.
 *  $PARAM        o  The object whose class name is to be returned.
 *  $RETURN       Class name of the specified object.
 *
 **************************************************************************************************/
static function string getObjectClassName(Object o) {
	local string result;
	local int index;
	
	if (o != none) {
		result = string(o.class);
		index = instr(result, ".");
		if (index >= 0) {
			result = mid(result, index + 1);
		}
	}
	
	return result;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	version=1.12
	versionCode=112
	internalVersion=1154
	packageName="Nexgen112"
	countryFlagsPkg="CountryFlags2"
}