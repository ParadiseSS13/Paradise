//backpack item

/obj/item/defibrillator
	name = "defibrillator"
	desc = "A device that delivers powerful shocks to detachable paddles that resuscitate incapacitated patients."
	icon_state = "defibunit"
	item_state = "defibunit"
	slot_flags = SLOT_BACK
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "biotech=4"
	actions_types = list(/datum/action/item_action/toggle_paddles)
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/back.dmi'
		)

	var/on = FALSE //if the paddles are equipped (1) or on the defib (0)
	var/safety = TRUE //if you can zap people with the defibs on harm mode
	var/powered = FALSE //if there's a cell in the defib with enough power for a revive, blocks paddles from reviving otherwise
	var/obj/item/twohanded/shockpaddles/paddles = null
	var/obj/item/stock_parts/cell/high/bcell = null
	var/combat = FALSE //can we revive through space suits?

/obj/item/defibrillator/New() //starts without a cell for rnd
	..()
	paddles = make_paddles()
	update_icon()

/obj/item/defibrillator/loaded/New() //starts with hicap
	..()
	bcell = new(src)
	update_icon()

/obj/item/defibrillator/update_icon()
	update_power()
	update_overlays()
	update_charge()

/obj/item/defibrillator/proc/update_power()
	if(!QDELETED(bcell))
		if(QDELETED(paddles) || bcell.charge < paddles.revivecost)
			powered = FALSE
		else
			powered = TRUE
	else
		powered = FALSE

/obj/item/defibrillator/proc/update_overlays()
	overlays.Cut()
	if(!on)
		overlays += "[initial(icon_state)]-paddles"
	if(powered)
		overlays += "[initial(icon_state)]-powered"
	if(!bcell)
		overlays += "[initial(icon_state)]-nocell"
	if(!safety)
		overlays += "[initial(icon_state)]-emagged"

/obj/item/defibrillator/proc/update_charge()
	if(powered) //so it doesn't show charge if it's unpowered
		if(!QDELETED(bcell))
			var/ratio = bcell.charge / bcell.maxcharge
			ratio = CEILING(ratio * 4, 1) * 25
			overlays += "[initial(icon_state)]-charge[ratio]"

/obj/item/defibrillator/CheckParts(list/parts_list)
	..()
	bcell = locate(/obj/item/stock_parts/cell) in contents
	update_icon()

/obj/item/defibrillator/ui_action_click()
	toggle_paddles()

/obj/item/defibrillator/CtrlClick()
	if(ishuman(usr) && Adjacent(usr))
		toggle_paddles()

/obj/item/defibrillator/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(bcell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
		else
			if(C.maxcharge < paddles.revivecost)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			user.drop_item()
			W.loc = src
			bcell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")

	if(istype(W, /obj/item/screwdriver))
		if(bcell)
			bcell.update_icon()
			bcell.loc = get_turf(src.loc)
			bcell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")

	update_icon()
	return

/obj/item/defibrillator/emag_act(mob/user)
	if(safety)
		safety = FALSE
		to_chat(user, "<span class='warning'>You silently disable [src]'s safety protocols with the cryptographic sequencer.</span>")
	else
		safety = TRUE
		to_chat(user, "<span class='notice'>You silently enable [src]'s safety protocols with the cryptographic sequencer.</span>")
	update_icon()

/obj/item/defibrillator/emp_act(severity)
	if(bcell)
		deductcharge(1000 / severity)
	if(safety)
		safety = FALSE
		visible_message("<span class='notice'>[src] beeps: Safety protocols disabled!</span>")
		playsound(src, 'sound/machines/defib_saftyOff.ogg', 50, 0)
	else
		safety = TRUE
		visible_message("<span class='notice'>[src] beeps: Safety protocols enabled!</span>")
		playsound(src, 'sound/machines/defib_saftyOn.ogg', 50, 0)
	update_icon()

/obj/item/defibrillator/proc/toggle_paddles()
	set name = "Toggle Paddles"
	set category = "Object"
	on = !on

	var/mob/living/carbon/user = usr
	if(on)
		//Detach the paddles into the user's hands
		if(!usr.put_in_hands(paddles))
			on = FALSE
			to_chat(user, "<span class='warning'>You need a free hand to hold the paddles!</span>")
			update_icon()
			return
	else
		//Remove from their hands and back onto the defib unit
		paddles.unwield()
		remove_paddles(user)

	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/defibrillator/proc/make_paddles()
	return new /obj/item/twohanded/shockpaddles(src)

/obj/item/defibrillator/equipped(mob/user, slot)
	..()
	if((slot_flags == SLOT_BACK && slot != slot_back) || (slot_flags == SLOT_BELT && slot != slot_belt))
		remove_paddles(user)
		update_icon()

/obj/item/defibrillator/item_action_slot_check(slot, mob/user)
	if(slot == slot_back)
		return 1

/obj/item/defibrillator/proc/remove_paddles(mob/user) // from your hands
	var/mob/living/carbon/human/M = user
	if(paddles in get_both_hands(M))
		M.unEquip(paddles)

/obj/item/defibrillator/Destroy()
	if(on)
		var/M = get(paddles, /mob)
		remove_paddles(M)
	QDEL_NULL(paddles)
	QDEL_NULL(bcell)
	return ..()

/obj/item/defibrillator/proc/deductcharge(chrgdeductamt)
	if(bcell)
		if(bcell.charge < (paddles.revivecost+chrgdeductamt))
			powered = FALSE
			update_icon()
		if(bcell.use(chrgdeductamt))
			update_icon()
			return TRUE
		else
			update_icon()
			return FALSE

/obj/item/defibrillator/proc/cooldowncheck(mob/user)
	spawn(50)
		if(bcell)
			if(bcell.charge >= paddles.revivecost)
				user.visible_message("<span class='notice'>[src] beeps: Unit ready.</span>")
				playsound(src, 'sound/machines/defib_ready.ogg', 50, 0)
			else
				user.visible_message("<span class='notice'>[src] beeps: Charge depleted.</span>")
				playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		paddles.cooldown = FALSE
		paddles.update_icon()
		update_icon()

/obj/item/defibrillator/compact
	name = "compact defibrillator"
	desc = "A belt-equipped defibrillator that can be rapidly deployed."
	icon_state = "defibcompact"
	item_state = "defibcompact"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_BELT
	origin_tech = "biotech=5"

/obj/item/defibrillator/compact/item_action_slot_check(slot, mob/user)
	if(slot == slot_belt)
		return 1

/obj/item/defibrillator/compact/loaded/New()
	..()
	bcell = new(src)
	update_icon()

/obj/item/defibrillator/compact/combat
	name = "combat defibrillator"
	desc = "A belt-equipped blood-red defibrillator that can be rapidly deployed. Does not have the restrictions or safeties of conventional defibrillators and can revive through space suits."
	combat = 1
	safety = 0

/obj/item/defibrillator/compact/combat/loaded/New()
	..()
	bcell = new /obj/item/stock_parts/cell/infinite(src)
	update_icon()

/obj/item/defibrillator/compact/combat/attackby(obj/item/W, mob/user, params)
	if(W == paddles)
		paddles.unwield()
		toggle_paddles()
		update_icon()

//paddles

/obj/item/twohanded/shockpaddles
	name = "defibrillator paddles"
	desc = "A pair of plastic-gripped paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"
	force = 0
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY

	var/revivecost = 1000
	var/cooldown = FALSE
	var/busy = FALSE
	var/obj/item/defibrillator/defib
	var/req_defib = TRUE
	var/combat = FALSE //If it penetrates armor and gives additional functionality

/obj/item/twohanded/shockpaddles/on_mob_move(dir, mob/user)
	check_range()

/obj/item/twohanded/shockpaddles/proc/check_range()
	if(!req_defib)
		return
	if(!in_range(src, defib))
		var/mob/living/L = loc
		if(istype(L))
			to_chat(L, "<span class='warning'>[defib]'s paddles overextend and come out of your hands!</span>")
			L.unEquip(src, TRUE)
		else
			visible_message("<span class='notice'>[src] snap back into [defib].</span>")
			snap_back()

/obj/item/twohanded/shockpaddles/proc/recharge(time)
	if(req_defib || !time)
		return
	cooldown = TRUE
	update_icon()
	sleep(time)
	var/turf/T = get_turf(src)
	T.audible_message("<span class='notice'>[src] beeps: Unit is recharged.</span>")
	playsound(src, 'sound/machines/defib_ready.ogg', 50, 0)
	cooldown = FALSE
	update_icon()

/obj/item/twohanded/shockpaddles/New(mainunit)
	..()
	if(check_defib_exists(mainunit, src) && req_defib)
		defib = mainunit
		forceMove(defib)
		update_icon()

/obj/item/twohanded/shockpaddles/update_icon()
	icon_state = "defibpaddles[wielded]"
	item_state = "defibpaddles[wielded]"
	if(cooldown)
		icon_state = "defibpaddles[wielded]_cooldown"
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		C.update_inv_l_hand()
		C.update_inv_r_hand()

/obj/item/twohanded/shockpaddles/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is putting the live paddles on [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(req_defib)
		defib.deductcharge(revivecost)
	playsound(src, 'sound/machines/defib_zap.ogg', 50, 1, -1)
	return OXYLOSS

/obj/item/twohanded/shockpaddles/dropped(mob/user)
	if(!req_defib)
		return ..()
	if(user)
		var/obj/item/twohanded/offhand/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
		to_chat(user, "<span class='notice'>The paddles snap back into the main unit.</span>")
		snap_back()
	return unwield(user)

/obj/item/twohanded/shockpaddles/proc/snap_back()
	if(!defib)
		return
	defib.on = FALSE
	forceMove(defib)
	defib.update_icon()

/obj/item/twohanded/shockpaddles/proc/check_defib_exists(mainunit, mob/living/carbon/M, obj/O)
	if(!req_defib)
		return TRUE //If it doesn't need a defib, just say it exists
	if (!mainunit || !istype(mainunit, /obj/item/defibrillator))	//To avoid weird issues from admin spawns
		qdel(O)
		return FALSE
	else
		return TRUE

/obj/item/twohanded/shockpaddles/attack(mob/M, mob/user)
	if(req_defib && !defib.powered)
		user.visible_message("<span class='notice'>[defib] beeps: Unit is unpowered.</span>")
		playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		return
	if(!wielded)
		if(isrobot(user))
			to_chat(user, "<span class='warning'>You must activate the paddles in your active module before you can use them on someone!</span>")
		else
			to_chat(user, "<span class='warning'>You need to wield the paddles in both hands before you can use them on someone!</span>")
		return
	if(cooldown)
		if(req_defib)
			to_chat(user, "<span class='warning'>[defib] is recharging!</span>")
		else
			to_chat(user, "<span class='warning'>[src] are recharging!</span>")
		return

	if(user.a_intent == INTENT_DISARM)
		do_disarm(M, user)
		return
	if(!ishuman(M))
		if(req_defib)
			to_chat(user, "<span class='warning'>The instructions on [defib] don't mention how to defibrillate that...</span>")
		else
			to_chat(user, "<span class='warning'>You aren't sure how to defibrillate that...</span>")
		return
	if(!busy)
		busy = TRUE
		if(user.a_intent == INTENT_HARM)
			do_harm(M, user)
		else
			do_help(M, user)
		busy = FALSE


/obj/item/twohanded/shockpaddles/proc/do_disarm(mob/living/M, mob/living/user)
	if(req_defib && defib.safety)
		return
	if(!req_defib && !combat)
		return
	M.visible_message("<span class='danger'>[user] has touched [M] with [src]!</span>", "<span class='userdanger'>[user] has touched [M] with [src]!</span>")
	M.adjustStaminaLoss(50)
	M.Paralyse(10)
	M.updatehealth() //forces health update before next life tick
	playsound(src,  'sound/machines/defib_zap.ogg', 50, 1, -1)
	M.emote("gasp")
	add_attack_logs(user, M, "Stunned with [src]")
	if(req_defib)
		defib.deductcharge(revivecost)
		cooldown = TRUE
	update_icon()
	if(req_defib)
		defib.cooldowncheck(user)
	else
		recharge(100)

/obj/item/twohanded/shockpaddles/proc/do_harm(mob/living/carbon/human/H, mob/living/user)
	if(req_defib && defib.safety)
		return
	if(!req_defib && !combat)
		return
	user.visible_message("<span class='notice'>[user] begins to place [src] on [H]'s chest.</span>",
		"<span class='warning'>You overcharge the paddles and begin to place them onto [H]'s chest...</span>")
	
	if(do_after_once(user, 30 * toolspeed, target = H))
		user.visible_message("<span class='notice'>[user] places [src] on [H]'s chest.</span>",
			"<span class='warning'>You place [src] on [H]'s chest and begin to charge them.</span>")
		var/turf/T = get_turf(defib)
		playsound(src, 'sound/machines/defib_charge.ogg', 75, 0) // Bit louder
		if(req_defib)
			T.audible_message("<span class='warning'>\The [defib] lets out an urgent beep and lets out a steadily rising hum...</span>")
		else
			user.audible_message("<span class='warning'>[src] let out an urgent beep.</span>")
		if(do_after_once(user, 30 * toolspeed, target = H)) //Takes longer due to overcharging
			if(!H)
				return
			if(H.stat == DEAD)
				to_chat(user, "<span class='warning'>[H] is dead.</span>")
				playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
				return
			user.visible_message("<span class='warning'><i>[user] shocks [H] with \the [src]!</span>", "<span class='warning'>You shock [H] with \the [src]!</span>")
			playsound(src, 'sound/machines/defib_zap.ogg', 100, 1, -1)
			playsound(src, 'sound/weapons/egloves.ogg', 100, 1, -1)
			H.emote("scream")
			if(H.can_heartattack() && !H.undergoing_cardiac_arrest())
				if(!H.stat)
					H.visible_message("<span class='warning'>[H] thrashes wildly, clutching at [H.p_their()] chest!</span>",
						"<span class='userdanger'>You feel a horrible agony in your chest!</span>")
				H.set_heartattack(TRUE)
			H.apply_damage(50, BURN, "chest")
			log_attack(user, H, "overloaded the heart of using [src]")
			H.Paralyse(10)
			H.Jitter(10)
			if(req_defib)
				defib.deductcharge(revivecost)
				cooldown = TRUE
			update_icon()
			if(!req_defib)
				recharge(100)
			if(req_defib)
				defib.cooldowncheck(user)
				return

/obj/item/twohanded/shockpaddles/proc/do_help(mob/living/carbon/human/H, mob/living/user)
	
	user.visible_message("<span class='notice'>[user] places [src] on [H.name]'s chest.</span>", "<span class='warning'>You place [src] on [H.name]'s chest.</span>")
	if(do_after_once(user, 30 * toolspeed, target = H))
		user.visible_message("<span class='notice'>[user] places [src] on [H]'s chest.</span>", "<span class='warning'>You place [src] on [H]'s chest.</span>")
		playsound(src, 'sound/machines/defib_charge.ogg', 50, 0)
		if(do_after_once(user, 20 * toolspeed, target = H)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
			
			var/tplus = world.time - H.timeofdeath
			if((!combat && !req_defib) || (req_defib && !defib.combat))
				for(var/obj/item/carried_item in H.contents)
					if(istype(carried_item, /obj/item/clothing/suit/space))
						user.audible_message("<span class='warning'>[req_defib ? "[defib]" : "[src]"] buzzes: Patient's chest is obscured. Operation aborted.</span>")
						playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
						return
			
			if(H.stat == DEAD)
				var/mob/dead/observer/ghost = H.get_ghost()
				if(ghost && !ghost.client)
					// In case the ghost's not getting deleted for some reason
					H.key = ghost.key
					log_runtime(EXCEPTION("Ghost of name [ghost.name] is bound to [H.real_name], but lacks a client. Deleting ghost."), src)

					QDEL_NULL(ghost)
				
				H.visible_message("<span class='warning'>[H]'s body convulses a bit.")
				playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
				var/tlimit = DEFIB_TIME_LIMIT * 10 //past this much time the patient is unrecoverable (in deciseconds)
				var/tloss = DEFIB_TIME_LOSS * 10 //brain damage starts setting in on the patient after some time left rotting
				var/total_burn = 0
				var/total_brute = 0
				for(var/obj/item/organ/external/O in H.bodyparts)
					total_brute	+= O.brute_dam
					total_burn	+= O.burn_dam
				if(total_burn <= 180 && total_brute <= 180 && !H.suiciding && !ghost && tplus < tlimit && !(NOCLONE in H.mutations) && (H.mind && H.mind.is_revivable()) && (H.get_int_organ(/obj/item/organ/internal/heart) || H.get_int_organ(/obj/item/organ/internal/brain/slime)))
					var/tobehealed = min(H.health - HEALTH_THRESHOLD_DEAD, 0) // It's HILARIOUS without this min statement, let me tell you
					tobehealed -= 5 //They get 5 of each type of damage healed so excessive combined damage will not immediately kill them after they get revived
					H.adjustOxyLoss(tobehealed)
					H.adjustToxLoss(tobehealed)
					H.adjustFireLoss(tobehealed)
					H.adjustBruteLoss(tobehealed)
					user.visible_message("<span class='boldnotice'>[defib] pings: Resuscitation successful.</span>")
					playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
					H.update_revive(FALSE)
					H.KnockOut(FALSE)
					H.Paralyse(5)
					H.emote("gasp")
					if(tplus > tloss)
						H.setBrainLoss( max(0, min(99, ((tlimit - tplus) / tlimit * 100))))
					H.shock_internal_organs(100)
					H.med_hud_set_health()
					H.med_hud_set_status()
					add_attack_logs(user, H, "Revived with [src]")
				else
					if(tplus > tlimit|| !H.get_int_organ(/obj/item/organ/internal/heart))
						user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Heart tissue damage beyond point of no return for defibrillation.</span>")
					else if(total_burn >= 180 || total_brute >= 180)
						user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Severe tissue damage detected.</span>")
					else if(ghost)
						user.visible_message("<span class='notice'>[defib] buzzes: Resuscitation failed: Patient's brain is unresponsive. Further attempts may succeed.</span>")
						to_chat(ghost, "<span class='ghostalert'>Your heart is being defibrillated. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)")
						window_flash(ghost.client)
						ghost << sound('sound/effects/genetics.ogg')
					else
						user.visible_message("<span class='notice'>[defib] buzzes: Resuscitation failed.</span>")
				if(req_defib)
					defib.deductcharge(revivecost)
					cooldown = TRUE
				update_icon()
				if(req_defib)
					defib.cooldowncheck(user)
				else
					recharge(100)

			else if(H.health <= HEALTH_THRESHOLD_CRIT || H.undergoing_cardiac_arrest())
				if((!H.get_int_organ(/obj/item/organ/internal/heart))) //prevents defibing someone still alive suffering from a heart attack attack if they lack a heart
					user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Failed to pick up any heart electrical activity.</span>")
					playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
					return
				else
					H.set_heartattack(FALSE)
					if(prob(66) && H.health <= HEALTH_THRESHOLD_CRIT)
						H.adjustOxyLoss(-50)
						H.visible_message("<span class='warning'>[H] inhales deeply!</span>")
					H.Paralyse(3)
					H.Stun(5)
					H.Weaken(5)
					H.AdjustStuttering(10)
					user.visible_message("<span class='boldnotice'>[defib] pings: Cardiac arrhythmia corrected.</span>")
					H.visible_message("<span class='warning'>[H]'s body convulses a bit.")
					playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
					playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
					if(req_defib)
						defib.deductcharge(revivecost)
						cooldown = TRUE
					update_icon()
					if(req_defib)
						defib.cooldowncheck(user)
					else
						recharge(100)
			else
				user.visible_message("<span class='notice'>[defib] buzzes: Patient is not in a valid state. Operation aborted.</span>")
				playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)

/obj/item/twohanded/shockpaddles/cyborg
	name = "cyborg defibrillator paddles"
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"
	req_defib = FALSE

/obj/item/twohanded/shockpaddles/cyborg/attack(mob/M, mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.emagged)
			combat = TRUE
		else
			combat = FALSE
	else
		combat = FALSE

	. = ..()

/obj/item/twohanded/shockpaddles/syndicate
	name = "syndicate defibrillator paddles"
	desc = "A pair of paddles used to revive deceased operatives. It possesses both the ability to penetrate armor and to deliver powerful shocks offensively."
	combat = TRUE
	req_defib = FALSE