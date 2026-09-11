/// Item pools are the items that have already been registered to an ERT loadout
/// slot at some point. They are kept around in order to have a nice list of sensible
/// defaults for those slots on the UI, alongside their human-readable names.
GLOBAL_LIST_EMPTY(ert_loadout_item_pools)
/// ERT loadouts imported or created during game-time. Can be modified.
GLOBAL_LIST_EMPTY(ert_custom_loadouts)
/// Concrete slot types that make up a loadout, in UI order.
GLOBAL_LIST_INIT(ert_loadout_slot_types, list(
	/datum/ert_loadout_slot/single/firearm/primary,
	/datum/ert_loadout_slot/single/firearm/secondary,
	/datum/ert_loadout_slot/single/glasses,
	/datum/ert_loadout_slot/single/head,
	/datum/ert_loadout_slot/single/l_ear,
	/datum/ert_loadout_slot/single/r_ear,
	/datum/ert_loadout_slot/single/neck,
	/datum/ert_loadout_slot/single/mask,
	/datum/ert_loadout_slot/single/uniform,
	/datum/ert_loadout_slot/single/suit,
	/datum/ert_loadout_slot/single/gloves,
	/datum/ert_loadout_slot/single/shoes,
	/datum/ert_loadout_slot/single/id,
	/datum/ert_loadout_slot/single/pda,
	/datum/ert_loadout_slot/single/belt,
	/datum/ert_loadout_slot/single/back,
	/datum/ert_loadout_slot/single/l_pocket,
	/datum/ert_loadout_slot/single/r_pocket,
	/datum/ert_loadout_slot/multiple/cybernetic_implant,
	/datum/ert_loadout_slot/multiple/bio_chip,
	/datum/ert_loadout_slot/assorted/backpack_contents,
))
/// ERT loadouts generated from the hardcoded outfits. Cannot be modified.
GLOBAL_LIST_INIT(ert_loadouts, generate_ert_loadouts_from_outfits())

/datum/ert_loadout
	/// The name of the loadout. Must be completely unique across all ERT loadouts.
	var/loadout_name
	/// Whether the loadout is hard-coded (i.e. one of the pre-existing ERT outfits.)
	/// Cannot be changed from within the UI, but a copy can be made and modified.
	var/frozen
	/// The "role" for this loadout, e.g. Engineering, Security, Medical, Paranormal.
	var/role

	var/list/slots = list()

/datum/ert_loadout/New(_loadout_name, _frozen = FALSE)
	. = ..()
	loadout_name = _loadout_name
	frozen = _frozen

	for(var/slot_type in GLOB.ert_loadout_slot_types)
		var/datum/ert_loadout_slot/slot = new slot_type
		slots[slot.outfit_var] = slot

/datum/ert_loadout/proc/copy_to_new(new_name)
	var/datum/ert_loadout/new_loadout = new(new_name)

	new_loadout.role = role

	for(var/outfit_var in slots)
		var/datum/ert_loadout_slot/slot = slots[outfit_var]
		slot.copy_into(new_loadout.slots[outfit_var])

	return new_loadout

/datum/ert_loadout/proc/to_outfit()
	var/datum/outfit/job/response_team/outfit = new

	for(var/outfit_var in slots)
		var/datum/ert_loadout_slot/slot = slots[outfit_var]
		slot.apply_to_outfit(outfit)

	return outfit

/datum/ert_loadout/serialize()
	. = ..()
	.["loadout_name"] = loadout_name
	.["loadout_role"] = role
	.["slots"] = list()

	for(var/outfit_var in slots)
		var/datum/ert_loadout_slot/slot = slots[outfit_var]
		.["slots"][outfit_var] = slot.serialize()

/datum/ert_loadout/deserialize(list/data)
	. = ..()

	role = data["loadout_role"]

	for(var/outfit_var in slots)
		if(data["slots"]?[outfit_var])
			var/datum/ert_loadout_slot/slot = slots[outfit_var]
			slot.deserialize(data["slots"][outfit_var])

/datum/ert_loadout/ui_data(mob/user)
	. = list()
	.["loadout_name"] = loadout_name
	.["loadout_role"] = role
	.["frozen"] = frozen
	.["single_slots"] = list()

	for(var/outfit_var in slots)
		var/datum/ert_loadout_slot/slot = slots[outfit_var]
		if(istype(slot, /datum/ert_loadout_slot/single))
			.["single_slots"][outfit_var] = slot.ui_data(user)

	var/datum/ert_loadout_slot/cybernetic_implants = slots["cybernetic_implants"]
	.["cybernetic_implants"] = cybernetic_implants.ui_data(user)
	var/datum/ert_loadout_slot/bio_chips = slots["bio_chips"]
	.["bio_chips"] = bio_chips.ui_data(user)
	var/datum/ert_loadout_slot/backpack_contents = slots["backpack_contents"]
	.["backpack_contents"] = backpack_contents.ui_data(user)

/datum/ert_loadout/proc/toggle_biochip(chip_type)
	var/datum/ert_loadout_slot/multiple/slot = slots["bio_chips"]
	if(chip_type in slot.chosen_items)
		slot.chosen_items -= chip_type
	else
		slot.chosen_items |= chip_type

/datum/ert_loadout/proc/toggle_implant(implant_type)
	var/datum/ert_loadout_slot/multiple/slot = slots["cybernetic_implants"]
	if(implant_type in slot.chosen_items)
		slot.chosen_items -= implant_type
	else
		slot.chosen_items |= implant_type

/// Return all items used in any ERT outfit.
/// Used to ensure that the ERT Loadout Manager properly names
/// them in the interface.
/proc/ert_all_discovered_items()
	. = list()
	for(var/item_type in GLOB.ert_loadout_item_pools)
		. |= GLOB.ert_loadout_item_pools[item_type]

/proc/ert_loadout_from_outfit(datum/outfit/job/response_team/outfit)
	var/datum/ert_loadout/loadout = new(outfit.name, _frozen = TRUE)

	loadout.role = outfit.base_role

	for(var/outfit_var in loadout.slots)
		if(outfit.vars[outfit_var])
			var/datum/ert_loadout_slot/slot = loadout.slots[outfit_var]
			slot.apply_from_outfit(outfit)

	return loadout

/// Copy the hardcoded ERT outfits into loadouts.
/proc/generate_ert_loadouts_from_outfits()
	var/list/loadouts = list()

	for(var/response_team_outfit in subtypesof(/datum/outfit/job/response_team))
		var/datum/outfit/job/response_team/outfit = new response_team_outfit()
		loadouts[response_team_outfit] = ert_loadout_from_outfit(outfit)

	return loadouts

/proc/ert_loadout_by_name(name)
	for(var/outfit_type in GLOB.ert_loadouts)
		var/datum/ert_loadout/loadout = GLOB.ert_loadouts[outfit_type]
		if(loadout.loadout_name == name)
			return loadout

	for(var/datum/ert_loadout/custom_loadout in GLOB.ert_custom_loadouts)
		if(custom_loadout.loadout_name == name)
			return custom_loadout
