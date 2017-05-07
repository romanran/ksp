RUNONCEPATH("0:lib/Inquiry").
set prompt to LIST(
	LEXICON(
		"name", "test4",
		"type", "checkbox", 
		"msg", "Choose any",
		"choices", LIST(
			LEXICON(
				"msg", "Item 1 example",
				"name", "item1"
			),
			LEXICON(
				"msg", "Item 2 example",
				"name", "item2"
			),
			LEXICON(
				"msg", "Item 3 example",
				"name", "item3"
			)
		)
	),
	LEXICON(
		"name", "test1",
		"type", "number", 
		"msg", "Test number in kilometers",
		"filter", {
			PARAMETER resolve, reject, val.
			IF (val < 1 OR val > 10) {
				return reject("Choose a number range of 1 to 10").
			} ELSE {
				return resolve(val * 1000).
			}
		}
	),
	LEXICON(
		"name", "test2",
		"type", "letter", 
		"msg", "Test str",
		"filter": {
			PARAMETER resolve, reject, str
			IF (str:LENGTH > 10) {
				return reject("String is too long: " + str:LENGTH + " out of 10 characters allowed").
			} ELSE {
				return resolve(str).
			}
		}
	),
	LEXICON(
		"name", "test3",
		"type", "char", 
		"msg", "Test character"
	)
).
LOCAL test TO Inquiry(prompt).
PRINT test.