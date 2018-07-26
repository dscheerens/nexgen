/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenSimpleListItem
 *  $VERSION      1.00 (14-10-2007 22:36)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Simple list item description class. Stores only two properties a display name and
 *                an item identifier.
 *
 **************************************************************************************************/
class NexgenSimpleListItem extends UWindowListBoxItem;

var string displayText;
var int itemID;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Compares two UWindowList items.
 *  $PARAM        a  First item to compare.
 *  $PARAM        b  Second item to compare.
 *  $REQUIRE      a != none && b != none
 *  $RETURNS      -1 If the first item is 'smaller' then the second item, otherwise 1 is returned.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int compare(UWindowList a, UWindowList b) {
	if (NexgenSimpleListItem(a).displayText < NexgenSimpleListItem(b).displayText) {
		return -1;
	} else {
		return 1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	itemID=-1
}