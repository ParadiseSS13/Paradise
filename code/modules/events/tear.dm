/datum/event/tear
	startWhen = 3
	announceWhen = 20
	endWhen = 50
	var/obj/effect/tear/TE

/datum/event/tear/announce()
	event_announcement.Announce("A tear in the fabric of space and time has opened. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/event/tear/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		TE = new /obj/effect/tear(T.loc)

/datum/event/tear/setup()
	impact_area = findEventArea()

/datum/event/tear/end()
	if(TE)
		qdel(TE)

/obj/effect/tear
	name="Dimensional Tear"
	desc="A tear in the dimensional fabric of space and time."
	icon='icons/effects/tear.dmi'
	icon_state="tear"
	unacidable = 1
	density = 0
	anchored = 1
	luminosity = 3
	var/list/tear_critters = list()

/obj/effect/tear/New()
	..()
	var/atom/movable/overlay/animation = null
	animation = new(loc)
	animation.icon_state = "newtear"
	animation.icon = 'icons/effects/tear.dmi'
	animation.master = src
//	flick("newtear",usr)
	spawn(15)
		if(animation)
			qdel(animation)

	spawn(rand(30,120))
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			if(initial(SA.gold_core_spawnable) == CHEM_MOB_SPAWN_HOSTILE)
				tear_critters += T

		for(var/i in 1 to 5)
			var/chosen = pick(tear_critters)
			var/mob/living/simple_animal/C = new chosen
			C.faction |= "chemicalsummon"
			C.forceMove(get_turf(src))
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(C, pick(NORTH,SOUTH,EAST,WEST))
