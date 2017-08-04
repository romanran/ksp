function P_Injection {
	LOCAL burn_time IS -9999. //dont fire until its calculated
	LOCAL thrott IS 0.
	LOCAL dV_change IS 0.
	LOCAL circ_burn_1s IS doOnce().
	LOCAL initialized TO 0.
	LOCAL done TO 0.
	
	function init {
		IF NOT initialized {
			RCS ON.
			SET thrott TO 0.
			HUDTEXT("CIRCURALISATION...", 3, 2, 42, RGB(10,225,10), false).	
			SET dV_change TO calcDeltaV(trgt["altA"]).
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
				LOCK thrott TO MAX(1 - (SHIP:ORBIT:PERIOD / trgt["period"]) ^ 100, 0.1). //release acceleration at the end
				LOCK THROTTLE to thrott.
				RETURN "Circuralisation burn".
			}).
		}
		
		IF ROUND(SHIP:ORBIT:PERIOD) >= trgt["period"] - 50 {
			UNLOCK thrott.
			SET thrott TO 0.
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