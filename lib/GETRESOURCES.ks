function getResources{
	SET res_l TO LEXICON().
	wait 0.1.
	print STAGE:RESOURCES.
	FOR RES IN STAGE:RESOURCES{
		IF RES:CAPACITY > 0{
			res_l:ADD(RES:NAME, RES:CAPACITY).
		}
	}
	CLEARSCREEN.
	RETURN res_l.
}