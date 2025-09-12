/proc/get_area_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	return format_text ? format_text(A.name) : A.name

/proc/get_location_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	return format_text ? format_text(A.name) : A.name

/proc/get_areas_in_range(dist=0, atom/center=usr)
	if(!dist)
		var/turf/T = get_turf(center)
		return T ? list(T.loc) : list()
	if(!center)
		return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	var/list/areas = list()
	for(var/V in turfs)
		var/turf/T = V
		areas |= T.loc
	return areas

/proc/get_open_turf_in_dir(atom/center, dir)
	var/turf/T = get_ranged_target_turf(center, dir, 1)
	if(T)
		var/list/milla = new/list(MILLA_TILE_SIZE)
		get_tile_atmos(T, milla)

		var/checked_dir
		switch(dir)
			if(NORTH)
				checked_dir = MILLA_NORTH
			if(EAST)
				checked_dir = MILLA_EAST
			if(SOUTH)
				checked_dir = MILLA_SOUTH
			if(WEST)
				checked_dir = MILLA_WEST

		if(milla[MILLA_INDEX_AIRTIGHT_DIRECTIONS] & checked_dir)
			return
		return T

/proc/get_adjacent_open_turfs(atom/center)
	. = list(get_open_turf_in_dir(center, NORTH),
			get_open_turf_in_dir(center, SOUTH),
			get_open_turf_in_dir(center, EAST),
			get_open_turf_in_dir(center, WEST))
	listclearnulls(.)

/proc/get_adjacent_open_areas(atom/center)
	. = list()
	var/list/adjacent_turfs = get_adjacent_open_turfs(center)
	for(var/I in adjacent_turfs)
		. |= get_area(I)

// Like view but bypasses luminosity check

/proc/hear(range, atom/source)
	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/atoms = list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms

/proc/ff_cansee(atom/A, atom/B)
	var/AT = get_turf(A)
	var/BT = get_turf(B)
	if(AT == BT)
		return 1
	var/list/line = get_line(A, B)
	for(var/turf/T in line)
		if(T == AT || T == BT)
			break
		if(T.density)
			return FALSE
	return TRUE

/proc/get_dist_euclidian(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx**2 + dy**2)

	return dist

/proc/circle_edge_turfs(center = usr, radius = 3) // Get the turfs on the edge of a circle. Currently only works for radius 3

	var/turf/centerturf = get_turf(center)
	var/list/turfs = list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx * dx + dy * dy <= (rsq - radius))
			continue
		if(dx * dx + dy * dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center = usr, radius = 3) // All the turfs in a circle of the radius

	var/turf/centerturf = get_turf(center)
	var/list/turfs = list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx * dx + dy * dy <= rsq)
			turfs += T
	return turfs

/proc/circlerangeturfs(center = usr, radius = 3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = list()
	var/rsq = radius * (radius + 0.5)

	for(var/turf/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx * dx + dy * dy <= rsq)
			turfs += T
	return turfs

/// Recursively loops through the contents of this atom looking for mobs, optionally requiring them to have a client.
/proc/collect_nested_mobs(atom/parent, list/mobs, recursion_limit = 3, client_check = TRUE, ai_eyes = AI_EYE_EXCLUDE)
	var/list/next_layer = list(parent)
	for(var/depth in 1 to recursion_limit)
		var/list/layer = next_layer
		next_layer = list()
		for(var/atom/thing in layer)
			next_layer += thing.contents
			if(!ismob(thing))
				continue
			var/mob/this_mob = thing
			if(!client_check || this_mob.client)
				if(is_ai(this_mob))
					// AIs can get messages from their eye as well as themselves, so use |= to make sure they don't get double messages.
					mobs |= this_mob
				else
					// Everything else can only be visited once, so use += for efficiency.
					mobs += this_mob
			else if(ai_eyes != AI_EYE_EXCLUDE && is_ai_eye(this_mob))
				var/mob/camera/eye/ai/eye = this_mob
				if((ai_eyes == AI_EYE_INCLUDE || eye.relay_speech) && eye.ai && (!client_check || eye.ai.client))
					mobs |= eye.ai
		if(!length(next_layer))
			return

// The old system would loop through lists for a total of 5000 per function call, in an empty server.
// This new system will loop at around 1000 in an empty server.

/proc/get_mobs_in_view(R, atom/source, include_clientless = FALSE, ai_eyes = AI_EYE_EXCLUDE)
	// Returns a list of mobs in range of R from source. Used in radio and say code.
#ifdef GAME_TESTS
	// kind of feels cleaner clobbering here than changing the loop?
	include_clientless = TRUE
#endif

	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	for(var/atom/A in hear(R, T))
		if(isobj(A) || ismob(A))
			collect_nested_mobs(A, hear, 3, !include_clientless, ai_eyes)

	return hear

/proc/is_same_root_atom(atom/one, atom/two)
	return get_atom_on_turf(one) == get_atom_on_turf(two)

/proc/get_mobs_in_radio_ranges(list/obj/item/radio/radios)
	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/obj/item/radio/R in radios)
		if(R)
			//Cyborg checks. Receiving message uses a bit of cyborg's charge.
			var/obj/item/radio/borg/BR = R
			if(istype(BR) && BR.myborg)
				var/mob/living/silicon/robot/borg = BR.myborg
				var/datum/robot_component/CO = borg.get_component("radio")
				if(!CO)
					continue //No radio component (Shouldn't happen)
				if(!borg.is_component_functioning("radio"))
					continue //No power.

			var/turf/speaker = get_turf(R)
			if(speaker)
				for(var/turf/T in hear(R.canhear_range,speaker))
					var/obj/item/radio/oldR = speaker_coverage[T]
					if(!istype(oldR))
						speaker_coverage[T] = R
						continue
					if(oldR.canhear_range < R.canhear_range)
						speaker_coverage[T] = R

	// Try to find all the players who can hear the message
	for(var/A in GLOB.player_list + GLOB.hear_radio_list)
		var/mob/M = A
		if(!M)
			continue
		var/turf/ear = get_turf(M)
		if(!ear)
			continue
		// Ghostship is magic: Ghosts can hear radio chatter from anywhere
		if(isobserver(M) && M.get_preference(PREFTOGGLE_CHAT_GHOSTRADIO))
			. |= M
			continue
		if(!speaker_coverage[ear])
			continue
		var/obj/item/radio/R = speaker_coverage[ear]
		if(!istype(R) || R.canhear_range > 0)
			. |= M
			continue
		if(is_same_root_atom(M, speaker_coverage[ear]))
			. |= M

/proc/inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
	var/turf/T
	if(X1==X2)
		if(Y1==Y2)
			return 1 //Light cannot be blocked on same tile
		else
			var/s = SIMPLE_SIGN(Y2-Y1)
			Y1+=s
			while(Y1!=Y2)
				T=locate(X1,Y1,Z)
				if(IS_OPAQUE_TURF(T))
					return 0
				Y1+=s
	else
		var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
		var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
		var/signX = SIMPLE_SIGN(X2-X1)
		var/signY = SIMPLE_SIGN(Y2-Y1)
		if(X1<X2)
			b+=m
		while(X1!=X2 || Y1!=Y2)
			if(round(m*X1+b-Y1))
				Y1+=signY //Line exits tile vertically
			else
				X1+=signX //Line exits tile horizontally
			T=locate(X1,Y1,Z)
			if(IS_OPAQUE_TURF(T))
				return 0
	return 1

/proc/isInSight(atom/A, atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	return inLineOfSight(Aturf.x, Aturf.y, Bturf.x, Bturf.y, Aturf.z)

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/try_move_adjacent(atom/movable/AM)
	var/turf/T = get_turf(AM)
	for(var/direction in GLOB.cardinal)
		if(AM.Move(get_step(T, direction)))
			break

/proc/get_mob_by_key(key)
	for(var/mob/M in GLOB.mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null

/proc/get_candidates(be_special_type, afk_bracket=3000, override_age=0, override_jobban=0)
	var/list/candidates = list()
	// Keep looping until we find a non-afk candidate within the time bracket (we limit the bracket to 10 minutes (6000))
	while(!length(candidates) && afk_bracket < 6000)
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(G.client != null)
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					if(!G.client.is_afk(afk_bracket) && (be_special_type in G.client.prefs.be_special))
						if(!override_jobban || (!jobban_isbanned(G, be_special_type) && !jobban_isbanned(G, ROLE_SYNDICATE)))
							if(override_age || player_old_enough_antag(G.client,be_special_type))
								candidates += G.client
		afk_bracket += 600 // Add a minute to the bracket, for every attempt

	return candidates

/proc/get_candidate_ghosts(be_special_type, afk_bracket=3000, override_age=0, override_jobban=0)
	var/list/candidates = list()
	// Keep looping until we find a non-afk candidate within the time bracket (we limit the bracket to 10 minutes (6000))
	while(!length(candidates) && afk_bracket < 6000)
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(G.client != null)
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					if(!G.client.is_afk(afk_bracket) && (be_special_type in G.client.prefs.be_special))
						if(!override_jobban || (!jobban_isbanned(G, be_special_type) && !jobban_isbanned(G, ROLE_SYNDICATE)))
							if(override_age || player_old_enough_antag(G.client,be_special_type))
								candidates += G
		afk_bracket += 600 // Add a minute to the bracket, for every attempt

	return candidates

/proc/remove_images_from_clients(image/I, list/show_to)
	for(var/client/C in show_to)
		C.images -= I

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_images_from_clients), I, show_to), duration, TIMER_CLIENT_TIME)

/proc/flick_overlay_view(image/I, atom/target, duration) //wrapper for the above, flicks to everyone who can see the target atom
	var/list/viewing = list()
	for(var/m in viewers(target))
		var/mob/M = m
		if(M.client)
			viewing += M.client
	flick_overlay(I, viewing, duration)

/// Get active players who are playing in the round
/proc/get_active_player_count()
	var/active_players = 0
	for(var/mob/player as anything in GLOB.player_list)
		if(isobserver(player)) // Ghosts are fine if they were playing once (didn't start as observers)
			var/mob/dead/observer/observer = player
			if(observer.ghost_flags & GHOST_START_AS_OBSERVER) // Exclude people who started as observers
				continue

		active_players++

	return active_players

/proc/mobs_in_area(area/the_area, client_needed=0, moblist=GLOB.mob_list)
	var/list/mobs_found[0]
	for(var/mob/M in moblist)
		if(client_needed && !M.client)
			continue
		if(the_area != get_area(M))
			continue
		mobs_found += M
	return mobs_found

/proc/alone_in_area(area/the_area, mob/must_be_alone, check_type = /mob/living/carbon)
	for(var/C in GLOB.alive_mob_list)
		if(!istype(C, check_type))
			continue
		if(C == must_be_alone)
			continue
		if(the_area == get_area(C))
			return 0
	return 1

/proc/lavaland_equipment_pressure_check(turf/T)
	. = FALSE
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.get_readonly_air()
	if(!istype(environment))
		return
	var/pressure = environment.return_pressure()
	if(pressure <= LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
		. = TRUE

/proc/pollCandidatesWithVeto(adminclient, adminusr, max_slots, Question, be_special_type, antag_age_check = FALSE, poll_time = 300, ignore_respawnability = FALSE, min_hours = FALSE, flashwindow = TRUE, check_antaghud = TRUE, source, role_cleanname)
	var/list/willing_ghosts = SSghost_spawns.poll_candidates(Question, be_special_type, antag_age_check, poll_time, ignore_respawnability, min_hours, flashwindow, check_antaghud, source, role_cleanname)
	var/list/selected_ghosts = list()
	if(!length(willing_ghosts))
		return selected_ghosts

	var/list/candidate_ghosts = willing_ghosts.Copy()

	to_chat(adminclient, "Candidate Ghosts:");
	for(var/mob/dead/observer/G in candidate_ghosts)
		if(G.key && G.client)
			to_chat(adminclient, "- [G] ([G.key])");
		else
			candidate_ghosts -= G

	for(var/i = max_slots, (i > 0 && length(candidate_ghosts)), i--)
		var/this_ghost = input("Pick players. This will go on until there either no more ghosts to pick from or the [i] remaining slot(s) are full.", "Candidates") as null|anything in candidate_ghosts
		candidate_ghosts -= this_ghost
		selected_ghosts += this_ghost
	return selected_ghosts

/proc/window_flash(client/C)
	if(ismob(C))
		var/mob/M = C
		if(M.client)
			C = M.client
	if(!C || !(C.prefs.toggles2 & PREFTOGGLE_2_WINDOWFLASHING))
		return
	winset(C, "mainwindow", "flash=5")

/**
  * Returns a list of vents that can be used as a potential spawn if they meet the criteria set by the arguments
  *
  * Will not include parent-less vents to the returned list.
  * Arguments:
  * * unwelded_only - Whether the list should only include vents that are unwelded
  * * exclude_mobs_nearby - Whether to exclude vents that are near living mobs
  * * min_network_size - The minimum length (non-inclusive) of the vent's parent network. A smaller number means vents in small networks (Security, Virology) will appear in the list
  */
/proc/get_valid_vent_spawns(unwelded_only = TRUE, exclude_mobs_nearby = FALSE, min_network_size = 50)
	ASSERT(min_network_size >= 0)

	. = list()
	for(var/object in GLOB.all_vent_pumps) // This only contains vent_pumps so don't bother with type checking
		var/obj/machinery/atmospherics/unary/vent_pump/vent = object
		var/vent_z = vent.z
		if(!is_station_level(vent_z))
			continue
		if(unwelded_only && vent.welded)
			continue
		if(exclude_mobs_nearby)
			var/turf/T = get_turf(vent)
			var/mobs_nearby = FALSE
			for(var/mob/living/M in orange(7, T))
				if(M.stat == DEAD) //we don't care about dead mobs
					continue
				if(!M.client && !istype(get_area(T), /area/station/science/xenobiology)) //we add an exception here for clientless mobs (apart from ones near xenobiology vents because it's usually filled with gold slime mobs who attack hostile mobs)
					continue
				mobs_nearby = TRUE
				break
			if(mobs_nearby)
				continue
		if(!vent.parent) // This seems to have been an issue in the past, so this is here until it's definitely fixed
			// Can cause heavy message spam in some situations (e.g. pipenets breaking)
			// log_debug("get_valid_vent_spawns(), vent has no parent: [vent], qdeled: [QDELETED(vent)], loc: [vent.loc]")
			continue
		if(length(vent.parent.other_atmosmch) <= min_network_size)
			continue
		. += vent

/**
 * Get a bounding box of a list of atoms.
 *
 * Arguments:
 * - atoms - List of atoms. Can accept output of view() and range() procs.
 *
 * Returns: list(x1, y1, x2, y2)
 */
/proc/get_bbox_of_atoms(list/atoms)
	var/list/list_x = list()
	var/list/list_y = list()
	for(var/_a in atoms)
		var/atom/a = _a
		list_x += a.x
		list_y += a.y
	return list(
		min(list_x),
		min(list_y),
		max(list_x),
		max(list_y))
