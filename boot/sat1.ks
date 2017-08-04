@LAZYGLOBAL on.
DECLARE GLOBAL env TO "live".

function loadDeps {
	COPYPATH("0:lib/PID", "1:").
	COPYPATH("0:lib/DOONCE", "1:").
	COPYPATH("0:lib/TIMER", "1:").
	COPYPATH("0:lib/FUNCTIONS", "1:").
	COPYPATH("0:lib/JOURNAL", "1:").
	COPYPATH("0:lib/DISPLAYER", "1:").
	COPYPATH("0:lib/INQUIRY", "1:").
	COPYPATH("0:lib/PROGRAM", "1:").
}
IF ADDONS:AVAILABLE("RT") {
	IF ADDONS:RT:HASKSCCONNECTION(SHIP) {
		loadDeps().
	}
} ELSE IF HOMECONNECTION:ISCONNECTED {
	loadDeps().
}
CD("1:").
RUNONCEPATH("PID").
RUNONCEPATH("TIMER").
RUNONCEPATH("DOONCE").
RUNONCEPATH("FUNCTIONS").
RUNONCEPATH("DISPLAYER").
RUNONCEPATH("JOURNAL").
RUNONCEPATH("INQUIRY").
RUNONCEPATH("PROGRAM").
// * TODO*
//- set states in root part tag and check status from there
// add sats cloud, next launched sat takes orbital period of previous sats and aims for the same orbital period
// write getNearestPart library for staging purposes 
// -if energy low, start fuel cell
//- rotate craft with pid for maximum sun exposure
// check for gimbals, if there are non in current stage,  enable RCS while in vacuum, or vernier engines while in atmosphere
//- make program creator
// move all of the ifs to function and load them on program checklist. for example, in altiitude ifs, call a funtion "deployantennas", so the function can be called even from ground.
// save created programs in json
// check if comm range is within max ranges of antennas on board
// check different gravity turns slopes by comparing dV and resources used
// - if throttle is 0, thrust with RCS
// check all for the parts
// - check the programming for the second staging wait under no thrust
// - move journal to a separate volume

SET THROTTLE TO 0. //safety measure for float point values of throttle when loading from a save

CS().
SET TERMINAL:WIDTH TO 42.
SET TERMINAL:HEIGHT TO 30.
LOCAL Display TO Displayer().

SET SHIP:NAME TO generateID().
LOCAL ship_log TO Journal().

LOCAL ship_state IS ShipState().
LOCAL pr TO Program().
LOCAL prlist TO pr["list"]().
LOCAL chosen_pr TO "".
IF ship_state["state"]:HASKEY("programme") {
	SET chosen_pr TO ship_state["state"]["programme"].
} ELSE {
	LOCAL pr_chooser TO LIST(
		LEXICON(
			"name", "program",
			"type", "select", 
			"msg", "Choose a program",
			"choices", prlist
		)
	).
	SET chosen_pr TO Inquiry(pr_chooser).
	SET chosen_pr TO chosen_pr["program"].
	ship_state["set"]("programme", chosen_pr).
}
LOCAL trgt_pr TO pr["fetch"](chosen_pr).
LOCAL trgt IS getTrgtAlt(trgt_pr["attributes"]["sats"], trgt_pr["attributes"]["alt"]).

LOCAL done IS false.
LOCAL done_staging IS true. //we dont need to stage when on launchpad or if loaded from a save to already staged rocket
LOCAL from_save IS true. //this value will be false, if a script runs from the launch of a ship. If ship is loaded from a save, it will be set to true.

LOCAL ship_res IS getResources().
LOCAL deploy_1s IS doOnce().
LOCAL fairing_1s IS doOnce().
LOCAL rcs_1s IS doOnce().
LOCAL circ_prepare_1s IS doOnce().
LOCAL circ_burn_1s IS doOnce().
LOCAL de_acc_1s IS doOnce().
LOCAL abort_1s IS doOnce().
LOCAL stage_1s IS doOnce().
LOCAL warp_1s IS doOnce().
LOCAL circ_done_1s IS doOnce().
LOCAL set_throttle_1s TO doOnce().
LOCAL ant_Timer IS Timer().
LOCAL conn_Timer IS Timer().
LOCAL journal_Timer IS Timer().
LOCAL staging_Timer IS Timer().
LOCAL staging2_Timer IS Timer(). //for no acceleration staging wait
LOCAL nacc_Timer IS Timer(). //for no acceleration test once

LOCAL stg IS LEXICON().
LOCAL stg_res IS LEXICON().
LOCAL antennas IS LEXICON().
LOCAL antennasRT IS LEXICON().
LOCAL ship_engines IS LIST().

LOCAL trgt_pitch TO 0.
LOCAL thrott TO 0. //throttle
LOCAL safe_alt IS 150. //safe altitude to release max thrust during a launch
LOCAL target_kPa IS 1.
LOCAL burn_time IS -10. //dont fire until its calculated
LOCAL dV_change IS 0.
LOCAL accvec TO 0.
LOCAL dyn_p TO 0.
LOCAL g_base TO KERBIN:MU / KERBIN:RADIUS^2.

//--PRELAUNCH
IF SHIP:STATUS = "PRELAUNCH" {
	Display["imprint"]("Aurora Space Program V1.3.1").
	Display["imprint"](SHIP:NAME).
	Display["imprint"]("Comm range:", trgt["r"]+"m.").
	Display["imprint"]("Target altitude:", trgt["alt"]+"m.").
	Display["imprint"]("Target orbital period:", trgt["period"]+"s.").
	LOCAL start IS false.
	SET done TO true.

	UNLOCK PIDC.
	SET from_save TO false.
	SET PIDC to setPID(0, 1).
	SET PIDC:MAXOUTPUT TO 1.
	SET PIDC:MINOUTPUT TO 1.
	LOCAL trgt_pitch TO 0.
	LOCAL thrott TO 1.
	
	LIST ENGINES IN ship_engines.
	//add once objects

	LOCK target_kPa TO ROUND(MAX(((-ALTITUDE + 40000) / 40000) * 10, 1), 3).
	SET PIDC:SETPOINT TO target_kPa.

	LOCAL first_stage_engines IS LIST().
	LOCAL last_eng_i TO 0.
	FOR eng IN ship_engines{
		IF eng:STAGE > last_eng_i {
			SET last_eng_i TO eng:STAGE.
		}
	}
	FOR eng IN ship_engines{
		IF eng:STAGE = last_eng_i {
			first_stage_engines:ADD(eng).
		}
	}
	function preLaunchError {
		PARAMETER err.
		LOCAL Sounds TO GETVOICE(0).
		HUDTEXT(err, 5, 4, 40, red, false).
		Sounds:PLAY(NOTE(400, 0.1)).
		Display["print"](err).
		Display["print"]("REBOOT? AG2").
		WAIT UNTIL AG2. 
		REBOOT.
	}
	
	IF first_stage_engines:LENGTH = 0 {
		preLaunchError("COULDN'T FIND 1st STAGE ENGINES").
	}
	LOCAL sensors_list IS LIST().
	LOCAL sensors_types IS LIST().
	LIST SENSORS IN sensors_list.
	FOR S IN sensors_list {
		sensors_types:ADD(S:TYPE).
	}
	IF (NOT sensors_types:CONTAINS("acc")) {
		preLaunchError("No accelerometer detected on the vessel").
	}
	IF (NOT sensors_types:CONTAINS("grav")) {
		preLaunchError("No gravetometer detected on the vessel").
	}

	LOCAL ksc_light TO SHIP:PARTSTAGGED("ksc_light").
	IF ksc_light:LENGTH > 0{
		SET ksc_m_light TO ksc_light[0]:GETMODULE("modulelight").
	}
	ON AG1{
		if ksc_light:LENGTH > 0{
			ksc_light[0]:GETMODULE("modulelight"):DOACTION("togglelight", true).
		}
		SET start TO TRUE.
		ship_log["add"]("countdown start").
	}
	Display["print"]("ALL SYSTEMS ARE GO.").
	Display["print"]("AWAITING LAUNCH CONFIRMATION ON AG1").
	Display["print"]("ABORT ON AG3.").
	WAIT UNTIL start = TRUE.
	Display["print"]("COUNTDOWN START").
	FROM {LOCAL i IS 5.} UNTIL i = 0 STEP {SET i TO i - 1.} DO {
		WAIT 1.
		HUDTEXT(i + "...", 1, 2, 40, green, false).
		IF i = 4{
			LOCK THROTTLE TO 1.
		}
		ON AG3 {
			if ksc_light:LENGTH > 0 {
				ksc_light[0]:GETMODULE("modulelight"):DOACTION("togglelight", false).
			}
			reboot.
		}
		IF i = 1 {
			FOR eng IN first_stage_engines {
				eng:ACTIVATE.
			}
			HUDTEXT("Engines ingnition", 1, 2, 40, green, false).

			ship_state["set"]("phase", "TAKEOFF").
			SET done TO false.
		}
	}	
}

LOCAL ship_p TO 0.
LOCAL pid_timer IS TIME:SECONDS.
SET stg_res TO getStageResources().
SET ship_res TO getResources().

//--- MAIN FLIGHT BODY
UNTIL done {
	Display["reset"]().
	Display["print"]("Current phase", ship_state["state"]["phase"]).
	ON AG5 {
		//stage override, just in case
		SET stg TO doStage().
		staging_Timer["set"]().
		SET done_staging TO stg["done"].
		SET stg_res TO stg["res"].
		ship_log["add"]("manually staged").
	}
	IF done_staging=false {
		IF STAGE:LIQUIDFUEL < 1 AND stg_res:HASKEY("LIQUIDFUEL") {
			//FOR eng IN ship_engines{
				//eng:SHUTDOWN.
			//}
			stage_1s["do"]({
				staging_Timer["set"]().
				HUDTEXT("OUT OF LIQUID FUEL", 1, 2, 42, green, false).
				HUDTEXT("SEPARATING...", 2, 2, 42, green, false).
				SET stg TO doStage().
				SET done_staging TO stg["done"].
				SET stg_res TO stg["res"].
				
				ship_log["add"]("Stage " + STAGE:NUMBER + " - out of LF").
			}).
		}
		IF STAGE:SOLIDFUEL < 0.1 AND stg_res:HASKEY("SOLIDFUEL") {
			stage_1s["do"]({
				staging_Timer["set"]().
				HUDTEXT("OUT OF SOLID FUEL, STAGING, RESETTING PID", 6, 2, 42, green, false).
				SET pid_timer TO TIME:SECONDS.
				IF DEFINED PIDC{
					PIDC:RESET.
				}
				IF DEFINED pid_1s {
					pid_1s["reset"]().
				}
				SET stg TO doStage().
				SET done_staging TO stg["done"].
				SET stg_res TO stg["res"].
				ship_log["add"]("Stage " + STAGE:NUMBER + " - out of SF").
			}).
		}
		staging_Timer["ready"](2, {
			stage_1s["reset"]().
		}).
	}//--staging handler
	
	IF ship_state["state"]["phase"] = "TAKEOFF" OR ship_state["state"]["phase"] = "THRUSTING" {

		set_throttle_1s["do"]({
			LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
			SET pitch_1s TO doOnce().
			SET pid_1s TO doOnce().
			SET pid_timer TO TIME:SECONDS.
			LOCK THROTTLE TO thrott.
			LOCK ship_p TO 90 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR).
			LOCK dyn_p TO ROUND(SHIP:Q*CONSTANT:ATMtokPa, 3).
			LOCK thrott TO MAX(ROUND(PIDC:UPDATE(TIME:SECONDS-pid_timer, dyn_p), 3), 0.1).
			SET once_thrott TO false.
			SET stg TO doStage().
			SET done_staging TO stg["done"].
			SET stg_res TO stg["res"].
			ship_state["set"]("phase", "THRUSTING").
			nacc_Timer["set"]().
			HUDTEXT("TAKEOFF!", 1, 2, 40, green, false).
			
			ship_log["add"]("TAKEOFF").
			journal_Timer["set"]().
		}).
		
		LOCAL nunder_acc TO SHIP:ALTITUDE < 70000 AND accvec:MAG / g_base < 0.04.
		//if not under accel
		IF nunder_acc {
			nacc_Timer["ready"](4, {
				HUDTEXT("NO ACCELERATION DETECTED, WAITING FOR THRUST 3 SECONDS...", 3, 3, 20, red, false).
				staging2_Timer["set"]().
				nacc_Timer["set"]().
			}).
		}
		
		staging2_Timer["ready"](3, {
			HUDTEXT("Waited 3 SECONDS...", 3, 2, 20, blue, false).
			//if there is still no acceleration, staging must have no engines available, stage again
			Display["print"]("Accelerating", nunder_acc).
			IF nunder_acc {
				stage_1s["reset"]().
				HUDTEXT("Reset, do stage.", 3, 2, 20, green, false).
				stage_1s["do"]({
					SET stg TO doStage().
					SET done_staging TO stg["done"].
					SET stg_res TO stg["res"].
					staging_Timer["set"]().
					staging2_Timer["set"]().
					ship_log["add"]("Stage " + STAGE:NUMBER + " - no acceleration detected during the thrusting phase").
				}).
			}
		}).
		
		pitch_1s["do"]({
			LOCK trgt_pitch TO MAX(0, calcTrajectory(SHIP:ALTITUDE)).
			LOCK STEERING TO R(0, 0, 0) + HEADING(90, trgt_pitch).
		}).
		
		IF ALT:RADAR > safe_alt {
			pid_1s["do"]({
				//reset pid from initial safe altitude gain 100% thrust
				SET set_pid TO false.
				SET pid_timer TO TIME:SECONDS.
				SET PIDC:MINOUTPUT TO 0.
				PIDC:RESET.
				ship_log["add"]("Reached the safe altitude of "+safe_alt).
			}).
		}
		
		SET PIDC:SETPOINT TO target_kpa.
		Display["print"]("THR", thrott).
		Display["print"]("PITCH:", ROUND(90 - VECTORANGLE(UP:VECTOR, SHIP:FACING:FOREVECTOR), 3)).
		Display["print"]("T.PIT:", trgt_pitch).
		Display["print"]("kPa:", ROUND(dyn_p, 3)).
		Display["print"]("T.kPa:", target_kpa).
		Display["print"]("ACC:", ROUND(accvec:MAG / g_base, 3) + "G").
			
		IF (ship_p < 0 OR SHIP:VERTICALSPEED < 0) AND GROUNDSPEED < 2000 AND nacc_Timer["check"]() < 8 AND nacc_Timer["check"]() > 4{
			//if ship is off course when not achieved orbital speed yet and the staging wait isnt in progress
			abort_1s["do"]({
				LOCK THROTTLE TO 0.
				HUDTEXT("MALFUNCTION ABORT", 5, 2, 54, red, false).
				ABORT ON.
				UNLOCK STEERING.
				SET done TO true.
				ship_log["add"]("Course deviation - malfunction - abort").
			}).
		}
		
		IF (ROUND(APOAPSIS) > trgt["alt"] - 200000) AND ALTITUDE > 50000 {
			//decrease acceleration to not to overshoot target apoapsis
			de_acc_1s["do"]({
				HUDTEXT("Decreasing acceleration", 2, 2, 42, green, false).
				UNLOCK PIDC.
				UNLOCK thrott.
				LOCK THROTTLE TO MAX(MIN( TAN( CONSTANT:Radtodeg*(1-(APOAPSIS/trgt["alt"]))*5 ), 1), 0.1).
				ship_log["add"]("Deacceleration").
			}).
		}
		
		IF ALTITUDE > 30000 AND dyn_p < 2 {
			LOCAL fairing IS LEXICON().
			fairing_1s["do"]({
				SET fairing TO getModules("ModuleProceduralFairing").
				IF fairing:LENGTH > 0 {
					FOR fpart IN fairing:VALUES {
						fpart:GETMODULE("ModuleProceduralFairing"):DOEVENT("DEPLOY").
					}
					ship_log["add"]("Fairings jettison").
				} ELSE {
					HUDTEXT("NO FAIRINGS DETECTED", 2, 2, 42, RGB(255,60,0), false).
				}
			}).
		}//eject fairing	
		
		IF CEILING(APOAPSIS) >= trgt["alt"] AND ALTITUDE>70000 {
			LOCK THROTTLE TO 0.
			HUDTEXT("COAST TRANSITION", 4, 2, 42, green, false).
			
			//leaving thrusting section at that time
			ship_state["set"]("phase", "COASTING").
			ship_log["add"]("Transition to the coasting phase").
		}
	}//--thrusting
	
	IF ALTITUDE > 80000 AND from_save = false {
		deploy_1s["do"]({
			PANELS ON.
			RADIATORS ON.
			SET antennasRT TO getModules("ModuleRTAntenna").
			SET antennas TO getModules("ModuleDeployableAntenna").
			ant_Timer["set"]().
		}).
		
		IF ant_Timer["ready"](3, {
			LIGHTS ON.
			HUDTEXT("DEPLOYING ANTENNAS", 2, 2, 42, RGB(55,255,0), false).
			FOR ant IN antennasRT:VALUES {
				SET ant1 TO ant:GETMODULE("ModuleRTAntenna").
				IF ant1:HASEVENT("ACTIVATE") {
					ant1:DOEVENT("ACTIVATE").
				}
			}
			FOR ant IN antennas:VALUES {
				SET ant1 TO ant:GETMODULE("ModuleDeployableAntenna").
				IF ant1:HASEVENT("extend antenna") {
					ant1:DOEVENT("extend antenna").
				}
			}
			IF antennas:LENGTH > 0 OR antennasRT:LENGTH > 0 {
				ship_log["add"]("Antennas deploy").
			} ELSE {
				HUDTEXT("NO ANTENNAS DETECTED", 2, 2, 42, RGB(255,60,0), false).
			}
		}).
	}//--vacuum, deploy panels and antennas, turn on lights
	
	IF ship_state["state"]["phase"] = "COASTING" {
		IF deploy_1s["get"]() > 0{
			warp_1s["do"]({
				HUDTEXT("WARPING", 2, 2, 42, green, false).
				SET WARPMODE TO "RAILS".
				WARPTO (TIME:SECONDS + ETA:APOAPSIS - 60).
			}).
		}
		IF ETA:APOAPSIS < 60 AND ETA:APOAPSIS <> 0{
			KUNIVERSE:TIMEWARP:CANCELWARP().
			ship_state["set"]("phase", "KERBINJECTION").
		}
	}//--coasting
	
	IF ((ship_res["ELECTRICCHARGE"]:AMOUNT / ship_res["ELECTRICCHARGE"]:CAPACITY)*100 < 20) OR ship_res["ELECTRICCHARGE"]:AMOUNT < 40 {
		//if below 10% of max ships capacity
		//electic charge saving and generation
		//KUNIVERSE:TIMEWARP:CANCELWARP().
		RCS ON.
		SAS OFF.
		LOCK STEERING TO UP + R(0,45,0).
		PANELS ON.
		FUELCELLS ON.
	}
		
	IF ship_state["state"]["phase"] = "KERBINJECTION" {
		rcs_1s["do"]({
			RCS ON.
			ship_log["add"]("RCS on, circuralisation").
		}).

		circ_prepare_1s["do"]({
			SET thrott TO 0.
			HUDTEXT("CIRCURALISATION...", 3, 2, 42, RGB(10,225,10), false).	
			SET dV_change TO calcDeltaV(trgt["altA"]).
			Display["print"]("dv change: ", dV_change).
			SET burn_time TO calcBurnTime(dV_change).
			Display["print"]("t: ", burn_time).
			HUDTEXT(burn_time, 3, 3, 20, green, false).
			SAS OFF.
			LOCK STEERING TO LOOKDIRUP(SHIP:PROGRADE:VECTOR, SHIP:FACING:TOPVECTOR):FOREVECTOR.
		}).
		
		IF FLOOR(ETA:APOAPSIS) <= FLOOR(burn_time / 2) {
			circ_burn_1s["do"]({
				HUDTEXT("CIRC BURN!", 3, 2, 42, RGB(230,155,10), false).
				LOCK thrott TO MAX(1 - (SHIP:ORBIT:PERIOD/trgt["period"]) ^ 100, 0.1).//release acceleration at the end
				LOCK THROTTLE to thrott.
				ship_log["add"]("CIRCURALISATION BURN").
			}).
		}
		IF ROUND(SHIP:ORBIT:PERIOD) >= (trgt["period"] - 50) {
			circ_done_1s["do"]({
				UNLOCK thrott.
				SET thrott TO 0.
				HUDTEXT("CIRCURALISATION PHASE I COMPLETE", 3, 2, 42, RGB(10,225,10), false).
				ship_log["add"]("CIRCURALISATION PHASE I COMPLETE").
				ship_log["save"]().
				ship_state["set"]("phase", "CORRECTION_BURN").
			}).
		}
		Display["print"]("THROTTLE: ", thrott).
		Display["print"]("ORB. PERIOD:", ROUND(SHIP:ORBIT:PERIOD, 3)).
		Display["print"]("TRGT ORB. PERIOD: ", trgt["period"]).
	}//target orbit injection
	IF ship_state["state"]["phase"] = "CORRECTION_BURN" {
		IF ROUND(SHIP:ORBIT:PERIOD, 3) >= trgt["period"]{
			SET SHIP:CONTROL:NEUTRALIZE to TRUE.
			HUDTEXT("CIRCURALISATION COMPLETE", 3, 2, 42, RGB(10,225,10), false).
			ship_log["add"]("CIRCURALISATION COMPLETE").
			ship_log["save"]().
			ship_state["set"]("phase", "ORBITING").
		} ELSE {
			SET SHIP:CONTROL:FORE TO 0.5.	
			Display["print"]("ORB. PERIOD:", ROUND(SHIP:ORBIT:PERIOD, 3)).
			Display["print"]("TRGT ORB. PERIOD: ", trgt["period"]).
		}
	}
	IF ship_state["state"]["phase"] = "ORBITING" {
		UNLOCK THROTTLE.
		UNLOCK STEERING.
		conn_Timer["set"]().
		SET done TO TRUE.
	}
	conn_Timer["ready"](10,{
		IF NOT ship_log["save"]() {
			conn_Timer["set"]().
		}
	}).
	journal_Timer["ready"](5,{
		ship_log["add"](ship_state["state"]["phase"] + " phase").
		journal_Timer["reset"]().
	}).
	WAIT 0.
}