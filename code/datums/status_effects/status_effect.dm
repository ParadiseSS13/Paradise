//Status effects are used to apply temporary or permanent effects to mobs. Mobs are aware of their status effects at all times.
//This file contains their code, plus code for applying and removing them.
//When making a new status effect, add a define to status_effects.dm in __DEFINES for ease of use!

/datum/status_effect
	/// A unique ID that is used to see if there is already a status effect of the same type on something. Also used for screen alerts
	var/id
	var/duration = -1 //How long the status effect lasts in DECISECONDS. Enter -1 for an effect that never ends unless removed through some means.
	var/tick_interval = 10 //How many deciseconds between ticks, approximately. Leave at 10 for every second. Setting this to -1 will stop processing if duration is also unlimited.
	var/mob/living/owner //The mob affected by the status effect.
	var/status_type = STATUS_EFFECT_UNIQUE //How many of the effect can be on one mob, and what happens when you try to add another
	var/on_remove_on_mob_delete = FALSE //if we call on_remove() when the mob is deleted
	var/examine_text //If defined, this text will appear when the mob is examined - to use he, she etc. use "SUBJECTPRONOUN" and replace it in the examines themselves
	var/alert_type = /atom/movable/screen/alert/status_effect //the alert thrown by the status effect, contains name and description
	var/atom/movable/screen/alert/status_effect/linked_alert = null //the alert itself, if it exists

/datum/status_effect/New(list/arguments)
	if(!id)
		stack_trace("[src] was created but did not have an unique ID. Deleting.")
		qdel(src)
		return

	on_creation(arglist(arguments))

/datum/status_effect/proc/on_creation(mob/living/new_owner, ...)
	if(new_owner)
		owner = new_owner
	if(owner)
		LAZYADD(owner.status_effects, src)
	if(!owner || !on_apply())
		qdel(src)
		return
	if(duration != -1)
		duration = world.time + duration
	tick_interval = world.time + tick_interval
	if(alert_type)
		var/atom/movable/screen/alert/status_effect/A = owner.throw_alert(id, alert_type)
		A.attached_effect = src //so the alert can reference us, if it needs to
		linked_alert = A //so we can reference the alert, if we need to
	if(duration > 0 || initial(tick_interval) > 0) //don't process if we don't care
		START_PROCESSING(SSfastprocess, src)
	return TRUE

/datum/status_effect/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(owner)
		owner.clear_alert(id)
		LAZYREMOVE(owner.status_effects, src)
		on_remove()
		owner = null
	if(linked_alert)
		linked_alert.attached_effect = null
	linked_alert = null
	return ..()

/datum/status_effect/process()
	if(!owner)
		qdel(src)
		return
	if(tick_interval <= world.time)
		tick()
		tick_interval = world.time + initial(tick_interval)
	if(duration != -1 && duration < world.time)
		on_timeout()
		qdel(src)

/datum/status_effect/proc/on_apply() //Called whenever the buff is applied; returning FALSE will cause it to autoremove itself.
	return TRUE

/datum/status_effect/proc/tick() //Called every tick.
	return

/datum/status_effect/proc/on_remove() //Called whenever the buff expires or is removed; do note that at the point this is called, it is out of the owner's status_effects but owner is not yet null
	return

/datum/status_effect/proc/on_timeout()  // Called specifically whenever the status effect expires.
	return

/datum/status_effect/proc/be_replaced() //Called instead of on_remove when a status effect is replaced by itself or when a status effect with on_remove_on_mob_delete = FALSE has its mob deleted
	owner.clear_alert(id)
	LAZYREMOVE(owner.status_effects, src)
	owner = null
	qdel(src)

/datum/status_effect/proc/before_remove() //! Called before being removed; returning FALSE will cancel removal
	return TRUE

/datum/status_effect/proc/refresh()
	var/original_duration = initial(duration)
	if(original_duration == -1)
		return
	duration = world.time + original_duration

//clickdelay/nextmove modifiers!
/datum/status_effect/proc/nextmove_modifier()
	return 1

/datum/status_effect/proc/nextmove_adjust()
	return 0

////////////////
// ALERT HOOK //
////////////////

/atom/movable/screen/alert/status_effect
	name = "Curse of Mundanity"
	desc = "You don't feel any different..."
	var/datum/status_effect/attached_effect

/atom/movable/screen/alert/status_effect/Destroy()
	if(attached_effect)
		attached_effect.linked_alert = null
	attached_effect = null
	return ..()


//////////////////
// HELPER PROCS //
//////////////////

/// Applies a given status effect to this mob, returning the effect if it was successful or null otherwise
/mob/living/proc/apply_status_effect(effect, ...)
	. = null
	if(QDELETED(src))
		return
	var/datum/status_effect/S1 = effect
	LAZYINITLIST(status_effects)
	for(var/datum/status_effect/S in status_effects)
		if(S.id == initial(S1.id) && S.status_type)
			if(S.status_type == STATUS_EFFECT_REPLACE)
				S.be_replaced()
			else if(S.status_type == STATUS_EFFECT_REFRESH)
				S.refresh()
				return
			else
				return
	var/list/arguments = args.Copy()
	arguments[1] = src
	S1 = new effect(arguments)
	. = S1

/// Removes all of a given status effect from this mob, returning TRUE if at least one was removed
/mob/living/proc/remove_status_effect(effect, ...)
	. = FALSE
	var/list/arguments = args.Copy(2)
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects)
			if(initial(S1.id) == S.id && S.before_remove(arglist(arguments)))
				qdel(S)
				. = TRUE

/// Returns the effect if the mob calling the proc owns the given status effect, or null otherwise
/mob/living/proc/has_status_effect(effect)
	. = null
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects)
			if(initial(S1.id) == S.id)
				return S

/// Returns the effect if the mob calling the proc owns the given status effect, but checks by type.
/mob/living/proc/has_status_effect_type(effect)
	if(!length(status_effects))
		return
	for(var/datum/status_effect/S in status_effects)
		if(istype(S, effect))
			return S

/// Returns a list of effects with matching IDs that the mod owns; use for effects there can be multiple of
/mob/living/proc/has_status_effect_list(effect)
	. = list()
	if(status_effects)
		var/datum/status_effect/S1 = effect
		for(var/datum/status_effect/S in status_effects)
			if(initial(S1.id) == S.id)
				. += S

//////////////////////
// STACKING EFFECTS //
//////////////////////

/datum/status_effect/stacking
	id = "stacking_base"
	alert_type = null
	var/stacks = 0 //how many stacks are accumulated, also is # of stacks that target will have when first applied
	var/delay_before_decay //deciseconds until ticks start occuring, which removes stacks (first stack will be removed at this time plus tick_interval)
	var/stack_decay = 1 //how many stacks are lost per tick (decay trigger)
	var/stack_threshold //special effects trigger when stacks reach this amount
	var/max_stacks //stacks cannot exceed this amount
	var/consumed_on_threshold = TRUE //if status should be removed once threshold is crossed
	var/threshold_crossed = FALSE //set to true once the threshold is crossed, false once it falls back below
	var/reset_ticks_on_stack = FALSE //resets the current tick timer if a stack is gained

/datum/status_effect/stacking/proc/threshold_cross_effect() //what happens when threshold is crossed
	return

/datum/status_effect/stacking/proc/stacks_consumed_effect() //runs if status is deleted due to threshold being crossed
	return

/datum/status_effect/stacking/proc/fadeout_effect() //runs if status is deleted due to being under one stack
	return

/datum/status_effect/stacking/proc/stack_decay_effect() //runs every time tick() causes stacks to decay
	return

/datum/status_effect/stacking/proc/on_threshold_cross()
	threshold_cross_effect()
	if(consumed_on_threshold)
		stacks_consumed_effect()
		qdel(src)

/datum/status_effect/stacking/proc/on_threshold_drop()
	return

/datum/status_effect/stacking/proc/can_have_status()
	return owner.stat != DEAD

/datum/status_effect/stacking/proc/can_gain_stacks()
	return owner.stat != DEAD

/datum/status_effect/stacking/tick()
	if(!can_have_status())
		qdel(src)
	else
		add_stacks(-stack_decay)
		stack_decay_effect()

/datum/status_effect/stacking/proc/add_stacks(stacks_added)
	if(stacks_added > 0 && !can_gain_stacks())
		return FALSE
	stacks += stacks_added
	if(reset_ticks_on_stack)
		tick_interval = world.time + initial(tick_interval)
	if(stacks > 0)
		if(stacks >= stack_threshold && !threshold_crossed) //threshold_crossed check prevents threshold effect from occuring if changing from above threshold to still above threshold
			threshold_crossed = TRUE
			on_threshold_cross()
			if(consumed_on_threshold)
				return
		else if(stacks < stack_threshold && threshold_crossed)
			threshold_crossed = FALSE //resets threshold effect if we fall below threshold so threshold effect can trigger again
			on_threshold_drop()
		if(stacks_added > 0)
			tick_interval += delay_before_decay //refreshes time until decay
		stacks = min(stacks, max_stacks)
	else
		fadeout_effect()
		qdel(src) //deletes status if stacks fall under one	return

/datum/status_effect/stacking/on_creation(mob/living/new_owner, stacks_to_apply)
	. = ..()
	if(.)
		add_stacks(stacks_to_apply)

/datum/status_effect/stacking/on_apply()
	if(!can_have_status())
		return FALSE
	return ..()

/// Status effect from multiple sources, when all sources are removed, so is the effect
/datum/status_effect/grouped
	id = "grouped"
	status_type = STATUS_EFFECT_MULTIPLE //! Adds itself to sources and destroys itself if one exists already, there are never multiple
	var/list/sources = list()

/datum/status_effect/grouped/on_creation(mob/living/new_owner, source)
	var/datum/status_effect/grouped/existing = new_owner.has_status_effect(type)
	if(existing)
		existing.sources |= source
		qdel(src)
		return FALSE
	else
		sources |= source
		return ..()

/datum/status_effect/grouped/before_remove(source)
	sources -= source
	return !length(sources)

/**
 * # Transient Status Effect (basetype)
 *
 * A status effect that works off a (possibly decimal) counter before expiring, rather than a specified world.time.
 * This allows for a more precise tweaking of status durations at runtime (e.g. paralysis).
 */
/datum/status_effect/transient
	id = "transient"
	tick_interval = 0.2 SECONDS // SSfastprocess interval
	alert_type = null
	/// How much strength left before expiring? time in deciseconds.
	var/strength = 0

/datum/status_effect/transient/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		strength = set_duration
	. = ..()

/datum/status_effect/transient/tick()
	if(QDELETED(src) || QDELETED(owner))
		return FALSE
	. = TRUE
	strength += calc_decay()
	if(strength <= 0)
		qdel(src)
		return FALSE

/**
 * Returns how much strength should be adjusted per tick.
 */
/datum/status_effect/transient/proc/calc_decay()
	return -0.2 SECONDS // 1 per second by default
