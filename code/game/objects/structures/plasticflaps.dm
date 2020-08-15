/obj/structure/plasticflaps
	name = "plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = 4
	armor = list(melee = 100, bullet = 80, laser = 80, energy = 100, bomb = 50, bio = 100, rad = 100, fire = 50, acid = 50)
	var/state = PLASTIC_FLAPS_NORMAL

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	switch(state)
		if(PLASTIC_FLAPS_NORMAL)
			. += "<span class='notice'>[src] are <b>screwed</b> to the floor.</span>"
		if(PLASTIC_FLAPS_DETACHED)
			. += "<span class='notice'>[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>sliced</b> apart.</span>"

/obj/structure/plasticflaps/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(state == PLASTIC_FLAPS_NORMAL)
		user.visible_message("<span class='warning'>[user] starts unscrewing [src] from the floor...</span>", "<span class='notice'>You start to unscrew [src] from the floor...</span>", "You hear rustling noises.")
		if(!I.use_tool(src, user, 180, volume = I.tool_volume) || state != PLASTIC_FLAPS_NORMAL)
			return
		state = PLASTIC_FLAPS_DETACHED
		anchored = FALSE
		to_chat(user, "<span class='notice'>You unscrew [src] from the floor.</span>")
	else if(state == PLASTIC_FLAPS_DETACHED)
		user.visible_message("<span class='warning'>[user] starts screwing [src] to the floor.</span>", "<span class='notice'>You start to screw [src] to the floor...</span>", "You hear rustling noises.")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != PLASTIC_FLAPS_DETACHED)
			return
		state = PLASTIC_FLAPS_NORMAL
		anchored = TRUE
		to_chat(user, "<span class='notice'>You screw [src] to the floor.</span>")

/obj/structure/plasticflaps/welder_act(mob/user, obj/item/I)
	if(state != PLASTIC_FLAPS_DETACHED)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 120, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		var/obj/item/stack/sheet/plastic/five/P = new(drop_location())
		P.add_fingerprint(user)
		qdel(src)

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if(istype(A, /obj/structure/bed) && (B.has_buckled_mobs() || B.density))//if it's a bed/chair and is dense or someone is buckled, it will not pass
		return FALSE

	if(istype(A, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/C = A
		if(C.move_delay)
			return FALSE

	if(ismecha(A))
		return FALSE

	else if(isliving(A)) // You Shall Not Pass!
		var/mob/living/M = A
		if(isbot(A)) //Bots understand the secrets
			return TRUE
		if(M.buckled && istype(M.buckled, /mob/living/simple_animal/bot/mulebot)) // mulebot passenger gets a free pass.
			return TRUE
		if(!M.lying && !M.ventcrawler && M.mob_size != MOB_SIZE_TINY)	//If your not laying down, or a ventcrawler or a small creature, no pass.
			return FALSE
	return ..()


/obj/structure/plasticflaps/CanAStarPass(ID, to_dir, caller)
	if(isliving(caller))
		if(isbot(caller))
			return TRUE

		var/mob/living/M = caller
		if(!M.ventcrawler && M.mob_size != MOB_SIZE_TINY)
			return FALSE
	var/atom/movable/M = caller
	if(M && M.pulling)
		return CanAStarPass(ID, to_dir, M.pulling)
	return TRUE //diseases, stings, etc can pass

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

/obj/structure/plasticflaps/mining/Initialize()
	air_update_turf(TRUE)
	..()

/obj/structure/plasticflaps/mining/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/plasticflaps/mining/CanAtmosPass(turf/T)
	return FALSE
