function GetTrgtAlt{
	parameter sat_num is 3.
	parameter min_h is 100.
	set ang to 360/(sat_num*2). 
	set h to KERBIN:RADIUS+min_h.
	set altA to (h/COS(ang)). //absolute
	set altR to altA-KERBIN:RADIUS. //relative altitude
	set r to SQRT((altA*altA)*2).//range
	set r to ROUND(r).
	set o to lexicon().
	o:ADD("r", r).
	o:ADD("alt", altR).
	return o.
}