COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("Timer", "DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Deployables {
	LOCAL fairing_1s IS doOnce().
	LOCAL deploy_1s IS doOnce().
	LOCAL antenna_1s IS doOnce().
	
	function jettisonFairing {
		return fairing_1s["do"]({
			IF doModuleEvent("ModuleProceduralFairing", "DEPLOY") {
				RETURN "Fairings jettison".
			} ELSE {
				HUDTEXT("NO FAIRINGS DETECTED", 2, 2, 42, RGB(255,60,0), false).
				RETURN "No fairings detected".
			}
		}).
	} //eject fairing	
	
	function deployAntennas {
		return antenna_1s["do"]({
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
		return deploy_1s["do"]({
			PANELS ON.
			RADIATORS ON.
			LIGHTS ON.
			RETURN "Panels ON Radiators ON Lights ON".
		}).
	}
	
	function resetAll {
		deploy_1s["reset"]().
		fairing_1s["reset"]().
		antenna_1s["reset"]().
	}
	
	LOCAL methods TO LEXICON(
		"fairing", jettisonFairing@,
		"antennas", deployAntennas@,
		"panels", deployPanels@,
		"reset", resetAll@
	).
	
	RETURN methods.
}