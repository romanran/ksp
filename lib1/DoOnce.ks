function DoOnce {
	LOCAL is_ready TO 1.
	function call {
		PARAMETER func IS 0.
		PARAMETER params IS "empty".
		IF (func <> 0) AND is_ready {
			if( params <> "empty" ){
				return func(params).//pass arguments as a list
			} else {
				return func().
			}
			SET is_ready TO 0.
		} ELSE {
			return 0.
		}
	}

	function resetIt {
		SET is_ready TO 1.
	}
	function isReady {
		return is_ready.
	}

	return lex(
		"do", call@,
		"ready", isReady@,
		"reset", resetIt@
	).
}