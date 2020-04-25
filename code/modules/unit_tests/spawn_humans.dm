/datum/unit_test/spawn_humans/Run()
    var/locs = block(run_loc_bottom_left, run_loc_top_right)

    for(var/I in 1 to 5)
        new /mob/living/carbon/human(pick(locs))

	// There is a 5 second delay here so that all the items on the humans have time to initialize and spawn
    sleep(50)
