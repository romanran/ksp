@LAZYGLOBAL off.

function Timer {
	LOCAL internal_t TO 999999999.
	LOCAL invokes TO 0. //0 - not yet set, 1 - timer set, counting, >2 - already used
	LOCAL wait_for TO 1.
	
	LOCAL function onReady {
		PARAMETER p_wait_for IS wait_for.
		PARAMETER fun IS 0.
		SET wait_for TO p_wait_for.
		IF TIME:SECONDS >= internal_t + wait_for AND invokes = 1 {
			SET invokes TO 2.
			IF fun <> 0 {
				RETURN fun().
			}
		} ELSE {
			RETURN 0.
		}
	}

	LOCAL function setTimer {
		SET internal_t TO TIME:SECONDS.
		SET invokes TO 1.
	}
	
	LOCAL function resetTimer {
		SET internal_t TO 999999999.
		SET invokes TO 0.
		SET wait_for TO 1.
	}
	
	LOCAL function delayTimer {
		PARAMETER delay_t IS 1.
		SET internal_t TO internal_t + delay_t - wait_for.
	}
	
	function checkTimer {
		RETURN TIME:SECONDS - (internal_t + wait_for).
	}

	return LEX(
		"ready", onReady@,
		"check", checkTimer@,
		"set", setTimer@,
		"reset", resetTimer@,
		"delay", delayTimer@
	).
}