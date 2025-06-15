/obj/effect/spawner/random/pool/spaceloot/casino
	guaranteed = TRUE
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/syndicate/rare,
		/obj/effect/spawner/random/pool/spaceloot/trader_departments/rare,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/rare,
	)

/datum/spawn_pool/casino_mobs
	available_points = 6

/obj/effect/spawner/random/pool/casino_mob
	icon_state = "pirate"
	spawn_pool = /datum/spawn_pool/casino_mobs
	point_value = 1
	loot = list(
		/mob/living/simple_animal/hostile/pirate,
		/mob/living/simple_animal/hostile/pirate/ranged,
	)
