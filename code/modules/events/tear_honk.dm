/datum/event/tear/honk
	var/obj/effect/tear/honk/HE //i could just inherit but its being finicky.

/datum/event/tear/honk/announce()
	event_announcement.Announce("A Honknomoly has opened. Expected location: [impact_area.name].", "Honknomoly Alert", 'sound/items/airhorn.ogg')

/datum/event/tear/honk/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		HE = new /obj/effect/tear/honk(T.loc)

/datum/event/tear/honk/end()
	if(HE)
		qdel(HE)

/obj/effect/tear/honk
	name="Honkmensional Tear"
	desc="A tear in the dimensional fabric of sanity."
	icon='icons/effects/tear.dmi'
	icon_state="tear"
	tear_critters = list(/mob/living/simple_animal/hostile/retaliate/clown/goblin)

/obj/effect/tear/honk/New()
	var/atom/movable/overlay/animation = null
	animation = new(loc)
	animation.icon_state = "newtear"
	animation.icon = 'icons/effects/tear.dmi'
	animation.master = src
	spawn(15)
		if(animation)
			qdel(animation)

	spawn(rand(30,120))

		for(var/i in 1 to 6)
			var/chosen = pick(tear_critters)
			var/mob/living/simple_animal/C = new chosen
			C.forceMove(get_turf(src))
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(C, pick(NORTH,SOUTH,EAST,WEST))
