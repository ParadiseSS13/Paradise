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
	// Settings
	/// Whether the baton can stun silicon mobs
	var/affect_silicon = FALSE
	/// The stun time (in life cycles) for non-silicons
	var/stun_time = 2 SECONDS_TO_LIFE_CYCLES
	/// The stun time (in life cycles) for silicons
	var/stun_time_silicon = 10 SECONDS_TO_LIFE_CYCLES
	/// Cooldown in deciseconds between two knockdowns
	var/cooldown = 2 SECONDS
	/// Sound to play when knocking someone down
	var/stun_sound = 'sound/effects/woodhit.ogg'
	// Variables
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

	if(user.a_intent == INTENT_HARM)
		return ..()
	if(on_cooldown)
		return
	if(issilicon(target) && !affect_silicon)
		return ..()
	else
		stun(target, user)

/**
  * Called when a target is about to be hit non-lethally.
  *
  * Arguments:
  * * target - The mob about to be hit
  * * user - The attacking user
  */
/obj/item/melee/classic_baton/proc/stun(mob/living/target, mob/living/user)
	if(issilicon(target))
		user.visible_message("<span class='danger'>[user] pulses [target]'s sensors with [src]!</span>",\
							 "<span class='danger'>You pulse [target]'s sensors with [src]!</span>")
		on_silicon_stun(target, user)
	else
		// Check for shield/countering
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
				return FALSE
			if(check_martial_counter(H, user))
				return FALSE
		user.visible_message("<span class='danger'>[user] knocks down [target] with [src]!</span>",\
							 "<span class='danger'>You knock down [target] with [src]!</span>")
		on_non_silicon_stun(target, user)
	// Visuals and sound
	user.do_attack_animation(target)
	playsound(target, stun_sound, 75, TRUE, -1)
	add_attack_logs(user, target, "Stunned with [src]")
	// Hit 'em
	target.LAssailant = iscarbon(user) ? user : null
	if(prob(75))
		target.Weaken(stun_time)
	else
		target.Weaken(stun_time + 1)
	on_cooldown = TRUE
	addtimer(CALLBACK(src, .proc/cooldown_finished), cooldown)
	return TRUE

/**
  * Called when a silicon has been stunned.
  *
  * Arguments:
  * * target - The hit mob
  * * user - The attacking user
  */
/obj/item/melee/classic_baton/proc/on_silicon_stun(mob/living/silicon/target, mob/living/user)
	target.flash_eyes(affect_silicon = TRUE)
	target.Weaken(stun_time_silicon)

/**
  * Called when a non-silicon has been stunned.
  *
  * Arguments:
  * * target - The hit mob
  * * user - The attacking user
  */
/obj/item/melee/classic_baton/proc/on_non_silicon_stun(mob/living/target, mob/living/user)
	return

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
	item_state = null
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	needs_permit = FALSE
	on = FALSE
	/// Force when concealed
	var/force_off = 0
	/// Force when extended
	var/force_on = 10
	/// Item state when extended
	var/item_state_on = "nullrod"
	/// Icon state when concealed
	var/icon_state_off = "telebaton_0"
	/// Icon state when extended
	var/icon_state_on = "telebaton_1"
	/// Sound to play when concealing or extending
	var/extend_sound = 'sound/weapons/batonextend.ogg'
	/// Attack verbs when concealed (created on Initialize)
	var/static/list/attack_verb_off
	/// Attack verbs when extended (created on Initialize)
	var/static/list/attack_verb_on

/obj/item/melee/classic_baton/telescopic/Initialize(mapload)
	. = ..()
	if(!attack_verb_off)
		attack_verb_off = list("hit", "poked")
		attack_verb_on = list("smacked", "struck", "cracked", "beaten")
	icon_state = icon_state_off
	force = force_off
	attack_verb = on ? attack_verb_on : attack_verb_off

/obj/item/melee/classic_baton/telescopic/attack_self(mob/user)
	on = !on
	icon_state = on ? icon_state_on : icon_state_off
	if(on)
		to_chat(user, "<span class='warning'>You extend [src].</span>")
		item_state = item_state_on
		w_class = WEIGHT_CLASS_BULKY //doesnt fit in backpack when its on for balance
		force = force_on //stunbaton damage
		attack_verb = attack_verb_on
	else
		to_chat(user, "<span class='notice'>You collapse [src].</span>")
		item_state = null //no sprite for concealment even when in hand
		slot_flags = SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = force_off //not so robust now
		attack_verb = attack_verb_off
	// Update mob hand visuals
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	// Update blood splatter
	if(blood_overlay)
		cut_overlay(blood_overlay)
		qdel(blood_overlay)
		add_blood_overlay(blood_overlay_color)
	playsound(loc, extend_sound, 50, TRUE)
	add_fingerprint(user)

/obj/item/melee/classic_baton/telescopic/blood_splatter_index()
	return "\ref[icon]-[icon_state]"

/obj/item/melee/classic_baton/telescopic/add_blood_overlay(color)
	var/index = blood_splatter_index()
	var/icon/blood_splatter_icon = GLOB.blood_splatter_icons[index]
	if(!blood_splatter_icon)
		blood_splatter_icon = icon(icon, icon_state)
		blood_splatter_icon.Blend("#ffffff", ICON_ADD)
		blood_splatter_icon.Blend(icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY)
		blood_splatter_icon = fcopy_rsc(blood_splatter_icon)
		GLOB.blood_splatter_icons[index] = blood_splatter_icon

	blood_overlay = image(blood_splatter_icon)
	blood_overlay.color = color
	blood_overlay_color = color
	add_overlay(blood_overlay)
