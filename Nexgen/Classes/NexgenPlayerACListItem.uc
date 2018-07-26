/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPlayerACListItem
 *  $VERSION      1.01 (21-10-2007 11:24)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Online user acccount list item description class.
 *
 **************************************************************************************************/
class NexgenPlayerACListItem extends NexgenPlayerList;

var bool bHasAccount;
var byte accountNum;



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
	local string pTitleA, pTitleB;
	local string pNameA, pNameB;
	
	pTitleA = caps(NexgenPlayerACListItem(a).pTitle);
	pTitleB = caps(NexgenPlayerACListItem(b).pTitle);
	pNameA = caps(NexgenPlayerACListItem(a).pName);
	pNameB = caps(NexgenPlayerACListItem(b).pName);
	
	if (pTitleA < pTitleB) {
		return -1;
	} else if (pTitleA == pTitleB) {
		if (pNameA < pNameB) {
			return -1;
		} else if (pNameA == pNameB) {
			return 0;
		} else {
			return 1;
		}
	} else {
		return 1;
	}
}
