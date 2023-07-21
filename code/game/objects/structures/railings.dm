/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/fence.dmi'
	icon_state = "railing"
	density = TRUE
	anchored = TRUE
	pass_flags = LETPASSTHROW
	climbable = TRUE
	layer = ABOVE_MOB_LAYER
	flags = ON_BORDER
	var/currently_climbed = FALSE
	var/mover_dir = null

/obj/structure/railing/corner //aesthetic corner sharp edges hurt oof ouch
	icon_state = "railing_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/railing/attackby(obj/item/I, mob/living/user, params)
	..()
	add_fingerprint(user)

/obj/structure/railing/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(. && M.environment_smash >= ENVIRONMENT_SMASH_WALLS)
		deconstruct(FALSE)
		M.visible_message("<span class='danger'>[M] tears apart [src]!</span>", "<span class='notice'>You tear apart [src]!</span>")


/obj/structure/railing/welder_act(mob/living/user, obj/item/I)
	if(user.intent != INTENT_HELP)
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return
	if(!I.tool_start_check(user, amount = 0))
		return
	to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
	if(I.use_tool(src, user, 40, volume = 50))
		obj_integrity = max_integrity
		to_chat(user, "<span class='notice'>You repair [src].</span>")

/obj/structure/railing/wirecutter_act(mob/living/user, obj/item/I)
	if(anchored)
		return
	to_chat(user, "<span class='warning'>You cut apart the railing.</span>")
	I.play_tool_sound(src, 100)
	deconstruct()
	return TRUE

/obj/structure/railing/deconstruct(disassembled)
	if(!(flags & NODECONSTRUCT))
		var/obj/item/stack/rods/rod = new /obj/item/stack/rods(drop_location(), 3)
		transfer_fingerprints_to(rod)
	return ..()

///Implements behaviour that makes it possible to unanchor the railing.
/obj/structure/railing/wrench_act(mob/living/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	to_chat(user, "<span class='notice'>You begin to [anchored ? "unfasten the railing from":"fasten the railing to"] the floor...</span>")
	if(I.use_tool(src, user, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "fasten the railing to":"unfasten the railing from"] the floor.</span>")
	return TRUE

/obj/structure/railing/corner/CanPass()
	return TRUE

/obj/structure/railing/corner/CanPathfindPass(obj/item/card/id/ID, to_dir, caller, no_id = FALSE)
	return TRUE

/obj/structure/railing/corner/CheckExit()
	return TRUE

/obj/structure/railing/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSFENCE))
		return TRUE
	if(istype(mover, /obj/item/projectile))
		return TRUE
	if(ismob(mover))
		var/mob/living/M = mover
		if(M.flying || (istype(M) && IS_HORIZONTAL(M) && HAS_TRAIT(M, TRAIT_CONTORTED_BODY)))
			return TRUE
	if(mover.throwing)
		return TRUE
	mover_dir = get_dir(loc, target)
	//Due to how the other check is done, it would always return density for ordinal directions no matter what
	if(ordinal_direction_check(mover_dir))
		return FALSE
	if(mover_dir != dir)
		return density
	return FALSE

/obj/structure/railing/CanPathfindPass(obj/item/card/id/ID, to_dir, caller, no_id = FALSE)
	if(to_dir == dir)
		return FALSE
	if(ordinal_direction_check(to_dir))
		return FALSE

	return TRUE

/obj/structure/railing/CheckExit(atom/movable/O, target)
	var/mob/living/M = O
	if(istype(O) && O.checkpass(PASSFENCE))
		return TRUE
	if(istype(O, /obj/item/projectile))
		return TRUE
	if(istype(M))
		if(M.flying || M.floating || (IS_HORIZONTAL(M) && HAS_TRAIT(M, TRAIT_CONTORTED_BODY)))
			return TRUE
	if(O.throwing)
		return TRUE
	if(O.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return TRUE
	if(currently_climbed)
		return TRUE
	mover_dir = get_dir(O.loc, target)
	if(mover_dir == dir)
		return FALSE
	if(ordinal_direction_check(mover_dir))
		return FALSE
	return TRUE

// Checks if the direction the mob is trying to move towards would be blocked by a corner railing
/obj/structure/railing/proc/ordinal_direction_check(check_dir)
	switch(dir)
		if(NORTHEAST)
			if(check_dir == NORTH || check_dir == EAST)
				return TRUE
		if(SOUTHEAST)
			if(check_dir == SOUTH || check_dir == EAST)
				return TRUE
		if(NORTHWEST)
			if(check_dir == NORTH || check_dir == WEST)
				return TRUE
		if(SOUTHWEST)
			if(check_dir == SOUTH || check_dir == WEST)
				return TRUE
	return FALSE

/obj/structure/railing/do_climb(mob/living/user)
	var/initial_mob_loc = get_turf(user)
	. = ..()
	if(.)
		currently_climbed = TRUE
		if(initial_mob_loc != get_turf(src)) // If we are on the railing, we want to move in the same dir as the railing. Otherwise we get put on the railing
			currently_climbed = FALSE
			return
		user.Move(get_step(user, dir), TRUE)
		currently_climbed = FALSE

/obj/structure/railing/proc/can_be_rotated(mob/user)
	if(anchored)
		to_chat(user, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, -45)

	if(!valid_window_location(loc, target_dir)) //Expanded to include rails, as well!
		to_chat(user, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE
	return TRUE

/obj/structure/railing/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/railing/proc/after_rotation(mob/user)
	add_fingerprint(user)

/obj/structure/railing/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	if(can_be_rotated(user))
		setDir(turn(dir, 45))
