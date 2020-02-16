/mob/living/simple_animal/hostile/retaliate/carp/koi/handle_automated_action()
	var/obj/structure/cable/C = locate() in loc
	var/turf/simulated/floor/F = get_turf(src)
	if(istype(F))
		///Evitar que los kois coman cables dentro de la estacion y debajo de tiles
	else
		if(prob(10))
			if(C.avail())
				visible_message("<span class='warning'>[src] chews through [C]. It's toast!</span>")
				playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
				C.deconstruct()
				toast()
			else
				C.deconstruct()
				visible_message("<span class='warning'>[src] chews through [C].</span>")
	..()

/mob/living/simple_animal/hostile/retaliate/carp/koi/proc/toast()
	add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
	desc = "It's toast."
	death()