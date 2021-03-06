@LAZYGLOBAL off.

function Journal {
	LOCAL self TO LEXICON().
	LOCAL ship_res TO getResources().
	LOCAL save_path TO "1:flightlogs/journal_" + SHIPNAME + ".json".
	
	LOCAL row TO LEXICON().
	LOCAL row_num TO 0.
	row:add("TIME", TIME:SECONDS).
	row:add("SHIP", SHIPNAME).
	row:add("MTIME", ROUND(MISSIONTIME, 1)).
	LOCAL res_lex TO LEXICON().
	FOR key IN ship_res:KEYS {
		res_lex:add(ship_res[key]:NAME, ship_res[key]:CAPACITY).
	}
	row:add("DESC", "On launchpad, waiting for countdown.").
	row:add("RES", res_lex).
	self:add(row_num, row).
	
	LOCAL function addEntry {
		PARAMETER description IS "NC".
		SET row_num TO row_num + 1.
		LOCAL ship_res TO getResources().
		SET row TO LEXICON().
		row:add("MTIME", ROUND(MISSIONTIME, 1)).
		row:add("TIME", ROUND(TIME:SECONDS, 1)).
		row:add("ALT", ROUND(ALT:RADAR)).
		row:add("APO", ROUND(ALT:APOAPSIS)).
		row:add("PER", ROUND(ALT:PERIAPSIS)).
		row:add("ORBV", ROUND(VELOCITY:ORBIT:MAG, 1)).
		row:add("SURV", ROUND(VELOCITY:SURFACE:MAG, 1)).
		row:add("Q", ROUND(globals["q_pressure"](), 3)).
		row:add("THROTT", ROUND(THROTTLE)).
		row:add("PITCH", ROUND(this_craft["Thrusting"]["ship_p"]())).
		row:add("FACING", FACING).
		row:add("VS", ROUND(VERTICALSPEED, 2)).
		row:add("ORBP", ROUND(SHIP:ORBIT:PERIOD, 3)).
		SET res_lex TO LEXICON().
		FOR key IN ship_res:KEYS {
			res_lex:add(ship_res[key]:NAME, ROUND(ship_res[key]:AMOUNT)).
		}
		row:add("RES", res_lex).
		row:add("STATUS", SHIP:STATUS).
		row:add("DESC", description).
		self:add(row_num, row).
		WRITEJSON(self, save_path).
	}
	LOCAL function dumpAll {
		PRINT self:DUMP.
	}
	
	LOCAL function saveToLog {
		WRITEJSON(self, save_path).
		IF ADDONS:RT:HASKSCCONNECTION(SHIP) OR HOMECONNECTION:ISCONNECTED { 
			COPYPATH(save_path, "0:flightlogs/").
			RETURN true.
		} ELSE {
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