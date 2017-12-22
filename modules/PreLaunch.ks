COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("Functions", "ShipGlobals").
loadDeps(dependencies).


function P_PreLaunch {
	LOCAL from_save TO true.
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	IF NOT(DEFINED Display) LOCAL Display TO globals["Display"].
	//--PRELAUNCH
	function init {
		LOCAL from_save TO false.
		LOCAL start IS false.
		
		LOCAL ship_engines IS LIST().
		LIST ENGINES IN ship_engines.

		LOCAL first_stage_engines IS LIST().
		LOCAL last_eng_i TO 0.
		FOR eng IN ship_engines{
			IF eng:STAGE > last_eng_i {
				SET last_eng_i TO eng:STAGE.
			}
		}
		FOR eng IN ship_engines{
			IF eng:STAGE = last_eng_i {
				first_stage_engines:ADD(eng).
			}
		}
		function preLaunchError {
			PARAMETER err.
			LOCAL Sounds TO GETVOICE(0).
			HUDTEXT(err, 5, 4, 40, red, false).
			Sounds:PLAY(NOTE(400, 0.1)).
			Display["print"](err).
			Display["print"]("REBOOT? AG2").
			WAIT UNTIL AG2. 
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
			preLaunchError("No gravetometer detected on the vessel").
		}

		LOCAL ksc_light TO SHIP:PARTSTAGGED("ksc_light").
		IF ksc_light:LENGTH > 0{
			SET ksc_m_light TO ksc_light[0]:GETMODULE("modulelight").
		}
		ON AG1 {
			doModuleAction("modulelight", "togglelight", true, ksc_light).
			SET start TO TRUE.
			logJ("Countdown start").
		}
		Display["print"]("ALL SYSTEMS ARE GO.").
		Display["print"]("AWAITING LAUNCH CONFIRMATION ON AG1").
		Display["print"]("ABORT ON AG3.").
		WAIT UNTIL start = TRUE.
		
		Display["print"]("COUNTDOWN START").
		FROM {LOCAL i IS 5.} UNTIL i = -1 STEP {SET i TO i - 1.} DO {
			WAIT 1.
			IF i = 4 {
				LOCK THROTTLE TO 1.
			}
			ON AG3 {
				doModuleAction("modulelight", "togglelight", false, ksc_light).
				reboot.
			}
			IF i = 1 {
				FOR eng IN first_stage_engines {
					eng:ACTIVATE.
				}
				HUDTEXT("Engines ingnition", 1, 2, 40, green, false).
			}
			IF i > 0 { 
				HUDTEXT(i + "...", 1, 2, 40, green, false).
			}
		}
	}
	
	LOCAL methods TO LEXICON(
		"init", init@,
		"from_save", from_save
	).
	
	RETURN methods.
}