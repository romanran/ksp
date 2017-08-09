@LAZYGLOBAL off.
GLOBAL env TO "live".

IF NOT(EXISTS("1:Utils")) AND ((ADDONS:AVAILABLE("RT") AND ADDONS:RT:HASKSCCONNECTION(SHIP)) OR HOMECONNECTION:ISCONNECTED) {
	COPYPATH("0:lib/Utils", "1:").
}
RUNONCEPATH("Utils").

function Tester {
	CD("1:").
	LOCAL dependencies IS LIST("PID", "Timer", "DoOnce", "Functions", "Displayer", "Journal", "Inquiry", "Programme", "ShipState", "ShipGlobals").
	loadDeps(dependencies).
	GLOBAL globals TO setGlobal().
	LOCAL ship_state TO globals["ship_state"].
	LOCAL Display TO globals["Display"].
	LOCAL ship_log TO globals["ship_log"].

	SET THROTTLE TO 0. //safety measure for float point values of throttle when loading from a save

	CS().
	//SET TERMINAL:WIDTH TO 42.
	//SET TERMINAL:HEIGHT TO 30.

	SET SHIP:NAME TO generateID().

	// Get programme name from ship state or inquiry
	LOCAL my_programme TO Programme().
	LOCAL prlist TO my_programme["list"]().
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
		SET chosen_prog TO Inquiry(pr_chooser)["program"].
		ship_state["set"]("programme", chosen_prog).
	}
	// load the programme
	LOCAL trgt_prog TO my_programme["fetch"](chosen_prog).
	LOCAL trgt_orbit IS getTrgtAlt(trgt_prog["attributes"]["sats"], trgt_prog["attributes"]["alt"]).

	LOCAL done IS false.
	LOCAL from_save IS true. //this value will be false, if a script runs from the launch of a ship. If ship is loaded from a save, it will be set to true inside prelaunch phase

	// Onces
	LOCAL warp_1s IS doOnce().

	// Timers
	LOCAL conn_Timer IS Timer(). // retry connection to KSC timer
	LOCAL journal_Timer IS Timer(). // save to journal in this time

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
		"Thrusting", P_Thrusting(trgt_orbit),
		"Deployables", P_Deployables(),
		"Injection", P_Injection(trgt_orbit),
		"CorrectionBurn", P_CorrectionBurn(),
		"CheckCraftCondition", P_CheckCraftCondition()
	).


	IF SHIP:STATUS = "PRELAUNCH" {
		Display["imprint"]("Aurora Space Program V1.4.0").
		Display["imprint"](SHIP:NAME).
		//this_craft["PreLaunch"]["init"](). // waits for user input, then countdowns, then on 0 it return and the script goes forward
		//ship_state["set"]("phase", "TAKEOFF").
	}
	SET from_save TO this_craft["PreLaunch"]["from_save"].
	
	function showPage {
		PARAMETER page.
		LOCAL choices TO this_craft[page]:KEYS.
		choices:ADD("Go Back").
		LOCAL a_chooser TO LIST(
			LEXICON(
				"name", "action",
				"type", "select",
				"msg", "Choose an action",
				"choices", choices
			)
		).
		LOCAL action_name TO Inquiry(a_chooser)["action"].
		IF NOT(action_name = "Go Back") {
			IF this_craft[page][action_name]:TYPENAME = "UserDelegate" {
				this_craft[page][action_name]:TYPENAME.
			} ELSE {
				CS().
				Display["print"](this_craft[page][action_name]).
				WAIT 2.
			}
			RETURN showPage(page).
		} ELSE {
			RETURN showHomePage().
		}
	}
	
	function showHomePage {
		LOCAL p_list TO LIST(
			"PreLaunch", 
			"HandleStaging",
			"Thrusting",
			"Deployables",
			"Injection",
			"CorrectionBurn",
			"CheckCraftCondition",
			"EXIT"
		).
		LOCAL m_chooser TO LIST(
			LEXICON(
				"name", "page",
				"type", "select",
				"msg", "Choose a module",
				"choices", p_list
			)
		).
		LOCAL page TO Inquiry(m_chooser)["page"].
		IF NOT(page = "EXIT") {
			return showPage(page).
		} ELSE {
			CS().
			RETURN 0.
		}
	}
	showHomePage().
}
Tester().
