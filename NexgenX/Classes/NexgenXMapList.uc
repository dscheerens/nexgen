/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenXMapList
 *  $VERSION      1.00 (6-12-2008 17:54)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Map list storage class.
 *
 **************************************************************************************************/
class NexgenXMapList extends Info;

var string maps[1024];                  // Maps available on the server.
var int numMaps;                        // Number of maps available.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Load the map list found on this machine.
 *
 **************************************************************************************************/
function loadLocalMaps() {
	local string firstMap;
	local string nextMap;
	local bool bIsValidMap;
	
	firstMap = getMapName("", "", 0);
	nextMap = firstMap;
	
	do {
		// Check if this is a valid map.
		bIsValidMap = class'NexgenUtil'.static.isValidLevel(nextMap);
		
		// Add map to maplist if valid.
		if (bIsValidMap) {
			maps[numMaps++] = nextMap;
		}
		
		// Retrieve next map.
		nextMap = getMapName("", nextMap, 1);
	} until (nextMap ~= firstMap || numMaps >= arrayCount(maps));
}