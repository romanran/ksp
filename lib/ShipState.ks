@LAZYGLOBAL off.
function ShipState {
	LOCAL filename IS "1:ship-state.json".
	LOCAL ship_state IS LEXICON().
	IF (EXISTS(filename)) {
		SET ship_state TO READJSON(filename).
	}
	
	function setAndSave {
		PARAMETER key.
		PARAMETER val.
		SET ship_state[key] TO val.
		WRITEJSON(ship_state, filename).
	}

	LOCAL methods TO LEXICON(
		"set", setAndSave@,
		"state", ship_state
	).
	
	RETURN methods.
}