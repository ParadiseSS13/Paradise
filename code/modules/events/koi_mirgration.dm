/datum/event/carp_migration/koi
	spawned_mobs = list(
    /mob/living/simple_animal/hostile/retaliate/carp/koi = 98,
    /mob/living/simple_animal/hostile/retaliate/carp/koi/honk = 2)


/datum/event/carp_migration/koi/start()
	spawn_fish(GLOB.landmarks_list.len)
