@LAZYGLOBAL off.
COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Thrusting {
	PARAMETER trgt_orbit.
	PARAMETER safe_alt IS 150. //safe altitude to release max thrust during a launch
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	LOCAL pid_timer TO TIME:SECONDS.
	LOCAL throttle_PID to setPID(0, 0.1).
	LOCAL using_rcs TO false.
	LOCAL aborted TO false.
	
	LOCAL pitch_1s TO DoOnce().
	LOCAL pid_1s TO DoOnce().
	LOCAL rcs_1s TO DoOnce().
	LOCAL abort_1s IS DoOnce().
	LOCAL de_acc_1s IS DoOnce().
	LOCAL thrust_data IS LEXICON().
	LOCAL thrust_data_file IS "0:datasets/thrust1.json".
	IF (EXISTS(thrust_data_file)) {
		SET thrust_data TO READJSON(thrust_data_file).
	}
	LOCAL LOCK trgt_pitch TO MAX(0, calcTrajectory(SHIP:ALTITUDE)).
	LOCAL LOCK ship_p TO 90 - VECTORANGLE(UP:FOREVECTOR, FACING:FOREVECTOR).
	LOCAL LOCK thrott TO MAX(ROUND(throttle_PID:UPDATE(TIME:SECONDS - pid_timer, SHIP:VELOCITY:SURFACE:MAG), 3), 0.1).
	LOCAL LOCK target4throttle TO interpolateLagrange(thrust_data, ALTITUDE).
	LOCAL eng_list IS LIST().
    LIST ENGINES IN eng_list. 
	
	// LOCAL LOCK thrott TO MAX(ROUND(throttle_PID:UPDATE(TIME:SECONDS - pid_timer, globals["q_pressure"]()), 3), 0.1).
    LOCAL LOCK target_kPa TO ROUND(MAX(((-ALTITUDE + 40000) / 40000) * 10, 1), 3).
 
	LOCAL function takeOff {
		SET throttle_PID:MAXOUTPUT TO 1.
		SET throttle_PID:MINOUTPUT TO 1.
		SET throttle_PID:SETPOINT TO 1.
		SET pid_timer TO TIME:SECONDS.
		LOCK THROTTLE TO thrott.
		RETURN "Take off".
	}
	
	LOCAL function handleFlight {
		LOCAL total_thrust IS 0.
		pitch_1s["do"]({
			LOCK STEERING TO R(0, 0, 0) + HEADING(90, trgt_pitch).
		}).
		
		IF ALT:RADAR > safe_alt AND pid_1s["ready"]() {
			pid_1s["do"]({
				//reset pid from initial safe altitude gain 100% thrust
				SET pid_timer TO TIME:SECONDS.
				SET throttle_PID:MINOUTPUT TO 0.
				throttle_PID:RESET.
				logJ("Reached the safe altitude of " + safe_alt).
			}).
		}
		SET throttle_PID:SETPOINT TO target4throttle.
		FOR eng in eng_list {
			IF eng:STAGE = STAGE:NUMBER {
				SET total_thrust TO total_thrust + eng:THRUST.
			}
		}
		IF total_thrust < 1 AND globals["q_pressure"]() < 1 {
			SET using_rcs TO true.
		}
		
		IF using_rcs {
			rcs_1s["do"]({
				RCS ON.
				SET SHIP:CONTROL:FORE TO 1. // use RCS
				logJ("Switch to RCS thrusters").
			}).
		}

		IF (ship_p < 0 OR SHIP:VERTICALSPEED < 0) AND GROUNDSPEED < 1800 {
			//if ship is off course when not achieved orbital speed yet and the staging wait isn't in progress
			abort_1s["do"]({
				LOCK THROTTLE TO 0.
				HUDTEXT("MALFUNCTION ABORT", 5, 2, 54, red, false).
				ABORT ON.
				UNLOCK STEERING.
				logJ("Course deviation - malfunction - abort").
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
			UNLOCK throttle_PID.
			UNLOCK thrott.
			IF NOT using_rcs {
				LOCK THROTTLE TO MAX(MIN( TAN( CONSTANT:Radtodeg*(1 - (APOAPSIS/trgt_orbit["alt"])) * 5 ), 1), 0.1).
			}
			logJ("Deacceleration").
		}).
		IF using_rcs {
			SET SHIP:CONTROL:FORE TO MAX(MIN( TAN( CONSTANT:Radtodeg*(1 - (APOAPSIS/trgt_orbit["alt"])) * 5 ), 1), 0.1).
		}
	}
	
	LOCAL function resetPID {
		SET pid_timer TO TIME:SECONDS.
		throttle_PID:RESET.
		pid_1s["reset"]().
	}
	
	LOCAL methods TO LEXICON(
		"takeOff", takeOff@,
		"handleFlight", handleFlight@,
		"decelerate", decelerate@,
		"resetPID", resetPID@,
		"trgt_pitch", trgt_pitch@, 
		"ship_p", ship_p@, 
		"target4throttle", target4throttle@, 
		"thrott", thrott@
	).
	
	RETURN methods.
}