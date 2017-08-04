function Timer {
	DECLARE LOCAL internal_t TO 999999999.
	DECLARE LOCAL invokes TO 0.
	DECLARE LOCAL wait_for TO 1.
	
	function onReady {
		PARAMETER wait_for.
		PARAMETER fun IS 0.
		PARAMETER params IS "empty".
		IF FLOOR(TIME:SECONDS) >= internal_t + wait_for AND invokes = 1{
			SET invokes TO 2.
			IF (fun <> 0){
				if( params <> "empty" ){
					fun(params).//pass arguments as a list
				}else{
					fun().
				}
			}
		}
	}

	function setTimer {
		SET internal_t TO FLOOR(TIME:SECONDS).
		SET invokes TO 1.
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
		"reset", setTimer@,
		"delay", delayTimer@
	).
}