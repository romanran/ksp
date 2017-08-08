COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("ShipGlobals").
loadDeps(dependencies).

function P_CorrectionBurn {	
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	LOCAL LOCK stg_res TO globals["stg_res"]().
	
	function neutralizeControls {
		RCS OFF.
		SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
		RETURN 1.
	}
	
	function moveFore {
		PARAMETER val.
		IF (stg_res["MonoPropellant"]:AMOUNT / stg_res["MonoPropellant"]:CAPACITY) * 100 < 10 {
			SET val TO MAX(-1, MIN(val, 1)).
			SET SHIP:CONTROL:FORE TO val.	
			RETURN 1.
		} ELSE {
			RETURN 0.
		}
	}
		
	LOCAL methods TO LEXICON(
		"fore", moveFore@,
		"neutralize", neutralizeControls@
	).
	
	RETURN methods.
}