/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPopupFrame
 *  $VERSION      1.03 (8-3-2008 16:12)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen GUI popup window class. An instance of this class defines the frame for a
 *                popup window.
 *
 **************************************************************************************************/
class NexgenPopupFrame extends UMenuFramedWindow;

var float windowWidth;        // Width of the popup window frame (in pixels).
var float windowHeight;       // Height of the popup window frame (in pixels).

var NexgenClient client;      // Nexgen client instance.
var GeneralConfig gc;         // General client configuration.
var ServerConfig sc;          // Server specific client configuration.
var string serverID;          // Identification code of the server where has been connected to.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Makes sure the popup frame will be properly setup.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	super.created();
	windowTitle = "Nexgen Server Controller v" $ left(class'NexgenUtil'.default.version, 4);
	bLeaveOnScreen = true;
	bMoving = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the contents of the popup window.
 *  $PARAM        popupClass  The dialog class used for the contents of the popup frame.
 *  $PARAM        str1        Dialog specific content data.
 *  $PARAM        str2        Dialog specific content data. 
 *  $PARAM        str3        Dialog specific content data.
 *  $PARAM        str4        Dialog specific content data.
 *  $REQUIRE      the specified popup class exists and is a subclass of NexgenPopupDialog
 *
 **************************************************************************************************/
function showPopup(string popupClass, optional string str1, optional string str2, optional string str3, optional string str4) {
	local NexgenPopupDialog dialog;
	local Class<NexgenPopupDialog> dialogClass;
	
	// Get the object class.
	if (instr(popupClass, ".") < 0) {
		popupClass = class'NexgenUtil'.default.packageName $ "." $ popupClass;
	}
	dialogClass = class<NexgenPopupDialog>(DynamicLoadObject(popupClass, class'Class'));
	
	// Set popup contents.
	dialog = NexgenPopupDialog(createWindow(dialogClass, 4, 16, winWidth - 4, winHeight - 16));
	dialog.gc = gc;
	dialog.sc = sc;
	dialog.serverID = serverID;
	dialog.client = client;
	dialog.setContent(str1, str2, str3, str4);
	clientArea = dialog;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	windowWidth=400.0
	windowHeight=200.0
}

