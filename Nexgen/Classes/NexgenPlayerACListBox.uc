/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPlayerACListBox
 *  $VERSION      1.00 (20-10-2007 15:47)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Online player account listbox GUI component.
 *
 **************************************************************************************************/
class NexgenPlayerACListBox extends NexgenPlayerListBox;

var color accountColor;
var color selectedAccountColor;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the font in which the text should be displayed for a list item.
 *  $PARAM        item  The item for which its display font has to be determined.
 *  $REQUIRE      item != none
 *  $RETURN       The font in which the text should be displayed for the specified item.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function font getDisplayFont(NexgenPlayerList item) {
	if (NexgenPlayerACListItem(item).bHasAccount) {
		return root.fonts[F_Bold];
	} else {
		return root.fonts[F_Normal];
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the color of the background in which the text should be displayed for a
 *                list item.
 *  $PARAM        item  The item for which its background color has to be determined.
 *  $REQUIRE      item != none
 *  $RETURN       The background color of the the specified item.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function color getBackgroundColor(NexgenPlayerList item) {
	if (item.bSelected) {
		if (NexgenPlayerACListItem(item).bHasAccount) {
			return selectedAccountColor;
		} else {
			return selectColor;
		}
	} else {
		return baseColor;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	accountColor=(R=150,G=150,B=150)
	selectedAccountColor=(R=200,G=150,B=100)
	bShowCountryFlag=false
	listClass=class'NexgenPlayerACListItem'
}