/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigVarEnum
 *  $VERSION      1.01 (13-02-2010 23:44)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Definition class for enumeration mod configuration variables.
 *
 **************************************************************************************************/
class NMCModConfigVarEnum extends NMCModConfigVar;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the type of data that is stored in the variable.
 *  $RETURN       The type of data that is stored in the variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function byte getDataType() {
	return modConfig.cfgContainer.DT_ENUM;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the default input type for this variable.
 *  $RETURN       The default input type for this variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function byte getDefaultInputType() {
	return modConfig.cfgContainer.IT_DROPDOWN;
}