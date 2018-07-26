/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigPanel
 *  $VERSION      1.02 (19-02-2010 18:07)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen control panel for editing mod configurations.
 *
 **************************************************************************************************/
class NMCModConfigPanel extends NexgenPanel abstract;

var NMCClient xClient;                  // Client controller.

var UWindowSmallButton resetButton;     // Button for resetting the values.
var UWindowSmallButton saveButton;      // Button for saving the values.
var NMCVarInput inputList;              // The input list for the mod variables.

var NMCModConfig modConfig;             // The mod configuration definition for this panel.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the layout for this panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local NMCModConfigVar modConfigVar;
	local int varCount;
	local int index;
	local int region;
	local NMCVarInput varInput;
	local NMCVarInput lastVarInput;
	
	// Check if mod configuration definition is available.
	if (modConfig == none) {
		return;
	}
	
	// Get client controller.
	xClient = NMCClient(client.getController(class'NMCClient'.default.ctrlID));
	
	// Count number of variables that will be displayed.
	for (modConfigVar = modConfig.varList; modConfigVar != none; modConfigVar = modConfigVar.nextVar) {
		if (supportsVariable(modConfigVar)) {
			varCount++;
		}
	}
	
	// Create layout & add components.
	if (varCount == 0) {
		setHeight(16 + 2 * defaultComponentDist + 14 + 2 * borderSize);
	} else {
		setHeight(varCount * 18 + 3 * defaultComponentDist + 14 + 20 + 2 * borderSize);
	}
	createPanelRootRegion();
	splitRegionH(12, defaultComponentDist);
	addLabel(modConfig.title, true, TA_Center);

	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');
	
	// Create save & reset buttons.
	if (varCount > 0) {
		splitRegionH(20, defaultComponentDist, , true);
		region = currRegion;
		skipRegion();
		splitRegionV(65, , true); //splitRegionV(196, , , true);
		skipRegion();
		divideRegionV(2, defaultComponentDist);
		saveButton = addButton(client.lng.saveTxt);
		resetButton = addButton(client.lng.resetTxt);
		selectRegion(region);
	}
	
	// Add variables.
	if (varCount == 0) {
		addLabel("There are no settings for this mod.", false, TA_Left);
	} else {
		selectRegion(divideRegionH(varCount));
		for (index = 0; index < varCount; index++) {
			splitRegionV(65, , true);
		}
		for (modConfigVar = modConfig.varList; modConfigVar != none; modConfigVar = modConfigVar.nextVar) {
			if (supportsVariable(modConfigVar)) {
				// Create components.
				addLabel(modConfigVar.description, true, TA_Left);
				varInput = createVarInput(modConfigVar);
				
				// Store input component.
				if (inputList == none) {
					inputList = varInput;
				}
				if (lastVarInput != none) {
					lastVarInput.nextVarInput = varInput;
				}
				lastVarInput = varInput;
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the input component for the specified variable.
 *  $PARAM        modConfigVar  The variable for which the input component is to be created.
 *  $REQUIRE      modConfigVar  != none
 *
 **************************************************************************************************/
function NMCVarInput createVarInput(NMCModConfigVar modConfigVar) {
	local class<NMCVarInput> varInputClass;
	local NMCVarInput varInput;
	
	// Determine class type.
	switch (modConfigVar.inputType) {
		case modConfigVar.modConfig.cfgContainer.IT_CHECKBOX: varInputClass = class'NMCVarInputCheckBox'; break;
		case modConfigVar.modConfig.cfgContainer.IT_EDITBOX:  varInputClass = class'NMCVarInputEditBox'; break;
		case modConfigVar.modConfig.cfgContainer.IT_DROPDOWN: varInputClass = class'NMCVarInputComboBox'; break;
		default:                                              varInputClass = class'NMCVarInputEditBox';
	}
	
	// Create component
	varInput = NMCVarInput(addComponent(varInputClass));
	varInput.modConfigVar = modConfigVar;
	varInput.setContent();
	varInput.setValue(modConfigVar.serialValue);
	
	// Return variable input component.
	return varInput;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adjusts the height of the panel. Note that calling this function will not update
 *                the layout of the panel itself. Therefore it has to be called before any
 *                components are added to the panel.
 *  $PARAM        newHeight  The new height of the panel
 *  $REQUIRE      newHeight > 0
 *
 **************************************************************************************************/
function setHeight(float newHeight) {
	winHeight = newHeight;
	panelHeight = newHeight;
	if (parentWindow != none && NexgenScrollPanelContainer(parentWindow.parentWindow) != none) {
		NexgenScrollPanelContainer(parentWindow.parentWindow).updateClientArea();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified mod configuration variable is supported by this
 *                panel. Variables that are supported are displayed on the panel and can be edited.
 *  $PARAM        modConfigVar  The mod configuration variable that is to be tested.
 *  $REQUIRE      modConfigVar != none
 *  $RETURN       True if the variable is supported, false if not.
 *
 **************************************************************************************************/
function bool supportsVariable(NMCModConfigVar modConfigVar);



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType) {
	super.notify(control, eventType);
	
	// Button pressed?
	if (control != none && eventType == DE_Click && control.isA('UWindowSmallButton') &&
	    !UWindowSmallButton(control).bDisabled) {
	
		switch (control) {
			case resetButton: resetValues(); break;
			case saveButton: saveValues(); break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Resets the values of all the mod variable input components to the last saved
 *                value of the mod configuration variable object.
 *
 **************************************************************************************************/
function resetValues() {
	local NMCVarInput varInput;
	
	for (varInput = inputList; varInput != none; varInput = varInput.nextVarInput) {
		varInput.resetValue();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the current value being displayed on the GUI input component for the
 *                specified mod configuration variable.
 *  $PARAM        modConfigVar  The mod configuration variable whose input component is to be updated.
 *  $REQUIRE      modConfigVar != none
 *
 **************************************************************************************************/
function updateVar(NMCModConfigVar modConfigVar) {
	local NMCVarInput varInput;
	
	for (varInput = inputList; varInput != none; varInput = varInput.nextVarInput) {
		if (varInput.modConfigVar == modConfigVar) {
			varInput.resetValue();
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the values of the variables that are modified.
 *
 **************************************************************************************************/
function saveValues() {
	local NMCVarInput varInput;
	
	for (varInput = inputList; varInput != none; varInput = varInput.nextVarInput) {
		varInput.validateValue();
		if (varInput.isChanged()) {
			saveValue(varInput);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the value the specified variable input component.
 *  $PARAM        varInput  The input component of the variable whose value is to be saved.
 *
 **************************************************************************************************/
function saveValue(NMCVarInput varInput);