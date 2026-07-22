/datum/technode/rnd
	name = "Research Basenode"
	desc = "If you see me, make a bug report!"
	id = "rnd_base"
	node_type = "Research Inquiry"

/datum/technode/rnd/test1
	name = "Research Node Test 1"
	desc = "wowwie im a test node!"
	id = "rnd_test_1"
	unlocks = list("advmop", "blutrash", "holosign")
	starting_node = TRUE

/datum/technode/rnd/test2
	name = "Research Node Test 2"
	desc = "wowwie im a test node!"
	id = "rnd_test_2"
	prereqs = list("rnd_test_1")

/datum/technode/rnd/test3
	name = "Research Node Test 3"
	desc = "wowwie im a test node!"
	id = "rnd_test_3"
	prereqs = list("rnd_test_2")
