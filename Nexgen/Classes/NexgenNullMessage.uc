/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenNullMessage
 *  $VERSION      1.00 (6-4-2008 11:59)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Special placeholder message. This localized message is used by the
 *                NexgenHUDWrapper class to clear the local message queue in the original HUD.
 *
 **************************************************************************************************/
class NexgenNullMessage extends LocalMessagePlus;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	bIsConsoleMessage=false
	bIsSpecial=true
}