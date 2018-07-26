/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenLogEntry
 *  $VERSION      1.00 (16-6-2008 11:31)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Class that describes a log entry.
 *
 **************************************************************************************************/
class NexgenLogEntry extends info;

var NexgenLogEntry nextLogEntry;        // Next log entry.

var string message;                     // The log message.

var byte type;                          // The type of message.

var int year;                           // Year when the message was generated.
var int month;                          // Month when the message was generated.
var int day;                            // Day when the message was generated.
var int dayOfWeek;                      // Day of the week when the message was generated.
var int hour;                           // Hour when the message was generated.
var int minute;                         // Minute when the message was generated.
var int second;                         // Second when the message was generated.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the NexgenLogEntry was destroyed. Destroys the next log entry.
 *  $ENSURE       nextLogEntry == none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function destroyed() {
	if (nextLogEntry != none) {
		nextLogEntry.destroy();
		nextLogEntry = none;
	}
}
