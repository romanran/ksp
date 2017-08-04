function Checkboxes {
	PARAMETER msg.
	PARAMETER choices.
	PARAMETER chtype IS "checkbox".
	LOCAL items_i TO 0.
	LOCAL print_i TO 0.
	LOCAL pointer TO 1.
	LOCAL answers TO LIST().

	function _print {
		PARAMETER str.
		PRINT str AT (0, print_i).
		SET print_i TO print_i + 1.
	}
	function getAnswers {
		IF chtype = "select" {
			return answers[pointer-1]["name"].
		}
		return answers.
	}

	function movePointer {
		PARAMETER char.
		IF char = TERMINAL:INPUT:UPCURSORONE {
			IF pointer > 1{
				PRINT " " AT (5, pointer).
				SET pointer TO pointer - 1.
				PRINT "<" AT (5, pointer).
				return true.
			}ELSE{	
				RETURN false.
			}
		}
		IF char = TERMINAL:INPUT:DOWNCURSORONE {
			IF pointer < items_i {
				PRINT " " AT (5, pointer).
				SET pointer TO pointer + 1.
				PRINT "<" AT (5, pointer).
				RETURN true.
			} ELSE {
				RETURN false.
			}
		}
		IF char = " " {
			togglePos().
			RETURN true.
		}
	}
	
	function togglePos {
		IF chtype = "select" {
			LOCAL i IS 0.
			UNTIL i = answers:LENGTH {
				SET answers[i]["value"] TO false.
				PRINT " " AT (3, i + 1).
				SET i TO i + 1.
			}
			SET answers[pointer-1]["value"] TO true.
		} ELSE {
			SET answers[pointer-1]["value"] TO NOT answers[pointer-1]["value"].
		}
		IF answers[pointer-1]["value"] {
			PRINT "x" AT (3, pointer).
		}ELSE{
			PRINT " " AT (3, pointer).
		}
	}
	
	function _reset {
		SET items_i TO 0.
		SET print_i TO 0.
	}

	function listItems {
		_print(msg).
		SET pos TO 1.
		FOR choice IN choices {
			IF choice:ISTYPE("LEXICON") {
				IF choice:HASKEY["name"] {
					answers:ADD(LEXICON("name", choice["name"], "value", FALSE)).
					IF choice:HASKEY["msg"] {
						PRINT choice["msg"] AT (10, items_i +1).
					} ELSE {
						PRINT choice["name"] AT (10, items_i +1).
					}
				}
			} ELSE {
				answers:ADD(LEXICON("name", choice, "value", FALSE)).
				PRINT choice AT (10, items_i +1).
			}
			PRINT pos AT (0, items_i +1).
			IF chtype = "select" {
				LOCAL default TO 0. 
				IF choice:ISTYPE("LEXICON") {
					IF choice:HASKEY["default"] {
						SET default TO items_i + 1.
					}
				}
				IF items_i = default {
					SET answers[items_i]["value"] TO true.
					PRINT ".(x) - " AT (1, items_i +1).
				} ELSE {
					PRINT ".( ) - " AT (1, items_i +1).
				}
			} ELSE {
				PRINT ".[ ] - " AT (1, items_i +1).
			}
			SET items_i TO items_i + 1.
			SET print_i TO print_i + 1.
			SET pos TO pos + 1.
			_print("").
		}
		PRINT "<" AT (5, pointer).
		_print("up/down arrows to move, space to check, enter to confirm").
	}
	
	function init{
		CS().
		listItems().
	}
	
	LOCAL methods TO LEXICON(
		"getAnswers", getAnswers@,
		"movePointer", movePointer@
	).
	init().
	RETURN methods.
}