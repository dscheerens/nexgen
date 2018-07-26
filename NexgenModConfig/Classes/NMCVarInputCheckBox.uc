/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCVarInputCheckBox
 *  $VERSION      1.00 (17-02-2010 23:39)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Check box input component for mod configuration variables.
 *
 **************************************************************************************************/
class NMCVarInputCheckBox extends NMCVarInput;

var UWindowCheckbox checkBox;           // The check box input component.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the layout for this panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	createPanelRootRegion();
	checkBox = addCheckBox(TA_Right);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the current value of the input component.
 *  $PARAM        value  The value that is to be set for the input component.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setValue(string value) {
	checkBox.bChecked = str2bool(value);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the current value of the input component.
 *  $RETURN       The value currently being displayed by the input component.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getValue() {
	return string(checkBox.bChecked);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically validates the current value if the input component.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function validateValue() {
	// No validation is necessary for this input component.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Converts the specified string to a boolean value.
 *  $PARAM        str  The string that is to be converted.
 *  $RETURN       The boolean value of the given string.
 *
 **************************************************************************************************/
function bool str2bool(string str) {
	str = class'NexgenUtil'.static.trim(str);
	
	return !(str == "" ||
	         str ~= "false" ||
	         str == "0" ||
	         str == string(0.0));
}