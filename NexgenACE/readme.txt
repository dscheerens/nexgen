================================================================================
  NEXGEN ACE PLUGIN VERSION 1.12-0.8g (FOR NEXGEN 1.12 AND ACE 0.8)
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
Nexgen uses a so called client ID to identify players. This client ID is used
among others to keep banned players from joining the server. However these
client IDs are very easy to change, making them not very strong in keeping
banned players away. With the recent release of ACE (Anti Cheat Engine) by
AnthraX a new hardware based player identification method has become available.
This identification method is much stronger than the default client IDs provided
by Nexgen.

As you might have guessed, this plugin makes this player identification method
available for Nexgen. It completely replaces the default client ID system of
Nexgen. As a result the banning system in Nexgen becomes much more effective.

Note that after the installation of this plugin all Nexgen user accounts become
unusable because the client ID of the users will be different. These accounts
will have to be recreated manually.

Another effect of this plugin is that it may take longer before a player will
login on Nexgen. This is because it takes a while before the ACE hardware ID
becomes available. Since Nexgen is very restrictive in the amount of time that
is available for logging in some players might experience login timouts. 



================================================================================
  2. QUICK INSTALLATION GUIDE.
================================================================================
 1. Make sure your server has been shut down.
 
 2. If ACE has not been installed yet, please do so first and ensure ACE is
    working properly on your server.
    
 3. Copy the NexgenACE112_08.u file to the system folder of your UT server.
    
 4. If your server is using redirect upload the NexgenACE112_08.u.uz file to
    the redirect server.
 
 5. Open your servers configuration file and add the following server package:
 
      ServerPackages=NexgenACE112_08
 
    Also add the following server actor:
    
      ServerActors=NexgenACE112_08.NXACEMain
      
    Note that the actor should be added AFTER the Nexgen controller server actor
    (ServerActors=Nexgen112.NexgenActor).
    
 5. Save the changes to the configuration file and start the server. The Nexgen
    ACE plugin should now be active on your server.



================================================================================
  3. VERSION HISTORY.
================================================================================

=== NEXGEN ACE v1.12-0.8 =======================================================
 - Changed: Plugin no longer has a dependency with IACEv08c.u.
 - Added: Spectators and Wine users will now use the default Nexgen client ID.

=== NEXGEN ACE v1.11-0.8g ======================================================
 - Misc: Release version for Nexgen v1.11 and ACE v0.8g.