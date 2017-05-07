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
		"msg", "Test number"
	),
	LEXICON(
		"name", "test2",
		"type", "letter", 
		"msg", "Test str"
	),
	LEXICON(
		"name", "test3",
		"type", "char", 
		"msg", "Test character"
	)
).
LOCAL test TO Inquiry(prompt).
PRINT test.