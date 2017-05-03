// Pass a list of lexicons:
// possible attributes of the lexicons
// name - (string) name of the returned variable
// type - (string) possible[number, letter, chars(letters and numbers), checkbox]
// msg - (string) message to show on the input
// choices - (list) list of lexicons for checkboxes, takes [name, msg] as before
//

COPYPATH("0:lib/checklist", "1:").
function Menu{
	PARAMETER inputs.
	LOCAL numbers TO "01234566789.":SPLIT("").
	LOCAL letters TO "abcdefghijklmnopqrstuwvxyz":SPLIT("").
	LOCAL Sounds TO GETVOICE(0).
	LOCAL err_s TO NOTE(400, 0.1).
	LOCAL correct_s TO NOTE("c6",  0.1, 0, 0.3).
	LOCAL enter_s TO  NOTE("E6",  0.5, 0, 0.3).
	
	function loop{
		LOCAL vals TO LEXICON().
		FOR inp IN inputs{
			IF(inp:HASKEY("name")){
				LOCAL msg TO inp["name"] + " input:".
				LOCAL itype TO "char".
				IF(inp:HASKEY("msg")){
					SET msg TO inp["msg"].
				}
				IF(inp:HASKEY("type")){
					SET itype TO inp["type"].
				}
				IF (inp:HASKEY("choices")) {
					SET vals[inp["name"]] TO read(msg, itype, inp["choices"]).
				} ELSE {
					SET vals[inp["name"]] TO read(msg, itype).
				}
			}
		}
		RETURN vals.
	}
	
	function onError{
		PARAMETER err TO "".
		PRINT err.
	}
	
	function read{
		CLEARSCREEN.
		PARAMETER msg TO "Value".
		PARAMETER ch_type TO "char".
		PARAMETER choices TO LIST().
		LOCAL val TO "".
		LOCAL enters TO 0.
		LOCAL done TO false.
		LOCAL check_list TO false.
		IF ch_type="checkbox"{
			RUNONCEPATH("1:Checklist").
			SET check_list TO Checklist(msg, choices).
		}
		UNTIL done {
			IF TERMINAL:INPUT:HASCHAR {
				LOCAL char to TERMINAL:INPUT:GETCHAR().
				IF ch_type="number" AND numbers:CONTAINS(char){
					SET val TO val+""+char.
					Sounds:PLAY(correct_s).
				}
				ELSE IF ch_type="letter" AND letters:CONTAINS(char){
					SET val TO val+""+char.
					Sounds:PLAY(correct_s).
				}
				ELSE IF ch_type="char" {
					SET val TO val+""+char.
					Sounds:PLAY(correct_s).
				}ELSE IF ch_type="checkbox" {
					IF check_list["movePointer"](char) {
						Sounds:PLAY(correct_s).
					} ELSE {
						Sounds:PLAY(err_s).
					}
				}ELSE{
					Sounds:PLAY(err_s).
				}
				IF char = TERMINAL:INPUT:BACKSPACE {
					SET val TO val:SUBSTRING(0, val:LENGTH - 1).
					PRINT msg+": "+val+"                                " AT (0,0).
					Sounds:PLAY( NOTE("d5",  0.1, 0, 0.3) ).
				}ELSE IF char = TERMINAL:INPUT:ENTER{
					IF ch_type = "checkbox"{
						SET val TO check_list["getAnswers"]().
					}
					SET done TO true.
					IF ch_type="number" AND NOT(val = ""){
						SET val TO val:TONUMBER(onError).
					}
					Sounds:PLAY( enter_s ).
					RETURN val.
				}
			}
			PRINT msg+": "+val AT (0,0).
			WAIT 0.1.
		}
		RETURN val.
	}
	RETURN loop().
}