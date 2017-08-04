function P_CorrectionBurn {	

	function neutrilize {
		RCS OFF.
		SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
		RETURN 1.
	}
	
	function move_fore {
		PARAMETER val.
		IF ((DEFINED stg_res AND stg_res["MonoPropellant"]:AMOUNT / stg_res["MonoPropellant"]:CAPACITY) * 100 < 10) {
			SET val TO MAX(-1, MIN(val, 1)).
			SET SHIP:CONTROL:FORE TO val.	
			RETURN 1.
		} ELSE {
			RETURN 0.
		}
	}
		
	LOCAL methods TO LEXICON(
		"fore", move_fore@,
		"neutrilize", neutrilize@
	).
	
	RETURN methods.
}