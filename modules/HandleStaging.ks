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
	LOCAL quiet_Timer IS Timer().
	LOCAL no_acc_Timer IS Timer(). //for no acceleration staging wait
	LOCAL stage_1s IS DoOnce(). //for no acceleration test once
	LOCAL nacc_1s IS DoOnce(). //for no acceleration test once
	LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS ^ 2.
	LOCAL done_staging IS true. //we dont need to stage when on launchpad or if loaded from a save to already staged rocket
	LOCAL eng_list IS LIST().
    LIST ENGINES IN eng_list. 
	LOCAL quiet_period IS 3.
	LOCAL no_acc_period IS 5.
	LOCAL quiet IS false.
	
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
		SET done_staging TO doStage().
		STEERINGMANAGER:RESETPIDS().

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
				staging_Timer["set"]().
				quiet_Timer["set"]().
				SET quiet TO true.
			}).
		}
		quiet_Timer["ready"](1, {
			nextStage(res_type).
		}).
	}
	
	LOCAL function refresh {
		staging_Timer["ready"](quiet_period, {
			staging_Timer["reset"]().
			stage_1s["reset"]().
			SET quiet TO false.
		}).
		IF NOT done_staging{
			check("LIQUIDFUEL").
			check("OXIDIZER").
			check("SOLIDFUEL").
		}
		
		LOCAL must_thrust_phase IS ship_state["get"]():HASKEY("phase") 
		AND LIST("TAKEOFF", "THRUSTING"):CONTAINS(ship_state["get"]("phase")).
		ship_state["set"]("quiet", quiet).
		
		IF NOT must_thrust_phase {
			RETURN 2.
		}
		
		LOCAL no_acceleration TO SHIP:ALTITUDE < 70000 AND globals["acc_vec"]():MAG / g_base < 0.04.
		//if not under accel
		IF no_acceleration {
			nacc_1s["do"]({
				HUDTEXT("NO ACCELERATION DETECTED, WAITING FOR THRUST " + no_acc_period + " SECONDS...", 3, 3, 20, red, false).
				no_acc_Timer["set"]().
				logJ("NO ACCELERATION DETECTED, WAITING FOR THRUST 3 SECONDS...").
			}).
		}
		
		no_acc_Timer["ready"](no_acc_period, {
			HUDTEXT("Waited " + no_acc_period + " SECONDS...", 3, 2, 20, blue, false).
			//if there is still no acceleration, staging must have no engines available, stage again
			IF no_acceleration {
				HUDTEXT("Reset, do stage.", 3, 2, 20, green, false).
				SET done_staging TO doStage().
				staging_Timer["set"]().
				IF DEFINED this_craft AND this_craft:HASKEY("Thrusting") {
					HUDTEXT("Resetting engine PID", 5, 2, 20, green, false).
				}
				nacc_1s["reset"]().
				logJ("Stage " + STAGE:NUMBER + " - no acceleration detected during the thrusting phase").
			}
		}).
		
		RETURN done_staging.
	}
	
	LOCAL function getQuiet {
		return quiet.
	}

	LOCAL methods TO LEXICON(
		"refresh", refresh@,
		"takeOff", takeOff@,
		"quiet", getQuiet@
	).
	
	RETURN methods.
}