/datum/spell_targeting
	/// The range of the spell; outer radius for aoe spells
	var/range = 7
	/// Can be "range" or "view"
	var/selection_type = "view"
	/// How many targets are allowed.
	var/max_targets
	/// Which type the targets have to be
	var/allowed_type = /mob/living
	/// If it includes user
	var/include_user = 0
	/// Whether or not the targeting is done by intercepting a click or not
	var/use_intercept_click = FALSE
	/// Whether or not the spell will try to auto target first before setting up the intercept click
	var/try_auto_target = FALSE

/**
 * Called when choosing the targets for the parent spell
 *
 * Arguments:
 * * user - the one who casts the spell
 * * spell - The spell being cast
 * * params - Params given by the intercept click. Only available if use_intercept_click is TRUE
 * * clicked_atom - The atom clicked on. Only available if use_intercept_click is TRUE
 */
/datum/spell_targeting/proc/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	SHOULD_NOT_SLEEP(TRUE)
	RETURN_TYPE(/list)
	return

/**
 * Will attempt to auto target the spell. Only works with 1 target
 */
/datum/spell_targeting/proc/attempt_auto_target(mob/user, obj/effect/proc_holder/spell/spell)
	var/atom/target
	for(var/atom/A in view_or_range(range, user, selection_type))
		if(valid_target(A, user))
			if(target)
				return FALSE // Two targets found. ABORT
			target = A

	if(target)
		to_chat(user, "<span class='warning'>Only one target found. Casting [src] on [target]!</span>")
		spell.try_perform(list(target), user)
		return TRUE
	return FALSE

/**
 * Called when the parent spell intercepts the click
 *
 * Arguments:
 * * user - Who clicks with the spell targeting active?
 * * params - Additional parameters from the click
 * * A - Atom the user clicked on
 * * spell - The spell being cast
 */
/datum/spell_targeting/proc/InterceptClickOn(mob/user, params, atom/A, obj/effect/proc_holder/spell/spell)
	var/list/targets = choose_targets(user, spell, params, A)
	spell.try_perform(targets, user)
	return


/datum/spell_targeting/proc/valid_target(target, user)
	return istype(target, allowed_type) && (include_user || target != user) && \
		(target in view_or_range(range, user, selection_type))
