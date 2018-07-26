/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenTextFile
 *  $VERSION      1.01 (17-6-2008 13:53)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  General purpose class to support writing to text files.
 *
 **************************************************************************************************/
 class NexgenTextFile extends StatLogFile;
 
 var bool bIsOpen;            // Whether the text file is open.
 
 
  
/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when this object is spawned.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function beginPlay() {
    // Do nothing, just prevent setTimer() from being called.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates a new text file. Initially the file will be named 'tempFileName'. Once the
 *                file is closed it will be renamed to 'fileName'.
 *  $RETRUN       True if the text file was successfully opened, false if it failed.
 *  $ENSURE       imply(result == true, bIsOpen)
 *
 **************************************************************************************************/
function bool openFile(string tempFileName, string fileName) {
	if (tempFileName == "" || fileName == "" || bIsOpen) {
		return false;
	}
	
	statLogFile = tempFileName;
	statLogFinal = fileName;
	openLog();
	
	bIsOpen = true;
	
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Closes the file. Before the file is closed any buffered text will be flushed.
 *
 **************************************************************************************************/
function closeFile() {
	if (bIsOpen) {
		fileFlush();
		closeLog();
		bIsOpen = false;
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Writes a new line to the text file.
 *  $PARAM        text      The text that is to be written to the file
 *  $PARAM        bNoFlush  Whether the text should be buffered, instead of written immediately.
 *
 **************************************************************************************************/
function println(string text, optional bool bBuffer) {
	if (bIsOpen) {
		logEventString(text);
		if (!bBuffer) fileFlush();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Flushes the buffer. Any text remaining in the buffer will be written to the file.
 *
 **************************************************************************************************/
function flush() {
	if (bIsOpen) {
		fileFlush();
	}
}
