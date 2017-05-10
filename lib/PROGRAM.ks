function Program {
	PARAMETER ptype IS "undefined".
	SET ptype TO ptype:REPLACE(".json", "").
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
		LOCAL obj TO READJSON(npath).
		RETURN obj["attributes"]:DUMP.
	}
	
	function dumpAll {
		PRINT self:DUMP.
	}
	
	function listPrograms {
		CD("0:program").
		LIST FILES IN filelist.
		LOCAL programs_a IS LIST().
		FOR file IN filelist {
			programs_a:ADD(file:NAME:SUBSTRING(0, file:NAME:FIND(".json"))).
		}
		CD("1:").
		RETURN programs_a.
	}
	
	function create {
		PARAMETER atts IS LEXICON().
		CD("0:program").
		LIST FILES IN filelist.
		
		IF VOLUME(0):EXISTS("program/" + ptype + ".json") {
			CD("1:").
			RETURN PRINT("Program already exists!").
		}

		SET new_program TO LEXICON(
			"type", ptype,
			"id", generateID(ptype),
			"vessels", LIST(),
			"attributes", atts
		).
		WRITEJSON(new_program, path).
		CD("1:").
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