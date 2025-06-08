/datum/event/tear/honk
	name = "honkmensional tear"
	notify_title = "Honkmensional Tear"
	notify_image = "clowngoblin"
	var/obj/effect/tear/honk/HE

/datum/event/tear/honk/spawn_tear(location)
	HE = new /obj/effect/tear/honk(location)

/datum/event/tear/honk/announce()
	GLOB.minor_announcement.Announce("На борту станции зафиксирована Хонканомалия. Предполагаемая локация: [impact_area.name].", "ВНИМАНИЕ: Обнаружена ХОНКАНОМАЛИЯ.", 'sound/items/airhorn.ogg')

/datum/event/tear/honk/end()
	if(HE)
		qdel(HE)

/obj/effect/tear/honk
	name = "honkmensional tear"
	desc = "A tear in the dimensional fabric of sanity."
	leader = /mob/living/simple_animal/hostile/retaliate/clown/goblin/cluwne
	possible_mobs = list(
		/mob/living/simple_animal/hostile/retaliate/clown,
		/mob/living/simple_animal/hostile/retaliate/clown/goblin
	)
