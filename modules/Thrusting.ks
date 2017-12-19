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
	LOCAL throttle_PID to setPID(0, 1).
	LOCAL using_rcs TO false.
	LOCAL aborted TO false.
	
	LOCAL pitch_1s TO DoOnce().
	LOCAL pid_1s TO DoOnce().
	LOCAL rcs_1s TO DoOnce().
	LOCAL abort_1s IS DoOnce().
	LOCAL de_acc_1s IS DoOnce().
	LOCAL LOCK trgt_pitch TO MAX(0, calcTrajectory(SHIP:ALTITUDE)).
	LOCAL LOCK ship_p TO 90 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR).
	LOCAL LOCK thrott TO MAX(ROUND(throttle_PID:UPDATE(TIME:SECONDS - pid_timer, globals["q_pressure"]()), 3), 0.1).
	LOCAL LOCK target_kPa TO ROUND(MAX(((-ALTITUDE + 40000) / 40000) * 10, 1), 3).

	
	function takeOff {
		SET throttle_PID:MAXOUTPUT TO 1.
		SET throttle_PID:MINOUTPUT TO 1.
		SET throttle_PID:SETPOINT TO target_kPa.
		SET pid_timer TO TIME:SECONDS.
		LOCK THROTTLE TO thrott.
		RETURN "Take off".
	}
	
	function handleFlight {
		
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
		
		SET throttle_PID:SETPOINT TO target_kpa.
		IF ROUND(globals["acc_vec"]():MAG / (KERBIN:MU / KERBIN:RADIUS ^ 2), 3) < 1 AND ALTITUDE > 70000 {
			SET using_rcs TO true.
		}
		
		IF using_rcs {
			rcs_1s["do"]({
				LOCK THROTTLE TO 0.
				SET SHIP:CONTROL:FORE TO 1. // use rcs
				logJ("Switch to rcs thrusters").
			}).
		}

		IF (ship_p < 0 OR SHIP:VERTICALSPEED < 0) AND GROUNDSPEED < 1800 {
			//if ship is off course when not achieved orbital speed yet and the staging wait isnt in progress
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
	
	function decelerate {
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
	
	function resetPID {
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
		"target_kpa", target_kpa@, 
		"thrott", thrott@
	).
	
	RETURN methods.
}