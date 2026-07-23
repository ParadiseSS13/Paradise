/datum/technode/alien
	name = "Alien Basenode"
	desc = "If you see me, make a bug report!"
	id = "alien_base"
	node_type = "Alien Technology"

/datum/technode/alien/test1
	name = "Alien Node Test 1"
	desc = "wowwie im a test node!"
	id = "alien_test_1"
	prereqs = list("rnd_test_1")
	cost_hidden = list("Alien" = 50)

/datum/technode/alien/test2
	name = "Alien Node Test 2"
	desc = "wowwie im a test node!"
	id = "alien_test_2"
	prereqs = list("alien_test_1")

/datum/technode/alien/test3
	name = "Alien Node Test 3"
	desc = "wowwie im a test node!"
	id = "alien_test_3"
	prereqs = list("alien_test_2")
