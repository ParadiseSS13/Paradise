/mob/dead/observer/DblClickOn(var/atom/A, var/params)
	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return
	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return									// seems legit.

	// Things you might plausibly want to follow
	if((ismob(A) && A != src) || istype(A,/obj/machinery/bot) || istype(A,/obj/singularity))
		ManualFollow(A)

	// Otherwise jump
	else
		loc = get_turf(A)

/mob/dead/observer/ClickOn(var/atom/A, var/params)
	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return
	if(world.time <= next_move)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	// You are responsible for checking config.ghost_interaction when you override this function
	// Not all of them require checking, see below
	A.attack_ghost(src)


// This is the ghost's follow verb with an argument
/mob/dead/observer/proc/ManualFollow(var/atom/target)
	following = target
	if(target)
		src << "\blue Now following [target]"
		spawn(0)
			var/turf/pos = get_turf(src)
			while(loc == pos && target && following == target)

				var/turf/T = get_turf(target)
				if(!T)
					break
				if(following != target)
					break
				if(!client)
					break
				loc = T
				pos = loc
				sleep(15)
			following = null

// We don't need a fucking toggle.
/mob/dead/observer/ShiftClickOn(var/atom/A)
	A.examine()

/atom/proc/attack_ghost(mob/user as mob)
	return

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, gateways, and teleporters while observing. -Sayu

/obj/machinery/teleport/hub/attack_ghost(mob/user as mob)
	var/obj/machinery/teleport/station/S = power_station
	if(S)
		var/obj/machinery/computer/teleporter/com = S.teleporter_console
		if(com && com.target)
			user.loc = get_turf(com.target)

/obj/effect/portal/attack_ghost(mob/user as mob)
	if(target)
		user.loc = get_turf(target)

/obj/machinery/gateway/centerstation/attack_ghost(mob/user as mob)
	if(awaygate)
		user.loc = awaygate.loc
	else
		user << "[src] has no destination."

/obj/machinery/gateway/centeraway/attack_ghost(mob/user as mob)
	if(stationgate)
		user.loc = stationgate.loc
	else
		user << "[src] has no destination."

// -------------------------------------------
// This was supposed to be used by adminghosts
// I think it is a *terrible* idea
// but I'm leaving it here anyway
// commented out, of course.

/atom/proc/attack_admin(mob/user as mob)
	if(!user || !user.client || !user.client.holder)
		return
	attack_hand(user)


