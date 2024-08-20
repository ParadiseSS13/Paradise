// This is a file with all the powers that buff or heal a mindflayer in some way

/datum/spell/flayer/self/rejuv
	name = "Rejuvenate"
	desc = "Heal and remove any incapacitating effects from yourself."
	power_type = FLAYER_INNATE_POWER
	checks_nullification = FALSE

/datum/spell/flayer/self/rejuv/cast(list/targets, mob/living/user)
	to_chat(user, "<span class='notice'>We begin to heal rapidly.</span>")
	user.apply_status_effect(STATUS_EFFECT_FLAYER_REJUV)

/datum/spell/flayer/self/quicksilver_form
	name = "Quicksilver Form"
	desc = "WIP something about becoming liquid mercury."
	power_type = FLAYER_PURCHASABLE_POWER
	base_cooldown = 40 SECONDS //25% uptime
	category = CATEGORY_DESTROYER
	stage = 2

/datum/spell/flayer/self/quicksilver_form/cast(list/targets, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_QUICKSILVER_FORM)
