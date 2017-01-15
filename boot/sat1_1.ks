IF ADDONS:RT:HASKSCCONNECTION(ship){
	COPYPATH("0:lib/GETMODULES", "1:").
	COPYPATH("0:lib/COMSAT_HEIGHT", "1:").
	COPYPATH("0:lib/PID", "1:").
	COPYPATH("0:lib/DOONCE", "1:").
	COPYPATH("0:lib/GETRESOURCES_f", "1:").
	COPYPATH("0:lib/TRAJECTORY", "1:").
	COPYPATH("0:lib/FUNCTIONS", "1:").
}
RUNPATH("GETMODULES").
RUNPATH("COMSAT_HEIGHT").
RUNPATH("PID").
RUNPATH("DOONCE").
RUNPATH("GETRESOURCES").
RUNPATH("TRAJECTORY").
RUNPATH("FUNCTIONS").

// * TODO*
// set states in root part tag and check status from there
// add sats cloud, next launched sat takes orbital period of previous sats and aims for the same orbital period
// states
// write getNearestPart library for staging purposes 
// if energy low, start fuel cell

SET root_part TO SHIP:ROOTPART.

CLEARSCREEN.
SET TERMINAL:CHARWIDTH TO 10.
SET TERMINAL:CHARHEIGHT TO 12.
SET TERMINAL:WIDTH TO 37.
SET TERMINAL:HEIGHT TO 25.
SET trgt TO GetTrgtAlt(3, 100000).

SET done TO false.

IF(SHIP:PRELAUNCH){
	PRINT "V1.0".
	PRINT "Comm range:"+trgt["r"]+"m.".
	PRINT "Target altitude:"+trgt["alt"]+"m.".
	SET g TO KERBIN:MU/KERBIN:RADIUS^2.
	SET s TO FALSE.
	UNLOCK PIDC.
	SET PIDC to setPID(0, 1).
	SET PIDC:MAXOUTPUT TO 1.
	SET PIDC:MINOUTPUT TO 1.
	PRINT calcDeltaV(1000).
	SET thrott TO 1.
	SET trgt_pitch TO 0.
	SET gf TO 0.

	SET chronos TO PROCESSOR("chronos").
	SET THROTTLE TO 0.

	SET ship_engines TO LIST().
	LIST ENGINES IN ship_engines.

	SET doneThrust TO false.
	SET doneGravTurn TO false.
	SET doneStaging TO false.

	SET pid_1s TO doOnce.
	SET pitch_1s TO true.
	SET once_pitch2 TO true.
	//add once objects
	SET set_throttle_1s TO doOnce.
	SET panels_1s TO doOnce.
	SET antennas_1s TO doOnce.
	SET fairing_1s TO doOnce.
	SET rcs_1s TO doOnce.
	SET circ_prepare_1s TO doOnce.
	SET circ_burn_1s TO doOnce.
	SET abort_1s IS doOnce.
	SET show_circ TO true.
	SET circuralise TO false.
	SET bulka TO 0.

	SET warpToApopsis TO false.
	SET wait_ready to true.
	SET wait_ready2 to true.

	SET timer3 TO TIME:SECONDS.
	LOCK target_press TO MAX(((-SHIP:ALTITUDE+40000)/40000)*10, 1).
	SET PIDC:SETPOINT TO target_press.
	SET s TO FALSE.

	LOG TIME + "MISSION START - "+SHIP TO flightlog.txt.
	PRINT "WAITING FOR START...".
	SET first_stage_engines TO LIST().
	SET antennas TO getModules("ModuleRTAntenna").
	LOCAL last_eng_i TO 0.
	FOR eng IN ship_engines{
		IF eng:STAGE > last_eng_i{
			SET last_eng_i TO eng:STAGE.
		}
	}
	FOR eng IN ship_engines{
		IF eng:STAGE = last_eng_i{
			first_stage_engines:ADD(eng).
		}
	}

	SET ksc_light TO SHIP:PARTSTAGGED("ksc_light").
	IF ksc_light:LENGTH > 0{
		SET ksc_m_light TO ksc_light[0]:GETMODULE("modulelight").
	}
	ON AG1{
		if ksc_light:LENGTH > 0{
			ksc_light[0]:GETMODULE("modulelight"):DOACTION("togglelight", true).
		}
		SET s TO TRUE.
	}
	PRINT "SYSTEMS READY".
	WAIT UNTIL S = TRUE.

	FROM{ LOCAL i is 5.} UNTIL i = 0 STEP { SET i TO i-1.} DO{
		IF i = 0{
			HUDTEXT(i+"LIFTOFF!", 1, 2, 40, green, false).
		}ELSE{
			HUDTEXT(i+"...", 1, 2, 30, green, false).
		}
		IF i = 4{
			LOCK THROTTLE TO 1.
		}
		WAIT 1.
		IF i = 2 {
			FOR eng IN first_stage_engines{
				eng:ACTIVATE.
			}
		}
	}

	CLEARSCREEN.
}
UNTIL done{
	ON AG5{
		doStage().
	}
	IF doneThrust = false{
		set_throttle_1s["do"]({
			SET pid_timer TO TIME:SECONDS.
			LOCK THROTTLE TO thrott.
			LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
			LOCK gf TO ROUND(accvec:MAG/g, 3).
			LOCK dyn_p TO ROUND(SHIP:Q*CONSTANT:ATMtokPa, 3).
			LOCK thrott TO MAX(ROUND(PIDC:UPDATE(TIME:SECONDS-pid_timer, dyn_p), 3), 0.01).
			LOCK ship_p TO 90 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR).
			SET once_thrott TO false.
			IF SHIP:ALTITUDE<100{
				doStage().
			}
			CLEARSCREEN.
		}).
		IF RADAR:ALT > 150 {
			pid_1s["do"]({
				SET set_pid TO false.
				SET pid_timer TO TIME:SECONDS.
				SET PIDC:MINOUTPUT TO 0.
				PIDC:RESET.
				//SET PIDC:MAXOUTPUT TO 1.
				//SET PIDC:SETPOINT TO target_press.
			}).
		}
		SET PIDC:SETPOINT TO target_press.
		PRINT "THROTTLE: " at(0,1).
		PRINT thrott at(18,1).
		PRINT "G-force: " at (0,2).
		PRINT gf at(18,2).
		PRINT "Target pressure:" at(0,4).
		PRINT target_press  at(18,4).
		PRINT "Dynamic Pressure:" at(0,5).
		PRINT dyn_p at(18,5).

		IF (ROUND(APOAPSIS) > trgt["alt"] - 200000) AND bulka<1 AND SHIP:ALTITUDE>50000 {
			HUDTEXT("Slowing down", 2, 2, 42, green, false).
			LOG TIME + "slowing down procedure" TO flightlog.txt.
			UNLOCK PIDC.
			UNLOCK thrott.
			LOCK THROTTLE TO MIN( TAN( CONSTANT:Radtodeg*(1-(APOAPSIS/trgt["alt"]))*5 ), 1).
			SET bulka TO bulka + 1.
		}
		IF ROUND(APOAPSIS) >= trgt["alt"] AND SHIP:ALTITUDE>70000{
			LOG TIME + "PHASE 1 Completed" TO flightlog.txt.
			LOCK THROTTLE TO 0.
			HUDTEXT("PHASE 1 Completed", 2, 2, 42, green, false).
			CLEARSCREEN.
			SET timer3 TO TIME:SECONDS.
			SET doneThrust TO true.
			SET warpToApopsis TO true.
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
			IF ETA:APOAPSIS < 60 AND ETA:APOAPSIS <> 0{
				SET WARP TO 0.
				SET warpToApopsis TO false.
				SET circuralise TO true.
			}
		}
	}
	IF doneStaging=false{
		IF STAGE:LIQUIDFUEL < 1 AND stg_res:HASKEY("LIQUIDFUEL"){
			//FOR eng IN ship_engines{
				//eng:SHUTDOWN.
			//}
			chronos:CONNECTION:SENDMESSAGE(5).
			HUDTEXT("OUT OF LIQUID FUEL", 1, 2, 42, green, false).

			IF NOT CORE:MESSAGES:EMPTY{
				SET is_done TO CORE:MESSAGES:POP.
				IF is_done:CONTENT = "done"{
					HUDTEXT("SEPARATING...", 1, 2, 42, green, false).
					doStage().
					CLEARSCREEN.
					LOG "next stage---" TO flightlog.txt.
					LOG stg_res TO flightlog.txt.
					//FOR eng IN ship_engines{
					//	eng:ACTIVATE.
					//}
				}
			}
		}
		IF STAGE:SOLIDFUEL < 0.1 AND stg_res:HASKEY("SOLIDFUEL"){
			HUDTEXT("OUT OF SOLID FUEL, STAGING, RESETTING PID", 3, 2, 42, green, false).
			SET pid_timer TO TIME:SECONDS.
			PIDC:RESET.
			SET pid_1s["reset"]().
			doStage().
		}
	}
	IF doneGravTurn=false{
		pitch_1s["do"]({
			LOCK trgt_pitch TO MAX(0, calcTrajectory(SHIP:ALTITUDE)).
			LOCK STEERING TO HEADING (0, trgt_pitch).
		})
		IF trgt_pitch > 89 AND once_pitch2{
			UNLOCK STEERING.
			SET once_pitch2 TO false.
			SET doneGravTurn TO true.
		}
		PRINT "Target PITCH: " at(0,3).
		PRINT trgt_pitch at(18,3).
	}
	IF ALTITUDE > 40000 AND STAGE:LIQUIDFUEL < 5 {
		fairing_1s["do"]({
			SET fairing TO getModules("ModuleProceduralFairing").
			IF fairing:LENGTH > 0{
				FOR fpart IN fairing:VALUES {
					fpart:GETMODULE("ModuleProceduralFairing"):DOEVENT("DEPLOY").
				}
			}ELSE{
				HUDTEXT("NO FAIRINGS DETECTED", 2, 2, 42, RGB(255,60,0), false).
			}
			SET wait_rcs to TIME:SECONDS.
		}).
	}
	IF ALTITUDE > 80000{
		panels_1s["do"]({PANELS ON.}).
		IF wait_ready2 = true{
			SET wait_ready2 TO false.
			SET wait_deploy to TIME:SECONDS.
		}
		IF TIME:SECONDS > (wait_deploy + 3){
			antennas_1s["do"]({
			LIGHTS ON.
				SET antennas TO getModules("ModuleRTAntenna").
				IF antennas:LENGTH > 0{
					HUDTEXT("DEPLOYING ANTENNAS", 2, 2, 42, RGB(55,255,0), false).
					FOR ant IN antennas:VALUES{
						SET ant1 TO ant:GETMODULE("ModuleRTAntenna").
						IF ant1:HASEVENT("ACTIVATE"){
							ant1:DOEVENT("ACTIVATE").
							chronos:CONNECTION:SENDMESSAGE(5).
						}
					}
				}ELSE{
					HUDTEXT("NO ANTENNAS DETECTED", 2, 2, 42, RGB(255,60,0), false).
				}
			}
		}

		IF NOT CORE:MESSAGES:EMPTY{
			SET is_done TO CORE:MESSAGES:POP.
			IF is_done:CONTENT = "done"{
				FOR ant IN antennas:VALUES {
					SET ant1 TO ant:GETMODULE("ModuleRTAntenna").
					IF ADDONS:RT:HASKSCCONNECTION(ship){
						COPYPATH("flightlog.txt", "0:log").
					}else{
						chronos:CONNECTION:SENDMESSAGE(50).
					}
				}
			}
		}
	}
	IF ship_p < 0 AND ALTITUDE < 40000{
		abort_1s["do"]({
			SET doneThrust TO true.
			LOCK THROTTLE TO 0.
			HUDTEXT("MALFUNCTION ABORT", 5, 2, 54, red, false).
		}).
	}
	IF circuralise{
		rcs_1s["do"]({
			RCS ON.
		}).
		IF TIME:SECONDS > (timer3 + 3){
			circ_prepare_1s["do"]({
				HUDTEXT("CIRCURALISATION...", 3, 2, 42, RGB(10,225,10), false).
				SET STEERING TO HEADING (0, -5).
				SET thrott2 TO 1.
				
				SET deltaV_change TO calcDeltaV(trgt["alt"]).
				SET burn_time TO calcBurnTime(deltaV_change).
			}).
			
			IF ETA:APOAPSIS <= burn_time/2{
				circ_burn_1s["do"]({
					HUDTEXT("CIRC BURN!", 3, 2, 42, RGB(230,155,10), false).
					SET pid_timer TO TIME:SECONDS.
					LOCK thrott2 TO 1-(PERIAPSIS^4/trgt["alt"]^4).
					SET circ_pid to setPID(trgt["alt"], 0.6).
					LOCK trgt_pitch TO ROUND(circ_pid:UPDATE(TIME:SECONDS-pid_timer, APOAPSIS), 3).
					LOCK THROTTLE to thrott2.
					LOCK STEERING TO HEADING (0, trgt_pitch).
				}).	
			}
			WHEN FLOOR(PERIAPSIS) = FLOOR(APOAPSIS) THEN{
				UNLOCK thrott2.
				SET thrott2 TO 0.
				SET circuralise TO false.
				HUDTEXT("CIRCURALISATION COMPLETE", 3, 2, 42, RGB(10,225,10), false).
			}
			PRINT "THROTTLE: " at(0,1).
			PRINT thrott2 at(18,1).
		}
	}

	WAIT 0.
}

PRINT "PROGRAM EXECUTED".
