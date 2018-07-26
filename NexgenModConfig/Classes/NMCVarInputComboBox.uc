/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCVarInputComboBox
 *  $VERSION      1.00 (17-02-2010 23:39)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Combo box input component for mod configuration variables.
 *
 **************************************************************************************************/
class NMCVarInputComboBox extends NMCVarInput;

var UWindowComboControl comboBox;       // The combo box input component.

var bool bHasCustomValueOption;         // Whether a custom option is available in the drop down input.
var string customValue;                 // The value of the custom option.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the layout for this panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	createPanelRootRegion();
	comboBox = addListCombo();
	loadEnumValues();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the enumeration values stored in the variable definition object.
 *
 **************************************************************************************************/
function loadEnumValues() {
	local int index;
	local string key;
	local string value;
	local string description;
	
	for (index = 0; index < modConfigVar.enumData.getEnumCount(); index++) {
		description = modConfigVar.enumData.getEnumDescription(index);
		if (description == "") {
			description = modConfigVar.enumData.getEnumValue(index);
		}
		comboBox.addItem(description);
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the current value of the input component.
 *  $PARAM        value  The value that is to be set for the input component.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setValue(string value) {
	local int index;
	local int enumCount;
	local bool bItemFound;

	// Preformat value.
	value = class'NexgenUtil'.static.trim(value);
	
	// Check if value matches the custom value.
	if (bHasCustomValueOption && value ~= customValue) {
		index = 0;
		bItemFound = true;
	}
	
	// Check if one of the enumeration values matches.
	if (!bItemFound) {
		// Find item.
		enumCount = modConfigVar.enumData.getEnumCount();
		index = 0;
		while (!bItemFound && index < enumCount) {
			if (modConfigVar.enumData.getEnumValue(index) ~= value) {
				bItemFound = true;
			} else {
				index++;
			}
		}
		
		// Remove custom option.
		if (bItemFound && bHasCustomValueOption) {
			comboBox.removeItem(0);
			bHasCustomValueOption = false;
		}
	}
	
	// Create custom option.
	if (!bItemFound) {
		if (bHasCustomValueOption) {
			comboBox.removeItem(0);
			comboBox.insertItem(value);
		} else {
			comboBox.insertItem(value);
		}
		index = 0;
		bHasCustomValueOption = true;
		customValue = value;
	}
	
	// Select value.
	comboBox.setSelectedIndex(index);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the current value of the input component.
 *  $RETURN       The value currently being displayed by the input component.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getValue() {
	local int index;
	
	// Check if custom option has been selected.
	index = comboBox.getSelectedIndex();
	if (bHasCustomValueOption && index == 0) {
		// Yes, return custom value.
		return customValue;
	} else {
		// No, return stored enumeration value.
		if (bHasCustomValueOption) {
			index--;
		}
		return modConfigVar.enumData.getEnumValue(index);
	}
	
}