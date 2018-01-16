@LAZYGLOBAL off.

function Journal {
	LOCAL self TO LEXICON().
	LOCAL ship_res TO getResources().
	LOCAL save_path TO "1:flightlogs/journal_" + SHIPNAME + ".json".
	
	LOCAL row TO LEXICON().
	LOCAL row_num TO 0.
	row:add("TIME", TIME:SECONDS).
	row:add("SHIP", SHIPNAME).
	LOCAL res_lex TO LEXICON().
	FOR key IN ship_res:KEYS {
		res_lex:add(ship_res[key]:NAME, ship_res[key]:CAPACITY).
	}
	row:add("DESC", "On launchpad, waiting for countdown.").
	row:add("RESOURCES", res_lex).
	self:add(row_num, row).
	
	LOCAL function addEntry {
		PARAMETER description IS "NC".
		SET row_num TO row_num + 1.
		LOCAL ship_res TO getResources().
		SET row TO LEXICON().
		row:add("MISSIONTIME", ROUND(MISSIONTIME)).
		row:add("TIME", ROUND(TIME:SECONDS)).
		row:add("ALT", ROUND(ALT:RADAR)).
		row:add("APO", ROUND(ALT:APOAPSIS)).
		row:add("PER", ROUND(ALT:PERIAPSIS)).
		row:add("ORBV", ROUND(VELOCITY:ORBIT:MAG)).
		row:add("SURV", ROUND(VELOCITY:SURFACE:MAG)).
		row:add("Q", ROUND(globals["q_pressure"]())).
		row:add("THROTT", ROUND(THROTTLE)).
		row:add("PITCH", ROUND(this_craft["Thrusting"]["ship_p"]())).
		row:add("FACING", FACING).
		row:add("VERTICALSPEED", ROUND(VERTICALSPEED)).
		SET res_lex TO LEXICON().
		FOR key IN ship_res:KEYS {
			res_lex:add(ship_res[key]:NAME, ROUND(ship_res[key]:AMOUNT)).
		}
		row:add("RESOURCES_LEFT", res_lex).
		row:add("STATUS", SHIP:STATUS).
		row:add("DESC", description).
		self:add(row_num, row).
		WRITEJSON(self, save_path).
	}
	LOCAL function dumpAll {
		PRINT self:DUMP.
	}
	
	LOCAL function saveToLog {
		IF ADDONS:RT:HASKSCCONNECTION(SHIP) {
			COPYPATH(save_path, "0:flightlogs/").
			HUDTEXT("Flight journal saved!", 3, 2, 40, green, false).
			RETURN true.
		} ELSE IF HOMECONNECTION:ISCONNECTED { 
			COPYPATH(save_path, "0:flightlogs/").
			HUDTEXT("Flight journal saved!", 3, 2, 40, green, false).
			RETURN true.
		} ELSE {
			HUDTEXT("Journal can't be send, no connection", 3, 2, 40, red, false).
			RETURN false.
		}
	}
	
	LOCAL methods TO LEXICON(
		"add", addEntry@,
		"dump", dumpAll@,
		"save", saveToLog@
	).
	
	RETURN methods.
}