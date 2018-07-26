/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXRCPBotControl
 *  $VERSION      1.00 (15-03-2010 13:39)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen bot control panel page.
 *
 **************************************************************************************************/
class NexgenXRCPBotControl extends NexgenPanel;

var NexgenXClient xClient;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {	
	// Min players.
	// Skill.
	// Auto adjust skill.
	// Random order.
	// Remove all bots.
	// Add x bots.
	// Move all to team x.
	// Balance bots.
	
	// Remove bot.
	// Switch to team.
	// Change name.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	panelIdentifier="botcontrol"
}