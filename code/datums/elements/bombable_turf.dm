/**
 * Apply this to a turf (usually a wall) and it will be destroyed instantly by any explosion.
 * Most walls can already be destroyed by explosions so this is largely for usually indestructible ones.
 * For applying it in a map editor, use /obj/effect/mapping_helpers/bombable_wall
 */
/datum/element/bombable_turf

/datum/element/bombable_turf/Attach(turf/target)
	. = ..()
	if(!iswallturf(target))
		return ELEMENT_INCOMPATIBLE
	var/turf/simulated/wall/W = target
	W.explosion_block = 1
	W.explodable = TRUE

	RegisterSignal(W, COMSIG_ATOM_EX_ACT, PROC_REF(detonate))
	RegisterSignal(W, COMSIG_TURF_CHANGE, PROC_REF(turf_changed))
	RegisterSignal(W, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))

	W.update_appearance(UPDATE_OVERLAYS)

/datum/element/bombable_turf/Detach(turf/source)
	UnregisterSignal(source, list(COMSIG_ATOM_EX_ACT, COMSIG_TURF_CHANGE, COMSIG_PARENT_EXAMINE))
	source.explosion_block = initial(source.explosion_block)
	source.update_appearance(UPDATE_OVERLAYS)
	return ..()

/// If we get blowed up, move to the next turf
/datum/element/bombable_turf/proc/detonate(turf/source)
	SIGNAL_HANDLER
	source.ChangeTurf(source.baseturf)

/// If this turf becomes something else we either just went off or regardless don't want this any more
/datum/element/bombable_turf/proc/turf_changed(turf/source)
	SIGNAL_HANDLER
	Detach(source)

/// Show a little extra on examine
/datum/element/bombable_turf/proc/on_examined(turf/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='notice'>It seems to be slightly cracked...</span>"
