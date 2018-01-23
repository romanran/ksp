@LAZYGLOBAL off.

function Checkboxes {
	PARAMETER msg.
	PARAMETER choices.
	PARAMETER chtype IS "checkbox".

	LOCAL print_i TO 0.
	LOCAL items_i TO 0.
	LOCAL pointer TO 1.
	LOCAL answers TO LIST().
	LOCAL pos TO 0.
	
	LOCAL sign IS "x".
	IF chtype = "select" {
		SET sign TO "●".
	}

	LOCAL function _print {
		PARAMETER str.
		PRINT str AT (0, print_i).
		SET print_i TO print_i + 1.
	}

	LOCAL function getAnswers {
		IF chtype = "select" {
			return answers[pointer - 1]["name"].
		}
		LOCAL answers_obj IS LEXICON().
		FOR answer IN answers {
			SET answers_obj[answer["name"]] TO answer["value"].
		}
		return answers_obj.
	}

	LOCAL function movePointer {
		PARAMETER char.
		IF char = " " {
			togglePos().
			RETURN true.
		}
		LOCAL prev_pointer IS pointer.
		IF char = TERMINAL:INPUT:UPCURSORONE {
			IF pointer > 1 {
				SET pointer TO pointer - 1.
			} ELSE {
				SET pointer TO items_i.
			}
		}
		IF char = TERMINAL:INPUT:DOWNCURSORONE {
			IF pointer < items_i {
				SET pointer TO pointer + 1.
			} ELSE {
				SET pointer TO 1.
			}
		}
		PRINT " " AT (6, prev_pointer).
		PRINT "<" AT (6, pointer).
		IF chtype = "select" togglePos().
		RETURN true.
	}

	LOCAL function togglePos {
		IF chtype = "select" {
			LOCAL i IS 0.
			UNTIL i = answers:LENGTH {
				SET answers[i]["value"] TO false.
				PRINT " " AT (4, i + 1).
				SET i TO i + 1.
			}
			SET answers[pointer - 1]["value"] TO true.
		} ELSE {
			SET answers[pointer - 1]["value"] TO NOT answers[pointer - 1]["value"].
		}
		IF answers[pointer - 1]["value"] {
			PRINT sign AT (4, pointer).
		}ELSE{
			PRINT " " AT (4, pointer).
		}
	}

	LOCAL function _reset {
		SET items_i TO 0.
		SET print_i TO 0.
	}

	LOCAL function listItems {
		_print(msg).
		SET pos TO 1.
		FOR choice IN choices {
			IF choice:ISTYPE("LEXICON") {
				IF choice:HASKEY["name"] {
					answers:ADD(LEXICON("name", choice["name"], "value", FALSE)).
					IF choice:HASKEY["msg"] {
						PRINT choice["msg"] AT (11, items_i + 1).
					} ELSE {
						PRINT choice["name"] AT (11, items_i + 1).
					}
				}
			} ELSE {
				answers:ADD(LEXICON("name", choice, "value", FALSE)).
				PRINT choice AT (11, items_i +1).
			}
			PRINT pos:TOSTRING():PADLEFT(2) AT (0, items_i + 1).
			IF chtype = "select" {
				LOCAL default TO 0. 
				IF choice:ISTYPE("LEXICON") {
					IF choice:HASKEY["default"] {
						SET default TO items_i + 1.
					}
				}
				IF items_i = default {
					SET answers[items_i]["value"] TO true.
					PRINT ".(" + sign + ") - " AT (2, items_i + 1).
				} ELSE {
					PRINT ".( ) - " AT (2, items_i + 1).
				}
			} ELSE {
				PRINT ".[ ] - " AT (2, items_i + 1).
			}
			SET items_i TO items_i + 1.
			SET print_i TO print_i + 1.
			SET pos TO pos + 1.
		}
		PRINT "<" AT (6, pointer).
		_print("").
		_print("up/down arrows to move, space to check, enter to confirm").
	}

	LOCAL function init {
		CS().
		listItems().
	}

	init().

	RETURN LEXICON(
		"getAnswers", getAnswers@,
		"movePointer", movePointer@
	).
}