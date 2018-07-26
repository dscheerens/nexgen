/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenMainFrame
 *  $VERSION      1.01 (08-09-2010 17:07)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen GUI main window class. Defines the frame for the Nexgen main window.
 *
 **************************************************************************************************/
class NexgenMainFrame extends UMenuFramedWindow;

var float windowWidth;                  // Width of the main window frame (in pixels).
var float windowHeight;                 // Height of the main window frame (in pixels).
var NexgenMainPanel mainPanel;          // Control panel root.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Makes sure the main frame is properly setup.
 *  $ENSURE       mainPanel != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	super.created();
	windowTitle = "Nexgen Server Controller v" $ left(class'NexgenUtil'.default.version, 4);
	clientArea = createWindow(class'NexgenMainPanel', 4, 16, winWidth - 4, winHeight - 16);
	mainPanel = NexgenMainPanel(clientArea);
	bLeaveOnScreen = true;
	bMoving = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the window was activated.
 *
 **************************************************************************************************/
function activated() {
	// Check if this window is an instance from the previous game.
	if (mainPanel.client.player != getPlayerOwner()) {
		// Yes it is, hide this window.
		bLeaveOnscreen = false;
		mainPanel.close();
	} else {
		super.activated();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	windowWidth=550.0
	windowHeight=370.0
}