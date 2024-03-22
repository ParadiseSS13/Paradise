/mob/dead/observer/DblClickOn(atom/A, params)
	if(client.click_intercept)
		// Not doing a click intercept here, because otherwise we double-tap with the `ClickOn` proc.
		// But we return here since we don't want to do regular dblclick handling
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"]) // Let ghosts point without teleporting
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
		forceMove(get_turf(A))
		update_parallax_contents()

/mob/dead/observer/ClickOn(atom/A, params)
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
			CtrlClickOn(A)
			return
		if(modifiers["shift"] && modifiers["middle"])
			M = get_mob_in_atom_with_warning(A)
			if(M)
				client.freeze(M)
			return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickNoInteract(src, A)
		return
	// You are responsible for checking config.ghost_interaction when you override this function
	// Not all of them require checking, see below
	A.attack_ghost(src)

// We don't need a fucking toggle.
/mob/dead/observer/ShiftClickOn(atom/A)
	examinate(A)

/mob/dead/observer/AltClickOn(atom/A)
	AltClickNoInteract(src, A)

/mob/dead/observer/AltShiftClickOn(atom/A)
	return

/mob/dead/observer/CtrlShiftClickOn(atom/A)
	return

/mob/dead/observer/MiddleShiftClickOn(atom/A)
	return

/mob/dead/observer/MiddleShiftControlClickOn(atom/A)
	return

/atom/proc/attack_ghost(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_GHOST, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

// health + machine analyzer for ghosts
/mob/living/attack_ghost(mob/dead/observer/user)
	if(!istype(user)) // Make sure user is actually an observer. Revenents also use attack_ghost, but do not have the health_scan var.
		return
	if(user.client && user.health_scan)
		if(issilicon(src) || ismachineperson(src))
			robot_healthscan(user, src)
		else if(ishuman(src))
			healthscan(user, src, 1, TRUE)
	return ..()

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, and teleporters while observing. -Sayu

/obj/machinery/teleport/hub/attack_ghost(mob/user as mob)
	var/obj/machinery/teleport/station/S = power_station
	if(S)
		var/obj/machinery/computer/teleporter/com = S.teleporter_console
		if(com && com.target)
			user.forceMove(get_turf(com.target))

/obj/effect/portal/attack_ghost(mob/user as mob)
	if(target)
		user.forceMove(get_turf(target))

/mob/dead/observer/CtrlClickOn(atom/A)
	if(!istype(src)) // Make sure the user is actually an observer.
		return
	if(!src.gas_analyzer)
		return
	if(istype(A, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/T = A
		T.atmosanalyzer_scan(T.parent.air, src, T)
		return
	else if(istype(A, /obj/machinery/atmospherics/unary))
		var/obj/machinery/atmospherics/unary/T = A
		T.atmosanalyzer_scan(T.air_contents, src, T)
		return
	else if(istype(A, /obj/machinery/atmospherics/portable))
		var/obj/machinery/atmospherics/portable/T = A
		T.atmosanalyzer_scan(T.air_contents, src, T)
		return
	else if(isturf(A))
		var/datum/gas_mixture/environment = A.return_air()

		var/pressure = environment.return_pressure()
		var/total_moles = environment.total_moles()

		var/list/result = list("<span class='boldnotice'>Results:</span>")

		if(abs(pressure - ONE_ATMOSPHERE) < 10)
			result += "<span class='notice'>Pressure: [round(pressure, 0.1)] kPa</span>"
		else
			result += "<span class='warning'>Pressure: [round(pressure, 0.1)] kPa</span>"
		if(total_moles)
			var/o2_concentration = environment.oxygen / total_moles
			var/n2_concentration = environment.nitrogen / total_moles
			var/co2_concentration = environment.carbon_dioxide / total_moles
			var/plasma_concentration = environment.toxins / total_moles
			var/n2o_concentration = environment.sleeping_agent / total_moles

			var/unknown_concentration = 1 - (o2_concentration + n2_concentration + co2_concentration + plasma_concentration + n2o_concentration)
			if(abs(n2_concentration - N2STANDARD) < 20)
				result += "<span class='notice'>Nitrogen: [round(n2_concentration * 100)]% ([round(environment.nitrogen, 0.01)] moles)</span>"
			else
				result += "<span class='warning'>Nitrogen: [round(n2_concentration * 100)]% ([round(environment.nitrogen, 0.01)] moles)</span>"

			if(abs(o2_concentration - O2STANDARD) < 2)
				result += "<span class='notice'>Oxygen: [round(o2_concentration * 100)]% ([round(environment.oxygen, 0.01)] moles)</span>"
			else
				result += "<span class='warning'>Oxygen: [round(o2_concentration * 100)]% ([round(environment.oxygen, 0.01)] moles)</span>"

			if(co2_concentration > 0.01)
				result += "<span class='warning'>CO2: [round(co2_concentration * 100)]% ([round(environment.carbon_dioxide, 0.01)] moles)</span>"
			else
				result += "<span class='notice'>CO2: [round(co2_concentration * 100)]% ([round(environment.carbon_dioxide, 0.01)] moles)</span>"

			if(plasma_concentration > 0.01)
				result += "<span class='warning'>Plasma: [round(plasma_concentration * 100)]% ([round(environment.toxins, 0.01)] moles)</span>"

			if(n2o_concentration > 0.01)
				result += "<span class='warning'>N2O: [round(n2o_concentration * 100)]% ([round(environment.sleeping_agent, 0.01)] moles)</span>"

			if(unknown_concentration > 0.01)
				result += "<span class='warning'>Unknown: [round(unknown_concentration * 100)]% ([round(unknown_concentration * total_moles, 0.01)] moles)</span>"

			result += "<span class='notice'>Temperature: [round(environment.temperature - T0C, 0.1)]&deg;C</span>"
			result += "<span class='notice'>Heat Capacity: [round(environment.heat_capacity(), 0.1)]</span>"
			to_chat(src, result.Join("<br>"))
