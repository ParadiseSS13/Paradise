#define SHOW_MINIATURE_MENU 0
#define SHOW_FULLSIZE_MENU 1
/// An element for atoms that, when dragged and dropped onto a mob, opens a strip panel.
/datum/element/strippable
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2

	/// An assoc list of keys to /datum/strippable_item
	var/list/items

	/// An existing strip menus
	var/list/strip_menus

/datum/element/strippable/Attach(datum/target, list/items = list())
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	// TODO: override = TRUE because strippable can get reattached to dead mobs after
	// revival. Will fix for basic mobs probably maybe.
	RegisterSignal(target, COMSIG_DO_MOB_STRIP, PROC_REF(mouse_drop_onto), override = TRUE)

	src.items = items

/datum/element/strippable/Detach(datum/source)
	. = ..()

	UnregisterSignal(source, COMSIG_DO_MOB_STRIP)

	if(!isnull(strip_menus))
		qdel(strip_menus[source])
		strip_menus -= source

/datum/element/strippable/proc/mouse_drop_onto(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER

	if(user == source)
		return

	if(over != user)
		return

	var/datum/strip_menu/strip_menu = LAZYACCESS(strip_menus, source)

	if(isnull(strip_menu))
		strip_menu = new(source, src)
		LAZYSET(strip_menus, source, strip_menu)

	INVOKE_ASYNC(strip_menu, TYPE_PROC_REF(/datum, ui_interact), user)

/// A representation of an item that can be stripped down
/datum/strippable_item
	/// The STRIPPABLE_ITEM_* key
	var/key


/// Gets the item from the given source.
/datum/strippable_item/proc/get_item(atom/source)
	return

/// Tries to equip the item onto the given source.
/// Returns TRUE/FALSE depending on if it is allowed.
/// This should be used for checking if an item CAN be equipped.
/// It should not perform the equipping itself.
/datum/strippable_item/proc/try_equip(atom/source, obj/item/equipping, mob/user)
	if(equipping.flags & NODROP)
		to_chat(user, "<span class='warning'>You can't put [equipping] on [source], it's stuck to your hand!</span>")
		return FALSE

	if(equipping.flags & ABSTRACT)
		return FALSE //I don't know a sane-sounding feedback message for trying to put a slap into someone's hand

	return TRUE

/// Start the equipping process. This is the proc you should yield in.
/// Returns TRUE/FALSE depending on if it is allowed.
/datum/strippable_item/proc/start_equip(atom/source, obj/item/equipping, mob/user)
	var/thief_mode = in_thief_mode(user)
	if(!thief_mode)
		source.visible_message(
			"<span class='notice'>[user] tries to put [equipping] on [source].</span>",
			"<span class='notice'>[user] tries to put [equipping] on you.</span>",
		)
		if(ishuman(source))
			var/mob/living/carbon/human/victim_human = source
			if(!victim_human.has_vision())
				to_chat(victim_human, "<span class='userdanger'>You feel someone trying to put something on you.</span>")

	if(!do_mob(user, source, equipping.put_on_delay, hidden = thief_mode))
		return FALSE

	if(QDELETED(equipping) || !user.Adjacent(source) || (equipping.flags & NODROP))
		return FALSE

	return TRUE

/// The proc that places the item on the source. This should not yield.
/datum/strippable_item/proc/finish_equip(atom/source, obj/item/equipping, mob/user)
	SHOULD_NOT_SLEEP(TRUE)
	return

/// Tries to unequip the item from the given source.
/// Returns TRUE/FALSE depending on if it is allowed.
/// This should be used for checking if it CAN be unequipped.
/// It should not perform the unequipping itself.
/datum/strippable_item/proc/try_unequip(atom/source, mob/user)
	SHOULD_NOT_SLEEP(TRUE)

	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	if(ismob(source))
		var/mob/mob_source = source
		if(!item.canStrip(user, mob_source))
			return FALSE

	return TRUE

/// Start the unequipping process. This is the proc you should yield in.
/// Returns TRUE/FALSE depending on if it is allowed.
/datum/strippable_item/proc/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	to_chat(user, "<span class='danger'>You try to remove [source]'s [item.name]...</span>")
	add_attack_logs(user, source, "Attempting stripping of [item]")
	item.add_fingerprint(user)

	var/thief_mode = in_thief_mode(user)
	if(!thief_mode)
		source.visible_message(
			"<span class='warning'>[user] tries to remove [source]'s [item.name].</span>",
			"<span class='userdanger'>[user] tries to remove your [item.name].</span>",
			"You hear rustling."
		)
		if(ishuman(source))
			var/mob/living/carbon/human/victim_human = source
			if(!victim_human.has_vision())
				to_chat(source, "<span class='userdanger'>You feel someone fumble with your belongings.</span>")

	return start_unequip_mob(get_item(source), source, user, hidden = thief_mode)

/// The proc that unequips the item from the source. This should not yield.
/datum/strippable_item/proc/finish_unequip(atom/source, mob/user)
	SHOULD_NOT_SLEEP(TRUE)
	return

/// Returns a STRIPPABLE_OBSCURING_* define to report on whether or not this is obscured.
/datum/strippable_item/proc/get_obscuring(atom/source)
	SHOULD_NOT_SLEEP(TRUE)
	return STRIPPABLE_OBSCURING_NONE

/// Returns the ID of this item's strippable action.
/// Return `null` if there is no alternate action.
/// Any return value of this must be in StripMenu.
/datum/strippable_item/proc/get_alternate_actions(atom/source, mob/user)
	return null

/**
 * Actions that can happen to that body part, regardless if there is an item or not. As long as it is not obscured
 */
/datum/strippable_item/proc/get_body_action(atom/source, mob/user)
	return

/// Performs an alternative action on this strippable_item.
/// `has_alternate_action` needs to be TRUE.
/// Returns FALSE if blocked by signal, TRUE otherwise.
/datum/strippable_item/proc/alternate_action(atom/source, mob/user, action_key)
	SHOULD_CALL_PARENT(TRUE)
	return TRUE

/// Returns whether or not this item should show.
/datum/strippable_item/proc/should_show(atom/source, mob/user)
	return TRUE

/// Returns whether the user is in "thief mode" where stripping/equipping is silent and stealing from pockets moves stuff to your hands
/datum/strippable_item/proc/in_thief_mode(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = usr
	var/obj/item/clothing/gloves/G = H.gloves
	return G?.pickpocket

/// A preset for equipping items onto mob slots
/datum/strippable_item/mob_item_slot
	/// The ITEM_SLOT_* to equip to.
	var/item_slot

/datum/strippable_item/mob_item_slot/get_item(atom/source)
	if(!ismob(source))
		return null

	var/mob/mob_source = source
	return mob_source.get_item_by_slot(item_slot)

/datum/strippable_item/mob_item_slot/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return

	if(!ismob(source))
		return FALSE

	if(!equipping.mob_can_equip(source, item_slot, disable_warning = TRUE))
		to_chat(user, "<span class='warning'>\The [equipping] doesn't fit in that place!</span>")
		return FALSE

	return TRUE

/datum/strippable_item/mob_item_slot/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return

	if(!ismob(source))
		return FALSE

	if(!equipping.mob_can_equip(source, item_slot, disable_warning = TRUE))
		return FALSE

	return TRUE

/datum/strippable_item/mob_item_slot/finish_equip(atom/source, obj/item/equipping, mob/user)
	if(!ismob(source))
		return FALSE

	var/mob/mob_source = source
	mob_source.equip_to_slot(equipping, item_slot)

	add_attack_logs(user, source, "Strip equipped [equipping]")

/datum/strippable_item/mob_item_slot/get_obscuring(atom/source)
	if(ishuman(source))
		var/mob/living/carbon/human/human_source = source
		if(item_slot & human_source.check_obscured_slots())
			return STRIPPABLE_OBSCURING_COMPLETELY
		return STRIPPABLE_OBSCURING_NONE

	return FALSE

/datum/strippable_item/mob_item_slot/finish_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	if(!ismob(source))
		return FALSE

	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(finish_unequip_mob), item, source, user)
	if(in_thief_mode(user))
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), item)

/// Returns the delay of equipping this item to a mob
/datum/strippable_item/mob_item_slot/proc/get_equip_delay(obj/item/equipping)
	return equipping.put_on_delay

/// A utility function for `/datum/strippable_item`s to start unequipping an item from a mob.
/proc/start_unequip_mob(obj/item/item, mob/source, mob/user, strip_delay, hidden = FALSE)
	if(!strip_delay)
		strip_delay = item.strip_delay
	if(!do_mob(user, source, strip_delay, hidden = hidden))
		return FALSE

	return TRUE

/// A utility function for `/datum/strippable_item`s to finish unequipping an item from a mob.
/proc/finish_unequip_mob(obj/item/item, mob/source, mob/user)
	if(!source.drop_item_to_ground(item))
		return

	add_attack_logs(user, source, "Stripping of [item]")

/// A representation of the stripping UI
/datum/strip_menu
	/// The owner who has the element /datum/element/strippable
	var/atom/movable/owner

	/// The strippable element itself
	var/datum/element/strippable/strippable

	/// A lazy list of user mobs to a list of strip menu keys that they're interacting with
	var/list/interactions

	/// Associated list of "[icon][icon_state]" = base64 representation of icon. Used for PERFORMANCE.
	var/static/list/base64_cache = list()

/datum/strip_menu/New(atom/movable/owner, datum/element/strippable/strippable)
	. = ..()
	src.owner = owner
	src.strippable = strippable

/datum/strip_menu/Destroy()
	owner = null
	strippable = null

	return ..()

/datum/strip_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StripMenu")
		ui.open()

/datum/strip_menu/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/inventory),
	)

/datum/strip_menu/ui_data(mob/user)
	var/list/data = list()

	var/list/items = list()

	var/list/unfiltered_items = strippable.items.Copy()
	SEND_SIGNAL(owner, COMSIG_STRIPPABLE_REQUEST_ITEMS, unfiltered_items)

	for(var/strippable_key in unfiltered_items)
		var/datum/strippable_item/item_data = unfiltered_items[strippable_key]

		if(!item_data.should_show(owner, user))
			continue

		var/list/result

		var/obj/item/item = item_data.get_item(owner)
		if(item && (item.flags & ABSTRACT || HAS_TRAIT(item, TRAIT_NO_STRIP)))
			items[strippable_key] = result
			continue

		if(strippable_key in LAZYACCESS(interactions, user))
			LAZYSET(result, "interacting", TRUE)

		var/obscuring = item_data.get_obscuring(owner)
		if(obscuring == STRIPPABLE_OBSCURING_COMPLETELY || (item && !item.canStrip(user)))
			LAZYSET(result, "cantstrip", TRUE)

		if(obscuring != STRIPPABLE_OBSCURING_NONE)
			LAZYSET(result, "obscured", obscuring)
			items[strippable_key] = result
			continue

		var/alternates = item_data.get_body_action(owner, user)
		if(!islist(alternates) && !isnull(alternates))
			alternates = list(alternates)

		if(isnull(item))
			if(length(alternates))
				LAZYSET(result, "alternates", alternates)
			items[strippable_key] = result
			continue

		LAZYINITLIST(result)

		var/key = "[item.icon],[item.icon_state]"
		if(!(key in base64_cache))
			base64_cache[key] = icon2base64(icon(item.icon, item.icon_state, dir = SOUTH, frame = 1, moving = FALSE))
		result["icon"] = base64_cache[key]
		result["name"] = item.name

		var/real_alts = item_data.get_alternate_actions(owner, user)
		if(!isnull(real_alts))
			if(islist(alternates))
				alternates += real_alts
			else
				alternates = real_alts
				if(!islist(alternates) && !isnull(alternates))
					alternates = list(alternates)
		result["alternates"] = alternates

		items[strippable_key] = result

	data["items"] = items

	// While most `\the`s are implicit, this one is not.
	// In this case, `\The` would otherwise be used.
	// This doesn't match with what it's used for, which is to say "Stripping the alien drone",
	// as opposed to "Stripping The alien drone".
	// Human names will still show without "the", as they are proper nouns.
	data["name"] = "\the [owner]"
	data["show_mode"] = user.client.prefs.toggles2 & PREFTOGGLE_2_BIG_STRIP_MENU ? SHOW_FULLSIZE_MENU : SHOW_MINIATURE_MENU

	return data

/datum/strip_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/user = ui.user
	if(!isliving(ui.user) || !HAS_TRAIT(user, TRAIT_CAN_STRIP))
		return

	var/list/unfiltered_items = strippable.items.Copy()
	SEND_SIGNAL(owner, COMSIG_STRIPPABLE_REQUEST_ITEMS, unfiltered_items)

	. = TRUE
	switch(action)
		if("use")
			var/key = params["key"]
			var/datum/strippable_item/strippable_item = unfiltered_items[key]

			if(isnull(strippable_item))
				return

			if(!strippable_item.should_show(owner, user))
				return

			if(strippable_item.get_obscuring(owner) == STRIPPABLE_OBSCURING_COMPLETELY)
				return

			var/item = strippable_item.get_item(owner)
			if(isnull(item))
				var/obj/item/held_item = user.get_active_hand()
				if(isnull(held_item))
					return

				if(strippable_item.try_equip(owner, held_item, user))
					LAZYORASSOCLIST(interactions, user, key)

					// Update just before the delay starts
					SStgui.update_uis(src)
					// Yielding call
					var/should_finish = strippable_item.start_equip(owner, held_item, user)

					LAZYREMOVEASSOC(interactions, user, key)

					if(!should_finish)
						return

					if(QDELETED(src) || QDELETED(owner))
						return

					// They equipped an item in the meantime, or they're no longer adjacent
					if(!isnull(strippable_item.get_item(owner)) || !user.Adjacent(owner))
						return

					// make sure to drop the item
					if(!user.drop_item_to_ground(held_item))
						return

					strippable_item.finish_equip(owner, held_item, user)
			else if(strippable_item.try_unequip(owner, user))
				LAZYORASSOCLIST(interactions, user, key)

				// Update just before the delay starts
				SStgui.update_uis(src)
				var/should_unequip = strippable_item.start_unequip(owner, user)

				LAZYREMOVEASSOC(interactions, user, key)

				// Yielding call
				if(!should_unequip)
					return

				if(QDELETED(src) || QDELETED(owner))
					return

				// They changed the item in the meantime
				if(strippable_item.get_item(owner) != item)
					return

				if(!user.Adjacent(owner))
					return

				strippable_item.finish_unequip(owner, user)
		if("alt")
			var/key = params["key"]
			var/datum/strippable_item/strippable_item = unfiltered_items[key]

			if(isnull(strippable_item))
				return

			if(!strippable_item.should_show(owner, user))
				return

			if(strippable_item.get_obscuring(owner) == STRIPPABLE_OBSCURING_COMPLETELY)
				return

			if(isnull(strippable_item.get_body_action(owner, user)))
				var/item = strippable_item.get_item(owner)
				if(isnull(item) || isnull(strippable_item.get_alternate_actions(owner, user)))
					return

			LAZYORASSOCLIST(interactions, user, key)

			// Update just before the delay starts
			SStgui.update_uis(src)
			// Potentially yielding
			strippable_item.alternate_action(owner, user, params["action_key"])

			LAZYREMOVEASSOC(interactions, user, key)

/datum/strip_menu/ui_host(mob/user)
	return owner

/datum/strip_menu/ui_state(mob/user)
	return GLOB.strippable_state

/// Creates an assoc list of keys to /datum/strippable_item
/proc/create_strippable_list(types)
	var/list/strippable_items = list()

	for(var/strippable_type in types)
		var/datum/strippable_item/strippable_item = new strippable_type
		strippable_items[strippable_item.key] = strippable_item

	return strippable_items

#undef SHOW_MINIATURE_MENU
#undef SHOW_FULLSIZE_MENU
