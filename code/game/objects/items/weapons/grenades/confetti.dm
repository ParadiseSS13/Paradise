/obj/item/grenade/confetti
	name = "party grenade"
	desc = "Party time!"
	icon_state = "confetti"
	var/spawner_type = /obj/effect/decal/cleanable/confetti

/obj/item/grenade/confetti/prime()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/confetti_partywhistle.ogg', 100, 1)
	for(var/i in 1 to 20) //20 confettis. Yes.
		var/atom/movable/x = new spawner_type
		x.loc = T
		for(var/j in 1 to rand(1, 4))
			step(x, pick(NORTH,SOUTH,EAST,WEST))

	qdel(src)
