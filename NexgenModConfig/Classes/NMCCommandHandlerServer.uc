/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCCommandHandlerServer
 *  $VERSION      1.01 (22-02-2010 16:36)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Command handler for the server.
 *
 **************************************************************************************************/
class NMCCommandHandlerServer extends NMCCommandHandler;



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
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool handleCommand(Actor source, string cmd, string args[10], out string error, out string result) {
	local NMCClient xClient;
	local bool bAllowCommand;
	
	xClient = NMCClient(source);
	
	// Check whether the command is allowed.
	bAllowCommand = NMCMain(source) != none || xClient != none && xClient.client.hasRight(xClient.client.R_ServerAdmin);

	// Execute command if allowed.
	if (bAllowCommand) {
		return super.handleCommand(source, cmd, args, error, result);
	} else {
		if (xClient != none) {
			lng.nmcLog(lng.blockedCmdWarning, xClient.client.playerName, cmd);
		}
		return false;
	}
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
	
	// Log action.
	if (error == "" && NMCClient(source) != none) {
		varNetType = cfgContainer.str2NetType(args[1]);
		modConfig = cfgContainer.getModConfig(args[0]);
		modConfigVar = modConfig.varList.getVar(args[2], args[3], varNetType);
		lng.logAdminAction(lng.adminChangeVarMsg, NMCClient(source).client,
		                   modConfigVar.className $ "." $ modConfigVar.varName,
		                   modConfigVar.serialValue, , true);
	}
	
	// Return result.
	return result;
}