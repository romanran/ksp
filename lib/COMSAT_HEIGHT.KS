function GetTrgtAlt{
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