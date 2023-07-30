/obj/effect/proc_holder/spell/touch/alien_spell
	name = "Basetype Alien spell"
	desc = "You should not see this in game, if you do file a github report!"
	hand_path = "/obj/item/melee/touch_attack/alien"
	action_icon_state = "gib"
	action_background_icon_state = "bg_alien"
	/// Extremely fast cooldown, only present so the cooldown system doesn't explode
	base_cooldown = 1
	/// Every alien spell creates only logs, no attack messages on someone placing weeds, but you DO get attack messages on neurotoxin and corrosive acid
	create_custom_logs = TRUE
	create_attack_logs = FALSE
	clothes_req = FALSE
	human_req = FALSE
	on_gain_message = ""
	on_withdraw_message = ""
	/// How much plasma it costs to use this
	var/plasma_cost = 0


/obj/effect/proc_holder/spell/touch/alien_spell/after_spell_init()
	update_alien_spell_name()


/obj/effect/proc_holder/spell/touch/alien_spell/write_custom_logs(list/targets, mob/user)
	user.create_log(ATTACK_LOG, "Cast the spell [name]")


/obj/effect/proc_holder/spell/touch/alien_spell/create_new_handler()
	var/datum/spell_handler/alien/H = new
	H.plasma_cost = plasma_cost
	return H


/obj/item/melee/touch_attack/alien
	name = "Basetype Alien touch_attack"
	desc = "You should not see this in game, if you do file a github report!"
	/// Alien spells don't have catchphrases
	catchphrase = null
	/// Beepsky shouldn't be arresting you over this
	needs_permit = FALSE


/obj/item/melee/touch_attack/alien/allowed_for_alien()
	return TRUE


/obj/item/melee/touch_attack/alien/proc/plasma_check(plasma, mob/living/carbon/user)
	var/plasma_current = user.get_plasma()
	if(plasma_current < plasma)
		qdel(src)
		return FALSE
	return TRUE

