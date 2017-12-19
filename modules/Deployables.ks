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
		PARAMETER t_on TO 1.
		IF NOT antenna_1s["ready"]() {
			RETURN "Already called".
		}
		return antenna_1s["do"]({
			IF t_on {
				IF doModuleEvent("ModuleRTAntenna", "ACTIVATE")  OR doModuleEvent("ModuleDeployableAntenna", "extend antenna") {
					HUDTEXT("DEPLOYING ANTENNAS", 2, 2, 42, RGB(55,255,0), false).
					RETURN "Antennas deploy".
				} ELSE {
					HUDTEXT("NO ANTENNAS DETECTED", 2, 2, 42, RGB(255,60,0), false).
					RETURN "Antennas not deployed - no antennas on the craft, this message is pretty useless, isn't it?".
				}
			} ELSE {
				IF doModuleEvent("ModuleRTAntenna", "DEACTIVATE") OR doModuleEvent("ModuleDeployableAntenna", "retract antenna") {
					HUDTEXT("RETRACTING ANTENNAS", 2, 2, 42, RGB(55,255,0), false).
					RETURN "Antennas retract".
				} ELSE {
					HUDTEXT("NO ANTENNAS DETECTED", 2, 2, 42, RGB(255,60,0), false).
					RETURN "Antennas not deployed - no antennas on the craft, this message is pretty useless, isn't it?".
				}
			}
		}).
	}
	
	function retractAntennas {
		return deployAntennas(0).
	}
	
	function deployPanels {
		PARAMETER t_on TO 1.
		IF t_on {
			return deploy_1s["do"]({
				PANELS ON.
				RADIATORS ON.
				LIGHTS ON.
				RETURN "Panels ON Radiators ON Lights ON".
			}).
		} ELSE {
			return deploy_1s["do"]({
				PANELS OFF.
				RADIATORS OFF.
				LIGHTS OFF.
				RETURN "Panels OFF Radiators OFF Lights OFF".
			}).
		}
	}
	
	function retractPanels {
		return deployPanels(0).
	}
	
	function resetAll {
		deploy_1s["reset"]().
		fairing_1s["reset"]().
		antenna_1s["reset"]().
	}
	
	LOCAL methods TO LEXICON(
		"fairing", jettisonFairing@,
		"antennas", deployAntennas@,
		"retractAntennas", retractAntennas@,
		"panels", deployPanels@,
		"retractPanels", retractPanels@,
		"reset", resetAll@
	).
	
	RETURN methods.
}