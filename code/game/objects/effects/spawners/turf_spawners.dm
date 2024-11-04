/obj/effect/spawner/random_spawners/proc/rustify(turf/T)
	var/turf/simulated/wall/W = T
	if(istype(W) && !HAS_TRAIT(W, TRAIT_RUSTY))
		W.rust_turf()

/obj/effect/spawner/random_spawners/wall_rusted_probably
	name = "rusted wall probably"
	icon_state = "rust"

/obj/effect/spawner/random_spawners/wall_rusted_probably/randspawn(turf/T)
	if(prob(75))
		rustify(T)
	qdel(src)

/obj/effect/spawner/random_spawners/wall_rusted_maybe
	name = "rusted wall maybe"
	icon_state = "rust"

/obj/effect/spawner/random_spawners/wall_rusted_maybe/randspawn(turf/T)
	if(prob(25))
		rustify(T)
	qdel(src)

/obj/effect/spawner/random_spawners/wall_rusted_always
	name = "rusted wall always"
	icon_state = "rust"

/obj/effect/spawner/random_spawners/wall_rusted_always/randspawn(turf/T)
	rustify(T)
	qdel(src)
