/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenCPKeyBind
 *  $VERSION      1.04 (19-1-2008 17:51)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen keybind settings panel.
 *
 **************************************************************************************************/
class NexgenCPKeyBind extends NexgenPanel;

var UMenuRaisedButton bindButton[9];    // Keybind buttons.
var string bindCommand[9];              // Console commands for the key binds.
var int selectedBind;                   // Currently selected key.
var bool bPolling;                      // Waiting for a new key assignment.

const bindSeparator = "|";              // Token used to seperate commands in an action string.
const getKeyNameCommand = "keyname";    // Console command to retrieve a key name.
const getKeyBindCommand = "keybinding"; // Console command to retrieve the action bound to a key.
const setKeyBindCommand = "set input";  // Console command to change a key binding.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local int index;	
	
	// Create layout & add components.
	setAcceptsFocus();
	createPanelRootRegion();
	splitRegionH(16);
	
	addLabel(client.lng.keyBindsTxt, true, TA_Center);
	divideRegionV(2);
	divideRegionH(arrayCount(bindButton));
	divideRegionH(arrayCount(bindButton));
	
	addLabel(client.lng.balanceBindTxt);
	addLabel(client.lng.switchRedBindTxt);
	addLabel(client.lng.switchBlueBindTxt);
	addLabel(client.lng.switchGreenBindTxt);
	addLabel(client.lng.switchGoldBindTxt);
	addLabel(client.lng.suicideBindTxt);
	addLabel(client.lng.openMapVoteBindTxt);
	addLabel(client.lng.openCPBindTxt);
	addLabel(client.lng.pauseGameBindTxt);
	
	for (index = 0; index < arrayCount(bindButton); index++) {
		bindButton[index] = addRaisedButton();
		bindButton[index].align = TA_Center;
		bindButton[index].bAcceptsFocus = false;
		bindButton[index].bIgnoreLDoubleClick = true;
		bindButton[index].bIgnoreMDoubleClick = true;
		bindButton[index].bIgnoreRDoubleClick = true;
		bindButton[index].index = index;
		bindButton[index].register(self);
	}
	
	loadKeyBinds();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the keybind settings and displays them on the config panel.
 *
 **************************************************************************************************/
function loadKeyBinds() {
	local int keyNum;
	local string keyName;
	local string keyAction;
	local int index;
	
	// Iterate over all keys.
	for (keyNum = 0; keyNum < 255; keyNum++) {
		keyName = client.player.consoleCommand(getKeyNameCommand @ keyNum);
		if (keyName != "") {
			// Get action assigned to key.
			keyAction = client.player.consoleCommand(getKeyBindCommand @ keyName);
			
			// Check action string with the keybind commands.
			for (index = 0; index < arrayCount(bindButton); index++) {
				if (containsCommand(keyAction, bindCommand[index])) {
					bindButton[index].text = keyName;
				}
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether a keybind action contains one of the specified commands. Commands 
 *                are separated by the 'separator' token (comma).
 *  $PARAM        action    Keybind action string.
 *  $PARAM        commands  List of commands to check for.
 *  $REQUIRE      commands != ""
 *  $RETURN       True if the action string contains one of the specified commands.
 *
 **************************************************************************************************/
function bool containsCommand(string action, string commands) {
	local string cmd;
	local string remaining;
	local int index;
	local bool bFound;
	
	action = caps(action);
	
	// For each command in the command string (separated by commas).
	remaining = caps(commands);
	while (remaining != "" && !bFound) {
		
		// Get next command.
		index = instr(remaining, separator);
		if (index < 0) {
			cmd = remaining;
			remaining = "";
		} else {
			cmd = left(remaining, index);
			remaining = mid(remaining, index + len(separator));
		}
		
		// Compare command.
		bFound = instr(action, cmd) >= 0;
	}
	
	return bFound;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType) {
	local int index;
	
	super.notify(control, eventType);
	
	if (eventType == DE_Click) {
		
		// Keybind button clicked?
		if (control != none && control.isA('UMenuRaisedButton')) {
			index = UMenuRaisedButton(control).index;
			
			if (bPolling && selectedBind == index) {
				// Clicked on same button, cancel polling.
				bindButton[selectedBind].bDisabled = false;
				bPolling = false;
			
			} else if (bPolling) {	
				// New key bind button selected.
				bindButton[selectedBind].bDisabled = false;
				bindButton[index].bDisabled = true;
				selectedBind = index;
				
			} else {
				// No key bind button selected yet.
				bindButton[index].bDisabled = true;
				selectedBind = index;
				bPolling = true;
			}
		
		} else if (bPolling) {
			// Clicked elsewhere, but still polling, cancel action.
			bindButton[selectedBind].bDisabled = false;
			bPolling = false;
		}
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of a key press event.
 *  $PARAM        key  The number of the key that was pressed.
 *  $PARAM        x    Unknown, x location of mouse cursor?
 *  $PARAM        y    Unknown, x location of mouse cursor?
 *  $OVERRIDE
 *
 **************************************************************************************************/
function keyDown(int key, float x, float y) {
	local string keyName;
	
	keyName = client.player.consoleCommand(getKeyNameCommand @ key);
	
	// Assign new key binding?
	if (bPolling && keyName != "") {
		
		// Remove old binding.
		removeKeybind(bindButton[selectedBind].text, bindCommand[selectedBind]);
		
		// Add new binding.
		addKeybind(keyName, bindCommand[selectedBind]);
		
		// Update buttons.
		bindButton[selectedBind].bDisabled = false;
		bindButton[selectedBind].text = keyName;
		bPolling = false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the specified commands from the action bound to the given key.
 *  $PARAM        keyName   Name of the key for which the bindings should be updated.
 *  $PARAM        commands  List of commands to remove from the action string.
 *  $REQUIRE      keyName != ""
 *
 **************************************************************************************************/
function removeKeybind(String keyName, string commands) {
	local string actionStr;
	local string remaining;
	local string cmd;
	local int index;
	
	// Get action string.
	actionStr = client.player.consoleCommand(getKeyBindCommand @ keyName);
	
	// Update action string.
	remaining = caps(commands);
	while (remaining != "") {
		
		// Get next command.
		index = instr(remaining, separator);
		if (index < 0) {
			cmd = remaining;
			remaining = "";
		} else {
			cmd = left(remaining, index);
			remaining = mid(remaining, index + len(separator));
		}
		
		// Remove command from action string.
		index = instr(caps(actionStr), cmd);
		if (index >= 0) {
			actionStr = left(actionStr, index) $ mid(actionStr, index + len(cmd));
			if (mid(actionStr, index, len(bindSeparator)) == bindSeparator) {
				// Remove | token after command.
				actionStr = left(actionStr, index) $ mid(actionStr, index + len(bindSeparator));
			}
		}
		
	}
	
	// Store action string.
	client.player.consoleCommand(setKeyBindCommand @ keyName @ actionStr);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified command from to the action bound to the given key.
 *  $PARAM        keyName   Name of the key for which the bindings should be updated.
 *  $PARAM        command   Commands to add to the action string.
 *  $REQUIRE      keyName != ""
 *
 **************************************************************************************************/
function addKeybind(String keyName, string command) {
	local string actionStr;
	local string cmd;
	
	// Get action string.
	actionStr = client.player.consoleCommand(getKeyBindCommand @ keyName);
	
	// Update action string.
	if (instr(command, separator) >= 0) {
		cmd = left(command, instr(command, separator));
	} else {
		cmd = command;
	}
	
	if (class'NexgenUtil'.static.trim(actionStr) == "") {
		// No action bound yet.
		actionStr = cmd;
	} else {
		// Some actions already bound.
		actionStr = actionStr $ bindSeparator $ cmd;
	}
	
	// Store action string.
	client.player.consoleCommand(setKeyBindCommand @ keyName @ actionStr);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	bindCommand(0)="mutate nsc balanceteams"
	bindCommand(1)="mutate nsc setteam 0"
	bindCommand(2)="mutate nsc setteam 1"
	bindCommand(3)="mutate nsc setteam 2"
	bindCommand(4)="mutate nsc setteam 3"
	bindCommand(5)="suicide"
	bindCommand(6)="mutate nsc openvote,mutate hz010"
	bindCommand(7)="mutate nsc openrcp,mutate asc#get#window,mutate hz0090"
	bindCommand(8)="mutate nsc pause"
}

