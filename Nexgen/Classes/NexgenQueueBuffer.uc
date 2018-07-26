/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenQueueBuffer
 *  $VERSION      1.00 (08-02-2010 17:06)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Sub buffer for the FIFO queue implementation for Unreal Tournament. Instances of
 *                this class hold the actual data of the queue. The queue is split in fixed size sub
 *                buffers, which are implemented in this class.
 *
 **************************************************************************************************/
class NexgenQueueBuffer extends info;

var NexgenQueueBuffer nextSubBuffer;    // Pointer to the next sub buffer.
var string subBuffer[100];              // Data of the sub buffer.
var int head;                           // Position of the head element in the buffer.
var int tail;                           // Next free buffer slot.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Tests whether the sub buffer is empty, i.e. it does not contain any data.
 *  $RETURN       True if the sub buffer is empty, false if it contains one ore more items.
 *
 **************************************************************************************************/
function bool subBufferEmpty() {
	return head == tail;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Tests whether the sub buffer is full, i.e. it not have any space left to store a
 *                new item.
 *  $RETURN       True if the sub buffer is full, false if there is space for one ore more items.
 *
 **************************************************************************************************/
function bool subBufferFull() {
	return tail >= arrayCount(subBuffer);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the front item of the sub buffer. In case the queue is empty this function
 *                will return an empty string.
 *  $RETURN       The value at the front of the sub buffer.
 *
 **************************************************************************************************/
function string front() {
	if (subBufferEmpty()) {
		return "";
	} else {
		return subBuffer[head];
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the front element from the queue.
 *  $ENSURE       new.size() = max(0, old.size() - 1)
 *
 **************************************************************************************************/
function dequeue() {
	if (!subBufferEmpty()) {
		head++;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified value to the end of the buffer.
 *  $PARAM        data  The data that is to be added to the buffer.
 *  $ENSURE       new.size() = old.size() + 1
 *
 **************************************************************************************************/
function enqueue(string data) {
	if (subBufferFull()) {
		if (nextSubBuffer == none) {
			nextSubBuffer = spawn(class'NexgenQueueBuffer');
		}
		nextSubBuffer.enqueue(data);
	} else {
		subBuffer[tail++] = data;
	}
}




/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the number of items that are stored in the buffer.
 *  $RETURN       The number of items that are stored in the buffer.
 *  $ENSURE       result >= 0
 *
 **************************************************************************************************/
function int size() {
	local int count;
	
	count = tail - head;
	if (nextSubBuffer != none) {
		count += nextSubBuffer.size();
	}
	
	return count;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Resets the empty sub buffer so that it can be reused in the sub buffer chain.
 *  $REQUIRE      subBufferEmpty()
 *
 **************************************************************************************************/
function reset() {
	nextSubBuffer = none;
	head = 0;
	tail = 0;
}