COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("Functions", "ShipGlobals", "Timer", "DoOnce").
loadDeps(dependencies).

function P_PreLaunch {
	LOCAL from_save TO true.
	LOCAL countdown_1s IS doOnce().
	LOCAL staging_Timer IS Timer().
	LOCAL countdown IS 5.
	LOCAL start IS 0.
	LOCAL ksc_light TO "".
	LOCAL first_stage_engines IS LIST().
	
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	IF NOT(DEFINED Display) LOCAL Display TO globals["Display"].
	//--PRELAUNCH
	LOCAL function init {
		SET from_save TO false.
		LOCAL start IS false.
		
		LOCAL ship_engines IS LIST().
		LIST ENGINES IN ship_engines.

		LOCAL last_eng_i TO 0.
		FOR eng IN ship_engines {
			IF eng:STAGE = STAGE:NUMBER - 1 {
				first_stage_engines:ADD(eng).
			}
		}
		PRINT first_stage_engines.
		
		LOCAL function preLaunchError {
			PARAMETER err.
			LOCAL Sounds TO GETVOICE(0).
			HUDTEXT(err, 5, 4, 40, red, false).
			Sounds:PLAY(NOTE(400, 0.1)).
			Display["print"](err).
			Display["print"]("Press any key to REBOOT").
			WAIT UNTIL TERMINAL:INPUT:HASCHAR. 
			REBOOT.
		}
		
		IF first_stage_engines:LENGTH = 0 {
			preLaunchError("COULDN'T FIND 1st STAGE ENGINES").
		}
		
		LOCAL sensors_list IS LIST().
		LOCAL sensors_types IS LIST().
		LIST SENSORS IN sensors_list.
		FOR S IN sensors_list {
			sensors_types:ADD(S:TYPE).
		}
		IF (NOT sensors_types:CONTAINS("acc")) {
			preLaunchError("No accelerometer detected on the vessel").
		}
		IF (NOT sensors_types:CONTAINS("grav")) {
			preLaunchError("No gravimeter detected on the vessel").
		}

		SET ksc_light TO SHIP:PARTSTAGGED("ksc_light").
		Display["print"]("Checks passed").
	}
	
	function refresh {
		IF TERMINAL:INPUT:HASCHAR {
			LOCAL char to TERMINAL:INPUT:GETCHAR().
			IF char = TERMINAL:INPUT:ENTER {
				SET start to true.
			}
		} 
		IF NOT start {
			RETURN 0.
		}
		countdown_1s["do"]({
			Display["print"]("COUNTDOWN STARTED").
			doModuleAction("modulelight", "togglelight", true, ksc_light).
			logJ("Countdown start").
			staging_Timer["set"]().
		}).
		
		
		RETURN staging_Timer["ready"](1, {
			IF countdown = 4 {
				LOCK THROTTLE TO 1.
			}
			IF TERMINAL:INPUT:HASCHAR {
				LOCAL char to TERMINAL:INPUT:GETCHAR().
				IF char = TERMINAL:INPUT:RETURN {
					doModuleAction("modulelight", "togglelight", false, ksc_light).
					reboot.
				}
			}				
			IF countdown = 1 {
				FOR eng IN first_stage_engines {
					eng:ACTIVATE.
				}
				HUDTEXT("Engines ingnition", 1, 2, 40, green, false).
			}
			IF countdown > 0 { 
				HUDTEXT(countdown + "...", 1, 2, 40, green, false).
			}
			SET countdown TO countdown - 1.
			staging_Timer["set"]().
			return countdown < 0.
		}).
	}
	
	LOCAL function getFromSave {
		return from_save.
	}
	
	LOCAL methods TO LEXICON(
		"init", init@,
		"refresh", refresh@,
		"from_save", getFromSave@
	).
	
	RETURN methods.
}