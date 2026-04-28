/datum/event/carp_migration/whale
	name =  "Whale Pod"
	spawned_mobs = list(
	/mob/living/basic/megafauna/space_whale)


/datum/event/carp_migration/whale/start()
	spawn_fish(rand(1, 2), 1, 3) //Whales are rather big and can cause good damage if angered so keeping numbers low
