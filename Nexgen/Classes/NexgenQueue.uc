/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenQueue
 *  $VERSION      1.01 (22-02-2010 23:09)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  FIFO queue data structure implementation for Unreal Tournament. In theory this
 *                queue can hold an 'infinitely' amount of strings. It is only bounded by the amount
 *                of memory that is available for the program.
 *
 **************************************************************************************************/
class NexgenQueue extends info;

var NexgenQueueBuffer buffer;              // Buffer that holds the data.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Tests whether the queue is empty, i.e. it does not contain any data.
 *  $RETURN       True if the queue is empty, false if it contains one ore more items.
 *
 **************************************************************************************************/
function bool empty() {
	return size() == 0;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the front item of the queue. In case the queue is empty this function will
 *                return an empty string.
 *  $RETURN       The value at the front of the queue.
 *
 **************************************************************************************************/
function string front() {
	if (buffer == none) {
		return "";
	} else {
		return buffer.front();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes the front element from the queue.
 *  $ENSURE       new.size() = max(0, old.size() - 1)
 *
 **************************************************************************************************/
function dequeue() {
	local NexgenQueueBuffer emptySubBuffer;
	local NexgenQueueBuffer lastSubBuffer;
	
	if (buffer != none) {
		buffer.dequeue();
		
		// Check if buffer is empty.
		if (buffer.subBufferEmpty()) {
			// Check if the next subbuffer contains data.
			if (buffer.nextSubBuffer != none && !buffer.nextSubBuffer.subBufferEmpty()) {
				// Yes, so head buffer has to be placed at the end of the sub buffer list.
				emptySubBuffer = buffer;
				
				// Update head buffer.
				buffer = buffer.nextSubBuffer;
				
				// Find last sub buffer.
				lastSubBuffer = buffer;
				while (lastSubBuffer.nextSubBuffer != none) {
					lastSubBuffer = lastSubBuffer.nextSubBuffer;
				}
				
				// Set old head buffer as new last sub buffer.
				emptySubBuffer.reset();
				lastSubBuffer.nextSubBuffer = emptySubBuffer;
			
			} else {
				// No, the head buffer can be safely reset.
				buffer.reset();
			}
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds the specified value to the end of the queue.
 *  $PARAM        data  The data that is to be added to the queue.
 *  $ENSURE       new.size() = old.size() + 1
 *
 **************************************************************************************************/
function enqueue(string data) {
	if (buffer == none) {
		buffer = spawn(class'NexgenQueueBuffer');
	}
	
	buffer.enqueue(data);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the number of items that are stored in the queue.
 *  $RETURN       The number of items that are stored in the queue.
 *  $ENSURE       result >= 0
 *
 **************************************************************************************************/
function int size() {
	if (buffer == none) {
		return 0;
	} else {
		return buffer.size();
	}
}