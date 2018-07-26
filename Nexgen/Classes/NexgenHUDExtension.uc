/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenHUDExtension
 *  $VERSION      1.00 (6-12-2008 14:31)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  A replacement class for HUD mutators, which allows the HUD extensions to render
 *                stuff while special screens are displayed, such as the scoreboard.
 *
 **************************************************************************************************/
class NexgenHUDExtension extends Actor;

var NexgenClient client;      // The NexgenClient for which this HUD extension is active.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the HUD. Called before anything of the game HUD has been drawn. This
 *                function is only called if the Nexgen HUD is enabled.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *
 **************************************************************************************************/
simulated function preRender(Canvas c) {
	// To implement in sub class.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the HUD. Called while the mutators are allowed to render. Only called if
 *                no special screens are shown (like the scoreboard).
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *
 **************************************************************************************************/
simulated function render(Canvas c) {
	// To implement in sub class.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the HUD. Called after everything of the game HUD has been drawn. This
 *                function is only called if the Nexgen HUD is enabled.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *
 **************************************************************************************************/
simulated function postRender(Canvas c) {
	// To implement in sub class.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	bHidden=true
}