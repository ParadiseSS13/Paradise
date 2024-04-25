
/datum/spell/paradox
	school = "paradox"
	action_background_icon_state = "bg_paradox"
	human_req = TRUE
	clothes_req = FALSE
	var/base_range = 1
	var/base_max_charges = 1
	var/datum/antagonist/paradox_clone/pc
	still_recharging_msg = "<span class='paradox'>Wait...</span>"

/datum/spell/paradox/self/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/paradox/click_target/create_new_targeting()
	var/datum/spell_targeting/click/C = new
	C.allowed_type = /mob/living/carbon
	C.range = base_range
	return C

/datum/spell/paradox/click_target/create_new_cooldown()
	var/datum/spell_cooldown/charges/C = new
	C.max_charges = base_max_charges
	C.recharge_duration = base_cooldown
	return C
