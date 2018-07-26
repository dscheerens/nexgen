/***************************************************************************************************
 *
 *  Nexgen Plus extension package by Zeropoint.
 *
 *  $CLASS        NXPServerFullDialog
 *  $VERSION      1.01 (06-09-2010 21:06)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the server is full. 
 *
 **************************************************************************************************/
class NXPServerFullDialog extends NexgenPopupDialog;

var UWindowSmallButton reconnectButton;           // Reconnect button component.
var UWindowSmallButton spectatorButton;           // Spectator button component.
var UMenuLabelControl slotLabel;                  // Slot label component.

var localized string caption;                     // Caption to display on the dialog.
var localized string message;                     // Caption to display on the dialog.
var localized string reconnectText;               // Text to display on the reconnect button.
var localized string spectatorText;               // Text to display on the spectator button.

var float nextVOffset;                            // Next vertical offset in the dialog.

var int numServers;                               // Number of servers to connect to.
var UWindowSmallButton serverButton[3];           // Server button components.
var string serverURL[3];                          // Server URLs.

const SSTR_OverrideClass = "OverrideClass";       // Override class setting string.
const openCommand = "Open";                       // Console command for opening an URL.
const reconnectCommand = "Reconnect";             // Console command for reconnecting.
const spectatorClass = "Botpack.CHSpectator";     // Override class to use for spectators.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
 *  $ENSURE       reconnectButton != none && spectatorButton != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	local float cy;
	
	super.created();
	
	// Add components.
	cy = borderSize;
	
	addText(caption, cy, F_Bold, TA_Center);
	addNewLine(cy);
	addText(message, cy, F_Normal, TA_Left);
	
	nextVOffset = cy;
	
	spectatorButton = addButton(spectatorText, 64.0);
	reconnectButton = addButton(reconnectText, 64.0);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this dialog.
 *  $PARAM        server1  Alternate server 1.
 *  $PARAM        server2  Alternate server 2.
 *  $PARAM        server3  Alternate server 3.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent(optional string server1, optional string server2, optional string server3, optional string arg4) {
	local float cy;
	
	cy = nextVOffset;
	
	if (server3 == "") addNewLine(cy);
	addServer(server1, cy);
	addServer(server2, cy);
	addServer(server3, cy);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new alternate server button to the dialog.
 *  $PARAM        server  Server description string, composed of the server title and url, which are
 *                        separated by a comma.
 *  $PARAM        cy      Vertical offset on the dialog where the server link is to be added.
 *  $REQUIRE      cy >= 0
 *
 **************************************************************************************************/
function addServer(string server, out float cy) {
	local float cx, cw, ch;
	local string buttonText;
	local string url;
	local UMenuLabelControl urlLabel;
	
	if (server != "" && numServers < arrayCount(serverButton)) {
		class'NexgenUtil'.static.split(server, buttonText, url);
		
		if (buttonText != "" && url != "") {
			cx = borderSize;
			cw = 128;
			ch = buttonHeight;
			
			serverButton[numServers] = UWindowSmallButton(createControl(class'UWindowSmallButton', cx, cy, cw, ch));
			
			cx += buttonSpace + cw;
			cw = winWidth - cx - borderSize;
			urlLabel = UMenuLabelControl(createControl(class'UMenuLabelControl', cx, cy + 2, cw, ch));
			urlLabel.setText(url);
			
			cy += ch + buttonSpace;
			
			serverButton[numServers].setText(buttonText);
			serverURL[numServers] = url;
			
			numServers++;
			
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *                Checks if the reconnect or spectator buttons have been clicked and deals with it
 *                accordingly.
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType){
	super.notify(control, eventType);
	
	if (control != none && control.isA('UWindowSmallButton') && eventType == DE_Click) {
		switch (control) {
			// Reconnect button.
			case reconnectButton:
				getplayerowner().consoleCommand(reconnectCommand);
				close();
				break;
			
			// Spectator button.
			case spectatorButton:
				getplayerowner().updateURL(SSTR_OverrideClass, spectatorClass, true);
				getplayerowner().consoleCommand(reconnectCommand);
				close();
				break;
			
			// Join server 1 button:
			case serverButton[0]:
				getplayerowner().consoleCommand(openCommand @ serverURL[0]);
				close();
				break;

			// Join server 2 button:
			case serverButton[1]:
				getplayerowner().consoleCommand(openCommand @ serverURL[1]);
				close();
				break;
				
			// Join server 3 button:
			case serverButton[2]:
				getplayerowner().consoleCommand(openCommand @ serverURL[2]);
				close();
				break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	caption="Failed to login: server is full."
	message="The server you have tried to enter has no more player slots available. You can try again in a few minutes or reconnect immediately as a spectator. If you wish to play immediately you can connect to one of the alternate servers."
	reconnectText="Reconnect"
	spectatorText="Spectator"
}