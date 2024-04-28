
/datum/spell/paradox_spell
	school = "paradox"
	action_background_icon_state = "bg_paradox"
	human_req = TRUE
	clothes_req = FALSE
	var/base_range = 1
	var/base_max_charges = 1
	still_recharging_msg = "<span class='notice'>The connection is being restored...</span>"

/datum/spell/paradox_spell/self/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/paradox_spell/click_target/create_new_targeting()
	var/datum/spell_targeting/click/C = new
	C.allowed_type = /mob/living/carbon
	C.range = base_range
	return C

/datum/spell/paradox_spell/click_target/create_new_cooldown()
	var/datum/spell_cooldown/charges/C = new
	C.max_charges = base_max_charges
	C.recharge_duration = base_cooldown
	return C

/datum/spell/touch/paradox_spell
	name = "Basetype Paradox spell"
	desc = "You should not see this in game, if you do file a github report!"
	action_background_icon_state = "bg_paradox"
	clothes_req = FALSE
	human_req = TRUE
	action_icon_state = "gib"
	still_recharging_msg = "<span class='notice'>The connection is being restored...</span>"
