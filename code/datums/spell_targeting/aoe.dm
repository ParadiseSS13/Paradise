/datum/spell_targeting/aoe
	/// The radius of turfs not being affected. -1 is inactive
	var/inner_radius = -1

/datum/spell_targeting/aoe/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	var/list/targets = list()

	for(var/turf/target in view_or_range(range,user,selection_type))
		targets += target
	if(inner_radius >= 0)
		targets -= view_or_range(inner_radius,user,selection_type) // remove the inner ring
	return targets
