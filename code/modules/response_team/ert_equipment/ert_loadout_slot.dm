/proc/get_loadout_item_name(item_path)
	if(ispath(item_path, /obj/item/mod/control/pre_equipped))
		// give modsuits with the same core a different name by taking
		// the leaf of their type path
		var/obj/item/mod/control/pre_equipped/item_type = item_path
		var/leaf = copytext("[item_path]", (findlasttext("[item_path]", "/") + 1))
		var/datum/mod_theme/theme = item_type::theme
		return "MOD [theme::name] suit ([leaf])"
	if(ispath(item_path, /obj/item/pda))
		var/leaf = copytext("[item_path]", (findlasttext("[item_path]", "/") + 1))
		return "PDA ([leaf])"
	if(ispath(item_path, /obj/item/card/id))
		var/leaf = copytext("[item_path]", (findlasttext("[item_path]", "/") + 1))
		return "ID ([leaf])"

	var/obj/item_type = item_path
	return item_type::name

/datum/ert_loadout_slot
	/// The human-readable name of the slot.
	var/slot_name
	/// Which pool of items this slot fills its dropdowns from.
	var/item_pool
	/// Name of the var on the [/datum/ert_loadout] this slot refers to.
	/// Used to make things polymorphic without needing separate explicit
	/// vars for one of each of 20 slot types.
	var/outfit_var

/datum/ert_loadout_slot/New()
	. = ..()

	if(isnull(item_pool))
		item_pool = type

/datum/ert_loadout_slot/proc/allowed_items()
	return GLOB.ert_loadout_item_pools[item_pool]

/datum/ert_loadout_slot/proc/register_item(item_type)
	if(isnull(item_type))
		return

	LAZYOR(GLOB.ert_loadout_item_pools[item_pool], item_type)

/datum/ert_loadout_slot/proc/set_item(item_type)
	SHOULD_CALL_PARENT(TRUE)
	register_item(item_type)
	return

/// Take this loadout slot and apply the item(s) in it to the instance of the outfit passed in.
/datum/ert_loadout_slot/proc/apply_to_outfit(datum/outfit/outfit)
	return

/// Take the slot from the passed in outfit and apply the item(s) in it to this loadout slot.
/datum/ert_loadout_slot/proc/apply_from_outfit(datum/outfit/outfit)
	return

/// Take the item(s) from this loadout slot and copy them over to the passed in loadout slot.
/datum/ert_loadout_slot/proc/copy_into(datum/ert_loadout_slot/slot)
	return

/datum/ert_loadout_slot/ui_data(mob/user)
	. = list()
	.["name"] = slot_name
	.["slot_type"] = type
	.["uid"] = UID()
