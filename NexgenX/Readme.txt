================================================================================
  NEXGEN SERVER CONTROLLER EXTENSION VERSION 1.11
  ZEROPOINT PRODUCTIONS, DECEMBER 2009
  D.SCHEERENS@GMAIL.COM
================================================================================



================================================================================
  TABLE OF CONTENTS.
================================================================================
 1. INTRODUCTION.
 2. QUICK INSTALLATION GUIDE.
 3. UPGRADING FROM A PREVIOUS VERSION.
 4. NEXGENX VERSION HISTORY.
 
 

================================================================================
  1. INTRODUCTION.
================================================================================
The Nexgen server controller extension is a plugin that adds new features to the
server. The following extensions are provided by this plugin:

 - A map switch tab is added for match administrators.
 
 - Player protection overlay effect. While a player is protected a shield is
   displayed around the player.
   
 - Team overlay effect. If the player isn't protected the players skin will be
   slightly colorized, depending on the team of the player.
   
 - A voice announcer counts down when the game is starting.
 
 - Player frag/score recovery. When a player leaves the server, his/her score
   will be remembered, so it can be restored once the player rejoins the server.
 
 - Adds the !stats command to the server, which toggles between the SmartCTF and
   normal scoreboard if the SmartCTF mutator is running.
 
 - Full server redirect. When your server is full players trying to join it will
   be promted with a dialog that can redirect them to other servers. It is also
   possible to send them to another server automatically.
   
 - A fix for the bug in Unreal Tournament that sometimes may cause a server to
   crash at the end of the game, because of an infinite loop in
   PlayerPawn.ViewPlayerNum().
   
 - Option to make AKA log client ID's. Note this will require the custom AKA
   logger that comes with ASC. For convenience it will also be included with the
   NexgenX package.
   
 - A match control tab that offers additional options to change the settings
   of the current.
   
 - Clan tag protection. With this feature it possible to prevent players on your
   server from using your clan tag. When enabled only players that have an
   account on the server are allowed to use such a tag.
   
 - Option to automatically notify server administrators when a new version of
   Nexgen is available.
 
 - Server rules. If enabled a new tab appears under the server section in the
   Nexgen control panel which displays the rules of the server. The rules can be
   specified in the plugin configuration settings tab. Moderators will receive
   the ability to force players to view the rules, very usefull if someone
   breaks the rules.
 
 - Option to disable the default anti-spam feature of Unreal Tournament.
 
 - Server peformance optimizer. If enabled the server will attempt to optimize
   it's performance when it is idle. The performance is optimized by collecting
   and purging garbage to free memory.

 - Ping and time status boxes. When enabled status boxes displaying the players
   ping and the time remaining or elapsed time are shown in the HUD.
   


================================================================================
  2. QUICK INSTALLATION GUIDE.
================================================================================
 1. Make sure your server has been shut down.
 
 2. Copy the NexgenX111.u file to the system folder of your UT server.
 
 3. If your server is using redirect upload the NexgenX111.u.uz file to the
    redirect server.
 
 4. Open your servers configuration file and add the following server package:
 
      ServerPackages=NexgenX111
 
    Also add the following server actor:
    
      ServerActors=NexgenX111.NexgenX
      
    Note that the actor should be added AFTER the Nexgen controller server actor
    (ServerActors=Nexgen111.NexgenActor).
  
 5. Save the changes to the configuration file and start the server. The
    extension plugin should now be active on your server.



================================================================================
  3. UPGRADING FROM A PREVIOUS VERSION.
================================================================================
 1. Make sure your server has been shut down.
 
 2. Delete NexgenX1xx.u (where xx is the previous version of NexgenX) from your
    servers system folder and upload NexgenX111.u to the same folder.
 
 3. If your server is using redirect you may wish to delete NexgenX1xx.u.uz if
    it is no longer used by other servers. Also upload NexgenX111.u.uz to the
    redirect server.
 
 4. Open Nexgen.ini or your servers configuration file if the Nexgen settings
    are stored there.
 
 5. Do a search and replace where the string "NexgenX1xx." should be replaced
    with "NexgenX111." (without the quotes). Again the xx denotes the previous
    version of NexgenX that was installed on your server.
 
 6. If you have Nexgen.ini opened save the changes and close the file. Now open
    the servers configuration file.

 7. Goto the [Engine.GameEngine] section and edit the server package and
    server actor lines for NexgenX. They should look like this:
       
       ServerActors=NexgenX111.NexgenX
      
       ServerPackages=NexgenX111
 
 8. Save changes to the servers configuration file and close it.
 
 9. Restart your server.


 
================================================================================
  4. NEXGENX VERSION HISTORY.
================================================================================

=== NEXGENX v1.11 ==============================================================
 - Fixed: Exploit that could crash the server.
 
=== NEXGENX v1.10 ==============================================================
 - Fixed: Unable to save the server rules if too many characters are used.
 
=== NEXGENX v1.09 ==============================================================
 - Fixed: High server load when match administrators join.
 - Changed: When the last bot is removed from the game MinPlayers is set to 0.
 - Added: Option to disable the buildin anti-spam feature of UT.
 - Added: Server performance optimizer.
 - Added: Option to display the players ping in the HUD.
 - Added: Option to display the remaining time or elapsed time in the HUD.
 - Added: Option to automatically redirect a player when the server is full.
 
=== NEXGENX v1.08 ==============================================================
 - Fixed: Clients sometimes not reconnecting to the server after a map switch.
 - Fixed: Accessed none warning in NexgenXClient.tick().
 - Fixed: Server URL cutoff in full server redirect settings.
 - Fixed: Mutators being loaded twice with a map switch if they also appear in the ServerActor list.
 - Fixed: Auto configuration file repair not saving changes.
 - Fixed: Commands not working for spectators (when using say, teamsay works fine).
 - Removed: Debug log from NexgenXClient.initialConfigReplicationComplete().
 - Added: Optional server rules tab.

=== NEXGENX v1.07 ==============================================================
 - Fixed: Unreal Tournament bug that causes the server to crash due to an infinite loop in viewPlayerNum().
 - Fixed: Map list sending to match administrators causing lag spikes.
 - Fixed: Clients getting muted for a short time just after connecting to the server.
 - Fixed: Accessed none warning in NexgenXClient.receiveMapListPart().
 - Added: Support for the custom AKA logger shipped with ASC to log Nexgen client IDs.
 - Added: Option to add or remove bots from the game.
 - Added: Extra game settings to the match control tab.
 - Added: Clan tag protection.
 - Added: Option to automatically check for updates.

=== NEXGENX v1.06 ==============================================================
 - Fixed: Too bright player overlay skins for green, gold and silver.
 - Added: Option to enable anti-spam.

=== NEXGENX v1.05 ==============================================================
 - Added: Plugin configuration section to the Nexgen control panel.
 - Added: Redirect to alternate servers when server is full.

=== NEXGENX v1.02 ==============================================================
 - Fixed: Countdown announcer not working sometimes.
 - Fixed: Specators receiving a player overlay skin.
 - Changed: Maps in the map swith control tab are now sorted.