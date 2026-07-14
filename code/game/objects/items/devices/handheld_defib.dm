/obj/item/handheld_defibrillator
	name = "handheld defibrillator"
	desc = "Used to restart stopped hearts."
	icon = 'icons/obj/medical.dmi'
	icon_state = "defib-on"
	inhand_icon_state = "defib"
	belt_icon = "defib"
	materials = list(MAT_METAL = 200, MAT_GLASS = 200)

	var/icon_base = "defib"
	/// Can the defib shock yet?
	var/cooldown = FALSE
	/// How long will it take to recharge after a shock?
	var/charge_time = 10 SECONDS
	/// How long until we can attack the same person with any emagged handheld defib or baton again?
	var/attack_cooldown = 3.5 SECONDS
	/// How long does this knock the target down for?
	var/knockdown_duration = 10 SECONDS
	new_attack_chain = TRUE

/obj/item/handheld_defibrillator/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		desc += " The screen only shows the word KILL flashing over and over."
		if(user)
			to_chat(user, SPAN_WARNING("You short out the safeties on [src]."))
			add_fingerprint(user)
		return TRUE

	emagged = FALSE
	desc = "Used to restart stopped hearts."
	if(user)
		to_chat(user, SPAN_WARNING("You restore the safeties on [src]."))
		add_fingerprint(user)
	return TRUE

/obj/item/handheld_defibrillator/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!ishuman(target))
		return ITEM_INTERACT_COMPLETE

	if(cooldown)
		to_chat(user, SPAN_WARNING("[src] is still charging!"))
		return ITEM_INTERACT_COMPLETE

	if(emagged)
		return

	var/mob/living/carbon/human/human_target = target
	if(human_target.health > HEALTH_THRESHOLD_CRIT && !human_target.undergoing_cardiac_arrest())
		to_chat(user, SPAN_NOTICE("[src]'s on board medical scanner indicates that no shock is required."))
		return ITEM_INTERACT_COMPLETE

	user.visible_message(
		SPAN_NOTICE("[user] shocks [human_target] with [src]."),
		SPAN_NOTICE("You shock [human_target] with [src]."),
		SPAN_HEAR("You hear a brief electric jolt!")
	)
	add_attack_logs(user, human_target, "defibrillated with [src]")
	playsound(user.loc, "sound/weapons/egloves.ogg", 75, 1)
	add_fingerprint(user)

	if(human_target.stat == DEAD)
		to_chat(user, SPAN_DANGER("[human_target] doesn't respond at all!"))
		cooldown = TRUE
		icon_state = "[icon_base]-shock"
		addtimer(CALLBACK(src, PROC_REF(short_charge)), 1 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time)
		return ITEM_INTERACT_COMPLETE

	human_target.set_heartattack(FALSE)
	var/total_damage = human_target.getBruteLoss() + human_target.getFireLoss() + human_target.getToxLoss()
	if(human_target.health <= HEALTH_THRESHOLD_CRIT)
		if(total_damage >= 90)
			to_chat(user, SPAN_DANGER("[human_target] looks horribly injured. Resuscitation alone may not help revive them!"))
		if(prob(66))
			to_chat(user, SPAN_NOTICE("[human_target] inhales deeply!"))
			human_target.adjustOxyLoss(-50)
		else
			to_chat(user, SPAN_DANGER("[human_target] doesn't respond!"))

	human_target.AdjustParalysis(6 SECONDS)
	human_target.AdjustWeakened(10 SECONDS)
	human_target.AdjustStuttering(20 SECONDS)
	to_chat(human_target, SPAN_DANGER("You feel a powerful jolt!"))
	SEND_SIGNAL(human_target, COMSIG_LIVING_MINOR_SHOCK, 100)

	cooldown = TRUE
	icon_state = "[icon_base]-shock"
	addtimer(CALLBACK(src, PROC_REF(short_charge)), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time)
	return ITEM_INTERACT_COMPLETE

/obj/item/handheld_defibrillator/attack(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(!ishuman(target))
		return ..()

	if(cooldown)
		to_chat(user, SPAN_WARNING("[src] is still charging!"))
		return

	if(!emagged)
		return

	var/user_UID = user.UID()
	if(HAS_TRAIT_FROM(target, TRAIT_WAS_BATONNED, user_UID)) // No following up with baton or dual wielding defibs for stunlock cheese purposes.
		return

	user.visible_message(
		SPAN_DANGER("[user] violently shocks [target] with [src]!"),
		SPAN_DANGER("You violently shock [target] with [src]!"),
		SPAN_HEAR("You hear a violent electric jolt!")
	)
	add_attack_logs(user, target, "emag-defibbed with [src]")
	playsound(user.loc, "sound/weapons/egloves.ogg", 75, 1)
	target.KnockDown(knockdown_duration)
	target.apply_damage(60, STAMINA)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
	ADD_TRAIT(target, TRAIT_WAS_BATONNED, user_UID)
	cooldown = TRUE
	icon_state = "[icon_base]-shock"
	addtimer(CALLBACK(src, PROC_REF(allowhit), target, user_UID), attack_cooldown)
	addtimer(CALLBACK(src, PROC_REF(short_charge)), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time)
	add_fingerprint(user)

/obj/item/handheld_defibrillator/proc/allowhit(mob/living/target, user_UID)
	REMOVE_TRAIT(target, TRAIT_WAS_BATONNED, user_UID)

/obj/item/handheld_defibrillator/proc/short_charge()
	icon_state = "[icon_base]-off"

/obj/item/handheld_defibrillator/proc/recharge()
	cooldown = FALSE
	icon_state = "[icon_base]-on"
	playsound(loc, "sound/weapons/flash.ogg", 75, 1)
