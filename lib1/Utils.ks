// Helper functions and utilities
function loadDeps {
	PARAMETER libs.
	PARAMETER path IS "lib".
	FOR lib IN libs {
		LOCAL trgt_path IS "0:" + path + "/" + lib.
		IF EXISTS(trgt_path) {
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
		IF (str1:LENGTH > 0) {
			PRINT str1.
		}
		IF (str2:LENGTH > 0) {
			PRINT str2.
		}
		IF (str3:LENGTH > 0) {
			PRINT str3.
		}
		IF (str4:LENGTH > 0) {
			PRINT str4.
		}
	} 
}

function generateID {
	PARAMETER default_vessel IS SHIP.
	LOCAL vessel_name TO default_vessel.

	IF default_vessel:typename() = "Vessel" {
		SET vessel_name TO default_vessel:NAME. 
	}
	IF default_vessel:typename() = "String" {
		SET vessel_name TO default_vessel. 
	}
	RETURN vessel_name + " " + FLOOR(RANDOM() * 1000).
}