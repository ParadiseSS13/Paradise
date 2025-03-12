#define INTERNALS_TOGGLE_DELAY (4 SECONDS)
#define POCKET_EQUIP_DELAY (1 SECONDS)

GLOBAL_LIST_INIT(strippable_human_items, create_strippable_list(list(
	/datum/strippable_item/mob_item_slot/head,
	/datum/strippable_item/mob_item_slot/back,
	/datum/strippable_item/mob_item_slot/mask,
	/datum/strippable_item/mob_item_slot/neck,
	/datum/strippable_item/mob_item_slot/eyes,
	/datum/strippable_item/mob_item_slot/left_ear,
	/datum/strippable_item/mob_item_slot/right_ear,
	/datum/strippable_item/mob_item_slot/jumpsuit,
	/datum/strippable_item/mob_item_slot/suit,
	/datum/strippable_item/mob_item_slot/gloves,
	/datum/strippable_item/mob_item_slot/feet,
	/datum/strippable_item/mob_item_slot/suit_storage,
	/datum/strippable_item/mob_item_slot/id,
	/datum/strippable_item/mob_item_slot/pda,
	/datum/strippable_item/mob_item_slot/belt,
	/datum/strippable_item/mob_item_slot/pocket/left,
	/datum/strippable_item/mob_item_slot/pocket/right,
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
	/datum/strippable_item/mob_item_slot/legcuffs,
)))

/datum/strippable_item/mob_item_slot/eyes
	key = STRIPPABLE_ITEM_EYES
	item_slot = ITEM_SLOT_EYES

/datum/strippable_item/mob_item_slot/jumpsuit
	key = STRIPPABLE_ITEM_JUMPSUIT
	item_slot = ITEM_SLOT_JUMPSUIT

/datum/strippable_item/mob_item_slot/jumpsuit/get_alternate_actions(atom/source, mob/user)
	var/list/multiple_options = list()
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if(!istype(jumpsuit))
		return null
	if(jumpsuit.has_sensor)
		multiple_options |= "suit_sensors"
	if(length(jumpsuit.accessories))
		multiple_options |= "remove_accessory"
	return multiple_options

/datum/strippable_item/mob_item_slot/jumpsuit/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if(!istype(jumpsuit))
		return
	if(action_key == "suit_sensors")
		jumpsuit.set_sensors(user)
		return

	if(action_key != "remove_accessory")
		return
	if(!length(jumpsuit.accessories))
		return
	var/obj/item/clothing/accessory/A = jumpsuit.accessories[1]
	var/thief_mode = in_thief_mode(user)
	if(!thief_mode)
		user.visible_message("<span class='danger'>[user] starts to take off [A] from [source]'s [jumpsuit]!</span>", \
							"<span class='danger'>You start to take off [A] from [source]'s [jumpsuit]!</span>")

	if(!do_mob(user, source, POCKET_STRIP_DELAY, hidden = thief_mode))
		return
	if(QDELETED(A) || !(A in jumpsuit.accessories))
		return

	if(!thief_mode)
		user.visible_message("<span class='danger'>[user] takes [A] off of [source]'s [jumpsuit]!</span>", \
							"<span class='danger'>You take [A] off of [source]'s [jumpsuit]!</span>")
	jumpsuit.detach_accessory(A, user)

/datum/strippable_item/mob_item_slot/left_ear
	key = STRIPPABLE_ITEM_L_EAR
	item_slot = ITEM_SLOT_LEFT_EAR

/datum/strippable_item/mob_item_slot/right_ear
	key = STRIPPABLE_ITEM_R_EAR
	item_slot = ITEM_SLOT_RIGHT_EAR

/datum/strippable_item/mob_item_slot/suit
	key = STRIPPABLE_ITEM_SUIT
	item_slot = ITEM_SLOT_OUTER_SUIT

/datum/strippable_item/mob_item_slot/gloves
	key = STRIPPABLE_ITEM_GLOVES
	item_slot = ITEM_SLOT_GLOVES

/datum/strippable_item/mob_item_slot/feet
	key = STRIPPABLE_ITEM_FEET
	item_slot = ITEM_SLOT_SHOES

/datum/strippable_item/mob_item_slot/suit_storage
	key = STRIPPABLE_ITEM_SUIT_STORAGE
	item_slot = ITEM_SLOT_SUIT_STORE

/datum/strippable_item/mob_item_slot/suit_storage/get_alternate_actions(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/suit_storage/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/id
	key = STRIPPABLE_ITEM_ID
	item_slot = ITEM_SLOT_ID

/datum/strippable_item/mob_item_slot/pda
	key = STRIPPABLE_ITEM_PDA
	item_slot = ITEM_SLOT_PDA

/datum/strippable_item/mob_item_slot/pda/get_obscuring(atom/source)
	return isnull(get_item(source)) \
		? STRIPPABLE_OBSCURING_NONE \
		: STRIPPABLE_OBSCURING_HIDDEN

/datum/strippable_item/mob_item_slot/belt
	key = STRIPPABLE_ITEM_BELT
	item_slot = ITEM_SLOT_BELT

/datum/strippable_item/mob_item_slot/belt/get_alternate_actions(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/belt/alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/pocket
	/// Which pocket we're referencing. Used for visible text.
	var/pocket_side

/datum/strippable_item/mob_item_slot/pocket/get_obscuring(atom/source)
	return isnull(get_item(source)) \
		? STRIPPABLE_OBSCURING_NONE \
		: STRIPPABLE_OBSCURING_HIDDEN

/datum/strippable_item/mob_item_slot/pocket/get_equip_delay(obj/item/equipping)
	return POCKET_EQUIP_DELAY // Equipping is 4 times as fast as stripping

/datum/strippable_item/mob_item_slot/pocket/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!. && !in_thief_mode(user))
		warn_owner(source)

/datum/strippable_item/mob_item_slot/pocket/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	to_chat(user, "<span class='notice'>You try to empty [source]'s [pocket_side] pocket.</span>")

	add_attack_logs(user, source, "Attempting pickpocketing of [item]")
	item.add_fingerprint(user)

	var/thief_mode = in_thief_mode(user)
	var/result = start_unequip_mob(item, source, user, POCKET_STRIP_DELAY, thief_mode)

	if(!result && !thief_mode)
		warn_owner(source)

	return result

/datum/strippable_item/mob_item_slot/pocket/proc/warn_owner(atom/owner)
	to_chat(owner, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")

/datum/strippable_item/mob_item_slot/pocket/left
	key = STRIPPABLE_ITEM_LPOCKET
	item_slot = ITEM_SLOT_LEFT_POCKET
	pocket_side = "left"

/datum/strippable_item/mob_item_slot/pocket/right
	key = STRIPPABLE_ITEM_RPOCKET
	item_slot = ITEM_SLOT_RIGHT_POCKET
	pocket_side = "right"

/proc/get_strippable_alternate_action_internals(obj/item/item, atom/source)
	if(!iscarbon(source))
		return

	var/mob/living/carbon/carbon_source = source
	if(carbon_source.can_breathe_internals() && istype(item, /obj/item/tank))
		if(carbon_source.internal != item)
			return "enable_internals"
		else
			return "disable_internals"

/proc/strippable_alternate_action_internals(obj/item/item, atom/source, mob/user)
	var/obj/item/tank/tank = item
	if(!istype(tank))
		return

	var/mob/living/carbon/carbon_source = source
	if(!istype(carbon_source))
		return

	if(!carbon_source.can_breathe_internals())
		return

	carbon_source.visible_message(
		"<span class='danger'>[user] tries to [(carbon_source.internal != item) ? "open" : "close"] the valve on [source]'s [item.name].</span>",
		"<span class='userdanger'>[user] tries to [(carbon_source.internal != item) ? "open" : "close"] the valve on your [item.name].</span>",
	)

	if(!do_mob(user, carbon_source, INTERNALS_TOGGLE_DELAY))
		return

	if(carbon_source.internal == item)
		carbon_source.internal = null
	else if(!QDELETED(item))
		carbon_source.internal = item

	carbon_source.update_action_buttons_icon()

	carbon_source.visible_message(
		"<span class='danger'>[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on [source]'s [item.name].</span>",
		"<span class='userdanger'>[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on your [item.name].</span>",
	)


#undef INTERNALS_TOGGLE_DELAY
#undef POCKET_EQUIP_DELAY
