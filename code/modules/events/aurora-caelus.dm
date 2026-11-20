/datum/event/aurora_caelus
	name = "Aurora Caelus"
	nominal_severity = EVENT_LEVEL_MAJOR
	endWhen = 50
	/// List of colors that the aurora takes
	var/list/aurora_colors = list("#A2FF80", "#A2FF8B", "#A2FF96", "#A2FFA5", "#A2FFAF", "#A2FFB6", "#A2FFC1", "#A2FFC7", "#A2FFDE", "#A2FFEE")
	/// Event stage
	var/aurora_progress = 0
	/// Target light range
	var/aurora_light_range = 4
	/// Starlight power on space during the aurora
	var/aurora_space_power = 1.2
	/// Starlight range when there's no aurora
	var/normal_light_range = 2
	/// How many steps it takes to fade back to normal
	var/fade_steps = 5
	/// Time between fade steps
	var/fade_step_time = 6 SECONDS
	/// Each change is spread over this long, so lighting can keep up with it
	var/spread_time = 5 SECONDS
	/// Every turf we changed the light of, so we can put them all back
	var/list/lit_turfs = list()
	/// Goes up with every change, so an older one still going can stop
	var/light_change = 0
	/// We stop and wait while lighting has more than this many updates waiting
	var/lighting_backlog_limit = 1000

/datum/event/aurora_caelus/announce(false_alarm)
	. = ..()
	GLOB.major_announcement.Announce(
		"[station_name()]: A harmless cloud of ions is approaching your station, and will exhaust their energy battering the hull. During this time, starlight will be bright but gentle, shifting between quiet green and blue colors. \n\nNanotrasen has approved a short break for all employees to relax and observe this very rare event. Any staff who would like to view these lights for themselves may proceed to the area nearest to them with viewing ports to open space. \n\nWe hope you enjoy the lights.",
		"Nanotrasen Meteorology Division",
		'sound/misc/announce.ogg'
	)

/datum/event/aurora_caelus/start()
	addtimer(CALLBACK(src, PROC_REF(start_music)), 5 SECONDS)

/datum/event/aurora_caelus/tick()
	. = ..()
	if(activeFor % 5 == 0)
		aurora_progress++
		INVOKE_ASYNC(src, PROC_REF(light_starlight), 0)

/datum/event/aurora_caelus/end()
	. = ..()
	if(aurora_progress)
		fade_back(1)
	GLOB.major_announcement.Announce("The Aurora Caelus event is now ending. Starlight conditions will slowly return to normal. When this has concluded, please return to your workplace and continue work as normal. \n\nHave a pleasant shift, [station_name()], and thank you for watching with us.",
		"Nanotrasen Meteorology Division",
		'sound/misc/announce.ogg'
	)

/datum/event/aurora_caelus/proc/start_music()
	for(var/mob/M in GLOB.player_list)
		if(!M.client || isnewplayer(M))
			continue
		if(M.client.prefs.sound & SOUND_MIDI)
			M.playsound_local(M, 'sound/ambience/aurora_caelus.ogg', 20, FALSE, pressure_affected = FALSE)

/// Dims the starlight one step and sets a timer for the next. After the last step it goes back to normal.
/datum/event/aurora_caelus/proc/fade_back(fade_step)
	if(fade_step >= fade_steps)
		INVOKE_ASYNC(src, PROC_REF(restore_starlight))
		return
	INVOKE_ASYNC(src, PROC_REF(light_starlight), fade_step / fade_steps)
	addtimer(CALLBACK(src, PROC_REF(fade_back), fade_step + 1), fade_step_time)

/// Sets the light of every starlight turf. Progress goes from 0 (full aurora) to 1 (back to normal power).
/// The range only changes on the first one. After that it's just power and colour.
/datum/event/aurora_caelus/proc/light_starlight(progress)
	var/change = ++light_change
	var/light_color = aurora_colors[aurora_progress]
	// Copied since we sleep, and turfs can change in the meantime
	var/list/turfs = GLOB.starlight.Copy()
	// Do a batch of turfs each tick, so the whole station takes spread_time (5 seconds) instead of all landing on lighting at once.
	// Between batches, wait_for_lighting() also waits if lighting is backed up.
	var/per_tick = max(1, CEILING(length(turfs) * world.tick_lag / spread_time, 1))
	for(var/i in 1 to length(turfs))
		if(!(i % per_tick) && !wait_for_lighting(change))
			return
		var/turf/spess = turfs[i]
		// Lost its starlight since we copied the list
		if(!spess.light)
			continue
		var/normal_power = initial(spess.light_power)
		var/aurora_power
		if(isspaceturf(spess))
			aurora_power = aurora_space_power
		else if(istype(spess, /turf/simulated/floor/transparent/glass))
			aurora_power = normal_power * 0.6
		else
			continue
		spess.set_light(aurora_light_range, aurora_power + (normal_power - aurora_power) * progress, light_color)
		lit_turfs[spess] = TRUE

/// Puts every turf we changed back to its normal light
/datum/event/aurora_caelus/proc/restore_starlight()
	var/change = ++light_change
	var/list/turfs = lit_turfs
	lit_turfs = list()
	// Spread out the same way as light_starlight()
	var/per_tick = max(1, CEILING(length(turfs) * world.tick_lag / spread_time, 1))
	var/i = 0
	for(var/turf/spess as anything in turfs)
		if(!(++i % per_tick) && !wait_for_lighting(change))
			return
		var/light_range
		if(isspaceturf(spess))
			light_range = normal_light_range
		else if(istype(spess, /turf/simulated/floor/transparent/glass))
			light_range = initial(spess.light_range)
		else
			continue
		// set_light() treats a null colour as no change, so set it directly
		spess.light_color = initial(spess.light_color)
		if(spess.light)
			spess.set_light(light_range, initial(spess.light_power))
		else
			// Lost its starlight during the event, so just fix its power for when update_starlight() lights it again
			spess.light_power = initial(spess.light_power)

/// Waits at least a tick, and longer while lighting is backed up, so other lights don't queue behind ours.
/// Returns FALSE if a newer change started in the meantime.
/datum/event/aurora_caelus/proc/wait_for_lighting(change)
	do
		stoplag()
		if(change != light_change)
			return FALSE
	while(length(SSlighting.sources_queue) + length(SSlighting.objects_queue) > lighting_backlog_limit)
	return TRUE
