/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPClientConfigRCP
 *  $VERSION      1.00 (7-12-2008 14:08)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen Plus client settings control panel page.
 *
 **************************************************************************************************/
class NXPClientConfigRCP extends NexgenPanel;

var NXPClient xClient;                            // Client controller interface.

var UWindowCheckbox enableStartAnnouncerInp;
var UWindowCheckbox showPingStatusBoxInp;
var UWindowCheckbox showTimeStatusBoxInp;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	// Retrieve client controller interface.
	xClient = NXPClient(client.getController(class'NXPClient'.default.ctrlID));
	
	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(12);
	addLabel(xClient.lng.clientConfigTitle, true, TA_Center);
	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');
	
	splitRegionV(65, , true);
	divideRegionH(3);
	divideRegionH(3);
	addLabel(xClient.lng.enableStartAnnouncerTxt, true, TA_Left);
	addLabel(xClient.lng.showPingStatusBoxTxt, true, TA_Left);
	addLabel(xClient.lng.showTimeStatusBoxTxt, true, TA_Left);
	enableStartAnnouncerInp = addCheckBox(TA_Right);
	showPingStatusBoxInp = addCheckBox(TA_Right);
	showTimeStatusBoxInp = addCheckBox(TA_Right);
	
	// Configure components.
	enableStartAnnouncerInp.register(self);
	showPingStatusBoxInp.register(self);
	showTimeStatusBoxInp.register(self);
	enableStartAnnouncerInp.bChecked = client.gc.get(xClient.SSTR_EnableStartAnnouncer, xClient.SSTRDV_EnableStartAnnouncer) ~= "true";
	showPingStatusBoxInp.bChecked = client.gc.get(xClient.SSTR_ShowPingStatusBox, xClient.SSTRDV_ShowPingStatusBox) ~= "true";
	showTimeStatusBoxInp.bChecked = client.gc.get(xClient.SSTR_ShowTimeStatusBox, xClient.SSTRDV_ShowTimeStatusBox) ~= "true";
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType) {
	super.notify(control, eventType);
	
	// Toggle game start announcer on/off.
	if (control == enableStartAnnouncerInp && eventType == DE_Click) {
		// Save setting.
		client.gc.set(xClient.SSTR_EnableStartAnnouncer, string(enableStartAnnouncerInp.bChecked));
		client.gc.saveConfig();
		
		// Apply setting.
		xClient.bEnableStartAnnouncer = enableStartAnnouncerInp.bChecked;
	}
	
	// Toggle ping box display on/off.
	if (control == showPingStatusBoxInp && eventType == DE_Click) {
		// Save setting.
		client.gc.set(xClient.SSTR_ShowPingStatusBox, string(showPingStatusBoxInp.bChecked));
		client.gc.saveConfig();
		
		// Apply setting.
		xClient.xHUD.bShowPingBox = showPingStatusBoxInp.bChecked;
	}
	
	// Toggle time box display on/off.
	if (control == showTimeStatusBoxInp && eventType == DE_Click) {
		// Save setting.
		client.gc.set(xClient.SSTR_ShowTimeStatusBox, string(showTimeStatusBoxInp.bChecked));
		client.gc.saveConfig();
		
		// Apply setting.
		xClient.xHUD.bShowTimeBox = showTimeStatusBoxInp.bChecked;
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="nexgenplusclientsettings"
	panelHeight=80
}