/datum/spell_targeting/directional
	use_intercept_click = TRUE

/datum/spell_targeting/directional/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	return clicked_atom ? list(clicked_atom) : null

