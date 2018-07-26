/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenExtendedClientController
 *  $VERSION      1.08 (01-08-2010 13:10)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen client controller with extended features.
 *
 **************************************************************************************************/
class NexgenExtendedClientController extends NexgenNetClientController;

var NexgenExtendedPlugin xControl;                // The plugin server controller.
var NexgenSharedDataSyncManager dataSyncMgr;      // Manager for the shared server variables.
var NexgenSharedDataContainer dataContainer;      // Currently selected data container.
var bool bInitialSyncComplete;                    // Whether the initial data synchronization was completed.

// Shared data synchronization commands.
const CMD_SYNC_PREFIX = "DSYNC";                  // Common synchronization command prefix.
const CMD_INIT_CONTAINER = "IC";                  // Initialize data container command.
const CMD_INIT_VAR = "IV";                        // Initialize variable command.
const CMD_INIT_COMPLETE = "ID";                   // Command that indicates initialization is complete.
const CMD_UPDATE_VAR = "SV";                      // Command to update the value of a variable.
const CMD_SAVE_DATA = "SD";                       // Save shared data command.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the NexgenClient has received its initial replication info is has
 *                been initialized. At this point it's safe to use all functions of the client.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function clientInitialized() {
	dataSyncMgr = spawn(class'NexgenSharedDataSyncManager');
	dataSyncMgr.xClient = self;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a string was received from the other machine.
 *  $PARAM        str  The string that was send by the other machine.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function recvStr(string str) {
	local string cmd;
	local string args[10];
	local int argCount;
	
	// Check controller role.
	if (role == ROLE_Authority) {
		// Commands accepted by server.
		if (class'NexgenUtil'.static.parseCmd(str, cmd, args, argCount, CMD_SYNC_PREFIX)) {
			switch (cmd) {
				case CMD_UPDATE_VAR:     exec_UPDATE_VAR(args, argCount); break;
				case CMD_SAVE_DATA:      exec_SAVE_DATA(args, argCount); break;
			}
		}
		
	} else {
		// Commands accepted by client.
		if (class'NexgenUtil'.static.parseCmd(str, cmd, args, argCount, CMD_SYNC_PREFIX)) {
			switch (cmd) {
				case CMD_INIT_CONTAINER: exec_INIT_CONTAINER(args, argCount); break;
				case CMD_INIT_VAR:       exec_INIT_VAR(args, argCount); break;
				case CMD_INIT_COMPLETE:  exec_INIT_COMPLETE(args, argCount); break;
				case CMD_UPDATE_VAR:     exec_UPDATE_VAR(args, argCount); break;
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a INIT_CONTAINER command.
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_INIT_CONTAINER(string args[10], int argCount) {
	local class<NexgenSharedDataContainer> dataContainerClass;
	local int index;
	
	// Check if current container has been initialized.
	if (dataContainer != none) {
		// Signal event to client controllers.
		for (index = 0; index < client.clientCtrlCount; index++) {
			if (NexgenExtendedClientController(client.clientCtrl[index]) != none) {
				NexgenExtendedClientController(client.clientCtrl[index]).dataContainerAvailable(dataContainer);
			}
		}
		
		// Signal event to GUI.
		client.mainWindow.mainPanel.dataContainerAvailable(dataContainer);
	}
	
	// Load class.
	dataContainerClass = class<NexgenSharedDataContainer>(dynamicLoadObject(args[0], class'Class'));
	
	// Create data container.
	dataContainer = dataSyncMgr.addDataContainer(dataContainerClass);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a INIT_VAR command.
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_INIT_VAR(string args[10], int argCount) {
	// Set value.
	if (argCount == 2) {
		dataContainer.set(args[0], args[1]);
	} else {
		dataContainer.set(args[0], args[2], int(args[1]));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a INIT_COMPLETE command.
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_INIT_COMPLETE(string args[10], int argCount) {
	local int index;
	
	// Check if current container has been initialized.
	if (dataContainer != none) {
		// Signal event to client controllers.
		for (index = 0; index < client.clientCtrlCount; index++) {
			if (NexgenExtendedClientController(client.clientCtrl[index]) != none) {
				NexgenExtendedClientController(client.clientCtrl[index]).dataContainerAvailable(dataContainer);
			}
		}
		
		// Signal event to GUI.
		client.mainWindow.mainPanel.dataContainerAvailable(dataContainer);
	}
	
	// The initial data synchronization of all containers in the sync manager has completed.
	bInitialSyncComplete = true;
	
	// Signal event to client controllers.
	for (index = 0; index < client.clientCtrlCount; index++) {
		if (NexgenExtendedClientController(client.clientCtrl[index]) != none) {
			NexgenExtendedClientController(client.clientCtrl[index]).sharedDataInitComplete(dataSyncMgr);
		}
	}
	
	// Signal event to GUI.
	client.mainWindow.mainPanel.sharedDataInitComplete(dataSyncMgr);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a UPDATE_VAR command.
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_UPDATE_VAR(string args[10], int argCount) {
	local int varIndex;
	local string varName;
	local string varValue;
	local NexgenSharedDataContainer container;
	local int index;
	
	// Get arguments.
	if (argCount == 3) {
		varName = args[1];
		varValue = args[2];
	} else if (argCount == 4) {
		varName = args[1];
		varIndex = int(args[2]);
		varValue = args[3];
	} else {
		return;
	}
	
	// Set variable value.
	dataSyncMgr.set(args[0], varName, varValue, varIndex, self);
	
	// Notify client that the value has changed.
	if (role != ROLE_Authority) {
		container = dataSyncMgr.getDataContainer(args[0]);
		
		// Signal event to client controllers.
		for (index = 0; index < client.clientCtrlCount; index++) {
			if (NexgenExtendedClientController(client.clientCtrl[index]) != none) {
				NexgenExtendedClientController(client.clientCtrl[index]).varChanged(container, varName, varIndex);
			}
		}
		
		// Signal event to GUI.
		client.mainWindow.mainPanel.varChanged(container, varName, varIndex);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a SAVE_DATA command.
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
function exec_SAVE_DATA(string args[10], int argCount) {
	// Check arguments.
	if (argCount != 1) {
		return;
	}
	
	// Check if client is allowed to save the data.
	if (!dataSyncMgr.maySaveData(self, args[0])) {
		return;
	}
	
	// Save data.
	dataSyncMgr.saveSharedData(args[0]);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the value of the specified variable.
 *  $PARAM        dataContainerID  Identifier of the data container that contains the variable.
 *  $PARAM        varName          Name of the variable whose value is to be changed.
 *  $PARAM        value            New value for the variable.
 *  $PARAM        index            Array index in case the variable is an array.
 *  $REQUIRE      dataContainerID != "" && varName != ""
 *
 **************************************************************************************************/
simulated function setVar(string dataContainerID, string varName, coerce string value, optional int index) {
	local NexgenSharedDataContainer dataContainer;
	local string oldValue;
	local string newValue;
	
	// Get data container.
	dataContainer = dataSyncMgr.getDataContainer(dataContainerID);
	
	// Check if variable can be updated.
	if (dataContainer == none || !dataContainer.mayWrite(self, varName)) return;
	
	// Update variable value.
	oldValue = dataContainer.getString(varName, index);
	dataContainer.set(varName, value, index);
	newValue = dataContainer.getString(varName, index);
	
	// Send new value to server.
	if (newValue != oldValue) {
		if (dataContainer.isArray(varName)) {
			sendStr(CMD_SYNC_PREFIX @ CMD_UPDATE_VAR
			        @ class'NexgenUtil'.static.formatCmdArg(dataContainerID)
			        @ class'NexgenUtil'.static.formatCmdArg(varName)
			        @ index
			        @ class'NexgenUtil'.static.formatCmdArg(newValue));
		} else {
			sendStr(CMD_SYNC_PREFIX @ CMD_UPDATE_VAR
			        @ class'NexgenUtil'.static.formatCmdArg(dataContainerID)
			        @ class'NexgenUtil'.static.formatCmdArg(varName)
			        @ class'NexgenUtil'.static.formatCmdArg(newValue));
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the data that is stored in the specified shared data container.
 *  $PARAM        dataContainerID  Identifier of the data container whose data is to be saved.
 *  $REQUIRE      dataContainerID != ""
 *
 **************************************************************************************************/
simulated function saveSharedData(string dataContainerID) {
	// Check if client is allowed to save the data.
	if (!dataSyncMgr.maySaveData(self, dataContainerID)) {
		return;
	}
	
	// Send save command to server.
	sendStr(CMD_SYNC_PREFIX @ CMD_SAVE_DATA
	        @ class'NexgenUtil'.static.formatCmdArg(dataContainerID));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *
 **************************************************************************************************/
simulated function varChanged(NexgenSharedDataContainer container, string varName, optional int index) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization of the given shared data container is
 *                done. After this has happend the client may query its variables and receive valid
 *                results (assuming the client is allowed to read those variables).
 *  $PARAM        container  The shared data container that has become available for use.
 *  $REQUIRE      container != none
 *
 **************************************************************************************************/
simulated function dataContainerAvailable(NexgenSharedDataContainer container) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization by the given synchronization manager is
 *                done. This means all the data containers in the ynchronization manager are ready
 *                to be queried.
 *  $PARAM        dataSyncMgr  The shared data synchronization manager whose containers were initialized.
 *  $REQUIRE      dataSyncMgr != none
 *
 **************************************************************************************************/
simulated function sharedDataInitComplete(NexgenSharedDataSyncManager dataSyncMgr) {
	// To implement in subclass.
}