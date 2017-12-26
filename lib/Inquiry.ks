// Pass a list of lexicons:
// possible attributes of the lexicons
// name - (string) name of the returned variable
// type - (string) possible[number, letter, chars(letters and numbers), checkbox, select]
// msg - (string) message to show on the input
// choices - (list) list of lexicons for checkboxes, takes [name, msg] as before, or a list of strings
// filter - (function delegate) it needs 3 parameters, 1st - success function, 2nd - failure function, 3rd - input value
// Return the success(input value) function call or the failure("message to show").
//
@LAZYGLOBAL off.

COPYPATH("0:lib/Checkboxes", "1:").
RUNONCEPATH("1:Checkboxes").
function Inquiry {
	PARAMETER inputs.
	LOCAL numbers TO "01234566789.":SPLIT("").
	LOCAL letters TO "abcdefghijklmnopqrstuwvxyz":SPLIT("").
	LOCAL Sounds TO GETVOICE(0).
	LOCAL err_s TO NOTE(400, 0.1).
	LOCAL correct_s TO NOTE("c6",  0.1, 0, 0.3).
	LOCAL enter_s TO  NOTE("E6",  0.5, 0, 0.3).

	LOCAL function loop {
		LOCAL vals TO LEXICON().
		FOR inp IN inputs {
			IF inp:HASKEY("name") {
				LOCAL msg TO inp["name"] + " input:".
				LOCAL itype TO "char".
				LOCAL choices TO LIST().
				function filterDelegate {
					PARAMETER res, rej, val.
					return res(val).
				}
				LOCAL filter TO filterDelegate@.
				IF inp:HASKEY("msg") {
					SET msg TO inp["msg"].
				}
				IF inp:HASKEY("type"){
					SET itype TO inp["type"].
				}
				IF inp:HASKEY("choices") {
					SET choices to inp["choices"].
				}
				IF inp:HASKEY("filter") {
					SET filter to inp["filter"].
				}
				SET vals[inp["name"]] TO read(msg, itype, choices, filter@).
			}
		}
		RETURN vals.
	}

	function onError {
		PARAMETER err TO "".
		PRINT " ":PADLEFT(TERMINAL:WIDTH) AT (0,1).
		PRINT err AT (0,1).
	}

	LOCAL function read {
		CS().
		PARAMETER msg.
		PARAMETER i_type.
		PARAMETER choices.
		PARAMETER filter.
		LOCAL val TO "".
		LOCAL enters TO 0.
		LOCAL done TO false.
		LOCAL check_list TO false.
		IF i_type = "checkbox" {
			SET check_list TO Checkboxes(msg, choices, "checkbox").
		}
		IF i_type = "select" {
			SET check_list TO Checkboxes(msg, choices, "select").
		}
		
		LOCAL function readInput {
			IF NOT TERMINAL:INPUT:HASCHAR {
				return 0.
			}
			PRINT " ":PADLEFT(TERMINAL:WIDTH) AT (0,0).
			LOCAL char to TERMINAL:INPUT:GETCHAR().
			IF i_type = "number" AND numbers:CONTAINS(char) {
				SET val TO val + "" + char.
				Sounds:PLAY(correct_s).
			} ELSE IF i_type = "letter" AND letters:CONTAINS(char) {
				SET val TO val + "" + char.
				Sounds:PLAY(correct_s).
			} ELSE IF i_type = "char" {
				SET val TO val + "" + char.
				Sounds:PLAY(correct_s).
			} ELSE IF i_type = "checkbox" OR i_type = "select" {
				IF check_list["movePointer"](char) {
					Sounds:PLAY(correct_s).
				} ELSE {
					Sounds:PLAY(err_s).
				}
			} ELSE {
				Sounds:PLAY(err_s).
			}
			IF char = TERMINAL:INPUT:BACKSPACE {
				IF val:LENGTH >= 1 {
					SET val TO val:SUBSTRING(0, val:LENGTH - 1).
					PRINT msg + ": " + val AT (0,0).
					Sounds:PLAY(NOTE("d5",  0.1, 0, 0.3)).
				} ELSE {
					Sounds:PLAY(err_s).
				}
			} ELSE IF char = TERMINAL:INPUT:ENTER {
				IF NOT i_type = "checkbox" AND val:LENGTH < 1 {
					RETURN onError("Value can't be empty").
				}
				IF i_type = "checkbox" OR i_type = "select" {
					SET val TO check_list["getAnswers"]().
				}
				IF i_type = "number" AND NOT(val = "") {
					SET val TO val:TONUMBER(onError).
				}
				LOCAL promise IS _promise(filter@, val).
				SET done TO promise["done"].
				IF promise["err"] = false {
					Sounds:PLAY( enter_s ).
					RETURN promise["val"].
				} ELSE {
					SET val TO val + "". //convert back to str
					onError(promise["val"]).
					Sounds:PLAY(err_s).
				}
			}
		}
		
		UNTIL done {
			readInput().
			PRINT msg + ": " + val AT (0,0).
			WAIT 0.
		}
		RETURN val.
	}


	LOCAL function _promise {
		PARAMETER filter, val.
		LOCAL done IS true.
		LOCAL err IS false.
		function resolve {
			PARAMETER val.
			return val.
		}
		function reject {
			PARAMETER msg.
			SET err TO true.
			return msg.
		}
		LOCAL filtered_val TO filter(resolve@, reject@, val).
		IF err = true {
			SET done TO false.
		}
		return LEXICON(
			"val", filtered_val,
			"done", done,
			"err", err
		).
	}

	RETURN loop().
}