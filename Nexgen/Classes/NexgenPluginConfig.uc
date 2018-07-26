/***************************************************************************************************
 *
 *  NSC. Nexgen Server Controller by Zeropoint.
 *
 *  $CLASS        NexgenPluginConfig
 *  $VERSION      1.00 (14-05-2010 14:50)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Plugin configuration / data container. This class is used to load and save the
 *                configuration settings / data of plugins. It should not be used to replicate data
 *                from the server to the client as was done in previously. Instead you should be
 *                using the NexgenSharedDataContainer classes for that.
 *
 **************************************************************************************************/
class NexgenPluginConfig extends info;

var NexgenExtendedPlugin xControl;                // The plugin server controller.
var config int lastInstalledVersion;              // Last installed version of the plugin.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs the plugin.
 *  $ENSURE       lastInstalledVersion >= xControl.versionNum
 *
 **************************************************************************************************/
function install() {
	if (lastInstalledVersion < xControl.versionNum) {
		lastInstalledVersion = xControl.versionNum;
		saveConfig();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the configuration. Problems with the plugin configuration will be 
 *                automatically repaired.
 *  $RETURN       True if the configuration was valid, false if there were one or more configuration
 *                corruptions.
 *  $ENSURE       new.validate()
 *
 **************************************************************************************************/
function bool validate() {
	// To implement in subclass.
	return true;
}