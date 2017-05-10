LIST(
	LEXICON(
		"name", "sats",
		"type", "number", 
		"msg", "number of satellites",
		"filter", {
			PARAMETER resolve, reject, val.
			IF (val < 3 OR val > 6) {
				return reject("Choose number of sats in range 3 - 6").
			} ELSE {
				return resolve(val).
			}
		}
	),
	LEXICON(
		"name", "alt",
		"type", "number", 
		"msg", "Altitude in km.",
		"filter", {
			PARAMETER resolve, reject, val.
			return resolve(val * 1000).
		}
	)
).