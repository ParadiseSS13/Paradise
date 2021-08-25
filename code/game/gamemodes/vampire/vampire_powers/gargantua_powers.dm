/obj/effect/proc_holder/spell/self/blood_swell
	name = "Blood Swell (30)"
	desc = "You infuse your body with blood, making us highly resistant to stuns and physical damage."
	gain_desc = "You have gained the ability to temporarly resist large amounts of stuns and physical damage."
	charge_max = 40 SECONDS
	required_blood = 30
	vampire_ability = TRUE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/obj/effect/proc_holder/spell/self/blood_swell/cast(list/targets, mob/user)
	for(var/target in targets)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)

/datum/vampire_passive/blood_swell_upgrade
	gain_desc = "While blood swell is active your unarmed and armed melee attacks deal increased damage."

/obj/effect/proc_holder/spell/self/overwhelming_force
	name = "Overwhelming Force"
	desc = "When toggled you will automatically pry open doors that you bump into and don't have access to."
	gain_desc = "You have gained the ability to force open doors at a small blood cost."
	charge_max = 2 SECONDS
	vampire_ability = TRUE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/obj/effect/proc_holder/spell/self/overwhelming_force/cast(list/targets, mob/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		to_chat(user,"<span class='warning'>You feel MIGHTY!</span>")
		ADD_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
	else
		REMOVE_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)

/obj/effect/proc_holder/spell/self/blood_rush
	name = "Blood Rush (30)"
	desc = "Infuse yourself with blood magic to boost your movement speed."
	gain_desc = "You have gained the ability to temporarily move at high speeds."
	vampire_ability = TRUE
	charge_max = 30 SECONDS
	required_blood = 30
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/obj/effect/proc_holder/spell/self/blood_rush/cast(list/targets, mob/user)
	ADD_TRAIT(user, TRAIT_GOTTAGOFAST, VAMPIRE_TRAIT)
	to_chat(user, "<span class='notice'>You feel a rush of energy!</span>")
	addtimer(CALLBACK(user, /mob/living/carbon/human/.proc/remove_speed, VAMPIRE_TRAIT), 10 SECONDS )

/mob/living/carbon/human/proc/remove_speed(source)
	REMOVE_TRAIT(src, TRAIT_GOTTAGOFAST, source)

/obj/effect/proc_holder/spell/targeted/click/charge
	name = "Charge(30)"
	desc = "You charge at the selected position, dealing large amounts of damage and destroying walls."
	gain_desc = "You can now charge at a target on screen, dealing massive damage and destroying structures."
	required_blood = 30
	charge_max = 30 SECONDS
	vampire_ability = TRUE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"
	allowed_type = /atom
	range = 7
	auto_target_single = FALSE
	click_radius = -1


/obj/effect/proc_holder/spell/targeted/click/charge/cast(list/targets, mob/user)
	var/target = targets[1]
	if(isliving(user))
		var/mob/living/L = user
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(target, range, 1, L, FALSE, callback = CALLBACK(L, /mob/living/.proc/remove_status_effect, STATUS_EFFECT_CHARGING))
