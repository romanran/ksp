COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("Functions", "ShipGlobals").
loadDeps(dependencies).

function P_CheckCraftCondition {

	function checkTreshold {
		PARAMETER res.
		PARAMETER percent.
		PARAMETER r_amount.
		IF ship_res:HASKEY(res) {
			RETURN ((ship_res[res]:AMOUNT / ship_res[res]:CAPACITY) * 100 < percent) OR ship_res[res]:AMOUNT < r_amount.
		} ELSE {
			RETURN 0.
		}
	}
	LOCAL LOCK ship_res TO getResources().
	LOCAL LOCK ec TO checkTreshold("ELECTRICCHARGE", 20, 40).
	LOCAL LOCK mp TO checkTreshold("MonoPropellant", 1, 1).
	LOCAL override IS 0.
	
	function refresh {
		IF ec {
			//if below 20% of max ships capacity or 40 units
			//electic charge saving and generation
			KUNIVERSE:TIMEWARP:CANCELWARP().
			RCS ON.
			SAS OFF.
			LOCK STEERING TO UP + R(0, 45, 0).
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