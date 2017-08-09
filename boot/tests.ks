DECLARE GLOBAL env TO "live".
PRINT "TEST START...".
//COPYPATH("0:lib/GETMODULES", "1:").
//COPYPATH("0:lib/COMSAT_HEIGHT", "1:").
//COPYPATH("0:lib/PID", "1:").
COPYPATH("0:lib/DOONCE", "1:").
//COPYPATH("0:lib/GETRESOURCES_f", "1:").
//COPYPATH("0:lib/TRAJECTORY", "1:").
COPYPATH("0:lib/FUNCTIONS", "1:").
COPYPATH("0:lib/JOURNAL", "1:").
COPYPATH("0:lib/PROGRAM", "1:").
COPYPATH("0:lib/INQUIRY", "1:").
COPYPATH("0:lib/DISPLAYER", "1:").
//RUNPATH("GETMODULES").
//RUNPATH("COMSAT_HEIGHT").
//RUNPATH("PID").
RUNPATH("DOONCE").
//RUNPATH("GETRESOURCES").
//RUNPATH("TRAJECTORY").
RUNPATH("FUNCTIONS").
RUNPATH("Journal").
RUNPATH("INQUIRY").
RUNPATH("PROGRAM").
RUNPATH("DISPLAYER").

LOCAL Display TO Displayer().
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
SET pr TO Program().
SET prlist TO pr["list"]().
LOCAL pr_chooser TO LIST(
	LEXICON(
		"name", "program",
		"type", "select", 
		"msg", "Choose a program",
		"choices", prlist
	)
).
SET chosen_pr TO Inquiry(pr_chooser).
SET trgt_pr TO Program(chosen_pr["program"]).
SET trgt_pr TO trgt_pr["fetch"]().
SET trgt_vessel TO VESSEL(trgt_pr["vessels"][0]).
CS().
SET last_angle TO 0.
Display["imprint"](trgt_vessel:NAME).
Display["imprint"]().
UNTIL false {
	Display["reset"]().
	LOCAL radius_percent IS ROUND(260 / trgt_vessel:OBT:PERIOD, 3).
	LOCAL phase_ang IS calcPhaseAngle(600000 + ALTITUDE, trgt_vessel:ORBIT:SEMIMAJORAXIS / 2).
	SET curr_angle TO calcAngleFromVec(SHIP:UP:STARVECTOR, trgt_vessel:UP:STARVECTOR).
	SET ahead TO false.
	IF curr_angle > last_angle {
		//target is ahead
		SET phase_ang TO - phase_ang.
	} 
	SET tphase_ang TO 360 / trgt_pr["attributes"]["sats"] + phase_ang.
	SET last_angle TO curr_angle.
	
	Display["print"]("Deegres spread:", 360 / trgt_pr["attributes"]["sats"]).
	Display["print"]("Deegres travelled:", 360 * radius_percent).
	Display["print"]("Target separation:", 360 * radius_percent +  360 / trgt_pr["attributes"]["sats"]).
	Display["print"]("Est. angle move:", phase_ang).
	Display["print"]().
	Display["print"]("Target phase angle:", tphase_ang).
	Display["print"]("Current phase angle:", curr_angle).
	WAIT 0.
}

//pr["add"]().
//PRINT pr["fetch"]().