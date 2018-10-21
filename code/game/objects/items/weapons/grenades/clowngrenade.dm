/obj/item/grenade/clown_grenade
	name = "Banana Grenade"
	desc = "HONK! brand Bananas. In a special applicator for rapid slipping of wide areas."
	icon_state = "banana"
	item_state = "flashbang"
	w_class = WEIGHT_CLASS_SMALL
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/affected_area = 2

/obj/item/grenade/clown_grenade/prime()
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
			var/obj/item/grown/bananapeel/traitorpeel/peel = new /obj/item/grown/bananapeel/traitorpeel(get_turf(src.loc))
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
	new /obj/item/grown/bananapeel/traitorpeel(get_turf(src.loc))
	qdel(src)
	return

/obj/item/grown/bananapeel/traitorpeel
	trip_stun = 0
	trip_weaken = 7
	trip_tiles = 4
	trip_walksafe = FALSE

	trip_chance = 100


/obj/item/grown/bananapeel/traitorpeel/on_trip(mob/living/carbon/human/H)
	. = ..()
	if(.)
		to_chat(H, "<span class='warning'>Your feet feel like they're on fire!</span>")
		H.take_overall_damage(0, rand(2,8))
		H.take_organ_damage(2) // Was 5 -- TLE

/obj/item/grown/bananapeel/traitorpeel/throw_impact(atom/hit_atom)
	var/burned = rand(1,3)
	if(istype(hit_atom ,/mob/living))
		var/mob/living/M = hit_atom
		M.take_organ_damage(0, burned)
	return ..()
