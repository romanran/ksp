@LAZYGLOBAL off.

IF NOT(EXISTS("1:Utils")) AND ((ADDONS:AVAILABLE("RT") AND ADDONS:RT:HASKSCCONNECTION(SHIP)) OR HOMECONNECTION:ISCONNECTED) {
	COPYPATH("0:lib/Utils", "1:").
}
RUNONCEPATH("Utils").

LOCAL dependencies IS LIST("Checkboxes", "Inquiry", "Program").
loadDeps(dependencies).

function Creator {
	LOCAL name_inq TO Inquiry(LIST(
		LEXICON(   
			"name", "pr_name",   
			"type", "char",    
			"msg", "Program name"
		)
	)).
	LOCAL pr TO Program(name_inq["pr_name"]).
	PRINT pr["list"]().

	LOCAL target_question TO LIST( 
		LEXICON(   
			"name", "sats",   
			"type", "number",    
			"msg", "Number of satellites",
			"filter", { 
				PARAMETER resolve, reject, val. 
				IF (val < 1 OR val > 6) { 
					return reject("Choose number of sats in range 1 - 6"). 
				} ELSE { 
					return resolve(val). 
				} 
			} 
		), 
		LEXICON( 
			"name", 	"alt",  
			 "type", 	 "number",   
			 "msg", 	 "Altitude in km.",
			 "filter", {
				PARAMETER resolve, reject, val.
				return resolve(val * 1000).
			}
		),
		LEXICON( 
			 "name", 	 "modules",  
			 "type", 	 "checkbox",   
			 "msg", 	 "Choose modules",
			 "choices", LIST(
				"PreLaunch",
				"TakeOff",
				"HandleStaging",
				"Thrusting",
				"Deployables",
				"Injection",
				"Coasting",
				"CorrectionBurn",
				"CheckCraftCondition"
			 )
		),
		LEXICON( 
			 "name", 	 "Journal",  
			 "type", 	 "bool",   
			 "msg", 	 "Save flight telemetry?"
		)
	).

	pr["create"](Inquiry(target_question)).
	CLEARSCREEN.
	PRINT Program("0:program/" + name_inq["pr_name"] + ".json")["fetch"]().
}
Creator().