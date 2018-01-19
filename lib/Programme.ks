@LAZYGLOBAL off.

function Programme {
	PARAMETER path.
	LOCAL filelist IS LIST().
	
	LOCAL function addVessel {
		LOCAL obj TO READJSON(path).
		FOR vsl IN obj["vessels"] {
			IF vsl = SHIPNAME {
				RETURN HUDTEXT(SHIPNAME + " already exists inside the " + path, 4, 2, 30, red, false).
			}
		}
		obj["vessels"]:ADD(SHIPNAME).
		WRITEJSON(obj, path).
		HUDTEXT(SHIPNAME + " has been added to the " + path, 4, 2, 30, green, false).
	}

	LOCAL function fetch {
		LOCAL obj TO READJSON(path).
		RETURN obj.
	}

	function dumpAll {
		PRINT self:DUMP.
	}

	LOCAL function listPrograms {
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

	LOCAL function create {
		PARAMETER atts IS LEXICON().
		
		IF VOLUME(0):EXISTS("program/" + path + ".json") {
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