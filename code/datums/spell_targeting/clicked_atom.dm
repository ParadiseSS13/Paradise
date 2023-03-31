/**
 * A simple spell targeting system. Will return the clicked atom as a target. Only works for 1 target max and is basically a dumbed down [/datum/spell_targeting/click]
 */
/datum/spell_targeting/clicked_atom
	use_intercept_click = TRUE

/datum/spell_targeting/clicked_atom/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	if(clicked_atom)
		return list(clicked_atom)
	else
		return null

