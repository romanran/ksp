RUNONCEPATH("0:lib/getModules_f").
RUNONCEPATH("0:lib/COMSAT_HEIGHT").
RUNONCEPATH("0:lib/PID").
RUNONCEPATH("0:lib/GETRESOURCES_f").
RUNONCEPATH("0:lib/TRAJECTORY").
CLEARSCREEN.
SET TERMINAL:CHARWIDTH TO 16.
SET TERMINAL:CHARHEIGHT TO 18.
SET TERMINAL:WIDTH TO 30.
SET TERMINAL:HEIGHT TO 40.
SET trgt TO GetTrgtAlt(3, 100000).
PRINT "V0.9".
PRINT "Comm range:"+trgt["r"]+"m.".
PRINT "Target altitude:"+trgt["alt"]+"m.".
SET g TO KERBIN:MU/KERBIN:RADIUS^2.
SET s TO FALSE.
UNLOCK PIDC.
SET PIDC to setPID(0, 1).
SET PIDC:MAXOUTPUT TO 1.
SET PIDC:MINOUTPUT TO 0.
SET thrott TO 0.
SET trgt_pitch TO 0.
SET gf TO 0.
SET trgtG TO 0.

SET THROTTLE TO 0.

SET ship_engines TO LIST().

SET done TO false.
SET doneThrust TO false.
SET doneGravTurn TO false.
SET doneStaging TO false.

SET once_thrott TO true.

SET once_thrott2 TO true.
SET once_pitch TO true.
SET once_pitch2 TO true.
SET doonce1 TO true.
SET doonce2 TO true.
SET doonce3 TO true.
SET doonce5 TO true.
SET show_circ TO true.
SET circuralise TO false.
SET bulka TO 0.

SET warpToApopsis TO false.
SET wait_ready to true.
SET wait_ready2 to true.
set wait_stage to 99999.
SET timer3 TO TIME:SECONDS.
LOCK target_press TO MAX(((-SHIP:ALTITUDE+40000)/40000)*10, 1) .
SET s TO FALSE.
LOG TIME + "MISSION START - "+SHIP TO flightlog.txt.
PRINT "WAITING FOR START...".
ON AG1{
	SET s TO TRUE.
}
WAIT UNTIL S = TRUE.
UNTIL done{
	CLEARSCREEN.
	IF doneThrust = false{
		CLEARSCREEN.
		IF once_thrott{
			SET pid_timer TO TIME:SECONDS.
			LOCK THROTTLE TO thrott.
			LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
			LOCK gf TO ROUND(accvec:MAG/g, 3).
			LOCK dyn_p TO ROUND(SHIP:Q*CONSTANT:ATMtokPa, 3).
			LOCK trgtG TO MIN(1.2+ROUND(SHIP:ALTITUDE/40000,2)*3, 3).
			LOCK thrott TO MAX(ROUND(PIDC:UPDATE(TIME:SECONDS-pid_timer, dyn_p), 3), 0.01).
			LOCK ship_p TO 90 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR).
			SET once_thrott TO false.
			SET doonce4 TO true.
			IF SHIP:ALTITUDE<100{
				STAGE.
				SET stg_res TO getResources().
			}
		}
		PRINT "THROTTLE: " at(0,1).
		PRINT thrott at(18,1).
		PRINT "G-force: " at (0,2).
		PRINT gf at(18,2).
		PRINT "Target pressure:" at(0,4).
		PRINT target_press  at(18,4).
		PRINT "Dynamic Pressure:" at(0,5).
		PRINT dyn_p at(18,5).
		IF SHIP:SOLIDFUEL=0{
			SET PIDC:SETPOINT TO target_press.
		}

		IF (ROUND(APOAPSIS) > trgt["alt"] - 200000) AND bulka<1 AND SHIP:ALTITUDE>50000 {
			HUDTEXT("Slowing down", 2, 2, 42, green, false).
			LOG TIME + "slowing down procedure" TO flightlog.txt.
			COPYPATH("flightlog.txt", "0:log").
			UNLOCK PIDC.
			UNLOCK thrott.
			LOCK THROTTLE TO TAN(1-(APOAPSIS/trgt["alt"])).
			SET doonce4 TO false.
			SET bulka TO bulka + 1.
		}
		IF (ROUND(APOAPSIS) > trgt["alt"] - 50) AND SHIP:ALTITUDE>70000{
			LOG TIME + "PHASE 1 Completed" TO flightlog.txt.
			COPYPATH("flightlog.txt", "0:log").
			LOCK THROTTLE TO 0.
			UNLOCK trgtG.
			HUDTEXT("PHASE 1 Completed", 2, 2, 42, green, false).
			CLEARSCREEN.
			SET timer3 TO TIME:SECONDS.
			SET doneThrust TO true.
			SET warpToApopsis TO true.
			SET circuralise TO true.
		}
	}
	IF warpToApopsis{
		IF TIME:SECONDS > (timer3 + 2){
			HUDTEXT("WARPING", 2, 2, 42, green, false).
			SET WARPMODE TO "RAILS".
			SET WARP TO 4.
			IF ETA:APOAPSIS<1000{
				SET WARP TO 2.
			}
			IF ETA:APOAPSIS < 120 AND ETA:APOAPSIS <> 0{
				SET WARP TO 0.
				SET warpToApopsis TO false.
			}
		}
	}
	IF doneStaging=false{
		IF STAGE:LIQUIDFUEL=0 AND stg_res:HASKEY("LIQUIDFUEL") {
			IF wait_ready = true{
				LIST ENGINES IN ship_engines.
				SET wait_stage to TIME:SECONDS.
				SET wait_ready TO false.
				FOR eng IN ship_engines{
					eng:SHUTDOWN.
				}
				HUDTEXT("OUT OF LIQUID FUEL, SEPARATING", 2, 2, 42, green, false).
				STAGE.
				SET stg_res TO getResources().
				LOG "next stage---" TO flightlog.txt.
				LOG stg_res TO flightlog.txt.
				FOR eng IN ship_engines{
					eng:ACTIVATE.
				}
			}
		}
		IF TIME:SECONDS > (wait_stage + 2){
			SET wait_ready TO true.
			IF STAGE:SOLIDFUEL=0 AND stg_res:HASKEY("SOLIDFUEL"){
				STAGE.
				SET stg_res TO getResources().
			}
		}
		IF STAGE:SOLIDFUEL=0 AND stg_res:HASKEY("SOLIDFUEL"){
			HUDTEXT("OUT OF SOLID FUEL, STAGING, RESETTING PID", 5, 2, 42, green, false).
			SET pid_timer TO TIME:SECONDS.
			PIDC:RESET.
			IF wait_ready = true{
				SET wait_stage to TIME:SECONDS.
				SET wait_ready TO false.
			}
		}
	}
	IF doneGravTurn=false{
		IF once_pitch{
			LOCK trgt_pitch TO MAX(0, calcTrajectory(SHIP:ALTITUDE)).
			LOCK STEERING TO HEADING (0, trgt_pitch).
			SET once_pitch TO false.
		}
		IF trgt_pitch > 89 AND once_pitch2{
			UNLOCK STEERING.
			SET once_pitch2 TO false.
			SET doneGravTurn TO true.
		}
		PRINT "Target PITCH: " at(0,3).
		PRINT trgt_pitch at(18,3).
	}
	IF ALTITUDE > 70000 {
		IF doonce4=true{
			SET fairing TO GETMODULES("ModuleProceduralFairing").
			IF fairing:LENGTH > 0{
				FOR fpart IN fairing:VALUES {
					fpart:GETMODULE("ModuleProceduralFairing"):DOEVENT("DEPLOY").
				}
			}ELSE{
				HUDTEXT("NO FAIRINGS DETECTED", 2, 2, 42, RGB(255,60,0), false).
			}
			SET wait_rcs to TIME:SECONDS.
			SET doonce4 TO FALSE.
		}
		IF TIME:SECONDS > wait_rcs+3 AND doonce3=true{
			RCS ON.
			SET doonce3 TO false.
		}
	}
	IF ALTITUDE > 80000{
		IF doonce1=true{
			SET doonce1 TO false.
			PANELS ON.
		}
		IF wait_ready2 = true{
			SET wait_ready2 TO false.
			SET wait_deploy to TIME:SECONDS.
		}
		IF TIME:SECONDS > (wait_deploy + 3) AND doonce2{
			SET doonce2 TO false.
			LIGHTS ON.
			SET antennas TO GETMODULES("ModuleRTAntenna").
			IF antennas:LENGTH > 0{
				HUDTEXT("DEPLOYING ANTENNAS", 2, 2, 42, RGB(55,255,0), false).
				FOR ant IN antennas:VALUES {
					SET ant1 TO ant:GETMODULE("ModuleRTAntenna").
					ant1:DOEVENT("ACTIVATE").
					IF ant:HASSUFFIX("SETFIELD"){
						ant1:SETFIELD("target", "Mission Control").
					}
					IF ant:HASSUFFIX("target"){
						ant1:TARGET("Mission Control").
					}
					LOG ant1:SUFFIXNAMES TO suffixesforant.txt.
				}
			}ELSE{
				HUDTEXT("NO ANTENNAS DETECTED", 2, 2, 42, RGB(255,60,0), false).
			}
		}
	}
	IF ship_p < 0 AND SHIP:ALTITUDE < 40000{
		SET doneThrust TO true.
		LOCK THROTTLE TO 0.
		HUDTEXT("MALFUNCTION ABORT", 5, 2, 54, red, false).
	}
	IF circuralise{
		IF TIME:SECONDS > (timer3 + 3){
			IF show_circ{
				HUDTEXT("CIRCURALISATION...", 3, 2, 42, RGB(10,225,10), false).
				SET show_circ to false.
			}
			LOCK STEERING TO PROGRADE.
			IF SHIP:VERTICALSPEED < 1 AND doonce5{
				HUDTEXT("CIRC BURN!", 3, 2, 42, RGB(230,155,10), false).
				LOG TIME + "CIRC BURN." TO flightlog.txt.
				//COPY flightlog.txt TO 0.
				SET thrott2 TO 0.
				SET vs_PID to setPID(0).
				SET timer2 TO TIME:SECONDS.
				LOCK thrott2 TO ROUND(vs_PID:UPDATE(TIME:SECONDS-timer2, SHIP:VERTICALSPEED), 3).
				LOCK THROTTLE to thrott2.
				SET doonce5 TO false.
			}
			WHEN PERIAPSIS-2>APOAPSIS THEN{
				UNLOCK thrott2.
				SET thrott2 TO 0.
				SET circuralise TO false.
				HUDTEXT("CIRCURALISATION COMPLETE", 3, 2, 42, RGB(10,225,10), false).
			}
		}
	}
	SET done TO false.
	WAIT 0.
}

PRINT "PROGRAM EXECUTED".
