/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenSimpleListBox
 *  $VERSION      1.01 (31-10-2007 13:44)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Simple listbox GUI component.
 *
 **************************************************************************************************/
class NexgenSimpleListBox extends UWindowListBox;



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
	if(NexgenSimpleListItem(item).bSelected) {
		c.drawColor.r = 0;
		c.drawColor.g = 0;
		c.drawColor.b = 128;
		drawStretchedTexture(c, x, y, w, h - 1, Texture'WhiteTexture');
		c.drawColor.r = 255;
		c.drawColor.g = 255;
		c.drawColor.b = 255;
	} else {
		c.drawColor.r = 0;
		c.drawColor.g = 0;
		c.drawColor.b = 0;
	}
	
	c.font = root.fonts[F_Normal];
	
	clipText(c, x + 2, y, NexgenSimpleListItem(item).displayText);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the item with the specified id number.
 *  $PARAM        itemID  The id number of the item to return.
 *  $RETURN       The item that has the specified id number, or none if there is no item with the
 *                specified id number.
 *
 **************************************************************************************************/
function NexgenSimpleListItem getItemByID(int itemID) {
	local NexgenSimpleListItem item;

	// Search for item.
	for (item = NexgenSimpleListItem(items); item != none; item = NexgenSimpleListItem(item.next)) {
		if (item.itemID == itemID) {
			return item;
		}
	}
	
	// Item not found, return none.
	return none;
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
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	listClass=class'NexgenSimpleListItem'
	itemHeight=13
}
