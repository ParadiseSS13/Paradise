/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid
	name = "Corrosive acid"
	desc = "Spit acid on someone in range, this acid melts through nearly anything and heavily damages anyone lacking proper safety equipment."
	hand_path = "/obj/item/melee/touch_attack/alien/corrosive_acid"
	action_icon_state = "alien_acid"
	on_gain_message = span_noticealien("You vomit acid in your hand and prepare to use it.")
	on_withdraw_message = span_noticealien("You decide not to use acid for now...")
	plasma_cost = 200


/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid/sentinel
	hand_path = "/obj/item/melee/touch_attack/alien/corrosive_acid/sentinel"
	plasma_cost = 150


/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid/praetorian
	hand_path = "/obj/item/melee/touch_attack/alien/corrosive_acid/praetorian"
	plasma_cost = 100


/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid/queen
	hand_path = "/obj/item/melee/touch_attack/alien/corrosive_acid/queen"
	plasma_cost = 50


/obj/item/melee/touch_attack/alien/corrosive_acid
	name = "Corrosive acid"
	desc = "A fistfull of death."
	icon_state = "alien_acid"
	var/plasma_cost = 200
	var/acid_power = 400


/obj/item/melee/touch_attack/alien/corrosive_acid/sentinel
	plasma_cost = 150


/obj/item/melee/touch_attack/alien/corrosive_acid/praetorian
	plasma_cost = 100


/obj/item/melee/touch_attack/alien/corrosive_acid/queen
	plasma_cost = 50
	acid_power = 1000


/obj/item/melee/touch_attack/alien/corrosive_acid/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(target == user)
		return ..()

	if(!proximity || isalien(target) || !iscarbon(user) || user.lying || user.handcuffed) // Don't want xenos ditching out of cuffs
		return

	if(!plasma_check(plasma_cost, user))
		to_chat(user, span_noticealien("You don't have enough plasma to perform this action!"))
		return

	if(target.acid_act(acid_power, 100))
		playsound(target, 'sound/items/welder.ogg', 150, TRUE)
		visible_message(span_alertalien("[user] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!"))
		add_attack_logs(user, target, "Applied corrosive acid") // Want this logged
		user.adjust_alien_plasma(-plasma_cost)
	else
		to_chat(user, span_noticealien("You cannot dissolve this object."))
	..()

