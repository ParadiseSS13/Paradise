/**
  * Attached to movable atoms with opacity. Listens to them move and updates their old and new turf loc's opacity accordingly
  */
/datum/element/light_blocking
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/light_blocking/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_move))
	var/atom/movable/movable_target = target
	if(isturf(movable_target.loc))
		var/turf/turf_loc = movable_target.loc
		turf_loc.add_opacity_source(target)

/datum/element/light_blocking/Detach(atom/movable/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	var/atom/movable/movable_target = target
	if(isturf(movable_target.loc))
		var/turf/turf_loc = movable_target.loc
		turf_loc.remove_opacity_source(target)

/// Updates old and new turf loc opacities
/datum/element/light_blocking/proc/on_target_move(atom/movable/source, atom/old_loc, dir, forced = FALSE)
	if(isturf(old_loc))
		var/turf/old_turf = old_loc
		old_turf.remove_opacity_source(source)
	if(isturf(source.loc))
		var/turf/new_turf = source.loc
		new_turf.add_opacity_source(source)
