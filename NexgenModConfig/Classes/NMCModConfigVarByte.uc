/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigVarByte
 *  $VERSION      1.01 (13-02-2010 23:44)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Definition class for byte mod configuration variables.
 *
 **************************************************************************************************/
class NMCModConfigVarByte extends NMCModConfigVar;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the type of data that is stored in the variable.
 *  $RETURN       The type of data that is stored in the variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function byte getDataType() {
	return modConfig.cfgContainer.DT_BYTE;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the default input type for this variable.
 *  $RETURN       The default input type for this variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function byte getDefaultInputType() {
	return modConfig.cfgContainer.IT_EDITBOX;
}