function doOnce {
	DECLARE LOCAL calls_num TO 0.
	function call {
		PARAMETER fun IS 0.
		PARAMETER params IS "empty".
		IF (fun <> 0) AND (calls_num = 0){
			if( params <> "empty" ){
				fun(params).//pass arguments as a list
			}else{
				fun().
			}
			SET calls_num TO 1.
		}ELSE{
			SET calls_num TO calls_num + 1.
		}
	}

	function resetIt {
		SET calls_num TO 0.
	}
	function getcalls_num{
		return calls_num.
	}

	return lex(
		"do", call@,
		"get", getcalls_num@,
		"reset", resetIt@
	).
}