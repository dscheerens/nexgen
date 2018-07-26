/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigPanelClient
 *  $VERSION      1.01 (19-02-2010 21:17)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen control panel for editing mod client side configurations.
 *
 **************************************************************************************************/
class NMCModConfigPanelClient extends NMCModConfigPanel;



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
	return modConfigVar.netType == modConfig.cfgContainer.NT_CLIENT &&
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
	varInput.modConfigVar.setValue(varInput.getValue());
	varInput.modConfigVar.storeValue();
}