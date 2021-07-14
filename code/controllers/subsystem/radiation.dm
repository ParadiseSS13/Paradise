PROCESSING_SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	flags = SS_BACKGROUND
	wait = 1 SECONDS
	offline_implications = "Radiation will no longer function; power generation may not happen. A restart may or may not be required, depending on the situation."
	var/list/warned_atoms = list()
	var/datum/radiation_cache/turf_cache

/datum/controller/subsystem/processing/radiation/Initialize(start_timeofday)
	. = ..()
	turf_cache = new()

/datum/controller/subsystem/processing/radiation/proc/warn(datum/component/radioactive/contamination)
	if(!contamination || QDELETED(contamination))
		return
	var/ref = contamination.parent.UID()
	if(warned_atoms[ref])
		return
	warned_atoms[ref] = TRUE
	var/atom/master = contamination.parent
	SSblackbox.record_feedback("tally", "contaminated", 1, master.type)
	var/msg = "has become contaminated with enough radiation to contaminate other objects. || Source: [contamination.source] || Strength: [contamination.strength]"
	master.investigate_log(msg, "radiation")

/datum/controller/subsystem/processing/radiation/proc/get_turf_radiation(turf/place)
	return turf_cache.get_turf_radiation(place)

/datum/controller/subsystem/processing/radiation/proc/update_rad_cache(datum/component/radioactive/thing)
	return turf_cache.update_rad_cache(thing)
/datum/radiation_cache
	// Cache radiation levels for each turf so it doesn't need to be done iteratively
	// turf_rad_cache is the state in the current loop, and may not be 100% representative
	// until processing is complete.
	// prev_rad_cache is the fully evaluated radiation state cache from the previous tick.
	var/has_refreshed_cache = FALSE
	var/list/turf_rad_cache = list()
	var/list/prev_rad_cache = list()

/datum/radiation_cache/New()
	. = ..()
	START_PROCESSING(SSradiation, src)

/datum/radiation_cache/Destroy()
	STOP_PROCESSING(SSradiation, src)
	return ..()

/datum/radiation_cache/proc/refresh_rad_cache()
	prev_rad_cache = turf_rad_cache.Copy()
	turf_rad_cache = list()

/datum/radiation_cache/proc/get_turf_radiation(turf/place)
	if (prev_rad_cache[place])
		return prev_rad_cache[place]
	else
		return 0

/datum/radiation_cache/proc/update_rad_cache(datum/component/radioactive/thing)
	var/atom/owner = thing.parent
	var/turf/place = get_turf(owner)
	if (turf_rad_cache[place])
		turf_rad_cache[place] += thing.strength
	else
		turf_rad_cache[place] = thing.strength

/datum/radiation_cache/process()
	refresh_rad_cache()
