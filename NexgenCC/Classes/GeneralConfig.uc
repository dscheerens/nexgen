/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        GeneralConfig
 *  $VERSION      1.00 (19-12-2006 14:09)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Client configuration settings container class. Any client side settings for the
 *                Nexgen server controller are stored in this class. They can be accessed using the
 *                get and set functions.
 *
 **************************************************************************************************/
class GeneralConfig extends Info config(User);

struct GeneralSettingEntry {                                // Setting description structure.
	var string name;
	var string value;
};

var private config GeneralSettingEntry settings[16];        // List of all (saved) settings.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the value of the specified setting.
 *  $PARAM        name          Name of the setting that is to be retrieved.
 *  $PARAM        defaultValue  Value to return if the setting couldn't been found.
 *  $RETURN       The value of the specified setting, or the default value if the setting doesn't
 *                exist.
 *
 **************************************************************************************************/
function string get(string name, optional string defaultValue) {
	local int index;
	local bool bFound;

	// Locate index of setting.
	while (!bFound && index < arrayCount(settings)) {
		if (settings[index].name ~= name) {
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
 *  $DESCRIPTION  Updates the specified setting with the given value.
 *  $PARAM        name     Name of the setting that is to be stored.
 *  $PARAM        value    (New) Value of the setting to store.
 *  $REQUIRE      name != ""
 *  $RETURN       True if the setting was updated/save, false if not.
 *  $ENSURE       result == true ? new.get(name) == value : true
 *
 **************************************************************************************************/
function bool set(string name, string value) {
	local int index;
	local bool bFound;

	// Check if setting already exists.
	while (!bFound && index < arrayCount(settings)) {
		if (settings[index].name ~= name) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// It doesn't, search for an empty entry.
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
	
	// Save setting.
	if (bFound) {
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