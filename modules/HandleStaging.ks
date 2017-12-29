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
	LOCAL nacc_1s IS DoOnce(). //for no acceleration test once
	LOCAL stage_1s IS DoOnce().
	LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS ^ 2.
	LOCAL done_staging IS true. //we dont need to stage when on launchpad or if loaded from a save to already staged rocket
	LOCAL stage_delay TO 2.
	LOCAL eng_list IS LIST().
    LIST ENGINES IN eng_list. 
	
	IF NOT(DEFINED globals) {
		GLOBAL globals TO setGlobal().
	}
	IF NOT(DEFINED ship_state) LOCAL ship_state TO globals["ship_state"].
	
	// --- METHODS ---
	
	LOCAL function takeOff {
		SET done_staging TO doStage().
	}
	
	LOCAL function nextStage {
		PARAMETER res_type.

		HUDTEXT("No " + res_type + " left, staging", 5, 2, 20, green, false).
		IF DEFINED this_craft AND this_craft:HASKEY("Thrusting") {
			HUDTEXT("Resetting engine PID", 5, 2, 20, green, false).
			this_craft["Thrusting"]["resetPID"]().
		}
		SET done_staging TO doStage().
		WAIT 0.
		FOR eng IN eng_list {
			IF eng:STAGE = STAGE:NUMBER {
				eng:SHUTDOWN.
			}
		}

		RETURN "Stage " + STAGE:NUMBER + " - out of " + res_type.
	}
	
	LOCAL function check {
		PARAMETER res_type.
		IF NOT res_type <> 0 {
			RETURN -1.
		}
		LOCAL out_of_res TO false.
		IF res_type = "LIQUIDFUEL" {
			SET out_of_res TO STAGE:LIQUIDFUEL < 1.
		} ELSE IF res_type = "SOLIDFUEL" {
			SET out_of_res TO STAGE:SOLIDFUEL < 1.
		} ELSE IF res_type = "MONOPROPELLANT" {
			SET out_of_res TO STAGE:MONOPROPELLANT < 1.
		} ELSE IF res_type = "OXIDIZER" {
			SET out_of_res TO STAGE:OXIDIZER < 1.
		}
		IF out_of_res AND stg_res:HASKEY(res_type) {
			stage_1s["do"]({
				HUDTEXT("Separation in " + stage_delay + " seconds...", 2, 2, 42, green, false).
				staging_Timer["set"]().
				nextStage(res_type).
			}).
		}
		staging_Timer["ready"](stage_delay, {
			stage_1s["reset"]().
			FOR eng IN eng_list {
				IF eng:STAGE = STAGE:NUMBER {
					eng:ACTIVATE.
				}
			}
			staging_Timer["reset"]().
		}).
	}
	
	LOCAL function refresh {
		IF NOT done_staging {
			check("LIQUIDFUEL").
			check("OXIDIZER").
			check("SOLIDFUEL").
		}
		
		LOCAL must_thrust_phase IS ship_state["state"]:HASKEY("phase") 
		AND LIST("TAKEOFF", "THRUSTING"):CONTAINS(ship_state["state"]["phase"]).
		
		IF NOT must_thrust_phase {
			RETURN 2.
		}
		
		LOCAL no_acceleration TO SHIP:ALTITUDE < 70000 AND globals["acc_vec"]():MAG / g_base < 0.04.
		//if not under accel
		IF no_acceleration {
			nacc_1s["do"]({
				HUDTEXT("NO ACCELERATION DETECTED, WAITING FOR THRUST 3 SECONDS...", 3, 3, 20, red, false).
				staging2_Timer["set"]().
				logJ("NO ACCELERATION DETECTED, WAITING FOR THRUST 3 SECONDS...").
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
					IF DEFINED this_craft AND this_craft:HASKEY("Thrusting") {
						HUDTEXT("Resetting engine PID", 5, 2, 20, green, false).
						this_craft["Thrusting"]["resetPID"]().
					}
					nacc_1s["reset"]().
					logJ("Stage " + STAGE:NUMBER + " - no acceleration detected during the thrusting phase").
				}).
			}
		}).
		
		RETURN done_staging.
	}

	LOCAL methods TO LEXICON(
		"refresh", refresh@,
		"takeOff", takeOff@
	).
	
	RETURN methods.
}