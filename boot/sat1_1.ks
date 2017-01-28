IF ADDONS:RT:HASKSCCONNECTION( SHIP ){
	COPYPATH("0:lib/COMSAT_HEIGHT", "1:").
	COPYPATH("0:lib/PID", "1:").
	COPYPATH("0:lib/DOONCE", "1:").
	COPYPATH("0:lib/FUNCTIONS", "1:").
}
RUNPATH("COMSAT_HEIGHT").
RUNPATH("PID").
RUNPATH("DOONCE").
RUNPATH("FUNCTIONS").
// * TODO*
//- set states in root part tag and check status from there
// add sats cloud, next launched sat takes orbital period of previous sats and aims for the same orbital period
// write getNearestPart library for staging purposes 
// if energy low, start fuel cell
//rotate craft with pid for maximum sun exposure
//check for gimbals, if there are non in current stage,  enable RCS while in vacuum, or vernier engines while in atmosphere
//make program creator, move all of the ifs to function and load them on program checklist.
//save created programs in json

SET root_part TO SHIP:ROOTPART.
SET THROTTLE TO 0. //safety measure for float point values of throttle when loading from a save

CLEARSCREEN.
SET TERMINAL:CHARWIDTH TO 10.
SET TERMINAL:CHARHEIGHT TO 12.
SET TERMINAL:WIDTH TO 37.
SET TERMINAL:HEIGHT TO 25.
SET trgt TO GetTrgtAlt(3, 100000).

SET done TO false.
SET done_staging TO false.
SET from_save TO true. //this value will be false, if a script runs from the launch of a ship. If ship is loaded from a save, it will be set to true.
SET chronos TO PROCESSOR("chronos").

SET deploy_1s TO doOnce().
SET antennas_1s TO doOnce().
SET fairing_1s TO doOnce().
SET rcs_1s TO doOnce().
SET circ_prepare_1s TO doOnce().
SET circ_burn_1s TO doOnce().
SET de_acc_1s TO doOnce().
SET abort_1s TO doOnce().
SET warp_1s TO doOnce().

IF SHIP:STATUS = "PRELAUNCH"{
	PRINT "V1.3".
	PRINT "Comm range:"+trgt["r"]+"m.".
	PRINT "Target altitude:"+trgt["alt"]+"m.".
	SET start TO false.
	SET done TO true.

	UNLOCK PIDC.
	SET from_save TO false.
	SET PIDC to setPID(0, 1).
	SET PIDC:MAXOUTPUT TO 1.
	SET PIDC:MINOUTPUT TO 1.
	SET thrott TO 1.
	SET trgt_pitch TO 0.
	SET safe_alt TO 150.
	
	SET ship_engines TO LIST().
	LIST ENGINES IN ship_engines.

	SET stg TO LEXICON().
	SET stg_res TO LEXICON().
	SET ship_res TO getResources().
	PRINT ship_res["ELECTRICCHARGE"]:AMOUNT.

	//add once objects
	SET set_throttle_1s TO doOnce().

	LOCK target_kpa TO MAX(((-ALTITUDE+40000)/40000)*10, 1).
	SET PIDC:SETPOINT TO target_kpa.

	SET first_stage_engines TO LIST().
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
		SET start TO TRUE.
	}
	PRINT "ALL SYSTEMS ARE GO.".
	PRINT "AWAITING LAUNCH CONFIRMATION ON AG1...".
	PRINT "ABORT ON AG3...".
	WAIT UNTIL start = TRUE.

	FROM{ LOCAL i IS 5.} UNTIL i < 1 STEP { SET i TO i-1.} DO{
		WAIT 1.
		IF i = 1{
			HUDTEXT("LIFTOFF!", 1, 2, 40, green, false).
		}ELSE{
			HUDTEXT(i+"...", 1, 2, 30, green, false).
		}
		IF i = 1{
			SET root_part:TAG TO "LIFTOFF".
			SET done TO false.
		}
		IF i = 4{
			LOCK THROTTLE TO 1.
		}
		ON AG3{
			if ksc_light:LENGTH > 0{
				ksc_light[0]:GETMODULE("modulelight"):DOACTION("togglelight", false).
			}
			reboot.
		}
		IF i = 2 {
			FOR eng IN first_stage_engines{
				eng:ACTIVATE.
			}
		}
	}

	CLEARSCREEN.
}
LOCK ship_p TO 90 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR).
LOCAL pid_timer IS TIME:SECONDS.
LOCAL antennas IS getModules("ModuleRTAntenna").

IF from_save = true{
	SET stg_res TO getStageResources().
	SET ship_res TO getResources().
	SET rcs_1s TO doOnce().
	SET deploy_1s TO doOnce().
	SET antennas_1s TO doOnce().
}

UNTIL done{
	ON AG5{
		//stage override, just in case
		doStage().
	}
	IF root_part:TAG = "LIFTOFF" OR root_part:TAG = "THRUSTING"{
		set_throttle_1s["do"]({
			SET pitch_1s TO doOnce().
			SET pid_1s TO doOnce().
			SET pid_timer TO TIME:SECONDS.
			SET printer_timer TO TIME:SECONDS.
			LOCK THROTTLE TO thrott.
			LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
			LOCK dyn_p TO ROUND(SHIP:Q*CONSTANT:ATMtokPa, 3).
			LOCK thrott TO MAX(ROUND(PIDC:UPDATE(TIME:SECONDS-pid_timer, dyn_p), 3), 0.01).
			SET once_thrott TO false.
			SET stg TO doStage().
			SET done_staging TO stg["done"].
			SET stg_res TO stg["res"].
			SET root_part:TAG TO "THRUSTING".
			CLEARSCREEN.
		}).
		
		pitch_1s["do"]({
			LOCK trgt_pitch TO MAX(0, calcTrajectory(SHIP:ALTITUDE)).
			LOCK STEERING TO HEADING (0, trgt_pitch).
		}).
		
		IF ALT:RADAR > safe_alt {
			pid_1s["do"]({
				//reset pid from initial safe altitude gain 100% thrust
				SET set_pid TO false.
				SET pid_timer TO TIME:SECONDS.
				SET PIDC:MINOUTPUT TO 0.
				PIDC:RESET.
			}).
		}
		
		SET PIDC:SETPOINT TO target_kpa.
		PRINT "THR" at(0,1).
		PRINT thrott at(10,1).
		PRINT "T.PIT: " at(0,2).
		PRINT trgt_pitch at(10,2).
		PRINT "kPa:" at(0,3).
		PRINT target_kpa  at(10,3).
		PRINT "T.kPa:" at(0,4).
		PRINT dyn_p at(10,4).
		
		IF printer_timer +1 = TIME:SECONDS {
			HUDTEXT("THR: "+ROUND(thrott), 1, 3, 12, green, false).
			HUDTEXT("T. kPa: "+ROUND(target_kpa), 1, 3, 12, green, false).
			HUDTEXT("kPa: "+ROUND(dyn_p), 1, 3, 12, green, false).
			HUDTEXT("PITCH: "+ (90 - VECTORANGLE(UP:VECTOR, FACING:FOREVECTOR)), 1, 3, 12, green, false).
			SET printer_timer TO TIME:SECONDS.
		}
			
		IF ship_p < 0 AND ALTITUDE < 40000{
			//if ship is off course
			abort_1s["do"]({
				LOCK THROTTLE TO 0.
				HUDTEXT("MALFUNCTION ABORT", 5, 2, 54, red, false).
			}).
		}
		
		IF (ROUND(APOAPSIS) > trgt["alt"] - 200000) AND ALTITUDE>50000 {
			//decrease acceleration to not to overshoot target apoapsis
			de_acc_1s["do"]({
				HUDTEXT("Decreasing acceleration", 2, 2, 42, green, false).
				UNLOCK PIDC.
				UNLOCK thrott.
				LOCK THROTTLE TO MIN( TAN( CONSTANT:Radtodeg*(1-(APOAPSIS/trgt["alt"]))*5 ), 1).
			}).
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
			}).
		}//eject fairing	
		
		IF ROUND(APOAPSIS) >= trgt["alt"] AND ALTITUDE>70000{
			LOCK THROTTLE TO 0.
			HUDTEXT("COAST TRANSITION", 4, 2, 42, green, false).
			CLEARSCREEN.
			//leaving thrusting section at that time
			SET root_part:TAG TO "COASTING".
		}
	}//--thrusting
	
	IF ALTITUDE > 80000 AND from_save = false{
		deploy_1s["do"]({
			PANELS ON.
			RADIATORS ON.
			SET wait_deploy to TIME:SECONDS.
		}).
		
		IF TIME:SECONDS > (wait_deploy + 3){
			antennas_1s["do"]({
				LIGHTS ON.
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
			}).
		}

		IF NOT CORE:MESSAGES:EMPTY{
			SET is_done TO CORE:MESSAGES:POP.
			IF is_done:CONTENT = "done"{
				FOR ant IN antennas:VALUES {
					SET ant1 TO ant:GETMODULE("ModuleRTAntenna").
					IF ADDONS:RT:HASKSCCONNECTION(ship){
						// copy flight log
					}else{
						chronos:CONNECTION:SENDMESSAGE(50).
					}
				}
			}
		}
	}//--vacuum, deploy panels and antennas, turn on lights
	
	IF root_part:TAG = "COASTING"{
		IF deploy_1s["get"]() > 0{
			warp_1s["do"]({
				HUDTEXT("WARPING", 2, 2, 42, green, false).
				SET WARPMODE TO "RAILS".
				WARPTO (TIME:SECONDS + ETA:APOAPSIS - 60).
			}).
		}
		IF ETA:APOAPSIS < 60 AND ETA:APOAPSIS <> 0{
			KUNIVERSE:TIMEWARP:CANCELWARP().
			SET root_part:TAG TO "KERBINJECTION".
		}
	}//--coasting
	
	IF (ship_res["ELECTRICCHARGE"]:AMOUNT / ship_res["ELECTRICCHARGE"]:CAPACITY)*100 < 10{
		//if below 10% of max ships capacity
		//electic charge saving and generation
		KUNIVERSE:TIMEWARP:CANCELWARP().
		RCS ON.
		SAS OFF.
		UNLOCK STEERING.
		PANELS ON.
		FUELCELLS ON.
	}
	
	IF done_staging=false{
		IF STAGE:LIQUIDFUEL < 1 AND stg_res:HASKEY("LIQUIDFUEL"){
			//FOR eng IN ship_engines{
				//eng:SHUTDOWN.
			//}
			chronos:CONNECTION:SENDMESSAGE(2).
			HUDTEXT("OUT OF LIQUID FUEL", 1, 2, 42, green, false).

			IF NOT CORE:MESSAGES:EMPTY{
				SET is_done TO CORE:MESSAGES:POP.
				IF is_done:CONTENT = "done"{
					HUDTEXT("SEPARATING...", 1, 2, 42, green, false).
					SET stg TO doStage().
					SET done_staging TO stg["done"].
					SET stg_res TO stg["res"].
					CLEARSCREEN.
				}
			}
		}
		IF STAGE:SOLIDFUEL < 0.1 AND stg_res:HASKEY("SOLIDFUEL"){
			HUDTEXT("OUT OF SOLID FUEL, STAGING, RESETTING PID", 3, 2, 42, green, false).
			SET pid_timer TO TIME:SECONDS.
			PIDC:RESET.
			pid_1s["reset"]().
			SET stg TO doStage().
			SET done_staging TO stg["done"].
			SET stg_res TO stg["res"].
		}
	}//--staging handler
	
	IF root_part:TAG = "KERBINJECTION"{
		rcs_1s["do"]({
			RCS ON.
		}).
		LOCAL burn_time IS -10. //dont fire until its calculated
		LOCAL dV_change IS 0.
		LOCAL thrott2 IS 0.
		circ_prepare_1s["do"]({
			HUDTEXT("CIRCURALISATION...", 3, 2, 42, RGB(10,225,10), false).
			SET STEERING TO HEADING (0, -5).		
			SET dV_change TO calcDeltaV(trgt["altA"]).
			PRINT "dv change: "+dV_change AT(0,5).
			SET burn_time TO calcBurnTime(dV_change).
			PRINT "t: "+burn_time AT(0,6).
			HUDTEXT(burn_time, 3, 3, 20, green, false).
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
		IF FLOOR(PERIAPSIS) = FLOOR(APOAPSIS){
			UNLOCK thrott2.
			UNLOCK STEERING.
			SET thrott2 TO 0.
			SET circuralise TO false.
			HUDTEXT("CIRCURALISATION COMPLETE", 3, 2, 42, RGB(10,225,10), false).
		}
		PRINT "THROTTLE: " at(0,1).
		PRINT thrott2 at(18,1).
	}//target orbit injection
	
	WAIT 0.
}
