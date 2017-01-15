function objInit {
	
	function setVal {
		parameter isdone.
		set done to isdone.
	}

	function getVal {
		return done.
	}

	return lex(
		"setVal", setVal@,
		"getVal", getVal@
	)
}