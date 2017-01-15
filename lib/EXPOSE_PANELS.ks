function exposePanels{
	//dependency - PID
	DECLARE LOCAL panels_PID TO 0.
	DECLARE LOCAL timer TO 0.
	function init{
		PARAMETER setp IS "err1".
		IF setp = "err1"{
			PRINT "No setpoint value specified"
			return false.
		}
		PARAMETER prop IS 0.2.
		SET timer TO TIME:SECONDS.
		SET panels_PID TO setPID( setp, prop ).
	}
	function refresh{
		return panels_PID:UPDATE(TIME:SECONDS-timer, LIGHT).
	}
}