//Chain link fences
//Sprites ported from /VG/

#define CUT_TIME 100
#define CLIMB_TIME 150
#define FULL_CUT_TIME 300

#define NO_HOLE 0 //section is intact
#define MEDIUM_HOLE 1 //medium hole in the section - can climb through
#define LARGE_HOLE 2 //large hole in the section - can walk through
#define MAX_HOLE_SIZE LARGE_HOLE
#define HOLE_REPAIR (hole_size * 2) //How many rods to fix these sections

/obj/structure/fence
	name = "fence"
	desc = "A chain link fence. Not as effective as a wall, but generally it keeps people out."
	density = TRUE
	anchored = TRUE

	icon = 'icons/obj/fence.dmi'
	icon_state = "straight"

	var/cuttable = TRUE
	var/hole_size = NO_HOLE
	var/invulnerable = FALSE
	var/shock_cooldown = FALSE

/obj/structure/fence/Initialize(mapload)
	. = ..()
	update_cut_status()

/obj/structure/fence/examine(mob/user)
	. = ..()
	switch(hole_size)
		if(MEDIUM_HOLE)
			. += "There is a large hole in \the [src]."
		if(LARGE_HOLE)
			. += "\The [src] has been completely cut through."

/obj/structure/fence/end
	icon_state = "end"
	cuttable = FALSE

/obj/structure/fence/corner
	icon_state = "corner"
	cuttable = FALSE

/obj/structure/fence/post
	icon_state = "post"
	cuttable = FALSE

/obj/structure/fence/cut/medium
	icon_state = "straight_cut2"
	hole_size = MEDIUM_HOLE
	climbable = TRUE

/obj/structure/fence/cut/large
	icon_state = "straight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/CanPass(atom/movable/mover, border_dir)
	if(istype(mover) && mover.checkpass(PASSFENCE))
		return TRUE
	if(isprojectile(mover))
		return TRUE
	if(!density)
		return TRUE
	return FALSE

/*
	Shock user with probability prb (if all connections & power are working)
	Returns TRUE if shocked, FALSE otherwise
	Totally not stolen from code\game\objects\structures\grille.dm
*/
/obj/structure/fence/proc/shock(mob/user, prb)
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user)) //To prevent TK and mech users from getting shocked
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, 1, TRUE))
			do_sparks(3, 1, src)
			return TRUE
	return FALSE

/obj/structure/fence/wirecutter_act(mob/living/user, obj/item/W)
	. = TRUE
	if(shock(user, 100))
		return
	if(invulnerable)
		to_chat(user, "<span class='warning'>This fence is too strong to cut through!</span>")
		return
	if(!cuttable)
		user.visible_message("<span class='warning'>[user] starts dismantling [src] with [W].</span>",\
		"<span class='warning'>You start dismantling [src] with [W].</span>")
		if(W.use_tool(src, user, FULL_CUT_TIME, volume = W.tool_volume))
			user.visible_message("<span class='notice'>[user] completely dismantles [src].</span>",\
			"<span class='notice'>You completely dismantle [src].</span>")
			qdel(src)
		return
	var/current_stage = hole_size
	user.visible_message("<span class='warning'>[user] starts cutting through [src] with [W].</span>",\
	"<span class='warning'>You start cutting through [src] with [W].</span>")
	if(W.use_tool(src, user, CUT_TIME * W.toolspeed, volume = W.tool_volume))
		if(current_stage == hole_size)
			switch(hole_size)
				if(NO_HOLE)
					user.visible_message("<span class='notice'>[user] cuts into [src] some more.</span>",\
					"<span class='notice'>You could probably fit yourself through that hole now. Although climbing through would be much faster if you made it even bigger.</span>")
					hole_size = MEDIUM_HOLE
				if(MEDIUM_HOLE)
					user.visible_message("<span class='notice'>[user] completely cuts through [src].</span>",\
					"<span class='notice'>The hole in [src] is now big enough to walk through.</span>")
					hole_size = LARGE_HOLE
				if(LARGE_HOLE)
					user.visible_message("<span class='notice'>[user] completely dismantles [src].</span>",\
					"<span class='notice'>You completely take apart [src].</span>")
					qdel(src)
					return
			update_cut_status()

/obj/structure/fence/item_interaction(mob/living/user, obj/item/C, list/modifiers)
	if(shock(user, 90))
		return ITEM_INTERACT_COMPLETE
	if(istype(C, /obj/item/stack/rods))
		if(hole_size == NO_HOLE)
			return ITEM_INTERACT_COMPLETE
		var/obj/item/stack/rods/R = C
		if(R.get_amount() < HOLE_REPAIR)
			to_chat(user, "<span class='warning'>You need [HOLE_REPAIR] rods to fix this fence!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You begin repairing the fence...</span>")
		if(do_after(user, 3 SECONDS * C.toolspeed, target = src) && hole_size != NO_HOLE && R.use(HOLE_REPAIR))
			playsound(src, C.usesound, 80, 1)
			hole_size = NO_HOLE
			obj_integrity = max_integrity
			to_chat(user, "<span class='notice'>You repair the fence.</span>")
			update_cut_status()
		return ITEM_INTERACT_COMPLETE

/obj/structure/fence/Bumped(atom/user)
	if(!ismob(user))
		return
	if(shock_cooldown)
		return
	shock(user, 70)
	shock_cooldown = TRUE // We do not want bump shock spam!
	addtimer(CALLBACK(src, PROC_REF(shock_cooldown)), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/structure/fence/proc/shock_cooldown()
	shock_cooldown = FALSE

/obj/structure/fence/attack_animal(mob/user)
	. = ..()
	if(. && !QDELETED(src) && !shock(user, 70))
		take_damage(rand(5,10), BRUTE, "melee", 1)

/obj/structure/fence/proc/update_cut_status()
	if(!cuttable)
		return
	var/new_density = TRUE
	switch(hole_size)
		if(NO_HOLE)
			icon_state = initial(icon_state)
			climbable = FALSE
		if(MEDIUM_HOLE)
			icon_state = "straight_cut2"
			climbable = TRUE
		if(LARGE_HOLE)
			icon_state = "straight_cut3"
			new_density = FALSE
			climbable = FALSE
	set_density(new_density)

//FENCE DOORS

/obj/structure/fence/door
	name = "fence door"
	desc = "Not very useful without a real lock."
	icon_state = "door_closed"
	cuttable = FALSE
	var/open = FALSE

/obj/structure/fence/door/Initialize(mapload)
	. = ..()
	update_door_status()

/obj/structure/fence/door/opened
	icon_state = "door_opened"
	open = TRUE

/obj/structure/fence/door/attack_hand(mob/user, list/modifiers)
	shock(user, 70)
	if(can_open(user))
		toggle(user)
	return TRUE

/obj/structure/fence/door/proc/toggle(mob/user)
	open = !open
	visible_message("<span class='notice'>\The [user] [open ? "opens" : "closes"] \the [src].</span>")
	update_door_status()
	playsound(src, 'sound/machines/door_open.ogg', 100, TRUE)

/obj/structure/fence/door/proc/update_door_status()
	set_density(!open)
	icon_state = open ? "door_opened" : "door_closed"

/obj/structure/fence/door/proc/can_open(mob/user)
	return TRUE

#undef CUT_TIME
#undef CLIMB_TIME
#undef FULL_CUT_TIME

#undef NO_HOLE
#undef MEDIUM_HOLE
#undef LARGE_HOLE
#undef MAX_HOLE_SIZE
#undef HOLE_REPAIR
