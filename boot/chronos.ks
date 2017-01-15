SET done TO false.
SET mother TO PROCESSOR("MU").
UNTIL done{
	IF NOT CORE:MESSAGES:EMPTY {
	  SET wait_for TO CORE:MESSAGES:POP.
	  PRINT "WAITING FOR "+wait_for:CONTENT.
	  WAIT wait_for:CONTENT.
	  SET MESSAGE TO "done". 
	  IF mother:CONNECTION:SENDMESSAGE(MESSAGE){
		PRINT "DONE".
	  }
	}
	wait 0.1.
}