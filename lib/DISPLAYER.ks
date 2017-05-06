function Displayer{
	LOCAL print_i TO 0.
	LOCAL imprint_i TO 0.
	LOCAL padd TO 0.
	
	function _print{
		PARAMETER str.
		PARAMETER val IS "empty-str".
		SET pat TO print_i + imprint_i.
		IF val = "empty-str"{
			PRINT str AT (0, pat).
		}ELSE{
			SET str TO str + "".
			SET val TO val + "". //convert to str
			IF str:LENGTH > padd{
				SET padd TO str:LENGTH + 3.
			}
			SET str TO str + val:PADLEFT(40 - padd).
			PRINT str AT (0, pat).
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