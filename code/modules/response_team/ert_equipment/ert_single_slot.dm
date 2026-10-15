/datum/ert_loadout_slot/single
	var/chosen_item

/datum/ert_loadout_slot/single/allowed_items()
	. = ..()

	if(chosen_item)
		. |= chosen_item

/datum/ert_loadout_slot/single/apply_to_outfit(datum/outfit/outfit)
	if(chosen_item && outfit_var)
		outfit.vars[outfit_var] = chosen_item

/datum/ert_loadout_slot/single/apply_from_outfit(datum/outfit/outfit)
	var/item_type = outfit.vars[outfit_var]
	if(ispath(item_type))
		chosen_item = item_type
		register_item(item_type)

/datum/ert_loadout_slot/single/copy_into(datum/ert_loadout_slot/single/slot)
	slot.chosen_item = chosen_item

/datum/ert_loadout_slot/single/set_item(item_type)
	. = ..()
	chosen_item = item_type

/datum/ert_loadout_slot/single/ui_data(mob/user)
	. = ..()
	.["chosen_item"] = chosen_item

/datum/ert_loadout_slot/single/serialize()
	. = ..()
	.["chosen_item"] = chosen_item

/datum/ert_loadout_slot/single/deserialize(list/data)
	. = ..()
	chosen_item = text2path(data["chosen_item"])

/datum/ert_loadout_slot/single/firearm

/datum/ert_loadout_slot/single/firearm/primary
	slot_name = "Primary firearm"
	item_pool = /datum/ert_loadout_slot/single/firearm
	outfit_var = "l_hand"

/datum/ert_loadout_slot/single/firearm/secondary
	slot_name = "Secondary firearm"
	item_pool = /datum/ert_loadout_slot/single/firearm
	outfit_var = "r_hand"

/datum/ert_loadout_slot/single/head
	slot_name = "Head"
	outfit_var = "head"


/datum/ert_loadout_slot/single/uniform
	slot_name = "Uniform"
	outfit_var = "uniform"

/datum/ert_loadout_slot/single/suit
	slot_name = "Suit"
	outfit_var = "suit"

/datum/ert_loadout_slot/single/gloves
	slot_name = "Gloves"
	outfit_var = "gloves"

/datum/ert_loadout_slot/single/l_ear
	slot_name = "Left Ear"
	outfit_var = "l_ear"

/datum/ert_loadout_slot/single/r_ear
	slot_name = "Right Ear"
	outfit_var = "r_ear"

/datum/ert_loadout_slot/single/id
	slot_name = "ID Card"
	outfit_var = "id"

/datum/ert_loadout_slot/single/pda
	slot_name = "PDA"
	outfit_var = "pda"

/datum/ert_loadout_slot/single/shoes
	slot_name = "Shoes"
	outfit_var = "shoes"

/datum/ert_loadout_slot/single/belt
	slot_name = "Belt"
	outfit_var = "belt"

/datum/ert_loadout_slot/single/back
	slot_name = "Back"
	outfit_var = "back"

/datum/ert_loadout_slot/single/glasses
	slot_name = "Glasses"
	outfit_var = "glasses"

/datum/ert_loadout_slot/single/mask
	slot_name = "Mask"
	outfit_var = "mask"

/datum/ert_loadout_slot/single/l_pocket
	slot_name = "Left Pocket"
	outfit_var = "l_pocket"

/datum/ert_loadout_slot/single/l_pocket/allowed_items()
	. = ..()
	. |= ert_all_discovered_items()

/datum/ert_loadout_slot/single/r_pocket
	slot_name = "Right Pocket"
	outfit_var = "r_pocket"

/datum/ert_loadout_slot/single/r_pocket/allowed_items()
	. = ..()
	. |= ert_all_discovered_items()

/datum/ert_loadout_slot/single/neck
	slot_name = "Neck"
	outfit_var = "neck"
