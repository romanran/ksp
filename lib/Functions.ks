@LAZYGLOBAL off.
// Flight related functions, ship helpers
function doStage {
	IF STAGE:NUMBER > 0 AND STAGE:READY {
		STAGE.
	}
	return STAGE:NUMBER = 0.
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
		IF res:CAPACITY > 0{
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
			IF module = search{
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
	LOCAL v2 IS SQRT( grav_param * (1 / target_alt) ).//speed in a circural orbit
	LOCAL trgtv IS 0.
	//return speed difference
	IF v2 > SHIP:VELOCITY:ORBIT:MAG {
		SET trgtv TO v2 - SHIP:VELOCITY:ORBIT:MAG.
	} ELSE {
		SET trgtv TO SHIP:VELOCITY:ORBIT:MAG - v2.
	}
	RETURN trgtv.
}

function calcBurnTime {
	// Takes dv as a parameter
	PARAMETER dV.
	LOCAL f IS 0.
	LOCAL p IS 0.
	LOCAL eng_list IS LIST().
	LIST ENGINES IN eng_list.
	FOR eng IN eng_list {
		IF eng:STAGE = STAGE:NUMBER {
			SET f TO f + eng:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
			SET p TO eng:ISP.                   // Engine ISP (s)
		}
	}
	LOCAL m IS SHIP:MASS * 1000.    // Starting mass (kg)
	LOCAL eul IS CONSTANT:E.       // Base of natural log
	LOCAL kerb_g IS 9.81.       // Gravitational acceleration constant (m/s)
	globals["display"]["print"](f).
	globals["display"]["print"](p).
	IF f > 0 AND p > 0 {
		RETURN kerb_g * m * p * (1 - eul ^ (-dV / ( kerb_g * p))) / f.
    }
	RETURN -1.
}

function calcOrbPeriod {
	// Takes r - circular orbit absolute altitude
	// Takes celestial body name string
	PARAMETER trgt_alt.
	PARAMETER trgt_body_str IS "current".
	LOCAL trgt_body IS SHIP:ORBIT:BODY.
	IF trgt_body_str <> "current" {
		SET trgt_body TO BODY(trgt_body_str).
	}
	LOCAL grav_param IS CONSTANT:G * trgt_body:MASS. //GM
	RETURN ROUND(SQRT((4 * CONSTANT:PI ^ 2 * trgt_alt ^ 3) / grav_param), 3).
}

function calcTrajectory {
	PARAMETER alt.
	PARAMETER target_alt IS 70000.
	LOCAL funcx TO ROUND(1 - (alt ^ 2 / target_alt ^ 2) ^ 0.25, 3).
	RETURN ROUND(SIN(funcx*CONSTANT:RadToDeg) * (90 * 1.1884), 2).
}

function getdV {   
	// https://www.reddit.com/r/Kos/comments/330yir/calculating_stage_deltav/
	// cc: only_to_downvote
    LOCAL fuels IS LIST("LiquidFuel", "Oxidizer", "SolidFuel", "MonoPropellant").

    // fuel density list (order must match name list)
    LOCAL fuelsDensity IS list(0.005, 0.005, 0.0075, 0.004).

    // initialize fuel mass sums
    LOCAL fuel_mass IS 0.
	LOCAL grav_param IS CONSTANT:G * SHIP:ORBIT:BODY:MASS. //GM
    // thrust weighted average isp
    LOCAL thrustTotal IS 0.
    LOCAL mDotTotal IS 0.

    // calculate total fuel mass
    FOR res IN STAGE:RESOURCES {
        LOCAL i is 0.
        FOR fuel in fuels {
            IF fuel = res:NAME {
                SET fuel_mass TO fuel_mass + fuelsDensity[i] * res:AMOUNT.
            }
            SET i TO i + 1.
        }
    }
	LOCAL eng_list IS LIST().
    LIST ENGINES IN eng_list. 
    FOR eng in eng_list {
        IF eng:STAGE = STAGE:NUMBER {
            SET thrustTotal TO thrustTotal + eng:maxthrust.
			SET mDotTotal TO mDotTotal + eng:maxthrust / eng:ISP.
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

function getTrgtAlt {
	PARAMETER sat_num is 3.
	PARAMETER min_h is 100.
	LOCAL ang TO 360 / (sat_num * 2). 
	LOCAL h TO KERBIN:RADIUS + min_h.
	LOCAL altA TO (h / COS(ang)). //absolute
	LOCAL altR TO altA - KERBIN:RADIUS. //relative altitude
	LOCAL comm_r TO ROUND(SQRT((altA * altA) * 2)).//range
	LOCAL orb_period TO calcOrbPeriod(altA).
	RETURN LEXICON(
		"r", comm_r,
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
	RETURN 180 * (1 - (r1 / (2 * r2) + 1 / 2) ^ (ROUND(3 / 2, 2))).
}

function calcAngleFromVec {
	PARAMETER v1.
	PARAMETER v2.
	SET v1 TO v1:NORMALIZED.
	SET v2 TO v2:NORMALIZED.
	RETURN ARCCOS(v1 * v2).
}

function getPhaseAngle {
	PARAMETER no_of_sats.
	PARAMETER trgt_vessel.
	PARAMETER last_angle IS 0.
	
	IF NOT trgt_vessel:ISTYPE("VESSEL") {
		RETURN 0.
	}
	
	LOCAL radius_percent IS ROUND(260 / trgt_vessel:OBT:PERIOD, 3).
	LOCAL phase_ang IS calcPhaseAngle(600000 + ALTITUDE, trgt_vessel:ORBIT:SEMIMAJORAXIS / 2).
	LOCAL curr_angle IS calcAngleFromVec(SHIP:UP:STARVECTOR, trgt_vessel:UP:STARVECTOR).
	LOCAL ahead IS false.
	IF curr_angle > last_angle {
		//target is ahead
		SET phase_ang TO - phase_ang.
	} 
	LOCAL tphase_ang TO 360 / no_of_sats + phase_ang.
	LOCAL last_angle TO curr_angle.

	RETURN LEXICON(
		"spread", 360 / no_of_sats,
		"traveled", 360 * radius_percent,
		"separation", 360 * radius_percent +  360 / no_of_sats,
		"move", phase_ang,
		"target", tphase_ang,
		"current", curr_angle
	).

}