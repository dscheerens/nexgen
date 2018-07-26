/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPServerInfo
 *  $VERSION      1.01 (10-11-2007 19:10)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen server info control panel page.
 *
 **************************************************************************************************/
class NexgenRCPServerInfo extends NexgenPanel;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local GameReplicationInfo GRI;
	local TournamentGameReplicationInfo TGRI;
	local NexgenContentPanel p;
	
	GRI = client.player.gameReplicationInfo;
	TGRI = TournamentGameReplicationInfo(GRI);
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionH(32, defaultComponentDist);
	
	// Title.
	p = addContentPanel();
	p.addLabel(GRI.serverName, true, TA_Center);
	
	// Contact info.
	splitRegionH(128, defaultComponentDist);
	p = addContentPanel();
	p.splitRegionV(128);
	p.divideRegionH(7);
	p.divideRegionH(7);
	p.addLabel(client.lng.administratorTxt, true);
	p.addLabel(client.lng.contactAddrTxt, true);
	p.addLabel(client.lng.msgOfTheDayTxt, true);
	p.skipRegion();
	p.skipRegion();
	p.skipRegion();
	p.addLabel(client.lng.serverIDTxt, true);
	p.addLabel(fixStr(GRI.adminName));
	p.addLabel(fixStr(GRI.adminEmail));
	p.addLabel(fixStr(GRI.MOTDLine1));
	p.addLabel(fixStr(GRI.MOTDLine2));
	p.addLabel(fixStr(GRI.MOTDLine3));
	p.addLabel(fixStr(GRI.MOTDLine4));
	p.addLabel(class'NexgenUtil'.static.formatGUID(client.serverID));
	
	// Server game stats.
	if (TGRI != none) {
		splitRegionV(160, defaultComponentDist);
		
		// Server stats.
		p = addContentPanel();
		p.splitRegionH(20, , true);
		p.addLabel(client.lng.statisticsTxt, true, TA_Center);
		p.splitRegionV(100);
		p.divideRegionH(4);
		p.divideRegionH(4);
		p.addLabel(client.lng.totalGamesTxt, true);
		p.addLabel(client.lng.totalFragsTxt, true);
		p.addLabel(client.lng.totalDeathsTxt, true);
		p.addLabel(client.lng.totalFlagsTxt, true);
		p.addLabel(TGRI.totalGames);
		p.addLabel(TGRI.totalFrags);
		p.addLabel(TGRI.totalDeaths);
		p.addLabel(TGRI.totalFlags);
		
		// Top players.
		p = addContentPanel();
		p.splitRegionH(20, , true);
		p.addLabel(client.lng.bestPlayersTxt, true, TA_Center);
		p.splitRegionV(160, , , true);
		p.divideRegionH(4);
		p.splitRegionV(48);
		p.addLabel(client.lng.playerNameTxt, true);
		p.addLabel(fixStr(TGRI.bestPlayers[0]));
		p.addLabel(fixStr(TGRI.bestPlayers[1]));
		p.addLabel(fixStr(TGRI.bestPlayers[2]));
		p.divideRegionH(4);
		p.divideRegionH(4);
		p.addLabel(client.lng.FPHTxt, true);
		p.addLabel(TGRI.bestFPHs[0]);
		p.addLabel(TGRI.bestFPHs[1]);
		p.addLabel(TGRI.bestFPHs[2]);
		p.addLabel(client.lng.recordSetTxt, true);
		p.addLabel(fixStr(TGRI.bestRecordDate[0]));
		p.addLabel(fixStr(TGRI.bestRecordDate[1]));
		p.addLabel(fixStr(TGRI.bestRecordDate[2]));
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Makes sure a non empty string is returned.
 *
 **************************************************************************************************/
static function string fixStr(coerce string str) {
	if (class'NexgenUtil'.static.trim(str) == "") {
		return "-";
	} else {
		return str;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="serverinfo"
}
