================================================================================
  NEXGEN MOD CONFIGURATION TOOL VERSION 1.01 (FOR NEXGEN 1.12)
  ZEROPOINT PRODUCTIONS, DECEMBER 2010
  D.SCHEERENS@GMAIL.COM
================================================================================



================================================================================
  TABLE OF CONTENTS.
================================================================================
 1. INTRODUCTION.
 2. QUICK INSTALLATION GUIDE.
 3. VERSION HISTORY.



================================================================================
  1. INTRODUCTION.
================================================================================
Many mutators and mods for UT come with configurable settings. As a server
administrator it is possible to change these settings by editing the
configuration files or executing console commands within the game. However you
seldom know all commands by heart and variable names in the configuration files
may not always be clear. Sometimes mods do provide you with a graphical user
interface (via the mod menu) to change the settings. Unfortunately this only
works for offline games, it does not allow you to change the settings on the
server.

The NexgenModConfig plugin is meant to overcome this problem. This plugin allows
you define which settings you would like to be able to change within the game.
Using these definitions it generates an interface so you can actually change the
server side mod settings. Additionally it also supports changing the settings at
the client side.

Mods are not supported automatically by the system. In order to support your mod
or mutator, you have to tell the system about the configurable variables. This
can be done be 'sending' definition lines to the NexgenModConfig plugin. An
example of how this is done is included (see source of the ModConfigDefinitions
package). You can add these definition to a dedicated definition loader or you
can simply put them in your mod itself, as no hard linking with the
NexgenModConfig plugin is necessary.

Note that this system has its limitations. It can only change simple variable
types, so arrays and structs are not supported. Also changes will not be applied
immediately but at the end of the game instead (except for client side
settings). This is done to prevent issues that arise if a mod is not able to
gracefully handle these changes on the fly. Finally the system is unable to
detect changes that are made outside of it (e.g. by the mod itself).



================================================================================
  2. QUICK INSTALLATION GUIDE.
================================================================================
 1. Make sure your server has been shut down.
 
 2. Copy the NexgenModConfig101.u file to the system folder of your UT server.
 
 3. If your server is using redirect upload the NexgenModConfig101.u.uz file to
    the redirect server.
 
 4. Open your servers configuration file and add the following server package:
 
      ServerPackages=NexgenModConfig101
 
    Also add the following server actor:
    
      ServerActors=NexgenModConfig101.NMCMain
      
    Note that the actor should be added AFTER the Nexgen controller server actor
    (ServerActors=Nexgen112.NexgenActor).

 5. Optionally install a definition loader for your mods (e.g. the included
    ModConfigDefinitions package).
  
 6. Save the changes to the configuration file and start the server. The
    extension plugin should now be active on your server.
 


================================================================================
  3. VERSION HISTORY.
================================================================================

=== NEXGENMODCONFIG v1.01 ======================================================
 - Changed: Major improvement in data tranfer performance.
 - Misc: Public release version of NexgenModConfig.

=== NEXGENMODCONFIG v1.00 ======================================================
 - Misc: Private test version of NexgenModConfig.
 