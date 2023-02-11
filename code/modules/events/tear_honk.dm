/datum/event/tear/honk
	name = "honkmensional tear"
	notify_title = "Honkmensional Tear"
	notify_image = "clowngoblin"
	var/obj/effect/tear/honk/HE

/datum/event/tear/honk/spawn_tear(location)
	HE = new /obj/effect/tear/honk(location)

/datum/event/tear/honk/announce()
	GLOB.minor_announcement.Announce("A Honknomoly has opened. Expected location: [impact_area.name].", "Honknomoly Alert", 'sound/items/airhorn.ogg')

/datum/event/tear/honk/end()
	if(HE)
		qdel(HE)

/obj/effect/tear/honk
	name = "honkmensional tear"
	desc = "A tear in the dimensional fabric of sanity."
	possible_mobs = list(/mob/living/simple_animal/hostile/retaliate/clown/goblin)
	leader = null // Doesn't spawn with a leader always

/obj/effect/tear/honk/Initialize(mapload)
	. = ..()
	if(prob(5))
		leader = /mob/living/simple_animal/hostile/retaliate/clown/goblin/cluwne
