/mob/living/simple_animal/hostile/retaliate/carp/koi/handle_automated_action()
	var/turf/space/S = get_turf(src)
	var/obj/structure/cable/C = locate() in S //Las catwalk son estructuras sobre turf/space
	if(C && prob(30)) //Solo pueden comer cables del espacio
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
