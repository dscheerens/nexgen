/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPlayerList
 *  $VERSION      1.05 (26-4-2009 11:48:55)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Player list item description class. Stores the basic player attributes, such as
 *                name, team and clientID.
 *
 **************************************************************************************************/
class NexgenPlayerList extends UWindowListBoxItem;

var int pNum;                 // Player num.
var string pName;             // Name used by the player.
var string pTitle;            // Title of the players account.
var string pIPAddress;        // IP Address.
var string pClientID;         // Client identification code.
var string pCountry;          // Country code based on the IP Address.
var byte pTeam;               // Team number.

var texture flagTex;          // Flag texture for the country.
var bool bFlagTexSet;         // Whether or not the flag texture has been set.

const specTeam = 5;           // Team used to indicate spectators.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the flag texture based on the current country code of the player. If the
 *                country code is invalid the flag texture will be set to none.
 *  $ENSURE       bFlagTexSet
 *
 **************************************************************************************************/
function setFlagTex() {
	if (len(pCountry) == 2 && caps(pCountry) != "XX") {
		flagTex = texture(dynamicLoadObject(class'NexgenUtil'.default.countryFlagsPkg $ "." $ pCountry, class'Texture'));
	} else {
		flagTex = none;
	}
	bFlagTexSet = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the flag texture associated with the country code of the player. Note
 *                that if the country code was changed setFlagTex() has to be called first in order
 *                to update the texture.
 *  $RETURN       A texture of the country flag of the player, might be none if an invalid country
 *                code is used.
 *
 **************************************************************************************************/
function texture getFlagTex() {
	if (!bFlagTexSet) {
		setFlagTex();
	}
	return flagTex;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Copies the attributes of this player list item to the specified player list item.
 *  $PARAM        target  The player list item where the attributes should be copied to.
 *  $REQUIRE      target != none
 *
 **************************************************************************************************/
function copyTo(NexgenPlayerList target) {
	target.pNum = self.pNum;
	target.pName = self.pName;
	target.pTitle = self.pTitle;
	target.pIPAddress = self.pIPAddress;
	target.pClientID = self.pClientID;
	target.pCountry = self.pCountry;
	target.pTeam = self.pTeam;
	target.flagTex = self.flagTex;
	target.bFlagTexSet = self.bFlagTexSet;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether this player is a spectator.
 *  $RETURN       True if this player is a spectator, false if not.
 *
 **************************************************************************************************/
function bool isSpectator() {
	return pTeam == specTeam;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	pNum=-1
}