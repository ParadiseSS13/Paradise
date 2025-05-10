/datum/spawn_pool/whiteship_mobs
	available_points = 0

/obj/effect/spawner/random/pool/whiteship_mob
	icon_state = "giftbox"
	spawn_pool = /datum/spawn_pool/whiteship_mobs
	unique_picks = TRUE
	guaranteed = TRUE
	point_value = 0
	loot = list(
		/mob/living/simple_animal/hostile/pirate,
		/obj/effect/spawner/random/space_pirate,
	)
