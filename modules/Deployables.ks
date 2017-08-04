function P_Deployables {
	LOCAL fairing_1s IS doOnce().
	LOCAL deploy_1s IS doOnce().
	LOCAL antenna_Timer IS Timer().
	
	function jettisonFairing {
		fairing_1s["do"]({
			IF doModuleEvent("ModuleProceduralFairing", "DEPLOY") {
				ship_log["add"]("Fairings jettison").
			} ELSE {
				HUDTEXT("NO FAIRINGS DETECTED", 2, 2, 42, RGB(255,60,0), false).
			}
		}).
		return fairing_1s.
	} //eject fairing	
	
	function deployAntennas {
		antenna_Timer["ready"](3, {
			IF doModuleEvent("ModuleRTAntenna", "ACTIVATE")  OR doModuleEvent("ModuleDeployableAntenna", "extend antenna") {
				HUDTEXT("DEPLOYING ANTENNAS", 2, 2, 42, RGB(55,255,0), false).
				ship_log["add"]("Antennas deploy").
			} ELSE {
				HUDTEXT("NO ANTENNAS DETECTED", 2, 2, 42, RGB(255,60,0), false).
			}
		}).
		return deploy_1s.
	}
	
	function deployPanels {
			deploy_1s["do"]({
			PANELS ON.
			RADIATORS ON.
			LIGHTS ON.
			antenna_Timer["set"]().
		}).
		
	}
	
	LOCAL methods TO LEXICON(
		"fairing", jettisonFairing@,
		"antennas", deployAntennas@,
		"panels", deployPanels@
	).
	
	RETURN methods.
}