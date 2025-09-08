/datum/game_test/room_test/spawn_humans/Run()
	for(var/I in 1 to 5)
		allocate(/mob/living/carbon/human, pick(available_turfs))

	// There is a 5 second delay here so that all the items on the humans have time to initialize and spawn
	sleep(50)
