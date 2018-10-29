/obj/structure/plasticflaps
	name = "plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = 4
	armor = list(melee = 100, bullet = 80, laser = 80, energy = 100, bomb = 50, bio = 100, rad = 100)
	var/list/mobs_can_pass = list(
		/mob/living/carbon/slime,
		/mob/living/simple_animal/mouse,
		/mob/living/silicon/robot/drone,
		/mob/living/simple_animal/bot/mulebot
		)
	var/state = PLASTIC_FLAPS_NORMAL

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	switch(state)
		if(PLASTIC_FLAPS_NORMAL)
			to_chat(user, "<span class='notice'>[src] are <b>screwed</b> to the floor.</span>")
		if(PLASTIC_FLAPS_DETACHED)
			to_chat(user, "<span class='notice'>[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>sliced</b> apart.</span>")

/obj/structure/plasticflaps/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(isscrewdriver(W))
		if(state == PLASTIC_FLAPS_NORMAL)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] unscrews [src] from the floor.</span>", "<span class='notice'>You start to unscrew [src] from the floor...</span>", "You hear rustling noises.")
			if(do_after(user, 180*W.toolspeed, target = src))
				if(state != PLASTIC_FLAPS_NORMAL)
					return
				state = PLASTIC_FLAPS_DETACHED
				anchored = FALSE
				to_chat(user, "<span class='notice'>You unscrew [src] from the floor.</span>")
		else if(state == PLASTIC_FLAPS_DETACHED)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] screws [src] to the floor.</span>", "<span class='notice'>You start to screw [src] to the floor...</span>", "You hear rustling noises.")
			if(do_after(user, 40*W.toolspeed, target = src))
				if(state != PLASTIC_FLAPS_DETACHED)
					return
				state = PLASTIC_FLAPS_NORMAL
				anchored = TRUE
				to_chat(user, "<span class='notice'>You screw [src] to the floor.</span>")
	else if(iswelder(W))
		if(state == PLASTIC_FLAPS_DETACHED)
			var/obj/item/weldingtool/WT = W
			if(!WT.remove_fuel(0, user))
				return
			playsound(loc, WT.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] slices apart [src].</span>", "<span class='notice'>You start to slice apart [src].</span>", "You hear welding.")
			if(do_after(user, 120*WT.toolspeed, target = src))
				if(state != PLASTIC_FLAPS_DETACHED)
					return
				to_chat(user, "<span class='notice'>You slice apart [src].</span>")
				var/obj/item/stack/sheet/plastic/five/P = new(loc)
				P.add_fingerprint(user)
				qdel(src)
	else
		. = ..()

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if(istype(A, /obj/structure/bed) && B.buckled_mob)//if it's a bed/chair and someone is buckled, it will not pass
		return 0

	if(istype(A, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/C = A
		if(C.move_delay)
			return 0

	if(istype(A, /obj/vehicle))	//no vehicles
		return 0

	var/mob/living/M = A
	if(istype(M))
		if(M.lying)
			return ..()
		for(var/mob_type in mobs_can_pass)
			if(istype(A, mob_type))
				return ..()
		if(istype(A, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.dna.species.is_small)
				return ..()
		return 0

	return ..()


/obj/structure/plasticflaps/CanAStarPass(ID, to_dir, caller)
	if(istype(caller, /mob/living))
		for(var/mob_type in mobs_can_pass)
			if(istype(caller, mob_type))
				return 1

		var/mob/living/M = caller
		if(!M.ventcrawler && M.mob_size > MOB_SIZE_SMALL)
			return 0
	return 1

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
		if(3)
			if(prob(5))
				qdel(src)

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(can_deconstruct)
		new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

/obj/structure/plasticflaps/mining/Initialize()
	air_update_turf(1)
	..()

/obj/structure/plasticflaps/mining/Destroy()
	air_update_turf(1)
	return ..()

/obj/structure/plasticflaps/mining/CanAtmosPass(turf/T)
	return 0
