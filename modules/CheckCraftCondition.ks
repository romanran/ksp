function P_CheckCraftCondition {
	LOCAL LOCK ec TO (DEFINED stg_res AND (stg_res["ELECTRICCHARGE"]:AMOUNT / stg_res["ELECTRICCHARGE"]:CAPACITY) * 100 < 20) OR stg_res["ELECTRICCHARGE"]:AMOUNT < 40.
	LOCAL LOCK mp TO (DEFINED stg_res AND (stg_res["MonoPropellant"]:AMOUNT / stg_res["MonoPropellant"]:CAPACITY) * 100 < 1) OR stg_res["MonoPropellant"]:AMOUNT < 1.
	LOCAL override IS 0.
	
	function refresh {
		IF ec {
			//if below 20% of max ships capacity or 40 units
			//electic charge saving and generation
			KUNIVERSE:TIMEWARP:CANCELWARP().
			RCS ON.
			SAS OFF.
			LOCK STEERING TO UP + R(0,45,0).
			PANELS ON.
			FUELCELLS ON.
		}
		
		SET override TO ec OR mp.
	}
	
	LOCAL methods TO LEXICON(
		"refresh", refresh@,
		"override", override
	).
	
	RETURN methods.
}