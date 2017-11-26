COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Injection {
	PARAMETER trgt_orbit.
	LOCAL LOCK thrott TO MAX(1 - (SHIP:ORBIT:PERIOD / trgt_orbit["period"]) ^ 100, 0.1). //release acceleration at the end
	LOCAL LOCK dV_change TO calcDeltaV(trgt_orbit["altA"]).
	LOCAL LOCK burn_time TO calcBurnTime(dV_change).
	LOCAL circ_burn_1s IS doOnce().
	LOCAL init_1s IS doOnce().
	LOCAL initialized TO 0.
	LOCAL done TO 0.
	
	function init {
		SET initialized TO 1.
		RCS ON.
		UNLOCK STEERING.
		SET THROTTLE TO 0.
		HUDTEXT("CIRCURALISATION...", 3, 2, 42, RGB(10,225,10), false).	
		SAS OFF.
		LOCAL trgt_vector TO LOOKDIRUP(SHIP:PROGRADE:VECTOR, SHIP:FACING:TOPVECTOR):FOREVECTOR.
		SET trgt_vector:X TO ROUND(trgt_vector:X, 4).
		SET trgt_vector:Y TO ROUND(trgt_vector:Y, 4).
		SET trgt_vector:Z TO ROUND(trgt_vector:Z, 4).
		LOCK STEERING TO trgt_vector.
		RETURN "RCS on, circuralisation".
	}

	function burn {
		IF FLOOR(ETA:APOAPSIS) <= FLOOR(burn_time / 2) {
			circ_burn_1s["do"]({
				HUDTEXT("CIRC BURN!", 3, 2, 42, RGB(230,155,10), false).
				LOCK THROTTLE TO thrott.
				RETURN "Circuralisation burn".
			}).
		}
		
		IF ROUND(SHIP:ORBIT:PERIOD) >= trgt_orbit["period"] - 50 {
			LOCK THROTTLE TO 0.
			SET done TO 1.
			HUDTEXT("CIRCURALISATION PHASE I COMPLETE", 3, 2, 42, RGB(10,225,10), false).
			RETURN "Circuralisation Phase I complete".
		}
		
		RETURN 0. // return that the maneuver is not done
	}
	

	LOCAL methods TO LEXICON(
		"init", init@,
		"burn", burn@,
		"initialized", initialized,
		"done", done,
		"dV_change", dV_change@,
		"burn_time", burn_time,
		"throttle", thrott@
	).
	
	RETURN methods.
}	