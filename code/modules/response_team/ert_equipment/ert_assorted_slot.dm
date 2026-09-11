/// An assorted slot containes a mapping of item paths -> amounts of that item.
/datum/ert_loadout_slot/assorted
	var/list/chosen_item_quantities = list()

/datum/ert_loadout_slot/assorted/set_item(item_type)
	. = ..()
	if(item_type in chosen_item_quantities)
		chosen_item_quantities[item_type]++
	else
		chosen_item_quantities[item_type] = 1

/datum/ert_loadout_slot/assorted/proc/decrement_item(item_type)
	chosen_item_quantities[item_type]--
	if(chosen_item_quantities[item_type] <= 0)
		chosen_item_quantities.Remove(item_type)

/datum/ert_loadout_slot/assorted/apply_to_outfit(datum/outfit/outfit)
	if(length(chosen_item_quantities) && outfit_var)
		outfit.vars[outfit_var] = chosen_item_quantities.Copy()

/datum/ert_loadout_slot/assorted/apply_from_outfit(datum/outfit/outfit)
	if(outfit.vars[outfit_var])
		var/list/items = outfit.vars[outfit_var]
		chosen_item_quantities = items.Copy()
		for(var/item_type in chosen_item_quantities)
			register_item(item_type)

/datum/ert_loadout_slot/assorted/copy_into(datum/ert_loadout_slot/assorted/slot)
	slot.chosen_item_quantities = chosen_item_quantities.Copy()

/datum/ert_loadout_slot/assorted/serialize()
	. = ..()
	.["chosen_item_quantities"] = list()

	for(var/item in chosen_item_quantities)
		.["chosen_item_quantities"][item] = chosen_item_quantities[item]

/datum/ert_loadout_slot/assorted/deserialize(list/data)
	. = ..()

	for(var/item in data["chosen_item_quantities"])
		chosen_item_quantities[text2path(item)] = data["chosen_item_quantities"][item]

/datum/ert_loadout_slot/assorted/ui_data(mob/user)
	. = ..()
	.["chosen_item_quantities"] = list()
	.["chosen_item_names"] = list()

	for(var/item in chosen_item_quantities)
		.["chosen_item_quantities"][item] = chosen_item_quantities[item]
		.["chosen_item_names"][item] = get_loadout_item_name(item)

/datum/ert_loadout_slot/assorted/backpack_contents
	slot_name = "Backpack Contents"
	outfit_var = "backpack_contents"

/datum/ert_loadout_slot/assorted/backpack_contents/allowed_items()
	. = ..()
	. |= ert_all_discovered_items()
