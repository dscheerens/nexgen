/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenSimplePlayerListBox
 *  $VERSION      1.00 (13-10-2007 18:28)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Simple player listbox GUI component.
 *
 **************************************************************************************************/
class NexgenSimplePlayerListBox extends NexgenPlayerListBox;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the text displayed for a list item.
 *  $PARAM        item  The item for which its display text has to be determined.
 *  $REQUIRE      item != none
 *  $RETURN       The text that should be displayed for the specified item in the listbox.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getDisplayText(NexgenPlayerList item) {
	return item.pName;
}
