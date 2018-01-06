@LAZYGLOBAL off.
GLOBAL env TO "live".

IF NOT(EXISTS("1:Utils")) AND ((ADDONS:AVAILABLE("RT") AND ADDONS:RT:HASKSCCONNECTION(SHIP)) OR HOMECONNECTION:ISCONNECTED) {
	COPYPATH("0:lib/Utils", "1:").
}
RUNONCEPATH("Utils").

SET STEERINGMANAGER:PITCHTS TO 6.
SET STEERINGMANAGER:ROLLTS TO 6.
SET STEERINGMANAGER:YAWTS TO 6.

function Aurora {
	CD("1:").
	LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "Displayer", "Journal", "Checkboxes","Inquiry", "Programme", "ShipState", "ShipGlobals").
	loadDeps(dependencies).
	SET THROTTLE TO 0. //safety measure for float point values of throttle when loading from a save
	CS().
	SET TERMINAL:WIDTH TO 42.
	SET TERMINAL:HEIGHT TO 30.
	IF SHIP:STATUS = "PRELAUNCH" {
		SET SHIP:NAME TO generateID().
	}
	
	GLOBAL globals TO setGlobal().
	LOCAL ship_state TO globals["ship_state"].
	LOCAL Display TO globals["Display"].
	LOCAL ship_log TO globals["ship_log"].

	// Get programme name from ship state or inquiry
	LOCAL my_programme TO Programme().
	LOCAL chosen_prog TO ship_state["get"]("programme").
	IF NOT chosen_prog {
		LOCAL pr_chooser TO LIST(
			LEXICON(
				"name", "program",
				"type", "select",
				"msg", "Choose a program",
				"choices", my_programme["list"]()
			)
		).
		SET chosen_prog TO Inquiry(pr_chooser).
		SET chosen_prog TO chosen_prog["program"].
		COPYPATH("0:program/" + chosen_prog + ".json", "1:" + chosen_prog + ".json").
		ship_state["set"]("programme", "1:" + chosen_prog + ".json").
		SET my_programme TO Programme(chosen_prog).
		CS().
	}
	// load the programme
	LOCAL trg_prog TO my_programme["fetch"](chosen_prog).
	LOCAL trg_orbit IS gettrgAlt(trg_prog["attributes"]["sats"], trg_prog["attributes"]["alt"]).

	LOCAL done IS false.
	LOCAL from_save IS true. //this value will be false, if a script runs from the launch of a ship. If ship is loaded from a save, it will be set to true inside prelaunch phase

	// Onces
	LOCAL warp_1s IS doOnce().
	LOCAL inject_init_1s IS doOnce().

	// Timers
	LOCAL conn_Timer IS Timer(). // retry connection to KSC timer
	LOCAL journal_Timer IS Timer(). // save to journal in this time
	LOCAL warp_delay IS Timer(). // save to journal in this time

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

	Display["imprint"]("Aurora Space Program V1.5.0").
	Display["imprint"](SHIP:NAME).
	Display["imprint"]("Comm range:", trg_orbit["r"] + "m.").
	Display["imprint"]("TRG ALT:", trg_orbit["alt"] + "m.").
	Display["imprint"]("TRG ORB period:", trg_orbit["period"] + "s.").
	
	IF SHIP:STATUS = "PRELAUNCH" {
		ship_state["set"]("phase", "PRELAUNCH").
		this_craft["PreLaunch"]["init"](). // waits for user input, then countdowns, then on 0 it return and the script goes forward
		ship_state["set"]("phase", "TAKEOFF").
	}
	SET done TO 0.
	SET from_save TO this_craft["PreLaunch"]["from_save"]().
	
	//--- MAIN FLIGHT BODY
	UNTIL done {
		LOCAL phase IS ship_state["get"]("phase").
		LOCAL stage_response IS this_craft["HandleStaging"]["refresh"]().
		
		Display["reset"]().
		Display["print"]("Current phase", phase).
		
		IF stage_response {
			this_craft["CheckCraftCondition"]["refresh"]().
			logJ(stage_response).
		}
			
		IF phase = "TAKEOFF" {
			ship_state["set"]("phase", "THRUSTING").
			this_craft["HandleStaging"]["takeOff"]().
			this_craft["Thrusting"]["takeOff"]().
			journal_Timer["set"]().
		} ELSE IF phase = "THRUSTING" {
			LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS ^ 2.
			Display["print"]("THR", THROTTLE * 100 + "%").
			Display["print"]("PITCH:", this_craft["Thrusting"]["ship_p"]()).
			Display["print"]("T.PITCH:", this_craft["Thrusting"]["trg_pitch"]()).
			Display["print"]("kPa:", ROUND(globals["q_pressure"](), 3)). 
			Display["print"]("TWR:", ROUND(getTWR(), 3)).
			Display["print"]("Current v:", SHIP:VELOCITY:SURFACE:MAG).
			Display["print"]("ACC:", ROUND(globals["acc_vec"]():MAG / g_base, 3) + "G").
			
			this_craft["Thrusting"]["handleFlight"]().
			IF (ROUND(APOAPSIS) > trg_orbit["alt"] - 200000) AND ALTITUDE > 50000 {
				this_craft["Thrusting"]["decelerate"]().
			}
			IF CEILING(APOAPSIS) >= trg_orbit["alt"] AND ALTITUDE > 50000 {
				ship_state["set"]("phase", "COASTING").
				SET THROTTLE TO 0.
				HUDTEXT("COAST TRANSITION", 4, 2, 42, green, false).
				//leaving thrusting section at that time
				ship_log["add"]("COAST TRANSITION phase").
				Display["clear"]().
				this_craft["Injection"]["burn_time"]().
			}
			
			IF ALTITUDE > 70000 AND globals["q_pressure"]() < 1 {
				this_craft["Deployables"]["fairing"]().
				RCS ON.
			} //eject fairing
			IF ALTITUDE > 71000 {
				//--vacuum, deploy panels and antennas, turn on lights
				this_craft["Deployables"]["panels"]().
			}
		} ELSE IF phase = "COASTING" {
			SET WARPMODE TO "RAILS".
			LOCAL safe_t TO 120.
			warp_1s["do"]({
				Display["clear"]().
				HUDTEXT("WARPING IN 2 SECONDS", 2, 2, 42, green, false).
				warp_delay["set"]().
				Display["print"]("BURN T: ", this_craft["Injection"]["burn_time"]()).
			}).
			IF ETA:APOAPSIS < (this_craft["Injection"]["burn_time"]() + safe_t) AND ETA:APOAPSIS > 0 {
				ship_state["set"]("phase", "KERBINJECTION").
				ship_log["add"]("KERBINJECTION phase").
				KUNIVERSE:TIMEWARP:CANCELWARP().
			}
			warp_delay["ready"](2, {
				WARPTO(TIME:SECONDS + ETA:APOAPSIS - (this_craft["Injection"]["burn_time"]() + safe_t)).
			}).
		} ELSE IF phase = "KERBINJECTION" {
			inject_init_1s["do"]({
				Display["clear"]().
				LOCAL init TO this_craft["Injection"]["init"]().
				logJ(init). // initialize and get the response
			}).
			Display["print"]("THROTTLE: ", this_craft["Injection"]["throttle"]()).
			Display["print"]("Est. dV: ", this_craft["Injection"]["dV_change"]()).
			Display["print"]("BURN T: ", this_craft["Injection"]["burn_time"]()).
			IF this_craft["Injection"]["burn"]() {
				ship_state["set"]("phase", "CORRECTION_BURN").
				ship_log["add"]("Injection complete").
				ship_log["save"]().
				Display["clear"]().
			}
		} ELSE IF phase = "CORRECTION_BURN" {
			IF SHIP:ORBIT:PERIOD >= trg_orbit["period"] {
				this_craft["CorrectionBurn"]["neutralize"]().
				ship_state["set"]("phase", "ORBITING").
				HUDTEXT("CIRCURALISATION COMPLETE", 3, 2, 42, RGB(10,225,10), false).
				ship_log["add"]("CIRCURALISATION COMPLETE").
				UNLOCK THROTTLE.
				UNLOCK STEERING.
				this_craft["Deployables"]["antennas"]().
				conn_Timer["set"]().
			} ELSE {
				LOCAL margin IS  SHIP:ORBIT:PERIOD / trg_orbit["period"].
				IF NOT this_craft["CorrectionBurn"]["fore"](margin) {
					HUDTEXT("ONLY 10% OF MONOPROP LEFT!", 3, 2, 42, RED, false).
				}
				Display["print"]("ORB. PERIOD:", SHIP:ORBIT:PERIOD).
				Display["print"]("TRG ORB. PERIOD: ", trg_orbit["period"]).
			}
		} ELSE IF phase = "ORBITING" {
			Display["print"]("ORB. PERIOD:", SHIP:ORBIT:PERIOD).
		}
		conn_Timer["ready"](10, {
			IF NOT ship_log["save"]() {
				conn_Timer["set"]().
			} ELSE {
				my_programme["add"]().
			}
		}).
		journal_Timer["ready"](10, {
			ship_log["add"](phase + " phase").
			journal_Timer["reset"]().
		}).
		WAIT 0.
	}
}
Aurora().
