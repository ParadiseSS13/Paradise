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
	base_cooldown = 3 MINUTES

/datum/spell/caretaker/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/caretaker/valid_target(target, user)
	if(!sentience_check(user))
		return FALSE
	return TRUE

/datum/spell/caretaker/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/carbon/carbon_user = user
	if(carbon_user.has_status_effect(/datum/status_effect/caretaker_refuge))
		carbon_user.remove_status_effect(/datum/status_effect/caretaker_refuge)
	else
		if(!do_after_once(user, 1.5 SECONDS, FALSE, user, TRUE, FALSE))
			cooldown_handler.revert_cast()
			return FALSE
		if(!sentience_check(user))
			cooldown_handler.revert_cast()
			return FALSE
		carbon_user.apply_status_effect(/datum/status_effect/caretaker_refuge)
		addtimer(CALLBACK(src, PROC_REF(early_warning), carbon_user), base_cooldown - (20 SECONDS))
		addtimer(CALLBACK(src, PROC_REF(remove_refuge), carbon_user), base_cooldown) // using base_cooldown makes it impossible to cast again bfore this effect is done
		cooldown_handler.start_recharge(cooldown_handler.recharge_duration * 0.1) //Cooldown activates primarly when you leave
	return TRUE

/datum/spell/caretaker/proc/sentience_check(mob/user)
	for(var/mob/living/alive in oview(7, user))
		if(alive.stat != DEAD && alive.client)
			to_chat(user, SPAN_WARNING("There are sentient beings blocking you from shifting!"))
			return FALSE
	return TRUE

/datum/spell/caretaker/proc/early_warning(mob/living/carbon/carbon_user)
	if(carbon_user.has_status_effect(/datum/status_effect/caretaker_refuge))
		to_chat(carbon_user, SPAN_DANGER("The caretaker will not allow us to remain in refuge for much longer!"))

/datum/spell/caretaker/proc/remove_refuge(mob/living/carbon/carbon_user)
	if(carbon_user.has_status_effect(/datum/status_effect/caretaker_refuge))
		carbon_user.remove_status_effect(/datum/status_effect/caretaker_refuge)
		cooldown_handler.start_recharge(cooldown_handler.recharge_duration)
