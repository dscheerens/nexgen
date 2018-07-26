/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenStringMap
 *  $VERSION      1.01 (02-03-2010 20:59)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Associative array data structure implementation for Unreal Tournament. The data
 *                structure is implemented using a hash table for storage and retrieval performance.
 *                However the order in which elements are stored will not be retained.
 *
 **************************************************************************************************/
class NexgenStringMap extends Info;

var bool bCaseSensitive;                // Whether the key names are case sensitive.
var NexgenStringMapBuffer table[31];    // Hash table containing the map elements.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Stores the given value for the specified key.
 *  $PARAM        key    Name of the element for which the value is to be stored.
 *  $PARAM        value  The value to store.
 *  $ENSURE       get(key, result); result == value
 *
 **************************************************************************************************/
function set(coerce string key, coerce string value) {
	local int index;
	
	index = getHashTableIndex(key);
	
	if (table[index] == none) {
		table[index] = spawn(class'NexgenStringMapBuffer');
		table[index].bCaseSensitive = bCaseSensitive;
	}
	
	table[index].set(key, value);
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
function bool get(coerce string key, out string value, optional coerce string defaultValue) {
	local int index;
	
	index = getHashTableIndex(key);
	
	if (table[index] == none) {
		value = defaultValue;
		return false;
	} else {
		return table[index].get(key, value, defaultValue);
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
function bool remove(coerce string key) {
	local int index;
	
	index = getHashTableIndex(key);
	
	if (table[index] == none) {
		return false;
	} else {
		return table[index].remove(key);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether there exist an element with the specified key.
 *  $PARAM        key  Name of the element that is to be checked for existance.
 *  $RETURN       True if an element with the specified key exist, false if not.
 *
 **************************************************************************************************/
function bool contains(coerce string key) {
	local int index;
	
	index = getHashTableIndex(key);
	
	if (table[index] == none) {
		return false;
	} else {
		return table[index].contains(key);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the number of elements stored in the map.
 *  $RETURN       The number of elements stored in the map.
 *  $ENSURE       result >= 0
 *
 **************************************************************************************************/
function int size() {
	local int size;
	local int index;
	
	// Count elements stored in buffers.
	for (index = 0; index < arrayCount(table); index++) {
		if (table[index] != none) {
			size += table[index].size();
		}
	}
	
	// Return total element count.
	return size;
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
	local bool bFound;
	local int tableIndex;
	
	while (!bFound && index >= 0 && tableIndex < arrayCount(table)) {
		if (table[tableIndex] != none && index < table[tableIndex].size()) {
			bFound = true;
			table[tableIndex].getElement(index, key, value);
		} else {
			if (table[tableIndex] != none) {
				index -= table[tableIndex].size();
			}
			tableIndex++;
		}
	}
	
	return !bFound;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Computes the hash table index for the specified key.
 *  $PARAM        key  The key for which the hash to index has be computed.
 *  $RETURN       The index in the hash table that contains the element with the specified key.
 *  $ENSURE       0 <= result && result < arrayCount(table)
 *
 **************************************************************************************************/
function int getHashTableIndex(string key) {
	local int index;
	local int hash;
	
	if (!bCaseSensitive) {
		key = caps(key);
	}
	
	for (index = 0; index < len(key); index++) {
		hash += clamp(asc(mid(key, index, 1)), 0, 255);
	}
	
	return hash % arrayCount(table);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the actor is destroyed and it will no longer be used during the game.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function destroyed() {
	local int index;
	
	// Destroy buffers.
	for (index = 0; index < arrayCount(table); index++) {
		if (table[index] != none) {
			table[index].destroy();
			table[index] = none;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	bCaseSensitive=false
}