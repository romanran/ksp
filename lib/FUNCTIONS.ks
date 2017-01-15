function doStage{
	IF STAGE:NUMBER > 0 AND STAGE:READY {
		STAGE.
		SET stg_res TO getResources().
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

function calcDeltaV{
	// Takes target altitude as a parameter
	LOCAL PARAMETER target_alt.
	LOCAL PARAMETER ms IS 1000.1.
	//LOCAL PARAMETER circ_m IS NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, ms).
	LOCAL PARAMETER circ_m IS NODE(TIME:SECONDS+10, 0, 0, ms).
	LOCAL PARAMETER i IS 0.
	SET i TO i + 1.
	IF i>100{
		RETURN "error".
	}
	IF ms = 1000.1{
		ADD circ_m.
		RETURN circ_m:ORBIT:APOAPSIS.
	}
	IF ROUND(circ_m:ORBIT:APOAPSIS) = ROUND(circ_m:ORBIT:PERIAPSIS){
		return ms.
	}ELSE{
		PRINT circ_m:ORBIT:APOAPSIS.
		PRINT circ_m:ORBIT:PERIAPSIS.	
		IF (circ_m:ORBIT:APOAPSIS-1 > target_alt AND circ_m:ORBIT:PERIAPSIS - 1 < target_alt) {
			calcDeltaV(target_alt, (ms+4)/2, circ_m, i).
		}ELSE{
			calcDeltaV(target_alt, (ms+4)*2, circ_m, i).
		}
	}
	
}
function calcBurnTime {
	// Takes dv as a parameter
  LOCAL PARAMETER dV.

  LIST ENGINES IN en.

  LOCAL f IS en[0]:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
  LOCAL m IS SHIP:MASS * 1000.        // Starting mass (kg)
  LOCAL e IS CONSTANT():E.            // Base of natural log
  LOCAL p IS en[0]:ISP.               // Engine ISP (s)
  LOCAL g IS 9.80665.                 // Gravitational acceleration constant (m/s²)

  RETURN g * m * p * (1 - e^(-dV/(g*p))) / f.
}