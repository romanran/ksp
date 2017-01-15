CLEARSCREEN.
SET TERMINAL:WIDTH TO 38.
SET TERMINAL:HEIGHT TO 24.
SET TERMINAL:CHARWIDTH TO 16.
SET TERMINAL:CHARHEIGHT TO 18.
print "COUNTDOWN".
FROM {local c is 10.} until c = 0 Step {set c to c-1.} DO {
	print c at (0,0).
	wait 0.1.
}.
print "LIFTOFF!".