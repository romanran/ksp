@LAZYGLOBAL off.
DECLARE GLOBAL env TO "live".
COPYPATH("0:lib/Utils", "1:").
RUNONCEPATH("UTILS").

function Aurora {
	CD("1:").
	LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "Displayer", "Journal", "Inquiry", "Programme", "ShipState").
	IF (ADDONS:AVAILABLE("RT") AND ADDONS:RT:HASKSCCONNECTION(SHIP)) OR HOMECONNECTION:ISCONNECTED {
		loadDeps(dependencies).
	}

	SET THROTTLE TO 0. //safety measure for float point values of throttle when loading from a save

	CS().
	SET TERMINAL:WIDTH TO 42.
	SET TERMINAL:HEIGHT TO 30.
	GLOBAL Display TO Displayer().

	SET SHIP:NAME TO generateID().
	GLOBAL ship_log TO Journal().
	function logJ {
		PARAMETER str.
		if (DEFINED ship_log AND ship_log:HASKEY("add")) {
			ship_log["add"](str).
		}
	}
	
	GLOBAL ship_state IS ShipState().
	LOCAL programme TO Programme().
	LOCAL prlist TO programme["list"]().
	LOCAL chosen_prog TO "".
	IF ship_state["state"]:HASKEY("programme") {
		SET chosen_prog TO ship_state["state"]["programme"].
	} ELSE {
		LOCAL pr_chooser TO LIST(
			LEXICON(
				"name", "program",
				"type", "select", 
				"msg", "Choose a program",
				"choices", prlist
			)
		).
		SET chosen_prog TO Inquiry(pr_chooser).
		SET chosen_prog TO chosen_prog["program"].
		ship_state["set"]("programme", chosen_prog).
	}
	
	GLOBAL trgt_prog TO programme["fetch"](chosen_prog).
	GLOBAL trgt_orbit IS getTrgtAlt(trgt_prog["attributes"]["sats"], trgt_prog["attributes"]["alt"]).
	
	GLOBAL done IS false.
	GLOBAL done_staging IS true. //we dont need to stage when on launchpad or if loaded from a save to already staged rocket
	GLOBAL from_save IS true. //this value will be false, if a script runs from the launch of a ship. If ship is loaded from a save, it will be set to true.

	// Onces
	LOCAL warp_1s IS doOnce().
	LOCAL takeoff_1s TO doOnce().

	// Timers
	LOCAL conn_Timer IS Timer(). // retry connection to KSC timer
	LOCAL journal_Timer IS Timer(). // save to journal in this time

	// Global/ Aurora scopre variables
	LOCAL stg IS LEXICON(). // stage resouces, taken from doStage
	GLOBAL LOCK stg_res TO getStageResources().
	LOCAL LOCK q_pressure TO ROUND(SHIP:Q * CONSTANT:ATMtokPa, 3).
	
	// Load the modules after all of the global variables are set
	LOCAL phase_modules IS LIST("PreLaunch", "HandleStaging", "Thrusting", "Deployables", "Injection", "CorrectionBurn", "CheckCraftCondition").
	loadDeps(phase_modules, "modules").
	
	LOCAL thisCraft IS LEXICON("PreLaunch", P_PreLaunch(), "HandleStaging", P_HandleStaging(), "Thrusting", P_Thrusting(), "Deployables", P_Deployables(), "Injection", P_Injection(), "CorrectionBurn", P_CorrectionBurn(), "CheckCraftCondition", P_CheckCraftCondition()).
	
	IF SHIP:STATUS = "PRELAUNCH" {
		thisCraft["PreLaunch"]["init"]().
	}

	//--- MAIN FLIGHT BODY
	UNTIL done {
		Display["reset"]().
		Display["print"]("Current phase", ship_state["state"]["phase"]).
		
		thisCraft["HandleStaging"]["refresh"]().
		
		IF ship_state["state"]["phase"] = "TAKEOFF" {
			thisCraft["Thrusting"]["takeOff"]().
		}
		IF ship_state["state"]["phase"] = "THRUSTING" {
			thisCraft["Thrusting"]["handleFlight"]().
			IF (ROUND(APOAPSIS) > trgt_orbit["alt"] - 200000) AND ALTITUDE > 50000 {
				thisCraft["Thrusting"]["decelerate"]().
			}
			IF CEILING(APOAPSIS) >= trgt_orbit["alt"] AND ALTITUDE > 70000 {
				LOCK THROTTLE TO 0.
				HUDTEXT("COAST TRANSITION", 4, 2, 42, green, false).
				
				//leaving thrusting section at that time
				ship_state["set"]("phase", "COASTING").
				ship_log["add"]("Transition to the coasting phase").
			}
		}//--thrusting
		
		IF ALTITUDE > 30000 AND q_pressure < 2 {
			thisCraft["Deployables"]["fairing"]().
		} //eject fairing	
		IF ALTITUDE > 80000 AND from_save = false {
			//--vacuum, deploy panels and antennas, turn on lights
			thisCraft["Deployables"]["antennas"](). 
			thisCraft["Deployables"]["panels"](). 
		}
		
		IF ship_state["state"]["phase"] = "COASTING" {
			IF NOT deploy_1s["ready"]() {
				warp_1s["do"]({
					HUDTEXT("WARPING", 2, 2, 42, green, false).
					SET WARPMODE TO "RAILS".
					WARPTO (TIME:SECONDS + ETA:APOAPSIS - 60).
				}).
			}
			IF ETA:APOAPSIS < 60 AND ETA:APOAPSIS <> 0{
				KUNIVERSE:TIMEWARP:CANCELWARP().
				ship_state["set"]("phase", "KERBINJECTION").
			}
		} //--coasting
		
		thisCraft["CheckCraftCondition"]["refresh"]().
			
		IF ship_state["state"]["phase"] = "KERBINJECTION" {
			thisCraft["Injection"]["init"]().
			IF thisCraft["Injection"]["burn"]() {
				ship_log["add"]("CIRCURALISATION PHASE I COMPLETE").
				ship_log["save"]().
				ship_state["set"]("phase", "CORRECTION_BURN").
			}
			Display["print"]("Est. dV: ", dV_change).
			Display["print"]("BURN T: ", burn_time).
			Display["print"]("THROTTLE: ", thrott).
			Display["print"]("ORB. PERIOD:", ROUND(SHIP:ORBIT:PERIOD, 3)).
			Display["print"]("TRGT ORB. PERIOD: ", trgt["period"]).
		} //target orbit injection
		
		IF ship_state["state"]["phase"] = "CORRECTION_BURN" {
			IF ROUND(SHIP:ORBIT:PERIOD, 3) = trgt_orbit["period"] {
				IF thisCraft["CorrectionBurn"]["neutrilize"]() {
					HUDTEXT("CIRCURALISATION COMPLETE", 3, 2, 42, RGB(10,225,10), false).
					ship_log["add"]("CIRCURALISATION COMPLETE").
					ship_log["save"]().
					ship_state["set"]("phase", "ORBITING").
				}
			} ELSE {
				LOCAL margin IS -(ROUND(SHIP:ORBIT:PERIOD, 3) / trgt_orbit["period"] - 1).
				IF NOT thisCraft["CorrectionBurn"]["fore"](margin) {
					HUDTEXT("CNLY 10% OF MONOPROP LEFT!", 3, 2, 42, RED, false).
				}
				Display["print"]("ORB. PERIOD:", ROUND(SHIP:ORBIT:PERIOD, 3)).
				Display["print"]("TRGT ORB. PERIOD: ", trgt_orbit["period"]).
			}
		}
		IF ship_state["state"]["phase"] = "ORBITING" {
			UNLOCK THROTTLE.
			UNLOCK STEERING.
			conn_Timer["set"]().
		}
		conn_Timer["ready"](10, {
			IF NOT ship_log["save"]() {
				conn_Timer["set"]().
			}
		}).
		journal_Timer["ready"](10, {
			ship_log["add"](ship_state["state"]["phase"] + " phase").
			journal_Timer["reset"]().
		}).
		WAIT 0.
	}
}
Aurora().