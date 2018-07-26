/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigVar
 *  $VERSION      1.06 (06-04-2010 11:06)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Definition class for the mod configuration variables.
 *
 **************************************************************************************************/
class NMCModConfigVar extends Info abstract;

var NMCModConfig modConfig;             // Mod configuration that contains the variable.
var NMCModConfigVar nextVar;            // Next variable in the linked variable list.
var string className;                   // The name of the class of which the variable is a property.
var string varName;                     // Name of the variable.
var byte netType;                       // Network role of variable.
var string description;                 // Description of the variable.
var bool bUnsupported;                  // Indicates whether the variable is supported, meaning that
                                        // it can be read/written on the local machine.
var string serialValue;                 // Serialized value (string) of the value of this variable.
var bool bValueSet;                     // Whether the value of this variable has been set.
var byte inputType;                     // The type of input component to use for this variable.
var NMCModConfigEnumData enumData;      // Enumeration data for the variable.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the mod configuration.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	modConfig = NMCModConfig(owner);
	inputType = getDefaultInputType();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the variable with the given name in the specified class.
 *  $PARAM        className  Name of the class of which the variable is a property.
 *  $PARAM        varName    The class propterty that is to be retrieved.
 *  $PARAM        netType    Network role of variable to retrieve.
 *  $REQUIRE      className != "" && varName != ""
 *  $RETURN       The requested variable or null if the variable does not exist.
 *  $ENSURE       imply(result != none, result.className ~= className &&
 *                                      result.varName   ~= varName &&
 *                                      result.netType   == netType)
 *
 **************************************************************************************************/
function NMCModConfigVar getVar(string className, string varName, byte netType) {
	if (class'NexgenUtil'.static.trim(className) ~= class'NexgenUtil'.static.trim(self.className) &&
	    class'NexgenUtil'.static.trim(varName) ~= class'NexgenUtil'.static.trim(self.varName) &&
	    netType == self.netType) {
		return self;
	} else if (nextVar == none) {
		return none;
	} else {
		return nextVar.getVar(className, varName, netType);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified mod configuration variable to the variable list.
 *  $PARAM        modConfigVar  The mod configuration variable that is to be added
 *  $REQUIRE      modConfigVar != none
 *  $ENSURE       self.getVar(modConfigVar.className, modConfigVar.varName,
 *                            modConfigVar.netType) == modConfigVar
 *
 **************************************************************************************************/
function addVariable(NMCModConfigVar modConfigVar) {
	if (nextVar == none) {
		nextVar = modConfigVar;
	} else {
		nextVar.addVariable(modConfigVar);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the type of data that is stored in the variable.
 *  $RETURN       The type of data that is stored in the variable.
 *
 **************************************************************************************************/
function byte getDataType();



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the mod configuration definition lines stored in the mod configuration to
 *                the specified network traffic handler.
 *  $PARAM        netHandler  The network traffic handler through which the data is to be send.
 *  $REQUIRE      netHandler != none
 *
 **************************************************************************************************/
function sendDefintionLines(NexgenNetClientController netHandler) {
	// Forget about unsupported variables.
	if (bUnsupported) {
		return;
	}
	
	// Add variable register command.
	netHandler.sendStr(modConfig.cfgContainer.CMD_ADD_VAR
	                   @ class'NexgenUtil'.static.formatCmdArg(modConfig.modID)
	                   @ class'NexgenUtil'.static.formatCmdArg(modConfig.cfgContainer.netType2Str(netType))
	                   @ class'NexgenUtil'.static.formatCmdArg(className)
	                   @ class'NexgenUtil'.static.formatCmdArg(varName)
	                   @ class'NexgenUtil'.static.formatCmdArg(modConfig.cfgContainer.dataType2Str(getDataType()))
	                   @ class'NexgenUtil'.static.formatCmdArg(description));

	// Add variable value.
	if (bValueSet) {
		netHandler.sendStr(modConfig.cfgContainer.CMD_SET_VAL
		                   @ class'NexgenUtil'.static.formatCmdArg(modConfig.modID)
		                   @ class'NexgenUtil'.static.formatCmdArg(modConfig.cfgContainer.netType2Str(netType))
		                   @ class'NexgenUtil'.static.formatCmdArg(className)
		                   @ class'NexgenUtil'.static.formatCmdArg(varName)
		                   @ class'NexgenUtil'.static.formatCmdArg(serialValue));
	}
	
	// Add variable input type.
	if (inputType != getDefaultInputType()) {
		netHandler.sendStr(modConfig.cfgContainer.CMD_SET_INPUT_TYPE
		                   @ class'NexgenUtil'.static.formatCmdArg(modConfig.modID)
		                   @ class'NexgenUtil'.static.formatCmdArg(modConfig.cfgContainer.netType2Str(netType))
		                   @ class'NexgenUtil'.static.formatCmdArg(className)
		                   @ class'NexgenUtil'.static.formatCmdArg(varName)
		                   @ class'NexgenUtil'.static.formatCmdArg(modConfig.cfgContainer.inputType2Str(inputType)));
	}
	
	// Add enumeration data for the variable.
	if (enumData != none) {
		enumData.sendDefintionLines(netHandler);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the value of this variable from the local configuration file that contains
 *                the variable. In case the value could not be loaded, the variable will be marked
 *                as invalid and it should be ignored.
 *  $RETURN       True if the value of the variable was successfully loaded, false if not.
 *
 **************************************************************************************************/
function bool loadValue() {
	local string value;
	local bool bValidValue;
	
	// Load value.
	bValidValue = modConfig.cfgContainer.getProperty(className, varName, value);
	
	// Store value if it is valid.
	if (bValidValue) {
		serialValue = value;
		bValueSet = true;
	} else {
		bUnsupported = true;
	}
	
	// Return result.
	return bValidValue;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Locally stores the value of this variable to the configuration file.
 *  $RETURN       True if the value of the variable was successfully stored, false if not.
 *
 **************************************************************************************************/
function bool storeValue() {
	if (modConfig.cfgContainer.setProperty(className, varName, serialValue)) {
		return true;
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the value of this variable.
 *  $RETURN       True if the value of the variable was successfully set, false if not.
 *
 **************************************************************************************************/
function bool setValue(string value) {
	serialValue = validateValue(value);
	bValueSet = true;
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the input type of this variable.
 *  $PARAM        inputType  The input component to use for this variable.
 *  $RETURN       True if the input type of the variable was successfully set, false if not.
 *
 **************************************************************************************************/
function bool setInputType(byte inputType) {
	self.inputType = inputType;
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the default input type for this variable.
 *  $RETURN       The default input type for this variable.
 *
 **************************************************************************************************/
function bool addEnumValue(string enumValue, string enumDescription) {
	// Create enumeration definition holder if necessary.
	if (enumData == none) {
		enumData = spawn(class'NMCModConfigEnumData');
		enumData.modConfigVar = self;
	}
	
	// Add enumeration value.
	enumData.addEnumValue(enumValue, enumDescription);
	
	// Automatically set input type to drowdown for enumerations.
	self.inputType = modConfig.cfgContainer.IT_DROPDOWN;
	
	// Return result.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the default input type for this variable.
 *  $RETURN       The default input type for this variable.
 *
 **************************************************************************************************/
function byte getDefaultInputType();



/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the specified value according to the value restrictions posed on the
 *                mod configuration variable.
 *  $PARAM        value  The serialized value that is to be validated.
 *  $RETURN       A validated version of the given value.
 *
 **************************************************************************************************/
function string validateValue(string value) {
	return value;
}