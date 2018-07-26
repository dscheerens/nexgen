/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPAbout
 *  $VERSION      1.00 (10-3-2007 21:20)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen about control panel page.
 *
 **************************************************************************************************/
class NexgenRCPAbout extends NexgenPanel;

#exec TEXTURE IMPORT NAME=logo FILE=Resources\logo.pcx GROUP="GFX" FLAGS=1 MIPS=Off



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	
	// Create layout & add components.
	createWindowRootRegion();
	divideRegionV(2);
	addImageBox(Texture'logo');
	divideRegionH(18);
	skipRegion();
	addLabel("Nexgen Server Controller", true, TA_Center);
	addLabel("version" @ left(class'NexgenUtil'.default.version, 4) @
	         "build" @ class'NexgenUtil'.default.internalVersion, , TA_Center);
	addLabel("Copyright © 2006-2011 Zeropoint productions", , TA_Center);
	addLabel("d.scheerens@gmail.com", , TA_Center);
	skipRegion();
	addLabel("Development", true, TA_Center);
	addLabel("Daan \"Defrost\" Scheerens", , TA_Center);
	skipRegion();
	addLabel("Credits and thanks to", true, TA_Center);
	addLabel("Mickaël \"ATHoS\" DEHEZ", , TA_Center);
	addLabel("Matthew \"MSuLL\" Sullivan", , TA_Center);
	addLabel("David \"The_Dave\" Schwartzstein", , TA_Center);
	addLabel("Zohar \"SuB\" Zada", , TA_Center);
	addLabel("*TNT*CryptKeeper", , TA_Center);
	addLabel("[BOSS]Snipes", , TA_Center);
	addLabel("AnthraX", , TA_Center);
	skipRegion();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="about"
}
