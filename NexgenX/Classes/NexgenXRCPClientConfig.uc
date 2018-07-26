/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXRCPClientConfig
 *  $VERSION      1.00 (7-12-2008 14:08)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  NexgenX client settings control panel page.
 *
 **************************************************************************************************/
class NexgenXRCPClientConfig extends NexgenPanel;

var NexgenXClient xClient;

var UWindowCheckbox showPingStatusBoxInp;
var UWindowCheckbox showTimeStatusBoxInp;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	
	xClient = NexgenXClient(client.getController(class'NexgenXClient'.default.ctrlID));
	
	// Create layout & add components.
	createPanelRootRegion();
	
	splitRegionH(12);
	addLabel(xClient.lng.clientConfigTitle, true, TA_Center);
	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');
	
	divideRegionV(2, defaultComponentDist);
	divideRegionH(2);
	divideRegionH(2);
	showPingStatusBoxInp = addCheckBox(TA_Left, xClient.lng.showPingStatusBoxTxt, true);
	showTimeStatusBoxInp = addCheckBox(TA_Left, xClient.lng.showTimeStatusBoxTxt, true);
	
	// Configure components.
	showPingStatusBoxInp.register(self);
	showTimeStatusBoxInp.register(self);
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
	panelIdentifier="nexgenxclientsettings"
	panelHeight=64
}
