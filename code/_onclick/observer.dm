/mob/dead/observer/DblClickOn(var/atom/A, var/params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return									// seems legit.

	// Follow !!ALL OF THE THINGS!!
	if(istype(A, /atom/movable) && A != src)
		ManualFollow(A)

	// Otherwise jump
	else
		following = null
		forceMove(get_turf(A))

/mob/dead/observer/ClickOn(var/atom/A, var/params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
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

// We don't need a fucking toggle.
/mob/dead/observer/ShiftClickOn(var/atom/A)
	examinate(A)

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
			user.forceMove(get_turf(com.target))

/obj/effect/portal/attack_ghost(mob/user as mob)
	if(target)
		user.forceMove(get_turf(target))

/obj/machinery/gateway/centerstation/attack_ghost(mob/user as mob)
	if(awaygate)
		user.forceMove(awaygate.loc)
	else
		to_chat(user, "[src] has no destination.")

/obj/machinery/gateway/centeraway/attack_ghost(mob/user as mob)
	if(stationgate)
		user.forceMove(stationgate.loc)
	else
		to_chat(user, "[src] has no destination.")
