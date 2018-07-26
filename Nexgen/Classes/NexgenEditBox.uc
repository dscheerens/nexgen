/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenEditBox
 *  $VERSION      1.01 (21-10-2007 11:02)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen extended editbox GUI component class.
 *
 **************************************************************************************************/
class NexgenEditBox extends UWindowEditBox;

var bool bDisabled;           // Whether the component is enabled or not.



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
	local float w, h;
	local float textY;
	
	if (bDisabled) {
		c.drawColor.r = 192;
		c.drawColor.g = 192;
		c.drawColor.b = 192;
		drawStretchedTexture(c, 0, 0, winWidth, winHeight, Texture'UWindow.WhiteTexture');
	}
	
	super.paint(c, x, y);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the value entered in the edit box. This is a fixed version of the
 *                UWindow.UWindowEditBox setValue function, which didn't updated the caretOffset
 *                when bAllSelected was set to true.
 *  $PARAM        newValue   The new value of the edit box.
 *  $PARAM        newValue2  New alternate value.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setValue(string newValue, optional string newValue2) {
	value = newValue;
	value2 = newValue2;
	
    if (bAllSelected || caretOffset > len(value)) {
		caretOffset = len(value);
	}
	
	notify(DE_Change);
}