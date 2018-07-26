/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenMainPanel
 *  $VERSION      1.01 (3-3-2007 17:01)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen control panel root.
 *
 **************************************************************************************************/
class NexgenMainPanel extends NexgenPanelContainer;

const barHeight = 22;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the layout for this panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	super(NexgenPanel).created();
	
	pages = UWindowPageControl(createWindow(class'UWindowPageControl', 0, 0, winWidth, winHeight - barHeight - 3));
	createWindow(class'NexgenMainPanelBar', 0, winHeight - barHeight - 3, winWidth, barHeight);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the window that a new level is going to be loaded.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notifyBeforeLevelChange() {
	super.notifyBeforeLevelChange();

	close();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Closes the dialog.
 *  $PARAM        bByParent  The close call was issued by the parent of the dialog.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function close(optional bool bByParent) {
	local UWindowRootWindow rootWin;
	local UWindowWindow win;
	local bool bWindowVisible;
	
	// Check if there is another visible window.
	rootWin = WindowConsole(getPlayerOwner().player.console).root;
	if (rootWin != none) {
		win = rootWin.firstChildWindow;
		while (!bWindowVisible && win != none) {
			// Current window visible?
			bWindowVisible = win != parentWindow && win.windowIsVisible() && win.bLeaveOnscreen;
			
			// Continue with next window.
			win = win.nextSiblingWindow;
		}
	}
	
	// Close the window.
	if (!bWindowVisible) {
		WindowConsole(getPlayerOwner().player.console).closeUWindow();
	}
	super.close(bByParent);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="main"
}