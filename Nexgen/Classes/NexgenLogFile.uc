/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenLogFile
 *  $VERSION      1.01 (17-6-2008 13:53)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Class that handles the writing of Nexgen logs to a file.
 *
 **************************************************************************************************/
class NexgenLogFile extends NexgenTextFile;

var NexgenController control;           // The Nexgen controller.
var NexgenLang lng;                     // The language support instance.

var string timeStampFormat;             // Time stamp format used.

const defaultLogFileExtension = "log";  // The default log file extension, if none is specified.
const tempLogFileExtension = "tmp";     // File extension for temp files.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the log file. Start the log based on the settings contained by the
 *                NexgenConfig object in the Nexgen server controller (control.sConf). If the log
 *                file was successfully created bIsOpen will be set to true.
 *  $REQUIRE      owner != none && owner.isA('NexgenController')
 *
 **************************************************************************************************/
function preBeginPlay() {
	local string logFilePath;
	local string logFileName;
	local string logFileExtension;
	
	local string tempLogFile;
	local string logFile;
	
	local bool bSuccess;
	
	super.preBeginPlay();
	
	// Get controller.
	control = NexgenController(owner);
	lng = control.lng;
	
	// Construct log file name.
	logFileName = class'NexgenUtil'.static.autoFormat(control, control.sConf.logFileNameFormat);
	logFileName = class'NexgenUtil'.static.validateFileName(logFileName);
	if (logFileName != "") {
		logFileExtension = class'NexgenUtil'.static.trim(control.sConf.logFileExtension);
		if (left(logFileExtension, 1) == ".") {
			logFileExtension = mid(logFileExtension, 1);
		}
		
		if (logFileExtension == "") {
			logFileExtension = defaultLogFileExtension;
		}
		
		logFilePath = class'NexgenUtil'.static.trim(control.sConf.logPath);
		if (logFilePath != "") {
			logFilePath = class'NexgenUtil'.static.replace(logFilePath, "\\", "/");
			if (right(logFilePath, 1) == "/") {
				logFilePath = left(logFilePath, len(logFilePath) - 1);
			}
		}
		
		logFile = logFilePath $ "/" $ logFileName $ "." $ logFileExtension;
		tempLogFile = logFile $ "." $ tempLogFileExtension;
	}
	
	// Open the log file.
	bSuccess = openFile(tempLogFile, logFile);
	if (bSuccess) {
		timeStampFormat = control.sConf.logFileTimeStampFormat;
		beginLog();
		control.nscLog(lng.format(lng.logFileCreated, tempLogFile));
	} else {
		control.nscLog(lng.format(lng.logFileCreateFailed, logFileName));
		//destroy();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Writes the log header.
 *
 **************************************************************************************************/
function beginLog() {
	local NexgenLogEntry logEntry;
	local string logLine;
	
	// Write header.
	println(lng.logFileTitle, true);
	println("", true);
	println(lng.format(lng.logFileEngineVersion, level.engineVersion), true);
	println(lng.format(lng.logFileNexgenVersion, class'NexgenCorePlugin'.default.pluginVersion), true);
	println(lng.format(lng.logFileServerID, class'NexgenUtil'.static.formatGUID(control.sConf.serverID)), true);
	println(lng.format(lng.logFileServerName, control.sConf.serverName), true);
	println(lng.format(lng.logFileServerPort, level.game.getServerPort()), true);
	println(lng.format(lng.logFileGameClass, level.game.class), true);
	println(lng.format(lng.logFileLevelName, class'NexgenUtil'.static.getLevelFileName(level)), true);
	println(lng.format(lng.logFileLevelTitle, level.summary.title), true);
	println("", true);
	println(lng.format(lng.logFileStart, lng.getCurrentDate(lng.longDateTimeFormat)), true);
	println("", true);
	
	// Write buffered logs.
	for (logEntry = control.logBuffer; logEntry != none; logEntry = logEntry.nextLogEntry) {
		logLine = control.getLogTypeTag(logEntry.type) @ logEntry.message;
		if (timeStampFormat != "") {
			logLine = lng.getDate(timeStampFormat,
			                      logEntry.year,
			                      logEntry.month,
			                      logEntry.day,
			                      logEntry.dayOfWeek,
			                      logEntry.hour,
			                      logEntry.minute,
			                      logEntry.second) @ logLine;
		}
		println(logLine, true);
	}
	
	// Flush output.
	flush();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Ends the log file.
 *  $ENSURE       !bIsOpen
 *
 **************************************************************************************************/
function endLog() {
	if (bIsOpen) {
		println("", true);
		println(lng.format(lng.logFileClose, lng.getCurrentDate(lng.longDateTimeFormat)), true);
		closeFile();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new entry to the log file.
 *  $PARAM        msg      Message that should be written to the log.
 *  $PARAM        logType  The type of log message.
 *
 **************************************************************************************************/
function addLog(string msg, optional byte logType) {
	if (bIsOpen) {
		if (timeStampFormat == "") {
			println(control.getLogTypeTag(logType) @ msg);
		} else {
			println(lng.getCurrentDate(timeStampFormat) @ control.getLogTypeTag(logType) @ msg);
		}
	}
}



