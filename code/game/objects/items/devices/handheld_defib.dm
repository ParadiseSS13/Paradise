/obj/item/handheld_defibrillator
	name = "handheld defibrillator"
	desc = "Used to restart stopped hearts."
	icon = 'icons/goonstation/objects/objects.dmi'
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'
	icon_state = "defib-on"
	item_state = "defib"

	var/icon_base = "defib"
	var/cooldown = FALSE
	var/charge_time = 100
	var/emagged = FALSE

/obj/item/handheld_defibrillator/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		desc += " The screen only shows the word KILL flashing over and over."
		if(user)
			to_chat(user, "<span class='warning'>you short out the safeties on [src]</span>")
	else
		emagged = FALSE
		desc = "Used to restart stopped hearts."
		if(user)
			to_chat(user, "<span class='warning'>You restore the safeties on [src]</span>")

/obj/item/handheld_defibrillator/emp_act(severity)
	if(emagged)
		emagged = FALSE
		desc = "Used to restart stopped hearts."
		visible_message("<span class='notice'>[src] beeps: Safety protocols enabled!</span>")
		playsound(get_turf(src), 'sound/machines/defib_saftyon.ogg', 50, 0)
	else
		emagged = TRUE
		desc += " The screen only shows the word KILL flashing over and over."
		visible_message("<span class='notice'>[src] beeps: Safety protocols disabled!</span>")
		playsound(get_turf(src), 'sound/machines/defib_saftyoff.ogg', 50, 0)

/obj/item/handheld_defibrillator/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	if(cooldown)
		to_chat(user, "<span class='warning'>[src] is still charging!</span>")
		return

	if(emagged || (H.health <= HEALTH_THRESHOLD_CRIT) || (H.undergoing_cardiac_arrest()))
		user.visible_message("<span class='notice'>[user] shocks [H] with [src].</span>", "<span class='notice'>You shock [H] with [src].</span>")
		add_attack_logs(user, H, "defibrillated with [src]")
		playsound(user.loc, "sound/weapons/Egloves.ogg", 75, 1)

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

			H.AdjustParalysis(3)
			H.AdjustStunned(5)
			H.AdjustWeakened(5)
			H.AdjustStuttering(10)
			to_chat(H, "<span class='danger'>You feel a powerful jolt!</span>")
			H.shock_internal_organs(100)

			if(emagged && prob(10))
				to_chat(user, "<span class='danger'>[src]'s on board scanner indicates that the target is undergoing a cardiac arrest!</span>")
				H.set_heartattack(TRUE)

		cooldown = TRUE
		icon_state = "[icon_base]-shock"
		addtimer(CALLBACK(src, .proc/short_charge), 10)
		addtimer(CALLBACK(src, .proc/recharge), charge_time)

	else
		to_chat(user, "<span class='notice'>[src]'s on board medical scanner indicates that no shock is required.</span>")

/obj/item/handheld_defibrillator/proc/short_charge()
	icon_state = "[icon_base]-off"

/obj/item/handheld_defibrillator/proc/recharge()
	cooldown = FALSE
	icon_state = "[icon_base]-on"
	playsound(loc, "sound/weapons/flash.ogg", 75, 1)