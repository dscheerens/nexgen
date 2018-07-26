/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCVarInputEditBox
 *  $VERSION      1.00 (17-02-2010 23:39)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Edit box input component for mod configuration variables.
 *
 **************************************************************************************************/
class NMCVarInputEditBox extends NMCVarInput;

var UWindowEditControl editBox;         // The edit box input component.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the layout for this panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	createPanelRootRegion();
	editBox = addEditBox();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the current value of the input component.
 *  $PARAM        value  The value that is to be set for the input component.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setValue(string value) {
	editBox.setValue(value);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the current value of the input component.
 *  $RETURN       The value currently being displayed by the input component.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getValue() {
	return editBox.getValue();
}