function P_Injection {
	LOCAL burn_time IS -9999. //dont fire until its calculated
	LOCAL thrott IS 0.
	LOCAL dV_change IS 0.
	LOCAL rcs_1s IS doOnce().
	LOCAL circ_prepare_1s IS doOnce().
	LOCAL circ_burn_1s IS doOnce().
	
	function init {
		rcs_1s["do"]({
			RCS ON.
			ship_log["add"]("RCS on, circuralisation").
		}).

		circ_prepare_1s["do"]({
			SET thrott TO 0.
			HUDTEXT("CIRCURALISATION...", 3, 2, 42, RGB(10,225,10), false).	
			SET dV_change TO calcDeltaV(trgt["altA"]).
			SET burn_time TO calcBurnTime(dV_change).
			SAS OFF.
			LOCK STEERING TO LOOKDIRUP(SHIP:PROGRADE:VECTOR, SHIP:FACING:TOPVECTOR):FOREVECTOR.
		}).
	}

	function burn {
		IF FLOOR(ETA:APOAPSIS) <= FLOOR(burn_time / 2) {
			circ_burn_1s["do"]({
				HUDTEXT("CIRC BURN!", 3, 2, 42, RGB(230,155,10), false).
				LOCK thrott TO MAX(1 - (SHIP:ORBIT:PERIOD / trgt["period"]) ^ 100, 0.1). //release acceleration at the end
				LOCK THROTTLE to thrott.
				ship_log["add"]("CIRCURALISATION BURN").
			}).
		}
		
		IF ROUND(SHIP:ORBIT:PERIOD) >= (trgt["period"] - 50) {
			UNLOCK thrott.
			SET thrott TO 0.
			HUDTEXT("CIRCURALISATION PHASE I COMPLETE", 3, 2, 42, RGB(10,225,10), false).
			RETURN 1.
		}
		
		RETURN 0. // return that the maneuver is not done
	}
	

	LOCAL methods TO LEXICON(
		"init", init@,
		"burn", burn@
	).
	
	RETURN methods.
}	