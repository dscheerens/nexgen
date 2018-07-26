/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigPanelServer
 *  $VERSION      1.02 (20-02-2010 17:37)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen control panel for editing mod server side configurations.
 *
 **************************************************************************************************/
class NMCModConfigPanelServer extends NMCModConfigPanel;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified mod configuration variable is supported by this
 *                panel. Variables that are supported are displayed on the panel and can be edited.
 *  $PARAM        modConfigVar  The mod configuration variable that is to be tested.
 *  $REQUIRE      modConfigVar != none
 *  $RETURN       True if the variable is supported, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool supportsVariable(NMCModConfigVar modConfigVar) {
	return modConfigVar.netType == modConfig.cfgContainer.NT_SERVER &&
	       modConfigVar.bValueSet && !modConfigVar.bUnsupported;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the value the specified variable input component.
 *  $PARAM        varInput  The input component of the variable whose value is to be saved.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function saveValue(NMCVarInput varInput) {
	local NMCModConfigVar mcVar; 
	
	mcVar = varInput.modConfigVar;
	
	xClient.sendStr(mcVar.modConfig.cfgContainer.CMD_SET_VAL
		            @ class'NexgenUtil'.static.formatCmdArg(mcVar.modConfig.modID)
		            @ class'NexgenUtil'.static.formatCmdArg(mcVar.modConfig.cfgContainer.netType2Str(mcVar.netType))
		            @ class'NexgenUtil'.static.formatCmdArg(mcVar.className)
		            @ class'NexgenUtil'.static.formatCmdArg(mcVar.varName)
		            @ class'NexgenUtil'.static.formatCmdArg(varInput.getValue()));
}