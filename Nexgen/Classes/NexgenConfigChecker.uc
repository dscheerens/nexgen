/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenConfigChecker
 *  $VERSION      1.06 (14-12-2008 11:34)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Configuration checking class. This class contains code for checking the
 *                configuration of the server controller. It will automatically try to repair any
 *                errors or inconsitensties. The code has been place into a separate class to save
 *                NexgenConfig from becoming too large (and therefore unreadable).
 *
 **************************************************************************************************/
class NexgenConfigChecker extends info;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the given Nexgen configuration. Any invalid settings will be
 *                automatically adjusted to a proper setting.
 *  $PARAM        c  The configuration that is to be checked.
 *  $REQUIRE      c  != none
 *  $RETURN       True, if the configuration was valid, false otherwise.
 *  $ENSURE       !old.checkConfig(c) ? new.checkConfig(c) : true
 *
 **************************************************************************************************/
function bool checkConfig(NexgenConfig c) {
	local bool bInvalid;
	
	bInvalid = checkEncryption(c) ||
	           checkGlobalServerSettings(c) ||
	           checkExtraServerSettings(c) ||
	           checkBootControlSettings(c) ||
	           checkAccountSystemSettings(c) ||
	           checkBanList(c) ||
	           checkMatchSettings(c) ||
	           checkLogSettings(c);

	// Save repaired configuration if needed.
	if (bInvalid) {
		c.saveConfig();
	}
	
	// Return result.
	return !bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the server encryption parameters.
 *  $PARAM        c  The configuration that is to be checked.
 *  $REQUIRE      c  != none
 *  $RETURN       True if the configuration was valid, false otherwise.
 *
 **************************************************************************************************/
function bool checkEncryption(NexgenConfig c) {
	local bool bInvalid;
	local int index;
	
	// Fix things if necessary.
	if (c.configEncryptionKeys[c.CS_GlobalServerSettings] == 0 || len(c.configCodeSchemes[c.CS_GlobalServerSettings]) != 32) {
		bInvalid = true;
		c.resetEncryptionConfig(c.CS_GlobalServerSettings);
		c.globalServerPassword = c.encode(c.CS_GlobalServerSettings, consoleCommand("get Engine.GameInfo GamePassword"));
		c.globalAdminPassword = c.encode(c.CS_GlobalServerSettings, consoleCommand("get Engine.GameInfo AdminPassword"));
		c.serverPassword = "";
		for (index = 0; index < arrayCount(c.atPassword); index++) {
			c.atPassword[index] = "";
		}
	}
	
	// Return result.
	return bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the global server settings.
 *  $PARAM        c  The configuration that is to be checked.
 *  $REQUIRE      c  != none
 *  $RETURN       True if the configuration was valid, false otherwise.
 *
 **************************************************************************************************/
function bool checkGlobalServerSettings(NexgenConfig c) {
	local bool bInvalid;
	
	// Check server info settings.
	if (c.serverName == "") {
		bInvalid = true;
		c.serverName = "[NEXGEN] Another UT Server";
	}
	bInvalid = bInvalid || fixStrLen(c.serverName,  128);
	bInvalid = bInvalid || fixStrLen(c.shortName,    32);
	bInvalid = bInvalid || fixStrLen(c.adminName,    64);
	bInvalid = bInvalid || fixStrLen(c.adminEmail,   64);
	bInvalid = bInvalid || fixStrLen(c.MOTDLine[0], 192);
	bInvalid = bInvalid || fixStrLen(c.MOTDLine[1], 192);
	bInvalid = bInvalid || fixStrLen(c.MOTDLine[2], 192);
	bInvalid = bInvalid || fixStrLen(c.MOTDLine[3], 192);
	
	// Check slot settings.
	bInvalid = bInvalid || fixByteRange(c.playerSlots,    0, 32);
	bInvalid = bInvalid || fixByteRange(c.vipSlots,       0, 16);
	bInvalid = bInvalid || fixByteRange(c.adminSlots,     0, 16);
	bInvalid = bInvalid || fixByteRange(c.spectatorSlots, 0, 16);
	if (c.playerSlots + c.vipSlots + c.adminSlots <= 0) {
		bInvalid = true;
		c.playerSlots = 16;
	}
	
	// Return check result.
	return bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the extra server settings.
 *  $PARAM        c  The configuration that is to be checked.
 *  $REQUIRE      c  != none
 *  $RETURN       True if the configuration was valid, false otherwise.
 *
 **************************************************************************************************/
function bool checkExtraServerSettings(NexgenConfig c) {
	local bool bInvalid;
	local int index;
	
	bInvalid = bInvalid || fixByteRange(c.waitTime,                     0,   60);
	bInvalid = bInvalid || fixByteRange(c.startTime,                    0,   30);
	bInvalid = bInvalid || fixByteRange(c.autoReconnectTime,            0,   60);
	bInvalid = bInvalid || fixIntRange(c.maxIdleTime,                   0, 9999);
	bInvalid = bInvalid || fixIntRange(c.maxIdleTimeCP,                 0, 9999);
	bInvalid = bInvalid || fixByteRange(c.spawnProtectionTime,          0,   60);
	bInvalid = bInvalid || fixByteRange(c.teamKillDamageProtectionTime, 0,   30);
	bInvalid = bInvalid || fixByteRange(c.teamKillPushProtectionTime,   0,   60);
	bInvalid = bInvalid || fixByteRange(c.autoDisableMatchTime,         0,  120);
	for (index = 0; index < arrayCount(c.spawnProtectExcludeWeapons); index++) {
		bInvalid = bInvalid || fixStrLen(c.spawnProtectExcludeWeapons[index], 64);
	}
	
	// Return check result.
	return bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the boot control settings.
 *  $PARAM        c  The configuration that is to be checked.
 *  $REQUIRE      c  != none
 *  $RETURN       True if the configuration was valid, false otherwise.
 *
 **************************************************************************************************/
function bool checkBootControlSettings(NexgenConfig c) {
	local bool bInvalid;
	
	if (len(c.bootGameType) > 64) {
		bInvalid = true;
		c.bootGameType = "";
	}
	bInvalid = bInvalid || fixStrLen(c.bootMapPrefix,   8);
	bInvalid = bInvalid || fixStrLen(c.bootOptions,   255);
	bInvalid = bInvalid || fixStrLen(c.bootCommands,  255);
	
	// Return check result.
	return bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the account system settings.
 *  $PARAM        c  The configuration that is to be checked.
 *  $REQUIRE      c  != none
 *  $RETURN       True if the configuration was valid, false otherwise.
 *
 **************************************************************************************************/
function bool checkAccountSystemSettings(NexgenConfig c) {
	local bool bInvalid;
	local int index;
	
	// Check account types.
	while(index < arrayCount(c.atTypeName) && c.atTypeName[index] != "") {
		bInvalid = bInvalid || fixStrLen(c.atTypeName[index],  24);
		bInvalid = bInvalid || fixStrLen(c.atRights[index],   255);
		bInvalid = bInvalid || fixStrLen(c.atTitle[index],     24);
		if (len(c.atPassword[index]) > 128) {
			c.atPassword[index] = "";
			bInvalid = true;
		}
		index++;
	}
	
	// Check user accounts.
	index = 0;
	while(index < arrayCount(c.paPlayerID) && c.paPlayerID[index] != "") {
		bInvalid = bInvalid || fixStrLen(c.paPlayerID[index],      32);
		bInvalid = bInvalid || fixStrLen(c.paPlayerName[index],    32);
		bInvalid = bInvalid || fixStrLen(c.paCustomRights[index], 255);
		bInvalid = bInvalid || fixStrLen(c.paCustomTitle[index],   24);
		if (c.get_paAccountType(index) < 0 && class'NexgenUtil'.static.trim(c.paCustomTitle[index]) == "") {
			bInvalid = true;
			c.paCustomTitle[index] = "Player*";
		}
		index++;
	}
	
	// Return check result.
	return bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the banlist.
 *  $PARAM        c  The configuration that is to be checked.
 *  $REQUIRE      c  != none
 *  $RETURN       True if the configuration was valid, false otherwise.
 *
 **************************************************************************************************/
function bool checkBanList(NexgenConfig c) {
	local bool bInvalid;
	local int index;
	
	while(index < arrayCount(c.bannedName) && c.bannedName[index] != "") {
		bInvalid = bInvalid || fixStrLen(c.bannedName[index],  32);
		bInvalid = bInvalid || fixStrLen(c.bannedIPs[index],  255);
		bInvalid = bInvalid || fixStrLen(c.bannedIDs[index],  255);
		bInvalid = bInvalid || fixStrLen(c.banReason[index],  255);
		bInvalid = bInvalid || fixStrLen(c.banPeriod[index],   32);
		index++;
	}
	
	// Return check result.
	return bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the match settings.
 *  $PARAM        c  The configuration that is to be checked.
 *  $REQUIRE      c  != none
 *  $RETURN       True if the configuration was valid, false otherwise.
 *
 **************************************************************************************************/
function bool checkMatchSettings(NexgenConfig c) {
	local bool bInvalid;
	local int index;
	
	bInvalid = bInvalid || fixByteRange(c.matchesToPlay, 1,             100);
	bInvalid = bInvalid || fixByteRange(c.currentMatch,  1, c.matchesToPlay);
	if (len(c.serverPassword) > 128) {
		c.serverPassword = "";
		bInvalid = true;
	}
	for (index = 0; index < arrayCount(c.tagsToSeparate); index++) {
		bInvalid = bInvalid || fixStrLen(c.tagsToSeparate[index], 16);
	}
	
	// Return check result.
	return bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks the log settings.
 *  $PARAM        c  The configuration that is to be checked.
 *  $REQUIRE      c  != none
 *  $RETURN       True if the configuration was valid, false otherwise.
 *
 **************************************************************************************************/
function bool checkLogSettings(NexgenConfig c) {
	local bool bInvalid;
	
	if (len(c.logPath) > 200) {
		c.logPath = "";
		bInvalid = true;
	}
	bInvalid = bInvalid || fixStrLen(c.logFileExtension, 10);
	bInvalid = bInvalid || fixStrLen(c.logFileNameFormat, 100);
	bInvalid = bInvalid || fixStrLen(c.logFileTimeStampFormat, 100);
	
	// Return check result.
	return bInvalid;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixes the length of a string. This function makes sure the length of a given
 *                string doesn't exceed the specified maximum length.
 *  $PARAM        str  The string of which the length has to be checked.
 *  $PARAM        maxLen  The maximum length of the string.
 *  $REQUIRE      maxLen >= 0
 *  $RETURN       True if the length of the string was changed, false otherwise.
 *  $ENSURE       len(new.str) <= maxLen
 *
 **************************************************************************************************/
function bool fixStrLen(out string str, int maxLen) {
	if (len(str) > maxLen) {
		str = left(str, maxLen);
		return true;
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixes the value of a given integer variable. Calling this function will ensure
 *                that the value of the variable will be in the specified domain.
 *  $PARAM        intVar      The integer variable whose value is to be checked.
 *  $PARAM        lowerBound  Lower bound on the range of the variable.
 *  $PARAM        upperBound  Upperbound bound on the range of the variable.
 *  $RETURN       True if value of the integer variable was changed, false otherwise.
 *  $ENSURE       lowerBound <= intVar && intVar <= upperBound
 *
 **************************************************************************************************/
function bool fixIntRange(out int intVar, int lowerBound, int upperBound) {
	if (intVar < lowerBound) {
		intVar = lowerBound;
		return true;
	} else if (intVar > upperBound) {
		intVar = upperBound;
		return true;
	} else {
		return false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixes the value of a given byte variable. Calling this function will ensure
 *                that the value of the variable will be in the specified domain.
 *  $PARAM        byteVar     The byte variable whose value is to be checked.
 *  $PARAM        lowerBound  Lower bound on the range of the variable.
 *  $PARAM        upperBound  Upperbound bound on the range of the variable.
 *  $RETURN       True if value of the byte variable was changed, false otherwise.
 *  $ENSURE       lowerBound <= byteVar && byteVar <= upperBound
 *
 **************************************************************************************************/
function bool fixByteRange(out byte byteVar, byte lowerBound, byte upperBound) {
	if (byteVar < lowerBound) {
		byteVar = lowerBound;
		return true;
	} else if (byteVar > upperBound) {
		byteVar = upperBound;
		return true;
	} else {
		return false;
	}
}