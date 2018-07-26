/***************************************************************************************************
 *
 *  NGLS. Nexgen Global Login System by Zeropoint.
 *
 *  $CLASS        NGLSLang
 *  $VERSION      1.03 (21-11-2008 0:21)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Localization support class.
 *
 **************************************************************************************************/
class NGLSLang extends Info;

const nglsLogTag = "[NGLS]";

const invalidConfigMsg = "NexgenGLS configuration file was corrupt and has been repaired.";

const loginFailedMsg = "Login for %1 has failed, reason: %2.";
const loginFailedWithDisconnectMsg = "Login for %1 has failed, reason: %2, disconnecting client...";
const loginTimeoutMsg = "timeout";
const loginVerifyFailedMsg = "unable to verify username and password";
const loginNoUsernameMsg = "no username entered";
const loginNoPasswordMsg = "no password entered";

const loginInfoReceivedMsg = "Login request for %1";
const loginUsernameMsg = "Username = %1";
const loginPasswordMsg = "Password = %1 (MD5)";

const loginAcceptedMsg = "Login for %1 accepted.";

const startCheckMsg = "Checking login for %1 with NGLS master server...";

const loginCheckInvalidServerAddressMsg = "Invalid NGLS master server address.";
const loginCheckTimeoutMsg = "Can't connect to the NGLS master server.";
const loginCheckOpenConnectionFailedMsg = "Unable to open a new connection to the NGLS master server.";
const loginCheckScriptMissingMsg = "Login verification script not found on NGLS master server.";
const loginCheckIOErrorMsg = "Communication error with NGLS master server, error code: %1.";

const nglsSettingsPanelTitle = "Nexgen Global Login System - General settings";

const enableNGLSTxt = "Enable the global login system";
const acceptLocalAccountsTxt = "Accept players with a local Nexgen account";
const allowUnregisteredSpecsTxt = "Allow unregistered spectators to join";
const disconnectClientWhenVerifyFailsTxt = "Disconnect player when login check fails";
const nglsServerHostTxt = "Host";
const nglsServerPortTxt = "Port";
const nglsServerPathTxt = "Script path";
const loginTimeoutTxt = "Login timeout";
const registerURLTxt = "Register URL";

const adminUpdateGeneralSettingsMsg = "<C07>%1 has modified the Nexgen Global Login System settings.";