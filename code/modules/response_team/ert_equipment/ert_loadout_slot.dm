/proc/get_loadout_item_name(item_path)
	if(ispath(item_path, /obj/item/mod/control/pre_equipped))
		// give modsuits with the same core a different name by taking
		// the leaf of their type path
		var/obj/item/mod/control/pre_equipped/item_type = item_path
		var/leaf = copytext("[item_path]", (findlasttext("[item_path]", "/") + 1))
		var/datum/mod_theme/theme = item_type::theme
		return "MOD [theme::name] suit ([leaf])"

	var/obj/item_type = item_path
	return item_type::name

/datum/ert_loadout_slot
	/// The human-readable name of the slot.
	var/slot_name
	/// Which pool of items this slot fills its dropdowns from.
	var/item_pool

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

/datum/ert_loadout_slot/ui_data(mob/user)
	. = list()
	.["name"] = slot_name
	.["slot_type"] = type
	.["uid"] = UID()

/datum/ert_loadout_slot/single
	var/chosen_item

/datum/ert_loadout_slot/single/allowed_items()
	. = ..()

	if(chosen_item)
		. |= chosen_item

/datum/ert_loadout_slot/single/set_item(item_type)
	. = ..()
	chosen_item = item_type

/datum/ert_loadout_slot/single/ui_data(mob/user)
	. = ..()
	.["chosen_item"] = chosen_item

// yes these appear similar to ui_data, but they are not
// and it's better to keep the wire format and UI format separate
/datum/ert_loadout_slot/single/serialize()
	. = ..()
	.["chosen_item"] = chosen_item

/datum/ert_loadout_slot/single/firearm

/datum/ert_loadout_slot/single/firearm/primary
	slot_name = "Primary firearm"
	item_pool = /datum/ert_loadout_slot/single/firearm

/datum/ert_loadout_slot/single/firearm/secondary
	slot_name = "Secondary firearm"
	item_pool = /datum/ert_loadout_slot/single/firearm

/datum/ert_loadout_slot/multiple
	var/list/chosen_items = list()

/datum/ert_loadout_slot/multiple/set_item(item_type)
	. = ..()
	chosen_items |= item_type

/datum/ert_loadout_slot/multiple/serialize()
	. = ..()
	.["chosen_items"] = list()

	for(var/item in chosen_items)
		.["chosen_items"] += item

/datum/ert_loadout_slot/multiple/ui_data(mob/user)
	. = ..()
	.["chosen_items"] = list()

	for(var/item in chosen_items)
		.["chosen_items"] += item

/datum/ert_loadout_slot/multiple/cybernetic_implant
	slot_name = "Cybernetic Implants"

/datum/ert_loadout_slot/multiple/bio_chip
	slot_name = "Bio-chips"

/datum/ert_loadout_slot/assorted
	var/list/chosen_item_quantities = list()

/datum/ert_loadout_slot/assorted/set_item(item_type)
	. = ..()
	if(item_type in chosen_item_quantities)
		chosen_item_quantities[item_type]++
	else
		chosen_item_quantities[item_type] = 1

/datum/ert_loadout_slot/assorted/serialize()
	. = ..()
	.["chosen_item_quantities"] = list()

	for(var/item in chosen_item_quantities)
		.["chosen_item_quantities"][item] = chosen_item_quantities[item]

/datum/ert_loadout_slot/assorted/ui_data(mob/user)
	. = ..()
	.["chosen_item_quantities"] = list()
	.["chosen_item_names"] = list()

	for(var/item in chosen_item_quantities)
		.["chosen_item_quantities"][item] = chosen_item_quantities[item]
		.["chosen_item_names"][item] = get_loadout_item_name(item)

/datum/ert_loadout_slot/assorted/backpack_contents
	slot_name = "Backpack Contents"

/datum/ert_loadout_slot/assorted/backpack_contents/allowed_items()
	. = ..()
	. |= ert_all_discovered_items()

/datum/ert_loadout_slot/single/head
	slot_name = "Head"

/datum/ert_loadout_slot/single/shoes
	slot_name = "Shoes"

/datum/ert_loadout_slot/single/belt
	slot_name = "Belt"

/datum/ert_loadout_slot/single/back
	slot_name = "Back"

/datum/ert_loadout_slot/single/glasses
	slot_name = "Glasses"

/datum/ert_loadout_slot/single/mask
	slot_name = "Mask"

/datum/ert_loadout_slot/single/l_pocket
	slot_name = "Left Pocket"

/datum/ert_loadout_slot/single/l_pocket/allowed_items()
	. = ..()
	. |= ert_all_discovered_items()

/datum/ert_loadout_slot/single/r_pocket
	slot_name = "Right Pocket"

/datum/ert_loadout_slot/single/r_pocket/allowed_items()
	. = ..()
	. |= ert_all_discovered_items()

/datum/ert_loadout_slot/single/neck
	slot_name = "Neck"
