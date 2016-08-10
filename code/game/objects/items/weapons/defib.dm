//backpack item

/obj/item/weapon/defibrillator
	name = "defibrillator"
	desc = "A device that delivers powerful shocks to detachable paddles that resuscitate incapacitated patients."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "defibunit"
	item_state = "defibunit"
	slot_flags = SLOT_BACK
	force = 5
	throwforce = 6
	w_class = 4
	origin_tech = "biotech=4"
	actions_types = list(/datum/action/item_action/toggle_paddles)
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/back.dmi'
		)

	var/on = 0 //if the paddles are equipped (1) or on the defib (0)
	var/safety = 1 //if you can zap people with the defibs on harm mode
	var/powered = 0 //if there's a cell in the defib with enough power for a revive, blocks paddles from reviving otherwise
	var/obj/item/weapon/twohanded/shockpaddles/paddles
	var/obj/item/weapon/stock_parts/cell/high/bcell = null
	var/combat = 0 //can we revive through space suits?

/obj/item/weapon/defibrillator/New() //starts without a cell for rnd
	..()
	paddles = make_paddles()
	update_icon()
	return

/obj/item/weapon/defibrillator/loaded/New() //starts with hicap
	..()
	paddles = make_paddles()
	bcell = new(src)
	update_icon()
	return

/obj/item/weapon/defibrillator/update_icon()
	update_power()
	update_overlays()
	update_charge()

/obj/item/weapon/defibrillator/proc/update_power()
	if(bcell)
		if(bcell.charge < paddles.revivecost)
			powered = 0
		else
			powered = 1
	else
		powered = 0

/obj/item/weapon/defibrillator/proc/update_overlays()
	overlays.Cut()
	if(!on)
		overlays += "[icon_state]-paddles"
	if(powered)
		overlays += "[icon_state]-powered"
	if(!bcell)
		overlays += "[icon_state]-nocell"
	if(!safety)
		overlays += "[icon_state]-emagged"

/obj/item/weapon/defibrillator/proc/update_charge()
	if(powered) //so it doesn't show charge if it's unpowered
		if(bcell)
			var/ratio = bcell.charge / bcell.maxcharge
			ratio = Ceiling(ratio*4) * 25
			overlays += "[icon_state]-charge[ratio]"

/obj/item/weapon/defibrillator/CheckParts(list/parts_list)
	..()
	bcell = locate(/obj/item/weapon/stock_parts/cell) in contents
	update_icon()

/obj/item/weapon/defibrillator/ui_action_click()
	toggle_paddles()

/obj/item/weapon/defibrillator/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/C = W
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

	if(istype(W, /obj/item/weapon/screwdriver))
		if(bcell)
			bcell.updateicon()
			bcell.loc = get_turf(src.loc)
			bcell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")

	update_icon()
	return

/obj/item/weapon/defibrillator/emag_act(user as mob)
	if(safety)
		safety = 0
		to_chat(user, "<span class='warning'>You silently disable [src]'s safety protocols with the card.")
	else
		safety = 1
		to_chat(user, "<span class='notice'>You silently enable [src]'s safety protocols with the card.")

/obj/item/weapon/defibrillator/emp_act(severity)
	if(bcell)
		deductcharge(1000 / severity)
		if(bcell.reliability != 100 && prob(50/severity))
			bcell.reliability -= 10 / severity
	if(safety)
		safety = 0
		src.visible_message("<span class='notice'>[src] beeps: Safety protocols disabled!</span>")
		playsound(get_turf(src), 'sound/machines/defib_saftyOff.ogg', 50, 0)
	else
		safety = 1
		src.visible_message("<span class='notice'>[src] beeps: Safety protocols enabled!</span>")
		playsound(get_turf(src), 'sound/machines/defib_saftyOn.ogg', 50, 0)
	update_icon()
	..()

/obj/item/weapon/defibrillator/verb/toggle_paddles()
	set name = "Toggle Paddles"
	set category = "Object"
	on = !on

	var/mob/living/carbon/human/user = usr
	if(on)
		//Detach the paddles into the user's hands
		if(!usr.put_in_hands(paddles))
			on = 0
			to_chat(user, "<span class='warning'>You need a free hand to hold the paddles!</span>")
			update_icon()
			return
		paddles.loc = user
	else
		//Remove from their hands and back onto the defib unit
		remove_paddles(user)

	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/weapon/defibrillator/proc/make_paddles()
	return new /obj/item/weapon/twohanded/shockpaddles(src)

/obj/item/weapon/defibrillator/equipped(mob/user, slot)
	..()
	if(slot != slot_back)
		remove_paddles(user)
		update_icon()

/obj/item/weapon/defibrillator/item_action_slot_check(slot, mob/user)
	if(slot == slot_back)
		return 1

/obj/item/weapon/defibrillator/proc/remove_paddles(mob/user)
	var/mob/living/carbon/human/M = user
	if(paddles in get_both_hands(M))
		M.unEquip(paddles)
	update_icon()
	return

/obj/item/weapon/defibrillator/Destroy()
	if(on)
		var/M = get(paddles, /mob)
		remove_paddles(M)
	if(paddles)
		qdel(paddles)
		paddles = null
	if(bcell)
		qdel(bcell)
		bcell = null
	return ..()

/obj/item/weapon/defibrillator/proc/deductcharge(var/chrgdeductamt)
	if(bcell)
		if(bcell.charge < (paddles.revivecost+chrgdeductamt))
			powered = 0
			update_icon()
		if(bcell.use(chrgdeductamt))
			update_icon()
			return 1
		else
			update_icon()
			return 0

/obj/item/weapon/defibrillator/proc/cooldowncheck(var/mob/user)
	spawn(50)
		if(bcell)
			if(bcell.charge >= paddles.revivecost)
				user.visible_message("<span class='notice'>[src] beeps: Unit ready.</span>")
				playsound(get_turf(src), 'sound/machines/defib_ready.ogg', 50, 0)
			else
				user.visible_message("<span class='notice'>[src] beeps: Charge depleted.</span>")
				playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
		paddles.cooldown = 0
		paddles.update_icon()
		update_icon()

/obj/item/weapon/defibrillator/compact
	name = "compact defibrillator"
	desc = "A belt-equipped defibrillator that can be rapidly deployed."
	icon_state = "defibcompact"
	item_state = "defibcompact"
	w_class = 3
	slot_flags = SLOT_BELT
	origin_tech = "biotech=4"

/obj/item/weapon/defibrillator/compact/item_action_slot_check(slot, mob/user)
	if(slot == slot_belt)
		return 1

/obj/item/weapon/defibrillator/compact/loaded/New()
	..()
	paddles = make_paddles()
	bcell = new(src)
	update_icon()
	return

/obj/item/weapon/defibrillator/compact/combat
	name = "combat defibrillator"
	desc = "A belt-equipped blood-red defibrillator that can be rapidly deployed. Does not have the restrictions or safeties of conventional defibrillators and can revive through space suits."
	combat = 1
	safety = 0

/obj/item/weapon/defibrillator/compact/combat/loaded/New()
	..()
	paddles = make_paddles()
	bcell = new /obj/item/weapon/stock_parts/cell/infinite(src)
	update_icon()
	return

/obj/item/weapon/defibrillator/compact/combat/attackby(obj/item/weapon/W, mob/user, params)
	if(W == paddles)
		paddles.unwield()
		toggle_paddles()
		update_icon()
		return

//paddles

/obj/item/weapon/twohanded/shockpaddles
	name = "defibrillator paddles"
	desc = "A pair of plastic-gripped paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "defibpaddles"
	item_state = "defibpaddles"
	force = 0
	throwforce = 6
	w_class = 4

	var/revivecost = 1000
	var/cooldown = 0
	var/busy = 0
	var/obj/item/weapon/defibrillator/defib

/obj/item/weapon/twohanded/shockpaddles/New(mainunit)
	..()
	if(check_defib_exists(mainunit, src))
		defib = mainunit
		loc = defib
		busy = 0
		update_icon()
	return

/obj/item/weapon/twohanded/shockpaddles/update_icon()
	icon_state = "defibpaddles[wielded]"
	item_state = "defibpaddles[wielded]"
	if(cooldown)
		icon_state = "defibpaddles[wielded]_cooldown"

/obj/item/weapon/twohanded/shockpaddles/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is putting the live paddles on \his chest! It looks like \he's trying to commit suicide.</span>")
	defib.deductcharge(revivecost)
	playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
	return (OXYLOSS)

/obj/item/weapon/twohanded/shockpaddles/dropped(mob/user as mob)
	if(user)
		var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
		to_chat(user, "<span class='notice'>The paddles snap back into the main unit.</span>")
		defib.on = 0
		loc = defib
		defib.update_icon()
	return	unwield()

/obj/item/weapon/twohanded/shockpaddles/proc/check_defib_exists(mainunit, var/mob/living/carbon/human/M, var/obj/O)
	if(!mainunit || !istype(mainunit, /obj/item/weapon/defibrillator))	//To avoid weird issues from admin spawns
		M.unEquip(O)
		qdel(O)
		return 0
	else
		return 1

/obj/item/weapon/twohanded/shockpaddles/attack(mob/M, mob/user)
	var/tobehealed
	var/threshold = -config.health_threshold_dead
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
		to_chat(user, "<span class='notice'>The instructions on [defib] don't mention how to revive that...</span>")
		return
	else
		if(user.a_intent == I_HARM && !defib.safety)
			busy = 1
			H.visible_message("<span class='danger'>[user] has touched [H.name] with [src]!</span>", \
					"<span class='userdanger'>[user] has touched [H.name] with [src]!</span>")
			H.adjustStaminaLoss(50)
			H.Weaken(5)
			H.updatehealth() //forces health update before next life tick
			playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
			H.emote("gasp")
			if(!H.heart_attack && (prob(10) || defib.combat)) // Your heart explodes.
				H.heart_attack = 1
			add_logs(M, user, "stunned", object="defibrillator")
			defib.deductcharge(revivecost)
			cooldown = 1
			busy = 0
			update_icon()
			defib.cooldowncheck(user)
			return
		if(user.zone_sel && user.zone_sel.selecting == "chest")
			user.visible_message("<span class='warning'>[user] begins to place [src] on [M.name]'s chest.</span>", "<span class='warning'>You begin to place [src] on [M.name]'s chest.</span>")
			busy = 1
			update_icon()
			if(do_after(user, 30, target = M)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
				user.visible_message("<span class='notice'>[user] places [src] on [M.name]'s chest.</span>", "<span class='warning'>You place [src] on [M.name]'s chest.</span>")
				playsound(get_turf(src), 'sound/machines/defib_charge.ogg', 50, 0)
				var/mob/dead/observer/ghost = H.get_ghost()
				if(ghost && !ghost.client)
					// In case the ghost's not getting deleted for some reason
					H.key = ghost.key
					log_to_dd("Ghost of name [ghost.name] is bound to [H.real_name], but lacks a client. Deleting ghost.")

					qdel(ghost)
					ghost = null
				var/tplus = world.time - H.timeofdeath
				var/tlimit = 1800 //past this much time the patient is unrecoverable (in deciseconds)
				var/tloss = 600 //brain damage starts setting in on the patient after some time left rotting
				var/total_burn	= 0
				var/total_brute	= 0
				if(do_after(user, 20, target = M)) //placed on chest and short delay to shock for dramatic effect, revive time is 5sec total
					for(var/obj/item/carried_item in H.contents)
						if(istype(carried_item, /obj/item/clothing/suit/space))
							if(!defib.combat)
								user.visible_message("<span class='notice'>[defib] buzzes: Patient's chest is obscured. Operation aborted.</span>")
								playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
								busy = 0
								update_icon()
								return
					if(H.heart_attack)
						if(!H.get_int_organ(/obj/item/organ/internal/heart) && !H.get_int_organ(/obj/item/organ/internal/brain/slime)) //prevents defibing someone still alive suffering from a heart attack attack if they lack a heart
							user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Failed to pick up any heart electrical activity.</span>")
							playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
							busy = 0
							update_icon()
							return
						else
							H.heart_attack = 0
							user.visible_message("<span class='boldnotice'>[defib] pings: Cardiac arrhythmia corrected.</span>")
							M.visible_message("<span class='warning'>[M]'s body convulses a bit.")
							playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
							playsound(get_turf(src), "bodyfall", 50, 1)
							playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
							defib.deductcharge(revivecost)
							busy = 0
							cooldown = 1
							update_icon()
							defib.cooldowncheck(user)
							return
					if(H.stat == DEAD)
						var/health = H.health
						M.visible_message("<span class='warning'>[M]'s body convulses a bit.")
						playsound(get_turf(src), "bodyfall", 50, 1)
						playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
						for(var/obj/item/organ/external/O in H.organs)
							total_brute	+= O.brute_dam
							total_burn	+= O.burn_dam
						if(total_burn <= 180 && total_brute <= 180 && !H.suiciding && !ghost && tplus < tlimit && !(NOCLONE in H.mutations) && (H.get_int_organ(/obj/item/organ/internal/heart) || H.get_int_organ(/obj/item/organ/internal/brain/slime)))
							tobehealed = min(health + threshold, 0) // It's HILARIOUS without this min statement, let me tell you
							tobehealed -= 5 //They get 5 of each type of damage healed so excessive combined damage will not immediately kill them after they get revived
							H.adjustOxyLoss(tobehealed)
							H.adjustToxLoss(tobehealed)
							H.adjustFireLoss(tobehealed)
							H.adjustBruteLoss(tobehealed)
							user.visible_message("<span class='boldnotice'>[defib] pings: Resuscitation successful.</span>")
							playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
							H.stat = 1
							H.update_revive()
							H.emote("gasp")
							if(tplus > tloss)
								H.setBrainLoss( max(0, min(99, ((tlimit - tplus) / tlimit * 100))))
							defib.deductcharge(revivecost)
							add_logs(M, user, "revived", object="defibrillator")
						else
							if(tplus > tlimit|| !H.get_int_organ(/obj/item/organ/internal/heart))
								user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Heart tissue damage beyond point of no return for defibrillation.</span>")
							else if(total_burn >= 180 || total_brute >= 180)
								user.visible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Severe tissue damage detected.</span>")
							else if(ghost)
								user.visible_message("<span class='notice'>[defib] buzzes: Resuscitation failed: Patient's brain is unresponsive. Further attempts may succeed.</span>")
								to_chat(ghost, "<span class='ghostalert'>Your heart is being defibrillated. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)")
								ghost << sound('sound/effects/genetics.ogg')
							else
								user.visible_message("<span class='notice'>[defib] buzzes: Resuscitation failed.</span>")
							playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
							defib.deductcharge(revivecost)
						update_icon()
						cooldown = 1
						defib.cooldowncheck(user)
					else
						user.visible_message("<span class='notice'>[defib] buzzes: Patient is not in a valid state. Operation aborted.</span>")
						playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
			busy = 0
			update_icon()
		else
			to_chat(user, "<span class='notice'>You need to target your patient's chest with [src].</span>")
			return

/obj/item/weapon/borg_defib
	name = "defibrillator paddles"
	desc = "A pair of mounted paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"
	force = 0
	w_class = 4
	var/revivecost = 1000
	var/cooldown = 0
	var/busy = 0
	var/safety = 1
	flags = NODROP

/obj/item/weapon/borg_defib/attack(mob/M, mob/user)
	var/tobehealed
	var/threshold = -config.health_threshold_dead
	var/mob/living/carbon/human/H = M

	if(busy)
		return
	if(cooldown)
		to_chat(user, "<span class='notice'>[src] is recharging.</span>")
	if(!ishuman(M))
		to_chat(user, "<span class='notice'>This unit is only designed to work on humanoid lifeforms.</span>")
		return
	else
		if(user.a_intent == I_HARM  && !safety)
			busy = 1
			H.visible_message("<span class='danger'>[user] has touched [H.name] with [src]!</span>", \
					"<span class='userdanger'>[user] has touched [H.name] with [src]!</span>")
			H.adjustStaminaLoss(50)
			H.Weaken(5)
			H.updatehealth() //forces health update before next life tick
			if(!H.heart_attack && prob(10)) // Your heart explodes.
				H.heart_attack = 1
			playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
			H.emote("gasp")
			add_logs(M, user, "stunned", object="defibrillator")
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.use(revivecost)
			cooldown = 1
			busy = 0
			update_icon()
			spawn(50)
				cooldown = 0
				update_icon()
			return
		if(user.zone_sel && user.zone_sel.selecting == "chest")
			user.visible_message("<span class='warning'>[user] begins to place [src] on [M.name]'s chest.</span>", "<span class='warning'>You begin to place [src] on [M.name]'s chest.</span>")
			busy = 1
			update_icon()
			if(do_after(user, 30, target = M)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
				user.visible_message("<span class='notice'>[user] places [src] on [M.name]'s chest.</span>", "<span class='warning'>You place [src] on [M.name]'s chest.</span>")
				playsound(get_turf(src), 'sound/machines/defib_charge.ogg', 50, 0)
				var/mob/dead/observer/ghost = H.get_ghost()
				if(ghost && !ghost.client)
					// In case the ghost's not getting deleted for some reason
					H.key = ghost.key
					log_to_dd("Ghost of name [ghost.name] is bound to [H.real_name], but lacks a client. Deleting ghost.")

					qdel(ghost)
					ghost = null
				var/tplus = world.time - H.timeofdeath
				var/tlimit = 1800 //past this much time the patient is unrecoverable (in deciseconds)
				var/tloss = 600 //brain damage starts setting in on the patient after some time left rotting
				var/total_burn	= 0
				var/total_brute	= 0
				if(do_after(user, 20, target = M)) //placed on chest and short delay to shock for dramatic effect, revive time is 5sec total
					if(H.stat == 2)
						var/health = H.health
						M.visible_message("<span class='warning'>[M]'s body convulses a bit.")
						playsound(get_turf(src), "bodyfall", 50, 1)
						playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
						for(var/obj/item/organ/external/O in H.organs)
							total_brute	+= O.brute_dam
							total_burn	+= O.burn_dam
						if(total_burn <= 180 && total_brute <= 180 && !H.suiciding && !ghost && tplus < tlimit && !(NOCLONE in H.mutations))
							tobehealed = min(health + threshold, 0) // It's HILARIOUS without this min statement, let me tell you
							tobehealed -= 5 //They get 5 of each type of damage healed so excessive combined damage will not immediately kill them after they get revived
							H.adjustOxyLoss(tobehealed)
							H.adjustToxLoss(tobehealed)
							H.adjustFireLoss(tobehealed)
							H.adjustBruteLoss(tobehealed)
							user.visible_message("<span class='notice'>[user] pings: Resuscitation successful.</span>")
							playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
							H.stat = UNCONSCIOUS
							H.update_revive()
							H.emote("gasp")
							if(tplus > tloss)
								H.setBrainLoss( max(0, min(99, ((tlimit - tplus) / tlimit * 100))))
							if(isrobot(user))
								var/mob/living/silicon/robot/R = user
								R.cell.use(revivecost)
							add_logs(M, user, "revived", object="defibrillator")
						else
							if(tplus > tlimit)
								user.visible_message("<span class='warning'>[user] buzzes: Resuscitation failed - Heart tissue damage beyond point of no return for defibrillation.</span>")
							else if(total_burn >= 180 || total_brute >= 180)
								user.visible_message("<span class='warning'>[user] buzzes: Resuscitation failed - Severe tissue damage detected.</span>")
							else if(ghost)
								user.visible_message("<span class='notice'>[user] buzzes: Resuscitation failed: Patient's brain is unresponsive. Further attempts may succeed.</span>")
								to_chat(ghost, "<span class='ghostalert'>Your heart is being defibrillated. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)")
								ghost << sound('sound/effects/genetics.ogg')
							else
								user.visible_message("<span class='warning'>[user] buzzes: Resuscitation failed.</span>")
							playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
							if(isrobot(user))
								var/mob/living/silicon/robot/R = user
								R.cell.use(revivecost)
						update_icon()
						cooldown = 1
						spawn(50)
							cooldown = 0
							update_icon()
					else
						user.visible_message("<span class='notice'>[user] buzzes: Patient is not in a valid state. Operation aborted.</span>")
						playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
			busy = 0
			update_icon()
		else
			to_chat(user, "<span class='notice'>You need to target your patient's chest with [src].</span>")
			return
