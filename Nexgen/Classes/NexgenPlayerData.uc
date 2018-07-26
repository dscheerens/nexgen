/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPlayerData
 *  $VERSION      1.00 (24-11-2007 15:28)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Saved player data support class. An instance of this class can be used to store
 *                attributes of a leaving player, which can later be retrieved once the player
 *                reconnects.
 *
 **************************************************************************************************/
class NexgenPlayerData extends info;

struct AttributeEntry {                           // Attribute data structure.
	var string name;                              // Name of the attribute.
	var string value;                             // Value of the attribute.
};

var private AttributeEntry attributes[64];        // Attributes for this player.

var string clientID;                              // ClientID of the player.

var NexgenPlayerData next;                        // Next player data instance.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes all attributes stored in this NexgenPlayerData instance.
 *
 **************************************************************************************************/
function clearData() {
	local int index;
	
	// Clear entries.
	while (index < arrayCount(attributes)) {
		attributes[index].name = "";
		attributes[index].value = "";
		index++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the value of the specified attribute.
 *  $PARAM        name          Name of the attribute that is to be retrieved.
 *  $PARAM        defaultValue  Value to return if the attribute couldn't been found.
 *  $RETURN       The value of the specified attribute, or the default value if the attribute
 *                doesn't exist.
 *
 **************************************************************************************************/
function string get(string name, optional string defaultValue) {
	local int index;
	local bool bFound;

	// Locate index of attribute.
	while (!bFound && index < arrayCount(attributes)) {
		if (attributes[index].name ~= name) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Return attribute value, or the default value if the attribute wasn't found.
	if (bFound) {
		return attributes[index].value;
	} else {
		return defaultValue;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the boolean value of the specified attribute.
 *  $PARAM        name          Name of the attribute that is to be retrieved.
 *  $PARAM        defaultValue  Value to return if the attribute couldn't been found.
 *  $RETURN       The value of the specified attribute, or the default value if the attribute
 *                doesn't exist.
 *
 **************************************************************************************************/
function bool getBool(string name, optional bool defaultValue) {
	local string value;
	
	value = class'NexgenUtil'.static.trim(get(name));
	if (value == "") {
		return defaultValue;
	} else {
		return value ~= string(true);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the byte value of the specified attribute.
 *  $PARAM        name          Name of the attribute that is to be retrieved.
 *  $PARAM        defaultValue  Value to return if the attribute couldn't been found.
 *  $RETURN       The value of the specified attribute, or the default value if the attribute
 *                doesn't exist.
 *
 **************************************************************************************************/
function byte getByte(string name, optional byte defaultValue) {
	local string value;
	
	value = class'NexgenUtil'.static.trim(get(name));
	if (value == "") {
		return defaultValue;
	} else {
		return byte(value);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the integer value of the specified attribute.
 *  $PARAM        name          Name of the attribute that is to be retrieved.
 *  $PARAM        defaultValue  Value to return if the attribute couldn't been found.
 *  $RETURN       The value of the specified attribute, or the default value if the attribute
 *                doesn't exist.
 *
 **************************************************************************************************/
function int getInt(string name, optional int defaultValue) {
	local string value;
	
	value = class'NexgenUtil'.static.trim(get(name));
	if (value == "") {
		return defaultValue;
	} else {
		return int(value);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the floating point value of the specified attribute.
 *  $PARAM        name          Name of the attribute that is to be retrieved.
 *  $PARAM        defaultValue  Value to return if the attribute couldn't been found.
 *  $RETURN       The value of the specified attribute, or the default value if the attribute
 *                doesn't exist.
 *
 **************************************************************************************************/
function float getFloat(string name, optional float defaultValue) {
	local string value;
	
	value = class'NexgenUtil'.static.trim(get(name));
	if (value == "") {
		return defaultValue;
	} else {
		return float(value);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the specified attribute with the given value.
 *  $PARAM        name     Name of the attribute that is to be stored.
 *  $PARAM        value    (New) Value of the attribute to store.
 *  $REQUIRE      name != ""
 *  $RETURN       True if the attribute was updated/save, false if not.
 *  $ENSURE       result == true ? new.get(name) == value : true
 *
 **************************************************************************************************/
function bool set(string name, coerce string value) {
	local int index;
	local bool bFound;

	// Check if attribute already exists.
	while (!bFound && index < arrayCount(attributes)) {
		if (attributes[index].name ~= name) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// It doesn't, search for an empty entry.
	if (!bFound) {
		index = 0;
		while (!bFound && index < arrayCount(attributes)) {
			if (attributes[index].name == "") {
				bFound = true;
			} else {
				index++;
			}
		}
	}
	
	// Save attribute.
	if (bFound) {
		attributes[index].name = name;
		attributes[index].value = value;
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