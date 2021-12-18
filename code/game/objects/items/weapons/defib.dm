//backpack item

/obj/item/defibrillator
	name = "defibrillator"
	desc = "A device that delivers powerful shocks to detachable paddles that resuscitate incapacitated patients."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibunit"
	item_state = "defibunit"
	slot_flags = SLOT_BACK
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "biotech=4"
	actions_types = list(/datum/action/item_action/toggle_paddles)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/back.dmi'
		)

	var/paddles_on_defib = TRUE //if the paddles are on the defib (TRUE)
	var/powered = FALSE //if there's a cell in the defib with enough power for a revive, blocks paddles from reviving otherwise
	var/obj/item/twohanded/shockpaddles/paddles
	var/obj/item/stock_parts/cell/high/cell = null
	var/safety = TRUE //if you can zap people with the defibs on harm mode
	var/combat = FALSE //can we revive through space suits?
	var/heart_attack = FALSE //can it give instant heart attacks when zapped on harm intent with combat?
	base_icon_state = "defibpaddles"
	var/obj/item/twohanded/shockpaddles/paddle_type = /obj/item/twohanded/shockpaddles

/obj/item/defibrillator/get_cell()
	return cell

/obj/item/defibrillator/Initialize(mapload) //starts without a cell for rnd
	. = ..()
	paddles = new paddle_type(src)
	update_icon()

/obj/item/defibrillator/loaded/Initialize(mapload) //starts with hicap
	. = ..()
	cell = new(src)
	update_icon()

/obj/item/defibrillator/update_icon()
	update_power()
	update_overlays()
	update_charge()

/obj/item/defibrillator/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ctrl-click to remove the paddles from the defibrillator.</span>"

/obj/item/defibrillator/proc/update_power()
	if(cell)
		if(cell.charge < paddles.revivecost)
			powered = FALSE
		else
			powered = TRUE
	else
		powered = FALSE

/obj/item/defibrillator/proc/update_overlays()
	overlays.Cut()
	if(paddles_on_defib)
		overlays += "[icon_state]-paddles"
	if(powered)
		overlays += "[icon_state]-powered"
	if(!cell)
		overlays += "[icon_state]-nocell"
	if(!safety)
		overlays += "[icon_state]-emagged"

/obj/item/defibrillator/proc/update_charge()
	if(powered) //so it doesn't show charge if it's unpowered
		if(cell)
			var/ratio = cell.charge / cell.maxcharge
			ratio = CEILING(ratio*4, 1) * 25
			overlays += "[icon_state]-charge[ratio]"

/obj/item/defibrillator/CheckParts(list/parts_list)
	..()
	cell = locate(/obj/item/stock_parts/cell) in contents
	update_icon()

/obj/item/defibrillator/ui_action_click()
	toggle_paddles()

/obj/item/defibrillator/CtrlClick()
	if(ishuman(usr) && Adjacent(usr))
		toggle_paddles()

/obj/item/defibrillator/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
		else
			if(C.maxcharge < paddles.revivecost)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			user.drop_item()
			W.loc = src
			cell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")

	if(istype(W, /obj/item/screwdriver))
		if(cell)
			cell.update_icon()
			cell.loc = get_turf(loc)
			cell = null
			to_chat(user, "<span class='notice'>You remove the cell from [src].</span>")

	update_icon()
	return

/obj/item/defibrillator/emag_act(user as mob)
	if(safety)
		safety = FALSE
		to_chat(user, "<span class='warning'>You silently disable [src]'s safety protocols with the card.")
	else
		safety = TRUE
		to_chat(user, "<span class='notice'>You silently enable [src]'s safety protocols with the card.")

/obj/item/defibrillator/emp_act(severity)
	if(cell)
		deductcharge(1000 / severity)
	if(safety)
		safety = FALSE
		visible_message("<span class='notice'>[src] beeps: Safety protocols disabled!</span>")
		playsound(get_turf(src), 'sound/machines/defib_saftyoff.ogg', 50, 0)
	else
		safety = TRUE
		visible_message("<span class='notice'>[src] beeps: Safety protocols enabled!</span>")
		playsound(get_turf(src), 'sound/machines/defib_saftyon.ogg', 50, 0)
	update_icon()
	..()

/obj/item/defibrillator/verb/toggle_paddles()
	set name = "Toggle Paddles"
	set category = "Object"

	var/mob/living/carbon/human/user = usr

	if(paddles_on_defib)
		//Detach the paddles into the user's hands
		if(usr.incapacitated()) return

		if(!usr.put_in_hands(paddles))
			to_chat(user, "<span class='warning'>You need a free hand to hold the paddles!</span>")
			update_icon()
			return
		paddles.loc = user
		paddles_on_defib = FALSE
	else if(user.is_in_active_hand(paddles))
		//Remove from their hands and back onto the defib unit
		remove_paddles(user)

	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/defibrillator/equipped(mob/user, slot)
	..()
	if(slot != slot_back)
		remove_paddles(user)
		update_icon()

/obj/item/defibrillator/item_action_slot_check(slot, mob/user)
	if(slot == slot_back)
		return TRUE

/obj/item/defibrillator/proc/remove_paddles(mob/user) // from your hands
	var/mob/living/carbon/human/M = user
	if(paddles in get_both_hands(M))
		M.unEquip(paddles)
		paddles_on_defib = TRUE
	update_icon()
	return

/obj/item/defibrillator/Destroy()
	if(!paddles_on_defib)
		var/M = get(paddles, /mob)
		remove_paddles(M)
	QDEL_NULL(paddles)
	QDEL_NULL(cell)
	return ..()

/obj/item/defibrillator/proc/deductcharge(chrgdeductamt)
	if(cell)
		if(cell.charge < (paddles.revivecost+chrgdeductamt))
			powered = FALSE
			update_icon()
		if(cell.use(chrgdeductamt))
			update_icon()
			return TRUE
		else
			update_icon()
			return FALSE

/obj/item/defibrillator/proc/cooldowncheck(mob/user)
	spawn(50)
		if(cell)
			if(cell.charge >= paddles.revivecost)
				user.visible_message("<span class='notice'>[src] beeps: Unit ready.</span>")
				playsound(get_turf(src), 'sound/machines/defib_ready.ogg', 50, 0)
			else
				user.visible_message("<span class='notice'>[src] beeps: Charge depleted.</span>")
				playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
		paddles.cooldown = FALSE
		paddles.update_icon()
		update_icon()

/obj/item/defibrillator/compact
	name = "compact defibrillator"
	desc = "A belt-mounted defibrillator that can be rapidly deployed."
	icon_state = "defibcompact"
	item_state = "defibcompact"
	sprite_sheets = null //Because Vox had the belt defibrillator sprites in back.dm
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_BELT
	origin_tech = "biotech=5"

/obj/item/defibrillator/compact/loaded/Initialize(mapload)
	. = ..()
	cell = new(src)
	update_icon()

/obj/item/defibrillator/compact/item_action_slot_check(slot, mob/user)
	if(slot == slot_belt)
		return TRUE

/obj/item/defibrillator/compact/combat
	name = "combat defibrillator"
	desc = "A belt-mounted blood-red defibrillator that can be rapidly deployed. Does not have the restrictions or safeties of conventional defibrillators and can revive through space suits."
	icon_state = "defibcombat"
	item_state = "defibcombat"
	paddle_type = /obj/item/twohanded/shockpaddles/syndicate
	combat = TRUE
	safety = FALSE

/obj/item/defibrillator/compact/combat/loaded/Initialize(mapload)
	. = ..()
	cell = new(src)
	update_icon()

/obj/item/defibrillator/compact/advanced
	name = "advanced compact defibrillator"
	desc = "A belt-mounted state-of-the-art defibrillator that can be rapidly deployed in all environments. Uses an experimental self-charging cell, meaning that it will (probably) never stop working. Can be used to defibrillate through space suits. It is impossible to damage."
	icon_state = "defibnt"
	item_state = "defibnt"
	paddle_type = /obj/item/twohanded/shockpaddles/advanced
	combat = TRUE
	safety = TRUE
	heart_attack = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //Objective item, better not have it destroyed.

	var/next_emp_message //to prevent spam from the emagging message on the advanced defibrillator

/obj/item/defibrillator/compact/advanced/attackby(obj/item/W, mob/user, params)
	if(W == paddles)
		paddles.unwield()
		toggle_paddles()
		update_icon()

/obj/item/defibrillator/compact/advanced/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/bluespace/charging(src)
	update_icon()

/obj/item/defibrillator/compact/advanced/emp_act(severity)
	if(world.time > next_emp_message)
		atom_say("Warning: Electromagnetic pulse detected. Integrated shielding prevented all potential hardware damage.")
		playsound(src, 'sound/machines/defib_saftyon.ogg', 50)
		next_emp_message = world.time + 5 SECONDS

/obj/item/defibrillator/compact/advanced/attackby(obj/item/W, mob/user, params)
	if(W == paddles)
		paddles.unwield()
		toggle_paddles()
		update_icon()
		return

//paddles

/obj/item/twohanded/shockpaddles
	name = "defibrillator paddles"
	desc = "A pair of plastic-gripped paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibpaddles"
	item_state = "defibpaddles"
	force = 0
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = INDESTRUCTIBLE
	toolspeed = 1

	var/revivecost = 1000
	var/cooldown = FALSE
	var/busy = FALSE
	base_icon_state = "defibpaddles"
	var/obj/item/defibrillator/defib

/obj/item/twohanded/shockpaddles/New(mainunit)
	..()
	if(check_defib_exists(mainunit, src))
		defib = mainunit
		loc = defib
		busy = FALSE
		update_icon()
	return

/obj/item/twohanded/shockpaddles/update_icon()
	icon_state = "[base_icon_state][wielded]"
	item_state = "[base_icon_state][wielded]"
	if(cooldown)
		icon_state = "[base_icon_state][wielded]_cooldown"

/obj/item/twohanded/shockpaddles/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is putting the live paddles on [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	defib.deductcharge(revivecost)
	playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
	return OXYLOSS

/obj/item/twohanded/shockpaddles/dropped(mob/user)
	..()
	if(user)
		var/obj/item/twohanded/offhand/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
		to_chat(user, "<span class='notice'>The paddles snap back into the main unit.</span>")
		defib.paddles_on_defib = TRUE
		loc = defib
		defib.update_icon()
		update_icon()
	unwield(user)

/obj/item/twohanded/shockpaddles/on_mob_move(dir, mob/user)
	if(defib)
		var/turf/t = get_turf(defib)
		if(!t.Adjacent(user))
			defib.remove_paddles(user)

/obj/item/twohanded/shockpaddles/proc/check_defib_exists(mainunit, mob/living/carbon/human/M, obj/O)
	if(!mainunit || !istype(mainunit, /obj/item/defibrillator))	//To avoid weird issues from admin spawns
		M.unEquip(O)
		qdel(O)
		return FALSE
	else
		return TRUE

/obj/item/twohanded/shockpaddles/attack(mob/M, mob/user)
	var/tobehealed
	var/threshold = -HEALTH_THRESHOLD_DEAD
	var/mob/living/carbon/human/H = M

	if(busy)
		return
	if(!defib.powered)
		user.visible_message("<span class='notice'>[defib] beeps: Unit is unpowered.</span>")
		playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
		return
	if(!wielded)
		to_chat(user, "<span class='boldnotice'>You need to wield the paddles in both hands before you can use them on someone!</span>")
		return
	if(cooldown)
		to_chat(user, "<span class='notice'>[defib] is recharging.</span>")
		return
	if(!ishuman(M))
		to_chat(user, "<span class='notice'>The instructions on [defib] don't mention how to defibrillate that...</span>")
		return
	else
		if(user.a_intent == INTENT_HARM && !defib.safety)
			busy = TRUE
			H.visible_message("<span class='danger'>[user] has touched [H.name] with [src]!</span>", \
					"<span class='userdanger'>[user] has touched [H.name] with [src]!</span>")
			H.adjustStaminaLoss(50)
			H.Weaken(5)
			playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
			H.emote("gasp")
			if(!H.undergoing_cardiac_arrest() && (prob(10) || (defib.combat && !defib.heart_attack) || prob(10) && (defib.combat && defib.heart_attack))) // Your heart explodes.
				H.set_heartattack(TRUE)
			SEND_SIGNAL(H, COMSIG_LIVING_MINOR_SHOCK, 100)
			add_attack_logs(user, M, "Stunned with [src]")
			defib.deductcharge(revivecost)
			cooldown = TRUE
			busy = FALSE
			update_icon()
			defib.cooldowncheck(user)
			return
		user.visible_message("<span class='warning'>[user] begins to place [src] on [M.name]'s chest.</span>", "<span class='warning'>You begin to place [src] on [M.name]'s chest.</span>")
		busy = TRUE
		update_icon()
		if(do_after(user, 30 * toolspeed, target = M)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
			user.visible_message("<span class='notice'>[user] places [src] on [M.name]'s chest.</span>", "<span class='warning'>You place [src] on [M.name]'s chest.</span>")
			playsound(get_turf(src), 'sound/machines/defib_charge.ogg', 50, 0)
			var/mob/dead/observer/ghost = H.get_ghost(TRUE)
			if(ghost && !ghost.client)
				// In case the ghost's not getting deleted for some reason
				H.key = ghost.key
				log_runtime(EXCEPTION("Ghost of name [ghost.name] is bound to [H.real_name], but lacks a client. Deleting ghost."), src)

				QDEL_NULL(ghost)
			var/tplus = world.time - H.timeofdeath
			var/tlimit = DEFIB_TIME_LIMIT
			var/tloss = DEFIB_TIME_LOSS
			var/total_burn	= 0
			var/total_brute	= 0
			if(do_after(user, 20 * toolspeed, target = M)) //placed on chest and short delay to shock for dramatic effect, revive time is 5sec total
				for(var/obj/item/carried_item in H.contents)
					if(istype(carried_item, /obj/item/clothing/suit/space))
						if(!defib.combat)
							user.visible_message("<span class='notice'>[defib] buzzes: Patient's chest is obscured. Operation aborted.</span>")
							playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
							busy = FALSE
							update_icon()
							return
				if(H.undergoing_cardiac_arrest())
					if(!H.get_int_organ(/obj/item/organ/internal/heart) && !H.get_int_organ(/obj/item/organ/internal/brain/slime)) //prevents defibing someone still alive suffering from a heart attack attack if they lack a heart
						user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Failed to pick up any heart electrical activity.</span>")
						playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
						busy = FALSE
						update_icon()
						return
					else
						var/obj/item/organ/internal/heart/heart = H.get_int_organ(/obj/item/organ/internal/heart)
						if(heart.status & ORGAN_DEAD)
							user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Heart necrosis detected.</span>")
							playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
							busy = FALSE
							update_icon()
							return
						H.set_heartattack(FALSE)
						SEND_SIGNAL(H, COMSIG_LIVING_MINOR_SHOCK, 100)
						user.visible_message("<span class='boldnotice'>[defib] pings: Cardiac arrhythmia corrected.</span>")
						M.visible_message("<span class='warning'>[M]'s body convulses a bit.")
						playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
						playsound(get_turf(src), "bodyfall", 50, 1)
						playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
						defib.deductcharge(revivecost)
						busy = FALSE
						cooldown = TRUE
						update_icon()
						defib.cooldowncheck(user)
						return
				if(H.stat == DEAD)
					var/health = H.health
					M.visible_message("<span class='warning'>[M]'s body convulses a bit.")
					playsound(get_turf(src), "bodyfall", 50, 1)
					playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
					for(var/obj/item/organ/external/O in H.bodyparts)
						total_brute	+= O.brute_dam
						total_burn	+= O.burn_dam
					if(total_burn <= 180 && total_brute <= 180 && !H.suiciding && !ghost && tplus < tlimit && !HAS_TRAIT(H, TRAIT_HUSK)  && !HAS_TRAIT(H, TRAIT_BADDNA) && (H.get_int_organ(/obj/item/organ/internal/heart) || H.get_int_organ(/obj/item/organ/internal/brain/slime)))
						tobehealed = min(health + threshold, 0) // It's HILARIOUS without this min statement, let me tell you
						tobehealed -= 5 //They get 5 of each type of damage healed so excessive combined damage will not immediately kill them after they get revived
						H.adjustOxyLoss(tobehealed)
						H.adjustToxLoss(tobehealed)
						H.adjustFireLoss(tobehealed)
						H.adjustBruteLoss(tobehealed)
						user.visible_message("<span class='boldnotice'>[defib] pings: Resuscitation successful.</span>")
						playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
						H.update_revive()
						H.KnockOut()
						H.Paralyse(5)
						H.emote("gasp")
						if(tplus > tloss)
							H.setBrainLoss( max(0, min(99, ((tlimit - tplus) / tlimit * 100))))
						SEND_SIGNAL(H, COMSIG_LIVING_MINOR_SHOCK, 100)
						H.med_hud_set_health()
						H.med_hud_set_status()
						defib.deductcharge(revivecost)
						add_attack_logs(user, M, "Revived with [src]")
					else
						if(tplus > tlimit|| !H.get_int_organ(/obj/item/organ/internal/heart))
							user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Heart tissue damage beyond point of no return for defibrillation.</span>")
						else if(total_burn >= 180 || total_brute >= 180)
							user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Severe tissue damage detected.</span>")
						else if(HAS_TRAIT(H, TRAIT_HUSK))
							user.visible_message("<span class='notice'>[defib] buzzes: Resucitation failed: Subject is husked.</span>")
						else if(ghost)
							if(!ghost.can_reenter_corpse) // DNR or AntagHUD
								user.visible_message("<span class='notice'>[defib] buzzes: Resucitation failed: No electrical brain activity detected.</span>")
							else
								user.visible_message("<span class='notice'>[defib] buzzes: Resuscitation failed: Patient's brain is unresponsive. Further attempts may succeed.</span>")
								to_chat(ghost, "<span class='ghostalert'>Your heart is being defibrillated. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)")
								window_flash(ghost.client)
								ghost << sound('sound/effects/genetics.ogg')
						else
							user.visible_message("<span class='notice'>[defib] buzzes: Resuscitation failed.</span>")
						playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
						defib.deductcharge(revivecost)
					update_icon()
					cooldown = TRUE
					defib.cooldowncheck(user)
				else
					user.visible_message("<span class='notice'>[defib] buzzes: Patient is not in a valid state. Operation aborted.</span>")
					playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
		busy = FALSE
		update_icon()

/obj/item/borg_defib
	name = "defibrillator paddles"
	desc = "A pair of paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"
	force = 0
	w_class = WEIGHT_CLASS_BULKY
	var/revivecost = 1000
	var/cooldown = FALSE
	var/busy = FALSE
	var/safety = TRUE
	flags = NODROP
	toolspeed = 1

/obj/item/borg_defib/attack(mob/M, mob/user)
	var/tobehealed
	var/threshold = -HEALTH_THRESHOLD_DEAD
	var/mob/living/carbon/human/H = M

	if(busy)
		return
	if(cooldown)
		to_chat(user, "<span class='notice'>[src] is recharging.</span>")
	if(!ishuman(M))
		to_chat(user, "<span class='notice'>This unit is only designed to work on humanoid lifeforms.</span>")
		return
	else
		if(user.a_intent == INTENT_HARM && !safety)
			busy = TRUE
			H.visible_message("<span class='danger'>[user] has touched [H.name] with [src]!</span>", \
					"<span class='userdanger'>[user] has touched [H.name] with [src]!</span>")
			H.adjustStaminaLoss(50)
			H.Weaken(5)
			if(!H.undergoing_cardiac_arrest() && prob(10)) // Your heart explodes.
				H.set_heartattack(TRUE)
			SEND_SIGNAL(H, COMSIG_LIVING_MINOR_SHOCK, 100)
			playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
			H.emote("gasp")
			add_attack_logs(user, M, "Stunned with [src]")
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.use(revivecost)
			cooldown = TRUE
			busy = FALSE
			update_icon()
			spawn(50)
				cooldown = FALSE
				update_icon()
			return
		user.visible_message("<span class='warning'>[user] begins to place [src] on [M.name]'s chest.</span>", "<span class='warning'>You begin to place [src] on [M.name]'s chest.</span>")
		busy = TRUE
		update_icon()
		if(do_after(user, 30 * toolspeed, target = M)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
			user.visible_message("<span class='notice'>[user] places [src] on [M.name]'s chest.</span>", "<span class='warning'>You place [src] on [M.name]'s chest.</span>")
			playsound(get_turf(src), 'sound/machines/defib_charge.ogg', 50, 0)
			var/mob/dead/observer/ghost = H.get_ghost()
			if(ghost && !ghost.client)
				// In case the ghost's not getting deleted for some reason
				H.key = ghost.key
				log_runtime(EXCEPTION("Ghost of name [ghost.name] is bound to [H.real_name], but lacks a client. Deleting ghost."), H)

				QDEL_NULL(ghost)
			var/tplus = world.time - H.timeofdeath
			var/tlimit = 3000 //past this much time the patient is unrecoverable (in deciseconds)
			var/tloss = 600 //brain damage starts setting in on the patient after some time left rotting
			var/total_burn	= 0
			var/total_brute	= 0
			if(do_after(user, 20 * toolspeed, target = M)) //placed on chest and short delay to shock for dramatic effect, revive time is 5sec total
				if(H.stat == DEAD)
					var/health = H.health
					M.visible_message("<span class='warning'>[M]'s body convulses a bit.")
					playsound(get_turf(src), "bodyfall", 50, 1)
					playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
					for(var/obj/item/organ/external/O in H.bodyparts)
						total_brute	+= O.brute_dam
						total_burn	+= O.burn_dam
					if(total_burn <= 180 && total_brute <= 180 && !H.suiciding && !ghost && tplus < tlimit && !HAS_TRAIT(H, TRAIT_HUSK))
						tobehealed = min(health + threshold, 0) // It's HILARIOUS without this min statement, let me tell you
						tobehealed -= 5 //They get 5 of each type of damage healed so excessive combined damage will not immediately kill them after they get revived
						H.adjustOxyLoss(tobehealed)
						H.adjustToxLoss(tobehealed)
						H.adjustFireLoss(tobehealed)
						H.adjustBruteLoss(tobehealed)
						user.visible_message("<span class='notice'>[user] pings: Resuscitation successful.</span>")
						playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
						H.update_revive(FALSE)
						H.KnockOut(FALSE)
						H.Paralyse(5)
						H.emote("gasp")
						if(tplus > tloss)
							H.setBrainLoss( max(0, min(99, ((tlimit - tplus) / tlimit * 100))))
						SEND_SIGNAL(H, COMSIG_LIVING_MINOR_SHOCK, 100)
						if(isrobot(user))
							var/mob/living/silicon/robot/R = user
							R.cell.use(revivecost)
						add_attack_logs(user, M, "Revived with [src]")
					else
						if(tplus > tlimit)
							user.visible_message("<span class='warning'>[user] buzzes: Resuscitation failed - Heart tissue damage beyond point of no return for defibrillation.</span>")
						else if(total_burn >= 180 || total_brute >= 180)
							user.visible_message("<span class='warning'>[user] buzzes: Resuscitation failed - Severe tissue damage detected.</span>")
						else if(ghost)
							user.visible_message("<span class='notice'>[user] buzzes: Resuscitation failed: Patient's brain is unresponsive. Further attempts may succeed.</span>")
							to_chat(ghost, "<span class='ghostalert'>Your heart is being defibrillated. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)")
							window_flash(ghost.client)
							ghost << sound('sound/effects/genetics.ogg')
						else
							user.visible_message("<span class='warning'>[user] buzzes: Resuscitation failed.</span>")
						playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
						if(isrobot(user))
							var/mob/living/silicon/robot/R = user
							R.cell.use(revivecost)
					update_icon()
					cooldown = TRUE
					spawn(50)
						cooldown = FALSE
						update_icon()
				else
					user.visible_message("<span class='notice'>[user] buzzes: Patient is not in a valid state. Operation aborted.</span>")
					playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
		busy = FALSE
		update_icon()

/obj/item/twohanded/shockpaddles/syndicate
	name = "combat defibrillator paddles"
	desc = "A pair of high-tech paddles with flat plasteel surfaces to revive deceased operatives (unless they exploded). They possess both the ability to penetrate armor and to deliver powerful or disabling shocks offensively."
	icon_state = "syndiepaddles0"
	item_state = "syndiepaddles0"
	base_icon_state = "syndiepaddles"

/obj/item/twohanded/shockpaddles/advanced
	name = "advanced defibrillator paddles"
	desc = "A pair of high-tech paddles with flat plasteel surfaces that are used to deliver powerful electric shocks. They possess the ability to penetrate armor to deliver shock."
	icon_state = "ntpaddles0"
	item_state = "ntpaddles0"
	base_icon_state = "ntpaddles"
