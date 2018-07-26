/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCDeferredUpdateHandler
 *  $VERSION      1.01 (21-02-2010 18:49)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Mod configuration variable update handler. This update handler is used to enable
 *                deferred updates of variables.
 *
 **************************************************************************************************/
 class NMCDeferredUpdateHandler extends Info config(system);

var NMCModConfigContainer cfgContainer; // The mod configuration container.

var config int numUpdates;              // The number of updates that are to be applied.
var config string updates[100];         // The updates that are to be applied.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds an update by using the current value of the specified mod configuration
 *                variable.
 *  $PARAM        modConfigVar  The variable for which the update is to be created.
 *  $REQUIRE      modConfigVar != none
 *  $RETURN       True if the update was successfully created, false if not.
 *
 **************************************************************************************************/
function bool addUpdateFromVar(NMCModConfigVar modConfigVar) {
	return addUpdate(modConfigVar.className,
	                 modConfigVar.varName,
	                 modConfigVar.serialValue);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified update to the update list.
 *  $PARAM        className     Class which contains the property to be updated.
 *  $PARAM        propertyName  The property for which the update is to be created.
 *  $PARAM        value         New value of the property
 *  $REQUIRE      className != "" && propertyName != ""
 *  $RETURN       True if the update was successfully created, false if not.
 *
 **************************************************************************************************/
function bool addUpdate(string className, string propertyName, string value) {
	local int index;
	
	// Get index of update.
	index = getUpdateIndex(className, propertyName);
	if (index < 0 && numUpdates < arrayCount(updates)) {
		index = numUpdates++;
	}
	
	// Store update.
	if (index >= 0) {
		updates[index] = class'NexgenUtil'.static.formatCmdArg(className)
		               @ class'NexgenUtil'.static.formatCmdArg(propertyName)
		               @ class'NexgenUtil'.static.formatCmdArg(value);
		saveConfig();
		return true;
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the index of the update for the specified property.
 *  $PARAM        className     Class which contains the property.
 *  $PARAM        propertyName  The property whose index is to be retrieved.
 *  $REQUIRE      className != "" && propertyName != ""
 *  $RETURN       The index of the specified property in the deferred update list or -1 if the
 *                update could not be found.
 *
 **************************************************************************************************/
function int getUpdateIndex(string className, string propertyName) {
	local bool bFound;
	local int index;
	local string cmd;
	local string args[10];
	local bool bParseOk;
	
	// Locate update.
	while (!bFound && index < numUpdates) {
		args[0] = ""; args[1] = "";
		bParseOk = class'NexgenUtil'.static.parseCommandStr("NSC" @ "SET" @ updates[index], cmd, args);
		if (bParseOk && args[0] ~= className && args[1] ~= propertyName) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Return result.
	if (bFound) {
		return index;
	} else {
		return -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Applies the deferred updates that are stored in the update handler.
 *
 **************************************************************************************************/
function applyUpdates() {
	local int index;
	local string cmd;
	local string args[10];
	
	// Apply updates.
	for (index = 0; index < numUpdates; index++) {
		if (class'NexgenUtil'.static.parseCommandStr("NSC" @ "SET" @ updates[index], cmd, args)) {
			cfgContainer.setProperty(args[0], args[1], args[2]);
		}
		updates[index] = "";
	}
	
	// Clear deferred update list.
	numUpdates = 0;
	saveConfig();
}