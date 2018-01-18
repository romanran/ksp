COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Injection {
	PARAMETER trg_orbit.
	LOCAL LOCK thrott TO MAX(1 - (SHIP:ORBIT:PERIOD / (trg_orbit["period"] - 10))^3, 0.1). //release acceleration at the end
	LOCAL LOCK dV_change TO calcDeltaV(trg_orbit["altA"]).
	LOCAL LOCK burn_time TO calcBurnTime(dV_change).
	
	LOCAL function init {
		RCS ON.
		SET THROTTLE TO 0.
		//HUDTEXT("Circularisation...", 3, 2, 42, RGB(10,225,10), false).	
		SAS OFF.
		LOCK STEERING TO PROGRADE.
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