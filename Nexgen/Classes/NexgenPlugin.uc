/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPlugin
 *  $VERSION      1.18 (26-4-2009 11:18:43)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen controller plugin. This is the base class used for nexgen plugins. The
 *                plugin is being setup from here. An instance of this class also receives events
 *                emitted by the Nexgen Server Controller.
 *
 **************************************************************************************************/
class NexgenPlugin extends Info abstract;

var NexgenController control;           // The Nexgen Server Controller instance.

var String pluginName;                  // Name of the plugin.
var String pluginAuthor;                // Who developed the plugin.
var String pluginVersion;               // Plugin version description.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Starts up the plugin. First the Nexgen controller is located. Once it has been
 *                found initialize() is called. If the initialization was successfull the plugin
 *                will be registered at the server controller. If any error occurs during the load
 *                process the plugin will be destroyed.
 *
 **************************************************************************************************/
function preBeginPlay() {	
	
	// Locate Nexgen Controller.
	foreach allActors(class'NexgenController', control) {
		if (control != none) {
			break;
		}
	}
	
	// Quit on error.
	if (control == none) {
		warn("CRITICAL EXCEPTION, Nexgen controller not detected.");
		destroy();
		return;
	}
	
	// Don't load on special mode.
	if (control.bSpecialMode) {
		destroy();
		return;
	}
	
	// Initialize plugin.
	control.nscLog(control.lng.format(control.lng.loadingPluginMsg, pluginName, pluginVersion));
	if (initialize()) {
		// Register plugin.
		if (!control.registerPlugin(self)) {
			// Failed to register, destroy instance.
			control.nscLog(control.lng.format(control.lng.regFailedMsg, string(self)));
			destroy();
		}
		
	} else {
		// Initialization failed, destroy instance.
		control.nscLog(control.lng.format(control.lng.initFailedMsg, string(self)));
		destroy();
	}
	
	// Make sure the checksums are up to date.
	control.sConf.updateDynamicChecksums();
	control.sConf.staticChecksum = control.sConf.calcStaticChecksum();	
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *
 **************************************************************************************************/
function bool initialize() {
	// To implement in subclass.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a new client has been created. Use this function to setup the new
 *                client with your own extensions (in order to support the plugin).
 *  $PARAM        client  The client that was just created.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function clientCreated(NexgenClient client) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a client is attempting to login. This allows to plugin to accept or
 *                reject the login request. If the function returns false the login request will be
 *                rejected (player will be disconnected). Please make sure the reason parameter
 *                is set in that case, as it will be written to the log.
 *  $PARAM        client      Client that is requesting to login to the server.
 *  $PARAM        rejectType  Reject type identification code.
 *  $PARAM        reason      Message describing why the login is rejected.
 *  $PARAM        popupWindowClass  Class name of the popup window that is to be shown at the client.
 *  $PARAM        popupArgs         Optional arguments for the popup window. Note you may have to
 *                                  explicitly reset them if you change the popupWindowClass.
 *  $REQUIRE      client != none
 *  $RETURN       True if the login request is accepted, false if it should be rejected.
 *  $ENSURE       result == false ? new.reason != "" : true
 *
 **************************************************************************************************/
function bool checkLogin(NexgenClient client, out name rejectType, out string reason,
                         out string popupWindowClass, out string popupArgs[4]) {
	// To implement in subclass.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever the login request of a player has been rejected and allows the
 *                plugin to modify the behaviour.
 *  $PARAM        client            The client that was denied access to the server.
 *  $PARAM        rejectType        Reject type identification code.
 *  $PARAM        reason            Reason why the player was rejected from the server.
 *  $PARAM        popupWindowClass  Class name of the popup window that is to be shown at the client.
 *  $PARAM        popupArgs         Optional arguments for the popup window. Note you may have to
 *                                  explicitly reset them if you change the popupWindowClass.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function modifyLoginReject(NexgenClient client, out name rejectType, out string reason,
                           out string popupWindowClass, out string popupArgs[4]) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a player has joined the game (after its login has been accepted).
 *  $PARAM        client  The player that has joined the game.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function playerJoined(NexgenClient client) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a client has finished its initialisation process. During this
 *                process things such as the remote control window are created. So only after the
 *                client is fully initialized all functions can be safely called.
 *  $PARAM        client  The client that has finished initializing.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function clientInitialized(NexgenClient client) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player (re)spawns and allows us to modify the player.
 *  $PARAM        client  The client of the player that was respawned.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function playerRespawned(NexgenClient client) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called if a player has left the server.
 *  $PARAM        client  The player that has left the game.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function playerLeft(NexgenClient client) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deals with a client that has switched to another team.
 *  $PARAM        client  The client that has changed team.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function playerTeamChanged(NexgenClient client) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Deals with a client that has changed his or her name.
 *  $PARAM        client             The client that has changed name.
 *  $PARAM        oldName            The old name of the player.
 *  $PARAM        bWasForcedChanged  Whether the name change was forced by the controller.
 *  $REQUIRE      client != none
 *
 **************************************************************************************************/
function playerNameChanged(NexgenClient client, string oldName, bool bWasForcedChanged) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game has started.
 *
 **************************************************************************************************/
function gameStarted() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game has ended.
 *
 **************************************************************************************************/
function gameEnded() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called to check if the specified message should be send to the given receiver.
 *  $PARAM        sender    The actor that has send the message.
 *  $PARAM        receiver  Pawn receiving the message.
 *  $PARAM        msg       The message that is to be send.
 *  $PARAM        bBeep     Whether or not to make a beep sound once received.
 *  $PARAM        type      Type of the message that is to be send.
 *  $RETURN       True if the message should be send, false if it should be suppressed.
 *
 **************************************************************************************************/
function bool mutatorBroadcastMessage(Actor sender, Pawn receiver, out coerce string msg,
                                      optional bool bBeep, out optional name type) {
	// To implement in subclass.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called to check if the specified team message should be send to the given
 *                receiver.
 *                is called if a message is send to player.
 *  $PARAM        sender    The actor that has send the message.
 *  $PARAM        receiver  Pawn receiving the message.
 *  $PARAM        pri       Player replication info of the sending player.
 *  $PARAM        s         The message that is to be send.
 *  $PARAM        type      Type of the message that is to be send.
 *  $PARAM        bBeep     Whether or not to make a beep sound once received.
 *  $RETURN       True if the message should be send, false if it should be suppressed.
 *
 **************************************************************************************************/
function bool mutatorTeamMessage(Actor sender, Pawn receiver, PlayerReplicationInfo pri,
                                 coerce string s, name type, optional bool bBeep) {
	// To implement in subclass.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called to check if the given localized message should be send to the specified
 *                receiver.
 *  $PARAM        sender          The actor that has send the message.
 *  $PARAM        receiver        Pawn receiving the message.
 *  $PARAM        message         The class of the localized message that is to be send.
 *  $PARAM        switch          Optional message switch argument.
 *  $PARAM        relatedPRI_1    PlayerReplicationInfo of a player that is related to the message.
 *  $PARAM        relatedPRI_2    PlayerReplicationInfo of a player that is related to the message.
 *  $PARAM        optionalObject  Optional object used to construct the message string.
 *  $REQUIRE      message != none
 *  $RETURN       True if the message should be send, false if it should be suppressed.
 *
 **************************************************************************************************/
function bool mutatorBroadcastLocalizedMessage(Actor sender, Pawn receiver,
                                               out class<LocalMessage> message,
                                               out optional int switch,
                                               out optional PlayerReplicationInfo relatedPRI_1,
                                               out optional PlayerReplicationInfo relatedPRI_2,
                                               out optional Object optionalObject) {
	// To implement in subclass.
	return true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player has send a mutate call to the server.
 *  $PARAM        mutateString  Mutator specific string (indicates the action to perform).
 *  $PARAM        sender        Player that has send the message.
 *
 **************************************************************************************************/
function mutate(string mutateString, PlayerPawn sender) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player attempts to login to the server. Allows mutators to modify
 *                some of the login parameters.
 *  $PARAM        spawnClass  The PlayerPawn class to use for the player.
 *  $PARAM        portal      Name of the portal where the player wishes to spawn.
 *  $PARAM        option      Login option parameters.
 *
 **************************************************************************************************/
function modifyLogin(out class<playerpawn> spawnClass, out string portal, out string options) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player (re)spawns and allows us to modify the player.
 *  $PARAM        other  The pawn/player that has (re)spawned.
 *  $REQUIRE      other != none
 *
 **************************************************************************************************/
function modifyPlayer(Pawn other) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a pawn takes damage.
 *  $PARAM        actualDamage  The amount of damage sustained by the pawn.
 *  $PARAM        victim        Pawn that has become victim of the damage.
 *  $PARAM        instigatedBy  The pawn that has instigated the damage to the victim.
 *  $PARAM        hitLocation   Location where the damage was dealt.
 *  $PARAM        momentum      Momentum of the damage that has been dealt.
 *  $PARAM        damageType    Type of damage dealt to the victim.
 *  $REQUIRE      victim != none
 *
 **************************************************************************************************/
function mutatorTakeDamage(out int actualDamage, Pawn victim, Pawn instigatedBy,
                           out vector hitLocation, out vector momentum, name damageType) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the server wants to check if a players death should be prevented.
 *  $PARAM        victim       The pawn that was killed.
 *  $PARAM        killer       The pawn that has killed the victim.
 *  $PARAM        damageType   Type of damage dealt to the victim.
 *  $PARAM        hitLocation  Location where the damage was dealt.
 *  $RETURN       True if the players death should be prevented, false if not.
 *
 **************************************************************************************************/
function bool preventDeath(Pawn victim, Pawn killer, name damageType, vector hitLocation) {
	// To implement in subclass.
	return false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a player was killed by another player.
 *  $PARAM        killer  The pawn that killed the other pawn. Might be none.
 *  $PARAM        victim  Pawn that was the victim.
 *
 **************************************************************************************************/
function scoreKill(Pawn killer, Pawn victim) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies this plugin that the server configuration has been updated.
 *  $PARAM        configType  Type of settings that have been changed.
 *
 **************************************************************************************************/
function configChanged(byte configType) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *
 **************************************************************************************************/
function notifyEvent(string type, optional string arguments) {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Plugin timer driven by the Nexgen controller. Ticks at a frequency of 1 Hz and is
 *                independent of the game speed.
 *
 **************************************************************************************************/
function virtualTimer() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the server is about to perform a server travel. Note that the server
 *                travel may fail to switch to the desired map. In that case the server will
 *                continue running the current game or a second notifyBeforeLevelChange() call may
 *                occur when trying to switch to another map. So be carefull what you do in this
 *                function!!!
 *
 **************************************************************************************************/
function notifyBeforeLevelChange() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles a potential command message.
 *  $PARAM        sender  PlayerPawn that has send the message in question.
 *  $PARAM        msg     Message send by the player, which could be a command.
 *  $REQUIRE      sender != none
 *  $RETURN       True if the specified message is a command, false if not.
 *
 **************************************************************************************************/
function bool handleMsgCommand(PlayerPawn sender, string msg) {
	return false;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game is executing it's first tick.
 *
 **************************************************************************************************/
function firstTick() {
	// To implement in subclass.
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	bAlwaysTick=true
}