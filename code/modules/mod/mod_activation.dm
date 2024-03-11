/// Creates a radial menu from which the user chooses parts of the suit to deploy/retract. Repeats until all parts are extended or retracted.
/obj/item/mod/control/proc/choose_deploy(mob/user)
	if(!length(mod_parts))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/obj/item/part as anything in mod_parts)
		display_names[part.name] = part.UID()
		var/image/part_image = image(icon = part.icon, icon_state = part.icon_state)
		if(part.loc != src)
			part_image.underlays += image(icon = 'icons/hud/radial.dmi', icon_state = "module_active")
		items += list(part.name = part_image)
	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE)
	if(!pick)
		return
	var/part_reference = display_names[pick]
	var/obj/item/part = locateUID(part_reference)
	if(!istype(part) || user.incapacitated())
		return
	if(active || activating)
		to_chat(user, "<span class='warning'>Deactivate the suit first!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	var/parts_to_check = mod_parts - part
	if(part.loc == src)
		deploy(user, part)
		on_mod_deployed(user)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc != src)
				continue
			choose_deploy(user)
			break
	else
		retract(user, part)
		on_mod_retracted(user)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc == src)
				continue
			choose_deploy(user)
			break

/// Quickly deploys all parts (or retracts if all are on the wearer)
/obj/item/mod/control/proc/quick_deploy(mob/user)
	if(active || activating)
		to_chat(user, "<span class='warning'>Deactivate the suit first!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	var/deploy = TRUE
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc == src)
			continue
		deploy = FALSE
		break
	for(var/obj/item/part as anything in mod_parts)
		if(deploy && part.loc == src)
			deploy(null, part, TRUE)
		else if(!deploy && part.loc != src)
			retract(null, part, TRUE)
	wearer.visible_message("<span class='notice'>[wearer]'s [src] [deploy ? "deploys" : "retracts"] its' parts with a mechanical hiss.</span>",
		"<span class='notice'>[src] [deploy ? "deploys" : "retracts"] its' parts with a mechanical hiss.</span>",
		"You hear a mechanical hiss.")
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(deploy)
		on_mod_deployed(user)
	else
		on_mod_retracted(user)
	return TRUE

/// Deploys a part of the suit onto the user.
/obj/item/mod/control/proc/deploy(mob/user, obj/item/part, mass = FALSE)
	if(part.loc != src)
		if(!user)
			return FALSE
		to_chat(user, "<span class='warning'>[part.name] already deployed!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	if(part in overslotting_parts)
		var/obj/item/overslot = wearer.get_item_by_slot(slot_bitfield_to_slot(part.slot_flags))
		if(overslot)
			wearer.unEquip(overslot, TRUE)
			overslotting_parts[part] = overslot
			overslot.forceMove(part)
			RegisterSignal(part, COMSIG_ATOM_EXITED, PROC_REF(on_overslot_exit))
	if(wearer.equip_to_slot_if_possible(part, slot_bitfield_to_slot(part.slot_flags), disable_warning = TRUE))
		part.flags |= NODROP
		if(mass)
			return TRUE
		wearer.visible_message("<span class='notice'>[wearer]'s [part.name] deploy[part.p_s()] with a mechanical hiss.</span>",
			"<span class='notice'>[part] deploy[part.p_s()] with a mechanical hiss.</span>",
			"You hear a mechanical hiss.")
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return TRUE
	else
		if(!user)
			return FALSE
		to_chat(user, "<span class='warning'>You already have clothing there!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/// Retract a part of the suit from the user.
/obj/item/mod/control/proc/retract(mob/user, obj/item/part, mass = FALSE)
	if(part.loc == src)
		if(!user)
			return FALSE
		to_chat(user, "<span class='warning'>You already have retracted there!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	part.flags &= ~NODROP
	wearer.unEquip(part, TRUE)
	part.forceMove(src)
	if(overslotting_parts[part])
		UnregisterSignal(part, COMSIG_ATOM_EXITED)
		var/obj/item/overslot = overslotting_parts[part]
		if(!wearer.equip_to_slot_if_possible(overslot, slot_bitfield_to_slot(overslot.slot_flags), disable_warning = TRUE))
			overslot.forceMove(get_turf(wearer))
		overslotting_parts[part] = null
	if(mass)
		return TRUE
	wearer.visible_message("<span class='notice'>[wearer]'s [part.name] retract[part.p_s()] back into [src] with a mechanical hiss.</span>",
		"<span class='notice'>[part] retract[part.p_s()] back into [src] with a mechanical hiss.</span>",
		"You hear a mechanical hiss.")
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/// Starts the activation sequence, where parts of the suit activate one by one until the whole suit is on
/obj/item/mod/control/proc/toggle_activate(mob/user, force_deactivate = FALSE)
	if(!wearer)
		if(!force_deactivate)
			to_chat(user, "<span class='warning'>Equip your suit first!</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!force_deactivate && (SEND_SIGNAL(src, COMSIG_MOD_ACTIVATE, user) & MOD_CANCEL_ACTIVATE))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	for(var/obj/item/part as anything in mod_parts)
		if(!force_deactivate && part.loc == src)
			to_chat(user, "<span class='warning'>Deploy all parts first!</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
	if(locked && !active && !allowed(user) && !force_deactivate)
		to_chat(user, "<span class='warning'>Insufficient access!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!get_charge() && !force_deactivate)
		to_chat(user, "<span class='warning'>Suit is not powered!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(open && !force_deactivate)
		to_chat(user, "<span class='warning'>Close the suit panel!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(activating)
		if(!force_deactivate)
			to_chat(user, "<span class='warning'>Suit is already [active ? "shutting down" : "starting up"]!</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	for(var/obj/item/mod/module/module as anything in modules)
		if(!module.active || (module.allow_flags & MODULE_ALLOW_INACTIVE))
			continue
		module.on_deactivation(display_message = FALSE)
	activating = TRUE
	to_chat(wearer, "<span class='notice'>MODsuit [active ? "shutting down" : "starting up"].</span>")
	if(do_after(wearer, activation_step_time, FALSE, target = src, allow_moving = TRUE, use_default_checks = FALSE))
		if(has_wearer())
			to_chat(wearer, "<span class='notice'>[boots] [active ? "relax their grip on your legs" : "seal around your feet"].</span>")
			playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			seal_part(boots, seal = !active)
	if(do_after(wearer, activation_step_time, FALSE, target = src, allow_moving = TRUE, use_default_checks = FALSE))
		if(has_wearer())
			to_chat(wearer, "<span class='notice'>[gauntlets] [active ? "become loose around your fingers" : "tighten around your fingers and wrists"].</span>")
			playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			seal_part(gauntlets, seal = !active)
	if(do_after(wearer, activation_step_time, FALSE, target = src, allow_moving = TRUE, use_default_checks = FALSE))
		if(has_wearer())
			to_chat(wearer, "<span class='notice'>[chestplate] [active ? "releases your chest" : "cinches tightly against your chest"].</span>")
			playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			seal_part(chestplate, seal = !active)
	if(do_after(wearer, activation_step_time, FALSE, target = src, allow_moving = TRUE, use_default_checks = FALSE))
		if(has_wearer())
			to_chat(wearer, "<span class='notice'>[helmet] hisses [active ? "open" : "closed"].</span>")
			playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			seal_part(helmet, seal = !active)
	if(do_after(wearer, activation_step_time, FALSE, target = src, allow_moving = TRUE, use_default_checks = FALSE))
		if(has_wearer())
			to_chat(wearer, "<span class='notice'>Systems [active ? "shut down. Parts unsealed. Goodbye" : "started up. Parts sealed. Welcome"], [wearer].</span>")
			finish_activation(on = !active)
			if(active)
				playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
				if(!malfunctioning)
					wearer.playsound_local(get_turf(src), 'sound/mecha/nominal.ogg', 50)
			else
				playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
	activating = FALSE
	SEND_SIGNAL(src, COMSIG_MOD_TOGGLED, user)
	return TRUE

///Seals or unseals the given part
/obj/item/mod/control/proc/seal_part(obj/item/clothing/part, seal)
	if(seal)
		part.icon_state = "[skin]-[part.base_icon_state]-sealed"
		part.flags |= part.visor_flags
		part.flags_inv |= part.visor_flags_inv
		part.flags_cover |= part.visor_flags_cover
		part.heat_protection = initial(part.heat_protection)
		part.cold_protection = initial(part.cold_protection)
	else
		part.icon_state = "[skin]-[part.base_icon_state]"
		part.flags_cover &= ~part.visor_flags_cover
		part.flags_inv &= ~part.visor_flags_inv
		part.flags &= ~part.visor_flags
		part.heat_protection = NONE
		part.cold_protection = NONE
	if(ishuman(wearer))
		var/mob/living/carbon/human/H = wearer
		H.regenerate_icons()

/// Finishes the suit's activation, starts processing
/obj/item/mod/control/proc/finish_activation(on)
	active = on
	if(active)
		for(var/obj/item/mod/module/module as anything in modules)
			module.on_suit_activation()
		START_PROCESSING(SSobj, src)
	else
		for(var/obj/item/mod/module/module as anything in modules)
			module.on_suit_deactivation()
		STOP_PROCESSING(SSobj, src)
	update_speed()
	update_icon_state()
	wearer.regenerate_icons()

/// Quickly deploys all the suit parts and if successful, seals them and turns on the suit. Intended mostly for outfits.
/obj/item/mod/control/proc/quick_activation()
	var/seal = TRUE
	for(var/obj/item/part as anything in mod_parts)
		if(!deploy(null, part))
			seal = FALSE
	if(!seal)
		return
	for(var/obj/item/part as anything in mod_parts)
		seal_part(part, seal = TRUE)
	finish_activation(on = TRUE)

/obj/item/mod/control/proc/has_wearer()
	return wearer

/obj/item/mod/control/proc/on_mod_deployed(mob/user)
	SEND_SIGNAL(src, COMSIG_MOD_DEPLOYED, user)

/obj/item/mod/control/proc/on_mod_retracted(mob/user)
	SEND_SIGNAL(src, COMSIG_MOD_RETRACTED, user)
