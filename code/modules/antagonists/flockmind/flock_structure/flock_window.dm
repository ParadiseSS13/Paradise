/obj/structure/window/flock
	icon = 'icons/goonstation/mob/featherzone.dmi'
	pass_flags = PASSFLOCK
	heat_resistance = 32000
	glass_type = /obj/item/stack/sheet/gnesis_glass

/obj/structure/window/flock/Initialize(mapload, direct)
	. = ..()
	AddComponent(/datum/component/flock_object)
	AddComponent(/datum/component/flock_protection, report_unarmed=FALSE)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_crossed),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	ADD_TRAIT(src, TRAIT_FLOCK_THING, INNATE_TRAIT)

/obj/structure/window/flock/proc/on_crossed(atom/source, atom/movable/crosser)
	SIGNAL_HANDLER

	if(!isflockdrone(crosser))
		return

	if(!HAS_TRAIT(crosser, TRAIT_FLOCKPHASE))
		animate_flockpass(crosser)

/obj/structure/window/flock/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> Transparent Barrier"),
		SPAN_FLOCKSAY("<b>System Integrity:</b> [get_integrity_percentage()]%"),
		SPAN_FLOCKSAY("<b>###=-</b>")
	)

/obj/structure/window/flock/CanPass(atom/movable/mover, border_dir)
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

/obj/structure/window/flock/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	var/atom/M = locateUID(pass_info.caller_uid)
	if(!M)
		return ..()
	if(!isflockdrone(M))
		return ..()
	var/mob/living/basic/flock/drone/bird = M
	if(!bird.can_flockphase())
		return ..()
	return TRUE

/obj/structure/window/flock/fulltile
	dir = SOUTHWEST
	fulltile = TRUE

/obj/structure/window/flock/try_flock_convert(datum/flock/flock, force)
	return
