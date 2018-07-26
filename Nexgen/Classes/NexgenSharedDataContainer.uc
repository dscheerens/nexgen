/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenSharedDataContainer
 *  $VERSION      1.04 (14-05-2010 16:23)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Container class for variables that are shared between the server and client and
 *                which should be kept in sync.
 *
 **************************************************************************************************/
class NexgenSharedDataContainer extends Info abstract;

var NexgenSharedDataSyncManager dataSyncMgr;      // Manager for the shared data in this container.
var NexgenExtendedPlugin xControl;                // The plugin server controller (server side).

var string containerID;                           // Identifier of the data container.

// Variable data types.
const DT_BOOL = 1;                                // Boolean data type.
const DT_BYTE = 2;                                // Byte data type.
const DT_INT = 3;                                 // Integer data type.
const DT_FLOAT = 4;                               // Float data type.
const DT_STRING = 5;                              // String data type.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the initial shared data setup commands to the specified client.
 *  $PARAM        xClient  The client controller which should be setup.
 *  $REQUIRE      xClient != none
 *
 **************************************************************************************************/
function initRemoteClient(NexgenExtendedClientController xClient) {
	local int varIndex;
	local int varCount;
	local string currentVar;
	local byte currentVarType;
	local string currentVarValue;
	local int varArrayIndex;
	local int varArrayCount;
	
	// Send container initialization command.
	xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_INIT_CONTAINER
	                @ class'NexgenUtil'.static.formatCmdArg(self.class));

	// Send variable initialization commands.
	varCount = getVarCount();
	for (varIndex = 0; varIndex < varCount; varIndex++) {
		// Retrieve variable information.
		currentVar = getVarName(varIndex);
		currentVarType = getVarType(currentVar);
		
		// Check if the variable is an array.
		if (isArray(currentVar)) {
			// Variable is array, send whole array contents.
			varArrayCount = getArraySize(currentVar);
			for (varArrayIndex = 0; varArrayIndex < varArrayCount; varArrayIndex++) {
				currentVarValue = getString(currentVar, varArrayIndex);
				if (!isTypeDefaultValue(currentVarType, currentVarValue)) {
					xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_INIT_VAR
					                @ class'NexgenUtil'.static.formatCmdArg(currentVar)
					                @ varArrayIndex
					                @ class'NexgenUtil'.static.formatCmdArg(currentVarValue));
				}
			}
		} else {
			// Variable contains a single value, send it.
			currentVarValue = getString(currentVar);
			if (!isTypeDefaultValue(currentVarType, currentVarValue)) {
				xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_INIT_VAR
				                @ class'NexgenUtil'.static.formatCmdArg(currentVar)
				                @ class'NexgenUtil'.static.formatCmdArg(currentVarValue));
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the given value is the default value of the specified data type.
 *  $PARAM        dataType  The data type for which the value is to be checked.
 *  $PARAM        value     Value which is to be checked.
 *
 **************************************************************************************************/
function bool isTypeDefaultValue(byte dataType, string value) {
	switch (dataType) {
		case DT_BOOL:   return value ~= "False";
		case DT_BYTE:   return value == "0";
		case DT_INT:    return value == "0";
		case DT_FLOAT:  return value == string(0.0);
		case DT_STRING: return value ~= "";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the data for this shared data container.
 *
 **************************************************************************************************/
function loadData() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the data store in this shared data container.
 *
 **************************************************************************************************/
function saveData() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be changed.
 *  $PARAM        value    New value for the variable.
 *  $PARAM        index    Array index in case the variable is an array.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *
 **************************************************************************************************/
function set(string varName, coerce string value, optional int index) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to read the variable value.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $PARAM        varName  Name of the variable whose access is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable may be read by the specified client, false if not.
 *
 **************************************************************************************************/
function bool mayRead(NexgenExtendedClientController xClient, string varName) {
	// To implement in subclass.
	return false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to change the variable value.
    $PARAM        xClient  The controller of the client that is to be checked.
 *  $PARAM        varName  Name of the variable whose access is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable may be changed by the specified client, false if not.
 *
 **************************************************************************************************/
function bool mayWrite(NexgenExtendedClientController xClient, string varName) {
	// To implement in subclass.
	return false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to save the data in this container.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $REQUIRE      xClient != none
 *  $RETURN       True if the data may be saved by the specified client, false if not.
 *
 **************************************************************************************************/
function bool maySaveData(NexgenExtendedClientController xClient) {
	// To implement in subclass.
	return false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified variable is an array.
 *  $PARAM        varName  Name of the variable which is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable is an array, false if not.
 *
 **************************************************************************************************/
function bool isArray(string varName) {
	// To implement in subclass.
	return false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the array length of the specified variable.
 *  $PARAM        varName  Name of the variable which is to be checked.
 *  $REQUIRE      varName != "" && isArray(varName)
 *  $RETURN       The size of the array.
 *
 **************************************************************************************************/
function int getArraySize(string varName) {
	// To implement in subclass.
	return 0;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the boolean value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The boolean value of the specified variable.
 *
 **************************************************************************************************/
function bool getBool(string varName, optional int index) {
	// To implement in subclass.
	return false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the byte value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The byte value of the specified variable.
 *
 **************************************************************************************************/
function byte getByte(string varName, optional int index) {
	// To implement in subclass.
	return 0;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the integer value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The integer value of the specified variable.
 *
 **************************************************************************************************/
function int getInt(string varName, optional int index) {
	// To implement in subclass.
	return 0;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the float value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The float value of the specified variable.
 *
 **************************************************************************************************/
function float getFloat(string varName, optional int index) {
	// To implement in subclass.
	return 0.0;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the string value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The string value of the specified variable.
 *
 **************************************************************************************************/
function string getString(string varName, optional int index) {
	// To implement in subclass.
	return "";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the number of variables that are stored in the container.
 *  $RETURN       The number of variables stored in the shared data container. 
 *
 **************************************************************************************************/
function int getVarCount() {
	// To implement in subclass.
	return 0;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the variable name of the variable at the specified index.
 *  $PARAM        varIndex  Index of the variable whose name is to be retrieved.
 *  $REQUIRE      0 <= varIndex && varIndex <= getVarCount()
 *  $RETURN       The name of the specified variable.
 *
 **************************************************************************************************/
function string getVarName(int varIndex) {
	// To implement in subclass.
	return "";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the data type of the specified variable.
 *  $PARAM        varName  Name of the variable whose data type is to be retrieved.
 *  $REQUIRE      varName != ""
 *  $RETURN       The data type of the specified variable.
 *
 **************************************************************************************************/
function byte getVarType(string varName) {
	// To implement in subclass.
	return 0;
}