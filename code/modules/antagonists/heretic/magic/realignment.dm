// Realignment. It's like Fleshmend but solely for stamina damage and stuns. Sec meta
/datum/spell/realignment
	name = "Realignment"
	desc = "Realign yourself, rapidly regenerating stamina and reducing any stuns or knockdowns. \
		You cannot attack while realigning. Can be casted multiple times in short succession, but each cast lengthens the cooldown."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "adrenal"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 6 SECONDS
	var/cooldown_reduction_per_rank = -6 SECONDS // we're not a wizard spell but we use the levelling mechanic
	level_max = 10 // we can get up to / over a minute duration cd time

	invocation = "R'S'T."
	invocation_type = INVOCATION_SHOUT

/datum/spell/realignment/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/realignment/cast(list/targets, mob/user)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	living_user.apply_status_effect(/datum/status_effect/realignment)
	to_chat(user, SPAN_NOTICE("We begin to realign ourselves.</span>"))

/datum/spell/realignment/after_cast(atom/cast_on)
	. = ..()
	// With every cast, our spell level increases for a short time, which goes back down after a period
	// and with every spell level, the cooldown duration of the spell goes up
	if(level_spell())
		var/reduction_timer = max(base_cooldown * level_max * 0.5, 1.5 MINUTES)
		addtimer(CALLBACK(src, PROC_REF(delevel_spell)), reduction_timer)

/datum/spell/realignment/proc/level_spell(bypass_cap = FALSE)
	// Spell cannot be levelled
	if(level_max <= 1)
		return FALSE

	// Spell is at cap, and we will not bypass it
	if(spell_level >= level_max)
		return FALSE

	spell_level++
	cooldown_handler.recharge_duration = max(cooldown_handler.recharge_duration - cooldown_reduction_per_rank, 0.25 SECONDS) // 0 second CD starts to break things.
	name = "[get_spell_title()][initial(name)]"
	return TRUE

/datum/spell/realignment/proc/delevel_spell()
	// Spell cannot be levelled
	if(level_max <= 1)
		return FALSE

	if(spell_level <= 1)
		return FALSE

	spell_level--
	if(cooldown_reduction_per_rank > 0 SECONDS)
		cooldown_handler.recharge_duration = min(cooldown_handler.recharge_duration + cooldown_reduction_per_rank, initial(cooldown_handler.recharge_duration))
	else
		cooldown_handler.recharge_duration = max(cooldown_handler.recharge_duration + cooldown_reduction_per_rank, initial(cooldown_handler.recharge_duration))

	name = "[get_spell_title()][initial(name)]"
	return TRUE

/datum/spell/realignment/proc/get_spell_title()
	switch(spell_level)
		if(1, 2)
			return "Hasty " // Hasty Realignment
		if(3, 4)
			return "" // Realignment
		if(5, 6, 7)
			return "Slowed " // Slowed Realignment
		if(8, 9, 10)
			return "Laborious " // Laborious Realignment (don't reach here)

	return ""

/datum/status_effect/realignment
	id = "realigment"
	status_type = STATUS_EFFECT_REFRESH
	duration = 8 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/realignment
	tick_interval = 0.5 SECONDS
	show_duration = TRUE
	///Traits to add/remove
	var/list/realignment_traits = list(TRAIT_BATON_RESISTANCE, TRAIT_PACIFISM)

/datum/status_effect/realignment/on_apply()
	ADD_TRAIT(owner, TRAIT_BATON_RESISTANCE, "[id]")
	ADD_TRAIT(owner, TRAIT_PACIFISM, "[id]")
	owner.add_filter(id, 2, list("type" = "outline", "color" = "#d6e3e7", "size" = 2))
	var/filter = owner.get_filter(id)
	animate(filter, alpha = 127, time = 1 SECONDS, loop = -1)
	animate(alpha = 63, time = 2 SECONDS)
	SEND_SIGNAL(owner, COMSIG_LIVING_CLEAR_STUNS)
	return TRUE

/datum/status_effect/realignment/on_remove()
	REMOVE_TRAIT(owner, TRAIT_BATON_RESISTANCE, "[id]")
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "[id]")
	owner.remove_filter(id)

/datum/status_effect/realignment/tick(seconds_between_ticks)
	owner.adjustStaminaLoss(-10)
	owner.AdjustParalysis(-1 SECONDS)
	owner.AdjustStunned(-1 SECONDS)
	owner.AdjustWeakened(-1 SECONDS)
	owner.AdjustKnockDown(-1 SECONDS)

/atom/movable/screen/alert/status_effect/realignment
	name = "Realignment"
	desc = "You're realigning yourself. You cannot attack, but are rapidly regenerating stamina."
	icon_state = "realignment"
