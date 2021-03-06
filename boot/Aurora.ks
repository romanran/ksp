@LAZYGLOBAL off.
GLOBAL env TO "live".

IF NOT EXISTS("1:Utils") AND HOMECONNECTION:ISCONNECTED {
	COPYPATH("0:lib/Utils", "1:").
}
RUNONCEPATH("Utils").

function Aurora {
	CD("1:").
	LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "Displayer", "Journal", "Checkboxes","Inquiry", "Program", "ShipState", "ShipGlobals").
	loadDeps(dependencies).
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	LOCK THROTTLE TO 0. //safety measure for float point values of throttle when loading from a save
	CS().
	SET TERMINAL:WIDTH TO 42.
	SET TERMINAL:HEIGHT TO 34.
	IF SHIP:STATUS = "PRELAUNCH" {
		SET SHIP:NAME TO generateID().
	}
	
	GLOBAL globals TO setGlobal().
	LOCAL ship_state TO globals["ship_state"].
	LOCAL Display TO globals["Display"].
	LOCAL ship_log TO globals["ship_log"].

	// Get program name from ship state or inquiry
	LOCAL chosen_prog TO ship_state["get"]("program").
	IF NOT chosen_prog {
		LOCAL pr_chooser TO LIST(
			LEXICON(
				"name", "program",
				"type", "select",
				"msg", "Choose a program",
				"choices", Program()["list"]()
			)
		).
		SET chosen_prog TO Inquiry(pr_chooser)["program"].
		COPYPATH("0:program/" + chosen_prog + ".json", "1:" + chosen_prog + ".json").
		ship_state["set"]("program", "1:" + chosen_prog + ".json").
		CS().
	}
	LOCAL my_program TO Program(ship_state["get"]("program")).
	// load the program
	LOCAL trg_prog TO my_program["fetch"]().
	LOCAL trg_orbit IS gettrgAlt(trg_prog["attributes"]["sats"], trg_prog["attributes"]["alt"]).

	LOCAL done IS false.
	LOCAL from_save IS true. //this value will be false, if a script runs from the launch of a ship. If ship is loaded from a save, it will be set to true inside prelaunch phase

	// Onces
	LOCAL warp_1s IS doOnce().
	LOCAL inject_init_1s IS doOnce().
	LOCAL quiet1_1s IS doOnce().
	LOCAL misc_1s IS doOnce().
	LOCAL quiet3_1s IS doOnce().

	// Timers
	LOCAL conn_Timer IS Timer(). // retry connection to KSC timer
	LOCAL journal_Timer IS Timer(). // save to journal in this time
	LOCAL warp_delay IS Timer(). // save to journal in this time
	LOCAL stage_delay IS Timer(). // satellite release delay for throttle cutoff
	//LOCAL phase_angle IS LEXICON("current", 0).

	// Load the modules after all of the global variables are set
	LOCAL phase_modules IS LIST(
		"PreLaunch",
		"HandleStaging",
		"Thrusting",
		"Deployables",
		"Injection",
		"CorrectionBurn",
		"CheckCraftCondition"
	).
	
	loadDeps(phase_modules, "modules").

	GLOBAL this_craft IS LEXICON(
		"PreLaunch", P_PreLaunch(),
		"HandleStaging", P_HandleStaging(),
		"Thrusting", P_Thrusting(trg_orbit),
		"Deployables", P_Deployables(),
		"Injection", P_Injection(trg_orbit),
		"CorrectionBurn", P_CorrectionBurn(),
		"CheckCraftCondition", P_CheckCraftCondition()
	).
	
	function askForTarget {
		trg_prog["vessels"]:ADD("none").
		SET TARGET TO SUN.
		LOCAL usr_input TO Inquiry(LIST(
			LEXICON(
				"name", "target",
				"type", "select",
				"msg", "Choose a target vessel or target manually",
				"choices", trg_prog["vessels"]
			)
		)).
		CS().
		ship_state["set"]("trg_vsl", usr_input["target"]).
	}

	IF SHIP:STATUS = "PRELAUNCH" {
		askForTarget().
		
		IF ship_state["get"]("trg_vsl") = "none" AND TARGET:NAME = "SUN" {
			ship_state["set"]("trg_vsl", false).
		} ELSE IF ship_state["get"]("trg_vsl") = "none" AND NOT (TARGET:NAME = "SUN") {
			ship_state["set"]("trg_vsl", TARGET:NAME).
		} ELSE {
			SET TARGET TO ship_state["get"]("trg_vsl").
		}
		Display["imprint"]("Aurora Space Program V2.0.0").
		Display["imprint"](SHIP:NAME).
		IF ship_state["get"]("trg_vsl") {
			Display["imprint"]("TRG Vessel", ship_state["get"]("trg_vsl")).
		}
		Display["imprint"]("Comm range:", trg_orbit["range"] + "m.").
		Display["imprint"]("TRG ALT:", trg_orbit["alt"] + "m.").
		Display["imprint"]("TRG ORB P:", trg_orbit["period"] + "s.").
		
		ship_state["set"]("phase", "PRELAUNCH").
		this_craft["PreLaunch"]["init"]().
		ship_state["set"]("phase", "WAITING").
		ship_state["set"]("saved", false).
	}
	SET done TO 0.
	SET from_save TO this_craft["PreLaunch"]["from_save"]().
	
	LOCAL phase_angle TO LEXICON("current", 0).
	LOCAL exec_time TO 200. // default exec time at about 200seconds
	IF trg_prog:HASKEY("exec_time") {
		SET exec_time TO trg_prog["exec_time"].
	}
	
	//--- MAIN FLIGHT BODY
	UNTIL done {
		LOCAL phase IS ship_state["get"]("phase").
		LOCAL done_staging IS false.
		IF trg_prog["attributes"]["modules"]["HandleStaging"] {
			SET done_staging TO this_craft["HandleStaging"]["refresh"]().
		}
		Display["reset"]().
		Display["print"]("PHASE", phase).
		
		IF done_staging {
			IF trg_prog["attributes"]["modules"]["CheckCraftCondition"] {
				this_craft["CheckCraftCondition"]["refresh"]().
			}
			logJ(done_staging).
		}
		IF phase = "WAITING" {
			IF NOT trg_prog["attributes"]["modules"]["PreLaunch"] {
				ship_state["set"]("phase", "TAKEOFF").
			} ELSE {
				
				LOCAL has_target TO false.
				IF ship_state["get"]("trg_vsl") {
					SET phase_angle TO getPhaseAngle(trg_prog["attributes"]["sats"], VESSEL(ship_state["get"]("trg_vsl")), phase_angle["current"], exec_time).	
					Display["print"]("Spread:", phase_angle["spread"] + "°").
					Display["print"]("Target travel:", phase_angle["traveled"] + "°").
					Display["print"]("Est. angle move:", phase_angle["move"] + "°").
					Display["print"]("Current phase angle:", phase_angle["current"] + "°").
					SET has_target TO true.
				}
				// IF has_target AND phase_angle["current"] * KUNIVERSE:TIMEWARP:WARP >= phase_angle["target"] 
					// AND phase_angle["current"] - KUNIVERSE:TIMEWARP:WARP <= phase_angle["target"] {
					// misc_1s["do"]({
						// KUNIVERSE:TIMEWARP:CANCELWARP().
					// }).
				// } ELSE IF has_target {
					// misc_1s["reset"]().
				// }
				Display["print"]("Press ENTER to launch").
				Display["print"]("Press ESC to abort").
				IF this_craft["PreLaunch"]["refresh"]() {
					ship_state["set"]("phase", "TAKEOFF").
					misc_1s["reset"]().
					Display["clear"]().
				}
			}
		}
		IF phase = "TAKEOFF" {
			IF NOT trg_prog["attributes"]["modules"]["TakeOff"] {
				IF trg_prog["attributes"]["modules"]["Thrusting"] {
					this_craft["Thrusting"]["takeOff"]().
					ship_state["set"]("phase", "THRUSTING").
				} ELSE {
					ship_state["set"]("phase", "COASTING").
				}
			} ELSE {
				ship_state["set"]("phase", "THRUSTING").
				this_craft["HandleStaging"]["takeOff"]().
				this_craft["Thrusting"]["takeOff"]().
				journal_Timer["set"]().
			}
		} ELSE IF phase = "THRUSTING" {
			IF NOT trg_prog["attributes"]["modules"]["Thrusting"] {
				ship_state["set"]("phase", "COASTING").
			} ELSE {
				LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS ^ 2.
				Display["print"]("THROTT:", ROUND(this_craft["Thrusting"]["thrott"]() * 100, 1) + "%").
				Display["print"]("kPa:", ROUND(globals["q_pressure"](), 3)). 
				Display["print"]("TWR:", ROUND(getTWR() * THROTTLE, 3)).
				Display["print"]("TRG PITCH:", this_craft["Thrusting"]["trg_pitch"]()).
				Display["print"]("PITCH:", this_craft["Thrusting"]["ship_p"]()).
				Display["print"]("SFC V:", SHIP:VELOCITY:SURFACE:MAG).
				Display["print"]("ACC:", ROUND(globals["acc_vec"]():MAG / g_base, 3) + "G").
					
				this_craft["Thrusting"]["handleFlight"]().
				IF (ROUND(APOAPSIS) > trg_orbit["alt"] - trg_orbit["alt"] * 0.25) AND ALTITUDE > 30000 {
					this_craft["Thrusting"]["decelerate"]().
				}
				
				LOCAL atm_clamp IS SHIP:SENSORS:PRES * trg_orbit["alt"] * 0.05.
				IF CEILING(APOAPSIS) - atm_clamp >= trg_orbit["alt"] {
					LOCK THROTTLE TO 0.
					// HUDTEXT("COAST TRANSITION", 4, 2, 20, green, false).
				}
				IF ALTITUDE > 73000 AND THROTTLE = 0 {
					ship_log["add"]("COAST TRANSITION phase").
					Display["clear"]().
					this_craft["Injection"]["burn_time"]().
					ship_state["set"]("phase", "COASTING").
				}
				IF ALTITUDE > 55000 AND globals["q_pressure"]() < 0.3 {
					quiet1_1s["do"]({
						this_craft["Deployables"]["fairing"]().
					}).
				} //eject fairing
				IF ALTITUDE > 71000 {
					quiet3_1s["do"]({
						// RCS ON.
						this_craft["Deployables"]["panels"]().
						RCS ON.
					}).
				}
			}
		} ELSE IF phase = "COASTING" {
			IF NOT trg_prog["attributes"]["modules"]["Coasting"] {
				ship_state["set"]("phase", "INJECTION").
			} ELSE {
				IF ALTITUDE > 71000 {
					SET WARPMODE TO "RAILS".
					LOCAL safe_t TO 60.
					warp_1s["do"]({
						Display["clear"]().
						// HUDTEXT("WARPING IN 2 SECONDS", 2, 2, 20, green, false).
						warp_delay["set"]().
						Display["print"]("BURN T: ", this_craft["Injection"]["burn_time"]()).
					}).
					IF ETA:APOAPSIS < (this_craft["Injection"]["burn_time"]() + safe_t) AND ETA:APOAPSIS > 0 {
						ship_state["set"]("phase", "INJECTION").
						ship_log["add"]("INJECTION phase").
						KUNIVERSE:TIMEWARP:CANCELWARP().
					}
					warp_delay["ready"](2, {
						WARPTO(TIME:SECONDS + ETA:APOAPSIS - (this_craft["Injection"]["burn_time"]() + safe_t)).
					}).
				}
			}
		} ELSE IF phase = "INJECTION" {
			IF NOT trg_prog["attributes"]["modules"]["Injection"] {
				ship_state["set"]("phase", "END").
			} ELSE {
				inject_init_1s["do"]({
					Display["clear"]().
					LOCAL init TO this_craft["Injection"]["init"]().
					logJ(init). // initialize and get the response
				}).
				Display["print"]("THROTT: ", this_craft["Injection"]["throttle"]()).
				Display["print"]("Est. dV: ", this_craft["Injection"]["dV_change"]()).
				Display["print"]("stg dV: ", getdV()).
				Display["print"]("BURN T: ", this_craft["Injection"]["burn_time"]()).
				
				Display["print"]("T-: ", this_craft["Injection"]["t_minus"]()).
				Display["print"]("ORB P:", SHIP:ORBIT:PERIOD).
				IF this_craft["Injection"]["burn"]() {
					misc_1s["do"]({
						IF this_craft["CorrectionBurn"]["checkStage"]() AND trg_prog["attributes"]["release"]  {
							SET THROTTLE TO 0.
							stage_delay["set"]().
						} ELSE {
							ship_state["set"]("phase", "CORRECTION_BURN").
							ship_log["add"]("Injection complete").
							ship_log["save"]().
							Display["clear"]().
						}
					}).
					stage_delay["ready"](2, {
						this_craft["HandleStaging"]["stage"]("RELEASE").
						ship_state["set"]("phase", "CORRECTION_BURN").
						ship_log["add"]("Injection complete").
						ship_log["save"]().
						Display["clear"]().
					}).
				}
			}
		} ELSE IF phase = "CORRECTION_BURN" {
			IF NOT trg_prog["attributes"]["modules"]["CorrectionBurn"] {
				ship_state["set"]("phase", "END").
			} ELSE {
				IF SHIP:ORBIT:PERIOD < trg_orbit["period"] + 0.01 AND SHIP:ORBIT:PERIOD > trg_orbit["period"] - 0.01 {
					this_craft["CorrectionBurn"]["neutralize"]().
					ship_log["add"]("CIRCURALISATION COMPLETE").
					misc_1s["reset"]().
					ship_state["set"]("phase", "END").
				} ELSE {
					LOCAL tail IS trg_orbit["period"] - 20.
					LOCAL margin IS 1 - ((SHIP:ORBIT:PERIOD - tail) / (trg_orbit["period"] - tail)) ^ 12.
					IF SHIP:ORBIT:PERIOD < trg_orbit["period"] - 30 {
						SET margin TO 1.
					}
					Display["print"]("FORE:", margin).
					this_craft["CorrectionBurn"]["fore"](margin).
					Display["print"]("ORB P:", SHIP:ORBIT:PERIOD).
					Display["print"]("TRG ORB P: ", trg_orbit["period"]).
				}
			}
		} ELSE IF phase = "END" {
			UNLOCK THROTTLE.
			UNLOCK STEERING.
			SET THROTTLE TO 0.
			Display["print"]("ORB P:", SHIP:ORBIT:PERIOD).
			misc_1s["do"]({
				Display["clear"]().
				conn_Timer["set"]().
				this_craft["Deployables"]["antennas"]().
			}).
			my_program["append"]("exec_time", MISSIONTIME).
		}
		IF NOT ship_state["get"]("saved") AND trg_prog["attributes"]["Journal"] {
			conn_Timer["ready"](10, {
				IF NOT ship_log["save"]() {
					conn_Timer["set"]().
				} ELSE {
					my_program["add"]().
					ship_state["set"]("saved", true).
				}
			}).
			journal_Timer["ready"](3, {
				ship_log["add"]().
				journal_Timer["set"]().
				ship_log["save"]().
			}).
		}
		WAIT 0.
	}
}
Aurora().
