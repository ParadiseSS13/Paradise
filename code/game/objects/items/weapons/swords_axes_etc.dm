/* Weapons
 * Contains:
 *		Banhammer
 *		Classic Baton
 */

/*
 * Banhammer
 */
/obj/item/banhammer/attack(mob/M, mob/user)
	to_chat(M, "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>")
	to_chat(user, "<font color='red'> You have <b>BANNED</b> [M]</font>")
	playsound(loc, 'sound/effects/adminhelp.ogg', 15) //keep it at 15% volume so people don't jump out of their skin too much

/*
 * Classic Baton
 */

/obj/item/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL
	var/cooldown = 0
	var/on = 1

/obj/item/melee/classic_baton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		add_fingerprint(user)
		if((CLUMSY in user.mutations) && prob(50))
			to_chat(user, "<span class ='danger'>You club yourself over the head.</span>")
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, "head")
			else
				user.take_organ_damage(2*force)
			return
		if(isrobot(target))
			..()
			return
		if(!isliving(target))
			return
		if(user.a_intent == INTENT_HARM)
			if(!..()) return
			if(!isrobot(target)) return
		else
			if(cooldown <= 0)
				if(ishuman(target))
					var/mob/living/carbon/human/H = target
					if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
						return
					if(check_martial_counter(H, user))
						return
				playsound(get_turf(src), 'sound/effects/woodhit.ogg', 75, 1, -1)
				target.Weaken(3)
				add_attack_logs(user, target, "Stunned with [src]")
				add_fingerprint(user)
				target.visible_message("<span class ='danger'>[user] has knocked down [target] with \the [src]!</span>", \
					"<span class ='userdanger'>[user] has knocked down [target] with \the [src]!</span>")
				if(!iscarbon(user))
					target.LAssailant = null
				else
					target.LAssailant = user
				cooldown = 1
				spawn(40)
					cooldown = 0
		return
	else
		return ..()

/obj/item/melee/classic_baton/ntcane
	name = "fancy cane"
	desc = "A cane with special engraving on it. It seems well suited for fending off assailants..."
	icon_state = "cane_nt"
	item_state = "cane_nt"
	needs_permit = 0

/obj/item/melee/classic_baton/ntcane/is_crutch()
	return 1

//Telescopic baton
/obj/item/melee/classic_baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon_state = "telebaton_0"
	item_state = null
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	needs_permit = 0
	force = 0
	on = 0

/obj/item/melee/classic_baton/telescopic/attack_self(mob/user as mob)
	on = !on
	if(on)
		to_chat(user, "<span class ='warning'>You extend the baton.</span>")
		icon_state = "telebaton_1"
		item_state = "nullrod"
		w_class = WEIGHT_CLASS_BULKY //doesnt fit in backpack when its on for balance
		force = 10 //stunbaton damage
		attack_verb = list("smacked", "struck", "cracked", "beaten")
	else
		to_chat(user, "<span class ='notice'>You collapse the baton.</span>")
		icon_state = "telebaton_0"
		item_state = null //no sprite for concealment even when in hand
		slot_flags = SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = 0 //not so robust now
		attack_verb = list("hit", "poked")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	add_fingerprint(user)
