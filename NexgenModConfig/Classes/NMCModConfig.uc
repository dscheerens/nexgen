/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfig
 *  $VERSION      1.10 (06-04-2010 11:01)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Definition class for the mod configurations.
 *
 **************************************************************************************************/
class NMCModConfig extends Info;

var string modID;                       // Identification string of the mod.
var string title;                       // The name of mod.
var NMCModConfig nextModConfig;         // The next mod config object in the linked list.
var NMCModConfigContainer cfgContainer; // The mod config container that contains this mod config.
var NMCModConfigVar varList;            // Linked list of variables for the mod configuration.
var bool bClosed;                       // Whether the definition is finalized.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the mod configuration.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	cfgContainer = NMCModConfigContainer(owner);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the mod config object with the specified identifier.
 *  $PARAM        modID  The ID of the mod that is to be retrieved.
 *  $REQUIRE      modID != ""
 *  $RETURN       The requested mod config object or null if no mod config object exists with the
 *                specified identifier.
 *  $ENSURE       imply(result != none, caps(result.modID) == caps(modID))
 *
 **************************************************************************************************/
function NMCModConfig getMod(string modID) {
	if (caps(class'NexgenUtil'.static.trim(modID)) == caps(class'NexgenUtil'.static.trim(self.modID))) {
		return self;
	} else if (nextModConfig == none) {
		return none;
	} else {
		return nextModConfig.getMod(modID);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the given mod config object to the linked list.
 *  $PARAM        modConfig  The mod config object that is to be added to the list.
 *  $REQUIRE      modID != none
 *  $ENSURE       self.getMod(modConfig.modID) != none
 *
 **************************************************************************************************/
function addMod(NMCModConfig modConfig) {
	if (nextModConfig == none) {
		nextModConfig = modConfig;
	} else {
		nextModConfig.addMod(modConfig);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the given variable (description) to the mod configuration.
 *  $PARAM        className    Name of the class of which the variable is a property. The class name
 *                             may include a package prefix, for example: "SLV204.SLConfig".
 *  $PARAM        varName      Name of the variable that is to be added
 *  $PARAM        netType      Net relevancy of the variable (client only, server only or both).
 *  $PARAM        dataType     Type of data that is being stored by the variable.
 *  $PARAM        description  Textual description of the variable.
 *  $REQUIRE      className != "" && varName != "" &&
 *                (netType  == NT_SERVER || netType  == NT_CLIENT || netType  == NT_BOTH) &&
 *                (dataType == DT_BOOL   || dataType == DT_BYTE   || dataType == DT_INT ||
 *                 dataType == DT_FLOAT  || dataType == DT_STRING || dataType == DT_ENUM)
 *  $RETURN       True if the variable was successfully added, false if not.
 *
 **************************************************************************************************/
function bool addVariable(string className, string varName, byte netType, byte dataType, string description) {
	local NMCModConfigVar modConfigVar;
	
	// Check if the mod configuration defintion has been closed;
	if (bClosed) {
		return false;
	}
	
	// Add variable.
	if (varList == none || varList.getVar(className, varName, netType) == none) {
		// Create mod config variable object.
		switch (dataType) {
			case cfgContainer.DT_BOOL:   modConfigVar = spawn(class'NMCModConfigVarBool', self); break;
			case cfgContainer.DT_BYTE:   modConfigVar = spawn(class'NMCModConfigVarByte', self); break;
			case cfgContainer.DT_INT :   modConfigVar = spawn(class'NMCModConfigVarInt', self); break;
			case cfgContainer.DT_FLOAT:  modConfigVar = spawn(class'NMCModConfigVarFloat', self); break;
			case cfgContainer.DT_STRING: modConfigVar = spawn(class'NMCModConfigVarString', self); break;
			case cfgContainer.DT_ENUM:   modConfigVar = spawn(class'NMCModConfigVarEnum', self); break;
		}
		modConfigVar.className = className;
		modConfigVar.varName = varName;
		modConfigVar.netType = netType;
		modConfigVar.description = description;
		
		// Add mod config variable object.
		if (varList == none) {
			varList = modConfigVar;
		} else {
			varList.addVariable(modConfigVar);
		}
		
		return true;
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the mod configuration definition lines stored in the mod configuration to
 *                the specified network traffic handler.
 *  $PARAM        netHandler          The network traffic handler through which the data is to be send.
 *  $PARAM        bIncludeServerVars  Whether to also count definition lines for server variables.
 *  $REQUIRE      netHandler != none
 *
 **************************************************************************************************/
function sendDefintionLines(NexgenNetClientController netHandler, optional bool bIncludeServerVars) {
	local NMCModConfigVar modConfigVar;
	local int relevantVarCount;
	
	// First check if there are at least some variable relevant for the client.
	for (modConfigVar = varList; modConfigVar != none; modConfigVar = modConfigVar.nextVar) {
		if ((modConfigVar.netType == cfgContainer.NT_CLIENT || bIncludeServerVars) &&
		    !modConfigVar.bUnsupported) {
			relevantVarCount++;
		}
	}
	if (relevantVarCount == 0) {
		return; // Don't send mod definitions if there are no relevant variables.
	}

	// Add register command.
	netHandler.sendStr(cfgContainer.CMD_REGISTER
	                   @ class'NexgenUtil'.static.formatCmdArg(modID)
	                   @ class'NexgenUtil'.static.formatCmdArg(title));
	
	// Add variable definition lines.
	for (modConfigVar = varList; modConfigVar != none; modConfigVar = modConfigVar.nextVar) {
		if ((modConfigVar.netType == cfgContainer.NT_CLIENT || bIncludeServerVars) &&
		    !modConfigVar.bUnsupported) {
			modConfigVar.sendDefintionLines(netHandler);
		}
	}

	// Add close command.
	if (bClosed) {
		netHandler.sendStr(cfgContainer.CMD_CLOSE
		                   @ class'NexgenUtil'.static.formatCmdArg(modID));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the value for the specified variable.
 *  $PARAM        className    Name of the class of which the variable is a property. The class name
 *                             may include a package prefix, for example: "SLV204.SLConfig".
 *  $PARAM        varName      Name of the variable whose value is to be set.
 *  $PARAM        netType      Net relevancy of the variable (client or server).
 *  $PARAM        value        Value of the variable (in serialized format).
 *  $REQUIRE      className != "" && varName != "" &&
 *                (netType  == NT_SERVER || netType  == NT_CLIENT)
 *  $RETURN       True if the value of the variable has been successfully set, false if not.
 *
 **************************************************************************************************/
function bool setVarValue(string className, string varName, byte netType, string value) {
	local NMCModConfigVar modConfigVar;
	
	// Get variable.
	if (varList != none) {
		modConfigVar = varList.getVar(className, varName, netType);
	}
	
	// Set variable value.
	if (modConfigVar != none) {
		return modConfigVar.setValue(value);
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the input type for the specified variable.
 *  $PARAM        className    Name of the class of which the variable is a property. The class name
 *                             may include a package prefix, for example: "SLV204.SLConfig".
 *  $PARAM        varName      Name of the variable whose input type is to be set.
 *  $PARAM        netType      Net relevancy of the variable (client or server).
 *  $PARAM        inputType    Type of input component to use for the variable.
 *  $REQUIRE      className != "" && varName != "" &&
 *                (netType   == NT_SERVER   || netType   == NT_CLIENT) &&
 *                (inputType == IT_CHECKBOX || inputType == IT_EDITBOX ||
 *                 inputType == IT_SLIDER   || inputType == IT_DROPDOWN)
 *  $RETURN       True if the input type of the variable has been successfully set, false if not.
 *
 **************************************************************************************************/
function bool setVarInputType(string className, string varName, byte netType, byte inputType) {
	local NMCModConfigVar modConfigVar;
	
	// Check if the mod configuration defintion has been closed;
	if (bClosed) {
		return false;
	}
	
	// Get variable.
	if (varList != none) {
		modConfigVar = varList.getVar(className, varName, netType);
	}
	
	// Set variable input type for the variable.
	if (modConfigVar == none) {
		return false;
	} else {
		return modConfigVar.setInputType(inputType);
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
function bool addVarEnumValue(string className, string varName, byte netType, string enumValue, string enumDescription) {
	local NMCModConfigVar modConfigVar;
	
	// Check if the mod configuration defintion has been closed;
	if (bClosed) {
		return false;
	}
	
	// Get variable.
	if (varList != none) {
		modConfigVar = varList.getVar(className, varName, netType);
	}
	
	// Add variable enumeration value for the mod config object.
	if (modConfigVar == none) {
		return false;
	} else {
		return modConfigVar.addEnumValue(enumValue, enumDescription);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Closes the mod configuration definition.
 *  $RETURN       True if the mod was successfully closed, false if not.
 *
 **************************************************************************************************/
function bool close() {
	bClosed = true;
	return true;
}