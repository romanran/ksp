function doStage{
	IF STAGE:NUMBER > 0 AND STAGE:READY {
		STAGE.
		DECLARE LOCAL stg_res TO getStageResources().
		IF STAGE:NUMBER = 0{
			return lex(
				"res", stg_res,
				"done", true
			).
		}else{
			return lex(
				"res", stg_res,
				"done", false
			).
		}
	}
}
function checkProperty{
	PARAMETER prop.
	LOCAL bool TO false.
	IF prop{
		IF prop:LENGTH > 0{
			SET bool TO true.
		}
	}
	return bool.
}

function getStageResources{
	SET res_l TO LEXICON().
	wait 0.1.
	FOR res IN STAGE:RESOURCES{
		IF res:CAPACITY > 0{
			res_l:ADD(res:NAME, res).
		}
	}
	RETURN res_l.
}

function getResources{
	SET res_l TO LEXICON().
	wait 0.1.
	FOR res IN SHIP:RESOURCES{
		IF res:CAPACITY > 0{
			res_l:ADD(res:NAME, res).
		}
	}
	RETURN res_l.
}

function getModules {
	parameter m.
	SET partlist TO SHIP:PARTS.
	SET mA TO LEXICON().
	FOR item IN partList {
		LOCAL moduleList TO item:MODULES.
		SET i TO 0.
		FOR module IN moduleList {
			IF mA:HASKEY(item:NAME+i){
				SET i TO i+1.
			}
			IF module = M{
				mA:ADD(item:NAME+i, item).
			}
		}.
	}.
	RETURN mA.
}.

function calcDeltaV{
	// Takes target altitude as a parameter
	LOCAL PARAMETER target_alt.
	LOCAL PARAMETER ms IS 1000.1.
	LOCAL PARAMETER circ_m IS NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, ms).
	//LOCAL PARAMETER circ_m IS NODE(TIME:SECONDS+10, 0, 0, ms).
	LOCAL PARAMETER i IS 0.
	SET i TO i + 1.
	IF ms = 1000.1{
		ADD circ_m.
	}
	IF i>100{
		RETURN "error".
	}
	SET circ_m:PROGRADE TO ms.
	IF ROUND(circ_m:ORBIT:APOAPSIS) = ROUND(circ_m:ORBIT:PERIAPSIS){
		return ms.
	}ELSE{
		PRINT circ_m:ORBIT:APOAPSIS.
		//PRINT circ_m:ORBIT:PERIAPSIS.	
		IF (circ_m:ORBIT:APOAPSIS-1 > target_alt AND circ_m:ORBIT:PERIAPSIS - 1 < target_alt) {
			calcDeltaV(target_alt, ms-ms/2, circ_m, i).
		}ELSE{
			calcDeltaV(target_alt, ms+ms/2, circ_m, i).
		}
	}
	
}
function calcBurnTime {
	// Takes dv as a parameter
  LOCAL PARAMETER dV.

  LIST ENGINES IN en.

  LOCAL f IS en[0]:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
  LOCAL m IS SHIP:MASS * 1000.        // Starting mass (kg)
  LOCAL eul IS CONSTANT:E.            // Base of natural log
  LOCAL p IS en[0]:ISP.               // Engine ISP (s)
  LOCAL kerb_g IS 9.80665.                 // Gravitational acceleration constant (m/s²)

  RETURN kerb_g * m * p * (1 - eul^(-dV/( kerb_g*p))) / f.
}

function calcTrajectory{
	LOCAL PARAMETER alt.
	DECLARE LOCAL funcx TO ROUND(1-((alt^2)/(70000^2))^0.25,3).
	RETURN ROUND((SIN(funcx*CONSTANT:RadToDeg))*(90*1.1884),2).
}