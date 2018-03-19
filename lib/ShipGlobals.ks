  // Aurora scope variables 
@LAZYGLOBAL off.
IF NOT EXISTS("1:Utils") AND HOMECONNECTION:ISCONNECTED {
	COPYPATH("0:lib/Utils", "1:").
}
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("Journal", "Displayer", "ShipState").
loadDeps(dependencies).

function setGlobal {
	LOCAL LOCK q_pressure TO ROUND(SHIP:Q * CONSTANT:AtmToKpa * SHIP:AIRSPEED / 1000, 3). 
	LOCAL LOCK acc_vec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV. 
	LOCAL ship_log TO Journal().
	LOCAL Display TO Displayer().
	LOCAL ship_state TO ShipState().
	LOCAL LOCK stg_res TO getStageResources().
	
	RETURN LEXICON(
		"q_pressure", q_pressure@,
		"acc_vec", acc_vec@,
		"ship_log", ship_log,
		"Display", Display,
		"ship_state", ship_state,
		"stg_res", stg_res@
	).
}