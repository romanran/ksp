@LAZYGLOBAL off.
function Displayer {
	LOCAL line_height TO 2.
	LOCAL print_i TO 0.
	LOCAL imprint_i TO 0.
	LOCAL padd TO 0.

	LOCAL function _genDots {
		PARAMETER str1 TO 0.
		PARAMETER str2 TO 0.
		PARAMETER char TO ".".
		PARAMETER full TO true.
		LOCAL dots IS "".
		IF str1:ISTYPE("String") {
			SET str1 TO str1:LENGTH.
		}
		IF str2:ISTYPE("String") {
			SET str2 TO str2:LENGTH.
		}
		LOCAL sto_range IS TERMINAL:WIDTH - (str1 + str2).
		LOCAL to_range IS 0.
		IF NOT full {
			SET to_range TO FLOOR(sto_range / 2).
			IF MOD(sto_range, 2) = 1 {
				SET to_range TO to_range - 1.
			}
		} ELSE {
			SET to_range TO sto_range.
		}
		FROM {LOCAL i TO 0.} UNTIL i = to_range STEP {SET i TO i+1.} DO {
			SET dots TO dots + char.
		}
		RETURN dots.
	}

	LOCAL function _print {
		PARAMETER sstr IS "empty-str".
		PARAMETER val IS "empty-str".
		LOCAL print_sum TO print_i + imprint_i.
		
		IF sstr = "empty-str" {
			PRINT _separator() AT (0, print_sum).
		} ELSE IF val = "empty-str" {
			LOCAL centered IS " ".
			LOCAL centered2 IS "-".
			SET sstr TO " " + sstr + " ".
			LOCAL sep TO _genDots(sstr:LENGTH, 0, "-", false).
			IF (sep + sstr + sep):LENGTH = TERMINAL:WIDTH {
				SET centered TO "".
				SET centered2 TO "".
			}
			PRINT centered + sep + sstr + sep + centered2 AT (0, print_sum).
		} ELSE {
			IF val:ISTYPE("Scalar") {
				SET val TO ROUND(val, 3).
			}
			LOCAL str TO sstr + " ".
			SET val TO " " + val. //convert to str
			LOCAL dots IS _genDots(str:LENGTH, val).
			SET str TO str + dots + val.
			PRINT str AT (0, print_sum).
		}
		SET print_i TO print_i + line_height.
	}
	LOCAL function _separator {
		LOCAL sep IS _genDots(0, 0, "-").
		return sep.
	}

	LOCAL function _reset {
		SET print_i TO 0.
	}

	LOCAL function imprint {
		PARAMETER str IS _separator().
		PARAMETER val IS "empty-str".
		_print(str, val).
		SET imprint_i TO imprint_i + line_height.
		SET print_i TO print_i - line_height.
	}


	LOCAL methods TO LEXICON(
		"print", _print@,
		"reset", _reset@,
		"imprint", imprint@
	).

	RETURN methods.
}