/datum/spawn_pool/whiteship_mobs

/obj/effect/spawner/random/pool/whiteship_mob
	icon_state = "giftbox"
	spawn_pool = /datum/spawn_pool/whiteship_mobs
	unique_picks = TRUE
	guaranteed = TRUE
	point_value = 0
	loot = list(
		/mob/living/basic/pirate,
		/obj/effect/spawner/random/space_pirate,
	)
