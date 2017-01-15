SWITCH TO 0.
SET partlist TO SHIP:PARTS.
//FOR P IN partlist {
//  LOG ("MODULES FOR PART NAMED " + P:NAME + ":") TO MODLIST.txt.
//  LOG "   -"+P:MODULES TO MODLIST.txt.
//}.
SET mA TO LEXICON().
FOR item IN partList {
	LOCAL moduleList TO item:MODULES.
	FOR module IN moduleList {
		IF NOT mA:HASKEY(item:NAME){
			mA:ADD(item:NAME, item).
			PRINT item:NAME.
		}
	}.
}.
	PRINT mA["KR-2042"]:MODULES.
SWITCH TO 1.