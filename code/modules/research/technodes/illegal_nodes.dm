/datum/technode/illegal
	name = "Illegal Basenode"
	desc = "If you see me, make a bug report!"
	id = "illegal_base"
	node_type = "Illegal Technology"

/datum/technode/illegal/test1
	name = "Illegal Node Test 1"
	desc = "wowwie im a test node!"
	id = "illegal_test_1"
	prereqs = list("rnd_test_1")
	cost_hidden = list("Illegal" = 50)

/datum/technode/illegal/test2
	name = "Illegal Node Test 2"
	desc = "wowwie im a test node!"
	id = "illegal_test_2"
	prereqs = list("illegal_test_1")

/datum/technode/illegal/test3
	name = "Illegal Node Test 3"
	desc = "wowwie im a test node!"
	id = "illegal_test_3"
	prereqs = list("illegal_test_2")
