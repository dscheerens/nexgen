/***************************************************************************************************
 *
 *  IGSRVEXT. IG Generation 3 server extension by Zeropoint.
 *
 *  $CLASS        IGSXRCPServerInfo
 *  $VERSION      1.00 (21-3-2008 23:27)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  IG server information panel page.
 *
 **************************************************************************************************/
class IGSXRCPServerInfo extends NexgenPanel;

#exec TEXTURE IMPORT NAME=serverbanner FILE=Resources\IG3Banner.pcx GROUP="GFX" FLAGS=1 MIPS=Off



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
	local int region;
	
	GRI = client.player.gameReplicationInfo;
	TGRI = TournamentGameReplicationInfo(GRI);
	
	// Create layout & add components.
	createWindowRootRegion();
	splitRegionH(66, defaultComponentDist);
	splitRegionV(258, defaultComponentDist);
	region = currRegion; skipRegion();
	addImageBox(Texture'serverbanner');
	
	// Admin contact.
	p = addContentPanel();
	p.divideRegionH(4);
	p.addLabel("Server administrators", true, TA_Center);
	p.splitRegionV(48);
	p.splitRegionV(48);
	p.splitRegionV(48);
	p.addLabel("Defrost", true); p.addLabel("d.scheerens@gmail.com");
	p.addLabel("SuB", true);     p.addLabel("substa@hotmail.com");
	p.addLabel("GF-REX", true);  p.addLabel("rocko_h@hotmail.com");
	
	// Server info.
	selectRegion(region);
	p = addContentPanel();
	p.splitRegionH(16);
	p.addLabel("Server information", true, TA_Center);
	p.splitRegionV(192);
	p.divideRegionH(11);
	p.divideRegionH(11);
	p.addLabel("Server name", true);
	p.addLabel("Server address", true);
	p.addLabel("Server ID", true);
	p.skipRegion();
	p.addLabel("Number of games hosted", true);
	p.skipRegion();
	p.addLabel("Server type", true);
	p.addLabel("Location", true);
	p.addLabel("Processor", true);
	p.addLabel("Memory", true);
	p.addLabel("Connection (U/D)", true);
	
	p.addLabel(GRI.serverName);
	p.addLabel("unreal://130.89.163.70:7700/");
	p.addLabel(class'NexgenUtil'.static.formatGUID(client.serverID));
	p.skipRegion();
	if (TGRI != none) { p.addLabel(TGRI.totalGames); } else  { p.skipRegion(); }
	p.skipRegion();
	p.addLabel("Privately owned dedicated server");
	p.addLabel("Enschede, The Netherlands");
	p.addLabel("Intel® Pentium® IV HT (Northwood) @ 3066 MHz");
	p.addLabel("1024 MB DDR-333");
	p.addLabel("100/100 (MBit)");
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="about"
}
