/datum/event/carp_migration
	spawned_mobs = list(
    /mob/living/simple_animal/hostile/retaliate/carp/koi = 95,
    /mob/living/simple_animal/hostile/retaliate/carp/koi/honk = 2,
	)


/datum/event/carp_migration/koi/start()
	spawn_fish(landmarks_list.len)