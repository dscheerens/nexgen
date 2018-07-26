/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigEnumData
 *  $VERSION      1.02 (06-04-2010 11:07)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Enumeration definition holder for mod configuration variables.
 *
 **************************************************************************************************/
class NMCModConfigEnumData extends Info;

var NMCModConfigVar modConfigVar;       // The variable for which this enumeration data is stored.
var string enumValues[20];              // The enumeration values.
var string enumDescriptions[20];        // Enumeration value descriptions.
var int numEnums;                       // Number of enumeration values stored.
var NMCModConfigEnumData nextEnumData;  // Next enumeration definition holder in the link chain.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified enumeration value and its description to the definition holder.
 *  $PARAM        value        The value of the enumeration option that is to be added.
 *  $PARAM        description  A semantic description of the meaning of the enumeration value.
 *
 **************************************************************************************************/
function addEnumValue(string value, string description) {
	
	// Check if there is still space available for the enumeration value.
	if (numEnums >= arrayCount(enumValues)) {
		// No no enough space, add it to the next enumeration definition holder.
		if (nextEnumData == none) {
			nextEnumData = spawn(class'NMCModConfigEnumData');
			nextEnumData.modConfigVar = self.modConfigVar;
		}
		nextEnumData.addEnumValue(value, description);
	} else {
		// Yes there is enough space, add the enumeration value.
		enumValues[numEnums] = class'NexgenUtil'.static.trim(value);
		enumDescriptions[numEnums] = description;
		numEnums++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the enumeration definition lines stored to the specified network traffic
 *                handler.
 *  $PARAM        netHandler  The network traffic handler through which the data is to be send.
 *  $REQUIRE      netHandler != none
 *
 **************************************************************************************************/
function sendDefintionLines(NexgenNetClientController netHandler) {
	local int index;
	
	// Add each enumeration value to the queue.
	for (index = 0; index < numEnums; index++) {
		netHandler.sendStr(modConfigVar.modConfig.cfgContainer.CMD_ADD_ENUM_VAL
		                   @ class'NexgenUtil'.static.formatCmdArg(modConfigVar.modConfig.modID)
		                   @ class'NexgenUtil'.static.formatCmdArg(modConfigVar.modConfig.cfgContainer.netType2Str(modConfigVar.netType))
		                   @ class'NexgenUtil'.static.formatCmdArg(modConfigVar.className)
		                   @ class'NexgenUtil'.static.formatCmdArg(modConfigVar.varName)
		                   @ class'NexgenUtil'.static.formatCmdArg(enumValues[index])
		                   @ class'NexgenUtil'.static.formatCmdArg(enumDescriptions[index]));
	}
	
	// Also add definition lines for the other enumeration definition holders in the linked list.
	if (nextEnumData != none) {
		nextEnumData.sendDefintionLines(netHandler);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the number of enumeration values that are stored.
 *  $RETURN       The number of enumeration values that are stored.
 *  $ENSURE       result >= 0 
 *
 **************************************************************************************************/
function int getEnumCount() {
	local int count;
	
	count = numEnums;
	if (nextEnumData != none) {
		count += nextEnumData.getEnumCount();
	}
	
	return count;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the enumeration value at the specified index. In case no enumeration
 *                definition exists at the specified index an empty string will be returned.
 *  $PARAM        index  The index of the enumeration definition.
 *  $RETURN       The value of the enumeration.
 *
 **************************************************************************************************/
function string getEnumValue(int index) {
	if (index < numEnums) {
		return enumValues[index];
	} else if (nextEnumData != none) {
		return nextEnumData.getEnumValue(index - numEnums);
	} else {
		return "";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the enumeration value at the specified index. In case no enumeration
 *                definition exists at the specified index an empty string will be returned.
 *  $PARAM        index  The index of the enumeration definition.
 *  $RETURN       The value of the enumeration.
 *
 **************************************************************************************************/
function string getEnumDescription(int index) {
	if (index < numEnums) {
		return enumDescriptions[index];
	} else if (nextEnumData != none) {
		return nextEnumData.getEnumDescription(index - numEnums);
	} else {
		return "";
	}
}