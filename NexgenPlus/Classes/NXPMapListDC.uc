/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPMapListDC
 *  $VERSION      1.02 (30-07-2010 23:13)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Map list data container.
 *
 **************************************************************************************************/
class NXPMapListDC extends NexgenSharedDataContainer;

var int numMaps;                        // Number of maps that are available on the server.
var string maps[1024];                  // Package names of the maps that are available on the server.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the data that for this shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function loadData() {
	local NXPConfig xConf;
	local int index;
	local bool cacheMapList;
	local bool reloadMapList;
	local int autoCacheThreshold;
	
	xConf = NXPConfig(xControl.xConf);
	
	// Load settings.
	cacheMapList = dataSyncMgr.getBool("nxp_config", "cacheMapList");
	reloadMapList = dataSyncMgr.getBool("nxp_config", "reloadMapList");
	autoCacheThreshold = dataSyncMgr.getInt("nxp_config", "autoMapListCachingThreshold");
	
	// Load maps from cache.
	if (cacheMapList && !reloadMapList) {
		// Load maps from cache.
		numMaps = 0;
		while (numMaps < arrayCount(maps) && xConf.cachedMaps[numMaps] != "") {
			maps[numMaps] = xConf.cachedMaps[numMaps];
			numMaps++;
		}
		
		// Reload map list if the cache is empty.
		if (numMaps == 0) {
			reloadMapList = true;
		}
	}
	
	// Load maps from file system.
	if (!cacheMapList || reloadMapList) {
		loadLocalMaps();
		
		// Automatically enable caching.
		if (!cacheMapList && autoCacheThreshold > 0 && numMaps >= autoCacheThreshold) {
			dataSyncMgr.set("nxp_config", "cacheMapList", true);
			cacheMapList = true;
			reloadMapList = true;
		}
	}
	
	// Store map list cache.
	if (cacheMapList && reloadMapList) {
		// Copy map list to cache.
		for (index = 0; index < arrayCount(maps); index++) {
			xConf.cachedMaps[index] = maps[index];
		}
		
		// Clear reload map list flag.
		if (reloadMapList) {
			dataSyncMgr.set("nxp_config", "reloadMapList", false);
		}
		
		// Save cache.
		xConf.saveConfig();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Load the map list found on this machine.
 *
 **************************************************************************************************/
function loadLocalMaps() {
	local string firstMap;
	local string nextMap;
	local bool bIsValidMap;
	
	firstMap = getMapName("", "", 0);
	nextMap = firstMap;
	
	do {
		// Check if this is a valid map.
		bIsValidMap = class'NexgenUtil'.static.isValidLevel(nextMap);
		
		// Add map to maplist if valid.
		if (bIsValidMap) {
			maps[numMaps++] = nextMap;
		}
		
		// Retrieve next map.
		nextMap = getMapName("", nextMap, 1);
	} until (nextMap ~= firstMap || numMaps >= arrayCount(maps));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the number of variables that are stored in the container.
 *  $RETURN       The number of variables stored in the shared data container. 
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getVarCount() {
	return 2;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the variable name of the variable at the specified index.
 *  $PARAM        varIndex  Index of the variable whose name is to be retrieved.
 *  $REQUIRE      0 <= varIndex && varIndex <= getVarCount()
 *  $RETURN       The name of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getVarName(int varIndex) {
	switch (varIndex) {
		case 0: return "numMaps";
		case 1: return "maps";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the data type of the specified variable.
 *  $PARAM        varName  Name of the variable whose data type is to be retrieved.
 *  $REQUIRE      varName != ""
 *  $RETURN       The data type of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function byte getVarType(string varName) {
	switch (varName) {
		case "numMaps": return DT_INT;
		case "maps":    return DT_STRING;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified variable is an array.
 *  $PARAM        varName  Name of the variable which is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable is an array, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool isArray(string varName) {
	switch (varName) {
		case "maps": return true;
		default:     return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the array length of the specified variable.
 *  $PARAM        varName  Name of the variable which is to be checked.
 *  $REQUIRE      varName != "" && isArray(varName)
 *  $RETURN       The size of the array.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getArraySize(string varName) {
	switch (varName) {
		case "maps": return arrayCount(maps);
		default:     return 0;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the string value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The string value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getString(string varName, optional int index) {
	switch (varName) {
		case "numMaps": return string(numMaps);
		case "maps":    return maps[index];
		default:        return "";
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the integer value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The integer value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getInt(string varName, optional int index) {
	switch (varName) {
		case "numMaps": return numMaps;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be changed.
 *  $PARAM        value    New value for the variable.
 *  $PARAM        index    Array index in case the variable is an array.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $OVERRIDE
 *
 **************************************************************************************************/
function set(string varName, coerce string value, optional int index) {
	switch (varName) {
		case "numMaps": numMaps     = int(value); break;
		case "maps":    maps[index] = value;      break;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to read the variable value.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $PARAM        varName  Name of the variable whose access is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable may be read by the specified client, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool mayRead(NexgenExtendedClientController xClient, string varName) {
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	containerID="maplist"
}