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
	
	LOCAL f_list IS LIST("getPhaseAngle", "getTrgtAlt", "calcBurnTime", "gbase", "BACK").

	LOCAL from_save TO this_craft["PreLaunch"]["from_save"]. //this value will be false, if a script runs from the launch of a ship. If ship is loaded from a save, it will be set to true inside prelaunch phase
		
	function listModules {
		LOCAL p_list TO this_craft:KEYS.
		p_list:ADD("BACK").
		LOCAL chooser TO LIST(
			LEXICON(
				"name", "module",
				"type", "select",
				"msg", "Select a module to test",
				"choices", p_list
			)
		).
		LOCAL page TO Inquiry(chooser)["module"].
		IF NOT(page = "BACK") {
			return showModulePage(page).
		} ELSE {
			//CS().
			RETURN showHomePage().
		}
	}
	
	function listFunctions {
		LOCAL chooser TO LIST(
			LEXICON(
				"name", "func",
				"type", "select",
				"msg", "Select a function to test",
				"choices", f_list
			)
		).
		LOCAL func TO Inquiry(chooser)["func"].
		IF NOT(func = "BACK") {
			return runFunction(func).
		} ELSE {
			//CS().
			RETURN showHomePage().
		}
	}
	
	function showModulePage {
		PARAMETER page.
		LOCAL choices TO this_craft[page]:KEYS.
		choices:ADD("BACK").
		LOCAL a_chooser TO LIST(
			LEXICON(
				"name", "action",
				"type", "select",
				"msg", "Choose an action",
				"choices", choices
			)
		).
		LOCAL action_name TO Inquiry(a_chooser)["action"].
		IF NOT(action_name = "BACK") {
			IF this_craft[page][action_name]:TYPENAME = "UserDelegate" {
				CS().
				Display["print"](action_name + " returned", this_craft[page][action_name]()).
			} ELSE {
				CS().
				Display["print"](action_name, this_craft[page][action_name]).
			}
			LOCAL done IS false.
			Display["print"]("Press enter to continue").
			UNTIL done {
				IF TERMINAL:INPUT:HASCHAR {
					LOCAL char to TERMINAL:INPUT:GETCHAR().
					IF char = TERMINAL:INPUT:ENTER {
						Display["reset"]().
						SET done to true.
						showModulePage(page).
					}
				}
			}
		} ELSE {
			RETURN listModules().
		}
	}
	
	LOCAL phase_angle IS LEXICON("current", 0).
	
	function runFunction {
		PARAMETER func.
		CS().
		IF func = "getPhaseAngle" {
			LOCAL target_l IS LIST().
			LIST TARGETS IN target_l.
			LOCAL usr_input TO Inquiry(LIST(
				LEXICON(
					"name", "target",
					"type", "select",
					"msg", "Choose a target vessel",
					"choices", target_l
				)
			)).
			CS().
			SET phase_angle TO getPhaseAngle(trgt_prog["attributes"]["sats"], usr_input["target"], phase_angle["current"]).
			Display["print"]("Degrees spread:", phase_angle["spread"]).
			Display["print"]("Degrees traveled:", phase_angle["traveled"]).
			Display["print"]("Target separation:", phase_angle["separation"]).
			Display["print"]("Est. angle move:", phase_angle["move"]).
			Display["print"]("Target phase angle:", phase_angle["target"]).
			Display["print"]("Current phase angle:", phase_angle["current"]).
			
		} ELSE IF func = "calcBurnTime" {
			LOCAL usr_input TO Inquiry(LIST(
				LEXICON(
					"name", "dv",
					"type", "number",
					"msg", "Input target ΔV"
				)
			)).
			CS().
			Display["print"]("Target dv: " + usr_input["dv"] + " time: " + calcBurnTime(usr_input["dv"])).
		} ELSE IF func = "getTrgtAlt" {
			LOCAL trgt TO Inquiry(LIST(
				LEXICON(
					"name", "sat_num",
					"type", "number",
					"msg", "Number of satellites"
				),
				LEXICON(
					"name", "min_h",
					"type", "number",
					"msg", "Min. altitute"
				)
			)).
			CS().
			Display["print"](getTrgtAlt(trgt["sat_num"], trgt["min_h"])).
		} ELSE IF func = "gbase" {
			LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS ^ 2.
			Display["print"]("G :", g_base).
			Display["print"]("Acceleration:", globals["acc_vec"]():MAG).
			Display["print"]("Acceleration absolute:", globals["acc_vec"]():MAG / g_base - 1).
		}
		LOCAL done IS false.
		Display["print"]("Press enter to continue").
		UNTIL done {
			IF TERMINAL:INPUT:HASCHAR {
				LOCAL char to TERMINAL:INPUT:GETCHAR().
				IF char = TERMINAL:INPUT:ENTER {
					Display["reset"]().
					SET done to true.
					listFunctions().
				}
			}
		}
	}
	
	function showHomePage {
		LOCAL chooser TO LIST(
			LEXICON(
				"name", "choice",
				"type", "select",
				"msg", "Choose test category",
				"choices", LIST("Modules", "Functions", "EXIT")
			)
		).
		LOCAL choice TO Inquiry(chooser)["choice"].
		IF choice = "Modules" {
			return listModules().
		} IF choice = "Functions" {
			return listFunctions().
		} ELSE IF choice = "EXIT" {
			CS().
			RETURN 0.
		}
	}
	showHomePage().
}

Tester().