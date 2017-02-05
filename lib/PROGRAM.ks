COPYPATH("0:lib/MENU", "1:").
RUNONCEPATH("MENU").
function Program{
	LOCAL pages TO LEXICON().
	LOCAL items_i TO 0.
	LOCAL print_i TO 0.
	LOCAL pointer TO 0.
	LOCAL 
	function _print{
		PARAMETER str.
		PRINT str AT (0, print_i).
		SET print_i TO print_i + 1.
	}
	function addPos{
		PARAMETER pos.
		PARAMETER p_name.
		PARAMETER callback.

	}
	function movePointer{
		PRINT pointer.
		IF TERMINAL:INPUT:HASCHAR{
			LOCAL char to TERMINAL:INPUT:GETCHAR().
			IF char = TERMINAL:INPUT:UPCURSORONE{
				IF pointer > 0{
					SET pointer TO pointer - 1.
				}
			}
			IF char = TERMINAL:INPUT:DOWNCURSORONE{
				IF pointer < items_i{
					SET pointer TO pointer + 1.
				}
			}
		}
	}
	function _page(){
		PARAMETER page_name.
		LOCAL lex TO LEXICON().
		lex:ADD("name", page_name).
	}
	function addPage{
		PARAMETER page_id.
		PARAMETER page_name.
		SET items_i TO items_i + 1.
		pages:add( page_id, _page( page_name ) ).
	}
	function _reset{
		SET items_i TO 0.
		SET print_i TO 0.
	}
	function listPrograms{
		_reset().
		_print("---- CHOOSE A PROGRAM ----").
		FOR key IN pages:KEYS{
			addPos(i, pages[key]["name"]).
			SET i TO i + 1.
		}
	}
	function listItems{
		PRINT pos AT (0, items_i + print_i).
		PRINT ". [ ] - " AT (2, items_i + print_i).
		PRINT p_name AT (10, items_i + print_i).
		SET items_i TO items_i + 1.
	}
	function addMenu{
		
	}
	function init{
		 listPrograms().
	}
	LOCAL methods TO LEXICON(
		"addPos", addPos@,
		"addMenu", addMenu@,
		"new", addPage@,
		"init", init@
	).
	RETURN methods.
}
SET program TO Program().
program["new"]("comm1","Kerbin Comm-sat").
program["addMenu"]("comm1", "" ).
program["init"]().