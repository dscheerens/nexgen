/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenDummyComponent
 *  $VERSION      1.00 (7-3-2007 20:49)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Dummy GUI component. This component only marks the occupied area, but doesn't
 *                have any means of interaction with the user. Should only be used for testing.
 *
 **************************************************************************************************/
class NexgenDummyComponent extends UWindowWindow;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Paints the dialog area.
 *  $PARAM        c  The canvas object which acts as a drawing surface for the dialog.
 *  $PARAM        x  Unknown.
 *  $PARAM        y  Unknown.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function paint(Canvas c, float x, float y){
	super.paint(c, x, y);
	
	drawUpBevel(c, 0, 0, winWidth, winHeight, getLookAndFeelTexture());
}