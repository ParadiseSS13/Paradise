/datum/spell/caretaker
	name = "Caretaker’s Last Refuge"
	desc = "Shifts you into the Caretaker's Refuge, rendering you translucent and intangible. \
		While in the Refuge your movement is unrestricted, but you cannot use your hands or cast any spells. \
		You cannot enter the Refuge while near other sentient beings, \
		and you can be removed from it upon contact with antimagical artifacts."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "caretaker"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/effects/curse/curse2.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 1 MINUTES

/datum/spell/caretaker/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/caretaker/valid_target(target, user)
	for(var/mob/living/alive in orange(5, user))
		if(alive.stat != DEAD && alive.client)
			to_chat(user, "<span class='warning'>There are sentient beings blocking you from shifting!</span>")
			return FALSE
	return TRUE

/datum/spell/caretaker/cast(list/targets, mob/user)
	. = ..()

	var/mob/living/carbon/carbon_user = user
	if(carbon_user.has_status_effect(/datum/status_effect/caretaker_refuge))
		carbon_user.remove_status_effect(/datum/status_effect/caretaker_refuge)
	else
		carbon_user.apply_status_effect(/datum/status_effect/caretaker_refuge)
		cooldown_handler.start_recharge(cooldown_handler.recharge_duration * 0.1) //Cooldown activates primarly when you leave
	return TRUE
