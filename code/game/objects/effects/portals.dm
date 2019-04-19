/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	unacidable = 1//Can't destroy energy portals.
	var/failchance = 5
	var/obj/item/target = null
	var/creator = null
	anchored = 1
	var/precision = 1 // how close to the portal you will teleport. 0 = on the portal, 1 = adjacent
	var/can_multitool_to_remove = 0
	var/ignore_tele_proof_area_setting = FALSE

/obj/effect/portal/Bumped(mob/M as mob|obj)
	teleport(M)

/obj/effect/portal/New(loc, turf/target, creator=null, lifespan=300)
	GLOB.portals += src
	src.loc = loc
	src.target = target
	src.creator = creator
	if(lifespan > 0)
		spawn(lifespan)
			qdel(src)

/obj/effect/portal/Destroy()
	GLOB.portals -= src
	if(istype(creator, /obj))
		var/obj/O = creator
		O.portal_destroyed(src)
	creator = null
	target = null
	return ..()

/obj/effect/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect)) //sparks don't teleport
		return
	if(M.anchored&&istype(M, /obj/mecha))
		return
	if(!( target ))
		qdel(src)
		return
	if(istype(M, /atom/movable))
		if(prob(failchance))
			src.icon_state = "portal1"
			if(!do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 0, bypass_area_flag = ignore_tele_proof_area_setting)) // Try to send them to deep space.
				invalid_teleport()
		else
			if(!do_teleport(M, target, precision, bypass_area_flag = ignore_tele_proof_area_setting)) // Try to send them to a turf adjacent to target.
				invalid_teleport()

/obj/effect/portal/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/multitool) && can_multitool_to_remove)
		qdel(src)

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