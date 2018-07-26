/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenStringMapBuffer
 *  $VERSION      1.01 (02-03-2010 21:01)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Element buffer for the associative array data structure implementation.
 *
 **************************************************************************************************/
class NexgenStringMapBuffer extends Info;

var NexgenStringMapBuffer nextBuffer;   // Next element buffer in the chain.
var int numElements;                    // Number of elements stored in the buffer.
var string keys[100];                   // Element key names.
var string values[100];                 // Element values.
var bool bCaseSensitive;                // Whether the key names are case sensitive.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the number of elements stored in the map buffer.
 *  $RETURN       The number of elements stored in the map buffer.
 *  $ENSURE       result >= 0
 *
 **************************************************************************************************/
function int size() {
	local int size;
	
	size = numElements;
	if (numElements == arrayCount(keys) && nextBuffer != none) {
		size += nextBuffer.size();
	}
	
	return size;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the actor is destroyed and it will no longer be used during the game.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function destroyed() {
	local int index;
	
	// Destroy buffer chain.
	if (nextBuffer != none) {
		nextBuffer.destroy();
		nextBuffer = none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Stores the given value for the specified key.
 *  $PARAM        key    Name of the element for which the value is to be stored.
 *  $PARAM        value  The value to store.
 *  $ENSURE       get(key, result); result == value
 *
 **************************************************************************************************/
function set(string key, string value) {
	local int index;
	local bool bFound;
	
	// First try to see if the element already exists in this buffer.
	while (!bFound && index < numElements) {
		if (!bCaseSensitive && keys[index] ~= key || keys[index] == key) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Set value.
	if (bFound) {
		values[index] = value;
	} else if (numElements == arrayCount(keys)) {
		if (nextBuffer == none) {
			nextBuffer = spawn(class'NexgenStringMapBuffer');
			nextBuffer.bCaseSensitive = bCaseSensitive;
		}
		nextBuffer.set(key, value);
	} else {
		index = numElements++;
		keys[index] = key;
		values[index] = value;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the value of the element with the specified key.
 *  $PARAM        key           Name of the element whose value is to be retrieved.
 *  $PARAM        value         The value of the element.
 *  $PARAM        defaultValue  Value to use in case the element does not exist.
 *  $RETURN       True if the element with the specified key exist, false if not.
 *  $ENSURE       imply(!get(key, result, defVal), result == defVal)
 *
 **************************************************************************************************/
function bool get(string key, out string value, optional string defaultValue) {
	local int index;
	local bool bFound;
	
	// First try to locate the element in this buffer.
	while (!bFound && index < numElements) {
		if (!bCaseSensitive && keys[index] ~= key || keys[index] == key) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Retrieve value.
	if (bFound) {
		value = values[index];
		return true;
	} else if (numElements == arrayCount(keys) && nextBuffer != none) {
		return nextBuffer.get(key, value, defaultValue);
	} else {
		value = defaultValue;
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether there exist an element with the specified key.
 *  $PARAM        key  Name of the element that is to be checked for existance.
 *  $RETURN       True if an element with the specified key exist, false if not.
 *
 **************************************************************************************************/
function bool contains(string key) {
	local int index;
	local bool bFound;
	
	// First try to locate the element in this buffer.
	while (!bFound && index < numElements) {
		if (!bCaseSensitive && keys[index] ~= key || keys[index] == key) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Check if element exists.
	if (bFound) {
		return true;
	} else if (numElements == arrayCount(keys) && nextBuffer != none) {
		return nextBuffer.contains(key);
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the element with the specified key.
 *  $PARAM        key  Name of the element that is to be removed.
 *  $RETURN       True if the element was removed, false if it did not exist.
 *  $ENSURE       !contains(key)
 *
 **************************************************************************************************/
function bool remove(string key) {
	local int index;
	local bool bFound;
	
	// First try to locate the element in this buffer.
	while (!bFound && index < numElements) {
		if (!bCaseSensitive && keys[index] ~= key || keys[index] == key) {
			bFound = true;
		} else {
			index++;
		}
	}
	
	// Remove element.
	if (bFound) {
		copyAndRemoveLastElement(keys[index], values[index]);
		return true;
	} else if (numElements == arrayCount(keys) && nextBuffer != none) {
		return nextBuffer.remove(key);
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the last element from the buffer chain and removes it.
 *  $PARAM        elementKey    Name of the last element that was removed.
 *  $PARAM        elementValue  Value of the last element that was removed.
 *  $REQUIRE      size() > 0
 *  $ENSURE       new.size() == old.size() - 1;
 *
 **************************************************************************************************/
function copyAndRemoveLastElement(out string elementKey, out string elementValue) {
	local string lastElementKey;
	local string lastElementValue;
	
	if (numElements < arrayCount(keys) || nextBuffer == none || nextBuffer.numElements == 0) {
		numElements--;
		elementKey = keys[numElements];
		elementValue = values[numElements];
		keys[numElements] = "";
		values[numElements] = "";
	} else {
		nextBuffer.copyAndRemoveLastElement(elementKey, elementValue);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the element with the specified index.
 *  $PARAM        index  The index of the element that is to be retrieved.
 *  $PARAM        key    Name of the element that is to be retrieved.
 *  $PARAM        value  Value of the element that is to be retrieved.
 *  $RETURN       True if the specified index exists and the element has been retrieved.
 *
 **************************************************************************************************/
function bool getElement(int index, out string key, out string value) {
	if (index < numElements) {
		key = keys[index];
		value = values[index];
		return true;
	} else if (nextBuffer != none && nextBuffer.numElements > 0) {
		return nextBuffer.getElement(index - numElements, key, value);
	} else {
		return false;
	}
}
