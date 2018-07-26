================================================================================
  MOD CONFIGURATION DEFINITIONS
  ZEROPOINT PRODUCTIONS, DECEMBER 2010
  D.SCHEERENS@GMAIL.COM
================================================================================



================================================================================
  TABLE OF CONTENTS.
================================================================================
 1. INTRODUCTION.
 2. QUICK INSTALLATION GUIDE.
 3. SUPPORTED MODS.
 4. KNOWN ISSUES.
 
 

================================================================================
  1. INTRODUCTION.
================================================================================
The ModConfigDefinitions package contains a definition loader for several mods.
This package is to be used in conjunction with the NexgenModConfig plugin (but
it is not statically linked to that package). It should be fairly easy to add
definitions for other mods.



================================================================================
  2. QUICK INSTALLATION GUIDE.
================================================================================
 1. Make sure your server has been shut down.
 
 2. Copy the ModConfigDefinitions.u file to the system folder of your UT server.
  
 3. Open your servers configuration file and add the following server actor:
 
      ServerActors=ModConfigDefinitions.DefinitionLoader
 
    This package is server side only, so don't add it to the server packages
    list. Also the position in the server actor list does not matter.
  
 4. Save the changes to the configuration file and start the server.



================================================================================
  3. SUPPORTED MODS.
================================================================================
The following mods are supported by the definition loader:
 - DoubleJumpUT
 - MapVoteLA13
 - Revenge2
 - SLV203
 - SLV203XM
 - SLV204
 - SLV204XM
 - SLV205
 - SLV205XM
 - SmartCTF_4D
 - SmartCTF_4E
 
You can easily add support for other mods. The source is included so all you
have to do is add your definitions and recompile the package.



================================================================================
  4. KNOWN ISSUES.
================================================================================
Version 2.03 and 2.04 of the StrangeLove mod incorrectly load the maxSpeed
variable when the boost option is enabled. When enabled, the maxSpeed variable
is increased by the boosterSpeed variable. So when you change ANY setting of
this mod be sure to reset the maxSpeed variable to the correct value of you have
the booster option enabled. In version 2.05 this issue does not occur.
