function Menu{
	LOCAL done TO false.
	LOCAL numbers TO "01234566789":SPLIT("").
	LOCAL letters TO "abcdefghijklmnopqrstuwvxyz":SPLIT("").
	LOCAL Sounds TO GETVOICE(0).
	LOCAL err_s TO NOTE(400, 0.1).
	LOCAL correct_s TO NOTE("c6",  0.1, 0, 0.3).
	LOCAL enter_s TO  NOTE("E6",  0.5, 0, 0.3).
	
	function onError{
		PARAMETER err TO "".
		PRINT err.
	}
	function read{
		CLEARSCREEN.
		PARAMETER ch_type TO "all".
		LOCAL val TO "".
		LOCAL enters TO 0.
		UNTIL done {
			IF TERMINAL:INPUT:HASCHAR{
				LOCAL char to TERMINAL:INPUT:GETCHAR().
				IF ch_type="number" AND numbers:CONTAINS(char){
					SET val TO val+""+char.
					Sounds:PLAY( correct_s ).
				}
				ELSE IF ch_type="letter" AND letters:CONTAINS(char){
					SET val TO val+""+char.
					Sounds:PLAY( correct_s ).
				}
				ELSE IF ch_type="all"{
					SET val TO val+""+char.
					Sounds:PLAY( correct_s ).
				}ELSE{
					Sounds:PLAY( err_s ).
				}
				IF char = TERMINAL:INPUT:BACKSPACE{
					SET val TO val:SUBSTRING(0, val:LENGTH - 1).
					PRINT "value: "+val+"                                " AT (0,0).
					Sounds:PLAY( NOTE("d5",  0.1, 0, 0.3) ).
				}ELSE IF char = TERMINAL:INPUT:ENTER{
					SET done TO true.
					IF ch_type="number" AND NOT(val = ""){
						SET val TO val:TONUMBER(onError).
					}
					Sounds:PLAY( enter_s ).
					RETURN val.
				}
			}
			PRINT "value: "+val AT (0,0).
			WAIT 0.1.
		}
	}
	LOCAL methods TO LEXICON(
		"read", read@
	).
	RETURN methods.
}