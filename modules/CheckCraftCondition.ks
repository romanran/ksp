COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("Functions", "ShipGlobals").
loadDeps(dependencies).

function P_CheckCraftCondition {
	LOCAL ship_res TO getResources().
	LOCAL LOCK ec TO ((ship_res["ELECTRICCHARGE"]:AMOUNT / ship_res["ELECTRICCHARGE"]:CAPACITY) * 100 < 20) OR ship_res["ELECTRICCHARGE"]:AMOUNT < 40.
	LOCAL LOCK mp TO ((ship_res["MonoPropellant"]:AMOUNT / ship_res["MonoPropellant"]:CAPACITY) * 100 < 1) OR ship_res["MonoPropellant"]:AMOUNT < 1.
	LOCAL override IS 0.
	
	function refresh {
		SET ship_res TO getResources().
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