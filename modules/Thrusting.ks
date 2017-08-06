COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_Thrusting {
	PARAMETER safe_alt IS 150. //safe altitude to release max thrust during a launch
	LOCAL pid_timer TO TIME:SECONDS.
	LOCAL throttle_PID TO 0.

	LOCAL pitch_1s TO DoOnce().
	LOCAL pid_1s TO DoOnce().
	LOCAL abort_1s IS DoOnce().
	LOCAL de_acc_1s IS DoOnce().
	LOCAL no_acc_Timer IS Timer().
	LOCAL ship_p TO 0.
	LOCAL trgt_pitch TO 0.
	LOCAL thrott TO 1.
	LOCAL target_kPa IS 1.
	LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS ^ 2.
	
	function takeOff {
		SET throttle_PID to setPID(0, 1).
		SET throttle_PID:MAXOUTPUT TO 1.
		SET throttle_PID:MINOUTPUT TO 1.

		LOCK target_kPa TO ROUND(MAX(((-ALTITUDE + 40000) / 40000) * 10, 1), 3).
		SET throttle_PID:SETPOINT TO target_kPa.
	
		SET pid_timer TO TIME:SECONDS.
		LOCK THROTTLE TO thrott.
		LOCK ship_p TO 90 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR).
		LOCK thrott TO MAX(ROUND(throttle_PID:UPDATE(TIME:SECONDS - pid_timer, q_pressure), 3), 0.1).
		SET done_staging TO doStage().
		no_acc_Timer["set"]().
		HUDTEXT("TAKEOFF!", 1, 2, 40, green, false).
		RETURN "Take off".
	}
	
	function handleFlight {
		
		pitch_1s["do"]({
			LOCK trgt_pitch TO MAX(0, calcTrajectory(SHIP:ALTITUDE)).
			LOCK STEERING TO R(0, 0, 0) + HEADING(90, trgt_pitch).
		}).
		
		IF ALT:RADAR > safe_alt AND pid_1s["ready"]() {
			pid_1s["do"]({
				//reset pid from initial safe altitude gain 100% thrust
				SET set_pid TO false.
				SET pid_timer TO TIME:SECONDS.
				SET throttle_PID:MINOUTPUT TO 0.
				throttle_PID:RESET.
				logJ("Reached the safe altitude of " + safe_alt).
			}).
		}
		
		SET throttle_PID:SETPOINT TO target_kpa.
		Display["print"]("THR", thrott).
		Display["print"]("PITCH:", ROUND(90 - VECTORANGLE(UP:VECTOR, SHIP:FACING:FOREVECTOR), 3)).
		Display["print"]("T.PIT:", trgt_pitch).
		Display["print"]("kPa:", ROUND(q_pressure, 3)).
		Display["print"]("T.kPa:", target_kpa).
		Display["print"]("ACC:", ROUND(acc_vec:MAG / g_base, 3) + "G").
			
		IF (ship_p < 0 OR SHIP:VERTICALSPEED < 0) AND GROUNDSPEED < 2000 AND no_acc_Timer["check"]() < 8 AND no_acc_Timer["check"]() > 4{
			//if ship is off course when not achieved orbital speed yet and the staging wait isnt in progress
			abort_1s["do"]({
				LOCK THROTTLE TO 0.
				HUDTEXT("MALFUNCTION ABORT", 5, 2, 54, red, false).
				ABORT ON.
				UNLOCK STEERING.
				SET done TO true.
				logJ("Course deviation - malfunction - abort").
			}).
		}
	}
	
	function decelerate {
		//decrease acceleration to not to overshoot target apoapsis
		de_acc_1s["do"]({
			HUDTEXT("Decreasing acceleration", 2, 2, 42, green, false).
			UNLOCK throttle_PID.
			UNLOCK thrott.
			LOCK THROTTLE TO MAX(MIN( TAN( CONSTANT:Radtodeg*(1 - (APOAPSIS/trgt["alt"])) * 5 ), 1), 0.1).
			logJ("Deacceleration").
		}).
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
		"resetPID", resetPID@
	).
	
	RETURN methods.
}