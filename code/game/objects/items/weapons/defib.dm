//backpack item

/obj/item/defibrillator
	name = "defibrillator"
	desc = "A device that delivers powerful shocks to detachable paddles that resuscitate incapacitated patients."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibunit"
	item_state = "defibunit"
	slot_flags = SLOT_FLAG_BACK
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "biotech=4"
	actions_types = list(/datum/action/item_action/toggle_paddles)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/back.dmi'
		)

	/// If the paddles are currently attached to the unit.
	var/paddles_on_defib = TRUE
	/// if there's a cell in the defib with enough power for a revive; blocks paddles from reviving otherwise
	var/powered = FALSE
	/// Ref to attached paddles
	var/obj/item/shockpaddles/paddles
	/// Ref to internal power cell.
	var/obj/item/stock_parts/cell/high/cell = null
	/// If false, using harm intent will let you zap people. Note that any updates to this after init will only impact icons.
	var/safety = TRUE
	/// If true, this can be used through hardsuits, and can cause heart attacks in harm intent.
	var/combat = FALSE
	// If safety is false and combat is true, the chance that this will cause a heart attack.
	var/heart_attack_probability = 30
	/// If this is vulnerable to EMPs.
	var/hardened = FALSE
	/// If this can be emagged.
	var/emag_proof = FALSE

	base_icon_state = "defibpaddles"
	/// Type of paddles that should be attached to this defib.
	var/obj/item/shockpaddles/paddle_type = /obj/item/shockpaddles

/obj/item/defibrillator/get_cell()
	return cell

/obj/item/defibrillator/Initialize(mapload) // Base version starts without a cell for rnd
	. = ..()
	paddles = new paddle_type(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/loaded/Initialize(mapload) // Loaded version starts with high-capacity cell.
	. = ..()
	cell = new(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/update_icon(updates=ALL)
	update_power()
	..()

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

/obj/item/defibrillator/update_overlays()
	. = ..()
	if(paddles_on_defib)
		. += "[icon_state]-paddles"
	if(!safety)
		. += "[icon_state]-emagged"
	if(powered)
		. += "[icon_state]-powered"
	if(powered && cell)
		var/ratio = cell.charge / cell.maxcharge
		ratio = CEILING(ratio*4, 1) * 25
		. += "[icon_state]-charge[ratio]"
	if(!cell)
		. += "[icon_state]-nocell"

/obj/item/defibrillator/CheckParts(list/parts_list)
	..()
	cell = locate(/obj/item/stock_parts/cell) in contents
	update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/ui_action_click()
	toggle_paddles()

/obj/item/defibrillator/CtrlClick(mob/user)
	if(ishuman(user) && Adjacent(user))
		toggle_paddles(user)

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

	update_icon(UPDATE_OVERLAYS)
	return

/obj/item/defibrillator/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, "<span class='notice'>[src] doesn't have a cell.</span>")
		return

	cell.update_icon()
	cell.forceMove(get_turf(loc))
	cell = null
	to_chat(user, "<span class='notice'>You remove the cell from [src].</span>")
	update_icon(UPDATE_OVERLAYS)
	return TRUE

/obj/item/defibrillator/emp_act(severity)
	if(cell)
		deductcharge(1000 / severity)
	safety = !safety
	update_icon(UPDATE_OVERLAYS)
	..()

/obj/item/defibrillator/emag_act(mob/user)
	safety = !safety
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/proc/toggle_paddles(mob/living/carbon/human/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(paddles_on_defib)
		//Detach the paddles into the user's hands
		if(!user.put_in_hands(paddles))
			to_chat(user, "<span class='warning'>You need a free hand to hold the paddles!</span>")
			update_icon(UPDATE_OVERLAYS)
			return
		paddles.forceMove(user)
		paddles_on_defib = FALSE
	else if(user.is_in_active_hand(paddles))
		//Remove from their hands and back onto the defib unit
		remove_paddles(user)

	update_icon(UPDATE_OVERLAYS)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/defibrillator/equipped(mob/user, slot)
	..()
	if(slot != SLOT_HUD_BACK)
		remove_paddles(user)
		update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/item_action_slot_check(slot, mob/user)
	if(slot == SLOT_HUD_BACK)
		return TRUE

/obj/item/defibrillator/proc/remove_paddles(mob/user) // from your hands
	var/mob/living/carbon/human/M = user
	if(paddles in get_both_hands(M))
		M.unEquip(paddles)
		paddles_on_defib = TRUE
	update_icon(UPDATE_OVERLAYS)
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
			update_icon(UPDATE_OVERLAYS)
		if(cell.use(chrgdeductamt))
			update_icon(UPDATE_OVERLAYS)
			return TRUE
		else
			update_icon(UPDATE_OVERLAYS)
			return FALSE

/obj/item/defibrillator/compact
	name = "compact defibrillator"
	desc = "A belt-mounted defibrillator that can be rapidly deployed."
	icon_state = "defibcompact"
	item_state = "defibcompact"
	sprite_sheets = null //Because Vox had the belt defibrillator sprites in back.dm
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_FLAG_BELT
	flags_2 = ALLOW_BELT_NO_JUMPSUIT_2
	origin_tech = "biotech=5"

/obj/item/defibrillator/compact/loaded/Initialize(mapload)
	. = ..()
	cell = new(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/compact/item_action_slot_check(slot, mob/user)
	if(slot == SLOT_HUD_BELT)
		return TRUE

/obj/item/defibrillator/compact/combat
	name = "combat defibrillator"
	desc = "A belt-mounted blood-red defibrillator that can be rapidly deployed. Does not have the restrictions or safeties of conventional defibrillators and can revive through space suits."
	icon_state = "defibcombat"
	item_state = "defibcombat"
	paddle_type = /obj/item/shockpaddles/syndicate
	combat = TRUE
	safety = FALSE
	heart_attack_probability = 100

/obj/item/defibrillator/compact/combat/loaded/Initialize(mapload)
	. = ..()
	cell = new(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/compact/advanced
	name = "advanced compact defibrillator"
	desc = "A belt-mounted state-of-the-art defibrillator that can be rapidly deployed in all environments. Uses an experimental self-charging cell, meaning that it will (probably) never stop working. Can be used to defibrillate through space suits. It is impossible to damage."
	icon_state = "defibnt"
	item_state = "defibnt"
	paddle_type = /obj/item/shockpaddles/advanced
	combat = TRUE
	safety = TRUE
	hardened = TRUE // emp-proof (on the component), but not emag-proof.
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //Objective item, better not have it destroyed.
	heart_attack_probability = 10

	var/next_emp_message //to prevent spam from the emagging message on the advanced defibrillator

/obj/item/defibrillator/compact/advanced/screwdriver_act(mob/living/user, obj/item/I)
	return // The cell is too strong roundstart and we dont want the adv defib to become useless

/obj/item/defibrillator/compact/advanced/attackby(obj/item/W, mob/user, params)
	if(W == paddles)
		toggle_paddles()
		update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/compact/advanced/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/bluespace/charging(src)
	update_icon(UPDATE_OVERLAYS)
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(alert_admins_on_destroy))

/obj/item/defibrillator/compact/advanced/emp_act(severity)
	if(world.time > next_emp_message)
		atom_say("Warning: Electromagnetic pulse detected. Integrated shielding prevented all potential hardware damage.")
		playsound(src, 'sound/machines/defib_saftyon.ogg', 50)
		next_emp_message = world.time + 5 SECONDS

//paddles

/obj/item/shockpaddles
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
	base_icon_state = "defibpaddles"
	/// Amount of power used on a shock.
	var/revivecost = 1000
	/// Active defib this is connected to.
	var/obj/item/defibrillator/defib
	/// Whether or not the paddles are on cooldown. Used for tracking icon states.
	var/on_cooldown = FALSE


/obj/item/shockpaddles/New(mainunit)
	. = ..()

	if(check_defib_exists(mainunit, null, src))
		defib = mainunit
		loc = defib
		update_icon(UPDATE_ICON_STATE)
		AddComponent(/datum/component/defib, actual_unit = defib, combat = defib.combat, safe_by_default = defib.safety, heart_attack_chance = defib.heart_attack_probability, emp_proof = defib.hardened, emag_proof = defib.emag_proof)
	else
		AddComponent(/datum/component/defib)
	RegisterSignal(src, COMSIG_DEFIB_READY, PROC_REF(on_cooldown_expire))
	RegisterSignal(src, COMSIG_DEFIB_SHOCK_APPLIED, PROC_REF(after_shock))
	RegisterSignal(src, COMSIG_DEFIB_PADDLES_APPLIED, PROC_REF(on_application))
	AddComponent(/datum/component/two_handed)

/obj/item/shockpaddles/Destroy()
	defib = null
	return ..()

/// Check to see if we should abort this before we've even gotten started
/obj/item/shockpaddles/proc/on_application(obj/item/paddles, mob/living/user, mob/living/carbon/human/target, should_cause_harm)
	SIGNAL_HANDLER  // COMSIG_DEFIB_PADDLES_APPLIED

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, "<span class='boldnotice'>You need to wield the paddles in both hands before you can use them on someone!</span>")
		return COMPONENT_BLOCK_DEFIB_MISC
	if(!defib.powered)
		return COMPONENT_BLOCK_DEFIB_DEAD

	return

/obj/item/shockpaddles/proc/on_cooldown_expire(obj/item/paddles)
	SIGNAL_HANDLER  // COMSIG_DEFIB_READY
	on_cooldown = FALSE
	if(defib.cell)
		if(defib.cell.charge >= revivecost)
			defib.visible_message("<span class='notice'>[defib] beeps: Unit ready.</span>")
			playsound(get_turf(src), 'sound/machines/defib_ready.ogg', 50, 0)
		else
			defib.visible_message("<span class='notice'>[defib] beeps: Charge depleted.</span>")
			playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
		update_icon(UPDATE_ICON_STATE)
	defib.update_icon(UPDATE_ICON_STATE)

/obj/item/shockpaddles/proc/after_shock()
	SIGNAL_HANDLER  // COMSIG_DEFIB_SHOCK_APPLIED
	on_cooldown = TRUE
	defib.deductcharge(revivecost)
	update_icon(UPDATE_ICON_STATE)

/obj/item/shockpaddles/update_icon_state()
	var/wielded = HAS_TRAIT(src, TRAIT_WIELDED)
	icon_state = "[base_icon_state][wielded]"
	item_state = "[base_icon_state][wielded]"
	if(on_cooldown)
		icon_state = "[base_icon_state][wielded]_cooldown"

/obj/item/shockpaddles/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is putting the live paddles on [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	defib.deductcharge(revivecost)
	playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
	return OXYLOSS

/obj/item/shockpaddles/dropped(mob/user)
	..()
	if(user)
		to_chat(user, "<span class='notice'>The paddles snap back into the main unit.</span>")
		defib.paddles_on_defib = TRUE
		loc = defib
		defib.update_icon(UPDATE_OVERLAYS)
		update_icon(UPDATE_ICON_STATE)

/obj/item/shockpaddles/on_mob_move(dir, mob/user)
	if(defib)
		var/turf/t = get_turf(defib)
		if(!t.Adjacent(user))
			defib.remove_paddles(user)

/obj/item/shockpaddles/proc/check_defib_exists(mainunit, mob/living/carbon/human/M, obj/O)
	if(!mainunit || !istype(mainunit, /obj/item/defibrillator))	//To avoid weird issues from admin spawns
		M?.unEquip(O)
		qdel(O)
		return FALSE
	else
		return TRUE

/obj/item/borg_defib
	name = "defibrillator paddles"
	desc = "A pair of paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"
	force = 0
	w_class = WEIGHT_CLASS_BULKY
	var/revivecost = 1000
	var/safety = TRUE
	flags = NODROP
	toolspeed = 1

/obj/item/borg_defib/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/defib, robotic = TRUE, safe_by_default = safety, emp_proof = TRUE)

	RegisterSignal(src, COMSIG_DEFIB_READY, PROC_REF(on_cooldown_expire))
	RegisterSignal(src, COMSIG_DEFIB_SHOCK_APPLIED, PROC_REF(after_shock))

/obj/item/borg_defib/proc/after_shock(obj/item/defib, mob/user)
	SIGNAL_HANDLER  // COMSIG_DEFIB_SHOCK_APPLIED
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		R.cell.use(revivecost)
	update_icon(UPDATE_ICON_STATE)

/obj/item/borg_defib/proc/on_cooldown_expire(obj/item/defib)
	SIGNAL_HANDLER  // COMSIG_DEFIB_READY
	visible_message("<span class='notice'>[src] beeps: Defibrillation unit ready.</span>")
	playsound(get_turf(src), 'sound/machines/defib_ready.ogg', 50, 0)
	update_icon(UPDATE_ICON_STATE)

/obj/item/shockpaddles/syndicate
	name = "combat defibrillator paddles"
	desc = "A pair of high-tech paddles with flat plasteel surfaces to revive deceased operatives (unless they exploded). They possess both the ability to penetrate armor and to deliver powerful or disabling shocks offensively."
	icon_state = "syndiepaddles0"
	item_state = "syndiepaddles0"
	base_icon_state = "syndiepaddles"

/obj/item/shockpaddles/advanced
	name = "advanced defibrillator paddles"
	desc = "A pair of high-tech paddles with flat plasteel surfaces that are used to deliver powerful electric shocks. They possess the ability to penetrate armor to deliver shock."
	icon_state = "ntpaddles0"
	item_state = "ntpaddles0"
	base_icon_state = "ntpaddles"
