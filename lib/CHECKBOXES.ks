function Checkboxes{
	PARAMETER msg.
	PARAMETER choices.
	LOCAL items_i TO 0.
	LOCAL print_i TO 0.
	LOCAL pointer TO 1.
	LOCAL answers TO LIST().

	function _print{
		PARAMETER str.
		PRINT str AT (0, print_i).
		SET print_i TO print_i + 1.
	}
	function getAnswers{
		return answers.
	}

	function movePointer{
		PARAMETER char.
		IF char = TERMINAL:INPUT:UPCURSORONE{
			IF pointer > 1{
				PRINT " " AT (5, pointer).
				SET pointer TO pointer - 1.
				PRINT "<" AT (5, pointer).
				return true.
			}ELSE{	
				RETURN false.
			}
		}
		IF char = TERMINAL:INPUT:DOWNCURSORONE{
			IF pointer < items_i{
				PRINT " " AT (5, pointer).
				SET pointer TO pointer + 1.
				PRINT "<" AT (5, pointer).
				RETURN true.
			}ELSE{
				RETURN false.
			}
		}
		IF char = " "{
			togglePos().
			RETURN true.
		}
	}
	
	function togglePos{
		SET answers[pointer-1]["value"] TO NOT answers[pointer-1]["value"].
		IF answers[pointer-1]["value"]{
			PRINT "x" AT (3, pointer).
		}ELSE{
			PRINT " " AT (3, pointer).
		}
	}
	
	function _reset{
		SET items_i TO 0.
		SET print_i TO 0.
	}

	function listItems{
		_print(msg).
		SET pos TO 1.
		FOR choice IN choices{
			answers:ADD(LEXICON("name", choice["name"], "value", FALSE)).
			PRINT pos AT (0, items_i +1).
			PRINT ".[ ] - " AT (1, items_i +1).
			PRINT choice["msg"] AT (10, items_i +1).
			SET items_i TO items_i + 1.
			SET print_i TO print_i + 1.
			SET pos TO pos + 1.
			_print("").
		}
		PRINT "<" AT (5, pointer).
		_print("up/down arrows to move, space to check, enter to confirm").
	}
	
	function init{
		CLEARSCREEN.
		listItems().
	}
	
	LOCAL methods TO LEXICON(
		"getAnswers", getAnswers@,
		"movePointer", movePointer@
	).
	init().
	RETURN methods.
}