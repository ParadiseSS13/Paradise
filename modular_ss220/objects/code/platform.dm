// Platform Code by Danaleja2005
/obj/structure/platform
	name = "platform"
	icon = 'modular_ss220/objects/icons/platform.dmi'
	icon_state = "metal"
	desc = "A metal platform."
	flags = ON_BORDER
	anchored = FALSE
	climbable = TRUE
	max_integrity = 200
	armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 50, BOMB = 20, RAD = 0, FIRE = 30, ACID = 30)
	var/corner = FALSE
	var/material_type = /obj/item/stack/sheet/metal
	var/material_amount = 4
	var/decon_speed

/obj/structure/platform/proc/CheckLayer()
	if(dir == SOUTH)
		layer = ABOVE_MOB_LAYER
	else if(corner || dir == NORTH)
		layer = BELOW_MOB_LAYER

/obj/structure/platform/setDir(newdir)
	. = ..()
	CheckLayer()

/obj/structure/platform/Initialize()
	. = ..()
	CheckLayer()

/obj/structure/platform/New()
	..()
	if(corner)
		decon_speed = 20
		density = FALSE
		climbable = FALSE
	else
		decon_speed = 30
	CheckLayer()

/obj/structure/platform/examine(mob/user)
	. = ..()
	. += span_notice("[src] is [anchored == TRUE ? "screwed" : "unscrewed"] [anchored == TRUE ? "to" : "from"] the floor.")
	. += span_notice("<b>Alt-Click</b> to rotate.")

/obj/structure/platform/proc/rotate(mob/user)
	if(user.incapacitated())
		return

	if(anchored)
		to_chat(user, span_warning("[src] cannot be rotated while it is screwed to the floor!"))
		return FALSE

	var/target_dir = turn(dir, 90)

	setDir(target_dir)
	recalculate_atmos_connectivity()
	add_fingerprint(user)
	return TRUE

/obj/structure/platform/AltClick(mob/user)
	rotate(user)

// Construction
/obj/structure/platform/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	to_chat(user, span_notice("You begin [anchored == TRUE ? "unscrewing" : "screwing"] [src] [anchored == TRUE ? "from" : "to"] the floor."))
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume))
		return
	to_chat(user, span_notice("You [anchored == TRUE ? "unscrew" : "screw"] [src] [anchored == TRUE ? "from" : "to"] the floor."))
	anchored = !anchored

/obj/structure/platform/wrench_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(anchored)
		to_chat(user, span_notice("You cannot disassemble [src], unscrew it first!"))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume))
		return
	var/obj/item/stack/sheet/G = new material_type(user.loc, material_amount)
	G.add_fingerprint(user)
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
	TOOL_DISMANTLE_SUCCESS_MESSAGE
	qdel(src)


/obj/structure/platform/CheckExit(atom/movable/O, turf/target)
	if(!anchored)
		CheckLayer()
	if(istype(O, /obj/structure/platform))
		return FALSE
	if(istype(O, /obj/item/projectile) || istype(O, /obj/effect))
		return TRUE
	if(corner)
		return !density
	if(O && O.throwing)
		return TRUE
	if(((flags & ON_BORDER) && get_dir(loc, target) == dir))
		return FALSE
	else
		return TRUE

/obj/structure/platform/CanPass(atom/movable/mover, turf/target)
	if(!anchored)
		CheckLayer()
	if(istype(mover, /obj/structure/platform))
		return FALSE
	if(istype(mover, /obj/item/projectile))
		return TRUE
	if(corner)
		return !density
	if(mover && mover.throwing)
		return TRUE
	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags & ON_BORDER) && climbable && isliving(mover))// Climbable objects allow you to universally climb over others
		return TRUE
	if(!(flags & ON_BORDER) || get_dir(loc, target) == dir)
		return FALSE
	else
		return TRUE

/obj/structure/platform/do_climb(mob/living/user)
	if(!can_touch(user) || !climbable)
		return
	var/blocking_object = density_check()
	if(blocking_object)
		to_chat(user, span_warning("You cannot climb over [src], as it is blocked by \a [blocking_object]!"))
		return

	var/destination_climb = get_step(src, dir)
	if(is_blocked_turf(destination_climb))
		to_chat(user, span_warning("You cannot climb over [src], the path is blocked!"))
		return
	var/turf/T = src.loc
	if(!T || !istype(T)) return

	if(get_turf(user) == get_turf(src))
		usr.visible_message(span_warning("[user] starts climbing over \the [src]!"))
	else
		usr.visible_message(span_warning("[user] starts getting off \the [src]!"))
	climber = user
	if(!do_after(user, 50, target = src))
		climber = null
		return

	if(!can_touch(user) || !climbable)
		climber = null
		return

	if(get_turf(user) == get_turf(src))
		usr.loc = get_step(src, dir)
		usr.visible_message(span_warning("[user] leaves \the [src]!"))
	else
		usr.loc = get_turf(src)
		usr.visible_message(span_warning("[user] starts climbing over \the [src]!"))
	climber = null

/obj/structure/platform/CanAtmosPass()
	return TRUE

// Platform types
/obj/structure/platform/reinforced
	name = "reinforced platform"
	desc = "A robust platform made of plasteel, more resistance for hazard sites."
	icon_state = "plasteel"
	material_type = /obj/item/stack/sheet/plasteel
	max_integrity = 300
	armor = list(MELEE = 20, BULLET = 30, LASER = 30, ENERGY = 100, BOMB = 50, RAD = 75, FIRE = 100, ACID = 100)

// Platform corners
/obj/structure/platform/corner
	name = "platform corner"
	desc = "A metal platform corner."
	icon_state = "metalcorner"
	corner = TRUE
	material_amount = 2

/obj/structure/platform/reinforced/corner
	name = "reinforced platform corner"
	desc = "A robust platform corner made of plasteel, more resistance for hazard sites."
	icon_state = "plasteelcorner"
	corner = TRUE
	material_amount = 2
