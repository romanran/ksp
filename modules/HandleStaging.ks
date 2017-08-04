function P_HandleStaging {
	LOCAL staging_Timer IS Timer().
	LOCAL staging2_Timer IS Timer(). //for no acceleration staging wait
	LOCAL nacc_Timer IS Timer(). //for no acceleration test once
	LOCAL stage_1s IS DoOnce().
	LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS ^ 2.
	
	ON AG5 {
		//stage override, just in case
		SET stg TO doStage().
		staging_Timer["set"]().
		SET done_staging TO stg["done"].
		ship_log["add"]("manually staged").
	}
	
	function refresh {
		IF DEFINED done_staging AND done_staging = false {
			IF STAGE:LIQUIDFUEL < 1 AND stg_res:HASKEY("LIQUIDFUEL") {
				//FOR eng IN ship_engines{
					//eng:SHUTDOWN.
				//}
				stage_1s["do"]({
					staging_Timer["set"]().
					HUDTEXT("OUT OF LIQUID FUEL", 1, 2, 42, green, false).
					HUDTEXT("SEPARATING...", 2, 2, 42, green, false).
					SET stg TO doStage().
					SET done_staging TO stg["done"].
					//SET stg_res TO stg["res"].
					
					ship_log["add"]("Stage " + STAGE:NUMBER + " - out of LF").
				}).
				RETURN 1.
			}
			IF STAGE:SOLIDFUEL < 0.1 AND stg_res:HASKEY("SOLIDFUEL") {
				stage_1s["do"]({
					staging_Timer["set"]().
					HUDTEXT("OUT OF SOLID FUEL, STAGING, RESETTING PID", 6, 2, 42, green, false).
					SET pid_timer TO TIME:SECONDS.
					IF DEFINED throttle_PID {
						throttle_PID:RESET.
					}
					IF DEFINED pid_1s {
						pid_1s["reset"]().
					}
					SET stg TO doStage().
					SET done_staging TO stg["done"].
					//SET stg_res TO stg["res"].
					ship_log["add"]("Stage " + STAGE:NUMBER + " - out of SF").
				}).
			}
			staging_Timer["ready"](2, {
				stage_1s["reset"]().
			}).
			RETURN 1.
		}
		
		IF ship_state["state"]:HASKEY("phase") AND (ship_state["state"]["phase"] = "TAKEOFF" OR ship_state["state"]["phase"] = "THRUSTING") {
			LOCAL no_acceleration TO SHIP:ALTITUDE < 70000 AND accvec:MAG / g_base < 0.04.
			//if not under accel
			IF no_acceleration {
				nacc_Timer["ready"](4, {
					HUDTEXT("NO ACCELERATION DETECTED, WAITING FOR THRUST 3 SECONDS...", 3, 3, 20, red, false).
					staging2_Timer["set"]().
					nacc_Timer["set"]().
				}).
			}
			
			staging2_Timer["ready"](3, {
				HUDTEXT("Waited 3 SECONDS...", 3, 2, 20, blue, false).
				//if there is still no acceleration, staging must have no engines available, stage again
				IF no_acceleration {
					stage_1s["reset"]().
					HUDTEXT("Reset, do stage.", 3, 2, 20, green, false).
					stage_1s["do"]({
						SET stg TO doStage().
						SET done_staging TO stg["done"].
						//SET stg_res TO stg["res"].
						staging_Timer["set"]().
						staging2_Timer["set"]().
						ship_log["add"]("Stage " + STAGE:NUMBER + " - no acceleration detected during the thrusting phase").
					}).
				}
			}).
		}
	}
	
	LOCAL methods TO LEXICON(
		"refresh", refresh@
	).
	
	RETURN methods.
}