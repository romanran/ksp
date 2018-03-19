@LAZYGLOBAL off.
IF NOT EXISTS("1:Utils") AND HOMECONNECTION:ISCONNECTED {
	COPYPATH("0:lib/Utils", "1:").
}
RUNONCEPATH("UTILS").
LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "ShipGlobals").
loadDeps(dependencies).

IF NOT(DEFINED globals) GLOBAL globals TO setGlobal().

function P_HandleStaging {

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
	LOCAL ship_state TO globals["ship_state"].
	
	// --- METHODS ---
	LOCAL function takeOff {
		SET done_staging TO doStage().
	}
	
	LOCAL function nextStage {
		PARAMETER res_type.
		SET done_staging TO doStage().
		LIST ENGINES IN eng_list. 
		STEERINGMANAGER:RESETPIDS().
		IF DEFINED this_craft AND this_craft:HASKEY("Thrusting") {
			this_craft["Thrusting"]["resetPID"]().
		} 
 
		RETURN "Stage " + STAGE:NUMBER + " - out of " + res_type.
	}
	
	LOCAL function check {
		PARAMETER res_type.
		PARAMETER tresh IS 1.
		IF NOT res_type <> 0 {
			RETURN -1.
		}
		LOCAL out_of_res TO false.
		IF res_type = "LIQUIDFUEL" {
			SET out_of_res TO STAGE:LIQUIDFUEL < tresh.
		} ELSE IF res_type = "SOLIDFUEL" {
			SET out_of_res TO STAGE:SOLIDFUEL < tresh.
		} ELSE IF res_type = "MONOPROPELLANT" {
			SET out_of_res TO STAGE:MONOPROPELLANT < tresh.
		} ELSE IF res_type = "OXIDIZER" {
			SET out_of_res TO STAGE:OXIDIZER < tresh.
		}
		IF out_of_res AND stg_res:HASKEY(res_type) {
			stage_1s["do"]({
				staging_Timer["set"]().
				quiet_Timer["set"]().
				ship_state["set"]("quiet", true).
			}).
		}
		quiet_Timer["ready"](2, {
			nextStage(res_type).
		}).
		RETURN out_of_res.
	}
	
	LOCAL function refresh {
		staging_Timer["ready"](quiet_period, {
			staging_Timer["reset"]().
			stage_1s["reset"]().
			ship_state["set"]("quiet", false).
		}).
		
		IF NOT done_staging{
			check("LIQUIDFUEL").
			check("OXIDIZER").
			check("SOLIDFUEL", 10).
			check("MONOPROPELLANT").
		}
		
		LOCAL must_thrust_phase IS ship_state["get"]():HASKEY("phase") 
		AND LIST("TAKEOFF", "THRUSTING"):CONTAINS(ship_state["get"]("phase")).
		
		IF NOT must_thrust_phase {
			RETURN 2.
		}
		
		LOCAL no_acceleration TO true.
		FOR eng IN eng_list {
			IF eng:THRUST > 0 {
				SET no_acceleration TO false.
			}
		}

		//if not under accel
		IF no_acceleration {
			nacc_1s["do"]({
				no_acc_Timer["set"]().
				logJ("NO ACCELERATION DETECTED, WAITING FOR THRUST " + no_acc_period + " SECONDS...").
			}).
		}
		
		no_acc_Timer["ready"](no_acc_period, {
			//if there is still no acceleration, staging must have no engines available, stage again
			IF no_acceleration {
				nextStage("ACCELERATION").
				staging_Timer["set"]().
				logJ("Stage " + STAGE:NUMBER + " - no acceleration detected during the thrusting phase").
				nacc_1s["reset"]().
			}
		}).
		
		RETURN done_staging.
	}

	LOCAL methods TO LEXICON(
		"refresh", refresh@,
		"takeOff", takeOff@,
		"check", check@
	).
	
	RETURN methods.
}