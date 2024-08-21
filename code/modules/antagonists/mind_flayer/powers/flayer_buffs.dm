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
	if(!..())
		return FALSE
	to_chat(user, "<span class='notice'>We begin to heal rapidly.</span>")
	user.apply_status_effect(STATUS_EFFECT_FLAYER_REJUV, extra_duration, extra_healing)

/datum/spell/flayer/self/rejuv/on_purchase_upgrade()
	if(!..())
		return FALSE
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
	/// Do we get bullet reflection
	var/should_get_reflection = FALSE
	/// Extra duration we gain from upgrading
	var/extra_duration = 0 // Base duration is 10 seconds

/datum/spell/flayer/self/quicksilver_form/cast(list/targets, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_QUICKSILVER_FORM, extra_duration, should_get_reflection)

/datum/spell/flayer/self/quicksilver_form/on_purchase_upgrade()
	if(!..())
		return FALSE
	switch(level)
		if(POWER_LEVEL_TWO)
			should_get_reflection = TRUE
		if(POWER_LEVEL_THREE)
			extra_duration += 10 SECONDS

/datum/spell/flayer/self/terminator_form
	name = "T.E.R.M.I.N.A.T.O.R. Form"
	desc = "For a short time, transcend your limits and pursue your target through hell."
	power_type = FLAYER_PURCHASABLE_POWER
	base_cooldown = 5 MINUTES // Base uptime is 20%
	category = CATEGORY_DESTROYER
	stage = 3 // TODO: figure out if this is the right stage
	base_cost = 250
	static_upgrade_increase = 50 // Total cost of 900 swarms
	max_level = 3
