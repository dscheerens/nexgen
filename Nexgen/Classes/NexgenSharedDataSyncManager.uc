/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenSharedDataSyncManager
 *  $VERSION      1.10 (01-08-2010 12:02)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Shared data synchronization manager.
 *
 **************************************************************************************************/
class NexgenSharedDataSyncManager extends Info;

var NexgenExtendedPlugin xControl;                // The plugin server controller (server side).
var NexgenExtendedClientController xClient;       // The local client controller (client side).
var NexgenSharedDataContainer dataContainers[16]; // List of data containers that are to be managed.
var NexgenSharedDataContainer cachedContainer;    // Last container retrieved via getContainer().
var int numDataContainers;                        // Number of active data containers.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a new shared data container that will be managed by this object.
 *  $PARAM        dataContainerClass  The class of the shared data container that should be created.
 *  $REQUIRE      dataContainerClass != none
 *  $RETURN       The data container that was added or null if the container could not be created.
 *
 **************************************************************************************************/
function NexgenSharedDataContainer addDataContainer(class<NexgenSharedDataContainer> dataContainerClass) {
	local NexgenSharedDataContainer dataContainer;
	
	// Check if the list of data containers is not full.
	if (numDataContainers < arrayCount(dataContainers)) {
		// Create data container.
		dataContainer = spawn(dataContainerClass);
		dataContainer.dataSyncMgr = self;
		dataContainer.xControl = xControl;
		
		// Add data container to list.
		dataContainers[numDataContainers++] = dataContainer;
	}
	
	// Return created data container.
	return dataContainer;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the initial shared data setup commands to the specified client.
 *  $PARAM        xClient  The client controller which should be setup.
 *  $REQUIRE      xClient != none
 *
 **************************************************************************************************/
function initRemoteClient(NexgenExtendedClientController xClient) {
	local int index;
	
	for (index = 0; index < numDataContainers; index++) {
		if (dataContainers[index] != none) {
			dataContainers[index].initRemoteClient(xClient);
		}
	}
	
	xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_INIT_COMPLETE);
	xClient.bInitialSyncComplete = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the data for all shared data containers stored in the manager.
 *
 **************************************************************************************************/
function loadSharedData() {
	local int index;
	
	for (index = 0; index < numDataContainers; index++) {
		if (dataContainers[index] != none) {
			dataContainers[index].loadData();
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the data stored in the shared data container with the specified id.
 *  $PARAM        dataContainerID  ID of the container whose data is to be saved.
 *  $REQUIRE      dataContainerID != none
 *
 **************************************************************************************************/
function saveSharedData(string dataContainerID) {
	local NexgenSharedDataContainer container;
	
	container = getDataContainer(dataContainerID);
	
	if (container != none) {
		container.saveData();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the data container with the specified identifier.
 *  $PARAM        dataContainerID  The identifier of the data container that is to be retrieved.
 *  $REQUIRE      dataContainerID != ""
 *  $RETURN       The data container with the specified identifier or none if the container could
 *                not be found.
 *  $ENSURE       imply(result != none, result.containerID ~= dataContainerID)
 *
 **************************************************************************************************/
function NexgenSharedDataContainer getDataContainer(string dataContainerID) {
	local int index;
	
	// Check cache to speed up retrieval.
	if (cachedContainer != none && cachedContainer.containerID ~= dataContainerID) {
		return cachedContainer;
	}
	
	// Find data container
	for (index = 0; index < numDataContainers; index++) {
		if (dataContainers[index].containerID ~= dataContainerID) {
			cachedContainer = dataContainers[index];
			return cachedContainer;
		}
	}
	
	// No data container with the specified ID was found.
	return none;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the value of the specified variable.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose value is to be changed.
 *  $PARAM        value            New value for the variable.
 *  $PARAM        index            Array index in case the variable is an array.
 *  $PARAM        author           Object that was responsible for the change.
 *  $REQUIRE      dataContainerID != "" && varName != "" &&
 *                imply(isArray(dataContainerID, varName),
 *                  0 <= index && index <= getArraySize(dataContainerID, varName))
 *
 **************************************************************************************************/
function set(string dataContainerID, string varName, coerce string value, optional int index, optional Object author) {
	local NexgenSharedDataContainer dataContainer;
	local NexgenClient client;
	local NexgenExtendedClientController xClient;
	local string oldValue;
	local string newValue;
	
	// Get the data container.
	dataContainer = getDataContainer(dataContainerID);
	if (dataContainer == none) return;
	
	// Check if we are on the server or client side.
	if (xControl != none) {
		// Server side, update variable.
		oldValue = dataContainer.getString(varName, index);
		dataContainer.set(varName, value, index);
		newValue = dataContainer.getString(varName, index);
		
		// Notify clients if variable has changed.
		if (newValue != oldValue) {
			for (client = xControl.control.clientList; client != none; client = client.nextClient) {
				xClient = xControl.getXClient(client);
				if (xClient != none && xClient.bInitialSyncComplete && dataContainer.mayRead(xClient, varName)) {
					if (dataContainer.isArray(varName)) {
						xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_UPDATE_VAR
						                @ class'NexgenUtil'.static.formatCmdArg(dataContainerID)
						                @ class'NexgenUtil'.static.formatCmdArg(varName)
						                @ index
						                @ class'NexgenUtil'.static.formatCmdArg(newValue));
					} else {
						xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_UPDATE_VAR
						                @ class'NexgenUtil'.static.formatCmdArg(dataContainerID)
						                @ class'NexgenUtil'.static.formatCmdArg(varName)
						                @ class'NexgenUtil'.static.formatCmdArg(newValue));
					}
				}
			}
		}
		
		// Also notify the server side controller of this event.
		if (newValue != oldValue) {
			xControl.varChanged(dataContainer, varName, index, author);
		}
		
	} else {
		// Client side, set simply set value.
		dataContainer.set(varName, value, index);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to read the variable value.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose access is to be checked.
 *  $REQUIRE      xClient != none && dataContainerID != "" && varName != ""
 *  $RETURN       True if the variable may be read by the specified client, false if not.
 *
 **************************************************************************************************/
function bool mayRead(NexgenExtendedClientController xClient, string dataContainerID, string varName) {
	return getDataContainer(dataContainerID).mayRead(xClient, varName);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to change the variable value.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose access is to be checked.
 *  $REQUIRE      xClient != none && dataContainerID != "" && varName != ""
 *  $RETURN       True if the variable may be changed by the specified client, false if not.
 *
 **************************************************************************************************/
function bool mayWrite(NexgenExtendedClientController xClient, string dataContainerID, string varName) {
	return getDataContainer(dataContainerID).mayWrite(xClient, varName);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to save the data in this container.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $REQUIRE      xClient != none && dataContainerID != ""
 *  $RETURN       True if the data may be saved by the specified client, false if not.
 *
 **************************************************************************************************/
function bool maySaveData(NexgenExtendedClientController xClient, string dataContainerID) {
	return getDataContainer(dataContainerID).maySaveData(xClient);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified variable is an array.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable which is to be checked.
 *  $REQUIRE      dataContainerID != "" && varName != ""
 *  $RETURN       True if the variable is an array, false if not.
 *
 **************************************************************************************************/
function bool isArray(string dataContainerID, string varName) {
	return getDataContainer(dataContainerID).isArray(varName);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the array length of the specified variable.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable which is to be checked.
 *  $REQUIRE      dataContainerID != "" && varName != "" && isArray(dataContainerID, varName)
 *  $RETURN       The size of the array.
 *
 **************************************************************************************************/
function int getArraySize(string dataContainerID, string varName) {
	return getDataContainer(dataContainerID).getArraySize(varName);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the boolean value of the specified variable.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose value is to be retrieved.
 *  $PARAM        index            Index of the element in the array that is to be retrieved.
 *  $REQUIRE      dataContainerID != "" && varName != "" &&
 *                imply(isArray(dataContainerID, varName),
 *                  0 <= index && index <= getArraySize(dataContainerID, varName))
 *  $RETURN       The boolean value of the specified variable.
 *
 **************************************************************************************************/
function bool getBool(string dataContainerID, string varName, optional int index) {
	return getDataContainer(dataContainerID).getBool(varName, index);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the byte value of the specified variable.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose value is to be retrieved.
 *  $PARAM        index            Index of the element in the array that is to be retrieved.
 *  $REQUIRE      dataContainerID != "" && varName != "" &&
 *                imply(isArray(dataContainerID, varName),
 *                  0 <= index && index <= getArraySize(dataContainerID, varName))
 *  $RETURN       The byte value of the specified variable.
 *
 **************************************************************************************************/
function byte getByte(string dataContainerID, string varName, optional int index) {
	return getDataContainer(dataContainerID).getByte(varName, index);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the integer value of the specified variable.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose value is to be retrieved.
 *  $PARAM        index            Index of the element in the array that is to be retrieved.
 *  $REQUIRE      dataContainerID != "" && varName != "" &&
 *                imply(isArray(dataContainerID, varName),
 *                  0 <= index && index <= getArraySize(dataContainerID, varName))
 *  $RETURN       The integer value of the specified variable.
 *
 **************************************************************************************************/
function int getInt(string dataContainerID, string varName, optional int index) {
	return getDataContainer(dataContainerID).getInt(varName, index);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the float value of the specified variable.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose value is to be retrieved.
 *  $PARAM        index            Index of the element in the array that is to be retrieved.
 *  $REQUIRE      dataContainerID != "" && varName != "" &&
 *                imply(isArray(dataContainerID, varName),
 *                  0 <= index && index <= getArraySize(dataContainerID, varName))
 *  $RETURN       The float value of the specified variable.
 *
 **************************************************************************************************/
function float getFloat(string dataContainerID, string varName, optional int index) {
	return getDataContainer(dataContainerID).getFloat(varName, index);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the string value of the specified variable.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose value is to be retrieved.
 *  $PARAM        index            Index of the element in the array that is to be retrieved.
 *  $REQUIRE      dataContainerID != "" && varName != "" &&
 *                imply(isArray(dataContainerID, varName),
 *                  0 <= index && index <= getArraySize(dataContainerID, varName))
 *  $RETURN       The string value of the specified variable.
 *
 **************************************************************************************************/
function string getString(string dataContainerID, string varName, optional int index) {
	return getDataContainer(dataContainerID).getString(varName, index);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the number of variables that are stored in the specified container.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variables.
 *  $REQUIRE      dataContainerID != ""
 *  $RETURN       The number of variables stored in the shared data container. 
 *
 **************************************************************************************************/
function int getVarCount(string dataContainerID) {
	return getDataContainer(dataContainerID).getVarCount();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the variable name of the variable at the specified index in the target
 *                shared data container.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variables.
 *  $PARAM        varIndex         Index of the variable whose name is to be retrieved.
 *  $REQUIRE      dataContainerID != "" && 0 <= varIndex && varIndex <= getVarCount(dataContainerID)
 *  $RETURN       The name of the specified variable.
 *
 **************************************************************************************************/
function string getVarName(string dataContainerID, int varIndex) {
	return getDataContainer(dataContainerID).getVarName(varIndex);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the data type of the specified variable.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose data type is to be retrieved.
 *  $REQUIRE      dataContainerID != "" && varName != ""
 *  $RETURN       The data type of the specified variable.
 *
 **************************************************************************************************/
function byte getVarType(string dataContainerID, string varName) {
	return getDataContainer(dataContainerID).getVarType(varName);
}
