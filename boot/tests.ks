PRINT "TEST START...".

//COPYPATH("0:lib/GETMODULES", "1:").
//COPYPATH("0:lib/COMSAT_HEIGHT", "1:").
//COPYPATH("0:lib/PID", "1:").
COPYPATH("0:lib/DOONCE", "1:").
//COPYPATH("0:lib/GETRESOURCES_f", "1:").
//COPYPATH("0:lib/TRAJECTORY", "1:").
COPYPATH("0:lib/FUNCTIONS", "1:").
COPYPATH("0:lib/JOURNAL", "1:").
//RUNPATH("GETMODULES").
//RUNPATH("COMSAT_HEIGHT").
//RUNPATH("PID").
RUNPATH("DOONCE").
//RUNPATH("GETRESOURCES").
//RUNPATH("TRAJECTORY").
RUNPATH("FUNCTIONS").
RUNPATH("journal").

SET once_1 TO doOnce().
SET once_2 TO doOnce().
SET once_3 TO doOnce().

SET ship_log TO Journal().
SET loops TO 5.
SET i TO 0.

function testStage{
	print "this function should run twice".
}
function testWParam{
	parameter param TO 0.
	print "this function have param passed that is different than 0: " + param[0].
}

UNTIL i > loops{
	PRINT i.
	once_1["do"]({ 
		//print "once 1 call on loop: "+i.
		//SET dV_change TO calcDeltaV(700000).
		//PRINT dV_change.
	}).
	//once_2["do"](testStage@).
	//once_3["do"](testWParam@, LIST("test parameter")).

	IF(i = 3){
		//once_2["reset"]().
	}
	SET i TO i + 1.
	wait 0.5.
	ship_log["add"]("test"+i).
}
ship_log["save"]().
