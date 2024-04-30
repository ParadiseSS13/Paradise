
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

/obj/item/melee/touch_attack/paradox/afterattack(atom/A, mob/living/user, params)
	. = ..()
	if(get_dist(user, A) != 1)
		attached_spell.revert_cast()
		return

/obj/item/melee/touch_attack/paradox
	name = "Base Hand"
	desc = "You're not supposed to see this. Notice coders."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"
	invisibility = SEE_INVISIBLE_LIVING
	flags = ABSTRACT | DROPDEL
	catchphrase = null
	w_class = WEIGHT_CLASS_HUGE
