function Displayer{
	LOCAL print_i TO 0.
	LOCAL imprint_i TO 0.
	LOCAL padd TO 0.
	
	function _print{
		PARAMETER str.
		PARAMETER val IS "empty-str".
		SET print_sum TO print_i + imprint_i.
		IF val = "empty-str"{
			PRINT str AT (0, print_sum).
		}ELSE{
			IF val:ISTYPE("Scalar") {
				SET val TO ROUND(val, 2).
			}
			SET str TO str + "".
			SET val TO val + "". //convert to str
			PRINT " ":PADLEFT(TERMINAL:WIDTH) AT (0, print_sum).
			SET str TO str + val:PADLEFT(TERMINAL:WIDTH - str:LENGTH).
			PRINT str AT (0, print_sum).
		}
		SET print_i TO print_i + 1.
	}
	
	function _reset{
		SET print_i TO 0.
	}
	
	function imprint{
		PARAMETER str.
		PARAMETER val IS "empty-str".
		_print(str, val).
		SET imprint_i TO imprint_i + 1.
		SET print_i TO print_i - 1.
	}
	
	LOCAL methods TO LEXICON(
		"Print", _print@,
		"reset", _reset@,
		"imprint", imprint@
	).

	RETURN methods.
}