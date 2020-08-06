/// Delay in deci-seconds between two non-lethal attacks
#define BATON_STUN_COOLDOWN 4 SECONDS
/// Force of the telescopic baton when deployed
#define BATON_TELESCOPIC_FORCE_DEPLOYED 10

/**
  * # Police Baton
  *
  * Knocks down the hit mob when not on harm intent and when [/obj/item/melee/classic_baton/on] is TRUE
  *
  * A non-lethal attack has a cooldown to avoid spamming
  */
/obj/item/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL
	/// Whether the baton is on cooldown
	var/on_cooldown = FALSE
	/// Whether the baton is toggled on (to allow attacking)
	var/on = TRUE

/obj/item/melee/classic_baton/attack(mob/living/target, mob/living/user)
	if(!on)
		return ..()

	add_fingerprint(user)
	if((CLUMSY in user.mutations) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally clubs [user.p_them()]self with [src]!</span>", \
							 "<span class='userdanger'>You accidentally club yourself with [src]!</span>")
		user.Weaken(force * 3)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(force * 2, BRUTE, "head")
		else
			user.take_organ_damage(force * 2)
		return

	if(user.a_intent == INTENT_HARM || isrobot(target)) // Lethal attack or it's a borg (can't knock them down!)
		return ..()
	else if(!on_cooldown) // Non-lethal attack - knock them down
		// Check for shield/countering
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
				return
			if(check_martial_counter(H, user))
				return
		// Visuals and sound
		user.do_attack_animation(target)
		playsound(target, 'sound/effects/woodhit.ogg', 75, TRUE, -1)
		add_attack_logs(user, target, "Stunned with [src]")
		target.visible_message("<span class='danger'>[user] has knocked down [target] with \the [src]!</span>", \
							   "<span class='userdanger'>[user] has knocked down [target] with \the [src]!</span>")
		// Hit 'em
		target.LAssailant = iscarbon(user) ? user : null
		target.Weaken(3)
		on_cooldown = TRUE
		addtimer(CALLBACK(src, .proc/cooldown_finished), BATON_STUN_COOLDOWN)

/**
  * Called some time after a non-lethal attack
  */
/obj/item/melee/classic_baton/proc/cooldown_finished()
	on_cooldown = FALSE

/**
  * # Fancy Cane
  */
/obj/item/melee/classic_baton/ntcane
	name = "fancy cane"
	desc = "A cane with special engraving on it. It seems well suited for fending off assailants..."
	icon_state = "cane_nt"
	item_state = "cane_nt"
	needs_permit = FALSE

/obj/item/melee/classic_baton/ntcane/is_crutch()
	return TRUE

/**
  * # Telescopic Baton
  */
/obj/item/melee/classic_baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon_state = "telebaton_0"
	item_state = null
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	needs_permit = FALSE
	force = 0
	on = FALSE
	/// Attack verbs when concealed (created on Initialize)
	var/static/list/attack_verb_off
	/// Attack verbs when extended (created on Initialize)
	var/static/list/attack_verb_on

/obj/item/melee/classic_baton/telescopic/Initialize(mapload)
	. = ..()
	if(!attack_verb_off)
		attack_verb_off = list("hit", "poked")
		attack_verb_on = list("smacked", "struck", "cracked", "beaten")
	attack_verb = on ? attack_verb_on : attack_verb_off

/obj/item/melee/classic_baton/telescopic/attack_self(mob/user)
	on = !on
	icon_state = "telebaton_[on]"
	if(on)
		to_chat(user, "<span class='warning'>You extend the baton.</span>")
		item_state = "nullrod"
		w_class = WEIGHT_CLASS_BULKY //doesnt fit in backpack when its on for balance
		force = BATON_TELESCOPIC_FORCE_DEPLOYED //stunbaton damage
		attack_verb = attack_verb_on
	else
		to_chat(user, "<span class='notice'>You collapse the baton.</span>")
		item_state = null //no sprite for concealment even when in hand
		slot_flags = SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = 0 //not so robust now
		attack_verb = attack_verb_off
	// Update mob hand visuals
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	playsound(loc, 'sound/weapons/batonextend.ogg', 50, TRUE)
	add_fingerprint(user)

#undef BATON_STUN_COOLDOWN
#undef BATON_TELESCOPIC_FORCE_DEPLOYED
