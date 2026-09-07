// MARK: Wall
/obj/item/inflatable
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall"
	var/structure_type = /obj/structure/inflatable
	var/torn = FALSE
	new_attack_chain = TRUE

/obj/item/inflatable/examine(mob/user)
	. = ..()
	if(!torn)
		. += SPAN_NOTICE("<b>Use this item in hand</b> to create an inflatable wall.")
	else
		. += SPAN_WARNING("[src] is torn and cannot hold air anymore. It's completely useless now.")


/obj/item/inflatable/activate_self(mob/user)
	if(..())
		return

	inflate(user, user)
	return ITEM_INTERACT_COMPLETE

/obj/item/inflatable/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	inflate(user, target)
	return ITEM_INTERACT_COMPLETE

/obj/item/inflatable/proc/inflate(mob/user, atom/target)
	if(torn)
		add_fingerprint(user)
		to_chat(user, SPAN_WARNING("[src] is torn and cannot be inflated anymore!"))
		return

	var/turf/T = get_turf(target)
	if(iswallturf(T))
		return

	if((locate(/obj/structure/inflatable) in T) || (locate(/obj/structure/window/full) in T))
		to_chat(user, SPAN_WARNING("There's no room to deploy [src] here!"))
		return

	var/obj/machinery/door/airlock = locate(/obj/machinery/door) in T
	var/obj/structure/mineral_door/mineral_door = locate(/obj/structure/mineral_door) in T
	if(mineral_door && mineral_door.density)
		to_chat(user, SPAN_WARNING("You need to open [mineral_door] before you can deploy [src] there!"))
		return

	if(airlock && airlock.density && !istype(airlock, /obj/machinery/door/window))
		to_chat(user, SPAN_WARNING("You need to open [airlock] before you can deploy [src] there!"))
		return

	playsound(loc, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, SPAN_NOTICE("You inflate [src]."))
	var/obj/structure/inflatable/R = new structure_type(T)
	src.transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	if(!isrobot(loc))
		qdel(src)

/obj/item/inflatable/torn
	name = "torn inflatable wall"
	icon_state = "folded_wall_torn"
	torn = TRUE

/obj/structure/inflatable
	name = "inflatable wall"
	desc = "An inflated membrane. Do not puncture."
	density = TRUE
	anchored = TRUE
	max_integrity = 50
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall"
	var/torn = /obj/item/inflatable/torn
	var/intact = /obj/item/inflatable

/obj/structure/inflatable/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("<b>Alt-Click</b> to deflate [src].")

/obj/structure/inflatable/Initialize(mapload, location)
	. = ..()
	recalculate_atmos_connectivity()

/obj/structure/inflatable/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.recalculate_atmos_connectivity()

/obj/structure/inflatable/CanPass(atom/movable/mover, border_dir)
	return

/obj/structure/inflatable/CanAtmosPass(direction)
	return !density

/obj/structure/inflatable/attack_hand(mob/user)
	add_fingerprint(user)

/obj/structure/inflatable/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!used.sharp && !is_type_in_typecache(used, GLOB.pointed_types))
		return ..()

	user.do_attack_animation(src, used_item = used)
	deconstruct(FALSE)
	return ITEM_INTERACT_COMPLETE

/obj/structure/inflatable/AltClick()
	if(usr.stat || usr.restrained())
		return

	if(!Adjacent(usr))
		return

	deconstruct(TRUE)

/obj/structure/inflatable/deconstruct(disassembled = TRUE)
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	if(!disassembled)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/torn/R = new torn(loc)
		transfer_fingerprints_to(R)
		qdel(src)
	else
		visible_message("[src] slowly deflates.")
		addtimer(CALLBACK(src, PROC_REF(deflate)), 5 SECONDS)

/obj/structure/inflatable/proc/deflate()
	var/obj/item/inflatable/R = new intact(loc)
	transfer_fingerprints_to(R)
	qdel(src)

// MARK: Door
/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple airtight door on activation."
	icon_state = "folded_door"
	structure_type = /obj/structure/inflatable/door

/obj/item/inflatable/door/torn
	name = "torn inflatable door"
	icon_state = "folded_door_torn"
	torn = TRUE

/// Based on mineral door code
/obj/structure/inflatable/door
	name = "inflatable door"
	icon_state = "door_closed"
	torn = /obj/item/inflatable/door/torn
	intact = /obj/item/inflatable/door

	var/state_open = FALSE
	var/is_operating = FALSE

/obj/structure/inflatable/door/attack_ai(mob/user as mob)
	if(is_ai(user)) // The AI can't open it.
		return

	if(isrobot(user) && Adjacent(user)) // Cyborgs can, but not remotely.
		return try_to_operate(user)

/obj/structure/inflatable/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		operate()

/obj/structure/inflatable/door/attack_hand(mob/user as mob)
	return try_to_operate(user)

/obj/structure/inflatable/door/CanPass(atom/movable/mover, border_dir)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/inflatable/door/CanAtmosPass(direction)
	return !density

/obj/structure/inflatable/door/proc/try_to_operate(atom/user)
	if(is_operating)
		return

	if(ismecha(user))
		operate()
		return

	if(ismob(user))
		var/mob/M = user
		if(!M.client)
			operate()
			return

		if(!iscarbon(M))
			operate()
			return

		var/mob/living/carbon/C = M
		if(!C.handcuffed)
			operate()

/obj/structure/inflatable/door/proc/operate()
	is_operating = TRUE
	//playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 100, 1)
	if(!state_open)
		flick("door_opening",src)
	else
		flick("door_closing",src)
	sleep(10)
	density = !density
	state_open = !state_open
	update_icon(UPDATE_ICON_STATE)
	is_operating = FALSE
	recalculate_atmos_connectivity()

/obj/structure/inflatable/door/update_icon_state()
	if(state_open)
		icon_state = "door_open"
	else
		icon_state = "door_closed"

// MARK: Robot Module
/obj/item/inflatable/cyborg
	var/power_cost = 400
	/// How long it takes to inflate.
	var/delay = 1 SECONDS

/obj/item/inflatable/cyborg/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon_state = "folded_door"
	power_cost = 600
	structure_type = /obj/structure/inflatable/door

/obj/item/inflatable/cyborg/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("As a synthetic, you will synthesise these directly from your cell's energy reserves.")

/obj/item/inflatable/cyborg/activate_self(mob/user)
	if(!do_after(user, delay, FALSE, user))
		return ITEM_INTERACT_COMPLETE

	if(!useResource(user))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/inflatable/cyborg/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!do_after(user, delay, FALSE, user))
		return ITEM_INTERACT_COMPLETE

	if(!useResource(user))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/inflatable/cyborg/proc/useResource(mob/user)
	if(!isrobot(user))
		return FALSE

	var/mob/living/silicon/robot/R = user
	if(R.cell.charge < power_cost)
		to_chat(user, SPAN_WARNING("Not enough power!"))
		return FALSE

	return R.cell.use(power_cost)

// MARK: Briefcase
/obj/item/storage/briefcase/inflatable
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf_box"
	inhand_icon_state = "syringe_kit"
	w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/inflatable)
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500)

/obj/item/storage/briefcase/inflatable/populate_contents()
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable/door(src)
	new /obj/item/inflatable(src)
	new /obj/item/inflatable(src)
	new /obj/item/inflatable(src)
	new /obj/item/inflatable(src)
