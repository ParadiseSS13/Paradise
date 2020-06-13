/mob/dead/observer/DblClickOn(var/atom/A, var/params)
	if(client.click_intercept)
		// Not doing a click intercept here, because otherwise we double-tap with the `ClickOn` proc.
		// But we return here since we don't want to do regular dblclick handling
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
		update_parallax_contents()

/mob/dead/observer/ClickOn(var/atom/A, var/params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return
	if(world.time <= next_move)
		return

	var/list/modifiers = params2list(params)
	if(check_rights(R_ADMIN, 0)) // Admin click shortcuts
		var/mob/M
		if(modifiers["shift"] && modifiers["ctrl"])
			client.debug_variables(A)
			return
		if(modifiers["ctrl"])
			M = get_mob_in_atom_with_warning(A)
			if(M)
				client.holder.show_player_panel(M)
			return
		if(modifiers["shift"] && modifiers["middle"])
			M = get_mob_in_atom_with_warning(A)
			if(M)
				admin_mob_info(M)
			return
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

// health + cyborg analyzer for ghosts
/mob/living/attack_ghost(mob/dead/observer/user)
	if(!istype(user)) // Make sure user is actually an observer. Revenents also use attack_ghost, but do not have the health_scan var.
		return
	if(user.client && user.health_scan)
		if(issilicon(src) || ismachine(src))
			robot_healthscan(user, src)
		else if(ishuman(src))
			healthscan(user, src, 1, TRUE)

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
