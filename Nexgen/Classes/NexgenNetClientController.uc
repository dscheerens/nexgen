/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenNetClientController
 *  $VERSION      1.09 (06-04-2010 10:32)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Client controller class with reliable data transfer and flow control mechanisms.
 *                This class basically implements TCP on top of the netcode of the Unreal Engine.
 *
 **************************************************************************************************/
class NexgenNetClientController extends NexgenClientController abstract;

// General data transfer control state variables.
var string inputBuffer;                 // Buffer holding the data that was recieved.
var string outputBuffer;                // Buffer holding the data that is to be send.

var bool bCheckInputBuffer;             // Flag that indicates whether there is new data available
                                        // in the input buffer that may be processed.

var bool bIgnoreIO;                     // Whether or not to ignore all I/O operations for this peer.

// Data input control state variables.
var int lastInOrderPacket;              // Number of the last packet that was recieved in correct order.
var int inPacketBlockStart[20];         // Number of first packet in a packet block.
var int inPacketBlockEnd[20];           // Number of last packet in a packet block.
var string inPacketBlockData[20];       // Concatenated data of all packets in a packet block.
var byte inPacketBlockOrder[20];        // Order of the packet blocks.
var byte inPacketBlockCount;            // Number of buffered packet blocks.

// Data output control state variables.
var int pendingOutgoingPackets;         // The number of outgoing packets that are awaiting
                                        // acknowledgement from the other peer.
var int nextOutgoingPacketNum;          // Packet number for the next outgoing packet.
var int outPacketNum[20];               // Packet number of pending outgoing packet.
var string outPacketData[20];           // Data of the pending outgoing packets.
var float outPacketTime[20];            // Last time at which the packet was sent.

// Settings.
var int windowSize;                     // Maximum number of packets that can be unacknowledged.

const maxPacketDataSize = 200;          // Maximum size of data packets in bytes.
const packetAckTimeout = 2.0;           // Resend data if no acknowledgement was received within this period.
const netLogTag = 'DevNetNSC';          // Log tag for logging network errors.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {
	unreliable if (role == ROLE_Authority) // Replicate to client...
		clientRecvPacket, clientAckPacket;
		
	unreliable if (role == ROLE_SimulatedProxy) // Replicate to server...
		serverRecvPacket, serverAckPacket;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function preBeginPlay() {
	// Execute server side actions.
	if (role == ROLE_Authority) {
		initNetClientController();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated event postNetBeginPlay() {
	if (bNetOwner) {
		super.postNetBeginPlay();
		
		initNetClientController();
	} else {
		destroy();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the state variables that are used for the data transfer control.
 *
 **************************************************************************************************/
simulated function initNetClientController() {
	local int index;
	
	lastInOrderPacket = -1;
	
	for (index = 0; index < arrayCount(inPacketBlockStart); index++) {
		inPacketBlockStart[index] = -1;
		outPacketNum[index] = -1;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the specified string to the other machine. Note that the string may not be
 *                send immediately in case other data is pending in the output buffer.
 *  $PARAM        str  The string that is to be send to the other machine.
 *
 **************************************************************************************************/
simulated function sendStr(coerce string str) {
	outputBuffer = outputBuffer $ serializeStr(str);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a string was received from the other machine.
 *  $PARAM        str  The string that was send by the other machine.
 *
 **************************************************************************************************/
simulated function recvStr(string str) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the specified packet to the other machine.
 *  $PARAM        packetNum  The number of the packet that is to be send.
 *  $PARAM        data       Contents of the packet, the data that is to be send.
 *
 **************************************************************************************************/
simulated function sendPacket(int packetNum, string data) {
	if (role == ROLE_Authority) {
		clientRecvPacket(packetNum, data);
	} else {
		serverRecvPacket(packetNum, data);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the client has received a packet.
 *  $PARAM        packetNum  The number of the packet that was received.
 *  $PARAM        data       Contents of the packet, the received data.
 *
 **************************************************************************************************/
simulated function clientRecvPacket(int packetNum, string data) {
	serverAckPacket(packetNum);
	recvPacket(packetNum, data);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the server has received a packet.
 *  $PARAM        packetNum  The number of the packet that was received.
 *  $PARAM        data       Contents of the packet, the received data.
 *
 **************************************************************************************************/
function serverRecvPacket(int packetNum, string data) {
	clientAckPacket(packetNum);
	recvPacket(packetNum, data);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a packet send by the client has been successfully transferred to the
 *                server and the server has acknowledged that is was received.
 *  $PARAM        packetNum  The number of the packet that successfully transferred.
 *
 **************************************************************************************************/
simulated function clientAckPacket(int packetNum) {
	ackPacket(packetNum);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a packet send by the server has been successfully transferred to the
 *                client and the client has acknowledged that is was received.
 *  $PARAM        packetNum  The number of the packet that successfully transferred.
 *
 **************************************************************************************************/
function serverAckPacket(int packetNum) {
	ackPacket(packetNum);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function. Called when the game performs its next tick.
 *                The following actions are performed:
 *                 - Processes pending data in the output buffer.
 *                 - Check for unacknowledged packets.
 *                 - Processes pending data in the input buffer.
 *  $PARAM        delta  Time elapsed (in seconds) since the last tick.
 *  $OVERRIDE     
 *
 **************************************************************************************************/
simulated function tick(float deltaTime) {
	// Check whether I/O operations have halted.
	if (bIgnoreIO) {
		inputBuffer = "";
		outputBuffer = "";
		return;
	}
	
	// Process the input buffer.
	if (bCheckInputBuffer) {
		processInputBuffer();
	}
	
	// Process the output buffer.
	processOutputBuffer();
	
	// Check for packet acknowledgement timeouts.
	if (pendingOutgoingPackets > 0) {
		checkForPacketTimeouts();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Processes the input buffer by trying to deserialize as many string it can from the
 *                data that is currently being held by the input buffer. Every deserialized string
 *                will be passed to the recvStr function so that the client can handle it.
 *  $ENSURE       !bCheckInputBuffer
 *
 **************************************************************************************************/
simulated function processInputBuffer() {
	local bool bNoMoreData;
	local string str;
	
	// Try to deserialize the data from the input buffer.
	do {
		if (readStrFromInputBuffer(str)) {
			recvStr(str);
		} else {
			bNoMoreData = true;
		}
	} until(bNoMoreData);
	
	// Clear input buffer updated flag.
	bCheckInputBuffer = false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Processes the data that is left in the output buffer. All data that is pending in
 *                the output buffer will be send until the window is full.
 *
 **************************************************************************************************/
simulated function processOutputBuffer() {
	local string packetData;
	
	// Continue sending packets as long as there is data to send and the window isn't full.
	while ((len(outputBuffer) > 0) && (pendingOutgoingPackets < windowSize)) {
		// Get packet data.
		if (len(outputBuffer) > maxPacketDataSize) {
			packetData = left(outputBuffer, maxPacketDataSize);
			outputBuffer = mid(outputBuffer, maxPacketDataSize);
		} else {
			packetData = outputBuffer;
			outputBuffer = "";
		}
		
		// Create a new packet and send it to the client.
		createAndSendPacket(packetData);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks for packet timeouts in the outgoing packet buffer. In case a packet in the
 *                outgoing buffer will not be acknowledged within a certain timeout limit the packet
 *                is assumed to be lost and it be retransmitted.
 *
 **************************************************************************************************/
simulated function checkForPacketTimeouts() {
	local byte packetIndex;
	
	for (packetIndex = 0; packetIndex < windowSize; packetIndex++) {
		if (outPacketNum[packetIndex] >= 0 &&
		    client.timeSeconds - outPacketTime[packetIndex] > packetAckTimeout) {
			sendStoredPacket(packetIndex);
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a new outgoing packet for the given data and sends it to the other machine.
 *  $PARAM        data  The data that is to be send.
 *  $REQUIRE      data != "" && pendingOutgoingPackets < windowSize
 *  $ENSURE       new.pendingOutgoingPackets = old.pendingOutgoingPackets + 1 &&
 *                new.nextOutgoingPacketNum = old.nextOutgoingPacketNum + 1
 *
 **************************************************************************************************/
simulated function createAndSendPacket(string data) {
	local int packetNum;
	local byte packetIndex;
	local bool bSlotFound;
	
	// Find a free slot in which the packet can be stored.
	while (!bSlotFound && packetIndex < windowSize) {
		if (outPacketNum[packetIndex] < 0) {
			bSlotFound = true;
		} else {
			packetIndex++;
		}
	}
	
	// Check if a slot has been found (this should be the case).
	if (!(bSlotFound)) {
		log("Assertion failed: " $ self $ ".createAndSendPacket() -> (bSlotFound). ", netLogTag);
		return;
	}
	
	// Get packet number.
	packetNum = nextOutgoingPacketNum++;
	
	// Temporarily store packet until it is acknowledged.
	outPacketNum[packetIndex] = packetNum;
	outPacketData[packetIndex] = data;
	pendingOutgoingPackets++;
	
	// Send packet.
	sendStoredPacket(packetIndex);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Sends the packet stored at the specified index of the outgoing packet buffer.
 *  $PARAM        packetIndex  The index of the stored packet that is to be send.
 *  $REQUIRE      0 <= packetIndex && packetIndex < windowSize && outPacketNum[packetIndex] >= 0
 *
 **************************************************************************************************/
simulated function sendStoredPacket(byte packetIndex) {
	outPacketTime[packetIndex] = client.timeSeconds;
	sendPacket(outPacketNum[packetIndex], outPacketData[packetIndex]);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a packet has been recieved from the other machine. This function
 *                either adds the data to the input buffer stores the packet in the incoming packet
 *                buffer, depending on whether the packet was in order or not.
 *  $PARAM        packetNum  The number of the packet that was received.
 *  $PARAM        data       Data contents of the packet.
 *
 **************************************************************************************************/
simulated function recvPacket(int packetNum, string data) {
	if (packetNum <= lastInOrderPacket) {
		// Packet was already received, ignore packet.
		return;
	} else if (packetNum == lastInOrderPacket + 1) {
		// Packet received in order, add to input buffer.
		inputBuffer = inputBuffer $ data;
		lastInOrderPacket++;
		bCheckInputBuffer = true;
	} else {
		// Packet was received out of order, store in packet input buffer.
		storeOutOfOrderPacket(packetNum, data);
	}
	
	// Check if the packet input buffer contains adjacent packet blocks.
	compactPacketInputBuffer();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Stores the given packet in the out of order incoming packet buffer.
 *  $PARAM        packetNum  Number of the packet that was recieved.
 *  $PARAM        data       Contents of the packet
 *
 **************************************************************************************************/
simulated function storeOutOfOrderPacket(int packetNum, string data) {
	local byte blockNum;
	local byte blockIndex;
	local byte index;
	local bool bBlockPositionFound;
	local bool bPacketStored;
	
	// Check if packet can be added to an existing packet block.
	while (!bBlockPositionFound && blockNum < inPacketBlockCount) {
		blockIndex = inPacketBlockOrder[blockNum];
		
		// Check if packet can be stored in the current block or not.
		if (packetNum < inPacketBlockStart[blockIndex] - 1) {
			// Packet has to be stored before the current block.
			bBlockPositionFound = true;
		} else if (packetNum == inPacketBlockStart[blockIndex] - 1) {
			// Packet can be added to the front of the current block.
			inPacketBlockStart[blockIndex] = packetNum;
			inPacketBlockData[blockIndex] = data $ inPacketBlockData[blockIndex];
			bBlockPositionFound = true;
			bPacketStored = true;
		} else if (packetNum <= inPacketBlockEnd[blockIndex]) {
			// Packet is already stored in the current block, packet should be ignored.
			bBlockPositionFound = true;
			bPacketStored = true;
		} else if (packetNum == inPacketBlockEnd[blockIndex] + 1 &&
		           (blockNum + 1 == inPacketBlockCount ||
		            packetNum < inPacketBlockStart[inPacketBlockOrder[blockNum + 1]])) {
			// Packet can be added to the back of the current block.
			inPacketBlockEnd[blockIndex] = packetNum;
			inPacketBlockData[blockIndex] = inPacketBlockData[blockIndex] $ data;
			bBlockPositionFound = true;
			bPacketStored = true;
		} else {
			// Packet cannot be stored in the current block, maybe in the next block.
			blockNum++;
		}
	}
	
	// Create new packet block if necessary.
	if (!bPacketStored) {
		// Check if packet may be stored.
		if (inPacketBlockCount >= windowSize) {
			log("Incoming packet block buffer full for " $ self $ ", unable to buffer out of order packet.", netLogTag);
			return;
		}
		
		// Find a free packet block entry.
		blockIndex = 0;
		while (!bPacketStored && blockIndex < windowSize) {
			if (inPacketBlockStart[blockIndex] < 0) {
				inPacketBlockStart[blockIndex] = packetNum;
				inPacketBlockEnd[blockIndex] = packetNum;
				inPacketBlockData[blockIndex] = data;
				bPacketStored = true;
			} else {
				blockIndex++;
			}
		}
		
		// Check if packet has been stored.
		if (!(bPacketStored)) {
			log("Assertion failed: " $ self $ ".storeOutOfOrderPacket() -> (bPacketStored). ", netLogTag);
			return;
		}
		
		// Update packet block order.
		for (index = inPacketBlockCount; index > blockNum; index--) {
			inPacketBlockOrder[index] = inPacketBlockOrder[index - 1];
		}
		inPacketBlockOrder[blockNum] = blockIndex;
		inPacketBlockCount++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Compacts the out of order incoming packet buffer. This is done by trying to merge
 *                adjacent blocks of buffered packets into a single packet block. Additionally the
 *                function checks whether there is a block that can be flushed to the input buffer.
 *
 **************************************************************************************************/
simulated function compactPacketInputBuffer() {
	local byte blockNum;
	local byte blockIndex1;
	local byte blockIndex2;
	local byte index;
	
	// Merge adjacent blocks.
	while (blockNum < inPacketBlockCount - 1) {
		blockIndex1 = inPacketBlockOrder[blockNum];
		blockIndex2 = inPacketBlockOrder[blockNum + 1];
		
		if (inPacketBlockEnd[blockIndex1] + 1 == inPacketBlockStart[blockIndex2]) {
			inPacketBlockData[blockIndex1] = inPacketBlockData[blockIndex1] $ inPacketBlockData[blockIndex2];
			inPacketBlockEnd[blockIndex1] = inPacketBlockEnd[blockIndex2];
			inPacketBlockStart[blockIndex2] = -1;
			inPacketBlockData[blockIndex2] = "";
			for (index = blockNum + 1; index < inPacketBlockCount - 1; index++) {
				inPacketBlockOrder[index] = inPacketBlockOrder[index + 1];
			}
			inPacketBlockCount--;
		} else {
			blockNum++;
		}
	}
	
	// Check if the first buffered packet block can be added to the input buffer.
	if (inPacketBlockCount > 0 && lastInOrderPacket + 1 == inPacketBlockStart[inPacketBlockOrder[0]]) {
		blockIndex1 = inPacketBlockOrder[0];
		
		// Add block data to input buffer.
		inputBuffer = inputBuffer $ inPacketBlockData[blockIndex1];
		lastInOrderPacket = inPacketBlockEnd[blockIndex1];
		bCheckInputBuffer = true;
		
		// Clear packet block.
		inPacketBlockStart[blockIndex1] = -1;
		inPacketBlockData[blockIndex1] = "";
		
		// Update packet block order.
		for (index = 0; index < inPacketBlockCount - 1; index++) {
			inPacketBlockOrder[index] = inPacketBlockOrder[index + 1];
		}
		inPacketBlockCount--;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a packet has been acknowledged by the other peer.
 *  $PARAM        packetIndex  The number of the packet that is being acknowledged.
 *  $REQUIRE      packetNum >= 0
 *
 **************************************************************************************************/
simulated function ackPacket(int packetNum) {
	local byte packetIndex;
	local bool bPacketFound;
	
	// Find packet in the outgoing packet buffer.
	while (!bPacketFound && packetIndex < windowSize) {
		if (outPacketNum[packetIndex] == packetNum) {
			bPacketFound = true;
			outPacketNum[packetIndex] = -1;
			outPacketData[packetIndex] = "";
			pendingOutgoingPackets--;
		} else {
			packetIndex++;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Attempts to read a string from the input buffer. This may fail if the string is
 *                not completely stored in the input buffer yet. If a string was read then it will
 *                be returned via the out paramater string and the string will be removed from the
 *                input buffer.
 *  $PARAM        str  The string that was read from the input buffer.
 *  $RETURN       True if a string was read, false if not.
 *
 **************************************************************************************************/
simulated function bool readStrFromInputBuffer(out string str) {
	local bool bStringRead;
	local bool bDataCorrupted;
	local int stringLength;
	
	if (len(inputBuffer) >= 4) {
		bDataCorrupted = !class'NexgenUtil'.static.hexToDec(left(inputBuffer, 4), stringLength);
		if (bDataCorrupted) {
			log("Input buffer of " $ self $ " is corrupted.", netLogTag);
			bIgnoreIO = true;
		} else {
			if (len(inputBuffer) >= 4 + stringLength) {
				str = mid(inputBuffer, 4, stringLength);
				inputBuffer = mid(inputBuffer, stringLength + 4, len(inputBuffer) - stringLength - 4);
				bStringRead = true;
			}
		}
	}
	
	return bStringRead;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Serializes the specified string so that it can be transferred to the other machine
 *                and decoded there correctly.
 *  $PARAM        str  The string that is to be serialized.
 *  $RETURN       The serialized version of the given string.
 *
 **************************************************************************************************/
static function string serializeStr(string str) {
	return class'MD5Hash'.static.decToHex(len(str), 2) $ str;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	windowSize=2
	netPriority=1.0
}