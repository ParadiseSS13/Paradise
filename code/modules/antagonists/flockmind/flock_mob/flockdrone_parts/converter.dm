/datum/flockdrone_part/converter

/datum/flockdrone_part/converter/left_click_on(atom/target, in_reach)
	if(!in_reach)
		return

	if(isliving(target))
		return try_cage(target)

	if(istype(target, /obj/structure/flock/tealprint))
		var/datum/action/cooldown/flock/deposit/deposit_action = locate() in drone.actions
		return deposit_action.Trigger(target = target)

	var/turf/T = get_turf(target)
	var/datum/action/cooldown/flock/convert/convert_action = locate() in drone.actions
	return convert_action.Trigger(target = T)

/datum/flockdrone_part/converter/right_click_on(atom/target, in_reach)
	if(!in_reach)
		return

	var/datum/action/cooldown/flock/deconstruct/decon_action = locate() in drone.actions
	return decon_action.Trigger(target = target)

/datum/flockdrone_part/converter/proc/try_cage(mob/living/victim)
	if(isflockmob(victim))
		to_chat(drone, span_warning("ERROR: Unable to imprison substrate construct."))
		return FALSE

	var/datum/action/cooldown/flock/cage_mob/cage_action = locate() in drone.actions
	return cage_action.Trigger(target = victim)
