/**
 * The base class for the targeting systems spells use.
 *
 * To create a new targeting datum you just inherit from this base type and override the [/datum/spell_targeting/proc/choose_targets] proc.
 * Override the [/datum/spell_targeting/proc/valid_target] proc for more complex validations.
 * More complex behaviour like [auto targeting][/datum/spell_targeting/proc/attempt_auto_target] and [click based][/datum/spell_targeting/proc/InterceptClickOn] activation is possible.
 */
/datum/spell_targeting
	/// The range of the spell; outer radius for aoe spells
	var/range = 7
	/// Can be SPELL_SELECTION_RANGE or SPELL_SELECTION_VIEW
	var/selection_type = SPELL_SELECTION_VIEW
	/// How many targets are allowed. INFINITY is used to target unlimited targets
	var/max_targets = 1
	/// Which type the targets have to be
	var/allowed_type = /mob/living/carbon/human
	/// If it includes user. Not always used in all spell_targeting objects
	var/include_user = FALSE
	/// Whether or not the targeting is done by intercepting a click or not
	var/use_intercept_click = FALSE
	/// Whether or not the spell will try to auto target first before setting up the intercept click
	var/try_auto_target = FALSE
	/// Whether or not the spell should use the turf of the user as starting point
	var/use_turf_of_user = FALSE

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
	RETURN_TYPE(/list)
	return

/**
 * Will attempt to auto target the spell. Only works with 1 target currently
 */
/datum/spell_targeting/proc/attempt_auto_target(mob/user, obj/effect/proc_holder/spell/spell)
	var/atom/target
	for(var/atom/A in view_or_range(range, use_turf_of_user ? get_turf(user) : user, selection_type))
		if(valid_target(A, user, spell))
			if(target)
				return FALSE // Two targets found. ABORT
			target = A

	if(target)
		to_chat(user, "<span class='warning'>Only one target found. Casting [spell] on [target]!</span>")
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

/**
 * Checks whether or not the given target is valid. Calls spell.valid_target as well
 *
 * Arguments:
 * * target - The one who is being considered as a target
 * * user - Who is casting the spell
 * * spell - The spell being cast
 */
/datum/spell_targeting/proc/valid_target(target, user, obj/effect/proc_holder/spell/spell)
	SHOULD_CALL_PARENT(TRUE)
	return istype(target, allowed_type) && (include_user || target != user) && \
		spell.valid_target(target, user) && (target in view_or_range(range, use_turf_of_user ? get_turf(user) : user, selection_type))
