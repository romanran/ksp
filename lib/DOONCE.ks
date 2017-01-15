function doOnce {
	DECLARE LOCAL calls_num TO 0.
	function call {
		parameter fun IS 0.
		parameter p1 IS "empty".
		parameter p2 IS "empty".
		parameter p3 IS "empty".
		IF (fun <> 0) AND (calls_num = 0){
			if( p3 <> "empty" ){
				fun(p1, p2, p3).
			}else if( p2 <> "empty" ){
				fun(p1, p2).
			}else if( p1 <> "empty" ){
				fun(p1).
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