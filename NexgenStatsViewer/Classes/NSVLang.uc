/***************************************************************************************************
 *
 *  Nexgen statistics viewer by Zeropoint.
 *
 *  $CLASS        NSVLang
 *  $VERSION      1.01 (23-6-2008 21:24)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Localization support class.
 *
 **************************************************************************************************/
class NSVLang extends Info;

const utstatsRetrieveFailedMsg = "Failed to retrieve statistics from UTStats server, error returned: %1";

const invalidConfigMsg = "NexgenStatsViewer configuration file was corrupt and has been repaired.";

const adminUpdateUTStatsClientSettingsMsg = "<C07>%1 Has modified the UTStats client settings.";

const utstatsClientSettingsPanelTitle = "Nexgen Stats Viewer - UTStats client settings";
const enableUTStatsClientTxt = "Enable UTStats client";
const utStatsHostMsg = "Host";
const utStatsPortMsg = "Port";
const utStatsPathMsg = "Script path";