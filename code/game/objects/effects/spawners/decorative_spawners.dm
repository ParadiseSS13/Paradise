/obj/effect/spawner/random_spawners
	name = "random spawners"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "questionmark"
	var/list/result = list(
	/datum/nothing = 1,
	/obj/effect/decal/cleanable/blood/splatter = 1,
	/obj/effect/decal/cleanable/blood/oil = 1,
	/obj/effect/decal/cleanable/fungus = 1)
	var/spawn_inside = null

// This needs to use New() instead of Initialize() because the thing it creates might need to be initialized too
// AA 2022-08-11: The above comment doesnt even make sense. If extra atoms are loaded during SSatoms.Initialize(), they still get initialised!
/obj/effect/spawner/random_spawners/New()
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		stack_trace("Spawner placed in nullspace!")
		return
	randspawn(T)

/obj/effect/spawner/random_spawners/proc/randspawn(turf/T)
	var/thing_to_place = pickweight(result)
	if(ispath(thing_to_place, /datum/nothing))
		// Nothing.
		qdel(src) // See line 13, this needs moving to /Initialize() so we can use the qdel hint already
		return
	else if(ispath(thing_to_place, /turf))
		T.ChangeTurf(thing_to_place)
	else
		if(ispath(spawn_inside, /obj))
			var/obj/O = new thing_to_place(T)
			var/obj/E = new spawn_inside(T)
			O.forceMove(E)
		else
			new thing_to_place(T)
	qdel(src)
