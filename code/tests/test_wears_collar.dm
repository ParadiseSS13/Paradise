/datum/game_test/wears_collar/Run()
	var/datum/test_puppeteer/player = new(src)

	var/obj/chair = player.spawn_obj_nearby(/obj/structure/chair)
	var/mob/corgi = player.spawn_mob_nearby(/mob/living/simple_animal/pet/dog/corgi)
	chair.buckle_mob(corgi) // So it doesn't wander off

	var/obj/item/petcollar/collar = player.spawn_obj_in_hand(/obj/item/petcollar)
	player.click_on(corgi)
	TEST_ASSERT(collar in corgi, "Collar not placed on corgi")
	TEST_ASSERT_EQUAL(corgi.name, "corgi", "animal name not preserved")

	qdel(collar)
	qdel(corgi)

	corgi = player.spawn_mob_nearby(/mob/living/simple_animal/pet/dog/corgi)
	chair.buckle_mob(corgi) // So it doesn't wander off

	collar = player.spawn_obj_in_hand(/obj/item/petcollar)
	collar.tagname = "Bucephalus"
	player.click_on(corgi)
	TEST_ASSERT(collar in corgi, "Collar not placed on corgi")
	TEST_ASSERT_EQUAL(corgi.name, "Bucephalus", "animal name not changed")

