/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigContainerServer
 *  $VERSION      1.01 (02-02-2010 21:21)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Container class for the mod configuration definitions. Server version.
 *
 **************************************************************************************************/
class NMCModConfigContainerServer extends NMCModConfigContainer;

var NMCMain xControl;                   // The plugin controller.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes the specified console command.
 *  $PARAM        command  The command that is to be executed.
 *  $RETURN       The result of the console command.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string localConsoleCommand(string command) {
	return consoleCommand(command);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Closes the mod configuration definition for the specified mod.
 *  $PARAM        modID  The ID of the mod that is to be closed.
 *  $REQUIRE      modID != ""
 *  $RETURN       True if the mod was successfully closed, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool closeMod(string modID) {
	local bool bClosed;
	local NMCModConfig modConfig;
	local NMCModConfigVar modConfigVar;
	
	bClosed = super.closeMod(modID);
	
	// Get mod config object for variable.
	if (bClosed && modConfigList != none) {
		modConfig = modConfigList.getMod(modID);
	}
	
	// Load variable values.
	if (bClosed && modConfig != none) {
		for (modConfigVar = modConfig.varList; modConfigVar != none; modConfigVar = modConfigVar.nextVar) {
			if (modConfigVar.netType == NT_SERVER) {
				modConfigVar.loadValue();
			}
		}
	}
	
	// Return result.
	return bClosed;
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
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool setVarValue(string modID, string className, string varName, byte netType, string value) {
	local NMCModConfig modConfig;
	local NMCModConfigVar modConfigVar;
	local string oldValue;
	
	// Get old value of variable.
	if (modConfigList != none) {
		modConfig = modConfigList.getMod(modID);
	}
	if (modConfig != none && modConfig.varList != none) {
		modConfigVar = modConfig.varList.getVar(className, varName, netType);
	}
	if (modConfigVar != none) {
		oldValue = modConfigVar.serialValue;
	}
	
	// First let super class handle the action.
	if (!super.setVarValue(modID, className, varName, netType, value)) {
		return false;
	}
	
	// Check if value of variable has changed.
	if (modConfigVar.serialValue != oldValue) {
		xControl.modConfigVarChanged(modConfigVar);
	}
	
	// Action succeeded.
	return true;
}