/obj/effect/proc_holder/spell/touch/alien_spell
	name = "Basetype Alien spell"
	desc = "You should not see this in game, if you do file a github report!"
	hand_path = "/obj/item/melee/touch_attack/alien"
	base_cooldown = 1
	action_background_icon_state = "bg_alien"
	clothes_req = FALSE
	/// How much plasma it costs to use this
	var/plasma_cost = 0
	action_icon_state = "gib"

/obj/effect/proc_holder/spell/touch/alien_spell/Initialize(mapload)
	. = ..()
	if(plasma_cost)
		name = "[name] ([plasma_cost])"


/obj/effect/proc_holder/spell/touch/alien_spell/create_new_handler()
	var/datum/spell_handler/alien/H = new
	H.plasma_cost = plasma_cost
	return H

/obj/item/melee/touch_attack/alien
	name = "Basetype Alien touch_attack"
	desc = "You should not see this in game, if you do file a github report!"
	has_catchphrase = FALSE // SHUT
	needs_permit = FALSE // No, beepsky WILL NOT arrest you for this

/obj/item/melee/touch_attack/alien/attack_alien(mob/user) // Can be picked up by aliens
	return attack_hand(user)
