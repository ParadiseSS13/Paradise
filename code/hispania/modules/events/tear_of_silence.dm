/datum/event/tear/silence
	var/obj/effect/tear/silence/HE //i could just inherit but its being finicky.

/datum/event/tear/silence/announce()
	GLOB.event_announcement.Announce("A Mimenomoly has opened. Expected location: [impact_area.name].", "Mimenomoly Alert", null)

/datum/event/tear/silence/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		HE = new /obj/effect/tear/silence(T.loc)

/datum/event/tear/silence/end()
	if(HE)
		qdel(HE)

/obj/effect/tear/silence
	name = "Mimensional Tear"
	desc = "A tear in the dimensional fabric of sanity."

/obj/effect/tear/silence/spew_critters()
	for(var/i in 1 to 6)
		var/mob/living/simple_animal/hostile/retaliate/mime_goblin/G = new(get_turf(src))
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(G, pick(NORTH, SOUTH, EAST, WEST))
