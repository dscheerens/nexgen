/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCClient
 *  $VERSION      1.12 (06-04-2010 10:49)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Nexgen Mod Configuration Tool client controller. This class is the base of the
 *                clientside support for the plugin.
 *
 **************************************************************************************************/
class NMCClient extends NexgenNetClientController;

var NMCLang lng;                        // Language instance to support localization.
var NMCMain xControl;                   // Plugin controller.
var NMCModConfigContainer cfgContainer; // The mod configuration definition container.
var NMCCommandHandler cmdHandler;       // Handles the execution of commands.

var bool bModDefRequested;              // Whether the mod definitions have been requested.

// Other constants.
const clientModConfigPanelName = "clientmodconfig";
const serverModConfigPanelName = "servermodconfig";



/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {
	//reliable if (role == ROLE_Authority) // Replicate to client...
		
	reliable if (role == ROLE_SimulatedProxy) // Replicate to server...
		requestModConfigDefinitions;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the client controller.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated event postNetBeginPlay() {
	if (bNetOwner) {
		super.postNetBeginPlay();
		
		lng = spawn(class'NMCLang');
	} else {
		destroy();
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the NexgenClient has received its initial replication info is has
 *                been initialized. At this point it's safe to use all functions of the client.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function clientInitialized() {
	// Create mod configuration container.
	cfgContainer = spawn(class'NMCModConfigContainerClient', self);
	cfgContainer.lng = self.lng;
	
	// Create command handler.
	cmdHandler = spawn(class'NMCCommandHandlerClient', self);
	cmdHandler.cfgContainer = cfgContainer;
	cmdHandler.lng = lng;
	
	// Request the mod config definitions from the server
	requestModConfigDefinitions();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called by the client on the server to request the mod configuration definitions.
 *                This will make the server send the definition lines one by one to the client.
 *
 **************************************************************************************************/
function requestModConfigDefinitions() {
	cfgContainer.sendDefintionLines(self, client.hasRight(client.R_ServerAdmin));
	bModDefRequested = true;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a string was received from the other machine.
 *  $PARAM        str  The string that was send by the other machine.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function recvStr(string str) {
	cmdHandler.execCommand(self, str);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the mod configuration panels for the specified mod.
 *  $PARAM        modID  Identifier of the mod whose configuration panels are to be created.
 *
 **************************************************************************************************/
simulated function createModConfigPanels(string modID) {
	local NMCModConfig modConfig;
	local NMCModConfigVar modConfigVar;
	local int clientVarCount;
	local int serverVarCount;
	
	// Get mod configuration.
	modConfig = cfgContainer.getModConfig(modID);
	
	// Get variable counts.
	for (modConfigVar = modConfig.varList; modConfigVar != none; modConfigVar = modConfigVar.nextVar) {
		if (modConfigVar.bValueSet && !modConfigVar.bUnsupported) {
			if (modConfigVar.netType == cfgContainer.NT_CLIENT) {
				clientVarCount++;
			}
			if (modConfigVar.netType == cfgContainer.NT_SERVER) {
				serverVarCount++;
			}
		}  
	}
	
	// Create panels.
	if (clientVarCount > 0) {
		createModConfigPanel(modConfig, class'NMCModConfigPanelClient', clientModConfigPanelName, "client");
	}
	if (client.hasRight(client.R_ServerAdmin) && serverVarCount > 0) {
		createModConfigPanel(modConfig, class'NMCModConfigPanelServer', serverModConfigPanelName, "server,serversettings");
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the mod configuration panel for the specified mod at the given location in
 *                the Nexgen control panel. In case the specified container panel does not exist, it
 *                will automatically be created.
 *  $PARAM        modConfig        The mod configuration for which the panel is to be created.
 *  $PARAM        panelClass       The class of the panel that is to be created
 *  $PARAM        panelIdentifier  Identifier of the container panel on which the mod configuration
 *                                 panel should be created.
 *  $PARAM        path             Path where the container panel is to be found.
 *  $REQUIRE      modConfig != none && panelClass != none && panelIdentifier != ""
 *
 **************************************************************************************************/
simulated function createModConfigPanel(NMCModConfig modConfig, class<NexgenPanel> panelClass, string panelIdentifier, string path) {
	local NexgenPanelContainer container;
	local NMCModConfigPanel panel;
	
	// Get or create mod configuration panel container tab.
	container = NexgenPanelContainer(client.mainWindow.mainPanel.getPanel(panelIdentifier));
	if (container == none) {
		container = NexgenPanelContainer(client.mainWindow.mainPanel.addPanel("Mods", class'NexgenScrollPanelContainer', panelIdentifier, path));
	}
	
	// Create panel.
	panel = NMCModConfigPanel(container.addPanel("", panelClass, panelIdentifier $ "_" $ modConfig.modID));
	panel.modConfig = modConfig;
	panel.setContent();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the current value being displayed on the GUI input component for the
 *                specified mod configuration variable.
 *  $PARAM        modConfigVar  The mod configuration variable whose input component is to be updated.
 *  $REQUIRE      modConfigVar != none
 *
 **************************************************************************************************/
simulated function updateModConfigVar(NMCModConfigVar modConfigVar) {
	local string panelIdentifier;
	local NMCModConfigPanel panel;
	
	// Check if the mod definition is closed. If not the input component does not exist.
	if (!modConfigVar.modConfig.bClosed) {
		return;
	}
	
	// Retrieve the panel containing the input component for the mod configuration variable.
	switch (modConfigVar.netType) {
		case cfgContainer.NT_CLIENT: panelIdentifier = clientModConfigPanelName;
		case cfgContainer.NT_SERVER: panelIdentifier = serverModConfigPanelName;
	}
	panelIdentifier = panelIdentifier $ "_" $ modConfigVar.modConfig.modID;
	panel = NMCModConfigPanel(client.mainWindow.mainPanel.getPanel(panelIdentifier));
	
	// Update value.
	if (panel != none) {
		panel.updateVar(modConfigVar);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	ctrlID="NexgenModConfigToolClient"
	windowSize=1
	netPriority=1.0
}