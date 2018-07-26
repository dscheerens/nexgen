/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCVarInput
 *  $VERSION      1.01 (19-02-2010 18:11)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Abstract class for input components that allow the user to edit the value of a
 *                variable in a mod configuration.
 *
 **************************************************************************************************/
class NMCVarInput extends NexgenPanel abstract;

var NMCModConfigVar modConfigVar;       // The mod configuration variable being edited.
var NMCVarInput nextVarInput;           // The next variable input component.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the current value of the input component.
 *  $PARAM        value  The value that is to be set for the input component.
 *
 **************************************************************************************************/
function setValue(string value);



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the current value of the input component.
 *  $RETURN       The value currently being displayed by the input component.
 *
 **************************************************************************************************/
function string getValue();



/***************************************************************************************************
 *
 *  $DESCRIPTION  Resets the value of the input component to the current value of the mod
 *                configuration variable.
 *
 **************************************************************************************************/
function resetValue() {
	setValue(modConfigVar.serialValue);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically validates the current value if the input component.
 *
 **************************************************************************************************/
function validateValue() {
	local string value;
	local string validatedValue;
	
	value = getValue();
	validatedValue = modConfigVar.validateValue(value);
	
	if (value != validatedValue) {
		setValue(validatedValue);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the value of the variable is changed.
 *  $RETURN       True if the value is changed, false if not.
 *
 **************************************************************************************************/
function bool isChanged() {
	return modConfigVar.serialValue != modConfigVar.validateValue(getValue());
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the root region to the content panel. This region occupies the whole surface
 *                of this content panel. Use this function instead of createRootRegion() if the
 *                panel is added as a component on another panel.
 *  $REQUIRE      regionCount == 0
 *  $ENSURE       new.regionCount = old.regionCount + 1
 *  $OVERRIDE
 *
 **************************************************************************************************/
function createPanelRootRegion() {
	currRegion = addRegion(0, 0, winWidth, winHeight);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelBGType=PBT_Transparent
}