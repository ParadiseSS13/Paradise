/**
  * # Police Baton
  *
  * Knocks down the hit mob when not on harm intent and when [/obj/item/melee/classic_baton/var/on] is `TRUE`.
  *
  * A non-lethal attack has a cooldown to avoid spamming
  */
/obj/item/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "baton"
	worn_icon_state = "classic_baton"
	inhand_icon_state = "classic_baton"
	slot_flags = ITEM_SLOT_BELT
	force = 12 //9 hit crit
	// Settings
	/// Whether the baton can stun silicon mobs
	var/affect_silicon = FALSE
	/// The amount of stamina damage the baton does per swing
	var/stamina_damage = 30
	/// How much melee armour is ignored by the stamina damage
	var/stamina_armor_pen = 0
	/// The stun time (in seconds) for non-silicons
	var/knockdown_duration = 6 SECONDS
	/// The stun time (in seconds) for silicons
	var/stun_time_silicon = 10 SECONDS
	/// Cooldown in seconds between two knockdowns
	var/cooldown = 4 SECONDS
	/// Sound to play when knocking someone down
	var/stun_sound = 'sound/effects/woodhit.ogg'
	// Variables
	/// Whether the baton is on cooldown
	var/on_cooldown = FALSE
	/// Whether the baton is toggled on (to allow attacking)
	var/on = TRUE

/obj/item/melee/classic_baton/attack__legacy__attackchain(mob/living/target, mob/living/user)
	if(!on)
		return ..()

	add_fingerprint(user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally clubs [user.p_themselves()] with [src]!</span>", \
							"<span class='userdanger'>You accidentally club yourself with [src]!</span>")
		user.KnockDown(knockdown_duration)
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
	if((issilicon(target) || isbot(target)) && !affect_silicon)
		return ..()
	baton_knockdown(target, user)

/**
  * Called when a target is about to be hit non-lethally.
  *
  * Arguments:
  * * target - The mob about to be hit
  * * user - The attacking user
  */
/obj/item/melee/classic_baton/proc/baton_knockdown(mob/living/target, mob/living/user)
	if(user.mind?.martial_art?.no_baton && user.mind?.martial_art?.can_use(user))
		to_chat(user, user.mind.martial_art.no_baton_reason)
		return
	var/user_UID = user.UID()
	if(HAS_TRAIT_FROM(target, TRAIT_WAS_BATONNED, user_UID)) // prevents double baton cheese.
		return FALSE
	if(issilicon(target))
		user.visible_message("<span class='danger'>[user] pulses [target]'s sensors with [src]!</span>",\
							"<span class='danger'>You pulse [target]'s sensors with [src]!</span>")
		on_silicon_stun(target, user)

	// Check for shield/countering
	else if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
			return FALSE
		user.visible_message("<span class='danger'>[user] knocks down [target] with [src]!</span>",\
							"<span class='danger'>You knock down [target] with [src]!</span>")
		on_non_silicon_stun(target, user)

	else if(isbot(target))
		user.visible_message("<span class='danger'>[user] pulses [target]'s sensors with [src]!</span>",\
							"<span class='danger'>You pulse [target]'s sensors with [src]!</span>")
		var/mob/living/simple_animal/bot/H = target
		H.disable(stun_time_silicon)
	// Visuals and sound
	user.do_attack_animation(target)
	playsound(target, stun_sound, 75, TRUE, -1)
	add_attack_logs(user, target, "Knocked down with [src]")
	// Hit 'em
	target.KnockDown(knockdown_duration)
	on_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, on_cooldown, FALSE), cooldown)
	ADD_TRAIT(target, TRAIT_WAS_BATONNED, user_UID) // so one person cannot hit the same person with two separate batons
	addtimer(CALLBACK(src, PROC_REF(baton_delay), target, user_UID), 2 SECONDS)
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
	var/armour = target.run_armor_check(BODY_ZONE_CHEST, armor_penetration_percentage = stamina_armor_pen) // returns their chest melee armour
	var/percentage_reduction = 0
	if(ishuman(target))
		percentage_reduction = (100 - ARMOUR_VALUE_TO_PERCENTAGE(armour)) / 100
	else
		percentage_reduction = (100 - armour) / 100 // converts the % into a decimal
	target.apply_damage(stamina_damage * percentage_reduction, STAMINA)

/obj/item/melee/classic_baton/proc/baton_delay(mob/living/target, user_UID)
	REMOVE_TRAIT(target, TRAIT_WAS_BATONNED, user_UID)

/**
  * # Fancy Cane
  */
/obj/item/melee/classic_baton/ntcane
	name = "fancy cane"
	desc = "A cane with special engraving on it. It seems well suited for fending off assailants..."
	icon_state = "cane_nt"
	worn_icon_state = null
	inhand_icon_state = null

/obj/item/melee/classic_baton/ntcane/get_crutch_efficiency()
	return 2

/**
  * # Telescopic Baton
  */
/obj/item/melee/classic_baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon_state = "telebaton_0" // For telling what it is when mapping
	worn_icon_state = null
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	on = FALSE
	/// Force when concealed
	var/force_off = 0
	/// Force when extended
	var/force_on = 10
	/// Worn icon state when extended
	var/worn_icon_state_on = "tele_baton"
	/// Inhand icon state when extended
	var/inhand_icon_state_on = "tele_baton"
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

/obj/item/melee/classic_baton/telescopic/attack_self__legacy__attackchain(mob/user)
	on = !on
	icon_state = on ? icon_state_on : icon_state_off
	if(on)
		to_chat(user, "<span class='warning'>You extend [src].</span>")
		worn_icon_state = worn_icon_state_on
		inhand_icon_state = inhand_icon_state_on
		w_class = WEIGHT_CLASS_BULKY //doesnt fit in backpack when its on for balance
		force = force_on //stunbaton damage
		attack_verb = attack_verb_on
	else
		to_chat(user, "<span class='notice'>You collapse [src].</span>")
		worn_icon_state = null
		inhand_icon_state = null //no sprite for concealment even when in hand
		w_class = WEIGHT_CLASS_SMALL
		force = force_off //not so robust now
		attack_verb = attack_verb_off
	// Update mob hand visuals
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	playsound(loc, extend_sound, 50, TRUE)
	add_fingerprint(user)
