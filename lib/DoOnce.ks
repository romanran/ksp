function DoOnce {
	LOCAL is_ready TO 1.
	
	LOCAL function call {
		PARAMETER func IS 0.
		PARAMETER params IS "empty".
		IF (func <> 0) AND is_ready {
			SET is_ready TO 0.
			RETURN func().
		} ELSE {
			RETURN 0.
		}
	}

	LOCAL function resetIt {
		SET is_ready TO 1.
	}
	
	LOCAL function isReady {
		RETURN is_ready.
	}

	RETURN LEXICON(
		"do", call@,
		"ready", isReady@,
		"reset", resetIt@
	).
}