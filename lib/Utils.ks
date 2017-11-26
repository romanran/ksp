@LAZYGLOBAL off.
// Helper functions and utilities
function loadDeps {
	PARAMETER libs.
	PARAMETER path IS "lib".
	IF NOT ((ADDONS:AVAILABLE("RT") AND ADDONS:RT:HASKSCCONNECTION(SHIP)) OR HOMECONNECTION:ISCONNECTED) {
		RETURN 0.
	}
	FOR lib IN libs {
		LOCAL trgt_path IS "0:" + path + "/" + lib.
		IF EXISTS(trgt_path) {
			IF EXISTS("1:" + lib) {
				DELETEPATH("1:" + lib).
			}
			COPYPATH(trgt_path, "1:").
			RUNONCEPATH(lib).
		} ELSE {
			deb("Path " + trgt_path + " not found").
		}
	}
}
	
function CS {
	IF NOT (env = "debug") {
		CLEARSCREEN.
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
	IF DEFINED ship_log AND ship_log:HASKEY("add") AND str {
		ship_log["add"](str).
	}
}