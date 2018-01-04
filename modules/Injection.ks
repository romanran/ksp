COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Injection {
	PARAMETER trg_orbit.
	LOCAL LOCK thrott TO MAX(1 - (SHIP:ORBIT:PERIOD / trg_orbit["period"]) ^ 100, 0.1). //release acceleration at the end
	LOCAL LOCK dV_change TO calcDeltaV(trg_orbit["altA"]).
	LOCAL LOCK burn_time TO calcBurnTime(dV_change).
	LOCAL initialized TO 0.
	LOCAL done TO 0.
	
	LOCAL function init {
		SET initialized TO 1.
		RCS ON.
		SET THROTTLE TO 0.
		HUDTEXT("Circularisation...", 3, 2, 42, RGB(10,225,10), false).	
		SAS OFF.
		LOCK trg_vector TO LOOKDIRUP(SHIP:PROGRADE:VECTOR, SHIP:FACING:TOPVECTOR):FOREVECTOR.
		LOCK STEERING TO trg_vector.
		RETURN "RCS ON, Circularisation".
	}

	LOCAL function burn {
		IF FLOOR(ETA:APOAPSIS) <= FLOOR(burn_time / 2) {
			IF globals["ship_state"]["get"]("quiet") {
				SET THROTTLE TO 0.
			} ELSE {
				SET THROTTLE TO thrott.
			}
			
		}
		IF ROUND(SHIP:ORBIT:PERIOD) >= trg_orbit["period"] - 50 {
			LOCK THROTTLE TO 0.
			SET done TO 1.
			HUDTEXT("CIRCULARISATION PHASE I COMPLETE", 3, 2, 42, RGB(10,225,10), false).
			RETURN true.
		}
		RETURN false. // return that the maneuver is not done
	}
	
	LOCAL function getInitialized {
		return initialized.
	}
	
	LOCAL function getDone {
		return done.
	}
	

	LOCAL methods TO LEXICON(
		"init", init@,
		"burn", burn@,
		"initialized", getInitialized@,
		"done", getDone@,
		"dV_change", dV_change@,
		"burn_time", burn_time@,
		"throttle", thrott@
	).
	
	RETURN methods.
}	