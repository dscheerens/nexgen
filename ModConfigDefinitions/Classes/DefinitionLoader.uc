/***************************************************************************************************
 *
 *  Mod Configuration Definitions by Zeropoint.
 *
 *  $CLASS        DefinitionLoader
 *  $VERSION      1.00 (23-02-2010 20:19)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  This class automatically loads the mod configuration definitions for the mods
 *                that are currently running on the server.
 *
 **************************************************************************************************/
class DefinitionLoader extends Info;

var Actor mct;                          // The mod configuration tool.
var bool bFirstTickCompleted;           // Indicates whether the first tick has been executed.
var int definitionVersion;              // Version number of the definition package.
var string definitionDate;              // Date at which the definition package was compiled.

// Mod load flags.
var bool bStrangeLoveLoaded;
var bool bRevenge2Loaded;
var bool bDoubleJumpLoaded;
var bool bSmartCTF4Loaded;
var bool bMapVoteLA13Loaded;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer tick function. Called when the game performs its next tick.
 *                The following actions are performed:
 *                 - Loading the mod configuration definitions at the first tick.
 *  $PARAM        delta  Time elapsed (in seconds) since the last tick.
 *  $OVERRIDE     
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	disable('tick');
	if (!bFirstTickCompleted) {
		bFirstTickCompleted = true;
		loadModDefinitions();
		destroy();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the mod configuration definitions.
 *
 **************************************************************************************************/
function loadModDefinitions() {
	local Actor a;
	
	// Show header.
	log("Running Mod Definition loader build " $ definitionVersion $ " (" $ definitionDate $ ")...");
	
	// First get a reference to the mod configuration tool.
	foreach allActors(class'Actor', mct, 'ModConfigTool') {
		break;
	}
	
	// Get mod configuration tool instance.
	if (mct == none) {
		log("Unable to find mod configuration tool, no definitions loaded!");
		return;
	}
	
	// Find active mods.
	foreach allActors(class'Actor', a) {
		switch (string(a.class)) {
			// StrangeLove
			case "SLV203.SLConfig":   def_StrangeLove("SLV203",   "v2.03"); break;
			case "SLV203XM.SLConfig": def_StrangeLove("SLV203XM", "v2.03 Xmas Edition"); break;
			case "SLV204.SLConfig":   def_StrangeLove("SLV204",   "v2.04"); break;
			case "SLV204XM.SLConfig": def_StrangeLove("SLV204XM", "v2.04 Xmas Edition"); break;
			case "SLV205.SLConfig":   def_StrangeLove("SLV205",   "v2.05"); break;
			case "SLV205XM.SLConfig": def_StrangeLove("SLV205XM", "v2.05 Xmas Edition"); break;
			
			// SmartCTF 4
			case "SmartCTF_4D.SmartCTF": def_SmartCTF4("SmartCTF_4D", "4D"); break;
			case "SmartCTF_4E.SmartCTF": def_SmartCTF4("SmartCTF_4E", "4E"); break;
			
			// Other mods
			case "Revenge2.RevengeMutator": def_Revenge2(); break;
			case "DoubleJumpUT.DoubleJumpUT": def_DoubleJump(); break;
			case "MapVoteLA13.BDBMapVote": def_MapVoteLA13(); break;
		}
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the StrangeLove mod definitions.
 *
 **************************************************************************************************/
function def_StrangeLove(string pkg, string ver) {
	if (bStrangeLoveLoaded) return;
	mct.getItemName("REGISTER      SLV                                                               \"StrangeLove "$ver$"\"");
	mct.getItemName("ADD_VAR       SLV  CLIENT  "$pkg$".SLConfig  showKeys              BOOL         \"Show keyboard controls while flying\"");
	mct.getItemName("ADD_VAR       SLV  CLIENT  "$pkg$".SLConfig  showRearView          BOOL         \"Show rear view window while flying \"");
	mct.getItemName("ADD_VAR       SLV  CLIENT  "$pkg$".SLConfig  disableLaunchScream   BOOL         \"Disable alt fire rocket launch scream\"");
	mct.getItemName("ADD_VAR       SLV  CLIENT  "$pkg$".SLConfig  disableContrails      BOOL         \"Disable contrails behind rocket\"");
	mct.getItemName("ADD_VAR       SLV  CLIENT  "$pkg$".SLConfig  contrailRotate        BOOL         \"Rotate contrail segments\"");
	mct.getItemName("ADD_VAR       SLV  CLIENT  "$pkg$".SLConfig  showDamageSparks      BOOL         \"Show sparks when rocket takes damage\"");
	mct.getItemName("ADD_VAR       SLV  CLIENT  "$pkg$".SLConfig  contrailLifeTime      FLOAT        \"Contrail segment visibility duration in seconds\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  maxRockets            INT          \"Maximum amount of rockets that can be carried\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  giveMaxAmmo           BOOL         \"Give players maximum amount of rockets when they (re)spawn\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  maxFuelCores          INT          \"Maximum amount of fuel cores that can be carried\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  initialFuelCores      INT          \"Number of fuel cores given when players (re)spawn\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  fuelCoresPerLauncher  INT          \"Number of fuel cores given per rocket launcher pickup\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  maxFuel               FLOAT        \"Amount of rocket fuel stored in fuel cores\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  defSideArmMode        ENUM         \"Default fire mode of the yellowjacket sidearm\"");
	mct.getItemName("ADD_ENUM_VAL  SLV  SERVER  "$pkg$".SLConfig  defSideArmMode        FM_Single    \"Single shot\"");
	mct.getItemName("ADD_ENUM_VAL  SLV  SERVER  "$pkg$".SLConfig  defSideArmMode        FM_Burst     \"Burst shot\"");
	mct.getItemName("ADD_ENUM_VAL  SLV  SERVER  "$pkg$".SLConfig  defSideArmMode        FM_Auto      \"Automatic\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  rocketArmor           FLOAT        \"Strength of the armor on the rockets hull\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  teamDamage            FLOAT        \"Damage multiplier for friendly fire on rocket hull armor\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  warheadStatus         ENUM         \"Default warhead status for alternate fire\"");
	mct.getItemName("ADD_ENUM_VAL  SLV  SERVER  "$pkg$".SLConfig  warheadStatus         WH_Disarmed  \"Disarmed\"");
	mct.getItemName("ADD_ENUM_VAL  SLV  SERVER  "$pkg$".SLConfig  warheadStatus         WH_Auto      \"Automatic arming\"");
	mct.getItemName("ADD_ENUM_VAL  SLV  SERVER  "$pkg$".SLConfig  warheadStatus         WH_Armed     \"Armed\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  noArmedSwitch         BOOL         \"Disallow players to set the warhead to armed directly\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  canOverrideWarStat    BOOL         \"Allow players to change the warhead status\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  shockwaveSize         FLOAT        \"Maximum explosion size of detonated rockets\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  coloredDetonations    BOOL         \"Use team colorized rocket explosions\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  minSpeed              FLOAT        \"Lowest velocity at which rockets can fly\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  fullSpeed             FLOAT        \"Velocity at which rockets fly at full throttle\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  maxSpeed              FLOAT        \"Maximum velocity of rocket possible with afterburners enabled\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  enableBoosters        BOOL         \"Equip rockets with the ability to turbo boost\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  boosterSpeed          FLOAT        \"Maximum extra speed of rocket when the boosters are active\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  boosterFuel           FLOAT        \"Amount of booster fuel recieved by consuming fuel cores\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  noPilotTeamDamage     BOOL         \"Unguided rockets bounce off on explosions from same team\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  pilotCarryMode        ENUM         \"Allow rocket pilots to carry enemy flags\"");
	mct.getItemName("ADD_ENUM_VAL  SLV  SERVER  "$pkg$".SLConfig  pilotCarryMode        CM_Off       \"Yes\"");
	mct.getItemName("ADD_ENUM_VAL  SLV  SERVER  "$pkg$".SLConfig  pilotCarryMode        CM_Normal    \"No\"");
	mct.getItemName("ADD_ENUM_VAL  SLV  SERVER  "$pkg$".SLConfig  pilotCarryMode        CM_Compatibility  \"No (compatibility mode)\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  noYJ                  BOOL         \"Disable the Yellow Jacket sidearm\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  maxSidearmClips       INT          \"Maximum number of Yellow Jacket clips that can be carried\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  roundsPerClip         INT          \"Number of bullets contained in a Yellow Jacket clip\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  sidearmDamage         FLOAT        \"Amount of damage done by a Yellow Jacket bullet hit\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  randomSLVPlacement    BOOL         \"Randomly spawn launchers over time close to the flag bases\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  replacePacks          BOOL         \"Replace health packs in the level with fuel cores\"");
	mct.getItemName("ADD_VAR       SLV  SERVER  "$pkg$".SLConfig  replaceVials          BOOL         \"Replace health vials in the level with fuel cores\"");
	mct.getItemName("CLOSE         SLV");
	bStrangeLoveLoaded = true;
	notifyLoad("StrangeLove" @ ver);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the Revenge 2 mod definitions.
 *
 **************************************************************************************************/
function def_Revenge2() {
	if (bRevenge2Loaded) return;
	mct.getItemName("REGISTER  REVENGE                                                           \"Revenge 2\"");
	mct.getItemName("ADD_VAR   REVENGE  SERVER  Revenge2.RevengeMutator  scoreBonus        INT   \"Bonus score for taking revenge\"");
	mct.getItemName("ADD_VAR   REVENGE  SERVER  Revenge2.RevengeMutator  broadcastRevenge  BOOL  \"Broadcast revenge message to all players\"");
	mct.getItemName("CLOSE     REVENGE");
	bRevenge2Loaded = true;
	notifyLoad("Revenge 2");
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the Double Jump mod definitions.
 *
 **************************************************************************************************/
function def_DoubleJump() {
	if (bDoubleJumpLoaded) return;
	mct.getItemName("REGISTER      DOUBLEJUMP                                                        \"Double Jump\"");
	mct.getItemName("ADD_VAR       DOUBLEJUMP  SERVER  DoubleJumpUT.DoubleJumpUT  maxJumps    INT    \"Amount of jumps a player can do after another\"");
	mct.getItemName("ADD_VAR       DOUBLEJUMP  SERVER  DoubleJumpUT.DoubleJumpUT  jumpType    INT    \"Players ability to make a second jump\"");
	mct.getItemName("ADD_ENUM_VAL  DOUBLEJUMP  SERVER  DoubleJumpUT.DoubleJumpUT  jumpType    0      \"At apex\"");
	mct.getItemName("ADD_ENUM_VAL  DOUBLEJUMP  SERVER  DoubleJumpUT.DoubleJumpUT  jumpType    1      \"Going up and apex\"");
	mct.getItemName("ADD_ENUM_VAL  DOUBLEJUMP  SERVER  DoubleJumpUT.DoubleJumpUT  jumpType    2      \"Always\"");
	mct.getItemName("ADD_VAR       DOUBLEJUMP  SERVER  DoubleJumpUT.DoubleJumpUT  jumpHeight  FLOAT  \"Height of the second jump relative to the normal jump height\"");
	mct.getItemName("CLOSE         DOUBLEJUMP");
	bDoubleJumpLoaded = true;
	notifyLoad("Double Jump");
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the SmartCTF 4 mod definitions.
 *
 **************************************************************************************************/
function def_SmartCTF4(string pkg, string ver) {
	if (bSmartCTF4Loaded) return;
	mct.getItemName("REGISTER      SMARTCTF                                                                \"SmartCTF "$ver$"\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bEnabled                    BOOL    \"Enable SmartCTF game extensions\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bExtraStats                 BOOL    \"Display extra statistics on scoreboard (DefKills & Seals)\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  CountryFlagsPackage         STRING  \"Name of package that contains the country flag images\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  CapBonus                    INT     \"Bonus score for capturing a flag\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  AssistBonus                 INT     \"Bonus score for assisting in a flag capture\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  FlagKillBonus               INT     \"Bonus score for killing a flag carrier\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverBonus                  INT     \"Bonus score for covering a flag carrier\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  SealBonus                   INT     \"Bonus score for sealing the base from enemies\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  GrabBonus                   INT     \"Bonus score for grabbing an enemy flag\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  BaseReturnBonus             FLOAT   \"Bonus score for returning the flag within your base\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  MidReturnBonus              FLOAT   \"Bonus score for returning the flag in the middle of the map\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  EnemyBaseReturnBonus        FLOAT   \"Bonus score for returning the flag in the enemy base\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  CloseSaveReturnBonus        FLOAT   \"Bonus score for a close save of the flag\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  SpawnKillPenalty            INT     \"Score penalty for making a spawn kill\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  MinimalCapBonus             INT     \"Minimal bonus score for making a flag capture\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bFixFlagBug                 BOOL    \"Drop flag when flag carrier disconnects from server\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bEnhancedMultiKill          BOOL    \"Enable enhanced multikill messages\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  EnhancedMultiKillBroadcast  BYTE    \"Level at which multikill messages should be broadcasted\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  EnhancedMultiKillBroadcast  0       \"Disabled\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  EnhancedMultiKillBroadcast  2       \"Double Kill\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  EnhancedMultiKillBroadcast  3       \"Triple Kill\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  EnhancedMultiKillBroadcast  4       \"Multi Kill\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  EnhancedMultiKillBroadcast  5       \"Mega Kill\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  EnhancedMultiKillBroadcast  6       \"Ultra Kill\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  EnhancedMultiKillBroadcast  7       \"Monster Kill\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bShowFCLocation             BOOL    \"Display location of the players team own flagcarrier\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bSmartCTFServerInfo         BOOL    \"Show enhanced server information under F2\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bNewCapAssistScoring        BOOL    \"Enable new scoring system for captures and assists\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bSpawnkillDetection         BOOL    \"Detect spawnkills and show spawnkill messages\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  SpawnKillTimeArena          FLOAT   \"Spawn kill detection time for arena games\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  SpawnKillTimeNW             FLOAT   \"Spawn kill detection time for normal weapon games\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bAfterGodLikeMsg            BOOL    \"Enable the additional killingspree message after Godlike\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bStatsDrawFaces             BOOL    \"Show avatars on the scoreboard\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bDrawLogo                   BOOL    \"Show SmartCTF logo when a player joins the server\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverMsgType                BYTE    \"Show '... covered the flagcarrier!' message on\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverMsgType                0       \"Nowhere (disabled)\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverMsgType                1       \"Players console only\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverMsgType                2       \"Console of all players\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverMsgType                3       \"HUD of all players\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverSpreeMsgType           BYTE    \"Show '... is on a multi cover / cover spree !' message on\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverSpreeMsgType           0       \"Nowhere (disabled)\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverSpreeMsgType           1       \"Players console only\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverSpreeMsgType           2       \"Console of all players\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  CoverSpreeMsgType           3       \"HUD of all players\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  SealMsgType                 BYTE    \"Show '... is sealing off the base!' message on\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  SealMsgType                 0       \"Nowhere (disabled)\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  SealMsgType                 1       \"Players console only\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  SealMsgType                 2       \"Console of all players\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  SealMsgType                 3       \"HUD of all players\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  SavedMsgType                BYTE    \"Show 'Saved By ...!' message on\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  SavedMsgType                0       \"Nowhere (disabled)\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  SavedMsgType                1       \"Players console only\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  SavedMsgType                2       \"Console of all players\"");
	mct.getItemName("ADD_ENUM_VAL  SMARTCTF  SERVER  "$pkg$".SmartCTF  SavedMsgType                3       \"HUD of all players\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bShowLongRangeMsg           BOOL    \"Display long range kill messages for kills over huge distances\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bShowSpawnKillerGlobalMsg   BOOL    \"Announce spawnkills to all players\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bShowAssistConsoleMsg       BOOL    \"Show reward for flag capture message on players console\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bShowSealRewardConsoleMsg   BOOL    \"Show reward for sealing the base message on players console\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bShowCoverRewardConsoleMsg  BOOL    \"Show reward for covering the flagcarrier message on console\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bPlayCaptureSound           BOOL    \"Play 'Capture' sound at a flag capture\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bPlayAssistSound            BOOL    \"Play 'Assist' sound when you have assisted in a flag capture\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bPlaySavedSound             BOOL    \"Play 'Nice Catch!' sound if you do a flagsave\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bPlayLeadSound              BOOL    \"Play taken the lead or lost the lead sounds on flag captures\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bPlay30SecSound             BOOL    \"Play missing 30 seconds remaining sound\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bEnableOvertimeControl      BOOL    \"Enable control over Sudden Death Overtime\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bRememberOvertimeSetting    BOOL    \"Disable auto reset of overtime at each map change\"");
	if (pkg ~= "SmartCTF_4E") { // SmartCTF 4E extensions:
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bSCTFSbDef                  BOOL    \"Show SmartCTF scoreboard instead of original by default\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bShowSpecs                  BOOL    \"Display spectators on the SmartCTF scoreboard\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bDoKeybind                  BOOL    \"Automatically create a keybind to toggle between the scoreboards\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bExtraMsg                   BOOL    \"Show players a message for the automatically created keybind\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  SbDelay                     FLOAT   \"Initialization delay for the scoreboard on the client\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  MsgDelay                    FLOAT   \"Welcome message delay in seconds\"");
	mct.getItemName("ADD_VAR       SMARTCTF  SERVER  "$pkg$".SmartCTF  bStoreStats                 FLOAT   \"Restore extended player stats after a reconnect\"");
	}
	mct.getItemName("CLOSE         SMARTCTF");
	bSmartCTF4Loaded = true;
	notifyLoad("SmartCTF" @ ver);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the MapVoteLA 13 mod definitions.
 *
 **************************************************************************************************/
function function def_MapVoteLA13() {
	if (bMapVoteLA13Loaded) return;
	mct.getItemName("REGISTER      MPVTLA13                                                                          \"MapVoteLA 13\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bAutoDetect                     BOOL    \"Automatically detect game type that is being played\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bDM                             BOOL    \"Create map list for Death Match games\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bLMS                            BOOL    \"Create map list for Last Man Standing games\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bTDM                            BOOL    \"Create map list for Team Death Match games\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bDOM                            BOOL    \"Create map list for Domination games\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bCTF                            BOOL    \"Create map list for Capture The Flag games\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bAS                             BOOL    \"Create map list for Assault games\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bSortWithPreFix                 BOOL    \"Include prefix when sorting maps by name\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  ASClass                         STRING  \"Assault game type class name\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  VoteTimeLimit                   INT     \"Amount of time available to vote for a map in seconds\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  KickPercent                     INT     \"Percentage of players needed to kick vote a player\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bUseMapList                     BOOL    \"Use map Unreal Tournaments default map cycle lists\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  ScoreBoardDelay                 INT     \"Amount of time to show the scoreboard before starting mapvote\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bAutoOpen                       BOOL    \"Automatically open mapvote window once map voting begins\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bKickVote                       BOOL    \"Enable players to kickvote other players\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bShowWhoKicksWho                BOOL    \"Show which player has place a kickvote for another player\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bCheckOtherGameTie              BOOL    \"Check custom games for ties at the end of the match\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  RepeatLimit                     INT     \"Number of last played maps to exclude from voting\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MapListIfNooneVoted             INT     \"Map list to use if no player has voted for a map\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MapVoteHistoryType              STRING  \"Map vote history list to use\"");
	mct.getItemName("ADD_ENUM_VAL  MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MapVoteHistoryType              MapVoteLA13.MapVoteHistory1");
	mct.getItemName("ADD_ENUM_VAL  MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MapVoteHistoryType              MapVoteLA13.MapVoteHistory2");
	mct.getItemName("ADD_ENUM_VAL  MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MapVoteHistoryType              MapVoteLA13.MapVoteHistory3");
	mct.getItemName("ADD_ENUM_VAL  MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MapVoteHistoryType              MapVoteLA13.MapVoteHistory4");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  ServerInfoURL                   STRING  \"URL of the website containing information about the server\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MapInfoURL                      STRING  \"Map Information Web Server URL\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MidGameVotePercent              INT     \"Percentage of players needed to initiate mid game voting\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  Mode                            STRING  \"Mapvote map selection mode\"");
	mct.getItemName("ADD_ENUM_VAL  MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  Mode                            Majority");
	mct.getItemName("ADD_ENUM_VAL  MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  Mode                            Elimination");
	mct.getItemName("ADD_ENUM_VAL  MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  Mode                            Score");
	mct.getItemName("ADD_ENUM_VAL  MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  Mode                            Accumulation");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MinMapCount                     INT     \"Minimum remaining maps allowed in elimination mode\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bRemoveCrashedMaps              BOOL    \"Remove maps on which the server has crashed from the map list\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bEntryWindows                   BOOL    \"Automatically open welcome or vote window when joining\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bDebugMode                      BOOL    \"Enable debug mode\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bEnableEmptyServerLevelSwitch   BOOL    \"Enable automatic map switch when server is empty\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  EmptyServerLevelSwitchTimeMins  INT     \"Number of minutes the map needs to be empty before switching\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bReloadMapsOnRequestOnly        BOOL    \"Reload maps on request only (manual reload)\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bFixCTFModifications            BOOL    \"Detect MultiCTF mod and create CTFM prefixes\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  MapVoteTitle                    STRING  \"Mapvote window title\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  LogoTexture                     STRING  \"Texture of logo to display on the mapvote window\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  List1Priority                   FLOAT   \"Priority of map list 1\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  List2Priority                   FLOAT   \"Priority of map list 2\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  List3Priority                   FLOAT   \"Priority of map list 3\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  List4Priority                   FLOAT   \"Priority of map list 4\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  List1Title                      STRING  \"Title displayed above map list 1\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  List2Title                      STRING  \"Title displayed above map list 2\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  List3Title                      STRING  \"Title displayed above map list 3\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  List4Title                      STRING  \"Title displayed above map list 4\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bList1ObeyRepeatLimit           BOOL    \"Use repeat limit for map list 1\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bList2ObeyRepeatLimit           BOOL    \"Use repeat limit for map list 2\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bList3ObeyRepeatLimit           BOOL    \"Use repeat limit for map list 3\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bList4ObeyRepeatLimit           BOOL    \"Use repeat limit for map list 4\"");
	mct.getItemName("ADD_VAR       MPVTLA13  SERVER  MapVoteLA13.BDBMapVote  bUseExcludeFilter               BOOL    \"Enable map exlusion filter\"");
	mct.getItemName("CLOSE         MPVTLA13");
	bMapVoteLA13Loaded = true;
	notifyLoad("MapVoteLA13");
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the system that the mod definitions for the specified mod have been loaded.
 *  $PARAM        title  The name of the mod whose definitions have been loaded.
 *
 **************************************************************************************************/
function notifyLoad(string title) {
	log("Loaded definitions for " $ title);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	definitionVersion=1012
	definitionDate="14-12-2010"
}