/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenRCPClientConfig
 *  $VERSION      1.06 (8-3-2008 22:13)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen client settings control panel page.
 *
 **************************************************************************************************/
class NexgenRCPClientConfig extends NexgenPanel;

var UWindowCheckbox enableNexgenHUDInp;
var UWindowCheckbox useMsgFlashEffectInp;
var UWindowCheckbox showPlayerLocationInp;
var UWindowCheckbox playPMSoundInp;
var UWindowCheckbox autoSSNormalGameInp;
var UWindowCheckbox autoSSMatchInp;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
	local NexgenContentPanel p;
	local int index;	
	
	// Create layout & add components.
	setAcceptsFocus();
	createPanelRootRegion(); //createWindowRootRegion();
	splitRegionV(196, defaultComponentDist);
	
	// Keybindings.
    addSubPanel(class'NexgenCPKeyBind');
	
	// User Interface settings.
	splitRegionH(96, defaultComponentDist);
	p = addContentPanel();
	p.splitRegionH(16);
	p.addLabel(client.lng.UISettingsTxt, true, TA_Center);
	p.divideRegionH(4);
	enableNexgenHUDInp = p.addCheckBox(TA_Left, client.lng.enableMsgHUDTxt);
	useMsgFlashEffectInp = p.addCheckBox(TA_Left, client.lng.msgFlashEffectTxt);
	showPlayerLocationInp = p.addCheckBox(TA_Left, client.lng.showPlayerLocationTxt);
	playPMSoundInp = p.addCheckBox(TA_Left, client.lng.pmSoundTxt);
	
	// Other stuff.
	splitRegionH(64, defaultComponentDist);
	p = addContentPanel();
	p.splitRegionH(16);
	p.addLabel(client.lng.miscSettingsTxt, true, TA_Center);
	p.divideRegionH(2);
	autoSSNormalGameInp = p.addCheckBox(TA_Left, client.lng.autoSSNormalGameTxt);
	autoSSMatchInp = p.addCheckBox(TA_Left, client.lng.autoSSMatchTxt);
	
	// Configure components.
	enableNexgenHUDInp.register(self);
	useMsgFlashEffectInp.register(self);
	showPlayerLocationInp.register(self);
	playPMSoundInp.register(self);
	autoSSNormalGameInp.register(self);
	autoSSMatchInp.register(self);

	enableNexgenHUDInp.bChecked = client.gc.get(client.SSTR_UseNexgenHUD, "true") ~= "true";
	useMsgFlashEffectInp.bChecked = client.gc.get(client.SSTR_FlashMessages, "false") ~= "true";
	showPlayerLocationInp.bChecked = client.gc.get(client.SSTR_ShowPlayerLocation, "true") ~= "true";
	playPMSoundInp.bChecked = client.gc.get(client.SSTR_PlayPMSound, "true") ~= "true";
	autoSSNormalGameInp.bChecked = client.gc.get(client.SSTR_AutoSSNormalGame, "false") ~= "true";
	autoSSMatchInp.bChecked = client.gc.get(client.SSTR_AutoSSMatch, "true") ~= "true";

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
	
	// Toggle Nexgen HUD on/off.
	if (control == enableNexgenHUDInp && eventType == DE_Click) {
		// Save setting.
		client.gc.set(client.SSTR_UseNexgenHUD, string(enableNexgenHUDInp.bChecked));
		client.gc.saveConfig();
		
		// Apply setting.
		client.setNexgenMessageHUD(enableNexgenHUDInp.bChecked);
	}
	
	// Toggle message flash effect on/off.
	if (control == useMsgFlashEffectInp && eventType == DE_Click) {
		// Save setting.
		client.gc.set(client.SSTR_FlashMessages, string(useMsgFlashEffectInp.bChecked));
		client.gc.saveConfig();
		
		// Apply setting.
		client.nscHUD.bFlashMessages = useMsgFlashEffectInp.bChecked;
	}
	
	
	// Toggle show player location in teamsay messages on/off.
	if (control == showPlayerLocationInp && eventType == DE_Click) {
		// Save setting.
		client.gc.set(client.SSTR_ShowPlayerLocation, string(showPlayerLocationInp.bChecked));
		client.gc.saveConfig();
		
		// Apply setting.
		client.nscHUD.bShowPlayerLocation = showPlayerLocationInp.bChecked;
	}
	
	// Toggle private message sound on/off.
	if (control == playPMSoundInp && eventType == DE_Click) {
		// Save setting.
		client.gc.set(client.SSTR_PlayPMSound, string(playPMSoundInp.bChecked));
		client.gc.saveConfig();
	}
	
	// Toggle auto screenshot for normal games on/off.
	if (control == autoSSNormalGameInp && eventType == DE_Click) {
		// Save setting.
		client.gc.set(client.SSTR_AutoSSNormalGame, string(autoSSNormalGameInp.bChecked));
		client.gc.saveConfig();
	}
	
	// Toggle auto screenshot for matches on/off.
	if (control == autoSSMatchInp && eventType == DE_Click) {
		// Save setting.
		client.gc.set(client.SSTR_AutoSSMatch, string(autoSSMatchInp.bChecked));
		client.gc.saveConfig();
	}
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="clientsettings"
	panelHeight=240
}

