// This is a file with all the powers that buff or heal a mindflayer in some way

/datum/spell/flayer/self/rejuv
	name = "Quick Reboot"
	desc = "Heal and remove any incapacitating effects from yourself."
	power_type = FLAYER_INNATE_POWER
	checks_nullification = FALSE
	action_icon = 'icons/mob/actions/flayer_actions.dmi'
	action_icon_state = "quick_reboot"
	upgrade_info = "Increase the amount you heal, decrease time between uses, and increase how long you heal for."
	max_level = 4
	base_cooldown = 30 SECONDS
	stat_allowed = UNCONSCIOUS
	base_cost = 50
	current_cost = 50 // Innate abilities HAVE to set `current_cost`
	static_upgrade_increase = 25
	/// Any extra duration we get from upgrading the spell.
	var/extra_duration = 0 // The base spell is 5 brute/burn healing a second for 5 seconds
	/// Any extra healing we get per second from upgrading the spell
	var/extra_healing = 0

/datum/spell/flayer/self/rejuv/cast(list/targets, mob/living/user)
	to_chat(user, "<span class='notice'>We begin to heal rapidly.</span>")
	user.apply_status_effect(STATUS_EFFECT_FLAYER_REJUV, extra_duration, extra_healing)

/datum/spell/flayer/self/rejuv/on_apply()
	..()
	cooldown_handler.recharge_duration -= 5 SECONDS
	extra_duration += 2 SECONDS
	extra_healing += 2

/datum/spell/flayer/self/quicksilver_form
	name = "Quicksilver Form"
	desc = "Allows us to transmute our physical form, letting us phase through glass and non-solid objects."
	action_icon_state = "blink"
	power_type = FLAYER_PURCHASABLE_POWER
	base_cooldown = 40 SECONDS //25% uptime at base
	category = FLAYER_CATEGORY_DESTROYER
	stage = 2
	base_cost = 100
	max_level = 3
	upgrade_info = "After upgrading once, we also deflect projectiles shot at us. After upgrading a second time, the duration of the effect is doubled."
	/// Do we get bullet reflection
	var/should_get_reflection = FALSE
	/// Extra duration we gain from upgrading
	var/extra_duration = 0 // Base duration is 10 seconds

/datum/spell/flayer/self/quicksilver_form/cast(list/targets, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_QUICKSILVER_FORM, extra_duration, should_get_reflection)

/datum/spell/flayer/self/quicksilver_form/on_apply()
	..()
	switch(level)
		if(FLAYER_POWER_LEVEL_TWO)
			should_get_reflection = TRUE
		if(FLAYER_POWER_LEVEL_THREE)
			extra_duration += 10 SECONDS

/// A toggle ability that makes you speedy and attack faster while heating up, level one cast is guaranteed to hurt a bit.
/datum/spell/flayer/self/overclock
	name = "Overclock"
	desc = "Allows us to move and attack faster, at the cost of putting extra strain on our motors and heating us up a dangerous amount."
	power_type = FLAYER_PURCHASABLE_POWER
	base_cooldown = 15 SECONDS
	category = FLAYER_CATEGORY_DESTROYER
	action_icon_state = "strained_muscles"
	stage = 3
	max_level = 3
	base_cost = 125
	upgrade_info = "Upgrading this improves our heat sinks, making us heat up slower."
	var/heat_per_tick = 22

/datum/spell/flayer/self/overclock/cast(list/targets, mob/living/user)
	if(user.has_status_effect(STATUS_EFFECT_OVERCLOCK))
		user.remove_status_effect(STATUS_EFFECT_OVERCLOCK)
		return
	user.apply_status_effect(STATUS_EFFECT_OVERCLOCK, heat_per_tick)

/datum/spell/flayer/self/overclock/on_apply()
	..()
	heat_per_tick -= 5

/datum/spell/flayer/self/terminator_form
	name = "T.E.R.M.I.N.A.T.O.R. Form"
	desc = "For a short time, you become unable to die and are not slowed down by pain. This will not heal you however, \
			and you will still die when the duration ends if you are damaged enough. \
			Using quick reboot in this form will heal massive amounts of stamina damage."
	power_type = FLAYER_PURCHASABLE_POWER
	base_cooldown = 5 MINUTES // Base uptime is 20%
	category = FLAYER_CATEGORY_DESTROYER
	stage = FLAYER_CAPSTONE_STAGE
	action_icon = "mutate"
	base_cost = 200
	static_upgrade_increase = 50 // Total cost of 750 swarms
	max_level = 3

/datum/spell/flayer/self/terminator_form/cast(list/targets, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_TERMINATOR_FORM)

/datum/spell/flayer/self/terminator_form/on_apply()
	..()
	cooldown_handler.recharge_duration -= 1 MINUTES
