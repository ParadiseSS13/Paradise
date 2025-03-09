/datum/strippable_item/mob_item_slot/head
	key = STRIPPABLE_ITEM_HEAD
	item_slot = ITEM_SLOT_HEAD

/datum/strippable_item/mob_item_slot/back
	key = STRIPPABLE_ITEM_BACK
	item_slot = ITEM_SLOT_BACK

/datum/strippable_item/mob_item_slot/back/get_alternate_actions(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/back/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/mask
	key = STRIPPABLE_ITEM_MASK
	item_slot = ITEM_SLOT_MASK

/datum/strippable_item/mob_item_slot/mask/get_body_action(atom/source, mob/user)
	if(!ishuman(source))
		return
	var/mob/living/carbon/human/H = source
	var/obj/item/organ/internal/headpocket/pocket = H.get_int_organ(/obj/item/organ/internal/headpocket)
	if(istype(pocket) && pocket.held_item)
		return "dislodge_headpocket"

/datum/strippable_item/mob_item_slot/mask/get_alternate_actions(atom/source, mob/user)
	var/obj/item/clothing/mask/muzzle/muzzle = get_item(source)
	if(!istype(muzzle))
		return
	if(muzzle.security_lock)
		return "[muzzle.locked ? "dis" : "en"]able_lock"

/datum/strippable_item/mob_item_slot/mask/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return

	var/thief_mode = in_thief_mode(user)

	// Headpocket dislodging
	if(action_key == "dislodge_headpocket")
		var/mob/living/carbon/human/H = source
		var/obj/item/organ/internal/headpocket/pocket = H.get_int_organ(/obj/item/organ/internal/headpocket)
		if(!pocket.held_item)
			return
		if(!thief_mode)
			user.visible_message("<span class='danger'>[user] is trying to remove something from [source]'s head!</span>",
								"<span class='danger'>You start to dislodge whatever's inside [source]'s headpocket!</span>")
		if(do_mob(user, source, POCKET_STRIP_DELAY, hidden = thief_mode))
			if(!thief_mode)
				user.visible_message("<span class='danger'>[user] has dislodged something from [source]'s head!</span>",
									"<span class='danger'>You have dislodged everything from [source]'s headpocket!</span>")
			pocket.empty_contents()
			add_attack_logs(user, source, "Stripped of headpocket items", isLivingSSD(source) ? null : ATKLOG_ALL)
		return

	// Altering a muzzle
	if(action_key != "enable_lock" && action_key != "disable_lock")
		return
	var/obj/item/clothing/mask/muzzle/muzzle = get_item(source)
	if(!istype(muzzle))
		return
	if(!ishuman(user))
		to_chat(user, "You lack the ability to manipulate the lock.")
		return

	if(!thief_mode)
		muzzle.visible_message("<span class='danger'>[user] tries to [muzzle.locked ? "unlock" : "lock"] [source]'s [muzzle.name].</span>", \
						"<span class='userdanger'>[user] tries to [muzzle.locked ? "unlock" : "lock"] [source]'s [muzzle.name].</span>")
	if(!do_mob(user, source, POCKET_STRIP_DELAY, hidden = thief_mode))
		return

	var/success = FALSE
	if(muzzle.locked)
		success = muzzle.do_unlock(user)
	else
		success = muzzle.do_lock(user)

	if(!success)
		return
	if(!thief_mode)
		muzzle.visible_message("<span class='danger'>[user] [muzzle.locked ? "locks" : "unlocks"] [source]'s [muzzle.name].</span>", \
						"<span class='userdanger'>[user] [muzzle.locked ? "locks" : "unlocks"] [source]'s [muzzle.name].</span>")


/datum/strippable_item/mob_item_slot/neck
	key = STRIPPABLE_ITEM_NECK
	item_slot = ITEM_SLOT_NECK

/datum/strippable_item/mob_item_slot/handcuffs
	key = STRIPPABLE_ITEM_HANDCUFFS
	item_slot = ITEM_SLOT_HANDCUFFED

/datum/strippable_item/mob_item_slot/handcuffs/should_show(atom/source, mob/user)
	if(!iscarbon(source))
		return FALSE

	var/mob/living/carbon/carbon_source = source
	return !isnull(carbon_source.handcuffed)

// You shouldn't be able to equip things to handcuff slots.
/datum/strippable_item/mob_item_slot/handcuffs/try_equip(atom/source, obj/item/equipping, mob/user)
	return FALSE

/datum/strippable_item/mob_item_slot/legcuffs
	key = STRIPPABLE_ITEM_LEGCUFFS
	item_slot = ITEM_SLOT_LEGCUFFED

/datum/strippable_item/mob_item_slot/legcuffs/should_show(atom/source, mob/user)
	if(!iscarbon(source))
		return FALSE

	var/mob/living/carbon/carbon_source = source
	return !isnull(carbon_source.legcuffed)

// You shouldn't be able to equip things to legcuff slots.
/datum/strippable_item/mob_item_slot/legcuffs/try_equip(atom/source, obj/item/equipping, mob/user)
	return FALSE

/// A strippable item for a hand
/datum/strippable_item/hand

	/// Which hand?
	var/which_hand

/datum/strippable_item/hand/get_item(atom/source)
	if(!ismob(source))
		return null

	var/mob/mob_source = source
	return mob_source.get_item_by_slot(which_hand)

/datum/strippable_item/hand/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ismob(source))
		return FALSE

	var/mob/mob_source = source
	if(!equipping.mob_can_equip(mob_source, which_hand, TRUE))
		to_chat(user, "<span class='warning'>\The [equipping] doesn't fit in that place!</span>")
		return FALSE

	return TRUE

/datum/strippable_item/hand/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return

	if(!ismob(source))
		return FALSE

	var/mob/mob_source = source

	if(mob_source.get_item_by_slot(which_hand))
		return FALSE

	return TRUE

/datum/strippable_item/hand/finish_equip(atom/source, obj/item/equipping, mob/user)
	if(!iscarbon(source))
		return FALSE

	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob, put_in_hand), equipping, which_hand)

/datum/strippable_item/hand/finish_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	if(!ismob(source))
		return FALSE

	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(finish_unequip_mob), item, source, user)

/datum/strippable_item/hand/left
	key = STRIPPABLE_ITEM_LHAND
	which_hand = ITEM_SLOT_LEFT_HAND

/datum/strippable_item/hand/right
	key = STRIPPABLE_ITEM_RHAND
	which_hand = ITEM_SLOT_RIGHT_HAND
