COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("ShipGlobals").
loadDeps(dependencies).

function P_CorrectionBurn {	
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	LOCAL LOCK ship_res TO getResources().
	
	function neutralizeControls {
		RCS OFF.
		SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
		RETURN 1.
	}
	
	function moveFore {
		PARAMETER val TO 1.
		IF ship_res:HASKEY("MonoPropellant") AND (ship_res["MonoPropellant"]:AMOUNT / ship_res["MonoPropellant"]:CAPACITY) * 100 < 10 {
			RETURN 0.
		} ELSE {
			SET val TO MAX(-1, MIN(val, 1)).
			SET SHIP:CONTROL:FORE TO val.	
			RETURN 1.
		}
	}
		
	LOCAL methods TO LEXICON(
		"fore", moveFore@,
		"neutralize", neutralizeControls@
	).
	
	RETURN methods.
}