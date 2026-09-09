/datum/event/carp_migration/whale
	name =  "Whale Pod"
	spawned_mobs = list(
	/mob/living/basic/megafauna/space_whale)

/datum/event/carp_migration/whale/start()
	spawn_fish(rand(1, 3), 1, 1) // Whales are rather big and can cause good damage if angered so keeping numbers low
	spawned_mobs = list(
		/mob/living/basic/carp = 95,
		/mob/living/basic/carp/megacarp = 5)
	spawn_fish(rand(1, 4), 2, 6) // Spawn some fish for them to eat too.

/datum/event/carp_migration/whale/announce()
	GLOB.minor_announcement.Announce("Migration of space whales detected near [station_name()]. Please stand by.", "Lifesign Alert")
