@LAZYGLOBAL off.
function setPID{
	PARAMETER setp IS "err1".
	IF setp = "err1"{
		PRINT "No setpoint value specified".
		return false.
	}
	PARAMETER prop IS 0.2.
	LOCAL Kp TO prop.
	LOCAL Ki TO prop * 0.5.
	LOCAL Kd TO prop * 0.0125.
	LOCAL PIDL TO PIDLOOP(Kp, Kp, Kd).
	SET PIDL:SETPOINT TO setp.
	return PIDL.
}