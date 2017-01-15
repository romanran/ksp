PRINT "TEST START...".

//COPYPATH("0:lib/GETMODULES", "1:").
//COPYPATH("0:lib/COMSAT_HEIGHT", "1:").
//COPYPATH("0:lib/PID", "1:").
COPYPATH("0:lib/DOONCE", "1:").
//COPYPATH("0:lib/GETRESOURCES_f", "1:").
//COPYPATH("0:lib/TRAJECTORY", "1:").
//COPYPATH("0:lib/FUNCTIONS", "1:").
//RUNPATH("GETMODULES").
//RUNPATH("COMSAT_HEIGHT").
//RUNPATH("PID").
RUNPATH("DOONCE").
//RUNPATH("GETRESOURCES").
//RUNPATH("TRAJECTORY").
//RUNPATH("FUNCTIONS").

SET once_1 TO doOnce().
SET once_2 TO doOnce().
SET once_3 TO doOnce().

SET loops TO 5.
SET i TO 0.

function testStage{
	print "this function should run twice".
}
function testWParam{
	parameter param TO 0.
	print "this function have param passed that is different than 0: " + param.
}

UNTIL i > loops{
	PRINT i.
	once_1["do"]({ print "once 1 call on loop: "+i.}).
	once_2["do"](testStage@).
	once_3["do"](testWParam@, "test parameter").

	IF(i = 3){
		once_2["reset"]().
	}
	SET i TO i + 1.
	wait 0.5.
}
