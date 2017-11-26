@LAZYGLOBAL off.
COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

function P_HandleStaging {
	
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	LOCAL LOCK stg_res TO globals["stg_res"]().
	LOCAL staging_Timer IS Timer().
	LOCAL staging2_Timer IS Timer(). //for no acceleration staging wait
	LOCAL nacc_Timer IS Timer(). //for no acceleration test once
	LOCAL stage_1s IS DoOnce().
	LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS ^ 2.
	LOCAL done_staging IS true. //we dont need to stage when on launchpad or if loaded from a save to already staged rocket
	
	ON AG5 {
		//stage override, just in case
		staging_Timer["set"]().
		SET done_staging TO doStage().
	}
	
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	IF NOT(DEFINED ship_state) LOCAL ship_state TO globals["ship_state"].
	
	// --- METHODS
	
	function takeOff {
		SET done_staging TO doStage().
	}
	
	function check {
		PARAMETER res_type.
		IF res_type <> 0 {
			RETURN -1.
		}
		
		IF STAGE:(res_type + "") < 1 AND stg_res:HASKEY(res_type) {
			//FOR eng IN ship_engines{
				//eng:SHUTDOWN.
			//}
						RETURN stage_1s["do"]({
				staging_Timer["set"]().
				HUDTEXT("OUT OF " + res_type + ", STAGING, RESETTING PID", 6, 2, 42, green, false).
				HUDTEXT("SEPARATING...", 2, 2, 42, green, false).
				IF DEFINED this_craft {
					this_craft["Thrusting"]["resetPID"]().
				}
				SET done_staging TO doStage().
				RETURN "Stage " + STAGE:NUMBER + " - out of " + res_type.
			}).
		}
		staging_Timer["ready"](2, {
			stage_1s["reset"]().
		}).
	}
	
	function refresh {
		IF NOT done_staging {
			check("LIQUIDFUEL").
			check("SOLIDFUEL").
		}
		LOCAL valid_phase IS ship_state["state"]:HASKEY("phase") 
		AND (ship_state["state"]["phase"] = "TAKEOFF" 
		OR ship_state["state"]["phase"] = "THRUSTING").
		
		IF valid_phase {
			LOCAL no_acceleration TO SHIP:ALTITUDE < 70000 AND globals["acc_vec"]():MAG / g_base < 0.04.
			//if not under accel
			IF no_acceleration {
				RETURN nacc_Timer["ready"](4, {
					HUDTEXT("NO ACCELERATION DETECTED, WAITING FOR THRUST 3 SECONDS...", 3, 3, 20, red, false).
					staging2_Timer["set"]().
					nacc_Timer["set"]().
					RETURN "NO ACCELERATION DETECTED, WAITING FOR THRUST 3 SECONDS...".
				}).
			}
			
			staging2_Timer["ready"](3, {
				HUDTEXT("Waited 3 SECONDS...", 3, 2, 20, blue, false).
				//if there is still no acceleration, staging must have no engines available, stage again
				IF no_acceleration {
					stage_1s["reset"]().
					HUDTEXT("Reset, do stage.", 3, 2, 20, green, false).
					RETURN stage_1s["do"]({
						SET done_staging TO doStage().
						staging_Timer["set"]().
						staging2_Timer["set"]().
						RETURN "Stage " + STAGE:NUMBER + " - no acceleration detected during the thrusting phase".
					}).
				}
			}).
		}
	}

	LOCAL methods TO LEXICON(
		"refresh", refresh@,
		"takeOff", takeOff@,
		"done_staging", done_staging
	).
	
	RETURN methods.
}