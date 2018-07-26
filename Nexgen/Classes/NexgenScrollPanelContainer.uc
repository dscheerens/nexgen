/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenScrollPanelContainer
 *  $VERSION      1.03 (13-05-2010 20:11)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen control panel page container scroll version.
 *
 **************************************************************************************************/
class NexgenScrollPanelContainer extends NexgenPanelContainer;

var UWindowPageWindow clientArea;       // Scrollable window.
var UWindowVScrollBar scrollBar;        // Vertical scrollbar control.

var NexgenPanel panels[32];             // Panels displayed on this panel.
var int numPanels;                      // Number of panels displayed.
var float clientAreaDesiredHeight;      // Desired height of the client area.
var float nextPanelOffset;              // Next vertical offset on the client area.

const panelDistance = 4.0;              // Distance between panels.
const borderDistance = 6.0;             // Disatnce between panels and the border of the client area.
const defaultPanelHeight = 288.0;       // Default height of panels displayed on the client area.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the layout for this panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	super(NexgenPanel).created();
	
	clientArea = UWindowPageWindow(createWindow(class'UWindowPageWindow', 0, 0, winWidth - 16, winHeight - 6, ownerWindow));
	
    scrollBar = UWindowVScrollbar(createWindow(class'UWindowVScrollbar', winWidth - 16, 0, 12, winHeight - 6));
    scrollBar.bAlwaysOnTop = true;
    
    clientAreaDesiredHeight = 2 * borderDistance;
    nextPanelOffset = borderDistance;
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Prepares the window for the paint call.
 *  $PARAM        c  The canvas object which acts as a drawing surface for the dialog.
 *  $PARAM        x  Unknown.
 *  $PARAM        y  Unknown.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function beforePaint(Canvas c, float x, float y) {
	local float clientWidth, clientHeight;
	local bool bNeedScrollBar;

	clientWidth = winWidth - 12;
	clientHeight = clientAreaDesiredHeight;
	if (clientHeight <= winHeight) {
		clientHeight = winHeight;
	} else {
		bNeedScrollBar = true;
	}
	
	clientArea.setSize(clientWidth, clientHeight);
	
	if (bNeedScrollBar) {
		scrollBar.setRange(0, clientHeight, scrollBar.winHeight, 10);
	} else {
		scrollBar.setRange(0, 0, 0, 0);
		scrollBar.pos = 0; 
	}
	
	clientArea.winTop = -scrollBar.pos;
	
	super.beforePaint(c, x, y);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the desired window dimensions.
 *  $PARAM        w  The desired width.
 *  $PARAM        h  The desired height.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function getDesiredDimensions(out float w, out float h){   
	super(UWindowWindow).getDesiredDimensions(w, h);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the GUI component.
 *  $PARAM        c  The canvas object which acts as a drawing surface for the dialog.
 *  $PARAM        x  Unknown.
 *  $PARAM        y  Unknown.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function paint(Canvas c, float x, float y) {
	// Ignore.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the panel with the specified name.
 *  $PARAM        panelName  Name of the panel that is to be returned.
 *  $REQUIRE      panelName != ""
 *  $RETURN       The panel that was requested or none if the panel wasn't found.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function NexgenPanel getPanel(string panelName) {
	local NexgenPanel panel;
	local int index;
	
	// Search for panel.
	while (panel == none && index < numPanels) {
		if (panels[index].panelIdentifier ~= panelName) {
			panel = panels[index];
		} else if (panels[index].isA('NexgenPanelContainer')) {
			panel = NexgenPanelContainer(panels[index]).getPanel(panelName);
		}
		index++;
	}
	
	// Return result.
	return panel;
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
 *  $OVERRIDE
 *
 **************************************************************************************************/
function NexgenPanel addPanel(string title, class<NexgenPanel> panelClass,
                              optional string identifier, optional string parent) {
	local NexgenPanel newPanel;
	local string parentPanel;
	local string subPanels;
	local NexgenPanelContainer container;
	local bool bFound;
	local int index;
	local float desiredPanelHeight;
	
	
	// Add to subpanel?
	if (parent != "") {
		
		// Get local parent name.
		class'NexgenUtil'.static.split(parent, parentPanel, subPanels);
		
		// Locate local parent.
		while (!bFound && index < numPanels) {
			if (panels[index].isA('NexgenPanelContainer') &&
			    NexgenPanelContainer(panels[index]).panelIdentifier ~= parentPanel ) {
				bFound = true;
				newPanel = NexgenPanelContainer(panels[index]).addPanel(title, panelClass, identifier, subPanels);
			} else {
				index++;
			}
		}
		
	} else {
		
		// Nope, add it to the scroll panel.
		if (numPanels < arrayCount(panels)) {
			
			// Determine panel height.
			desiredPanelHeight = panelClass.default.panelHeight;
			if (desiredPanelHeight <= 0) {
				desiredPanelHeight = defaultPanelHeight;
			}
			
			// Create control.
			newPanel = NexgenPanel(clientArea.createWindow(panelClass, borderDistance, nextPanelOffset, clientArea.winWidth - 2 * borderDistance, desiredPanelHeight));
			panels[numPanels] = newPanel;
			if (identifier != "") {
				newPanel.panelIdentifier = identifier;
			}
			newPanel.client = self.client;
			newPanel.setContent();
			
			// Update client area metrics.
			clientAreaDesiredHeight += desiredPanelHeight;
			if (numPanels > 0) {
				clientAreaDesiredHeight += panelDistance;
			}
			nextPanelOffset += desiredPanelHeight + panelDistance;
			
			numPanels++;
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
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool selectPanel(string panelName) {
	local int index;
	local bool bFound;
	
	while (!bFound && index < numPanels) {
		
		// Check panel.
		if (panels[index].panelIdentifier ~= panelName) {
			// Panel found, select it.
			bFound = true;
		} else if (panels[index].isA('NexgenPanelContainer')) {
			// No, but page is a NexgenPanelContainer, so it may include the panel.
			bFound = NexgenPanelContainer(panels[index]).selectPanel(panelName);
		}
		
		// Panel found?
		if (bFound) {
			// Panel found, select it.
			scrollBar.pos = panels[index].winTop;
		} else {
			// No, continue with next page.
			index++;
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
	local int index;
	
	for (index = 0; index < numPanels; index++) {
		panels[index].configChanged(configType);
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
	local int index;
	
	for (index = 0; index < numPanels; index++) {
		panels[index].gameInfoChanged(infoType);
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
	local int index;
	
	for (index = 0; index < numPanels; index++) {
		panels[index].playerEvent(playerNum, eventType, args);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *
 **************************************************************************************************/
function notifyEvent(string type, optional string arguments) {
	local int index;
	
	for (index = 0; index < numPanels; index++) {
		panels[index].notifyEvent(type, arguments);
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
	local int panelIndex;
	
	for (panelIndex = 0; panelIndex < numPanels; panelIndex++) {
		panels[panelIndex].varChanged(container, varName, index);
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
	local int panelIndex;
	
	for (panelIndex = 0; panelIndex < numPanels; panelIndex++) {
		panels[panelIndex].dataContainerAvailable(container);
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
	local int panelIndex;
	
	for (panelIndex = 0; panelIndex < numPanels; panelIndex++) {
		panels[panelIndex].sharedDataInitComplete(dataSyncMgr);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically reorders the panels within this scroll panel container.
 *
 **************************************************************************************************/
function updateClientArea() {
	local int index;
	local float desiredPanelHeight;
	
	// Set initial metrics.
	clientAreaDesiredHeight = 2 * borderDistance;
	nextPanelOffset = borderDistance;
	
	// Update metrics for each panel.
	for (index = 0; index < numPanels; index++) {
		// Get desired panel height for the panel.
		desiredPanelHeight = panels[index].panelHeight;
		if (desiredPanelHeight <= 0) {
			desiredPanelHeight = defaultPanelHeight;
		}
		
		// Update panel top and height.
		panels[index].winTop = nextPanelOffset;
		panels[index].winHeight = desiredPanelHeight;
		
		// Update client area metrics.
		clientAreaDesiredHeight += desiredPanelHeight;
		if (index > 0) {
			clientAreaDesiredHeight += panelDistance;
		}
		nextPanelOffset += desiredPanelHeight + panelDistance;
	}
	
	// Update scrollbar position if necessary.
	if (clientAreaDesiredHeight < winHeight) {
		scrollBar.pos = 0;
	} else {
		scrollBar.pos = fclamp(scrollBar.pos, 0, clientAreaDesiredHeight);
	}
}

