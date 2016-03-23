/obj/item/weapon/grenade/confetti
	name = "party grenade"
	desc = "Party time!"
	icon_state = "confetti"
	var/spawner_type = /obj/effect/decal/cleanable/confetti

/obj/item/weapon/grenade/confetti/prime()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/confetti_partywhistle.ogg', 100, 1)
	for(var/i=1, i<=20, i++) //20 confettis. Yes.
		var/atom/movable/x = new spawner_type
		x.loc = T
		for(var/j = 1, j <= rand(1, 4), j++)
			step(x, pick(NORTH,SOUTH,EAST,WEST))

	qdel(src)
	return