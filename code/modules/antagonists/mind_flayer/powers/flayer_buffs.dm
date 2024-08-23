// This is a file with all the powers that buff or heal a mindflayer in some way

/datum/spell/flayer/self/rejuv
	name = "Rejuvenate"
	desc = "Heal and remove any incapacitating effects from yourself."
	power_type = FLAYER_INNATE_POWER
	checks_nullification = FALSE
	max_level = 4
	base_cooldown = 30 SECONDS
	base_cost = 75 // Upgrading this past the base form costs a ton but is very rewarding
	var/extra_duration = 0 // The base spell is 5 brute/burn healing a second for 5 seconds
	var/extra_healing = 0

/datum/spell/flayer/self/rejuv/cast(list/targets, mob/living/user)
	to_chat(user, "<span class='notice'>We begin to heal rapidly.</span>")
	user.apply_status_effect(STATUS_EFFECT_FLAYER_REJUV, extra_duration, extra_healing)

/datum/spell/flayer/self/rejuv/on_purchase_upgrade()
	cooldown_handler.recharge_duration -= 5 SECONDS
	extra_duration += 2 SECONDS
	extra_healing += 2

/datum/spell/flayer/self/quicksilver_form
	name = "Quicksilver Form"
	desc = "WIP something about becoming liquid mercury."
	power_type = FLAYER_PURCHASABLE_POWER
	base_cooldown = 40 SECONDS //25% uptime at base
	category = CATEGORY_DESTROYER
	stage = 2
	base_cost = 100
	max_level = 3
	upgrade_info = "At level 2, you also deflect projectiles shot at you. Level 3 doubles the duration of the effect."
	/// Do we get bullet reflection
	var/should_get_reflection = FALSE
	/// Extra duration we gain from upgrading
	var/extra_duration = 0 // Base duration is 10 seconds

/datum/spell/flayer/self/quicksilver_form/cast(list/targets, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_QUICKSILVER_FORM, extra_duration, should_get_reflection)

/datum/spell/flayer/self/quicksilver_form/on_purchase_upgrade()
	switch(level)
		if(POWER_LEVEL_TWO)
			should_get_reflection = TRUE
		if(POWER_LEVEL_THREE)
			extra_duration += 10 SECONDS

/// A toggle ability, high risk/high reward by making you move and attack faster, but you heat up over time and ignite if you get too hot.
/datum/spell/flayer/self/overclock
	name = "Overclock"
	desc = "WIP"
	power_type = FLAYER_PURCHASABLE_POWER
	base_cooldown = 15 SECONDS
	category = CATEGORY_DESTROYER
	stage = 3
	max_level = 3
	base_cost = 150
	static_upgrade_increase = 50
	upgrade_info = "Improve your heat sinks, making you heat up slower."
	var/heat_per_tick = 20

/datum/spell/flayer/self/overclock/cast(list/targets, mob/living/user)
	if(user.has_status_effect(STATUS_EFFECT_OVERCLOCK))
		user.remove_status_effect(STATUS_EFFECT_OVERCLOCK)
		return
	user.apply_status_effect(STATUS_EFFECT_OVERCLOCK, heat_per_tick)

/datum/spell/flayer/self/overclock/on_purchase_upgrade()
	heat_per_tick -= 5

/datum/spell/flayer/self/terminator_form
	name = "T.E.R.M.I.N.A.T.O.R. Form"
	desc = "For a short time, transcend your limits and pursue your target through hell."
	power_type = FLAYER_PURCHASABLE_POWER
	base_cooldown = 5 MINUTES // Base uptime is 20%
	category = CATEGORY_DESTROYER
	stage = CAPSTONE_STAGE
	base_cost = 250
	static_upgrade_increase = 50 // Total cost of 900 swarms
	max_level = 3

/datum/spell/flayer/self/terminator_form/cast(list/targets, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_TERMINATOR_FORM)
