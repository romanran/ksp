@LAZYGLOBAL off.
IF NOT EXISTS("1:Utils") AND HOMECONNECTION:ISCONNECTED {
	COPYPATH("0:lib/Utils", "1:").
}
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Injection {
	PARAMETER trg_orbit.
	LOCAL LOCK thrott TO MAX(1 - ((SHIP:ORBIT:PERIOD - 20) / (trg_orbit["period"] - 20)) ^ 20, 0.1). //release acceleration at the end
	LOCAL LOCK dV_change TO calcDeltaV(trg_orbit["altA"]).
	LOCAL LOCK burn_time TO calcBurnTime(dV_change).
	LOCAL function init {
		RCS ON.
		SAS OFF.
		LOCK THROTTLE TO 0.
		LOCK STEERING TO PROGRADE + R(0, 0, 90).
		IF getdV() < dV_change / 10 {
			doStage().
		}
		RETURN "RCS ON, Circularisation".
	}

	LOCAL function burn {
		IF FLOOR(ETA:APOAPSIS) <= FLOOR(burn_time / 2) {
			IF globals["ship_state"]["get"]("quiet") {
				LOCK THROTTLE TO 0.
			} ELSE {
				LOCK THROTTLE TO thrott.
			}
			
		}
		IF ROUND(SHIP:ORBIT:PERIOD) >= trg_orbit["period"] - 50 {
			LOCK THROTTLE TO 0.
			UNLOCK STEERING.
			RETURN true.
		}
		RETURN false. // return that the maneuver is not done
	}

	LOCAL methods TO LEXICON(
		"init", init@,
		"burn", burn@,
		"dV_change", dV_change@,
		"burn_time", burn_time@,
		"throttle", thrott@
	).
	
	RETURN methods.
}	