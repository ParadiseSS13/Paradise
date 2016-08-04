/obj/item/weapon/grenade/clown_grenade
	name = "Banana Grenade"
	desc = "HONK! brand Bananas. In a special applicator for rapid slipping of wide areas."
	icon_state = "banana"
	item_state = "flashbang"
	w_class = 2
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/affected_area = 2

	prime()
		..()
		playsound(src.loc, 'sound/items/bikehorn.ogg', 25, -3)
		/*
		for(var/turf/simulated/floor/T in view(affected_area, src.loc))
			if(prob(75))
				banana(T)
		*/
		var/i = 0
		var/number = 0
		for(var/direction in alldirs)
			for(i = 0; i < 2; i++)
				number++
				var/obj/item/weapon/bananapeel/traitorpeel/peel = new /obj/item/weapon/bananapeel/traitorpeel(get_turf(src.loc))
			/*	var/direction = pick(alldirs)
				var/spaces = pick(1;150, 2)
				var/a = 0
				for(a = 0; a < spaces; a++)
					step(peel,direction)*/
				var/a = 1
				if(number & 2)
					for(a = 1; a <= 2; a++)
						step(peel,direction)
				else
					step(peel,direction)
		new /obj/item/weapon/bananapeel/traitorpeel(get_turf(src.loc))
		qdel(src)
		return
/*
	proc/banana(turf/T as turf)
		if(!T || !istype(T))
			return
		if(locate(/obj/structure/grille) in T)
			return
		if(locate(/obj/structure/window) in T)
			return
		new /obj/item/weapon/bananapeel/traitorpeel(T)
*/

/obj/item/weapon/bananapeel/traitorpeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 1
	throwforce = 0
	throw_speed = 4
	throw_range = 20

	Crossed(AM as mob|obj)
		var/burned = rand(2,5)
		if(istype(AM, /mob/living/carbon))
			var/mob/living/carbon/M = AM
			if(ishuman(M))
				if(isobj(M:shoes))
					if((M:shoes.flags&NOSLIP) || (M:species.bodyflags & FEET_NOSLIP))
						return
				else
					to_chat(M, "\red Your feet feel like they're on fire!")
					M.take_overall_damage(0, max(0, (burned - 2)))

			if(!istype(M, /mob/living/carbon/slime) && !isrobot(M))
				M.slip("banana peel!", 0, 7, 4)
				M.take_organ_damage(2) // Was 5 -- TLE
				M.take_overall_damage(0, burned)

	throw_impact(atom/hit_atom)
		var/burned = rand(1,3)
		if(istype(hit_atom ,/mob/living))
			var/mob/living/M = hit_atom
			M.take_organ_damage(0, burned)
		return ..()