/// A multiple slot contains multiple type paths.
/datum/ert_loadout_slot/multiple
	var/list/chosen_items = list()

/datum/ert_loadout_slot/multiple/set_item(item_type)
	. = ..()
	chosen_items |= item_type

/datum/ert_loadout_slot/multiple/copy_into(datum/ert_loadout_slot/multiple/slot)
	slot.chosen_items = chosen_items.Copy()

/datum/ert_loadout_slot/multiple/apply_to_outfit(datum/outfit/outfit)
	if(length(chosen_items) && outfit_var)
		outfit.vars[outfit_var] = chosen_items.Copy()

/datum/ert_loadout_slot/multiple/apply_from_outfit(datum/outfit/outfit)
	if(outfit.vars[outfit_var])
		var/list/items = outfit.vars[outfit_var]
		chosen_items = items.Copy()
		for(var/item_type in chosen_items)
			register_item(item_type)

/datum/ert_loadout_slot/multiple/serialize()
	. = ..()
	.["chosen_items"] = list()

	for(var/item in chosen_items)
		.["chosen_items"] += item

/datum/ert_loadout_slot/multiple/deserialize(list/data)
	. = ..()
	for(var/item in data["chosen_items"])
		chosen_items += text2path(item)

/datum/ert_loadout_slot/multiple/ui_data(mob/user)
	. = ..()
	.["chosen_items"] = list()

	for(var/item in chosen_items)
		.["chosen_items"] += item

/datum/ert_loadout_slot/multiple/cybernetic_implant
	slot_name = "Cybernetic Implants"
	outfit_var = "cybernetic_implants"

/datum/ert_loadout_slot/multiple/bio_chip
	slot_name = "Bio-chips"
	outfit_var = "bio_chips"
