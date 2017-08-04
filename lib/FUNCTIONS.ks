function doStage {
	IF STAGE:NUMBER > 0 AND STAGE:READY {
		STAGE.
		DECLARE LOCAL stg_res TO getStageResources().
		return lex(
			"res", stg_res,
			"done", STAGE:NUMBER = 0
		).
	}
}

function getStageResources {
	SET res_l TO LEXICON().
	wait 0.1.
	FOR res IN STAGE:RESOURCES {
		IF res:CAPACITY > 0{
			res_l:ADD(res:NAME, res).
		}
	}
	RETURN res_l.
}

function getResources{
	SET res_l TO LEXICON().
	wait 0.1.
	FOR res IN SHIP:RESOURCES {
		IF res:CAPACITY > 0{
			res_l:ADD(res:NAME, res).
		}
	}
	RETURN res_l.
}

function getModules {
	PARAMETER search.
	SET modules_l TO LEXICON().
	FOR item IN SHIP:PARTS {
		SET i TO 0.
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
}.

function calcDeltaV {
	// Takes target absolute altitude (desired orbit radius) as a parameter
	PARAMETER target_alt.
	PRINT target_alt AT(0,10).
	LOCAL grav_param IS CONSTANT:G * SHIP:ORBIT:BODY:MASS. //GM
	LOCAL v2 IS SQRT( grav_param * (1/target_alt) ).//speed in a circural orbit
	LOCAL trgtv IS 0.
	//return speed difference
	IF v2 > SHIP:VELOCITY:ORBIT:MAG {
		SET trgtv TO v2 - SHIP:VELOCITY:ORBIT:MAG.
	}ELSE{
		SET trgtv TO SHIP:VELOCITY:ORBIT:MAG - v2.
	}
	RETURN trgtv.
}

function calcBurnTime {
	// Takes dv as a parameter
	PARAMETER dV.
	LOCAL f IS 0.
	LOCAL p IS 0.
	LIST ENGINES IN en.
	FOR eng IN en{
		IF eng:STAGE = STAGE:NUMBER{
			SET f TO f + eng:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
			SET p TO eng:ISP.               // Engine ISP (s)
		}
	}
	LOCAL m IS SHIP:MASS * 1000.        // Starting mass (kg)
	LOCAL eul IS CONSTANT:E.            // Base of natural log
	LOCAL kerb_g IS 9.80665.                 // Gravitational acceleration constant (m/s²)
	IF f > 0 AND p > 0{
		RETURN kerb_g * m * p * (1 - eul^(-dV/( kerb_g*p))) / f.
    }
	RETURN 0.
}

function calcOrbPeriod {
	// Takes r - circular orbit absolute altitude
	// Takes celestial body name string
	PARAMETER trgt_alt.
	PARAMETER trgt_body_str IS "current".
	LOCAL trgt_body IS SHIP:ORBIT:BODY.
	IF trgt_body_str <> "current"{
		SET trgt_body TO BODY(trgt_body_str).
	}
	LOCAL grav_param IS CONSTANT:G * trgt_body:MASS. //GM
	RETURN ROUND(SQRT( (4*CONSTANT:PI^2*trgt_alt^3)/grav_param ), 3).
}

function calcTrajectory {
	PARAMETER alt.
	DECLARE LOCAL funcx TO ROUND(1 - (alt ^ 2 / 70000 ^ 2) ^ 0.25, 3).
	RETURN ROUND(SIN(funcx*CONSTANT:RadToDeg) * (90 * 1.1884), 2).
}

function generateID {
	PARAMETER default_vessel IS SHIP.
	LOCAL vessel_name TO default_vessel.

	IF default_vessel:typename() = "Vessel"{
		SET vessel_name TO default_vessel:NAME. 
	}
	IF default_vessel:typename() = "String"{
		SET vessel_name TO default_vessel. 
	}
	RETURN vessel_name + " " + FLOOR(RANDOM() * 1000).
}

function getdV {   
	//https://www.reddit.com/r/Kos/comments/330yir/calculating_stage_deltav/
	//only_to_downvote
    LOCAL fuels IS list().
    fuels:ADD("LiquidFuel").
    fuels:ADD("Oxidizer").
    fuels:ADD("SolidFuel").
    fuels:ADD("MonoPropellant").

    // fuel density list (order must match name list)
    LOCAL fuelsDensity IS list().
    fuelsDensity:ADD(0.005).
    fuelsDensity:ADD(0.005).
    fuelsDensity:ADD(0.0075).
    fuelsDensity:ADD(0.004).

    // initialize fuel mass sums
    LOCAL fuelMass IS 0.
	LOCAL grav_param IS CONSTANT:G * SHIP:ORBIT:BODY:MASS. //GM
    // thrust weighted average isp
    LOCAL thrustTotal IS 0.
    LOCAL mDotTotal IS 0.

    // calculate total fuel mass
    FOR r IN STAGE:RESOURCES {
        LOCAL iter is 0.
        FOR f in fuels{
            IF f = r:NAME{
                SET fuelMass TO fuelMass + fuelsDensity[iter]*r:AMOUNT.
            }
            SET iter TO iter+1.
        }
    }

    LIST ENGINES IN engList. 
    FOR eng in engList{
        IF eng:IGNITION {
            SET thrustTotal TO thrustTotal + eng:maxthrust.
			SET mDotTotal TO mDotTotal + eng:maxthrust / eng:ISP.
        }
    }
	LOCAL avgIsp IS 0.
    IF NOT mDotTotal = 0 {
		SET avgIsp TO thrustTotal / mDotTotal.
	}
    // deltaV calculation as Isp*g0*ln(m0/m1).
    LOCAL deltaV IS avgIsp * 9.82 * LN(SHIP:MASS / (SHIP:MASS - fuelMass)).

    RETURN deltaV.
}.

function getTrgtAlt {
	parameter sat_num is 3.
	PARAMETER min_h is 100.
	LOCAL ang TO 360/(sat_num*2). 
	LOCAL h TO KERBIN:RADIUS+min_h.
	LOCAL altA TO (h/COS(ang)). //absolute
	LOCAL altR TO altA-KERBIN:RADIUS. //relative altitude
	LOCAL comm_r TO ROUND( SQRT((altA*altA)*2) ).//range
	LOCAL o TO lexicon().
	LOCAL orb_period TO calcOrbPeriod(altA).
	o:ADD("r", comm_r).
	o:ADD("altA",  altA).
	o:ADD("alt", altR).
	o:ADD("period", orb_period).
	return o.
}

function calcOrbitRadius {
	PARAMETER vsl.
	LOCAL smaj TO vsl:OBT:SEMIMAJORAXIS.
	LOCAL smin TO vsl:OBT:SEMIMINORAXIS.
	LOCAL h TO (smaj - smin)^2/(smaj + smin)^2.
	RETURN CONSTANT:PI * (smaj + smin) * (1 + (3 * h) / 10 + SQRT(4 - 3 * h)).
}

function calcPhaseAngle {
	PARAMETER r1.
	PARAMETER r2.
	RETURN 180 * (1 - (r1 / (2 * r2) + 1 / 2) ^ (ROUND(3 / 2, 2))).
}

function CS {
	IF NOT (env = "debug") {
		CLEARSCREEN.
	}
}

function calcAngleFromVec {
	PARAMETER v1.
	PARAMETER v2.
	SET v1 TO v1:NORMALIZED.
	SET v2 TO v2:NORMALIZED.
	RETURN ARCCOS(v1 * v2).
}

function deb {
	PARAMETER str1 IS "".
	PARAMETER str2 IS "".
	PARAMETER str3 IS "".
	PARAMETER str4 IS "".
	IF env = "debug" {
		IF (str1:LENGTH > 0) {
			PRINT str1.
		}
		IF (str2:LENGTH > 0) {
			PRINT str2.
		}
		IF (str3:LENGTH > 0) {
			PRINT str3.
		}
		IF (str4:LENGTH > 0) {
			PRINT str4.
		}
	} 
}