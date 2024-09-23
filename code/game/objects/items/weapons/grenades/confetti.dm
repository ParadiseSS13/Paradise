/obj/item/grenade/confetti
	name = "party grenade"
	desc = "Party time!"
	icon_state = "confetti"

/obj/item/grenade/confetti/prime()
	confettisize(src, 20, 4) //20 confettis. Yes.
	qdel(src)

/proc/confettisize(turf/simulated/T, volume, range)
	var/spawner_type = /obj/effect/decal/cleanable/confetti
	playsound(T, 'sound/effects/confetti_partywhistle.ogg', 70, 1)
	for(var/i in 1 to volume)
		var/atom/movable/x = new spawner_type(T)
		for(var/j in 1 to rand(1, range))
			step(x, pick(NORTH,SOUTH,EAST,WEST))
