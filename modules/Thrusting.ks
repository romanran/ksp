@LAZYGLOBAL off.
COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Thrusting {
	PARAMETER trg_orbit.
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	LOCAL using_rcs TO false.
	LOCAL aborted TO false.
	
	LOCAL pitch_1s TO DoOnce().
	LOCAL rcs_1s TO DoOnce().
	LOCAL abort_1s IS DoOnce().
	LOCAL de_acc_1s IS DoOnce().

	LOCAL LOCK trg_pitch TO MAX(0, calcTrajectory(70000)).
	LOCAL LOCK ship_p TO 90 - VECTORANGLE(UP:FOREVECTOR, FACING:FOREVECTOR).
	LOCAL thrott TO 1.
	LOCAL eng_list IS LIST().
    LIST ENGINES IN eng_list. 
	
	LOCAL function takeOff {
		LOCK THROTTLE TO thrott.
		RETURN "Take off".
	}
	
	LOCAL function handleFlight {
		LOCAL total_thrust IS 0.
		pitch_1s["do"]({
			LOCK STEERING TO R(0, 0, 0) + HEADING(90, trg_pitch).
		}).
		
		IF globals["ship_state"]["get"]("quiet")  {
			SET thrott TO 0.
		} ELSE {
			SET thrott TO 1.
		}


		FOR eng in eng_list {
			IF eng:STAGE = STAGE:NUMBER {
				SET total_thrust TO total_thrust + eng:THRUST.
			}
		}
		IF total_thrust < 1 AND globals["q_pressure"]() < 1 AND NOT globals["ship_state"]["get"]("quiet")  {
			SET using_rcs TO true.
		}
		IF using_rcs {
			rcs_1s["do"]({
				RCS ON.
				SET SHIP:CONTROL:FORE TO 1. // use RCS
				logJ("Switch to RCS thrusters").
			}).
		}

		IF (ship_p < -10 OR SHIP:VERTICALSPEED < 0) AND GROUNDSPEED < 1800 {
			//if ship is off course when not achieved orbital speed yet and the staging wait isn't in progress
			abort_1s["do"]({
				LOCK THROTTLE TO 0.
				HUDTEXT("MALFUNCTION ABORT", 5, 2, 54, red, false).
				ABORT ON.
				UNLOCK STEERING.
				logJ("Course deviation - malfunction - abort").
				globals["ship_state"]["set"]("phase", "aborted").
				SET aborted TO true.
				IF using_rcs {
					SET SHIP:CONTROL:FORE TO 0.
				}
			}).
		}
	}
	
	LOCAL function decelerate {
		IF aborted {
			RETURN 0.
		}

		//decrease acceleration to not to overshoot target apoapsis
		de_acc_1s["do"]({
			HUDTEXT("Decreasing acceleration", 2, 2, 42, green, false).
			UNLOCK thrott.
			logJ("Deacceleration").
		}).
		IF NOT using_rcs {
			IF globals["ship_state"]["get"]("quiet") {
				SET THROTTLE TO 0.
			} ELSE {
				SET THROTTLE TO MAX(MIN(TAN(CONSTANT:Radtodeg * (1 - APOAPSIS/trg_orbit["alt"]) * 5 ), 1), 0.1).
			}
		} ELSE {
			SET SHIP:CONTROL:FORE TO MAX(MIN(TAN(CONSTANT:Radtodeg * (1 - (APOAPSIS/trg_orbit["alt"])) * 5 ), 1), 0.1).
		}
	}
	
	
	LOCAL methods TO LEXICON(
		"takeOff", takeOff@,
		"handleFlight", handleFlight@,
		"decelerate", decelerate@,
		"trg_pitch", trg_pitch@, 
		"ship_p", ship_p@
	).
	
	RETURN methods.
}