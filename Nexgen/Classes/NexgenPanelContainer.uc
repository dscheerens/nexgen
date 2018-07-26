/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPanelContainer
 *  $VERSION      1.04 (13-05-2010 20:11)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen control panel page container.
 *
 **************************************************************************************************/
class NexgenPanelContainer extends NexgenPanel;

var UWindowPageControl pages;           // Page control for panels added on this container.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the layout for this panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	super.created();
	
	pages = UWindowPageControl(createWindow(class'UWindowPageControl', 0, 0, winWidth - 2, winHeight - 3));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the panel with the specified name.
 *  $PARAM        panelName  Name of the panel that is to be returned.
 *  $REQUIRE      panelName != ""
 *  $RETURN       The panel that was requested or none if the panel wasn't found.
 *
 **************************************************************************************************/
function NexgenPanel getPanel(string panelName) {
	local UWindowPageControlPage pageControl;
	local NexgenPanel panel;
	local bool bFound;
	
	// Search for panel.
	pageControl = pages.firstPage();
	while (!bFound && pageControl != none) {
		panel = NexgenPanel(pageControl.page);
		
		// Is this the one we are looking for?
		if (panel != none) {
			if (panel.panelIdentifier ~= panelName) {
				// Yeah, stop looking and return result.
				bFound = true;
			} else if (panel.isA('NexgenPanelContainer')) {
				// No, but it is a panel container so it might contain the one we're looking for.
				panel = NexgenPanelContainer(panel).getPanel(panelName);
				bFound = panel != none;
			}
		}
		
		// Continue with next page if not found yet.
		if (!bFound) {
			pageControl = pageControl.nextPage();
		}
	}
	
	// Return result.
	if (bFound) {
		return panel;
	} else {
		return none;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new NexgenPanel to the container or one of its subcontainers. To specify
 *                a specific parent use the parent parameter to indicate the path, e.g.
 *                "plugin,settings". If an invalid path is specified the panel won't be created.
 *  $PARAM        title       Text to display in the tab header.
 *  $PARAM        panelClass  Type of NexgenPanel to add/create.
 *  $PARAM        identifier  Identifier to assign to the new panel.
 *  $PARAM        parent      Path where to the parent of the new panel.
 *  $REQUIRE      panelClass != none
 *  $RETURN       The panel that was created and added to the container, or none if an invalid path
 *                to the parent container was specified.
 *
 **************************************************************************************************/
function NexgenPanel addPanel(string title, class<NexgenPanel> panelClass,
                              optional string identifier, optional string parent) {
	local UWindowPageControlPage pageControl;
	local NexgenPanel newPanel;
	local string parentPanel;
	local string subPanels;
	local bool bFound;
	local NexgenPanelContainer container;
	
	// Add to subpanel?
	if (parent != "") {
		
		// Get local parent name.
		if (instr(parent, separator) > 0) {
			parentPanel = left(parent, instr(parent, separator));
			subPanels = mid(parent, instr(parent, separator) + 1);
		} else {
			parentPanel = parent;
		}
		
		// Locate local parent.
		pageControl = pages.firstPage();
		while (!bFound && pageControl != none) {
			container = NexgenPanelContainer(pageControl.page);
			if (container != none && container.panelIdentifier ~= parentPanel) {
				bFound = true;
			} else {
				pageControl = pageControl.nextPage();
			}
		}
		
		// Delegate action.
		if (bFound) {
			// NOTE: Recursion can be avoided here, but the performance gain is insignificant.
			newPanel = container.addPanel(title, panelClass, identifier, subPanels);
		}
		
	} else {
	
		// Create panel.
		pageControl = pages.addPage(title, panelClass);
		
		if (pageControl != none) {
			newPanel = NexgenPanel(pageControl.page);
			if (identifier != "") {
				newPanel.panelIdentifier = identifier;
			}
			newPanel.client = self.client;
			newPanel.setContent();
		}
	}
	
	// Return created panel.
	return newPanel;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Selects the panel with the specified name.
 *  $PARAM        panelName  The name of the panel that is to be selected.
 *  $RETURN       True if the panel was selected, false if it wasn't found.
 *
 **************************************************************************************************/
function bool selectPanel(string panelName) {
	local UWindowPageControlPage pageControl;
	local NexgenPanel panel;
	local bool bFound;
	
	pageControl = pages.firstPage();
	while (!bFound && pageControl != none) {
		panel = NexgenPanel(pageControl.page);
		
		// Check panel.
		if (panel.panelIdentifier ~= panelName) {
			// Panel found, select it.
			bFound = true;
		} else if (panel.isA('NexgenPanelContainer')) {
			// No, but page is a NexgenPanelContainer, so it may include the panel.
			bFound = NexgenPanelContainer(panel).selectPanel(panelName);
		}
		
		// Panel found?
		if (bFound) {
			// Panel found, select it.
			pages.gotoTab(pageControl, true);
		} else {
			// No, continue with next page.
			pageControl = pageControl.nextPage();
		}
	}
	
	return bFound;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the sub panels on this panel that the server configuration has been
 *                updated.
 *  $PARAM        configType  Type of settings that have been changed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function configChanged(byte configType) {
	local UWindowPageControlPage pageControl;
	
	for (pageControl = pages.firstPage(); pageControl != none; pageControl = pageControl.nextPage()) {
		if (NexgenPanel(pageControl.page) != none) {
			NexgenPanel(pageControl.page).configChanged(configType);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies this panel that the extended game info has been updated.
 *  $PARAM        infoType  Type of information that has been changed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function gameInfoChanged(byte infoType) {
	local UWindowPageControlPage pageControl;
	
	for (pageControl = pages.firstPage(); pageControl != none; pageControl = pageControl.nextPage()) {
		if (NexgenPanel(pageControl.page) != none) {
			NexgenPanel(pageControl.page).gameInfoChanged(infoType);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client of a player event. Additional arguments to the event should be
 *                combined into one string which then can be send along with the playerEvent call.
 *  $PARAM        playerNum  Player identification number.
 *  $PARAM        eventType  Type of event that has occurred.
 *  $PARAM        args       Optional arguments.
 *  $REQUIRE      playerNum >= 0
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerEvent(int playerNum, string eventType, optional string args) {
	local UWindowPageControlPage pageControl;
	
	for (pageControl = pages.firstPage(); pageControl != none; pageControl = pageControl.nextPage()) {
		if (NexgenPanel(pageControl.page) != none) {
			NexgenPanel(pageControl.page).playerEvent(playerNum, eventType, args);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notifyEvent(string type, optional string arguments) {
	local UWindowPageControlPage pageControl;
	
	for (pageControl = pages.firstPage(); pageControl != none; pageControl = pageControl.nextPage()) {
		if (NexgenPanel(pageControl.page) != none) {
			NexgenPanel(pageControl.page).notifyEvent(type, arguments);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *  $OVERRIDE
 *
 **************************************************************************************************/
function varChanged(NexgenSharedDataContainer container, string varName, optional int index) {
	local UWindowPageControlPage pageControl;
	
	for (pageControl = pages.firstPage(); pageControl != none; pageControl = pageControl.nextPage()) {
		if (NexgenPanel(pageControl.page) != none) {
			NexgenPanel(pageControl.page).varChanged(container, varName, index);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization of the given shared data container is
 *                done. After this has happend the client may query its variables and receive valid
 *                results (assuming the client is allowed to read those variables).
 *  $PARAM        container  The shared data container that has become available for use.
 *  $REQUIRE      container != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function dataContainerAvailable(NexgenSharedDataContainer container) {
	local UWindowPageControlPage pageControl;
	
	for (pageControl = pages.firstPage(); pageControl != none; pageControl = pageControl.nextPage()) {
		if (NexgenPanel(pageControl.page) != none) {
			NexgenPanel(pageControl.page).dataContainerAvailable(container);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization by the given synchronization manager is
 *                done. This means all the data containers in the ynchronization manager are ready
 *                to be queried.
 *  $PARAM        dataSyncMgr  The shared data synchronization manager whose containers were initialized.
 *  $REQUIRE      dataSyncMgr != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function sharedDataInitComplete(NexgenSharedDataSyncManager dataSyncMgr) {
	local UWindowPageControlPage pageControl;
	
	for (pageControl = pages.firstPage(); pageControl != none; pageControl = pageControl.nextPage()) {
		if (NexgenPanel(pageControl.page) != none) {
			NexgenPanel(pageControl.page).sharedDataInitComplete(dataSyncMgr);
		}
	}
}

