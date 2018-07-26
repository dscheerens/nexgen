/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPConfigDC
 *  $VERSION      1.08 (17-12-2010 22:57:41)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen Plus configuration data container.
 *
 **************************************************************************************************/
class NXPConfigDC extends NexgenSharedDataContainer;

var NXPConfig xConf;                              // Configuration instance.

var bool enableMapSwitch;                         // Whether map switch is available.
var bool cacheMapList;                            // Whether to use the cached map list.
var bool reloadMapList;                           // Reload the map list next game.
var int autoMapListCachingThreshold;              // Map number threshold for automatically enabling
                                                  // map list caching.
var bool showMapSwitchAtEndOfGame;                // Automatically open map switch tab at the end of
                                                  // the game?
var int mapSwitchAutoDisplayDelay;                // Time to wait before automatically opening the
                                                  // map switch tab.
var bool showDamageProtectionShield;              // Show a damage protection shield around players.
var bool colorizePlayerSkins;                     // Colorize the player skins with team colors.
var bool enableAKALogging;                        // Enable AKA client ID logging.
var bool disableUTAntiSpam;                       // Disable UTs buildin anti message spam feature.
var bool enableNexgenAntiSpam;                    // Enable Nexgens anti message spam feature.
var bool checkForNexgenUpdates;                   // Automatically check for new Nexgen versions.

var bool enableFullServerRedirect;                // Show list of alternate servers when server is full.
var bool autoFullServerRedirect;                  // Automatically redirect player when server is full.
var string altServerName[3];                      // Names of the alternate servers.
var string altServerAddress[3];                   // Addresses of the alternate servers.

var bool enableTagProtection;                     // Whether tag protection should be enabled.
var string tagsToProtect[6];                      // The tags that are protected.

var string serverRules[10];                       // The rules of the server.
var bool showServerRulesTab;                      // Whether to display the server rules tab in the control panel.
var bool showServerRulesInHUD;                    // Whether to display the server rules tab in the players HUD.
var byte serverRulesHUDAnchorPointLocH;           // Horizontal anchor point of the server rules HUD window.
var byte serverRulesHUDAnchorPointLocV;           // Vertical anchor point of the server rules HUD window.
var int serverRulesHUDPosX;                       // Horizontal position of the HUD anchor point on the screen.
var int serverRulesHUDPosY;                       // Vertical position of the HUD anchor point on the screen.
var byte serverRulesHUDPosXUnits;                 // Units of the horizontal rules HUD anchor point.
var byte serverRulesHUDPosYUnits;                 // Units of the vertical rules HUD anchor point.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the data that for this shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function loadData() {
	local int index;
	
	xConf = NXPConfig(xControl.xConf);
	
	enableMapSwitch               = xConf.enableMapSwitch;
	cacheMapList                  = xConf.cacheMapList;
	reloadMapList                 = xConf.reloadMapList;
	autoMapListCachingThreshold   = xConf.autoMapListCachingThreshold;
	showMapSwitchAtEndOfGame      = xConf.showMapSwitchAtEndOfGame;
	mapSwitchAutoDisplayDelay     = xConf.mapSwitchAutoDisplayDelay;
	showDamageProtectionShield    = xConf.showDamageProtectionShield;
	colorizePlayerSkins           = xConf.colorizePlayerSkins;
	enableAKALogging              = xConf.enableAKALogging;
	disableUTAntiSpam             = xConf.disableUTAntiSpam;
	enableNexgenAntiSpam          = xConf.enableNexgenAntiSpam;
	checkForNexgenUpdates         = xConf.checkForNexgenUpdates;
	enableFullServerRedirect      = xConf.enableFullServerRedirect;
	autoFullServerRedirect        = xConf.autoFullServerRedirect;
	for (index = 0; index < arrayCount(altServerName); index++)
	altServerName[index]          = xConf.altServerName[index];
	for (index = 0; index < arrayCount(altServerAddress); index++)
	altServerAddress[index]       = xConf.altServerAddress[index];
	enableTagProtection           = xConf.enableTagProtection;
	for (index = 0; index < arrayCount(tagsToProtect); index++)
	tagsToProtect[index]          = xConf.tagsToProtect[index];
	for (index = 0; index < arrayCount(serverRules); index++)
	serverRules[index]            = xConf.serverRules[index];
	showServerRulesTab            = xConf.showServerRulesTab;
	showServerRulesInHUD          = xConf.showServerRulesInHUD;
	serverRulesHUDAnchorPointLocH = xConf.serverRulesHUDAnchorPointLocH;
	serverRulesHUDAnchorPointLocV = xConf.serverRulesHUDAnchorPointLocV;
	serverRulesHUDPosX            = xConf.serverRulesHUDPosX;
	serverRulesHUDPosY            = xConf.serverRulesHUDPosY;
	serverRulesHUDPosXUnits       = xConf.serverRulesHUDPosXUnits;
	serverRulesHUDPosYUnits       = xConf.serverRulesHUDPosYUnits;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the data store in this shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function saveData() {
	xConf.saveConfig();
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
		case "enableMapSwitch":               enableMapSwitch               = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.enableMapSwitch               = enableMapSwitch;               } break;
		case "cacheMapList":                  cacheMapList                  = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.cacheMapList                  = cacheMapList;                  } break;
		case "reloadMapList":                 reloadMapList                 = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.reloadMapList                 = reloadMapList;                 } break;
		case "autoMapListCachingThreshold":   autoMapListCachingThreshold   = clamp(int(value), 0, 9999);               if (xConf != none) { xConf.autoMapListCachingThreshold   = autoMapListCachingThreshold;   } break;
		case "showMapSwitchAtEndOfGame":      showMapSwitchAtEndOfGame      = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.showMapSwitchAtEndOfGame      = showMapSwitchAtEndOfGame;      } break;
		case "mapSwitchAutoDisplayDelay":     mapSwitchAutoDisplayDelay     = clamp(int(value), 0, 999);                if (xConf != none) { xConf.mapSwitchAutoDisplayDelay     = mapSwitchAutoDisplayDelay;     } break;
		case "showDamageProtectionShield":    showDamageProtectionShield    = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.showDamageProtectionShield    = showDamageProtectionShield;    } break;
		case "colorizePlayerSkins":           colorizePlayerSkins           = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.colorizePlayerSkins           = colorizePlayerSkins;           } break;
		case "enableAKALogging":              enableAKALogging              = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.enableAKALogging              = enableAKALogging;              } break;
		case "disableUTAntiSpam":             disableUTAntiSpam             = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.disableUTAntiSpam             = disableUTAntiSpam;             } break;
		case "enableNexgenAntiSpam":          enableNexgenAntiSpam          = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.enableNexgenAntiSpam          = enableNexgenAntiSpam;          } break;
		case "checkForNexgenUpdates":         checkForNexgenUpdates         = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.checkForNexgenUpdates         = checkForNexgenUpdates;         } break;
		case "enableFullServerRedirect":      enableFullServerRedirect      = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.enableFullServerRedirect      = checkForNexgenUpdates;         } break;
		case "autoFullServerRedirect":        autoFullServerRedirect        = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.autoFullServerRedirect        = autoFullServerRedirect;        } break;
		case "altServerName":                 altServerName[index]          = value;                                    if (xConf != none) { xConf.altServerName[index]          = altServerName[index];          } break;
		case "altServerAddress":              altServerAddress[index]       = value;                                    if (xConf != none) { xConf.altServerAddress[index]       = altServerAddress[index];       } break;
		case "enableTagProtection":           enableTagProtection           = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.enableTagProtection           = enableTagProtection;           } break;
		case "tagsToProtect":                 tagsToProtect[index]          = value;                                    if (xConf != none) { xConf.tagsToProtect[index]          = tagsToProtect[index];          } break;
		case "serverRules":                   serverRules[index]            = value;                                    if (xConf != none) { xConf.serverRules[index]            = serverRules[index];            } break;
		case "showServerRulesTab":            showServerRulesTab            = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.showServerRulesTab            = showServerRulesTab;            } break;
		case "showServerRulesInHUD":          showServerRulesInHUD          = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.showServerRulesInHUD          = showServerRulesInHUD;          } break;
		case "serverRulesHUDAnchorPointLocH": serverRulesHUDAnchorPointLocH = byte(clamp(int(value), 1, 3));            if (xConf != none) { xConf.serverRulesHUDAnchorPointLocH = serverRulesHUDAnchorPointLocH; } break;
		case "serverRulesHUDAnchorPointLocV": serverRulesHUDAnchorPointLocV = byte(clamp(int(value), 1, 3));            if (xConf != none) { xConf.serverRulesHUDAnchorPointLocV = serverRulesHUDAnchorPointLocV; } break;
		case "serverRulesHUDPosX":            serverRulesHUDPosX            = int(value);                               if (xConf != none) { xConf.serverRulesHUDPosX            = serverRulesHUDPosX;            } break;
		case "serverRulesHUDPosY":            serverRulesHUDPosY            = int(value);                               if (xConf != none) { xConf.serverRulesHUDPosY            = serverRulesHUDPosY;            } break;
		case "serverRulesHUDPosXUnits":       serverRulesHUDPosXUnits       = byte(clamp(int(value), 1, 2));            if (xConf != none) { xConf.serverRulesHUDPosXUnits       = serverRulesHUDPosXUnits;       } break;
		case "serverRulesHUDPosYUnits":       serverRulesHUDPosYUnits       = byte(clamp(int(value), 1, 2));            if (xConf != none) { xConf.serverRulesHUDPosYUnits       = serverRulesHUDPosYUnits;       } break;
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
	switch (varName) {
		case "enableMapSwitch":               return xClient.client.hasRight(xClient.client.R_MatchAdmin);
		case "cacheMapList":                  return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "reloadMapList":                 return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "autoMapListCachingThreshold":   return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "showMapSwitchAtEndOfGame":      return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "mapSwitchAutoDisplayDelay":     return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "showDamageProtectionShield":    return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "colorizePlayerSkins":           return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "enableAKALogging":              return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "disableUTAntiSpam":             return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "enableNexgenAntiSpam":          return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "checkForNexgenUpdates":         return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "enableFullServerRedirect":      return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "autoFullServerRedirect":        return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "altServerName":                 return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "altServerAddress":              return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "enableTagProtection":           return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "tagsToProtect":                 return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "serverRules":                   return true;
		case "showServerRulesTab":            return true;
		case "showServerRulesInHUD":          return true;
		case "serverRulesHUDAnchorPointLocH": return true;
		case "serverRulesHUDAnchorPointLocV": return true;
		case "serverRulesHUDPosX":            return true;
		case "serverRulesHUDPosY":            return true;
		case "serverRulesHUDPosXUnits":       return true;
		case "serverRulesHUDPosYUnits":       return true;
		default:                              return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to change the variable value.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $PARAM        varName  Name of the variable whose access is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable may be changed by the specified client, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool mayWrite(NexgenExtendedClientController xClient, string varName) {
	switch (varName) {
		case "enableMapSwitch":               return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "cacheMapList":                  return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "reloadMapList":                 return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "autoMapListCachingThreshold":   return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "showMapSwitchAtEndOfGame":      return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "mapSwitchAutoDisplayDelay":     return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "showDamageProtectionShield":    return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "colorizePlayerSkins":           return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "enableAKALogging":              return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "disableUTAntiSpam":             return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "enableNexgenAntiSpam":          return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "checkForNexgenUpdates":         return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "enableFullServerRedirect":      return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "autoFullServerRedirect":        return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "altServerName":                 return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "altServerAddress":              return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "enableTagProtection":           return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "tagsToProtect":                 return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "serverRules":                   return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "showServerRulesTab":            return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "showServerRulesInHUD":          return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "serverRulesHUDAnchorPointLocH": return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "serverRulesHUDAnchorPointLocV": return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "serverRulesHUDPosX":            return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "serverRulesHUDPosY":            return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "serverRulesHUDPosXUnits":       return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		case "serverRulesHUDPosYUnits":       return xClient.client.hasRight(xClient.client.R_ServerAdmin);
		default:                              return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to save the data in this container.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $REQUIRE      xClient != none
 *  $RETURN       True if the data may be saved by the specified client, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool maySaveData(NexgenExtendedClientController xClient) {
	return xClient.client.hasRight(xClient.client.R_ServerAdmin);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the boolean value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The boolean value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool getBool(string varName, optional int index) {
	switch (varName) {
		case "enableMapSwitch":             return enableMapSwitch;
		case "cacheMapList":                return cacheMapList;
		case "reloadMapList":               return reloadMapList;
		case "showMapSwitchAtEndOfGame":    return showMapSwitchAtEndOfGame;
		case "showDamageProtectionShield":  return showDamageProtectionShield;
		case "colorizePlayerSkins":         return colorizePlayerSkins;
		case "enableAKALogging":            return enableAKALogging;
		case "disableUTAntiSpam":           return disableUTAntiSpam;
		case "enableNexgenAntiSpam":        return enableNexgenAntiSpam;
		case "checkForNexgenUpdates":       return checkForNexgenUpdates;
		case "enableFullServerRedirect":    return enableFullServerRedirect;
		case "autoFullServerRedirect":      return autoFullServerRedirect;
		case "enableTagProtection":         return enableTagProtection;
		case "showServerRulesTab":          return showServerRulesTab;
		case "showServerRulesInHUD":        return showServerRulesInHUD;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the byte value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The byte value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function byte getByte(string varName, optional int index) {
	switch (varName) {
		case "serverRulesHUDAnchorPointLocH": return int(serverRulesHUDAnchorPointLocH);
		case "serverRulesHUDAnchorPointLocV": return int(serverRulesHUDAnchorPointLocV);
		case "serverRulesHUDPosXUnits":       return int(serverRulesHUDPosXUnits);
		case "serverRulesHUDPosYUnits":       return int(serverRulesHUDPosYUnits);
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
		case "autoMapListCachingThreshold":   return autoMapListCachingThreshold;
		case "mapSwitchAutoDisplayDelay":     return mapSwitchAutoDisplayDelay;
		case "serverRulesHUDAnchorPointLocH": return int(serverRulesHUDAnchorPointLocH);
		case "serverRulesHUDAnchorPointLocV": return int(serverRulesHUDAnchorPointLocV);
		case "serverRulesHUDPosX":            return serverRulesHUDPosX;
		case "serverRulesHUDPosY":            return serverRulesHUDPosY;
		case "serverRulesHUDPosXUnits":       return int(serverRulesHUDPosXUnits);
		case "serverRulesHUDPosYUnits":       return int(serverRulesHUDPosYUnits);
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
		case "enableMapSwitch":               return string(enableMapSwitch);
		case "cacheMapList":                  return string(cacheMapList);
		case "reloadMapList":                 return string(reloadMapList);
		case "autoMapListCachingThreshold":   return string(autoMapListCachingThreshold);
		case "showMapSwitchAtEndOfGame":      return string(showMapSwitchAtEndOfGame);
		case "mapSwitchAutoDisplayDelay":     return string(mapSwitchAutoDisplayDelay);
		case "showDamageProtectionShield":    return string(showDamageProtectionShield);
		case "colorizePlayerSkins":           return string(colorizePlayerSkins);
		case "enableAKALogging":              return string(enableAKALogging);
		case "disableUTAntiSpam":             return string(disableUTAntiSpam);
		case "enableNexgenAntiSpam":          return string(enableNexgenAntiSpam);
		case "checkForNexgenUpdates":         return string(checkForNexgenUpdates);
		case "enableFullServerRedirect":      return string(enableFullServerRedirect);
		case "autoFullServerRedirect":        return string(autoFullServerRedirect);
		case "altServerName":                 return altServerName[index];
		case "altServerAddress":              return altServerAddress[index];
		case "enableTagProtection":           return string(enableTagProtection);
		case "tagsToProtect":                 return tagsToProtect[index];
		case "serverRules":                   return serverRules[index];
		case "showServerRulesTab":            return string(showServerRulesTab);
		case "showServerRulesInHUD":          return string(showServerRulesInHUD);
		case "serverRulesHUDAnchorPointLocH": return string(serverRulesHUDAnchorPointLocH);
		case "serverRulesHUDAnchorPointLocV": return string(serverRulesHUDAnchorPointLocV);
		case "serverRulesHUDPosX":            return string(serverRulesHUDPosX);
		case "serverRulesHUDPosY":            return string(serverRulesHUDPosY);
		case "serverRulesHUDPosXUnits":       return string(serverRulesHUDPosXUnits);
		case "serverRulesHUDPosYUnits":       return string(serverRulesHUDPosYUnits);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the number of variables that are stored in the container.
 *  $RETURN       The number of variables stored in the shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getVarCount() {
	return 27;
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
		case 0:  return "enableMapSwitch";
		case 1:  return "cacheMapList";
		case 2:  return "reloadMapList";
		case 3:  return "autoMapListCachingThreshold";
		case 4:  return "showMapSwitchAtEndOfGame";
		case 5:  return "mapSwitchAutoDisplayDelay";
		case 6:  return "showDamageProtectionShield";
		case 7:  return "colorizePlayerSkins";
		case 8:  return "enableAKALogging";
		case 9:  return "disableUTAntiSpam";
		case 10: return "enableNexgenAntiSpam";
		case 11: return "checkForNexgenUpdates";
		case 12: return "enableFullServerRedirect";
		case 13: return "autoFullServerRedirect";
		case 14: return "altServerName";
		case 15: return "altServerAddress";
		case 16: return "enableTagProtection";
		case 17: return "tagsToProtect";
		case 18: return "serverRules";
		case 19: return "showServerRulesTab";
		case 20: return "showServerRulesInHUD";
		case 21: return "serverRulesHUDAnchorPointLocH";
		case 22: return "serverRulesHUDAnchorPointLocV";
		case 23: return "serverRulesHUDPosX";
		case 24: return "serverRulesHUDPosY";
		case 25: return "serverRulesHUDPosXUnits";
		case 26: return "serverRulesHUDPosYUnits";
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
		case "enableMapSwitch":               return DT_BOOL;
		case "cacheMapList":                  return DT_BOOL;
		case "reloadMapList":                 return DT_BOOL;
		case "autoMapListCachingThreshold":   return DT_INT;
		case "showMapSwitchAtEndOfGame":      return DT_BOOL;
		case "mapSwitchAutoDisplayDelay":     return DT_INT;
		case "showDamageProtectionShield":    return DT_BOOL;
		case "colorizePlayerSkins":           return DT_BOOL;
		case "enableAKALogging":              return DT_BOOL;
		case "disableUTAntiSpam":             return DT_BOOL;
		case "enableNexgenAntiSpam":          return DT_BOOL;
		case "checkForNexgenUpdates":         return DT_BOOL;
		case "enableFullServerRedirect":      return DT_BOOL;
		case "autoFullServerRedirect":        return DT_BOOL;
		case "altServerName":                 return DT_STRING;
		case "altServerAddress":              return DT_STRING;
		case "enableTagProtection":           return DT_BOOL;
		case "tagsToProtect":                 return DT_STRING;
		case "serverRules":                   return DT_STRING;
		case "showServerRulesTab":            return DT_BOOL;
		case "showServerRulesInHUD":          return DT_BOOL;
		case "serverRulesHUDAnchorPointLocH": return DT_BYTE;
		case "serverRulesHUDAnchorPointLocV": return DT_BYTE;
		case "serverRulesHUDPosX":            return DT_INT;
		case "serverRulesHUDPosY":            return DT_INT;
		case "serverRulesHUDPosXUnits":       return DT_BYTE;
		case "serverRulesHUDPosYUnits":       return DT_BYTE;
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
		case "altServerName":               return arrayCount(altServerName);
		case "altServerAddress":            return arrayCount(altServerAddress);
		case "tagsToProtect":               return arrayCount(tagsToProtect);
		case "serverRules":                 return arrayCount(serverRules);
		default:				            return 0;
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
		case "altServerName":
		case "altServerAddress":
		case "tagsToProtect":
		case "serverRules":
			return true;
		default:
			return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	containerID="nxp_config"
}