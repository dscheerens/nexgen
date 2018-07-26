================================================================================
  NEXGEN STATISTICS VIEWER PLUGIN VERSION 1.05 (FOR NEXGEN 1.12)
  ZEROPOINT PRODUCTIONS, DECEMBER 2010
  D.SCHEERENS@GMAIL.COM
================================================================================



================================================================================
  TABLE OF CONTENTS.
================================================================================
 1. INTRODUCTION.
 2. REQUIREMENTS.
 3. INSTALLATION GUIDE.
 3.1. INSTALLING THE UTSTATS QUERY SCRIPT
 3.2. INSTALLING THE NEXGEN PLUGIN
 4. UPGRADING FROM A PREVIOUS VERSION.
 5. VERSION HISTORY.
 
 

================================================================================
  1. INTRODUCTION.
================================================================================
The Nexgen Statistics Viewer Plugin tries to enhance your server by displaying a
list with the players with the highest UTStats ranking, similar to the rankings
page found on the online UTStats websites. This list will be displayed once you
have connected to the server and will disappear as soon as you press fire. A
preview of how this looks ingame can be seen here:
http://zeropoint2.student.utwente.nl/misc/NexgenStatsViewerPlugin.jpg

It is possible to display stats for different games and utstats databases.



================================================================================
  2. REQUIREMENTS.
================================================================================
In order to be able to use the statistics viewer plugin your server is required
to be running the Nexgen Server Controller. Since Nexgen plugins are compiled
for specific versions, you can only use this plugin on Nexgen version 1.07. Once
a new version of Nexgen is released, this plugin will be recompiled for that
version and made available for download.

Another thing you will need for this plugin is an installed version of UTStats.
In case you haven't installed UTStats yet you can download it here:
http://downloads.unrealadmin.org/UnrealTournament/Addons/UTStats/. During the
rest of this document I will assume you have a working version of UTStats
available. Please don't send me e-mails if you have problems getting UTStats to
work (which can sometimes be a bit difficult).

Finally you will need some place to upload the script to and have access to the
database where the UTStats are being stored. If you have installed UTStats
yourself this shouldn't be a problem.



================================================================================
  3. INSTALLATION GUIDE.
================================================================================
Before you proceed with the installation of the Nexgen Statistics Viewer Plugin,
make sure you have read the requirements section first!

The statistics viewer consists of two separate systems: a plugin for Nexgen
which contains the code for displaying the statistics and a query script for
UTStats which will be accessed by the Nexgen plugin to retrieve the list of
players.

=== 3.1. INSTALLING THE UTSTATS QUERY SCRIPT ===================================

 1. Open the getstats.php file (included with this archive) with a text editor.
 
 2. Under the CONFIG section, enter one or more lists you wish to display. The
    format of the addlist command has the following arguments:
    
    database_hostname = The hostname of the database server that is hosting the
                        statistics server, for example 'www.ut-slv.com' or
                        '123.45.67.89'. Most of the times you will probably run
                        the script from the same server where the database
                        server is running. In that case just use 'localhost'.
    database_name     = Name of database that contains the statistics, which is
                        probably 'utstats'.
    database_username = The user that will access the database.
    database_password = Password for that user that accesses the database.
    game_name         = Name of the ranking list you wish to display. This
                        should be exactly the same name as found on the rankings
                        page on utstats. For example if you wish to display the
                        players under the 'Top 10 Capture the Flag Players' list
                        use: 'Capture the Flag'.
    number_of_players = The number of players you wish to display.
    display_title     = The title of the list you wish to display, for example:
                        'Best 25 CTF players ever!!!'.

    An example configuration would look like this:
    add_player_list('localhost', 'utstats', 'ut_user', 'guess_my_password', 'Tournament DeathMatch', 10, 'Top DM players');
    add_player_list('localhost', 'utstats', 'ut_user', 'guess_my_password', 'Tournament Team Game', 5, 'Top AS players');
    add_player_list('localhost', 'utstats', 'ut_user', 'guess_my_password', 'Capture the Flag', 5, 'Top CTF players');
    add_player_list('localhost', 'utstats', 'ut_user', 'guess_my_password', 'Assault', 5, 'Top AS players');
    add_player_list('localhost', 'utstats', 'ut_user', 'guess_my_password', 'Domination', 5, 'Top CTF players');
    
    Note that a maximum of 5 lists can be displayed. Also the maximum number of
    players that can be displayed (sum of all lists) is 30.
    
    Also note that most of the time the database_hostname, database_name,
    database_username and database_password arguments are probably just the same
    as for the UTStats website. So you can just find their correct values by
    looking in the config.php file of UTStats (found in the 'utstats/include'
    folder).

 3. Upload the script to your webserver. If you upload it to another server than
    the one where you have your UTStats website hosted make sure this server has
    php with the mysql extension installed.

 4. Test the query script. Open a web browser and enter the URL where you have
    uploaded the script. For example 'http://www.bla.com/utstats/getstats.php'.
    If you have everything configured correctly your browser should now display
    some gibberish text that includes some player names. Of course this will
    only be the case if UTStats already has collected some statistics and there
    is something to display. If not it will just display an empty page.
    
    If there was something wrong with your configuration an error message will
    be displayed in your browser indicating what went wrong.
    
    Note that if you have entered a non-existing game name in the configuration, 
    either because you used the wrong name (see step 2) or because there are no
    stats available for this game (yet) it will simply be ignored. This may also
    result in empty page.

=== 3.2. INSTALLING THE NEXGEN PLUGIN ==========================================

 1. Make sure your server has been shut down.
 
 2. Copy NexgenStatsViewer105.u to the system folder of your UT server.
 
 3. If your server is using redirect upload the NexgenStatsViewer105.u.uz file
    to the redirect server.
 
 4. Open your servers configuration file and add the following server package:
 
      ServerPackages=NexgenStatsViewer105
 
    Also add the following server actor:
    
      ServerActors=NexgenStatsViewer105.NSVMain
      
    Note that the actor should be added AFTER the Nexgen controller server actor
    (ServerActors=Nexgen112.NexgenActor).
    
 5. Save the changes to the configuration file and start the server.
 
 6. Connect to your server and make sure you have the 'Server administrator'
    privilege in Nexgen.
    
 7. Open the Nexgen control panel and go to the following tab:
    server -> settings -> plugins. If you have configured your server config
    file correctly, there should now be a new section available called:
    'Nexgen Stats Viewer - UTStats client settings'
 
 8. Enter the hostname of the server running the query script. Also enter the
    path where you have uploaded the query script and make sure you have the
    'Enable UTStats client' option checked. In our previous example in section
    3.2 of 'http://www.bla.com/utstats/getstats.php' the hostname would be:
    'www.bla.com' and the script path would be '/utstats/getstats.php'.
 
 9. If you have entered the UTStats client settings correctly and enabled it,
    click on the save button. In order to see the statistics (if utstats has
    already collected some) you need to restart the game. Once the game has been
    restarted you should now be able to see the UTStats rankings on the left
    side of your screen!



================================================================================
  3. UPGRADING FROM A PREVIOUS VERSION.
================================================================================
 1. Make sure your server has been shut down.
 
 2. Delete NexgenStatsViewer1xx.u (where xx is the previous version of the
    statistics viewer plugin) from your servers system folder and upload
    NexgenStatsViewer105.u to the same folder.
 
 3. If your server is using redirect you may wish to delete
    NexgenStatsViewer1xx.u.uz if it is no longer used by other servers. Also
    upload NexgenStatsViewer1xx.u.uz to the redirect server.
 
 4. Open Nexgen.ini or your servers configuration file if the Nexgen settings
    are stored there.
 
 5. Do a search and replace where the string "NexgenStatsViewer1xx." should be
    replaced with "NexgenStatsViewer105." (without the quotes). Again the xx
    denotes the previous version of the statistics viewer plugin that was
    installed on your server.
 
 6. If you have Nexgen.ini opened save the changes and close the file. Now open
    the servers configuration file.

 7. Goto the [Engine.GameEngine] section and edit the server package and
    server actor lines for NexgenStatsViewer. They should look like this:
       
       ServerActors=NexgenStatsViewer105.NSVMain
      
       ServerPackages=NexgenStatsViewer105
 
 8. Save changes to the servers configuration file and close it.
 
 9. Restart your server.



================================================================================
  5. VERSION HISTORY.
================================================================================

=== NEXGEN v1.02 ===============================================================
 - Changed: Stats will be visible for 8 seconds instead of 6.
 - Added: Support for other mods to check if the stats are shown.

=== NEXGEN v1.01 ===============================================================
 - Changed: Stats will now automatically disappear after 6 seconds if the game is in progress.
 - Added: New command (!nscstats) to view the stats.

=== NEXGEN v1.00 ===============================================================
 - Misc: First public release version of the Nexgen Statistics Viewer Plugin.
 