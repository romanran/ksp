@LAZYGLOBAL off.

function Timer {
	LOCAL internal_t TO 999999999.
	LOCAL invokes TO 0.
	LOCAL wait_for TO 1.
	
	function onReady {
		PARAMETER p_wait_for IS wait_for.
		PARAMETER fun IS 0.
		PARAMETER params IS "empty".
		SET wait_for TO p_wait_for.
		IF FLOOR(TIME:SECONDS) >= internal_t + wait_for AND invokes = 1 {
			SET invokes TO 2.
			IF fun <> 0 {
				IF params <> "empty" {
					RETURN fun(params).//pass arguments as a list
				} ELSE {
					RETURN fun().
				}
			}
		} ELSE {
			RETURN 0.
		}
	}

	function setTimer {
		SET internal_t TO FLOOR(TIME:SECONDS).
		SET invokes TO 1.
	}
	
	function resetTimer {
		SET internal_t TO 999999999.
		SET invokes TO 0.
		SET wait_for TO 1.
	}
	
	function delayTimer {
		PARAMETER delay_t IS 1.
		SET internal_t TO internal_t + delay_t - wait_for.
	}
	
	function checkTimer {
		RETURN FLOOR(TIME:SECONDS) - (internal_t + wait_for).
	}

	return lex(
		"ready", onReady@,
		"check", checkTimer@,
		"set", setTimer@,
		"reset", resetTimer@,
		"delay", delayTimer@
	).
}