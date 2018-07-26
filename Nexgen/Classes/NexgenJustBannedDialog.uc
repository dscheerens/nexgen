/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenJustBannedDialog
 *  $VERSION      1.00 (17-11-2007 18:34)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dialog to display if the player just got kicked / banned from the server.
 *
 **************************************************************************************************/
class NexgenJustBannedDialog extends NexgenBannedDialog;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	caption="You have been kicked/banned from the server."
	message="An administrator has just kicked or banned you from the server. This means you are probably not welcome for the time being. Please go play somewhere else, there are enough of other servers and games out there."
}