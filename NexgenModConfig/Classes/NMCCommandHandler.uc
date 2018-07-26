/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCCommandHandler
 *  $VERSION      1.09 (22-02-2010 12:47)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Handles the mod configuration definition commands that are received by the plugin.
 *
 **************************************************************************************************/
class NMCCommandHandler extends info;

var NMCLang lng;                        // Language instance to support localization.
var NMCModConfigContainer cfgContainer; // The mod config container on which to operate.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes the given command.
 *  $PARAM        source  The source of the execute command call.
 *  $PARAM        cmd     The command that is to be executed.
 *  $REQUIRE      cmd != ""
 *  $RETURN       The result of the executed command.
 *
 **************************************************************************************************/
function string execCommand(Actor source, string cmd) {
	local bool bParseOk;
	local string cmdName;
	local string args[10];
	local string result;
	local string error;
	
	
	// Parse command string.
	bParseOk = class'NexgenUtil'.static.parseCommandStr("NSC" @ cmd, cmdName, args);
	
	// Quit if an invalid command string was received.
	if (!bParseOk) {
		lng.nmcLog(lng.invalidCommandMsg, cmd);
		return "";
	}
	
	// Handle command.
	if (handleCommand(source, cmdName, args, error, result)) {
		// Log error if there was one.
		if (error != "") {
			lng.nmcLog(lng.commandFailedMsg, cmd, error);
		}
	} else {
		default: lng.nmcLog(lng.unknownCommandMsg, cmdName);
	}
	
	return result;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles the specified command.
 *  $PARAM        source  Source of the command call.
 *  $PARAM        cmd     Name of the command that is to be executed.
 *  $PARAM        args    The arguments of the command.
 *  $PARAM        error   Error description in case the command failed, empty if it succeeded.
 *  $PARAM        result  The result of the executed command.
 *  $REQUIRE      cmd != ""
 *  $RETURN       True if the command was recognized, false if not.
 *
 **************************************************************************************************/
function bool handleCommand(Actor source, string cmd, string args[10], out string error, out string result) {
	local bool bUnrecognizedCommand;
	
	// Handle command.
	switch (caps(cmd)) {
		case cfgContainer.CMD_REGISTER:       result = execRegisterMod(source, args, error); break;
		case cfgContainer.CMD_ADD_VAR:        result = execAddModVar(source, args, error); break;
		case cfgContainer.CMD_CLOSE:          result = execCloseModDef(source, args, error); break;
		case cfgContainer.CMD_SET_VAL:        result = execSetModVarValue(source, args, error); break;
		case cfgContainer.CMD_SET_INPUT_TYPE: result = execSetModVarInputType(source, args, error); break;
		case cfgContainer.CMD_ADD_ENUM_VAL:   result = execAddModVarEnumValue(source, args, error); break;
		default: bUnrecognizedCommand = true;
	}
	
	// Return result.
	return !bUnrecognizedCommand;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a register mod command.
 *  $PARAM        source  Source of the command call.
 *  $PARAM        args    The arguments of the command.
 *  $PARAM        error   Error description in case the command failed, empty if it succeeded.
 *  $RETURN       The result of the executed command.
 *
 **************************************************************************************************/
function string execRegisterMod(Actor source, string args[10], out string error) {
	if (class'NexgenUtil'.static.trim(args[0]) == "") {
		error = lng.modIDMissingErr;
	} else if (!cfgContainer.registerMod(args[0], args[1])) {
		error = lng.actionFailedErr;
	}
	
	return "";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a add mod variable command.
 *  $PARAM        source  Source of the command call.
 *  $PARAM        args    The arguments of the command.
 *  $PARAM        error   Error description in case the command failed, empty if it succeeded.
 *  $RETURN       The result of the executed command.
 *
 **************************************************************************************************/
function string execAddModVar(Actor source, string args[10], out string error) {
	local byte varNetType;
	local byte varDataType;
	
	// Check if all required arguments are present.
	if (class'NexgenUtil'.static.trim(args[0]) == "") {
		error = lng.modIDMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[1]) == "") {
		error = lng.netTypeMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[2]) == "") {
		error = lng.classMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[3]) == "") {
		error = lng.varNameMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[4]) == "") {
		error = lng.dataTypeMissingErr;
	}
	
	// Check variable net type.
	if (error == "") {
		varNetType = cfgContainer.str2NetType(args[1]);
		if (varNetType < 0) {
			error = lng.unknownNetTypeErr;
		}
	}
	
	// Check variable data type.
	if (error == "") {
		varDataType = cfgContainer.str2DataType(args[4]);
		if (varDataType < 0) {
			error = lng.unknownDataTypeErr;
		}
	}
	
	// Add variable.
	if (error == "") {
		if (!cfgContainer.addVariable(args[0], args[2], args[3], varNetType, varDataType, args[5])) {
			error = lng.actionFailedErr;
		}
	}
	
	return "";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a close mod config definition command.
 *  $PARAM        source  Source of the command call.
 *  $PARAM        args    The arguments of the command.
 *  $PARAM        error   Error description in case the command failed, empty if it succeeded.
 *  $RETURN       The result of the executed command.
 *
 **************************************************************************************************/
function string execCloseModDef(Actor source, string args[10], out string error) {
	if (class'NexgenUtil'.static.trim(args[0]) == "") {
		error = lng.modIDMissingErr;
	} else if (!cfgContainer.closeMod(args[0])) {
		error = lng.actionFailedErr;
	}
	
	return "";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a set mod variable value command.
 *  $PARAM        source  Source of the command call.
 *  $PARAM        args    The arguments of the command.
 *  $PARAM        error   Error description in case the command failed, empty if it succeeded.
 *  $RETURN       The result of the executed command.
 *
 **************************************************************************************************/
function string execSetModVarValue(Actor source, string args[10], out string error) {
	local byte varNetType;
	
	// Check if all required arguments are present.
	if (class'NexgenUtil'.static.trim(args[0]) == "") {
		error = lng.modIDMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[1]) == "") {
		error = lng.netTypeMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[2]) == "") {
		error = lng.classMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[3]) == "") {
		error = lng.varNameMissingErr;
	}
	
	// Check variable net type.
	if (error == "") {
		varNetType = cfgContainer.str2NetType(args[1]);
		if (varNetType < 0) {
			error = lng.unknownNetTypeErr;
		}
	}
	
	// Set variable value.
	if (error == "") {
		if (!cfgContainer.setVarValue(args[0], args[2], args[3], varNetType, args[4])) {
			error = lng.actionFailedErr;
		}
	}
	
	return "";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a set mod variable input type command.
 *  $PARAM        source  Source of the command call.
 *  $PARAM        args    The arguments of the command.
 *  $PARAM        error   Error description in case the command failed, empty if it succeeded.
 *  $RETURN       The result of the executed command.
 *
 **************************************************************************************************/
function string execSetModVarInputType(Actor source, string args[10], out string error) {
	local byte varNetType;
	local byte varInputType;
	
	// Check if all required arguments are present.
	if (class'NexgenUtil'.static.trim(args[0]) == "") {
		error = lng.modIDMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[1]) == "") {
		error = lng.netTypeMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[2]) == "") {
		error = lng.classMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[3]) == "") {
		error = lng.varNameMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[4]) == "") {
		error = lng.inputTypeMissingErr;
	}
	
	// Check variable net type.
	if (error == "") {
		varNetType = cfgContainer.str2NetType(args[1]);
		if (varNetType < 0) {
			error = lng.unknownNetTypeErr;
		}
	}
	
	// Check variable input type.
	if (error == "") {
		varInputType = cfgContainer.str2InputType(args[4]);
		if (varInputType < 0) {
			error = lng.unknownInputTypeErr;
		}
	}
	
	// Set variable value.
	if (error == "") {
		if (!cfgContainer.setVarInputType(args[0], args[2], args[3], varNetType, varInputType)) {
			error = lng.actionFailedErr;
		}
	}
	
	return "";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a add mod variable enumeration value command.
 *  $PARAM        source  Source of the command call.
 *  $PARAM        args    The arguments of the command.
 *  $PARAM        error   Error description in case the command failed, empty if it succeeded.
 *  $RETURN       The result of the executed command.
 *
 **************************************************************************************************/
function string execAddModVarEnumValue(Actor source, string args[10], out string error) {
	local byte varNetType;
	
	// Check if all required arguments are present.
	if (class'NexgenUtil'.static.trim(args[0]) == "") {
		error = lng.modIDMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[1]) == "") {
		error = lng.netTypeMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[2]) == "") {
		error = lng.classMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[3]) == "") {
		error = lng.varNameMissingErr;
	} else if (class'NexgenUtil'.static.trim(args[4]) == "") {
		error = lng.enumValueMissingErr;
	}
	
	// Check variable net type.
	if (error == "") {
		varNetType = cfgContainer.str2NetType(args[1]);
		if (varNetType < 0) {
			error = lng.unknownNetTypeErr;
		}
	}
	
	// Set variable value.
	if (error == "") {
		if (!cfgContainer.addVarEnumValue(args[0], args[2], args[3], varNetType, args[4], args[5])) {
			error = lng.actionFailedErr;
		}
	}
	
	return "";
}