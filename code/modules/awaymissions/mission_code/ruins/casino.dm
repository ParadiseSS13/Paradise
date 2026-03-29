/obj/effect/spawner/random/pool/spaceloot/syndicate/rare/casino
	guaranteed = TRUE

/datum/spawn_pool/casino_mobs
	available_points = 6

/obj/effect/spawner/random/pool/casino_mob
	icon_state = "pirate"
	spawn_pool = /datum/spawn_pool/casino_mobs
	point_value = 1
	loot = list(
		/mob/living/basic/pirate,
		/mob/living/basic/pirate/ranged,
	)
