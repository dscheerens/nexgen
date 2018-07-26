================================================================================
  NEXGEN SERVER CONTROLLER VERSION 1.12
  ZEROPOINT PRODUCTIONS, DECEMBER 2010
  D.SCHEERENS@GMAIL.COM
================================================================================



================================================================================
  TABLE OF CONTENTS.
================================================================================
 1. INTRODUCTION.
 2. QUICK INSTALLATION GUIDE.
 3. UPGRADING FROM A PREVIOUS VERSION.
 4. NEXGEN VERSION HISTORY.



================================================================================
  1. INTRODUCTION.
================================================================================
Nexgen is mod for dedicated Unreal Tournament servers to facilitate server
administration tasks. Rather than having the execute console commands or edit
configuration files, Nexgen allows server administrators to change settings and
perform actions in game via an user friendly interface. Nexgen also provides
several useful features that are commonly desired, such as spawn protection,
message logging and a ban system. The complete feature set is quite extensive
and can best be studied by looking at all the available options in the Nexgen
control panel interface. Finally Nexgen has support for plugins so that extra
features can be added.



================================================================================
  2. QUICK INSTALLATION GUIDE.
================================================================================
 1. Make sure your server has been shut down.
 
 2. Lookup the admin password in your servers configuration file. You'll need it
    later to configure Nexgen.
 
 3. Copy the following files to the system folder of your UT server: NexgenCC.u
    and Nexgen112.u
 
 4. If your server is using redirect upload the NexgenCC.u.uz and Nexgen112.u.uz
    files to the redirect server.
 
 5. Open your servers configuration file and add the following server packages:
 
      ServerPackages=NexgenCC
      ServerPackages=Nexgen112
 
    Also add the following server actor:
    
      ServerActors=Nexgen112.NexgenActor
  
 6. Save the changes to the configuration file and start the server. Note that
    the server controller will install itself automatically, so there is no ini
    file included with the Nexgen distribution.
 
 7. Start unreal and visit your server. If the installation was successful,
    Nexgen should now be running on your server.
 
 8. Now would be a good time to configure Nexgen. To do this open the control
    panel (say !open) and select admin login from the Client->Home tab. In the
    window that appears, enter your server administrator password (see step 2),
    and click on login.
 
 9. Once your password has been accepted a window will appear that tells you
    that your rights have been updated. Click the reconnect button to return to
    the server. Now you will have full access to all the tabs of the control
    panel. To configure your server goto the server tab and customize the
    settings to your preferences.



================================================================================
  3. UPGRADING FROM A PREVIOUS VERSION.
================================================================================
 1. Make sure your server has been shut down.
 
 2. Delete Nexgen1xx.u (where xx is the previous version of Nexgen) from your
    servers system folder and upload Nexgen112.u to the same folder.
 
 3. If your server is using redirect you may wish to delete Nexgen1xx.u.uz if it
    is no longer used by other servers. Also upload Nexgen112.u.uz to the
    redirect server.
 
 4. Open Nexgen.ini or your servers configuration file if the Nexgen settings
    are stored there.
 
 5. Do a search and replace where the string "Nexgen1xx." should be replaced
    with "Nexgen112." (without the quotes). Again the xx denotes the previous
    version of Nexgen that was installed on your server.
 
 6. If you upgrade from version 1.08 and below change the following setting
    keys:
      
       configEncryptionKey=
       configCodeScheme=
    
    to:
    
       configEncryptionKeys[0]=
       configCodeSchemes[0]=
    
    This step is very important. If you forget to do so, all passwords on your
    server become unusable.
 
 7. If you have Nexgen.ini opened save the changes and close the file. Now open
    the servers configuration file.
 
 8. Goto the [Engine.GameEngine] section and edit the server package and
    server actor lines for Nexgen. They should look like this:
       
       ServerActors=Nexgen112.NexgenActor
      
       ServerPackages=Nexgen112
 
 9. Save changes to the servers configuration file and close it.
 
10. Restart your server.
 


================================================================================
  4. NEXGEN VERSION HISTORY.
================================================================================

=== NEXGEN v1.12 ===============================================================
 - Fixed: Separate by tag function not working correctly.
 - Fixed: Compatibility check at server startup causing some servers to crash.
 - Fixed: Client controllers sometimes not receiving the client initialized signal.
 - Fixed: Nexgen alert windows not showing up.
 - Fixed: Nexgen control panel window from previous game not always properly closed.
 - Fixed: Auto reconnect not working if server restarts too fast.
 - Changed: The position of ipToCountry in the server actor list does no longer matter.
 - Changed: Players are no longer banned by their nickname.
 - Added: Queue and map data structures for the plugin framework.
 - Added: Client support for simple web services over HTTP POST requests.
 - Added: Button in match control tab to force the game to start.
 - Added: Support for reliable data transfer and flow control in client controllers.
 - Added: Data synchronization manager for plugins.
 - Added: Protection against brute force admin login attacks.
 - Added: Option to enable game start control only for match administrators (if they are present).

=== NEXGEN v1.11 ===============================================================
 - Fixed: Color codes not stripped from Nexgen messages if HUD extensions are disabled.
 - Fixed: Friendly fire scale setting not working even if team kill damage protect is disabled.
 - Fixed: Failed to load texture CountryFlags2.xx warnings in client side log.
 - Fixed: Exploit that could crash the server.
 - Changed: Team kill damage protector will no longer protect enemy damage.

=== NEXGEN v1.10 ===============================================================
 - Fixed: Several accessed none warnings in NexgenClient.
 - Fixed: Login timeout with diagnostics code 0x000000FF.
 - Fixed: Exploit that could crash the server.
 - Changed: New method for enabling the Nexgen HUD (should support more mods).
 - Added: Automatic adjustment of netspeed setting when a login timeout occurs.
 - Added: Moderator event signals for plugins.

=== NEXGEN v1.09 ===============================================================
 - Fixed: Nexgen treating MessagingSpectators as clients.
 - Fixed: Muted players could still send voice messages.
 - Fixed: Mapvote not appearing when the game is ended manually with Nexgen.
 - Fixed: Wrong Nexgen message HUD color in non team games.
 - Fixed: Accessed null class context in NexgenController.mutatorBroadcastLocalizedMessage().
 - Fixed: New players unable to use Nexgen if the match password is changed.
 - Fixed: Plugins not being notified when the server switches to another map.
 - Fixed: Security issue with passwords.
 - Fixed: Nexgen HUD not working with UTPure (Nexgen HUD will be forced).
 - Fixed: Players starting with a flag on their back with UTPure and tournament mode.
 - Fixed: Accessed none warnings in NexgenClient.timer().
 - Changed: Better support for plugins to modify the client login procedure.
 - Changed: Message flash effect is now disabled by default.
 - Added: Option to announce private messages to messaging spectators.
 - Added: A player recieves a message if a login timeout occurs instead of just connection failed.
 - Added: Option to use variable player slots (admin and vip slots will be disabled).
 - Added: HUD extension support for plugins.

=== NEXGEN v1.08 ===============================================================
 - Fixed: Typing prompt being cleared once the Nexgen client initializes.
 - Fixed: Player lists in the control panel being empty because of some rare bug in the Unreal Engine.
 - Fixed: Root admin login would give the player all privileges while some shouldn't be given.
 - Fixed: Login security issue when a player has a modified/hacked Nexgen package. 
 - Fixed: Value of 'Allow spectators to enter the game without a password' getting inverted.
 - Changed: No more false crash warning messages shown once the server was rebooted using Nexgen.
 - Changed: Increased account and ban list sizes.
 - Changed: User account lists are now sorted by account title in the accounts tab.
 - Added: Feature to view a players IP address and client ID in the moderator tab.
 - Added: Option to automatically register the server in the Nexgen server database.
 - Added: Better client controller synchronization support for the initialization process.

=== NEXGEN v1.07 ===============================================================
 - Fixed: Game never starts when game wait time is set to 0.
 - Fixed: Global and admin server password not being read from the servers config file.
 - Fixed: Removing an account type did not update the user account list.
 - Fixed: Changing a players name via the Nexgen control panel didn't update the player lists.
 - Fixed: Ban system not working anymore since version 1.06.
 - Changed: Maximum length of mutator list size increased (fixes the missing mutators issue).
 - Changed: Control panel height has been slightly increased.
 - Changed: Language variables have been changed to constants in order to reduce memory usage.
 - Changed: Improved performance of the configuration replication control subsystem.
 - Added: Option to prevent players from losing a frag when they switch to another team.
 - Added: Option to disable the Nexgen controlled game start.
 - Added: Support for tournament mode when Nexgen controlled game start is enabled.
 - Added: Special privilege to be able to ban players from the server that have an account.
 - Added: Option to enable / disable tournament mode.
 - Added: Map checking before loading a map during the boot phase.
 - Added: A warning message is shown once the server restarts after a crash.
 - Added: New privilege to hide a players admin status.
 - Added: Better support and control over the logging of administrator actions.
 - Added: Option to make Nexgen create log files.

=== NEXGEN v1.06 ===============================================================
 - Fixed: Accessed none warning in NexgenClient.setEncryptionParams().
 - Fixed: Unrelevant client controllers getting activated when viewing another player.
 - Fixed: Improper handling of players that disconnect before the Nexgen login procedure is complete.
 - Fixed: False 'enemy has the flag' messages shown in CTF games.
 - Fixed: Zone names shown when spectators use teamsay.
 - Fixed: Several plugin hooks not working correctly.
 - Fixed: Clients that have a different character set then the server can't initialize.
 - Fixed: Banning or kicking a player not working correctly if the player has an expired ban entry.
 - Changed: Admins or vips will no longer use free player slots.
 - Added: Support for the Nexgen message HUD for custom game types.
 - Added: Plugins can now also add client settings instead of only server settings.

=== NEXGEN v1.05 ===============================================================
 - Fixed: Custom game type description string not read from .int files.
 - Fixed: Zone names not appearing in the Nexgen HUD when using voice or teamsay commands.
 - Fixed: Some special messages aren't displayed in the center of the screen with the Nexgen HUD.
 - Fixed: Changing a players name doesn't save the name clientside in user.ini.
 - Fixed: Spectators not able to join a server when all player slots are used.
 - Changed: Plugin & GUI framework extended.
 - Added: Compatibility mode for UTPure.

=== NEXGEN v1.04 ===============================================================
 - Fixed: Game pauses during a match when a spectator leaves the game.
 - Fixed: Game not responding to certain events when the game is paused.
 - Fixed: Nexgen doesn't initialize clients joining a paused game.
 - Changed: Everyone can start the game even if an administrator is present, except in match mode.
 - Changed: Default player join and leave messages are suppressed.
 - Changed: Nexgen messages are displayed in a different color.
 - Added: Keybind for administrators to pause/unpause the game.
 - Added: Separate idle time counter for the time spend with an open control panel.
 - Added: A warning sound is played if the idle time remaining is below 15 seconds.
 - Added: A welcome message for player that are new to Nexgen.
 - Added: Retry button on the 'client ID already in use' dialog.

=== NEXGEN v1.03 ===============================================================
 - Fixed: Server crashes with: 'AActor::TestCanSeeMe'.
 - Fixed: Team balancer sometimes switches a player that has the flag.
 - Fixed: Duplicate client id's not detected.

=== NEXGEN v1.02 ===============================================================
 - Fixed: Teambalancer not working in some cases.
 - Fixed: Admins sometimes not being able to switch players to another team.
 - Fixed: Boot control panel not updated if settings are changed by another admin.
 - Changed: Increased player data storage capacity.
 - Changed: Account managers can no longer grant or revoke rights not owned by themself.
 - Changed: Account managers can no longer edit accounts of server administrators.
 - Added: Additional plugin hooks.
 - Added: Weapons can be excluded from cancelling spawn protection.
 - Added: Server reboot delay.
 - Added: !TEAMS and !GOLD commands.
 - Added: Control panel includes option to add and remove HUD class replacements.
 - Added: Additional right for allowing administrators to use the match setup control panel.
 - Added: A warning is displayed if a Nexgen.ini file is present at the client.

=== NEXGEN v1.01 ===============================================================
 - Fixed: Restarting a game changed the names of players.
 - Fixed: Player names sometimes not being colorized.
 - Fixed: Client crashes with "Assertion failed: Font".
 - Fixed: Mutator not showing up in the active mutator list.
 - Fixed: Changing a players name on v451 servers.
 - Fixed: Unable to enter a value in the separate by tags input fields.
 - Fixed: Spectators with a colon in their name can't execute message commands.
 - Fixed: Messages send by spectators written twice to the log.
 - Fixed: Chat messages send by spectators were not displayed in the chatbox.
 - Fixed: Various timings not being independent of the game speed.
 - Fixed: Joining spectators getting spawn protected.
 - Changed: The Nexgen window will now close once open mapvote is pressed.
 - Changed: No screenshot will be taken if a player has spend less then 30 seconds on the server.
 - Changed: Received private messages now include the admin title of the sender.
 - Added: A two second delay before a screenshot is taken automatically.
 - Added: Time remaining is displayed for games with a time limit in the Nexgen HUD.
 - Added: Encrypted password storage and transfer for enhanced server security.
 - Added: Mutator hooks to the plugin system.
 - Added: Option to reboot the server in the boot control tab.
 - Misc: First public release version of NEXGEN.

=== NEXGEN v1.00 ===============================================================
 - Misc: First public test version of NEXGEN.
 