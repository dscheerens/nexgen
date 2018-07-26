/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPanel
 *  $VERSION      1.10 (20-12-2010 22:48:02)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen control panel page.
 *
 **************************************************************************************************/
class NexgenPanel extends NexgenContentPanel;

var string panelIdentifier;             // Unique panel identifier.

var NexgenClient client;                // Nexgen client instance.

var float panelHeight;                  // Desired panel height.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the contents for this panel. This function is automatically called after
 *                the panel has been successfully created and all variables have been set. This
 *                applies in particular for the client variable which is often required to setup the
 *                contents of the panel.
 *
 **************************************************************************************************/
function setContent() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies this panel that the server configuration has been updated.
 *  $PARAM        configType  Type of settings that have been changed.
 *
 **************************************************************************************************/
function configChanged(byte configType) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies this panel that the extended game info has been updated.
 *  $PARAM        infoType  Type of information that has been changed.
 *
 **************************************************************************************************/
function gameInfoChanged(byte infoType) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the client of a player event. Additional arguments to the event should be
 *                combined into one string which then can be send along with the playerEvent call.
 *  $PARAM        playerNum  Player identification number.
 *  $PARAM        eventType  Type of event that has occurred.
 *  $PARAM        args       Optional arguments.
 *  $REQUIRE      playerNum >= 0
 *
 **************************************************************************************************/
function playerEvent(int playerNum, string eventType, optional string args) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *
 **************************************************************************************************/
function notifyEvent(string type, optional string arguments) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the player list for the specified player list box.
 *  $PARAM        list  The player list box for which the player list is to be loaded.
 *  $REQUIRE      list != none
 *
 **************************************************************************************************/
function loadPlayerList(NexgenPlayerListBox list) {
	local NexgenPlayerInfo player;
	local NexgenPlayerList playerItem;
	
	for (player = client.playerList; player != none; player = player.nextPlayer) {
		playerItem = list.addPlayer();
		playerItem.pNum = player.playerNum;
		playerItem.pName = player.playerName;
		playerItem.pTitle = player.playerTitle;
		playerItem.pIPAddress = player.ipAddress;
		playerItem.pClientID = player.clientID;
		playerItem.pCountry = player.countryCode;
		playerItem.pTeam = player.teamNum;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new player to the specified player listbox.
 *  $PARAM        list       The player listbox where the new player should be added to.
 *  $PARAM        playerNum  The player code of the new player to add.
 *  $PARAM        args       Player joined event arguments.
 *  $REQUIRE      list != none && playerNum >= 0
 *  $RETURN       The player item that was added to the list.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function NexgenPlayerList addPlayerToList(NexgenPlayerListBox list, int playerNum, string args) {
	local NexgenPlayerList playerItem;
	
	playerItem = list.addPlayer();
	playerItem.pNum = playerNum;
	playerItem.pName = class'NexgenUtil'.static.getProperty(args, client.PA_Name);
	playerItem.pTitle = class'NexgenUtil'.static.getProperty(args, client.PA_Title);
	playerItem.pIPAddress = class'NexgenUtil'.static.getProperty(args, client.PA_IPAddress);
	playerItem.pClientID = class'NexgenUtil'.static.getProperty(args, client.PA_ClientID);
	playerItem.pCountry = class'NexgenUtil'.static.getProperty(args, client.PA_Country);
	playerItem.pTeam = byte(class'NexgenUtil'.static.getProperty(args, client.PA_Team));
	
	return playerItem;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the attributes of the specified player in the given player listbox.
 *  $PARAM        list       The player listbox where the player info should be updated.
 *  $PARAM        playerNum  The player code of the player to update.
 *  $PARAM        args       Player attribute change event arguments.
 *  $REQUIRE      list != none && playerNum >= 0
 *  $RETURN       The player item that was updated in the list. Might be none if the list didn't
 *                contain the player with the specified player code.
 *
 **************************************************************************************************/
function NexgenPlayerList updatePlayerInfo(NexgenPlayerListBox list, int playerNum, string args) {
	local NexgenPlayerList playerItem;
	local string value;
	
	playerItem = list.getPlayer(playerNum);
	
	if (playerItem != none) {
		// Name attribute.
		value = class'NexgenUtil'.static.getProperty(args, client.PA_Name);
		if (value != "") {
			playerItem.pName = value;
		}
		
		// Title attribute.
		value = class'NexgenUtil'.static.getProperty(args, client.PA_Title);
		if (value != "") {
			playerItem.pTitle = value;
		}
		
		// Country attribute.
		value = class'NexgenUtil'.static.getProperty(args, client.PA_Country);
		if (value != "") {
			playerItem.pCountry = value;
			playerItem.setFlagTex();
		}
		
		// Team attribute.
		value = class'NexgenUtil'.static.getProperty(args, client.PA_Team);
		if (value != "") {
			playerItem.pTeam = byte(value);
		}
	}
	
	return playerItem;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new component container panel to the current region.
 *  $PARAM        bgType  Panel border/background style.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The raised that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function NexgenPanel addSubPanel(class<NexgenPanel> panelClass, optional EPanelBackType bgType) {
	local NexgenPanel panel;
	
	panel = NexgenPanel(addComponent(panelClass));
	panel.panelBGType = bgType;
	panel.parentCP = self;
	panel.client = self.client;
	panel.setContent();
	
	return panel;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *
 **************************************************************************************************/
function varChanged(NexgenSharedDataContainer container, string varName, optional int index) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization of the given shared data container is
 *                done. After this has happend the client may query its variables and receive valid
 *                results (assuming the client is allowed to read those variables).
 *  $PARAM        container  The shared data container that has become available for use.
 *  $REQUIRE      container != none
 *
 **************************************************************************************************/
function dataContainerAvailable(NexgenSharedDataContainer container) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization by the given synchronization manager is
 *                done. This means all the data containers in the ynchronization manager are ready
 *                to be queried.
 *  $PARAM        dataSyncMgr  The shared data synchronization manager whose containers were initialized.
 *  $REQUIRE      dataSyncMgr != none
 *
 **************************************************************************************************/
function sharedDataInitComplete(NexgenSharedDataSyncManager dataSyncMgr) {
	// To implement in subclass.
}
