/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigContainer
 *  $VERSION      1.15 (06-04-2010 10:56)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Container class for the mod configuration definitions.
 *
 **************************************************************************************************/
class NMCModConfigContainer extends Info abstract;

var NMCLang lng;                        // Language instance to support localization.
var NMCModConfig modConfigList;         // Mod configuration linked list.
var string classNotFoundMsg;            // Result of console command in case the class of a GET
                                        // command could not be found.
var string propertyNotFoundMsg;         // Result of console command in case the property of a GET
                                        // command could not be found.
const ARG_CLASSNAME = "%CLASS%";        // Class name argument placeholder for strings.
const ARG_PROPNAME = "%VAR%";           // Property name argument placeholder for strings.

// Commands.
const CMD_REGISTER = "REGISTER";        // Register new mod configuration command.
const CMD_ADD_VAR = "ADD_VAR";          // Add new mod configuration variable command.
const CMD_CLOSE = "CLOSE";              // Finalize mod configuration definition command.
const CMD_SET_VAL = "SET_VAL";          // Set variable value command.
const CMD_SET_INPUT_TYPE = "SET_INP_TYPE"; // Set variable input type command.
const CMD_ADD_ENUM_VAL = "ADD_ENUM_VAL";   // Add enumeration value command.

// Variable net types.
const NT_SERVER = 1;                    // Variable is used server side.
const NT_CLIENT = 2;                    // Variable is used client side.

// Variable data types.
const DT_BOOL = 1;                      // Boolean data type.
const DT_BYTE = 2;                      // Byte data type.
const DT_INT = 3;                       // Integer data type.
const DT_FLOAT = 4;                     // Float data type.
const DT_STRING = 5;                    // String data type.
const DT_ENUM = 6;                      // Enumeration data type.

// Variable input types.
const IT_CHECKBOX = 1;                  // Checkbox component input type.
const IT_EDITBOX = 2;                   // Editbox component input type.
const IT_SLIDER = 3;                    // Slider component input type.
const IT_DROPDOWN = 4;                  // Dropdown combo component input type.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the mod configuration container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	local string temp;
	super.preBeginPlay();
	
	// Determine class not found message.
	classNotFoundMsg = localConsoleCommand("GET XXXXXXXX.YYYYYYYY ZZZZZZZZ");
	classNotFoundMsg = class'NexgenUtil'.static.replace(classNotFoundMsg, "XXXXXXXX.YYYYYYYY", ARG_CLASSNAME);
	
	// Determine property not found message.
	propertyNotFoundMsg = localConsoleCommand("GET Engine.GameEngine ZZZZZZZZ");
	propertyNotFoundMsg = class'NexgenUtil'.static.replace(propertyNotFoundMsg, "ZZZZZZZZ", ARG_PROPNAME);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attemps to read the specified property for the given class.
 *  $PARAM        className     Name of the class from which the property should be read. The
 *                              class name should contain the package that contains the class, e.g.
 *                              "BotPack.DeathMatchPlus"
 *  $PARAM        propertyName  Name of the property that is to be loaded.
 *  $PARAM        value         The value of the specified property.
 *  $REQUIRE      className != "" && propertyName != ""
 *  $RETURN       True if the property was successfully read and the result if valid, false if not.
 *
 **************************************************************************************************/
function bool getProperty(string className, string propertyName, out string value) {
	local bool bValidResult;
	local string result;
	local class<Object> clss;
	
	// Get property value.
	bValidResult = true;
	result = localConsoleCommand("GET" @ className @ propertyName);
	
	// Check for class not found messages.
	if (result ~= class'NexgenUtil'.static.replace(classNotFoundMsg, ARG_CLASSNAME, className)) {
		// Attempt to load class.
		clss = class<Object>(dynamicLoadObject(className, class'class', true));
		
		// Try again.
		if (clss != none) {
			result = localConsoleCommand("GET" @ className @ propertyName);
		} else {
			bValidResult = false;
		}
	}
	
	// Check for property not found messages.
	if (bValidResult && result ~= class'NexgenUtil'.static.replace(propertyNotFoundMsg, ARG_PROPNAME, propertyName)) {
		bValidResult = false;
	}
	
	// Log errors.
	if (!bValidResult) {
		lng.nmcLog(lng.getPropertyErr, className, propertyName);
	}
	
	// Set value & return result.
	value = result;
	return bValidResult;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attemps to write the specified property for the given class.
 *  $PARAM        className     Name of the class which contains the property to be written. The
 *                              class name should contain the package that contains the class, e.g.
 *                              "BotPack.DeathMatchPlus"
 *  $PARAM        propertyName  Name of the property that is to be written.
 *  $PARAM        value         The value of the specified property.
 *  $REQUIRE      className != "" && propertyName != ""
 *  $RETURN       True if the property was successfully stored, false if not.
 *
 **************************************************************************************************/
function bool setProperty(string className, string propertyName, string value) {
	local bool bPropertySet;
	local string result;
	local class<Object> clss;
	
	// Get property value.
	bPropertySet = true;
	result = localConsoleCommand("SET" @ className @ propertyName @ value);
	
	// Check for class not found messages.
	if (result ~= class'NexgenUtil'.static.replace(classNotFoundMsg, ARG_CLASSNAME, className)) {
		// Attempt to load class.
		clss = class<Object>(dynamicLoadObject(className, class'class', true));
		
		// Try again.
		if (clss != none) {
			result = localConsoleCommand("SET" @ className @ propertyName @ value);
		} else {
			bPropertySet = false;
		}
	}
	
	// Check for property not found messages.
	if (bPropertySet && result ~= class'NexgenUtil'.static.replace(propertyNotFoundMsg, ARG_PROPNAME, propertyName)) {
		bPropertySet = false;
	}
	
	// Log errors.
	if (!bPropertySet) {
		lng.nmcLog(lng.setPropertyErr, className, propertyName);
	}
	
	// Return result.
	return bPropertySet;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes the specified console command.
 *  $PARAM        command  The command that is to be executed.
 *  $RETURN       The result of the console command.
 *
 **************************************************************************************************/
function string localConsoleCommand(string command);



/***************************************************************************************************
 *
 *  $DESCRIPTION  Registers the mod with the specified identifier in the container.
 *  $PARAM        modID  The ID of the mod that is to be registered.
 *  $PARAM        title  Name of the mod.
 *  $REQUIRE      modID != ""
 *  $RETURN       True if the mod was successfully registered, false if not.
 *
 **************************************************************************************************/
function bool registerMod(string modID, string title) {
	local NMCModConfig modConfig;
	
	if (modConfigList == none || modConfigList.getMod(modID) == none) {
		// Create mod config object.
		modConfig = spawn(class'NMCModConfig', self);
		modConfig.modID = modID;
		modConfig.title = title;
		
		// Add mod config object.
		if (modConfigList == none) {
			modConfigList = modConfig;
		} else {
			modConfigList.addMod(modConfig);
		}
		
		return true;
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the given variable (description) to the specified mod.
 *  $PARAM        modID        The ID of the mod in which the variable should be added.
 *  $PARAM        className    Name of the class of which the variable is a property. The class name
 *                             may include a package prefix, for example: "SLV204.SLConfig".
 *  $PARAM        varName      Name of the variable that is to be added
 *  $PARAM        netType      Net relevancy of the variable (client or server).
 *  $PARAM        dataType     Type of data that is being stored by the variable.
 *  $PARAM        description  Textual description of the variable.
 *  $REQUIRE      modID != "" && className != "" && varName != "" &&
 *                (netType  == NT_SERVER || netType  == NT_CLIENT) &&
 *                (dataType == DT_BOOL   || dataType == DT_BYTE   || dataType == DT_INT ||
 *                 dataType == DT_FLOAT  || dataType == DT_STRING || dataType == DT_ENUM)
 *  $RETURN       True if the variable was successfully added, false if not.
 *
 **************************************************************************************************/
function bool addVariable(string modID, string className, string varName, byte netType, byte dataType, string description) {
	local NMCModConfig modConfig;
	
	// Get mod config object for variable.
	if (modConfigList != none) {
		modConfig = modConfigList.getMod(modID);
	}
	
	// Add variable to mod config object.
	if (modConfig == none) {
		return false;
	} else {
		return modConfig.addVariable(className, varName, netType, dataType, description);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Closes the mod configuration definition for the specified mod.
 *  $PARAM        modID  The ID of the mod that is to be closed.
 *  $REQUIRE      modID != ""
 *  $RETURN       True if the mod was successfully closed, false if not.
 *
 **************************************************************************************************/
function bool closeMod(string modID) {
	local NMCModConfig modConfig;
	
	// Get mod config object for variable.
	if (modConfigList != none) {
		modConfig = modConfigList.getMod(modID);
	}
	
	// Add variable to mod config object.
	if (modConfig == none) {
		return false;
	} else {
		return modConfig.close();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the mod configuration definition lines stored in the container to the
 *                specified network traffic handler.
 *  $PARAM        netHandler          The network traffic handler through which the data is to be send.
 *  $PARAM        bIncludeServerVars  Whether to also count definition lines for server variables.
 *  $REQUIRE      netHandler != none
 *
 **************************************************************************************************/
function sendDefintionLines(NexgenNetClientController netHandler, optional bool bIncludeServerVars) {
	local NMCModConfig modConfig;
	
	for (modConfig = modConfigList; modConfig != none; modConfig = modConfig.nextModConfig) {
		modConfig.sendDefintionLines(netHandler, bIncludeServerVars);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the variable value for the specified mod.
 *  $PARAM        modID        The ID of the mod in which the variable should reside.
 *  $PARAM        className    Name of the class of which the variable is a property. The class name
 *                             may include a package prefix, for example: "SLV204.SLConfig".
 *  $PARAM        varName      Name of the variable whose value is to be set.
 *  $PARAM        netType      Net relevancy of the variable (client or server).
 *  $PARAM        value        Value of the variable (in serialized format).
 *  $REQUIRE      modID != "" && className != "" && varName != "" &&
 *                (netType  == NT_SERVER || netType  == NT_CLIENT)
 *  $RETURN       True if the value of the variable has been successfully set, false if not.
 *
 **************************************************************************************************/
function bool setVarValue(string modID, string className, string varName, byte netType, string value) {
	local NMCModConfig modConfig;
	
	// Get mod config object for variable.
	if (modConfigList != none) {
		modConfig = modConfigList.getMod(modID);
	}
	
	// Set variable value for the mod config object.
	if (modConfig == none) {
		return false;
	} else {
		return modConfig.setVarValue(className, varName, netType, value);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the input type for the specified variable.
 *  $PARAM        modID        The ID of the mod in which the variable should reside.
 *  $PARAM        className    Name of the class of which the variable is a property. The class name
 *                             may include a package prefix, for example: "SLV204.SLConfig".
 *  $PARAM        varName      Name of the variable whose input type is to be set.
 *  $PARAM        netType      Net relevancy of the variable (client or server).
 *  $PARAM        inputType    Type of input component to use for the variable.
 *  $REQUIRE      modID != "" && className != "" && varName != "" &&
 *                (netType   == NT_SERVER   || netType   == NT_CLIENT) &&
 *                (inputType == IT_CHECKBOX || inputType == IT_EDITBOX ||
 *                 inputType == IT_SLIDER   || inputType == IT_DROPDOWN)
 *  $RETURN       True if the input type of the variable has been successfully set, false if not.
 *
 **************************************************************************************************/
function bool setVarInputType(string modID, string className, string varName, byte netType, byte inputType) {
	local NMCModConfig modConfig;
	
	// Get mod config object for variable.
	if (modConfigList != none) {
		modConfig = modConfigList.getMod(modID);
	}
	
	// Set variable input type for the mod config object.
	if (modConfig == none) {
		return false;
	} else {
		return modConfig.setVarInputType(className, varName, netType, inputType);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the given enumeration value to the specified variable.
 *  $PARAM        modID            The ID of the mod in which the variable should reside.
 *  $PARAM        className        Name of the class of which the variable is a property. The class
 *                                 name may include a package prefix, for example: "SLV204.SLConfig".
 *  $PARAM        varName          Name of the variable to which the enumeration value is to be added.
 *  $PARAM        netType          Net relevancy of the variable (client or server).
 *  $PARAM        enumValue        Enumeration value to add (in serialized format).
 *  $PARAM        enumDescription  Description of the enumeration value.
 *  $REQUIRE      modID != "" && className != "" && varName != "" &&
 *                (netType  == NT_SERVER || netType  == NT_CLIENT)
 *  $RETURN       True if the enumeration value has been successfully added, false if not.
 *
 **************************************************************************************************/
function bool addVarEnumValue(string modID, string className, string varName, byte netType, string enumValue, string enumDescription) {
	local NMCModConfig modConfig;
	
	// Get mod config object for variable.
	if (modConfigList != none) {
		modConfig = modConfigList.getMod(modID);
	}
	
	// Add variable enumeration value for the mod config object.
	if (modConfig == none) {
		return false;
	} else {
		return modConfig.addVarEnumValue(className, varName, netType, enumValue, enumDescription);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the mod configuration definition for the specified mod.
 *  $PARAM        modID        The ID of the mod configuration to retrieve.
 *  $RETURN       The mod configuration definition for the specified mod.
 *
 **************************************************************************************************/
function NMCModConfig getModConfig(string modID) {
	return modConfigList.getMod(modID);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the specified data type code to a data type description string.
 *  $PARAM        dataType  The data type code that is to be converted.
 *  $RETURN       Data type description string for the specified data type or an empty string if an
 *                invalid code is given.
 *
 **************************************************************************************************/
static function string dataType2Str(byte dataType) {
	switch (dataType) {
		case DT_BOOL:   return "BOOL";
		case DT_BYTE:   return "BYTE";
		case DT_INT:    return "INT";
		case DT_FLOAT:  return "FLOAT";
		case DT_STRING: return "STRING";
		case DT_ENUM:   return "ENUM";			
		default:        return "";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the specified data type description string to a byte that represents the
 *                code of the data type.
 *  $PARAM        dataType  A string containing the data type description string.
 *  $RETURN       The data type code for that corresponds with the given data type description
 *                string or -1 in case an invalid string is given.
 *
 **************************************************************************************************/
static function byte str2dataType(string dataType) {
	switch (caps(class'NexgenUtil'.static.trim(dataType))) {
		case "BOOL":   return DT_BOOL;
		case "BYTE":   return DT_BYTE;
		case "INT":    return DT_INT;
		case "FLOAT":  return DT_FLOAT;
		case "STRING": return DT_STRING;
		case "ENUM":   return DT_ENUM;
		default:       return -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the specified net type code to a net type description string.
 *  $PARAM        netType  The net type code that is to be converted.
 *  $RETURN       Net type description string for the specified net type or an empty string if an
 *                invalid code is given.
 *
 **************************************************************************************************/
static function string netType2Str(byte netType) {
	switch (netType) {
		case NT_SERVER: return "SERVER";
		case NT_CLIENT: return "CLIENT";
		default:        return "";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the specified net type description string to a byte that represents the
 *                code of the net type.
 *  $PARAM        netType  A string containing the net type description string.
 *  $RETURN       The net type code for that corresponds with the given net type description string
 *                or -1 in case an invalid string is given.
 *
 **************************************************************************************************/
static function byte str2NetType(string netType) {
	switch (caps(class'NexgenUtil'.static.trim(netType))) {
		case "SERVER": return NT_SERVER;
		case "CLIENT": return NT_CLIENT;
		default:       return -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the specified input type code to a input type description string.
 *  $PARAM        inputType  The input type code that is to be converted.
 *  $RETURN       Input type description string for the specified input type or an empty string if
 *                an invalid code is given.
 *
 **************************************************************************************************/
static function string inputType2Str(byte inputType) {
	switch (inputType) {
		case IT_CHECKBOX: return "CHECKBOX";
		case IT_EDITBOX:  return "EDITBOX";
		//case IT_SLIDER:   return "SLIDER"; -- Not supported (yet)
		case IT_DROPDOWN: return "DROPDOWN";
		default:          return "";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the specified input type description string to a byte that represents the
 *                code of the input type.
 *  $PARAM        inputType  A string containing the input type description string.
 *  $RETURN       The input type code for that corresponds with the given input type description
 *                string or -1 in case an invalid string is given.
 *
 **************************************************************************************************/
static function byte str2InputType(string inputType) {
	switch (caps(class'NexgenUtil'.static.trim(inputType))) {
		case "CHECKBOX": return IT_CHECKBOX;
		case "EDITBOX":  return IT_EDITBOX;
		//case "SLIDER":   return IT_SLIDER; -- Not supported (yet)
		case "DROPDOWN": return IT_DROPDOWN;
		default:         return -1;
	}
}
