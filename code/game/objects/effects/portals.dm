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
	anchored = 1.0
	var/precision = 1 // how close to the portal you will teleport. 0 = on the portal, 1 = adjacent

/obj/effect/portal/Bumped(mob/M as mob|obj)
	src.teleport(M)

/obj/effect/portal/New(loc, turf/target, creator)
	portals += src
	src.forceMove(loc)
	src.target = target
	src.creator = creator
	spawn(300)
		qdel(src)
	return

/obj/effect/portal/Destroy()
	portals -= src
	if(istype(creator, /obj/item/weapon/hand_tele))
		var/obj/item/weapon/hand_tele/O = creator
		O.active_portals--
	else if(istype(creator, /obj/item/weapon/gun/energy/wormhole_projector))
		var/obj/item/weapon/gun/energy/wormhole_projector/P = creator
		P.portal_destroyed(src)
	creator = null
	return ..()

/obj/effect/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect)) //sparks don't teleport
		return
	if(M.anchored&&istype(M, /obj/mecha))
		return
	if (!( target ))
		qdel(src)
		return
	if (istype(M, /atom/movable))
		if(prob(failchance)) //oh dear a problem, put em in deep space
			src.icon_state = "portal1"
			do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 0)
		else
			do_teleport(M, target, precision) ///You will appear adjacent to the beacon
