/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid
	name = "Corrosive acid"
	desc = "Spit acid on someone in range, this acid melts through nearly anything and heavily damages anyone lacking propery safety equipment."
	hand_path = "/obj/item/melee/touch_attack/alien/corrosive_acid"
	action_icon_state = "alien_acid"
	plasma_cost = 200

/obj/item/melee/touch_attack/alien/corrosive_acid
	name = "Corrosive acid"
	desc = "A fistfull of death."
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/touch_attack/alien/corrosive_acid/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(target == user)
		user.add_plasma(200, user)
		to_chat(user, "<span class='noticealien'>You withdraw your readied acid.</span>")
		..()
		return
	if(!proximity || isalien(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) // Don't want xenos ditching out of cuffs
		return

	if(target.acid_act(200, 100))
		visible_message("<span class='alertalien'>[user] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
	else
		to_chat(user, "<span class='noticealien'>You cannot dissolve this object.</span>")
		user.add_plasma(200, user)
	..()
