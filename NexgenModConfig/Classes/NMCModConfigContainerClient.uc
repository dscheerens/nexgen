/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigContainerClient
 *  $VERSION      1.01 (02-02-2010 21:27)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Container class for the mod configuration definitions. Client version.
 *
 **************************************************************************************************/
class NMCModConfigContainerClient extends NMCModConfigContainer;

var NMCClient xClient;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the mod configuration container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	xClient = NMCClient(owner);
	
	super.preBeginPlay();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes the specified console command.
 *  $PARAM        command  The command that is to be executed.
 *  $RETURN       The result of the console command.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string localConsoleCommand(string command) {
	local string result;
	
	level.netMode = NM_Standalone;
	result = consoleCommand(command);
	level.netMode = NM_Client;
	
	return result;
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
			if (modConfigVar.netType == NT_CLIENT) {
				modConfigVar.loadValue();
			}
		}
	}
	
	// Return result.
	return bClosed;
}