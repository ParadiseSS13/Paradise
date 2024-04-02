/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid
	name = "Corrosive acid"
	desc = "Spit acid on someone in range, this acid melts through nearly anything and heavily damages anyone lacking proper safety equipment."
	hand_path = "/obj/item/melee/touch_attack/alien/corrosive_acid"
	action_icon_state = "alien_acid"
	plasma_cost = 200
	base_cooldown = 15 SECONDS

/obj/item/melee/touch_attack/alien/corrosive_acid
	name = "Corrosive acid"
	desc = "A fistfull of death."
	icon_state = "alien_acid"

/obj/item/melee/touch_attack/alien/corrosive_acid/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(target == user)
		to_chat(user, "<span class='noticealien'>You withdraw your readied acid.</span>")
		..()
		return
	if(!proximity || isalien(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) // Don't want xenos ditching out of cuffs
		return
	if(!plasma_check(200, user))
		to_chat(user, "<span class='noticealien'>You don't have enough plasma to perform this action!</span>")
		return
	var/acid_damage_modifier = 100
	if(isliving(target))
		acid_damage_modifier = 50
	if(target.acid_act(2 * acid_damage_modifier, acid_damage_modifier))
		visible_message("<span class='alertalien'>[user] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
		add_attack_logs(user, target, "Applied corrosive acid") // Want this logged
		user.add_plasma(-200)
	else
		to_chat(user, "<span class='noticealien'>You cannot dissolve this object.</span>")
	..()

/obj/effect/proc_holder/spell/touch/alien_spell/burning_touch
	name = "Blazing touch"
	desc = "Boil acid within your hand to burn through anything you touch with it, deals a lot of damage to aliens and destroys resin structures instantly."
	hand_path = "/obj/item/melee/touch_attack/alien/burning_touch"
	action_icon_state = "alien_acid"
	plasma_cost = 100
	base_cooldown = 10 SECONDS

/obj/item/melee/touch_attack/alien/burning_touch
	name = "Blazing touch"
	desc = "The air warps around your hand, somehow the heat doesn't hurt."
	icon_state = "alien_acid"

/obj/item/melee/touch_attack/alien/burning_touch/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(target == user)
		to_chat(user, "<span class='noticealien'>You cool down your boiled aid.</span>")
		..()
		return
	if(!proximity || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!plasma_check(100, user))
		to_chat(user, "<span class='noticealien'>You don't have enough plasma to perform this action!</span>")
		return
	if(isliving(target))
		var/mob/living/guy_to_burn = target
		add_attack_logs(user, target, "Applied blazing touch") // Want this logged
		guy_to_burn.adjustFireLoss(60)
		guy_to_burn.adjust_fire_stacks(3)
		guy_to_burn.IgniteMob()
		user.visible_message("<span class='alertalien'>[user] touches [target] and a fireball erupts on contact!</span>")
		user.add_plasma(-100)
		..()
	else
		var/static/list/resin_objects = list(/obj/structure/alien/resin, /obj/structure/alien/egg, /obj/structure/bed/nest, /obj/structure/bed/revival_nest)
		for(var/resin_type in resin_objects)
			if(!istype(target, resin_type))
				continue
			user.visible_message("<span class='alertalien'>[user] touches [target] and burns right through it!</span>")
			user.add_plasma(-100)
			qdel(target)
			..()
