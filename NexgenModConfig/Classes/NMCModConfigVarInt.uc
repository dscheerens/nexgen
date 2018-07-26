/***************************************************************************************************
 *
 *  Nexgen Mod Configuration Tool by Zeropoint.
 *
 *  $CLASS        NMCModConfigVarInt
 *  $VERSION      1.01 (13-02-2010 23:44)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  Definition class for integer mod configuration variables.
 *
 **************************************************************************************************/
class NMCModConfigVarInt extends NMCModConfigVar;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the type of data that is stored in the variable.
 *  $RETURN       The type of data that is stored in the variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function byte getDataType() {
	return modConfig.cfgContainer.DT_INT;
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



/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the specified value according to the value restrictions posed on the
 *                mod configuration variable.
 *  $PARAM        value  The serialized value that is to be validated.
 *  $RETURN       A validated version of the given value.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string validateValue(string value) {
	value = class'NexgenUtil'.static.trim(value);
	
	if (value ~= "true") {
		return "1";
	} else {
		return string(int(value));
	}
}