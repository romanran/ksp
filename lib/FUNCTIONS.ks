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
	// Takes target absolute altitude (desired orbit radius) as a parameter
	LOCAL PARAMETER target_alt.
	LOCAL grav_param IS SHIP:ORBIT:BODY:MASS. //GM
	LOCAL v2 IS SQRT( grav_param * (1/target_alt) ).//speed in a circural orbit
	RETURN v2 - SHIP:ORBIT:VELOCITY.//return speed difference
}
function calcBurnTime {
	// Takes dv as a parameter
	LOCAL PARAMETER dV.
	LOCAL f IS 0.
	LIST ENGINES IN en.
	FOR eng IN en{
		IF eng:STAGE = STAGE:NUMBER{
			LOCAL f IS f + eng:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
		}
	}
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