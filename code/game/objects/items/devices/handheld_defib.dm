/obj/item/handheld_defibrillator
	name = "handheld defibrillator"
	desc = "Used to restart stopped hearts."
	icon = 'icons/obj/medical.dmi'
	icon_state = "defib-on"
	inhand_icon_state = "defib"
	belt_icon = "defib"

	var/icon_base = "defib"
	///Can the defib shock yet?
	var/cooldown = FALSE
	///How long will it take to recharge after a shock?
	var/charge_time = 10 SECONDS
	///How long until we can attack the same person with any emagged handheld defib or baton again?
	var/attack_cooldown = 3.5 SECONDS
	///How long does this knock the target down for?
	var/knockdown_duration = 10 SECONDS

/obj/item/handheld_defibrillator/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		desc += " The screen only shows the word KILL flashing over and over."
		if(user)
			to_chat(user, "<span class='warning'>you short out the safeties on [src]</span>")
		return TRUE
	else
		emagged = FALSE
		desc = "Used to restart stopped hearts."
		if(user)
			to_chat(user, "<span class='warning'>You restore the safeties on [src]</span>")
		return TRUE

/obj/item/handheld_defibrillator/attack__legacy__attackchain(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	if(cooldown)
		to_chat(user, "<span class='warning'>[src] is still charging!</span>")
		return

	if(emagged)
		var/user_UID = user.UID()
		if(HAS_TRAIT_FROM(H, TRAIT_WAS_BATONNED, user_UID)) // no following up with baton or dual wielding defibs for stunlock cheese purposes
			return

		user.visible_message("<span class='danger'>[user] violently shocks [H] with [src]!</span>", "<span class='danger'>You violently shock [H] with [src]!</span>")
		add_attack_logs(user, H, "emag-defibbed with [src]")
		playsound(user.loc, "sound/weapons/egloves.ogg", 75, 1)
		H.KnockDown(knockdown_duration)
		H.apply_damage(60, STAMINA)
		SEND_SIGNAL(H, COMSIG_LIVING_MINOR_SHOCK, 100)
		ADD_TRAIT(H, TRAIT_WAS_BATONNED, user_UID)
		cooldown = TRUE
		icon_state = "[icon_base]-shock"
		addtimer(CALLBACK(src, PROC_REF(allowhit), H, user_UID), attack_cooldown)
		addtimer(CALLBACK(src, PROC_REF(short_charge)), 1 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time)
		return

	if((H.health <= HEALTH_THRESHOLD_CRIT) || (H.undergoing_cardiac_arrest()))
		user.visible_message("<span class='notice'>[user] shocks [H] with [src].</span>", "<span class='notice'>You shock [H] with [src].</span>")
		add_attack_logs(user, H, "defibrillated with [src]")
		playsound(user.loc, "sound/weapons/egloves.ogg", 75, 1)

		if(H.stat == DEAD)
			to_chat(user, "<span class='danger'>[H] doesn't respond at all!</span>")
		else
			H.set_heartattack(FALSE)
			var/total_damage = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss()
			if(H.health <= HEALTH_THRESHOLD_CRIT)
				if(total_damage >= 90)
					to_chat(user, "<span class='danger'>[H] looks horribly injured. Resuscitation alone may not help revive them.</span>")
				if(prob(66))
					to_chat(user, "<span class='notice'>[H] inhales deeply!</span>")
					H.adjustOxyLoss(-50)
				else
					to_chat(user, "<span class='danger'>[H] doesn't respond!</span>")

			H.AdjustParalysis(6 SECONDS)
			H.AdjustWeakened(10 SECONDS)
			H.AdjustStuttering(20 SECONDS)
			to_chat(H, "<span class='danger'>You feel a powerful jolt!</span>")
			SEND_SIGNAL(H, COMSIG_LIVING_MINOR_SHOCK, 100)

		cooldown = TRUE
		icon_state = "[icon_base]-shock"
		addtimer(CALLBACK(src, PROC_REF(short_charge)), 1 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time)

	else
		to_chat(user, "<span class='notice'>[src]'s on board medical scanner indicates that no shock is required.</span>")

/obj/item/handheld_defibrillator/proc/allowhit(mob/living/target, user_UID)
	REMOVE_TRAIT(target, TRAIT_WAS_BATONNED, user_UID)

/obj/item/handheld_defibrillator/proc/short_charge()
	icon_state = "[icon_base]-off"

/obj/item/handheld_defibrillator/proc/recharge()
	cooldown = FALSE
	icon_state = "[icon_base]-on"
	playsound(loc, "sound/weapons/flash.ogg", 75, 1)
