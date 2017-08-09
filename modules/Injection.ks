COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Injection {
	PARAMETER trgt_orbit.
	LOCAL burn_time IS -9999. //dont fire until its calculated
	LOCAL LOCK thrott TO MAX(1 - (SHIP:ORBIT:PERIOD / trgt_orbit["period"]) ^ 100, 0.1). //release acceleration at the end
	LOCAL dV_change IS 0.
	LOCAL circ_burn_1s IS doOnce().
	LOCAL initialized TO 0.
	LOCAL done TO 0.
	
	function init {
		IF NOT initialized {
			RCS ON.
			LOCK THROTTLE TO 0.
			HUDTEXT("CIRCURALISATION...", 3, 2, 42, RGB(10,225,10), false).	
			SET dV_change TO calcDeltaV(trgt_orbit["altA"]).
			SET burn_time TO calcBurnTime(dV_change).
			SAS OFF.
			LOCK STEERING TO LOOKDIRUP(SHIP:PROGRADE:VECTOR, SHIP:FACING:TOPVECTOR):FOREVECTOR.
			RETURN "RCS on, circuralisation".
		} ELSE {
			RETURN 0.
		}
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
		"done", done
	).
	
	RETURN methods.
}	