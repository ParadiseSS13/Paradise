/datum/spell/touch/alien_spell/corrosive_acid
	name = "Corrosive acid"
	desc = "Spit acid on someone in range, this acid melts through nearly anything and heavily damages anyone lacking proper safety equipment."
	hand_path = "/obj/item/melee/touch_attack/alien/corrosive_acid"
	action_icon_state = "alien_acid"
	plasma_cost = 200
	base_cooldown = 15 SECONDS

/obj/item/melee/touch_attack/alien/corrosive_acid
	name = "Corrosive acid"
	desc = "A fistful of death."
	icon_state = "alien_acid"

/obj/item/melee/touch_attack/alien/corrosive_acid/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(target == user)
		to_chat(user, "<span class='noticealien'>You withdraw your readied acid.</span>")
		return
	if(!proximity_flag || isalien(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) // Don't want xenos ditching out of cuffs
		return
	var/mob/living/carbon/C = user
	if(!plasma_check(200, C))
		to_chat(C, "<span class='noticealien'>You don't have enough plasma to perform this action!</span>")
		return
	var/acid_damage_modifier = 100
	if(isliving(target))
		acid_damage_modifier = 50
	if(target.acid_act(2 * acid_damage_modifier, acid_damage_modifier))
		visible_message("<span class='alertalien'>[C] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
		add_attack_logs(C, target, "Applied corrosive acid") // Want this logged
		C.add_plasma(-200)
	else
		to_chat(C, "<span class='noticealien'>You cannot dissolve this object.</span>")
	handle_delete(user)

/obj/item/melee/touch_attack/alien/corrosive_acid/customised_abstract_text(mob/living/carbon/owner)
	return "<span class='warning'>[owner.p_their(TRUE)] [owner.l_hand == src ? "left hand" : "right hand"] is dripping with vile corrosive goo!</span>"

/datum/spell/touch/alien_spell/burning_touch
	name = "Blazing touch"
	desc = "Boil acid within your hand to burn through anything you touch with it, dealing a lot of damage to aliens and destroying resin structures instantly."
	hand_path = "/obj/item/melee/touch_attack/alien/burning_touch"
	action_icon_state = "alien_acid"
	plasma_cost = 100
	base_cooldown = 10 SECONDS

/obj/item/melee/touch_attack/alien/burning_touch
	name = "Blazing touch"
	desc = "The air warps around your hand, somehow the heat doesn't hurt."
	icon_state = "alien_acid"

/obj/item/melee/touch_attack/alien/burning_touch/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(target == user)
		to_chat(user, "<span class='noticealien'>You cool down your boiled aid.</span>")
		return
	if(!proximity_flag || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	var/mob/living/carbon/C = user
	if(!plasma_check(100, C))
		to_chat(C, "<span class='noticealien'>You don't have enough plasma to perform this action!</span>")
		return
	if(isliving(target))
		var/mob/living/guy_to_burn = target
		add_attack_logs(C, target, "Applied blazing touch") // Want this logged
		guy_to_burn.adjustFireLoss(60)
		guy_to_burn.adjust_fire_stacks(3)
		guy_to_burn.IgniteMob()
		C.visible_message("<span class='alertalien'>[C] touches [target] and a fireball erupts on contact!</span>")
		C.add_plasma(-100)
	else
		var/static/list/resin_objects = list(/obj/structure/alien/resin, /obj/structure/alien/egg, /obj/structure/bed/nest)
		for(var/resin_type in resin_objects)
			if(!istype(target, resin_type))
				continue
			C.visible_message("<span class='alertalien'>[C] touches [target] and burns right through it!</span>")
			C.add_plasma(-100)
			qdel(target)
	handle_delete(user)

/obj/item/melee/touch_attack/alien/burning_touch/customised_abstract_text(mob/living/carbon/owner)
	return "<span class='warning'>[owner.p_their(TRUE)] [owner.l_hand == src ? "left hand" : "right hand"] has a shimmering mirage around it!</span>"

