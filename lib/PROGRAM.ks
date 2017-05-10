function Program {
	PARAMETER ptypeb IS "undefined".
	SET ptype TO ptypeb:REPLACE(".json", "").
	LOCAL path TO "0:program/" + ptype + ".json".
	
	function addVessel {
		LOCAL obj TO READJSON(path).
		FOR vsl IN obj["vessels"] {
			IF vsl = SHIPNAME{
				RETURN HUDTEXT(SHIPNAME + " already exists inside the " + ptype + "program", 4, 2, 40, red, false).
			}
		}
		obj["vessels"]:ADD(SHIPNAME).
		WRITEJSON(obj, path).
		HUDTEXT(SHIPNAME + " has been added to the " + ptype + "program", 4, 2, 40, green, false).
	}
	
	function fetch {
		PARAMETER npath IS path.
		IF npath:FIND("json") < 0 {
			SET npath TO "0:program/" + npath + ".json".
		}
		LOCAL obj TO READJSON(npath).
		RETURN obj.
	}
	
	function dumpAll {
		PRINT self:DUMP.
	}
	
	function listPrograms {
		LOCAL prev_path TO PATH().
		CD("0:program").
		LIST FILES IN filelist.
		LOCAL programs_a IS LIST().
		FOR file IN filelist {
			IF file:ISFILE AND file:EXTENSION = "json" {
				programs_a:ADD(file:NAME:REPLACE(".json", "")).
			}
		}
		CD(prev_path).
		RETURN programs_a.
	}
	
	function create {
		PARAMETER atts IS LEXICON().
		
		IF VOLUME(0):EXISTS("program/" + ptype + ".json") {
			RETURN PRINT("Program already exists!").
		}
		
		LIST FILES IN filelist.
		LOCAL prev_path TO PATH().

		SET new_program TO LEXICON(
			"type", ptype,
			"id", generateID(ptype),
			"vessels", LIST(),
			"attributes", atts
		).
		CD("0:program").
		WRITEJSON(new_program, path).
		CD(prev_path).
	}
	
	LOCAL methods TO LEXICON(
		"create", create@,
		"add", addVessel@,
		"list", listPrograms@,
		"fetch", fetch@,
		"read", fetch@
	).
	
	RETURN methods.
}