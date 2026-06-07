/obj/structure/closet/flock
	name = "pulsing cache"
	desc = "A large closet-like structure that appears to lack a handle. The doors seem to open to the touch."
	icon_state = "flock"
	max_integrity = 100
	armor = list(MELEE = -20, BULLET = -20, LASER = 80, ENERGY = 80, BOMB = 0, RAD = 100, FIRE = 80, ACID = 100)
	pass_flags = PASSFLOCK
	material_drop = /obj/item/stack/sheet/gnesis
	enable_door_overlay = FALSE

/obj/structure/closet/flock/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_crossed),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/flock_protection, FALSE, TRUE, FALSE, FALSE)
	ADD_TRAIT(src, TRAIT_FLOCK_EXAMINE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)

/obj/structure/closet/flock/proc/on_crossed(atom/source, atom/movable/crosser)
	SIGNAL_HANDLER

	if(!isflockdrone(crosser) || broken)
		return

	if(!HAS_TRAIT(crosser, TRAIT_FLOCKPHASE))
		animate_flockpass(crosser)

/obj/structure/closet/flock/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return .

	if(!isflockdrone(mover))
		return .

	var/mob/living/basic/flock/drone/bird = mover
	if(HAS_TRAIT(bird, TRAIT_FLOCKPHASE))
		return TRUE

	if(bird.can_flockphase())
		return TRUE

/obj/structure/closet/flock/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	var/atom/M = locateUID(pass_info.caller_uid)
	if(!M)
		return ..()
	if(!isflockdrone(M))
		return ..()
	var/mob/living/basic/flock/drone/bird = M
	if(!bird.can_flockphase())
		return ..()
	return TRUE

/obj/structure/closet/flock/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> Storage Capsule"),
		SPAN_FLOCKSAY("<b>System Integrity:</b> [get_integrity_percentage()]%"),
		SPAN_FLOCKSAY("<b>###=-</b>")
	)

/obj/structure/closet/flock/try_flock_convert(datum/flock/flock, force)
	return
