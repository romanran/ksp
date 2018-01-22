@LAZYGLOBAL off.
IF NOT (DEFINED env) {
	GLOBAL env IS false.
}
// Helper functions and utilities
function loadDeps {
	PARAMETER libs.
	PARAMETER path IS "lib".
	IF NOT ((ADDONS:AVAILABLE("RT") AND ADDONS:RT:HASKSCCONNECTION(SHIP)) OR HOMECONNECTION:ISCONNECTED) {
		FOR lib IN libs {
			LOCAL trg_path IS "1:" + lib.
			IF EXISTS(trg_path) {
				IF EXISTS("1:" + lib) {
					RUNONCEPATH(lib).
				}
			} ELSE {
				deb("Path " + trg_path + " not found").
			}
		}
		RETURN 0.
	}
	FOR lib IN libs {
		LOCAL trg_path IS "0:" + path + "/" + lib.
		IF EXISTS(trg_path) {
			IF EXISTS("1:" + lib) {
				DELETEPATH("1:" + lib).
			}
			COPYPATH(trg_path, "1:").
			RUNONCEPATH(lib).
		} ELSE {
			deb("Path " + trg_path + " not found").
		}
	}
}
	
function CS {
	IF NOT (env = "debug") {
		CLEARSCREEN.
	}
	IF DEFINED Display {
		Display["reset"]().
	}
}

function deb {
	PARAMETER str1 IS "".
	PARAMETER str2 IS "".
	PARAMETER str3 IS "".
	PARAMETER str4 IS "".
	IF env = "debug" {
		IF (str1) {
			PRINT str1.
		}
		IF (str2) {
			PRINT str2.
		}
		IF (str3) {
			PRINT str3.
		}
		IF (str4) {
			PRINT str4.
		}
	} 
}

function generateID {
	PARAMETER default_vessel IS SHIP.
	LOCAL vessel_name TO default_vessel.
	function catch {
	}

	IF default_vessel:typename() = "Vessel" {
		SET vessel_name TO default_vessel:NAME. 
	}
	IF default_vessel:typename() = "String" {
		SET vessel_name TO default_vessel. 
	}
	LOCAL vessel_name_A TO vessel_name:SPLIT(" ").
	IF NOT(NOT(vessel_name_A[vessel_name_A:LENGTH - 1]:TONUMBER(catch))) { 
		// remove the last number
		vessel_name_A:REMOVE(vessel_name_A:LENGTH - 1).
	}
	
	SET vessel_name TO vessel_name_A:JOIN(" ").
	RETURN vessel_name + " " + FLOOR(RANDOM() * 1000).
}

function logJ {
	PARAMETER str.
	IF DEFINED globals["ship_log"] AND globals["ship_log"]:HASKEY("add") AND str {
		globals["ship_log"]["add"](str).
	}
}

function arr2obj {
	PARAMETER data.
	PARAMETER key1.
	PARAMETER key2.
	LOCAL key IS "".
	LOCAL return_lex IS LEXICON(key1, LIST(), key2, LIST()).
	FROM {LOCAL i is 0.} UNTIL i = data:LENGTH STEP {SET i TO i + 1.} DO {
		IF MOD(i, 2) = 0 {
			SET key TO key1.
		} ELSE {
			SET key TO key2.
		}
		return_lex[key]:ADD(data[i]).
	}
	RETURN return_lex.
}