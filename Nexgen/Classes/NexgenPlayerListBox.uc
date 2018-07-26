/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPlayerListBox
 *  $VERSION      1.03 (20-10-2007 14:45)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Player listbox GUI component.
 *
 **************************************************************************************************/
class NexgenPlayerListBox extends UWindowListBox;

#exec TEXTURE IMPORT NAME=noCountry FILE=Resources\NoCountry.pcx GROUP="GFX" FLAGS=2 MIPS=Off

var color baseColor;          // Default color used to render textures in their original color.
var color selectColor;        // Background color of selected items.
var color teamColor[6];       // Team colors used for drawing the items text.
var bool bShowCountryFlag;    // Indicates if little country flags should be displayed.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the specified listbox item.
 *  $PARAM        c     The canvas object on which the rendering will be performed.
 *  $PARAM        item  Item to render.
 *  $PARAM        x     Horizontal offset on the canvas.
 *  $PARAM        y     Vertical offset on the canvas.
 *  $PARAM        w     Width of the item that is to be rendered.
 *  $PARAM        h     Height of the item that is to be rendered.
 *  $REQUIRE      c != none && item != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function drawItem(Canvas c, UWindowList item, float x, float y, float w, float h) {
	local int offsetX;
	local texture flagTex;
	local color backgroundColor;
	
	// Draw background.
	backgroundColor = getBackgroundColor(NexgenPlayerList(item));
	if (backgroundColor != baseColor) {
		c.drawColor = backgroundColor;
		drawStretchedTexture(c, x, y, w, h - 1, Texture'WhiteTexture');
	}
	
	// Draw country flag.
	offsetX = 2;
	if (bShowCountryFlag) {
		c.drawColor = baseColor;
		flagTex = NexgenPlayerList(item).getFlagTex();
		if (flagTex == none) {
			flagTex = texture'noCountry';
		}
		drawClippedTexture(c, x + offsetX, y + 1, flagTex);
		offsetX += 18;
	}
	
	// Draw text.
	c.drawColor = getDisplayColor(NexgenPlayerList(item));
	c.font = getDisplayFont(NexgenPlayerList(item));
	clipText(c, x + offsetX, y, getDisplayText(NexgenPlayerList(item)));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when an item was double clicked on.
 *  $PARAM        item  The item which was double clicked.
 *  $REQUIRE      item != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function doubleClickItem(UWindowListBoxItem item) {
	if (notifyWindow != none) {
		notifyWindow.notify(self, DE_DoubleClick);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the font in which the text should be displayed for a list item.
 *  $PARAM        item  The item for which its display font has to be determined.
 *  $REQUIRE      item != none
 *  $RETURN       The font in which the text should be displayed for the specified item.
 *
 **************************************************************************************************/
function font getDisplayFont(NexgenPlayerList item) {
	return root.fonts[F_Bold];
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the text displayed for a list item.
 *  $PARAM        item  The item for which its display text has to be determined.
 *  $REQUIRE      item != none
 *  $RETURN       The text that should be displayed for the specified item in the listbox.
 *
 **************************************************************************************************/
function string getDisplayText(NexgenPlayerList item) {
	return "[" $ item.pTitle $ "] " $ item.pName;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the color of the background in which the text should be displayed for a
 *                list item.
 *  $PARAM        item  The item for which its background color has to be determined.
 *  $REQUIRE      item != none
 *  $RETURN       The background color of the the specified item.
 *
 **************************************************************************************************/
function color getBackgroundColor(NexgenPlayerList item) {
	if (item.bSelected) {
		return selectColor;
	} else {
		return baseColor;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the color in which the text should be displayed for a list item.
 *  $PARAM        item  The item for which its display color has to be determined.
 *  $REQUIRE      item != none
 *  $RETURN       The color in which the text should be displayed for the specified item.
 *
 **************************************************************************************************/
function color getDisplayColor(NexgenPlayerList item) {
	return teamColor[item.pTeam];
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new player to the list.
 *  $RETURN       The player item that was added to the list.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function NexgenPlayerList addPlayer() {
	return NexgenPlayerList(items.append(listClass));
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the player with the specified player code from the list.
 *  $PARAM        playerNum  The player to remove.
 *  $REQUIRE      playerNum >= 0
 *  $ENSURE       getPlayer(playerNum) == none
 *
 **************************************************************************************************/
function removePlayer(int playerNum) {
	local NexgenPlayerList item;

	// Search for player.
	for (item = NexgenPlayerList(items); item != none; item = NexgenPlayerList(item.next)) {
		if (item.pNum == playerNum) {
			item.remove();
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the player item with the specified player number.
 *  $PARAM        playerNum  Indicates the player to return.
 *  $REQUIRE      playerNum >= 0
 *  $RETURN       The player item that has the specified player number, or none if there is no 
 *                player item with the specified player number.
 *
 **************************************************************************************************/
function NexgenPlayerList getPlayer(int playerNum) {
	local NexgenPlayerList item;

	// Search for player.
	for (item = NexgenPlayerList(items); item != none; item = NexgenPlayerList(item.next)) {
		if (item.pNum == playerNum) {
			return item;
		}
	}
	
	// Player not found, return none.
	return none;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the player item with the specified player number.
 *  $PARAM        playerNum  Indicates the player to return.
 *  $REQUIRE      playerNum >= 0
 *  $RETURN       The player item that has the specified player number, or none if there is no 
 *                player item with the specified player number.
 *
 **************************************************************************************************/
function NexgenPlayerList getPlayerByID(string clientID) {
	local NexgenPlayerList item;

	// Search for player.
	for (item = NexgenPlayerList(items); item != none; item = NexgenPlayerList(item.next)) {
		if (item.pClientID ~= clientID) {
			return item;
		}
	}
	
	// Player not found, return none.
	return none;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Moves the selected item to the specified player listbox.
 *  $PARAM        target  The player listbox where the currently selected item should be moved to.
 *  $REQUIRE      target != none
 *  $ENSURE       selectedItem == none
 *
 **************************************************************************************************/
function moveSelectedPlayerTo(NexgenPlayerListBox target) {
	local NexgenPlayerList item;
	
	if (selectedItem != none) {
		item = target.addPlayer();
		NexgenPlayerList(selectedItem).copyTo(item);
		selectedItem.remove();
		selectedItem = none;
		target.setSelectedItem(item);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	baseColor=(R=255,G=255,B=255)
	selectColor=(R=250,G=200,B=150)
	teamColor(0)=(R=200,G=20,B=20)
	teamColor(1)=(R=20,G=20,B=150)
	teamColor(2)=(R=20,G=200,B=20)
	teamColor(3)=(R=200,G=150,B=20)
	teamColor(4)=(R=0,G=0,B=0)
	teamColor(5)=(R=100,G=100,B=100)
	bShowCountryFlag=true
	listClass=class'NexgenPlayerList'
	itemHeight=13
}