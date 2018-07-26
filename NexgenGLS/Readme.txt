================================================================================
  NEXGEN GLOBAL LOGIN SYSTEM VERSION 1.06 (FOR NEXGEN 1.12)
  ZEROPOINT PRODUCTIONS, DECEMBER 2010
  D.SCHEERENS@GMAIL.COM
================================================================================



================================================================================
  TABLE OF CONTENTS.
================================================================================
 1. INTRODUCTION.
 2. INSTALLATION GUIDE.
 2.1. INSTALLING THE NGLS DATABASE SERVER
 2.1.1 E107 CMS
 2.1.2 OTHER SYSTEMS
 2.2. INSTALLING THE NEXGEN PLUGIN
 3. NGLS VERSION HISTORY.
 
 

================================================================================
  1. INTRODUCTION.
================================================================================
The Nexgen Global Login System is a plugin for the Nexgen Server Controller that
allows admins to filter the players that enter their server by requiring the
players to login before they can play on the server. The logins are checked with
a local or remote database that contains the accounts of the registered players.
This database can be anything, ranging from a general community forum to a
dedicated NGLS master server. Because the accounts are stored on a central
server it possible to easily ban a player from all your servers if they access
the same NGLS database server.

Once the Nexgen Global Login System has been installed on your server, new
players will be prompted with a dialog where they can enter their username and
password. A register button is provided so they can be redirected to the site
where they can create an account that allows them to play on your server. If the
user has entered the correct login information, he/she can hit reconnect and
will no longer be bothered by the system until the account is either deactivated
by an administrator or the user manually opens the login dialog using the !login
command.

The plugin also has various settings that will allow the server administrator to
change the level of strictness of the system. The following options are
available:
 - Allow players to enter the server as spectator without having to login.
 - Always accept players that have a Nexgen account stored on the UT server
   itself. Note that players with the 'Server Administrator' privilege will be
   granted access to the server at all time; they never need to login.
 - Disconnect players when the NGLS system is unable to verify the username and
   password. This might happen if the NGLS database server can't be reached by
   the UT server or when the NGLS database server is experiencing other
   problems. It's not recommended to enable this option.
 - The amount of time a player has to send it's login information. Note that the
   login information is send automatically and as fast as possible, however this
   will prevent players with a modified version of the NGLS client to circumvent
   the login procedure.



================================================================================
  2. INSTALLATION GUIDE.
================================================================================

=== 2.1. INSTALLING THE NGLS DATABASE SERVER ===================================
The method of installing the NGLS database server depends on the system you are
going to use. Currently this release only supports the e107 content managing
system. However it should be fairly easy to create a script for other systems.

=== 2.1.1 E107 CMS =============================================================
 1. Locate the ngls_check.php file in the scripts/e107 folder of the NGLS
    archive you downloaded that contains this readme file.
 
 2. Create a copy of the file and open it with a text editor.
 
 3. Enter the correct settings under the database settings sections, save the
    changes and close the file.
 
 4. Upload the file to your webserver. If you upload the file to a server that
    doesn't run the mysql server for the e107 cms, make sure the user you
    entered in the ngls_check.php has access to the database from a remote
    location (not just from localhost).
 
 5. Remember the path where you uploaded the script, for example
    www.yoursite.com/subdir/ngls_check.php. You'll need this information later
    when installing the Nexgen plugin.

=== 2.1.2 OTHER SYSTEMS ========================================================
Other systems are currently not supported, however a template script is provided
so you can write an interface for that system yourself. It should be pretty easy
if you have experience with PHP and MYSQL. The template can be found in the
scripts/template folder of this archive.

=== 2.2. INSTALLING THE NEXGEN PLUGIN ==========================================

 1. Make sure your server has been shut down.
 
 2. Copy NexgenGLS106.u to the system folder of your UT server.
 
 3. If your server is using redirect upload the NexgenGLS106.u.uz file to the
    redirect server.
 
 4. Open your servers configuration file and add the following server package:
 
      ServerPackages=NexgenGLS106
 
    Also add the following server actor:
    
      ServerActors=NexgenGLS106.NGLSMain
      
    Note that the actor should be added AFTER the Nexgen controller server actor
    (ServerActors=Nexgen112.NexgenActor).
    
 5. Save the changes to the configuration file and start the server.
 
 6. Connect to your server and make sure you have the 'Server administrator'
    privilege in Nexgen.
    
 7. Open the Nexgen control panel and go to the following tab:
    server -> settings -> plugins. If you have configured your server config
    file correctly, there should now be a new section available called:
    'Nexgen Global Login System - General settings'.
 
 8. Enter the hostname of the server running the interface script. Also enter
    the path where you have uploaded the interface script and make sure you have
    the 'Enable the global login system' option checked. Modify the other
    settings if you like.
 
 9. Once you have set all settings correctly click on the save button. If
    everthing was installed correctly the Nexgen Global Login System should now
    be active. To test if the system works, remove your administrator account
    from the server and reconnect. You should now recieve a dialog that asks for
    your username and password. Note that you won't see the dialog when you have
    the 'Server Administrator' privilege. Server administrators are assumed to
    be trusted persons, so they never have to login.

 
 
================================================================================
  3. NGLS VERSION HISTORY.
================================================================================

=== NEXGENGLS v1.02 ============================================================
 - Changed: A HTTP client is spawned for each login request.

=== NEXGENGLS v1.01 ============================================================
 - Added: Client check buffer queue.

=== NEXGENGLS v1.00 ============================================================
 - Misc: First public release.