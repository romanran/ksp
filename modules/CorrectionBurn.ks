@LAZYGLOBAL off.
IF NOT EXISTS("1:Utils") AND HOMECONNECTION:ISCONNECTED {
	COPYPATH("0:lib/Utils", "1:").
}
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("ShipGlobals").
loadDeps(dependencies).

function P_CorrectionBurn {	
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	LOCAL LOCK ship_res TO getResources().
	
	LOCAL function neutralizeControls {
		RCS OFF.
		SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
		RETURN 1.
	}
	
	LOCAL function moveFore {
		PARAMETER val TO 1.
		IF ship_res:HASKEY("MonoPropellant") AND (ship_res["MonoPropellant"]:AMOUNT / ship_res["MonoPropellant"]:CAPACITY) * 100 < 5 {
			HUDTEXT("NO MONOPROP", 3, 2, 42, RGB(10,225,10), false).
			// RETURN 0.
		} ELSE {
		}
		SET val TO MAX(MIN(val, 1), -1).
		IF val > 0 {
			SET val TO MAX(val, 0.1).
		} ELSE {
			SET val TO MIN(val, -0.1).
		}
		SET SHIP:CONTROL:FORE TO val.	
		RETURN 1.
	}
		
	LOCAL methods TO LEXICON(
		"fore", moveFore@,
		"neutralize", neutralizeControls@
	).
	
	RETURN methods.
}