/**
 * An area of effect based spell targeting system. Will return all targets in the given range
 */
/datum/spell_targeting/aoe
	max_targets = INFINITY
	/// The radius of turfs not being affected. -1 is inactive
	var/inner_radius = -1

/datum/spell_targeting/aoe/choose_targets(mob/user, datum/spell/spell, params, atom/clicked_atom)
	var/list/targets = list()
	var/spell_center = use_turf_of_user ? get_turf(user) : user

	for(var/atom/target in view_or_range(range, spell_center, selection_type))
		if(valid_target(target, user, spell, FALSE))
			targets += target
	if(inner_radius >= 0)
		targets -= view_or_range(inner_radius, user, selection_type) // remove the inner ring
	return targets

/datum/spell_targeting/aoe/turf
	allowed_type = /turf
