@LAZYGLOBAL off.
COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Thrusting {
	PARAMETER trg_orbit.
	PARAMETER safe_alt IS 150. //safe altitude to release max thrust during a launch
	PARAMETER trg4throttp TO 10.
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	LOCAL pid_timer TO TIME:SECONDS.
	LOCAL throttle_PID to setPID(0, 0.5).
	SET throttle_PID:Kd TO 0.365.
	SET throttle_PID:Ki TO 0.0125.
	LOCAL using_rcs TO false.
	LOCAL aborted TO false.
	
	LOCAL pid_1s TO DoOnce().
	LOCAL rcs_1s TO DoOnce().
	LOCAL abort_1s IS DoOnce().
	LOCAL de_acc_1s IS DoOnce().
	LOCAL thrust_data IS LEXICON().
	LOCAL thrust_data_file IS "0:datasets/thrust1.json".
	IF (EXISTS(thrust_data_file)) {
		SET thrust_data TO READJSON(thrust_data_file).
	}
	LOCAL LOCK trg_pitch TO MAX(0, calcTrajectory(SHIP:ALTITUDE, 60000)).
	LOCAL LOCK ship_p TO 90 - VECTORANGLE(UP:FOREVECTOR, FACING:FOREVECTOR).
	LOCAL LOCK thrott TO throttle_PID:UPDATE(TIME:SECONDS - pid_timer, globals["q_pressure"]()).
	LOCAL LOCK trg4thrott TO trg4throttp * (1 / (getTWR() * 0.9)).

	LOCAL eng_list IS LIST().
    LIST ENGINES IN eng_list. 
	
	LOCAL function takeOff {
		SET throttle_PID:MAXOUTPUT TO 1.
		SET throttle_PID:MINOUTPUT TO 1.
		SET throttle_PID:SETPOINT TO 1.
		SET pid_timer TO TIME:SECONDS.
		LOCK THROTTLE TO thrott.
		LOCK STEERING TO HEADING(0, 90).
		RETURN "Take off".
	}
	
	function limitThrust {
		//limit to max 4 twr
		LOCAL limit IS MIN(4 / getTWR() * 100, 100).
		FOR eng in eng_list {
			SET eng:THRUSTLIMIT TO limit.
		}
	}
	
	LOCAL function handleFlight {
		LOCAL total_thrust IS 0.

		IF ALT:RADAR > safe_alt AND pid_1s["ready"]() {
			pid_1s["do"]({
				//reset pid from initial safe altitude gain 100% thrust
				LOCK STEERING TO HEADING(90, trg_pitch).
				SET pid_timer TO TIME:SECONDS.
				SET throttle_PID:MINOUTPUT TO 0.1.
				throttle_PID:RESET.
				logJ("Reached the safe altitude of " + safe_alt).
			}).
		}
		
		limitThrust().
		
		SET throttle_PID:SETPOINT TO trg4thrott.
		
		IF globals["ship_state"]["get"]("quiet") {
			SET throttle_PID:MINOUTPUT TO 0.
			SET throttle_PID:MAXOUTPUT TO 0.
		} ELSE {
			SET throttle_PID:MINOUTPUT TO 0.1.
			SET throttle_PID:MAXOUTPUT TO 1.
		}

		FOR eng in eng_list {
			IF eng:STAGE = STAGE:NUMBER {
				SET total_thrust TO total_thrust + eng:THRUST.
			}
		}
		IF total_thrust < 1 AND globals["q_pressure"]() < 1 AND NOT globals["ship_state"]["get"]("quiet")  {
			// SET using_rcs TO true.
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
	
	LOCAL last_thrott TO 0.
	LOCAL function decelerate {
		IF aborted {
			RETURN 0.
		}

		//decrease acceleration to not to overshoot target apoapsis
		de_acc_1s["do"]({
			SET last_thrott TO thrott.
			UNLOCK THROTTLE.
			UNLOCK throttle_PID.
			UNLOCK thrott.
			logJ("Deacceleration").
		}).
		IF NOT using_rcs {
			IF globals["ship_state"]["get"]("quiet") {
				LOCK THROTTLE TO 0.
			} ELSE {
				LOCK THROTTLE TO MAX(MIN(last_thrott - (APOAPSIS / trg_orbit["alt"] * last_thrott) ^ (30 * 1/getTWR()), last_thrott), 0.1).
			}
		} ELSE {
			SET SHIP:CONTROL:FORE TO MAX(MIN(TAN(CONSTANT:Radtodeg * (1 - (APOAPSIS/trg_orbit["alt"])) * 5 ), 1), 0.1).
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
		"trg_pitch", trg_pitch@, 
		"ship_p", ship_p@, 
		"trg4thrott", trg4thrott@, 
		"thrott", thrott@
	).
	
	RETURN methods.
}