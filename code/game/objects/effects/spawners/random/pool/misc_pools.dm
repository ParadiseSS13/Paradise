/datum/spawn_pool/whiteship_mobs
	id = "whiteship_mobs_spawn_pool"
	available_points = 0

/obj/effect/spawner/random/pool/whiteship_mob
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "giftbox"
	spawn_pool_id = "whiteship_mobs_spawn_pool"
	unique_picks = TRUE
	guaranteed = TRUE
	point_value = 0
	loot = list(
		/mob/living/simple_animal/hostile/pirate,
		/obj/effect/spawner/random/space_pirate,
	)
