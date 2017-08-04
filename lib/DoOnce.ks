function DoOnce {
	LOCAL is_ready TO 1.
	
	function call {
		PARAMETER func IS 0.
		PARAMETER params IS "empty".
		IF (func <> 0) AND is_ready {
			SET is_ready TO 0.
			IF params <> "empty" {
				RETURN func(params).//pass arguments as a list
			} ELSE {
				RETURN func().
			}
		} ELSE {
			RETURN 0.
		}
	}

	function resetIt {
		SET is_ready TO 1.
	}
	
	function isReady {
		RETURN is_ready.
	}

	RETURN lex(
		"do", call@,
		"ready", isReady@,
		"reset", resetIt@
	).
}