@LAZYGLOBAL off.
GLOBAL env TO "live".

IF NOT(EXISTS("1:Utils")) AND ((ADDONS:AVAILABLE("RT") AND ADDONS:RT:HASKSCCONNECTION(SHIP)) OR HOMECONNECTION:ISCONNECTED) {
	COPYPATH("0:lib/Utils", "1:").
}
RUNONCEPATH("Utils").

SET STEERINGMANAGER:PITCHTS TO 8.
SET STEERINGMANAGER:ROLLTS TO 5.
SET STEERINGMANAGER:YAWTS TO 8.
SET STEERINGMANAGER:PITCHPID:KD TO 0.75.
SET STEERINGMANAGER:YAWPID:KD TO 0.75.
SET STEERINGMANAGER:ROLLPID:KD TO 0.75.
SET STEERINGMANAGER:MAXSTOPPINGTIME TO 8.

function Aurora {
	CD("1:").
	LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "Displayer", "Journal", "Checkboxes","Inquiry", "Program", "ShipState", "ShipGlobals").
	loadDeps(dependencies).
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	SET THROTTLE TO 0. //safety measure for float point values of throttle when loading from a save
	CS().
	SET TERMINAL:WIDTH TO 42.
	SET TERMINAL:HEIGHT TO 34.
	IF SHIP:STATUS = "PRELAUNCH" {
		SET SHIP:NAME TO generateID().
	}
	
	IF NOT(DEFINED globals) GLOBAL globals TO setGlobal().
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
		SET chosen_prog TO Inquiry(pr_chooser).
		SET chosen_prog TO chosen_prog["program"].
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
	LOCAL phase_angle IS LEXICON("current", 0).

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

	IF SHIP:STATUS = "PRELAUNCH" {
		trg_prog["vessels"]:ADD("none").
		LOCAL usr_input TO Inquiry(LIST(
			LEXICON(
				"name", "target",
				"type", "select",
				"msg", "Choose a target vessel",
				"choices", trg_prog["vessels"]
			)
		)).
		CS().
		ship_state["set"]("trg_vsl", usr_input["target"]).
		IF ship_state["get"]("trg_vsl") = "none" {
			ship_state["set"]("trg_vsl", false).
		}
		Display["imprint"]("Aurora Space Program V1.6.3").
		Display["imprint"](SHIP:NAME).
		IF ship_state["get"]("trg_vsl") {
			Display["imprint"]("TRG_VSL", ship_state["get"]("trg_vsl")).
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
	
	//--- MAIN FLIGHT BODY
	UNTIL done {
		LOCAL phase IS ship_state["get"]("phase").
		LOCAL stage_response IS trg_prog["attributes"]["modules"]["HandleStaging"].
		IF stage_response {
			SET stage_response TO this_craft["HandleStaging"]["refresh"]().
		}
		Display["reset"]().
		Display["print"]("PHASE", phase).
		
		IF stage_response {
			IF trg_prog["attributes"]["modules"]["CheckCraftCondition"] {
				this_craft["CheckCraftCondition"]["refresh"]().
			}
			logJ(stage_response).
		}
		IF phase = "WAITING" {
			IF NOT trg_prog["attributes"]["modules"]["PreLaunch"] {
				ship_state["set"]("phase", "TAKEOFF").
			} ELSE {
				LOCAL phase_angle TO "".
				LOCAL has_target TO false.
				IF ship_state["get"]("trg_vsl") {
					SET phase_angle TO getPhaseAngle(trg_prog["attributes"]["sats"], VESSEL(ship_state["get"]("trg_vsl")), phase_angle["current"]).	
					Display["print"]("Degrees spread:", phase_angle["spread"]).
					Display["print"]("Degrees traveled:", phase_angle["traveled"]).
					Display["print"]("Target separation:", phase_angle["separation"]).
					Display["print"]("Est. angle move:", phase_angle["move"]).
					Display["print"]("Target phase angle:", phase_angle["target"]).
					Display["print"]("Current phase angle:", phase_angle["current"]).
					SET has_target TO true.
				}
				IF has_target AND phase_angle["current"] + 0.5 * (KUNIVERSE:TIMEWARP:WARP + 1) >= phase_angle["target"] 
					AND phase_angle["current"] - (KUNIVERSE:TIMEWARP:WARP + 1) <= phase_angle["target"] {
					misc_1s["do"]({
						KUNIVERSE:TIMEWARP:CANCELWARP().
					}).
				} ELSE IF has_target {
					misc_1s["reset"]().
				}
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
				journal_Timer["set"]().
			}
		} ELSE IF phase = "THRUSTING" {
			IF NOT trg_prog["attributes"]["modules"]["Thrusting"] {
				ship_state["set"]("phase", "COASTING").
			} ELSE {
				LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS ^ 2.
				Display["print"]("THROTT:", ROUND(THROTTLE * 100, 1) + "%").
				Display["print"]("TRG THROTT:", this_craft["Thrusting"]["target4throttle"]()).
				Display["print"]("PITCH:", this_craft["Thrusting"]["ship_p"]()).
				Display["print"]("kPa:", ROUND(globals["q_pressure"](), 3)). 
				Display["print"]("TWR:", ROUND(getTWR(), 3)).
				Display["print"]("SFC V:", SHIP:VELOCITY:SURFACE:MAG).
				Display["print"]("ACC:", ROUND(globals["acc_vec"]():MAG / g_base, 3) + "G").
					
				this_craft["Thrusting"]["handleFlight"]().
				IF (ROUND(APOAPSIS) > trg_orbit["alt"] - 200000) AND ALTITUDE > 50000 {
					this_craft["Thrusting"]["decelerate"]().
				}
				IF CEILING(APOAPSIS) >= trg_orbit["alt"] AND ALTITUDE > 50000 {
					ship_state["set"]("phase", "COASTING").
					SET THROTTLE TO 0.
					// HUDTEXT("COAST TRANSITION", 4, 2, 20, green, false).
					//leaving thrusting section at that time
					ship_log["add"]("COAST TRANSITION phase").
					Display["clear"]().
					this_craft["Injection"]["burn_time"]().
				}
				IF ALTITUDE > 65000 AND globals["q_pressure"]() < 0.3 {
					quiet1_1s["do"]({
						this_craft["Deployables"]["fairing"]().
					}).
				} //eject fairing
				IF ALTITUDE > 71000 {
					quiet3_1s["do"]({
						// RCS ON.
						this_craft["Deployables"]["panels"]().
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
						RCS ON.
					}
					warp_delay["ready"](2, {
						WARPTO(TIME:SECONDS + ETA:APOAPSIS - (this_craft["Injection"]["burn_time"]() + safe_t)).
					}).
				}
			}
		} ELSE IF phase = "INJECTION" {
		IF NOT trg_prog["attributes"]["modules"]["Injection"] {
				ship_state["set"]("phase", "ORBITING").
			} ELSE {
				inject_init_1s["do"]({
					Display["clear"]().
					LOCAL init TO this_craft["Injection"]["init"]().
					logJ(init). // initialize and get the response
				}).
				Display["print"]("THROTT: ", this_craft["Injection"]["throttle"]()).
				Display["print"]("Est. dV: ", this_craft["Injection"]["dV_change"]()).
				Display["print"]("BURN T: ", this_craft["Injection"]["burn_time"]()).
				Display["print"]("ORB P:", SHIP:ORBIT:PERIOD).
				IF this_craft["Injection"]["burn"]() {
					ship_state["set"]("phase", "CORRECTION_BURN").
					ship_log["add"]("Injection complete").
					ship_log["save"]().
					Display["clear"]().
				}
			}
		} ELSE IF phase = "CORRECTION_BURN" {
			IF SHIP:ORBIT:PERIOD < trg_orbit["period"] + 0.01 AND SHIP:ORBIT:PERIOD > trg_orbit["period"] - 0.01 {
				this_craft["CorrectionBurn"]["neutralize"]().
				ship_state["set"]("phase", "ORBITING").
				ship_log["add"]("CIRCURALISATION COMPLETE").
				UNLOCK THROTTLE.
				UNLOCK STEERING.
				this_craft["Deployables"]["antennas"]().
				conn_Timer["set"]().
				Display["clear"]().
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
		} ELSE IF phase = "ORBITING" {
			Display["print"]("ORB P:", SHIP:ORBIT:PERIOD).
		}
		IF NOT ship_state["get"]("saved") {
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
