/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	anchored = TRUE

	var/obj/item/target = null
	var/creator = null

	var/failchance = 5
	var/fail_icon = "portal1"

	var/precision = TRUE // how close to the portal you will teleport. FALSE = on the portal, TRUE = adjacent
	var/can_multitool_to_remove = FALSE
	var/ignore_tele_proof_area_setting = FALSE

/obj/effect/portal/New(loc, turf/target, creator = null, lifespan = 300)
	..()

	GLOB.portals += src

	src.target = target
	src.creator = creator

	if(lifespan > 0)
		spawn(lifespan)
			qdel(src)

/obj/effect/portal/Destroy()
	GLOB.portals -= src

	if(isobj(creator))
		var/obj/O = creator
		O.portal_destroyed(src)

	creator = null
	target = null
	return ..()

/obj/effect/portal/singularity_pull()
	return

/obj/effect/portal/singularity_act()
	return

/obj/effect/portal/Crossed(atom/movable/AM, oldloc)
	if(isobserver(AM))
		return ..()

	if(target && (get_turf(oldloc) == get_turf(target)))
		return ..()

	if(!teleport(AM))
		return ..()

/obj/effect/portal/attack_tk(mob/user)
	return

/obj/effect/portal/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(get_turf(user) == get_turf(src))
		teleport(user)
	if(Adjacent(user))
		user.forceMove(get_turf(src))

/obj/effect/portal/attack_ghost(mob/dead/observer/O)
	if(target)
		O.forceMove(target)

/obj/effect/portal/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(can_multitool_to_remove)
		qdel(src)
	else
		user.forceMove(get_turf(src))

/obj/effect/portal/proc/can_teleport(atom/movable/M)
	. = TRUE

	if(!istype(M))
		. = FALSE

	if(!M.simulated || iseffect(M))
		. = FALSE

	if(M.anchored && ismecha(M))
		. = FALSE

/obj/effect/portal/proc/teleport(atom/movable/M)
	if(!can_teleport(M))
		return FALSE

	if(!target)
		qdel(src)
		return FALSE

	if(ismegafauna(M))
		message_admins("[M] has used a portal at [ADMIN_VERBOSEJMP(src)] made by [key_name_admin(usr)].")

	if(prob(failchance))
		icon_state = fail_icon
		if(!do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 0, bypass_area_flag = ignore_tele_proof_area_setting)) // Try to send them to deep space.
			invalid_teleport()
			return FALSE
	else
		if(!do_teleport(M, target, precision, bypass_area_flag = ignore_tele_proof_area_setting)) // Try to send them to a turf adjacent to target.
			invalid_teleport()
			return FALSE

	return TRUE

/obj/effect/portal/proc/invalid_teleport()
	visible_message("<span class='warning'>[src] flickers and fails due to bluespace interference!</span>")
	do_sparks(5, 0, loc)
	qdel(src)

/obj/effect/portal/redspace
	name = "redspace portal"
	desc = "A portal capable of bypassing bluespace interference."
	icon_state = "portal1"
	failchance = 0
	precision = 0
	ignore_tele_proof_area_setting = TRUE
