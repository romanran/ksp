COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("Functions", "ShipGlobals").
loadDeps(dependencies).

function P_CheckCraftCondition {
	LOCAL do_once IS true.
	LOCAL function checkTreshold {
		PARAMETER res.
		PARAMETER percent.
		PARAMETER r_amount.
		IF ship_res:HASKEY(res) {
			RETURN ((ship_res[res]:AMOUNT / ship_res[res]:CAPACITY) * 100 < percent) OR ship_res[res]:AMOUNT < r_amount.
		} ELSE {
			RETURN false.
		}
	}
	LOCAL LOCK ship_res TO getResources().
	LOCAL override IS 0.
	
	LOCAL function refresh {
		LOCAL ec TO checkTreshold("ELECTRICCHARGE", 20, 40).
		LOCAL mp TO checkTreshold("MonoPropellant", 1, 1).
		IF ec AND do_once AND NOT (globals["ship_state"]["get"]("phase") = "KERBINJECTION") {
			//if below 20% of max ships capacity or 40 units
			//electic charge saving and generation
			KUNIVERSE:TIMEWARP:CANCELWARP().
			RCS ON.
			SAS OFF.
			SET THROTTLE TO 0.
			LOCK STEERING TO SHIP:PROGRADE:VECTOR.
			PANELS ON.
			FUELCELLS ON.
			SET do_once TO false.
		}
		
		SET override TO ec OR mp.
	}
	
	LOCAL function getOverride {
		return override.
	}
	
	LOCAL methods TO LEXICON(
		"refresh", refresh@,
		"override", getOverride@
	).
	
	RETURN methods.
}