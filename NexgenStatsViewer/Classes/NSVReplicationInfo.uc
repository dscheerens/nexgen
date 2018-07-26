/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $CLASS        NSVReplicationInfo
 *  $VERSION      1.01 (22-6-2008 22:07)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen stats replication support class. This class is responsible for
 *                transferring the statistics info from the server to the client.
 *
 **************************************************************************************************/
class NSVReplicationInfo extends ReplicationInfo;

var int playerListChecksum;             // Checksum of playerList.

var string playerName[30];              // Name of top players.
var string score[30];                   // Score for the top players.
var string country[30];                 // Countries of top players.
var byte positionChange[30];            // Ranking position change indicator for the top players.

var string listName[5];                 // Caption of the top players list.
var byte listLength[5];                 // Length of the top players list.

const PC_NoChange = 0;                  // Ranking hasn't changed.
const PC_MovedUp = 1;                   // Player moved up in the ranking.
const PC_MovedDown = 2;                 // Player moved down in the ranking.
const PC_NotAvailable = 255;            // No ranking change information available.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

	reliable if (role == ROLE_Authority)
		playerListChecksum, playerName, score, country, positionChange, listName, listLength;
	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Calculates a checksum of the replicated player list variables.
 *  $RETURN       The checksum of the replicated player list variables.
 *
 **************************************************************************************************/
simulated function int calcPlayerListChecksum() {
	local int checksum;
	local int index;
	
	checksum = 1;
	
	for (index = 0; index < arrayCount(playerName); index++) {
		checksum += len(playerName[index]);
	}
	
	for (index = 0; index < arrayCount(score); index++) {
		checksum += len(score[index]);
	}
	
	for (index = 0; index < arrayCount(country); index++) {
		checksum += len(country[index]);
	}
	
	for (index = 0; index < arrayCount(positionChange); index++) {
		checksum += positionChange[index];
	}
	
	for (index = 0; index < arrayCount(listName); index++) {
		checksum += len(listName[index]);
	}
	
	for (index = 0; index < arrayCount(listLength); index++) {
		checksum += listLength[index];
	}
	
	return checksum;
}