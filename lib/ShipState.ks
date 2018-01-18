@LAZYGLOBAL off.

function ShipState {
	LOCAL filename IS "1:ship-state".
	LOCAL ship_state IS LEXICON().

	LOCAL function setAndSave {
		PARAMETER key.
		PARAMETER val.
		SET ship_state[key] TO val.
		WRITEJSON(ship_state, filename).
	}
	
	LOCAL function shipState {
		PARAMETER key IS "n0n".
		IF (EXISTS(filename)) {
			SET ship_state TO READJSON(filename).
		}
		IF key = "n0n" {
			return ship_state.
		} ELSE IF ship_state:HASKEY(key) {
			return ship_state[key].
		}
		return 0.
	}

	LOCAL methods TO LEXICON(
		"set", setAndSave@,
		"get", shipState@
	).
	
	RETURN methods.
}