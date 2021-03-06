@LAZYGLOBAL off.
// Flight related functions, ship helpers
function doStage {
	IF STAGE:NUMBER > 0 AND STAGE:READY {
		STAGE.
	}
	return STAGE:NUMBER = 0.
}

function setPID {
	PARAMETER setp IS "err1".
	IF setp = "err1"{
		PRINT "No setpoint value specified".
		return false.
	}
	PARAMETER prop IS 0.2.
	LOCAL Kp TO prop.
	LOCAL Ki TO prop * 0.5.
	LOCAL Kd TO prop * 0.0125.
	LOCAL PIDL TO PIDLOOP(Kp, Kp, Kd).
	SET PIDL:SETPOINT TO setp.
	return PIDL.
}

function getStageResources {
	LOCAL res_l TO LEXICON().
	FOR res IN STAGE:RESOURCES {
		IF res:CAPACITY > 0{
			res_l:ADD(res:NAME, res).
		}
	}
	RETURN res_l.
}

function getResources{
	LOCAL res_l TO LEXICON().
	FOR res IN SHIP:RESOURCES {
		IF res:CAPACITY > 0 {
			res_l:ADD(res:NAME, res).
		}
	}
	RETURN res_l.
}

function getModules {
	PARAMETER search.
	PARAMETER s_parts IS SHIP:PARTS.
	LOCAL modules_l TO LEXICON().
	FOR item IN s_parts {
		LOCAL i TO 0.
		FOR module IN item:MODULES {
			IF modules_l:HASKEY(item:NAME + i) {
				SET i TO i + 1.
			}
			IF module = search AND  NOT modules_l:HASKEY(item:NAME + i) {
				modules_l:ADD(item:NAME + i, item).
			}
		}
	}
	RETURN modules_l.
}

function doModuleAction {
	PARAMETER module.
	PARAMETER action_name.
	PARAMETER action_param.
	PARAMETER s_parts IS SHIP:PARTS.
	LOCAL parts_list TO getModules(module).
	FOR _part IN parts_list:VALUES {
		SET _part TO _part:GETMODULE(module).
		IF _part:HASACTION(action_name) {
			_part:DOACTION(action_name, action_param).
		}
	}
	return parts_list:LENGTH > 0.
}

function doModuleEvent {
	PARAMETER module.
	PARAMETER event.
	PARAMETER s_parts IS SHIP:PARTS.
	LOCAL parts_list TO getModules(module).
	FOR _part IN parts_list:VALUES {
		SET _part TO _part:GETMODULE(module).
		IF _part:HASEVENT(event) {
			_part:DOEVENT(event).
		}
	}
	return parts_list:LENGTH > 0.
}

function calcDeltaV {
	// Takes target absolute altitude (desired orbit radius) as a parameter
	PARAMETER target_alt.
	LOCAL grav_param IS CONSTANT:G * SHIP:ORBIT:BODY:MASS. //GM
	LOCAL v2 IS SQRT( grav_param * (1 / target_alt) ).//speed in a circular orbit
	//return speed difference
	LOCAL trgv IS SHIP:VELOCITY:ORBIT:MAG - v2.
	IF v2 > SHIP:VELOCITY:ORBIT:MAG {
		SET trgv TO -trgv.
	}
	RETURN trgv.
}

function calcBurnTime {
	// Takes dv as a parameter
	PARAMETER dV.
	PARAMETER rcs_on IS false.
	LOCAL f IS 0.
	LOCAL p IS 0.
	LOCAL eng_list IS LIST().
	LIST ENGINES IN eng_list.
	LOCAL rcs_thrusters TO getModules("modulercsfx").
	FOR eng IN eng_list {
		IF eng:STAGE = STAGE:NUMBER {
			SET f TO f + eng:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
			SET p TO eng:ISP.                   // Engine ISP (s)
		}
	}
	IF rcs_on {
		FOR rcs_eng IN rcs_thrusters {
			LOCAL rcs_isp TO rcs_eng:GETFIELD("rcs isp").
		}
	}
	LOCAL m IS SHIP:MASS * 1000.    // Starting mass (kg)
	LOCAL eul IS CONSTANT:E.       // Base of natural log
	LOCAL kerb_g IS 9.81.       // Gravitational acceleration constant (m/s)

	IF f > 0 AND p > 0 {
		RETURN kerb_g * m * p * (1 - eul ^ (-dV / ( kerb_g * p))) / f.
    }
	RETURN 60.
}

function calcOrbPeriod {
	// Takes r - circular orbit absolute altitude
	// Takes celestial body name string
	PARAMETER trg_alt.
	PARAMETER trg_body_str IS "current".
	LOCAL trg_body IS SHIP:ORBIT:BODY.
	IF trg_body_str <> "current" {
		SET trg_body TO BODY(trg_body_str).
	}
	LOCAL g_param IS CONSTANT:G * trg_body:MASS. //GM
	RETURN ROUND(SQRT((4 * CONSTANT:PI ^ 2 * trg_alt ^ 3) / g_param), 3).
}

function getTWR {
	LOCAL radius TO SHIP:ALTITUDE + SHIP:ORBIT:BODY:RADIUS. 
	LOCAL weight TO CONSTANT:G * ((SHIP:MASS * SHIP:ORBIT:BODY:MASS) / (radius ^ 2)).
	RETURN SHIP:MAXTHRUST / weight + 0.0001.
}

function calcTrajectory {
	PARAMETER alt. 
	PARAMETER target_alt IS 70000.
	LOCAL twr TO getTWR() * THROTTLE.
	IF alt >= target_alt {
		RETURN 0.
	}
	// sin( 1 -(x/ 600)^(2-b^0.35) ) * 90 * 1.1884
	// (1 - (x/40)^(0.5*(1-b/10)))*90
	LOCAL funcx TO 1 - (alt / target_alt) ^ (1 - twr / 10). 
	RETURN funcx * 90.
}

function getdV {   
	//fuels with density
    LOCAL fuels IS LEXICON(
		"LiquidFuel", 0.005,
		"Oxidizer",  0.005, 
		"SolidFuel", 0.0075,
		"MonoPropellant", 0.004,
		"XenonGas", 0.0001
	).
    // initialize fuel mass sums
    LOCAL fuel_mass IS 0.
	LOCAL grav_param IS CONSTANT:G * SHIP:ORBIT:BODY:MASS. //GM
    // thrust weighted average isp
    LOCAL thrustTotal IS 0.
    LOCAL mDotTotal IS 0.

    // calculate total fuel mass
	FOR fuel in fuels:KEYS {
		IF STAGE:RESOURCESLEX:HASKEY(fuel) {
			LOCAL res IS STAGE:RESOURCESLEX[fuel].
			SET fuel_mass TO fuel_mass + fuels[fuel] * res:AMOUNT.
		}
    }
	LOCAL eng_list IS LIST().
    LIST ENGINES IN eng_list. 
    FOR eng in eng_list {
        IF eng:STAGE = STAGE:NUMBER {
            SET thrustTotal TO thrustTotal + eng:MAXTHRUST.
			SET mDotTotal TO mDotTotal + eng:MAXTHRUST / eng:ISP.
        }
    }
	LOCAL avgIsp IS 0.
    IF NOT mDotTotal = 0 {
		SET avgIsp TO thrustTotal / mDotTotal.
	}
    // deltaV calculation as Isp*g0*ln(m0/m1).
    LOCAL dV IS avgIsp * 9.81 * LN(SHIP:MASS / (SHIP:MASS - fuel_mass)).

    RETURN dV.
}

function gettrgAlt {
	PARAMETER sat_num is 3.
	PARAMETER min_h is 100.
	PARAMETER trg_body_str IS "current".
	LOCAL trg_body IS SHIP:ORBIT:BODY.
	IF trg_body_str <> "current" {
		SET trg_body TO BODY(trg_body_str).
	}
	LOCAL ang TO 360 / (sat_num * 2).
	LOCAL h TO trg_body:RADIUS + min_h.
	LOCAL altA TO (h / COS(ang)). //absolute
	IF sat_num = 1 {
		SET altA TO min_h + trg_body:RADIUS.
	}
	LOCAL altR TO altA - trg_body:RADIUS. //relative altitude
	LOCAL comm_r TO ROUND(SQRT((altA * altA) * 2)).//range
	LOCAL orb_period TO calcOrbPeriod(altA, trg_body_str).

	RETURN LEXICON(
		"range", comm_r,
		"altA",  altA,
		"alt", altR,
		"period", orb_period
	).
}

function calcOrbitRadius {
	PARAMETER vsl.
	LOCAL smaj TO vsl:OBT:SEMIMAJORAXIS.
	LOCAL smin TO vsl:OBT:SEMIMINORAXIS.
	LOCAL h TO (smaj - smin) ^ 2 / (smaj + smin) ^ 2.
	RETURN CONSTANT:PI * (smaj + smin) * (1 + (3 * h) / 10 + SQRT(4 - 3 * h)).
}

function calcPhaseAngle {
	PARAMETER r1.
	PARAMETER r2.
	//180° * ( 1 - ( (r1/r2 + 1) / 2)^3/2)
	RETURN 180 * (1 - ((r1 / r2 + 1) / 2) ^ (3 / 2)).
}

function calcCraftsAngle {
	PARAMETER v1.
	PARAMETER v2.
	SET v1 TO v1:UP:STARVECTOR:NORMALIZED.
	LOCAL v2_right TO v2:UP:STARVECTOR:NORMALIZED.
	SET v2 TO v2:UP:VECTOR:NORMALIZED.
	IF VDOT(v1, v2) > 0 {
		RETURN 360 - ARCCOS(VDOT(v1, v2_right)).
	} ELSE {
		RETURN ARCCOS(VDOT(v1, v2_right)).
	}
}

function getPhaseAngle {
	PARAMETER no_of_sats.
	PARAMETER trg_vessel.
	PARAMETER last_angle IS 0.
	
	LOCAL tphase_ang TO 0.
	LOCAL launch_duration TO 200.
	IF NOT trg_vessel:ISTYPE("VESSEL") {
		RETURN 0.
	}
	
	LOCAL radius_percent IS ROUND(launch_duration / trg_vessel:OBT:PERIOD, 3). // targets angle traveled during launch
	LOCAL phase_ang IS calcPhaseAngle(SHIP:ORBIT:BODY:RADIUS + ALTITUDE, trg_vessel:ORBIT:SEMIMAJORAXIS / 2).
	LOCAL curr_angle IS calcCraftsAngle(SHIP, trg_vessel).
	LOCAL diff TO 360 * radius_percent.
	IF last_angle > phase_ang {
		// clockwise
	}
	SET tphase_ang TO phase_ang - 360 / no_of_sats + diff.
	// SET tphase_ang TO phase_ang + 360 / no_of_sats - diff.
	// IF tphase_ang > 360 {
		// SET tphase_ang TO tphase_ang - 360.
	// }

	RETURN LEXICON(
		"spread", 360 / no_of_sats,
		"traveled", diff,
		"move", ROUND(phase_ang + diff, 2),
		// "target", ROUND(tphase_ang, 2),
		"current", ROUND(curr_angle, 2)
	).
}

function interpolateLagrange {
	PARAMETER data.
	PARAMETER param.
	LOCAL result IS 0.
	IF data:TYPENAME = "LIST" {
		SET data TO arr2obj(data, "x", "y").
	}
	LOCAL n IS data["x"]:LENGTH.
	FROM {LOCAL i is 0.} UNTIL i = n STEP {SET i TO i + 1.} DO {
		LOCAL term TO 1.
		FROM {LOCAL j is 0.} UNTIL j = n STEP {SET j TO j + 1.} DO {
			IF NOT (i = j) {
				SET term TO term * ((param - data["x"][j]) / (data["x"][i] - data["x"][j])).
			}
		}
		SET result TO result + data["y"][i] * term.
	}
	RETURN result.
}