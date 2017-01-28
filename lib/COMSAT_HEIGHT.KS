function GetTrgtAlt{
	parameter sat_num is 3.
	parameter min_h is 100.
	set ang to 360/(sat_num*2). 
	set h to KERBIN:RADIUS+min_h.
	set altA to (h/COS(ang)). //absolute
	set altR to altA-KERBIN:RADIUS. //relative altitude
	set comm_r to SQRT((altA*altA)*2).//range
	set comm_r to ROUND(comm_r).
	set o to lexicon().
	o:ADD("r", comm_r).
	o:ADD("altA",  altA).
	o:ADD("alt", altR).
	return o.
}