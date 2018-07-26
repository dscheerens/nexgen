/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCCommandHandlerClient
 *  $VERSION      1.01 (22-02-2010 16:39)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Command handler for the clients.
 *
 **************************************************************************************************/
class NMCCommandHandlerClient extends NMCCommandHandler;



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
	local string result;
	
	result = super.execCloseModDef(source, args, error);
	
	if (error == "") {
		NMCClient(source).createModConfigPanels(args[0]);
	}
	
	return result;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a set mod variable value command.
 *  $PARAM        source  Source of the command call.
 *  $PARAM        args    The arguments of the command.
 *  $PARAM        error   Error description in case the command failed, empty if it succeeded.
 *  $RETURN       The result of the executed command.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string execSetModVarValue(Actor source, string args[10], out string error) {
	local string result;
	local byte varNetType;
	local NMCModConfig modConfig;
	local NMCModConfigVar modConfigVar;
	
	// Execute command.
	result = super.execSetModVarValue(source, args, error);
	
	// Update GUI.
	if (error == "" && NMCClient(source) != none) {
		varNetType = cfgContainer.str2NetType(args[1]);
		modConfig = cfgContainer.getModConfig(args[0]);
		modConfigVar = modConfig.varList.getVar(args[2], args[3], varNetType);
		NMCClient(source).updateModConfigVar(modConfigVar);
	}
	
	// Return result.
	return result;
}