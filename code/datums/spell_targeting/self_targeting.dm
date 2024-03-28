/**
 * A spell targeting system which will return the caster as target
 */
/datum/spell_targeting/self

/datum/spell_targeting/self/choose_targets(mob/user, datum/spell/spell, params, atom/clicked_atom)
	return list(user) // That's how simple it is
