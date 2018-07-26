/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenEditControl
 *  $VERSION      1.00 (20-10-2007 23:13)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen extended edit control GUI component class.
 *
 **************************************************************************************************/
class NexgenEditControl extends UWindowEditControl;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the setup for this GUI component.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
    super(UWindowDialogControl).created();
    
	editBox = UWindowEditBox(createWindow(class'NexgenEditBox', 0, 0, winWidth, winHeight)); 
	editBox.notifyOwner = self;
	editBox.bSelectOnFocus = true;
	
	editBoxWidth = winWidth / 2;
	
	setEditTextColor(lookAndFeel.editBoxTextColor);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Disables or enables the component. In the disabled state an user can't change the
 *                value entered in the editbox.
 *  $PARAM        bDisabled  Indicates whether or not the component should be disabled.
 *
 **************************************************************************************************/
function setDisabled(bool bDisabled) {
	NexgenEditBox(editBox).bDisabled = bDisabled;
	editBox.bCanEdit = !bDisabled;
}