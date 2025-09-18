PROCESSING_SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	flags = SS_BACKGROUND | SS_NO_INIT
	wait = 1 SECONDS
	offline_implications = "Radiation will no longer function; power generation may not happen. A restart may or may not be required, depending on the situation."
	cpu_display = SS_CPUDISPLAY_HIGH
	var/list/warned_atoms = list()
	// Cache radiation levels for each turf so it doesn't need to be done iteratively
	// turf_rad_cache is the state in the current loop, and may not be 100% representative
	// until processing is complete.
	// prev_rad_cache is the fully evaluated radiation state cache from the previous tick.
	var/last_rad_cache_update = 0
	var/rad_cache_update_interval = 5 SECONDS
	var/list/turf_rad_cache = list()
	var/list/prev_rad_cache = list()
	/// Lazy list of all radioactive components
	var/list/all_radiations


/datum/controller/subsystem/processing/radiation/proc/warn(datum/component/radioactive/contamination)
	if(!contamination || QDELETED(contamination))
		return
	var/ref = contamination.parent.UID()
	if(warned_atoms[ref])
		return
	warned_atoms[ref] = TRUE
	var/atom/master = contamination.parent
	SSblackbox.record_feedback("tally", "contaminated", 1, master.type)
	var/msg = "has become contaminated with enough radiation to emit radiation waves || Source: [contamination.source] || Strength: [contamination.alpha_strength + contamination.beta_strength + contamination.gamma_strength]"
	master.investigate_log(msg, INVESTIGATE_RADIATION)

/datum/controller/subsystem/processing/radiation/fire(resumed)
	if(world.time > last_rad_cache_update + rad_cache_update_interval)
		refresh_rad_cache()
		last_rad_cache_update = world.time
	for(var/emission_type in GLOB.turf_rad_item_cache)
		GLOB.turf_rad_item_cache["[emission_type]"] = list()
	. = ..()

/datum/controller/subsystem/processing/radiation/proc/get_turf_radiation(turf/place)
	if(prev_rad_cache[place])
		return prev_rad_cache[place]
	else
		return 0

/datum/controller/subsystem/processing/radiation/proc/update_rad_cache_contaminated(datum/component/radioactive/thing)
	var/atom/owner = thing.parent
	var/turf/place = get_turf(owner)
	if(turf_rad_cache[place])
		turf_rad_cache[place][1] += thing.alpha_strength
		turf_rad_cache[place][2] += thing.beta_strength
		turf_rad_cache[place][3] += thing.gamma_strength
	else
		turf_rad_cache[place] = list(thing.alpha_strength, thing.beta_strength, thing.gamma_strength)

/datum/controller/subsystem/processing/radiation/proc/update_rad_cache_inherent(datum/component/inherent_radioactivity/thing)
	var/atom/owner = thing.parent
	var/turf/place = get_turf(owner)
	if(turf_rad_cache[place])
		turf_rad_cache[place][1] += thing.radioactivity_alpha
		turf_rad_cache[place][2] += thing.radioactivity_beta
		turf_rad_cache[place][3] += thing.radioactivity_gamma
	else
		turf_rad_cache[place] = list(thing.radioactivity_alpha, thing.radioactivity_beta, thing.radioactivity_gamma)


/datum/controller/subsystem/processing/radiation/proc/refresh_rad_cache()
	prev_rad_cache.Cut()
	prev_rad_cache = turf_rad_cache
	turf_rad_cache = list()
