function P_Deployables {
	LOCAL fairing_1s IS doOnce().
	LOCAL deploy_1s IS doOnce().
	LOCAL antenna_Timer IS Timer().
	
	function jettisonFairing {
		fairing_1s["do"]({
			IF doModuleEvent("ModuleProceduralFairing", "DEPLOY") {
				RETURN "Fairings jettison".
			} ELSE {
				HUDTEXT("NO FAIRINGS DETECTED", 2, 2, 42, RGB(255,60,0), false).
				RETURN "No fairings detected".
			}
		}).
		return fairing_1s.
	} //eject fairing	
	
	function deployAntennas {
		RETURN antenna_Timer["ready"](3, {
			IF doModuleEvent("ModuleRTAntenna", "ACTIVATE")  OR doModuleEvent("ModuleDeployableAntenna", "extend antenna") {
				HUDTEXT("DEPLOYING ANTENNAS", 2, 2, 42, RGB(55,255,0), false).
				RETURN "Antennas deploy".
			} ELSE {
				HUDTEXT("NO ANTENNAS DETECTED", 2, 2, 42, RGB(255,60,0), false).
				RETURN "Antennas not deployed - no antennas on the craft, this message is pretty useless, isn't it?".
			}
		}).
	}
	
	function deployPanels {
		deploy_1s["do"]({
			PANELS ON.
			RADIATORS ON.
			LIGHTS ON.
			antenna_Timer["set"]().
			RETURN "Panels ON Radiators ON Light ON".
		}).
		return deploy_1s.
	}
	
	LOCAL methods TO LEXICON(
		"fairing", jettisonFairing@,
		"antennas", deployAntennas@,
		"panels", deployPanels@
	).
	
	RETURN methods.
}