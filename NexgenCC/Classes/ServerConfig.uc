/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        ServerConfig
 *  $VERSION      1.00 (19-12-2006 16:51)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Server specific settings container class. This class provides an interface for
 *                storing server specific settings. Settings can be stored / retrieved using the
 *                set() and get() functions. If the settings list is full, one can use the
 *                removeOldestServer() function to remove the least recently visited server
 *                settings, so new space becomes available.
 *
 **************************************************************************************************/
class ServerConfig extends Info config(User);

struct Date {                                               // Date description structure.
	var int year;
	var int month;
	var int day;
	var int hour;
	var int min;
	var int sec;
	var int msec;
};

struct ServerSettingEntry {                                 // Server setting description structure.
	var int serverNum;
	var string name;
	var string value;
};

struct ServerInfoEntry {                                    // Server description structure.
	var string serverID;
	var Date lastVisit;
};

var private config ServerInfoEntry servers[8];              // Most recently visited servers.
var private config ServerSettingEntry settings[64];         // List of all (saved) settings.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the current date.
 *  $RETURN       A data structure containing the current date and time.
 *
 **************************************************************************************************/
function Date getCurrentDate() {
	local Date currentDate;
	
	currentDate.year = level.year;
	currentDate.month = level.month;
	currentDate.day = level.day;
	currentDate.hour = level.hour;
	currentDate.min = level.minute;
	currentDate.sec = level.second;
	currentDate.msec = level.milliSecond;
	
	return currentDate;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Compares two dates.
 *  $PARAM        date1  The first date to compare.
 *  $PARAM        date2  The second date to compare.
 *  $RETURN       -1 if date1 is before date2,
 *                0 if date1 and date2 are equal,
 *                1 if date1 is after date2.
 *  $ENSURE       result == -1 || result == 0 || result == 1
 *
 **************************************************************************************************/
function int compareDate(Date date1, Date date2) {
	// Compare each attribute.
	if (date1.year < date2.year) return -1;
	if (date1.year > date2.year) return 1;
	if (date1.month < date2.month) return -1;
	if (date1.month > date2.month) return 1;
	if (date1.day < date2.day) return -1;
	if (date1.day > date2.day) return 1;
	if (date1.hour < date2.hour) return -1;
	if (date1.hour > date2.hour) return 1;
	if (date1.min < date2.min) return -1;
	if (date1.min > date2.min) return 1;
	if (date1.sec < date2.sec) return -1;
	if (date1.sec > date2.sec) return 1;
	if (date1.msec < date2.msec) return -1;
	if (date1.msec > date2.msec) return 1;
		
	// Dates are equal.
	return 0;
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the oldest (least recently visited) server from the server list. If no
 *                servers have been stored so far, no changes will be made. When a server is removed
 *                all of its settings will also be removed from the settings list.
 *  $RETURN       The index of the server that has been removed from the list, or -1 if the list was
 *                empty.
 *  $ENSURE       There is at least one free entry available in the server list &&
 *                -1 <= result && result <= arrayCount(servers)
 *
 **************************************************************************************************/
function int removeOldestServer() {
	local int oldestServer;
	local Date oldestDate;
	local int index;
	
	// Locate index of oldest server.
	oldestServer = -1;
	oldestDate.year = 0x7FFFFFFF;
	for (index = 0; index < arrayCount(servers); index++) {
		if (servers[index].serverID != "" && compareDate(servers[index].lastVisit, oldestDate) < 0) {
			oldestServer = index;
			oldestDate = servers[index].lastVisit;
		}
	}

	// Remove oldest server if found.
	if (oldestServer >= 0) {
		// Remove settings of oldest server.
		for (index = 0; index < arrayCount(settings); index++) {
			if (settings[index].serverNum == oldestServer + 1) {
				settings[index].serverNum = 0;
				settings[index].name = "";
				settings[index].value = "";
			}
		}
		
		// Remove oldest server from server list.
		servers[oldestServer].serverID = "";
		servers[oldestServer].lastVisit.year = 0;
		servers[oldestServer].lastVisit.month = 0;
		servers[oldestServer].lastVisit.day = 0;
		servers[oldestServer].lastVisit.hour = 0;
		servers[oldestServer].lastVisit.min = 0;
		servers[oldestServer].lastVisit.sec = 0;
		servers[oldestServer].lastVisit.msec = 0;
	}
	
	return oldestServer;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Marks the specified server as recently visisted. If the server has no entry in the
 *                server list a new entry will be created (possibly removing another server if the
 *                list is full).
 *  $ENSURE       there exists an entry in the server list where entry.serverID == serverID
 *
 **************************************************************************************************/
function visitServer(string serverID) {
	local int index;
	local bool bFound;
	
	// Locate server entry.
	while (!bFound && index < arrayCount(servers)) {
		if (servers[index].serverID ~= serverID) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// If server hasn't been visited yet, find an empty entry.
	if (!bFound) {
		index = 0;
		while (!bFound && index < arrayCount(servers)) {
			if (servers[index].serverID == "") {
				bFound = true;
			} else {
				index++;
			}
		}
	}
	
	// If there is no empty space, delete the oldest server.
	if (!bFound) {
		index = removeOldestServer();
	}
	
	// Save server info.
	servers[index].serverID = serverID;
	servers[index].lastVisit = getCurrentDate();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the value of the specified setting for the specified server. If the
 *                server isn't listed the default value will be returned.
 *  $PARAM        serverID      The identification code of the server for which the setting is to be
 *                              retrieved.
 *  $PARAM        name          Name of the setting that is to be retrieved.
 *  $PARAM        defaultValue  Value to return if the setting couldn't been found.
 *  $RETURN       The value of the specified setting, or the default value if the setting doesn't
 *                exist.
 *
 **************************************************************************************************/
function string get(string serverID, string name, optional string defaultValue) {
	local int index;
	local bool bFound;
	local int serverNum;
	
	// Locate server entry.
	while (!bFound && index < arrayCount(servers)) {
		if (servers[index].serverID ~= serverID) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// If server doesn't exist, return the default value.
	if (!bFound) {
		return defaultValue;
	}
	
	// Locate index of setting.
	serverNum = index + 1;
	index = 0;
	bFound = false;
	while (!bFound && index < arrayCount(settings)) {
		if (settings[index].serverNum == serverNum && settings[index].name ~= name) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Return setting value, or the default setting if the setting wasn't found.
	if (bFound) {
		return settings[index].value;
	} else {
		return defaultValue;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the specified setting with the given value for the specified server. The
 *                update may fail if all setting entries are used.
 *  $PARAM        serverID  The identification code of the server for which the setting is to be
 *                          updated.
 *  $PARAM        name      Name of the setting that is to be stored.
 *  $PARAM        value     (New) Value of the setting to store.
 *  $PARAM        bAutoRem  Indicates whether or not to remove a server if the list is full.
 *  $REQUIRE      name != ""
 *  $RETURN       True if the setting was updated/save, false if not.
 *  $ENSURE       result == true ? new.get(serverID, name) == value : true
 *
 **************************************************************************************************/
function bool set(string serverID, string name, string value, optional bool bAutoRem) {
	local int index;
	local bool bFound;
	local int serverNum;
	
	// Locate server entry.
	while (!bFound && index < arrayCount(servers)) {
		if (servers[index].serverID ~= serverID) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// If server doesn't exist, the setting can't be stored.
	if (!bFound) {
		return false;
	}
	
	// Locate index of setting.
	serverNum = index + 1;
	index = 0;
	bFound = false;
	while (!bFound && index < arrayCount(settings)) {
		if (settings[index].serverNum == serverNum && settings[index].name ~= name) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Setting doesn't exist yet, search for an empty entry.
	if (!bFound) {
		index = 0;
		while (!bFound && index < arrayCount(settings)) {
			if (settings[index].name == "") {
				bFound = true;
			} else {
				index++;
			}
		}
	}
	
	// Clear a server if the list is full?
	if (!bFound && bAutoRem) {
		removeOldestServer();

		// Search for an empty entry.
		if (!bFound) {
			index = 0;
			while (!bFound && index < arrayCount(settings)) {
				if (settings[index].name == "") {
					bFound = true;
				} else {
					index++;
				}
			}
		}
	}
	
	// Save setting.
	if (bFound) {
		settings[index].serverNum = serverNum;
		settings[index].name = name;
		settings[index].value = value;
	}
	
	return bFound;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	bHidden=true
	remoteRole=ROLE_None
}