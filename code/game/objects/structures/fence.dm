//Sprites ported from /VG/
/// Time to climb through a fence with a `SMALL_HOLE`.
#define CLIMB_TIME 15 SECONDS
/// Time to cut fences with `can_have_holes` = `TRUE`.
#define CUT_TIME 10 SECONDS
/// Time to cut fences with `can_have_holes` = `FALSE`.
#define FULL_CUT_TIME 30 SECONDS
/// Fully intact fence.
#define NO_HOLE 0 //section is intact
/// Small hole in fence, can be climbed through.
#define SMALL_HOLE 1
/// Large hole in fence, can be walked through.
#define LARGE_HOLE 2
/// Material cost to fix a fence section.
#define HOLE_REPAIR (hole_size * 2)

/obj/structure/fence
	name = "fence"
	desc = "A chain link fence. Not as effective as a wall, but generally it keeps people out."
	icon = 'icons/obj/fence.dmi'
	icon_state = "straight"
	density = TRUE
	anchored = TRUE
	/// Does this fence get cut in stages or all at once?
	var/can_have_holes = TRUE
	/// How big is the hole in this fence, if present?
	var/hole_size = NO_HOLE
	/// Cooldown on the fence applying shocks.
	var/shock_cooldown_duration = 1 SECONDS
	// Cooldown exists to stop shock spam on bumping.
	COOLDOWN_DECLARE(shock_cooldown)

/obj/structure/fence/Initialize(mapload)
	. = ..()
	update_cut_status()

/obj/structure/fence/examine(mob/user)
	. = ..()
	switch(hole_size)
		if(SMALL_HOLE)
			. += "There is a large hole in [src]."
		if(LARGE_HOLE)
			. += "[src] has been completely cut through."

/obj/structure/fence/CanPass(atom/movable/mover, border_dir)
	if(istype(mover) && mover.checkpass(PASSFENCE))
		return TRUE

	if(isprojectile(mover))
		return TRUE

	if(!density)
		return TRUE

	return FALSE

/obj/structure/fence/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(shock(user, 90))
		return ITEM_INTERACT_COMPLETE

	if(!istype(used, /obj/item/stack/rods))
		return NONE

	if(hole_size == NO_HOLE)
		return ITEM_INTERACT_COMPLETE

	var/obj/item/stack/rods/R = used
	if(R.get_amount() < HOLE_REPAIR)
		to_chat(user, SPAN_WARNING("You need [HOLE_REPAIR] rods to fix this fence!"))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_NOTICE("You begin repairing the fence..."))
	if(do_after_once(user, 3 SECONDS * used.toolspeed, target = src) && hole_size != NO_HOLE && R.use(HOLE_REPAIR))
		playsound(src, used.usesound, 80, 1)
		hole_size = NO_HOLE
		obj_integrity = max_integrity
		to_chat(user, SPAN_NOTICE("You repair the fence."))
		update_cut_status()
	return ITEM_INTERACT_COMPLETE

/obj/structure/fence/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(shock(user, 100))
		return

	if(flags & NODECONSTRUCT)
		to_chat(user, SPAN_WARNING("This fence is too strong to cut through!"))
		return

	user.visible_message(
		SPAN_WARNING("[user] starts cutting through [src] with [I]."),
		SPAN_NOTICE("You start cutting through [src] with [I].")
	)
	if(!can_have_holes)
		if(I.use_tool(src, user, FULL_CUT_TIME, volume = I.tool_volume, do_after_once = TRUE))
			user.visible_message(
				SPAN_WARNING("[user] completely dismantles [src]."),
				SPAN_NOTICE("You completely dismantle [src].")
			)
			deconstruct()
		return

	// Required to avoid tool spam from stacking and instantly cutting multiple stages at once.
	if(!I.use_tool(src, user, CUT_TIME * I.toolspeed, volume = I.tool_volume, do_after_once = TRUE))
		return

	switch(hole_size)
		if(NO_HOLE)
			user.visible_message(
				SPAN_WARNING("[user] cuts a hole into [src]."),
				SPAN_NOTICE("You could probably fit yourself through that hole. Although climbing through would be much faster if you made it even bigger...")
			)
		if(SMALL_HOLE)
			user.visible_message(
				SPAN_WARNING("[user] completely cuts through [src]."),
				SPAN_NOTICE("The hole in [src] is now big enough to walk through.")
			)
		if(LARGE_HOLE)
			user.visible_message(
				SPAN_WARNING("[user] completely dismantles [src]."),
				SPAN_NOTICE("You completely dismantle [src].")
			)
			deconstruct()
			return

	hole_size = hole_size + 1
	update_cut_status()

/obj/structure/fence/deconstruct(disassembled)
	. = ..()
	if(!(flags & NODECONSTRUCT))
		qdel(src)

/obj/structure/fence/proc/update_cut_status()
	if(!can_have_holes)
		return

	var/new_density = TRUE
	switch(hole_size)
		if(NO_HOLE)
			icon_state = initial(icon_state)
			climbable = FALSE
		if(SMALL_HOLE)
			icon_state = "straight_cut2"
			climbable = TRUE
		if(LARGE_HOLE)
			icon_state = "straight_cut3"
			new_density = FALSE
			climbable = FALSE
	set_density(new_density)

/obj/structure/fence/Bumped(atom/user)
	if(!ismob(user) || !COOLDOWN_FINISHED(src, shock_cooldown))
		return

	shock(user, 70)
	COOLDOWN_START(src, shock_cooldown, shock_cooldown_duration)

/obj/structure/fence/attack_hand(mob/user, list/modifiers)
	shock(user, 70)

/obj/structure/fence/attack_animal(mob/user)
	. = ..()
	if(. && !QDELETED(src) && !shock(user, 70))
		take_damage(rand(5,10), BRUTE, "melee", 1)

/*
	Shock `user` with probability `shock_chance` (if there's a powered wire node under the fence section).
	Returns `TRUE` if shocked, `FALSE` otherwise.
*/
/obj/structure/fence/proc/shock(mob/user, shock_chance)
	if(!prob(shock_chance))
		return FALSE

	if(!in_range(src, user)) // To prevent TK and mech users from getting shocked
		return FALSE

	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, 1, TRUE))
			do_sparks(3, 1, src)
			return TRUE

	return FALSE

/obj/structure/fence/cut/medium
	icon_state = "straight_cut2"
	hole_size = SMALL_HOLE
	climbable = TRUE

/obj/structure/fence/cut/large
	icon_state = "straight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/post
	icon_state = "post"
	can_have_holes = FALSE

/obj/structure/fence/corner
	icon_state = "corner"
	can_have_holes = FALSE

/obj/structure/fence/end
	icon_state = "end"
	can_have_holes = FALSE

/obj/structure/fence/door
	name = "fence door"
	desc = "A chain link fence door. Not very useful without a real lock."
	icon_state = "door_closed"
	can_have_holes = FALSE
	var/open = FALSE

/obj/structure/fence/door/Initialize(mapload)
	. = ..()
	update_door_status()

/obj/structure/fence/door/attack_hand(mob/user, list/modifiers)
	..()
	toggle(user)

/obj/structure/fence/door/proc/toggle(mob/user)
	open = !open
	visible_message(SPAN_NOTICE("[user] [open ? "opens" : "closes"] [src]."))
	update_door_status()
	playsound(src, 'sound/machines/door_open.ogg', 20, TRUE)

/obj/structure/fence/door/proc/update_door_status()
	set_density(!open)
	icon_state = open ? "door_opened" : "door_closed"

/obj/structure/fence/door/opened
	icon_state = "door_opened"
	open = TRUE

#undef CLIMB_TIME
#undef CUT_TIME
#undef FULL_CUT_TIME
#undef NO_HOLE
#undef SMALL_HOLE
#undef LARGE_HOLE
#undef HOLE_REPAIR
