/proc/get_area(atom/A)
	RETURN_TYPE(/area)
	if(isarea(A))
		return A
	var/turf/T = get_turf(A)
	return T ? T.loc : null

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
	if(T && !T.density)
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

/proc/hear(var/range, var/atom/source)
	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
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
	var/list/atoms = new/list()
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
	var/list/line = getline(A, B)
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

/proc/circlerangeturfs(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center=usr,radius=3)		//Is there even a diffrence between this proc and circlerangeturfs()?

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs



//GLOBAL_VAR_INIT(debug_mob, 0)

// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.

/proc/recursive_mob_check(var/atom/O,  var/list/L = list(), var/recursion_limit = 3, var/client_check = 1, var/sight_check = 1, var/include_radio = 1)

	//GLOB.debug_mob += O.contents.len
	if(!recursion_limit)
		return L
	for(var/atom/A in O.contents)

		if(ismob(A))
			var/mob/M = A
			if(client_check && !M.client)
				L |= recursive_mob_check(A, L, recursion_limit - 1, client_check, sight_check, include_radio)
				continue
			if(sight_check && !isInSight(A, O))
				continue
			L |= M
			//log_world("[recursion_limit] = [M] - [get_turf(M)] - ([M.x], [M.y], [M.z])")

		else if(include_radio && istype(A, /obj/item/radio))
			if(sight_check && !isInSight(A, O))
				continue
			L |= A

		if(isobj(A) || ismob(A))
			L |= recursive_mob_check(A, L, recursion_limit - 1, client_check, sight_check, include_radio)
	return L

// The old system would loop through lists for a total of 5000 per function call, in an empty server.
// This new system will loop at around 1000 in an empty server.

/proc/get_mobs_in_view(var/R, var/atom/source, var/include_clientless = FALSE)
	// Returns a list of mobs in range of R from source. Used in radio and say code.

	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = hear(R, T)

	for(var/atom/A in range)
		if(ismob(A))
			var/mob/M = A
			if(M.client || include_clientless)
				hear += M
			//log_world("Start = [M] - [get_turf(M)] - ([M.x], [M.y], [M.z])")
		else if(istype(A, /obj/item/radio))
			hear += A

		if(isobj(A) || ismob(A))
			hear |= recursive_mob_check(A, hear, 3, 1, 0, 1)

	return hear


/proc/get_mobs_in_radio_ranges(var/list/obj/item/radio/radios)
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
					speaker_coverage[T] = T


	// Try to find all the players who can hear the message
	for(var/A in GLOB.player_list + GLOB.hear_radio_list)
		var/mob/M = A
		if(M)
			var/turf/ear = get_turf(M)
			if(ear)
				// Ghostship is magic: Ghosts can hear radio chatter from anywhere
				if(speaker_coverage[ear] || (istype(M, /mob/dead/observer) && M.get_preference(PREFTOGGLE_CHAT_GHOSTRADIO)))
					. |= M		// Since we're already looping through mobs, why bother using |= ? This only slows things down.
	return .

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
				if(T.opacity)
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
			if(T.opacity)
				return 0
	return 1

/proc/isInSight(var/atom/A, var/atom/B)
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

/proc/get_mob_by_key(var/key)
	for(var/mob/M in GLOB.mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null

/proc/get_candidates(be_special_type, afk_bracket=3000, override_age=0, override_jobban=0)
	var/roletext = get_roletext(be_special_type)
	var/list/candidates = list()
	// Keep looping until we find a non-afk candidate within the time bracket (we limit the bracket to 10 minutes (6000))
	while(!candidates.len && afk_bracket < 6000)
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(G.client != null)
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					if(!G.client.is_afk(afk_bracket) && (be_special_type in G.client.prefs.be_special))
						if(!override_jobban || (!jobban_isbanned(G, roletext) && !jobban_isbanned(G,"Syndicate")))
							if(override_age || player_old_enough_antag(G.client,be_special_type))
								candidates += G.client
		afk_bracket += 600 // Add a minute to the bracket, for every attempt

	return candidates

/proc/get_candidate_ghosts(be_special_type, afk_bracket=3000, override_age=0, override_jobban=0)
	var/roletext = get_roletext(be_special_type)
	var/list/candidates = list()
	// Keep looping until we find a non-afk candidate within the time bracket (we limit the bracket to 10 minutes (6000))
	while(!candidates.len && afk_bracket < 6000)
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(G.client != null)
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					if(!G.client.is_afk(afk_bracket) && (be_special_type in G.client.prefs.be_special))
						if(!override_jobban || (!jobban_isbanned(G, roletext) && !jobban_isbanned(G,"Syndicate")))
							if(override_age || player_old_enough_antag(G.client,be_special_type))
								candidates += G
		afk_bracket += 600 // Add a minute to the bracket, for every attempt

	return candidates

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))	O = new /obj/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))	return
	if(!group)	group = GLOB.clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

/proc/remove_images_from_clients(image/I, list/show_to)
	for(var/client/C in show_to)
		C.images -= I

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, /proc/remove_images_from_clients, I, show_to), duration, TIMER_CLIENT_TIME)

/proc/flick_overlay_view(image/I, atom/target, duration) //wrapper for the above, flicks to everyone who can see the target atom
	var/list/viewing = list()
	for(var/m in viewers(target))
		var/mob/M = m
		if(M.client)
			viewing += M.client
	flick_overlay(I, viewing, duration)

/proc/get_active_player_count()
	// Get active players who are playing in the round
	var/active_players = 0
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/M = GLOB.player_list[i]
		if(M && M.client)
			if(isnewplayer(M)) // exclude people in the lobby
				continue
			else if(isobserver(M)) // Ghosts are fine if they were playing once (didn't start as observers)
				var/mob/dead/observer/O = M
				if(O.started_as_observer) // Exclude people who started as observers
					continue
			active_players++
	return active_players

/datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(var/src_x, var/src_y, var/time, var/distance, \
						   var/power_x, var/power_y, var/dest_x, var/dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(var/src_x, var/src_y, var/rotation, var/angle, var/power)

	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2* power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)


/proc/mobs_in_area(var/area/the_area, var/client_needed=0, var/moblist=GLOB.mob_list)
	var/list/mobs_found[0]
	var/area/our_area = get_area(the_area)
	for(var/mob/M in moblist)
		if(client_needed && !M.client)
			continue
		if(our_area != get_area(M))
			continue
		mobs_found += M
	return mobs_found

/proc/alone_in_area(var/area/the_area, var/mob/must_be_alone, var/check_type = /mob/living/carbon)
	var/area/our_area = get_area(the_area)
	for(var/C in GLOB.alive_mob_list)
		if(!istype(C, check_type))
			continue
		if(C == must_be_alone)
			continue
		if(our_area == get_area(C))
			return 0
	return 1

/proc/lavaland_equipment_pressure_check(turf/T)
	. = FALSE
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return
	var/pressure = environment.return_pressure()
	if(pressure <= LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
		. = TRUE

/proc/pollCandidatesWithVeto(adminclient, adminusr, max_slots, Question, be_special_type, antag_age_check = FALSE, poll_time = 300, ignore_respawnability = FALSE, min_hours = FALSE, flashwindow = TRUE, check_antaghud = TRUE, source, role_cleanname)
	var/list/willing_ghosts = SSghost_spawns.poll_candidates(Question, be_special_type, antag_age_check, poll_time, ignore_respawnability, min_hours, flashwindow, check_antaghud, source, role_cleanname)
	var/list/selected_ghosts = list()
	if(!willing_ghosts.len)
		return selected_ghosts

	var/list/candidate_ghosts = willing_ghosts.Copy()

	to_chat(adminusr, "Candidate Ghosts:");
	for(var/mob/dead/observer/G in candidate_ghosts)
		if(G.key && G.client)
			to_chat(adminusr, "- [G] ([G.key])");
		else
			candidate_ghosts -= G

	for(var/i = max_slots, (i > 0 && candidate_ghosts.len), i--)
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
  * * exclude_mobs_nearby - Whether to exclude vents that are near living mobs regardless of visibility
  * * nearby_mobs_range - The range at which to look for living mobs around the vent for the above argument
  * * exclude_visible_by_mobs - Whether to exclude vents that are visible to any living mob
  * * min_network_size - The minimum length (non-inclusive) of the vent's parent network. A smaller number means vents in small networks (Security, Virology) will appear in the list
  * * station_levels_only - Whether to only consider vents that are in a Z-level with a STATION_LEVEL trait
  * * z_level - The Z-level number to look for vents in. Defaults to all
  */
/proc/get_valid_vent_spawns(unwelded_only = TRUE, exclude_mobs_nearby = FALSE, nearby_mobs_range = world.view, exclude_visible_by_mobs = FALSE, min_network_size = 50, station_levels_only = TRUE, z_level = 0)
	ASSERT(min_network_size >= 0)
	ASSERT(z_level >= 0)

	var/num_z_levels = length(GLOB.space_manager.z_list)
	var/list/non_station_levels[num_z_levels] // Cache so we don't do is_station_level for every vent!

	. = list()
	for(var/object in GLOB.all_vent_pumps) // This only contains vent_pumps so don't bother with type checking
		var/obj/machinery/atmospherics/unary/vent_pump/vent = object
		var/vent_z = vent.z
		if(z_level && vent_z != z_level)
			continue
		if(station_levels_only && (non_station_levels[vent_z] || !is_station_level(vent_z)))
			non_station_levels[vent_z] = TRUE
			continue
		if(unwelded_only && vent.welded)
			continue
		if(exclude_mobs_nearby)
			var/turf/T = get_turf(vent)
			var/mobs_nearby = FALSE
			for(var/mob/living/M in orange(nearby_mobs_range, T))
				if(!M.is_dead())
					mobs_nearby = TRUE
					break
			if(mobs_nearby)
				continue
		if(exclude_visible_by_mobs)
			var/turf/T = get_turf(vent)
			var/visible_by_mobs = FALSE
			for(var/mob/living/M in viewers(world.view, T))
				if(!M.is_dead())
					visible_by_mobs = TRUE
					break
			if(visible_by_mobs)
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
