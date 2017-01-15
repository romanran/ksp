function doOnce {
	DECLARE LOCAL calls TO 0.
	function call {
		parameter fun IS 0.
		parameter p1 IS "empty".
		parameter p2 IS "empty".
		parameter p3 IS "empty".
		IF (fun <> 0) AND (calls = 0){
			if( p3 <> "empty" ){
				fun(p1, p2, p3).
			}else if( p2 <> "empty" ){
				fun(p1, p2).
			}else if( p1 <> "empty" ){
				fun(p1).
			}else{
				fun().
			}
			SET calls TO 1.
		}ELSE{
			SET calls TO calls + 1.
		}
	}

	function resetIt {
		SET calls TO 0.
	}

	return lex(
		"do", call@,
		"reset", resetIt@
	).
}