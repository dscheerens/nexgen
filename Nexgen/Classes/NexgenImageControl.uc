/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenImageControl
 *  $VERSION      1.00 (10-03-2007 22:54)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Image GUI component.
 *
 **************************************************************************************************/
class NexgenImageControl extends UWindowDialogControl;

var Texture image;            // Image to display.
var bool bStretch;            // Whether to stretch the image if the dimensions do not match.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the GUI component.
 *  $PARAM        c  The canvas object which acts as a drawing surface for the dialog.
 *  $PARAM        x  Unknown.
 *  $PARAM        y  Unknown.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function paint(Canvas c, float x, float y) {
	local float xPos;
	local float yPos;
	
	if (image != none) {
		if (bStretch) {
			drawStretchedTexture(c, 0, 0, winWidth, winHeight, image);
		} else {
			xPos = int((winWidth - image.uSize) / 2.0);
			yPos = int((winHeight - image.vSize) / 2.0);
			drawClippedTexture(c, xPos, yPos, image);
		}
	}
}