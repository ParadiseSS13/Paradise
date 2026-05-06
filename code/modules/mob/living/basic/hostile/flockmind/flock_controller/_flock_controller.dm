/proc/get_default_flock() as /datum/flock
	var/static/datum/flock/flock
	if(isnull(flock))
		flock = new

	return flock

/datum/flock
	var/name = "BAD FLOCK"

	/// The master of the flock
	var/mob/camera/flock/overmind/overmind

	/// Cache of images used by notices.
	var/list/notice_images = list()
	/// A k:V list of atoms the Overmind has marked for conversion, where the value is TRUE
	var/list/marked_for_conversion = list()
	/// A k:v list of atoms the Overmind has marked for deconstruction, where the value is TRUE
	var/list/marked_for_deconstruction = list()
	/// A k:V list of reserved_turf = TRUE.
	var/list/turf_reservations = list()
	/// A k:V list of flock mobs to their reserved turf.
	var/list/turf_reservations_by_flock = list()

	var/list/claimed_floors = list()
	var/list/claimed_walls = list()

	/// Every structure we've built.
	var/list/structures = list()

	/// The bits
	var/list/bits = list()
	/// The drones
	var/list/drones = list()
	/// The traces
	var/list/traces = list()

	/// A k:v list of mob : details, contains enemy mobs.
	var/list/enemies = list()
	/// A k:V list of mob : TRUE, where mob is mobs that ai will ignore.
	var/list/ignores = list()

	/// A k:V list of client : image, see ping().
	var/list/active_pings = list()

	var/list/datum/flock_unlockable/unlockables
	/// The total amount of computational power available, before whats being used.
	var/datum/point_holder/bandwidth
	/// The computational power being used.
	var/used_bandwidth = 0
	/// The maximum amount of traces allowed.
	var/max_traces = 10

	/// The current substrate cost to lay an egg.
	var/current_egg_cost = FLOCK_SUBSTRATE_COST_LAY_EGG

	var/flock_started = FALSE
	/// Flock status, won, lost, etc
	var/flock_game_status = NONE

	/// Current UI tab, saves on data sending.
	var/ui_tab = FLOCK_UI_DRONES

	//* STAT TRACKING *//
	var/stat_drones_made = 0
	var/stat_bits_made = 0
	var/stat_deaths = 0
	var/stat_resources_gained = 0
	var/stat_traces_made = 0
	var/stat_tiles_made = 0
	var/stat_structures_made = 0
	var/stat_highest_bandwidth = 0

/datum/flock/New()
	name = flock_realname(FLOCK_TYPE_OVERMIND)

	bandwidth = new
	create_hud_images()

	unlockables = list()
	for(var/datum/flock_unlockable/unlockable as anything in typesof(/datum/flock_unlockable))
		if(isabstract(unlockable))
			continue
		unlockables += new unlockable

// Called by gamemode code
/datum/flock/process(delta_time)
	if(flock_game_status == FLOCK_ENDGAME_LOST)
		return

	update_relay_huds()
	stat_highest_bandwidth = max(stat_highest_bandwidth, bandwidth.has_points())

/// Called after everything is setup, and clients are in control of their mobs.
/datum/flock/proc/start()
	if(flock_started)
		return

	flock_started = TRUE
	refresh_unlockables()

/// Claim it for the flock, optionally converting it. Converting should only be avoided if the turf is already a flockturf.
/datum/flock/proc/claim_turf(turf/T, convert = TRUE)
	if(isnull(T))
		return

	free_turf(T)
	if(convert)
		T = flock_convert_turf(T, src)

	if(isnull(T))
		return

	if(convert)
		playsound(T, 'sound/items/deconstruct.ogg', 30, TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

	if(iswallturf(T))
		claimed_walls[T] = TRUE
	else
		claimed_floors[T] = TRUE

	T.AddComponent(/datum/component/flock_interest, src)
	RegisterSignal(T, COMSIG_TURF_CHANGE, PROC_REF(claimed_turf_change))
	SEND_SIGNAL(T, COMSIG_TURF_CLAIMED_BY_FLOCK, src)

/// Stop tracking a turf that is in our claimed walls or claimed floors lists.
/datum/flock/proc/stop_tracking_turf(turf/T)
	if(iswallturf(T))
		claimed_walls -= T
	else
		claimed_floors -= T

	qdel(T.GetComponent(/datum/component/flock_interest))
	UnregisterSignal(T, COMSIG_TURF_CHANGE)

/// Reserves a turf, making AI ignore it for the purposes of targetting.
/datum/flock/proc/reserve_turf(mob/living/simple_animal/flock/user, turf/target, remove_on_change = TRUE)
	if(turf_reservations_by_flock[user])
		return FALSE
	if(turf_reservations[target])
		return FALSE

	turf_reservations_by_flock[user] = target
	turf_reservations[target] = user
	add_notice(target, FLOCK_NOTICE_RESERVED)
	if(remove_on_change)
		RegisterSignal(target, COMSIG_TURF_CHANGE, PROC_REF(reserved_turf_change))
	return TRUE

/// Free a turf from reservation, allowing AI to target it again. override_turf can be given to lookup the user if there isnt a user in this context.
/datum/flock/proc/free_turf(mob/living/simple_animal/flock/user, turf/override_turf)
	var/turf/to_free
	if(user)
		to_free = turf_reservations_by_flock[user]
	else
		user = turf_reservations[override_turf]
		if(isnull(user))
			return

		to_free = override_turf

	if(isnull(to_free))
		return

	remove_notice(to_free, FLOCK_NOTICE_RESERVED)
	remove_notice(to_free, FLOCK_NOTICE_PRIORITY)
	turf_reservations_by_flock -= user
	turf_reservations -= to_free
	marked_for_conversion -= to_free
	UnregisterSignal(to_free, COMSIG_TURF_CHANGE)

/// Returns TRUE if the given turf is not reserved.
/datum/flock/proc/is_turf_free(turf/T)
	return !turf_reservations[T]

/// Returns TRUE if the given mob is an enemy.
/datum/flock/proc/is_mob_enemy(mob/M)
	return enemies[M]

/// Returns TRUE if the given mob is ignored by the flock.
/datum/flock/proc/is_mob_ignored(mob/M)
	return ignores[M]

/// Adds a unit to the flock and sets up all of the tracking.
/datum/flock/proc/add_unit(mob/unit)
	if(isflocktrace(unit))
		traces += unit

		var/mob/camera/flock/trace/ghostbird = unit
		add_bandwidth_influence(ghostbird.bandwidth_provided)
		return

	if(isflockdrone(unit))
		drones += unit
		update_egg_cost()

	else if(isflockbit(unit))
		bits += unit

	unit.AddComponent(/datum/component/flock_interest, src)

	var/mob/living/basic/flock/bird = unit
	add_bandwidth_influence(bird.bandwidth_provided)

/// Removes a unit from the flock.
/datum/flock/proc/free_unit(mob/unit)
	if(isflocktrace(unit))
		var/mob/camera/flock/trace/ghostbird = unit
		ghostbird.flock = null
		traces -= unit
		remove_bandwidth_influence(ghostbird.bandwidth_provided)
		return

	else if(isflockdrone(unit))
		var/mob/living/basic/flock/drone/bird = unit
		bird.flock = null
		drones -= unit
		remove_bandwidth_influence(bird.bandwidth_provided)
		update_egg_cost()

	else if(isflockbit(unit))
		var/mob/living/basic/flock/bit/bitty_bird = unit
		bitty_bird.flock = null
		bits -= unit
		remove_bandwidth_influence(bitty_bird.bandwidth_provided)

	remove_notice(unit, FLOCK_NOTICE_HEALTH)
	free_turf(unit)
	qdel(unit.GetComponent(/datum/component/flock_interest))

	consider_game_over()

/// Add a structure to the flock.
/datum/flock/proc/add_structure(obj/structure/flock/struct)
	structures += struct
	struct.flock = src
	struct.AddComponent(/datum/component/flock_interest, src)
	add_bandwidth_influence(struct.bandwidth_provided)

	if(istype(struct, /obj/structure/flock/egg))
		update_egg_cost()

/// Remove a structure from the flock.
/datum/flock/proc/free_structure(obj/structure/flock/struct)
	structures -= struct
	qdel(struct.GetComponent(/datum/component/flock_interest))
	struct.flock = null
	if(struct.active)
		remove_bandwidth_influence(-struct.active_bandwidth_cost)
	else
		remove_bandwidth_influence(struct.bandwidth_provided)

	if(istype(struct, /obj/structure/flock/egg))
		update_egg_cost()

/// Wrapper for spawning a tealprint, used by Create Structure
/datum/flock/proc/create_structure(turf/location, structure_type)
	new /obj/structure/flock/tealprint(location, src, structure_type)

/// Wrapper for handling bandwidth alongside used_bandwidth for new mobs
/datum/flock/proc/add_bandwidth_influence(num)
	if(num < 0)
		used_bandwidth += abs(num)
	else
		bandwidth.adjust_points(num)

	refresh_unlockables()

/// Wrapper for handling bandwidth alongside used_bandwidth for mobs leaving the flock
/datum/flock/proc/remove_bandwidth_influence(num)
	if(num < 0)
		used_bandwidth -= abs(num)
	else
		bandwidth.adjust_points(-num)

	refresh_unlockables()

/// Refreshes the status of every unlockable.
/datum/flock/proc/refresh_unlockables()
	if(!flock_started)
		return

	var/new_total = bandwidth.has_points()
	var/new_available = available_bandwidth()

	for(var/datum/flock_unlockable/unlockable as anything in unlockables)
		unlockable.refresh_lock_status(src, new_total, new_available)

/// Returns the total amount of bandwidth, including bandwidth being used.
/datum/flock/proc/total_bandwidth()
	return bandwidth.has_points()

/// Returns the amount of available bandwidth. Can return negative if over budget.
/datum/flock/proc/available_bandwidth()
	return bandwidth.has_points() - used_bandwidth

/// Returns TRUE if the flock has the required bandwidth
/datum/flock/proc/can_afford(amt)
	return amt <= max(available_bandwidth(), 0)

/// Updates the substrate cost of an egg given the current status of the flock.
/datum/flock/proc/update_egg_cost()
	var/egg_count = 0
	for(var/obj/structure/flock/egg/egg as anything in structures)
		egg_count++

	var/status_addend = (length(drones) + egg_count) ** sqrt(2)
	current_egg_cost = round(FLOCK_SUBSTRATE_COST_LAY_EGG + status_addend, 10)

/// Returns the substract requirement to be able to spend substrate on an egg. See above proc.
/datum/flock/proc/get_egg_elligibility_cost()
	var/ideal_pop_factor = length(drones) - FLOCK_MIN_DESIRED_POP
	if(ideal_pop_factor <= 0)
		return current_egg_cost

	return round(current_egg_cost + (ideal_pop_factor * FLOCK_ADDITIONAL_RESOURCE_RESERVATION_PER_DRONE), 1)

/// Sets the flock's overmind
/datum/flock/proc/register_overmind(mob/camera/flock_overmind)
	overmind = flock_overmind

/// Updates a mob's enemy status. If they are already an enemy, their entry will be updated with new information.
/datum/flock/proc/update_enemy(atom/movable/enemy)
	if(is_mob_ignored(enemy))
		return FALSE

	for(var/mob/living/L in enemy.buckled_mobs)
		update_enemy(L)

	if(!isliving(enemy))
		return FALSE
	if(!enemies[enemy])
		RegisterSignal(enemy, COMSIG_PARENT_QDELETING, PROC_REF(on_enemy_gone))
		add_notice(enemy, FLOCK_NOTICE_ENEMY)
	enemies[enemy] = get_area_name(enemy)
	return TRUE

/// Removes an atom from the enemies list.
/datum/flock/proc/remove_enemy(atom/movable/enemy, skip_buckled)
	if(!skip_buckled)
		for(var/mob/living/L in enemy.buckled_mobs)
			remove_enemy(L)

	if(!isliving(enemy))
		return

	enemies -= enemy
	UnregisterSignal(enemy, COMSIG_PARENT_QDELETING)
	remove_notice(enemy, FLOCK_NOTICE_ENEMY)
	return

/// Adds a mob to the ignored list.
/datum/flock/proc/add_ignore(atom/movable/ignore)
	for(var/mob/living/L in ignore.buckled_mobs)
		add_ignore(L)

	if(!isliving(ignore))
		return

	if(!enemies[ignore])
		RegisterSignal(ignore, COMSIG_PARENT_QDELETING, PROC_REF(on_ignore_gone))
		add_notice(ignore, FLOCK_NOTICE_IGNORE)
	ignores[ignore] = TRUE

/// Removes a mob from the ignore list.
/datum/flock/proc/remove_ignore(atom/movable/ignore, skip_buckled)
	if(!skip_buckled)
		for(var/mob/living/L in ignore.buckled_mobs)
			add_ignore(L)

	if(!isliving(ignore))
		return

	ignores -= ignore
	remove_notice(ignore, FLOCK_NOTICE_IGNORE)
	UnregisterSignal(ignore, COMSIG_PARENT_QDELETING)

/// (un)Mark a flock atom for deconstruction. Returns FALSE if it cannot be deconstructed.
/datum/flock/proc/toggle_deconstruction_mark(atom/A)
	if(ismob(A) || !HAS_TRAIT(A, TRAIT_FLOCK_THING) || HAS_TRAIT(A, TRAIT_FLOCK_NODECON))
		return FALSE

	if(marked_for_deconstruction[A])
		marked_for_deconstruction -= A
		UnregisterSignal(A, COMSIG_PARENT_QDELETING)
		remove_notice(A, FLOCK_NOTICE_DECONSTRUCT)
	else
		marked_for_deconstruction[A] = TRUE
		RegisterSignal(A, COMSIG_PARENT_QDELETING, PROC_REF(deconstruct_mark_deleted))
		add_notice(A, FLOCK_NOTICE_DECONSTRUCT)
	return TRUE

/// Places a flock notice on an atom. See flock_defines.dm
/datum/flock/proc/add_notice(atom/target, notice_type)
	var/image/I = image(notice_images[notice_type], loc = target)
	return target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/flock, notice_type, I, NONE, src)

/// Removes a flock notice from an atom.
/datum/flock/proc/remove_notice(atom/target, notice_type)
	target.remove_alt_appearance(notice_type)

/// Returns a list of turfs marked for conversion, minus turfs that drones have already reserved.
/datum/flock/proc/get_priority_turfs(mob/living/simple_animal/flock/bird)
	if(!length(marked_for_conversion))
		return null

	return marked_for_conversion - turf_reservations

/// Pings a location, alerting all flocktraces.
/datum/flock/proc/ping(turf/T, mob/camera/flock/pinger)
	var/message = "System interrupt. Designating new target: [T] in [get_area(T)]."
	flock_talk(pinger, message, src, TRUE, list("italics"))
	T.AddComponent(/datum/component/flock_ping, 5 SECONDS)

	for(var/mob/camera/flock/ghost_bird in (traces + overmind))
		var/client/target_client = ghost_bird.client
		if(!target_client)
			if(!ghost_bird.controlling_bird?.client)
				continue
			target_client = ghost_bird.controlling_bird.client

		target_client.mob.playsound_local(null, 'goon/sounds/flockmind/ping.ogg', 50, TRUE)
		if(ghost_bird == pinger)
			continue

		var/image/pointer = pointer_image_to(target_client.mob, T)
		animate(pointer, time = 3 SECONDS, alpha = 0)
		add_ping_image(target_client, pointer, 3 SECONDS)

/// Returns the total percentage of the sum of every mob's health and max health.
/datum/flock/proc/get_total_health_percentage()
	var/numerator = 0
	var/denominator = 0
	for(var/mob/living/basic/flock/bird as anything in (drones + bits))
		numerator += bird.health
		denominator += bird.maxHealth

	if(denominator == 0) // somehow i guess
		return 0

	return round(numerator / denominator * 100, 0.1)

/// Returns the total amount of substrate by all flock mobs.
/datum/flock/proc/get_total_substrate()
	. = 0
	for(var/mob/living/basic/flock/drone/bird as anything in drones)
		. += bird.substrate.has_points()

/// Called when a turf reserved by a flock mob changes.
/datum/flock/proc/reserved_turf_change(datum/source)
	SIGNAL_HANDLER
	free_turf(override_turf = source)

/// Called when a turf owned by the flock changes.
/datum/flock/proc/claimed_turf_change(turf/source)
	SIGNAL_HANDLER
	if(isflockturf(source))
		stop_tracking_turf(source)
		claim_turf(source, FALSE) // WAll to floor or visa-versa, keep it updated.
	else
		stop_tracking_turf(source)

/// Helper for adding a ping image to a client's screen and handling clean up.
/datum/flock/proc/add_ping_image(client/C, image/ping, duration)
	if(isnull(C))
		return

	C.images += ping
	active_pings[C] += list(ping)
	RegisterSignal(C, COMSIG_PARENT_QDELETING, PROC_REF(on_client_gone), override = TRUE)
	addtimer(CALLBACK(src, PROC_REF(cleanup_ping_images), C, ping), 3 SECONDS)

/// Called by add_ping_image via timer callback.
/datum/flock/proc/cleanup_ping_images(client/C, list/images_to_clean)
	if(isnull(C))
		return

	var/list/images = images_to_clean || active_pings[C]
	C.images -= images
	active_pings[C] -= images
	if(!length(active_pings[C]))
		active_pings -= C
		UnregisterSignal(C, COMSIG_PARENT_QDELETING)

/// Checks to see if the given atom is allowed to be there. Has lots of behavior like making drones dormant and snapping traces back to the station.
/datum/flock/proc/is_on_safe_z(atom/A)
	var/turf/T = get_turf(A)
	if(!T.z)
		return FALSE

	if(flock_game_status == FLOCK_ENDGAME_LOST)
		return TRUE

	if(is_station_level(T.z))
		return TRUE

	return FALSE

/// Called when a client holding a ping image disconnects.
/datum/flock/proc/on_client_gone(client/source)
	SIGNAL_HANDLER
	cleanup_ping_images()

/// Called when a unit under the flock's control dies.
/datum/flock/proc/on_unit_death(datum/source)
	SIGNAL_HANDLER
	free_unit(source)

/// Called when an enemy atom is deleted.
/datum/flock/proc/on_enemy_gone(datum/source)
	SIGNAL_HANDLER
	remove_enemy(source, TRUE)

/// Called when an ignored mob is deleted.
/datum/flock/proc/on_ignore_gone(datum/source)
	SIGNAL_HANDLER
	remove_ignore(source, TRUE)

/// Instantiates all of the flock notice image singletons.
/datum/flock/proc/create_hud_images()
	notice_images[FLOCK_NOTICE_RESERVED] = new /image{
		icon = 'goon/icons/mob/featherzone.dmi';
		icon_state = "frontier";
		plane = ABOVE_LIGHTING_PLANE;
		appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM;
		alpha = 80;
	}

	notice_images[FLOCK_NOTICE_PRIORITY] = new /image{
		icon = 'goon/icons/mob/featherzone.dmi';
		icon_state = "frontier";
		plane = ABOVE_LIGHTING_PLANE;
		appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM;
		alpha = 180;
	}

	notice_images[FLOCK_NOTICE_ENEMY] = new /image{
		icon = 'goon/icons/mob/featherzone.dmi';
		icon_state = "hazard";
		pixel_y = 16;
		plane = ABOVE_LIGHTING_PLANE;
		appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM;
	}

	notice_images[FLOCK_NOTICE_IGNORE] = new /image{
		icon = 'goon/icons/mob/featherzone.dmi';
		icon_state = "ignore";
		pixel_y = 16;
		plane = ABOVE_LIGHTING_PLANE;
		appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM;
	}

	notice_images[FLOCK_NOTICE_FLOCKMIND_CONTROL] = new /image{
		icon = 'goon/icons/mob/featherzone.dmi';
		icon_state = "flockmind_face";
		pixel_y = 16;
		plane = ABOVE_LIGHTING_PLANE;
		appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM;
	}

	notice_images[FLOCK_NOTICE_FLOCKTRACE_CONTROL] = new /image{
		icon = 'goon/icons/mob/featherzone.dmi';
		icon_state = "flocktrace_face";
		pixel_y = 16;
		plane = ABOVE_LIGHTING_PLANE;
		appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM;
	}

	notice_images[FLOCK_NOTICE_DECONSTRUCT] = new /image{
		icon = 'goon/icons/mob/featherzone.dmi';
		icon_state = "deconstruct";
		pixel_y = 16;
		plane = ABOVE_LIGHTING_PLANE;
		appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM;
	}

	notice_images[FLOCK_NOTICE_HEALTH] = new /image{
		icon = 'goon/icons/mob/featherzone.dmi';
		icon_state = "hp-100";
		pixel_x = 10;
		pixel_y = 16;
		plane = ABOVE_LIGHTING_PLANE;
		appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM;
	}

/// Setter for flock_game_status.
/datum/flock/proc/set_flock_game_status(new_status)
	var/old_status = flock_game_status
	if(old_status == new_status)
		return null

	flock_game_status = new_status

	return old_status

/// Update the relay status huds for all flock traces and the overmind.
/datum/flock/proc/update_relay_huds()
	var/new_alpha

	switch(flock_game_status)
		if(NONE)
			var/percent_avail_bandwidth = min(available_bandwidth() / FLOCK_COMPUTE_COST_RELAY, 1)
			var/percent_tiles = min((length(claimed_floors) + length(claimed_walls)) / FLOCK_TURFS_FOR_RELAY, 1)
			new_alpha = round(255 * percent_avail_bandwidth * percent_tiles)

		if(FLOCK_ENDGAME_LOST)
			new_alpha = 0

		else
			new_alpha = 255

	var/new_desc
	switch(flock_game_status)
		if(NONE)
			var/percent_avail_bandwidth = min(100, floor(available_bandwidth() / FLOCK_COMPUTE_COST_RELAY * 100))
			var/percent_tiles = min(100, floor((length(claimed_floors) + length(claimed_walls)) / FLOCK_TURFS_FOR_RELAY * 100))
			var/percent_total = floor((percent_avail_bandwidth / 100) * (percent_tiles / 100) * 100)
			new_desc =  "Overall Progress: [percent_total]%</br>Bandwidth: [percent_avail_bandwidth]%</br>Converted: [percent_tiles]%"

		if(FLOCK_ENDGAME_RELAY_BUILT)
			new_desc = "Time until broadcast: [] seconds."

		if(FLOCK_ENDGAME_RELAY_ACTIVATING, FLOCK_ENDGAME_VICTORY)
			new_desc = "!!! TRANSMITTING !!!"

	for(var/mob/camera/flock/ghost_bird in (traces + overmind))
		var/atom/movable/screen/flock_relay_status/status
		if(ghost_bird.controlling_bird)
			status = astype(ghost_bird.controlling_bird.hud_used, /datum/hud/flockdrone)?.relay_status
		else
			status = astype(ghost_bird.hud_used, /datum/hud/flockghost)?.relay_status

		status.desc = new_desc
		status.alpha = new_alpha
		if(status.flock_status == flock_game_status)
			continue

		status.flock_status = flock_game_status
		status.update_appearance()

/// Ends the flock if it is unable to continue spreading.
/datum/flock/proc/consider_game_over()
	if(!flock_started)
		return FALSE

	if(flock_game_status == FLOCK_ENDGAME_LOST)
		return TRUE

	if(flock_game_status == FLOCK_ENDGAME_VICTORY)
		return TRUE

	if(length(drones))
		return FALSE

	if(locate(/obj/structure/flock/egg, structures) || locate(/obj/structure/flock/rift, structures))
		return FALSE

	game_over()
	return TRUE

/// Kills off the flock. Pass completely_destroy = FALSE to allow the overmind to live on.
/datum/flock/proc/game_over(completely_destroy = TRUE)
	set waitfor = FALSE

	// Cleanup any pings
	for(var/client/C in active_pings)
		cleanup_ping_images(C)

	// Cleanup turf claims
	for(var/turf/T as anything in turf_reservations)
		free_turf(override_turf = T)

	for(var/turf/flockturf as anything in claimed_floors + claimed_walls)
		stop_tracking_turf(flockturf)
		CHECK_TICK

	// Extra lives
	if(!completely_destroy)
		refresh_unlockables()
		return

	set_flock_game_status(FLOCK_ENDGAME_LOST)

	// Kill overmind
	overmind?.so_very_sad_death() // Overmind can be null here if it died outside of game_over().

	// Kill traces
	for(var/mob/camera/flock/trace/ghostbird as anything in traces)
		ghostbird.so_very_sad_death()

	// Free units
	for(var/mob/living/basic/flock/bird as anything in (bits + drones))
		bird.dormantize()

	// Blow up structures
	for(var/obj/structure/flock/structure as anything in structures)
		structure.deconstruct(FALSE)

	// Remove ignores
	for(var/mob/M as anything in ignores)
		remove_ignore(M, TRUE)

	// Remove enemies
	for(var/mob/M as anything in enemies)
		remove_enemy(M, TRUE)

/// Called when an atom marked for deconstruction is qdeleted.
/datum/flock/proc/deconstruct_mark_deleted(datum/source)
	SIGNAL_HANDLER

	toggle_deconstruction_mark(source)
