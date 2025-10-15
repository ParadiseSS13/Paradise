/// Item pools are the items that have already been registered to an ERT loadout
/// slot at some point. They are kept around in order to have a nice list of sensible
/// defaults for those slots on the UI, alongside their human-readable names.
GLOBAL_LIST_EMPTY(ert_loadout_item_pools)
/// ERT loadouts imported or created during game-time. Can be modified.
GLOBAL_LIST_EMPTY(ert_custom_loadouts)
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

	var/datum/ert_loadout_slot/single/firearm/primary/primary_firearm
	var/datum/ert_loadout_slot/single/firearm/secondary/secondary_firearm
	var/datum/ert_loadout_slot/multiple/cybernetic_implant/cybernetic_implants
	var/datum/ert_loadout_slot/multiple/bio_chip/bio_chips
	var/datum/ert_loadout_slot/assorted/backpack_contents/backpack_contents
	var/datum/ert_loadout_slot/single/head/head
	var/datum/ert_loadout_slot/single/shoes/shoes
	var/datum/ert_loadout_slot/single/belt/belt
	var/datum/ert_loadout_slot/single/back/back
	var/datum/ert_loadout_slot/single/glasses/glasses
	var/datum/ert_loadout_slot/single/mask/mask
	var/datum/ert_loadout_slot/single/l_pocket/l_pocket
	var/datum/ert_loadout_slot/single/r_pocket/r_pocket
	var/datum/ert_loadout_slot/single/neck/neck

/datum/ert_loadout/New(_loadout_name, _frozen = FALSE)
	. = ..()
	loadout_name = _loadout_name
	frozen = _frozen

	primary_firearm = new()
	secondary_firearm = new()
	cybernetic_implants = new()
	bio_chips = new()
	backpack_contents = new()
	head = new()
	shoes = new()
	belt = new()
	back = new()
	glasses = new()
	mask = new()
	l_pocket = new()
	r_pocket = new()
	neck = new()

/datum/ert_loadout/proc/copy_to_new(new_name)
	var/datum/ert_loadout/new_loadout = new(new_name)

	new_loadout.role = role

	new_loadout.primary_firearm.set_item(primary_firearm.chosen_item)
	new_loadout.secondary_firearm.set_item(secondary_firearm.chosen_item)
	new_loadout.head.set_item(head.chosen_item)
	new_loadout.shoes.set_item(shoes.chosen_item)
	new_loadout.belt.set_item(belt.chosen_item)
	new_loadout.back.set_item(back.chosen_item)
	new_loadout.glasses.set_item(glasses.chosen_item)
	new_loadout.mask.set_item(mask.chosen_item)
	new_loadout.l_pocket.set_item(l_pocket.chosen_item)
	new_loadout.r_pocket.set_item(r_pocket.chosen_item)
	new_loadout.neck.set_item(neck.chosen_item)
	for(var/implant in cybernetic_implants.chosen_items)
		new_loadout.cybernetic_implants.set_item(implant)
	for(var/bio_chip in bio_chips.chosen_items)
		new_loadout.bio_chips.set_item(bio_chip)
	for(var/backpack_item in backpack_contents.chosen_item_quantities)
		for(var/i in 1 to backpack_contents.chosen_item_quantities[backpack_item])
			new_loadout.backpack_contents.set_item(backpack_item)

	return new_loadout

/datum/ert_loadout/serialize()
	. = ..()
	.["loadout_name"] = loadout_name
	.["loadout_role"] = role
	.["primary_firearm"] = primary_firearm.serialize()
	.["secondary_firearm"] = secondary_firearm.serialize()
	.["cybernetic_implants"] = cybernetic_implants.serialize()
	.["bio_chips"] = bio_chips.serialize()
	.["backpack_contents"] = backpack_contents.serialize()
	.["head"] = head.serialize()
	.["shoes"] = shoes.serialize()
	.["belt"] = belt.serialize()
	.["back"] = back.serialize()
	.["glasses"] = glasses.serialize()
	.["mask"] = mask.serialize()
	.["l_pocket"] = l_pocket.serialize()
	.["r_pocket"] = r_pocket.serialize()
	.["neck"] = neck.serialize()

/datum/ert_loadout/deserialize(list/data)
	. = ..()

	role = data["loadout_role"]
	primary_firearm.chosen_item = text2path(data["primary_firearm"]["chosen_item"])
	secondary_firearm.chosen_item = text2path(data["secondary_firearm"]["chosen_item"])
	head.chosen_item = text2path(data["head"]["chosen_item"])
	shoes.chosen_item = text2path(data["shoes"]["chosen_item"])
	belt.chosen_item = text2path(data["belt"]["chosen_item"])
	back.chosen_item = text2path(data["back"]["chosen_item"])
	glasses.chosen_item = text2path(data["glasses"]["chosen_item"])
	mask.chosen_item = text2path(data["mask"]["chosen_item"])
	l_pocket.chosen_item = text2path(data["l_pocket"]["chosen_item"])
	r_pocket.chosen_item = text2path(data["r_pocket"]["chosen_item"])
	neck.chosen_item = text2path(data["neck"]["chosen_item"])

	for(var/implant in data["cybernetic_implants"]["chosen_item"])
		cybernetic_implants.chosen_items += text2path(implant)
	for(var/bio_chip in data["bio_chips"]["chosen_items"])
		bio_chips.chosen_items += text2path(bio_chip)
	for(var/backpack in data["backpack_contents"]["chosen_item_quantities"])
		backpack_contents.chosen_item_quantities[text2path(backpack)] = data["backpack_contents"]["chosen_item_quantities"][backpack]

/datum/ert_loadout/ui_data(mob/user)
	. = list()
	.["loadout_name"] = loadout_name
	.["loadout_role"] = role
	.["frozen"] = frozen

	.["primary_firearm"] = primary_firearm.ui_data()
	.["secondary_firearm"] = secondary_firearm.ui_data()
	.["cybernetic_implants"] = cybernetic_implants.ui_data()
	.["bio_chips"] = bio_chips.ui_data()
	.["backpack_contents"] = backpack_contents.ui_data()
	.["head"] = head.ui_data()
	.["shoes"] = shoes.ui_data()
	.["belt"] = belt.ui_data()
	.["back"] = back.ui_data()
	.["glasses"] = glasses.ui_data()
	.["mask"] = mask.ui_data()
	.["l_pocket"] = l_pocket.ui_data()
	.["r_pocket"] = r_pocket.ui_data()
	.["neck"] = neck.ui_data()

/datum/ert_loadout/proc/toggle_biochip(chip_type)
	if(chip_type in bio_chips.chosen_items)
		bio_chips.chosen_items -= chip_type
	else
		bio_chips.chosen_items |= chip_type

/datum/ert_loadout/proc/toggle_implant(implant_type)
	if(implant_type in cybernetic_implants.chosen_items)
		cybernetic_implants.chosen_items -= implant_type
	else
		cybernetic_implants.chosen_items |= implant_type

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

	if(outfit.head)
		loadout.head.set_item(outfit.head)
	if(outfit.shoes)
		loadout.shoes.set_item(outfit.shoes)
	if(outfit.belt)
		loadout.belt.set_item(outfit.belt)
	if(outfit.back)
		loadout.back.set_item(outfit.back)
	if(outfit.glasses)
		loadout.glasses.set_item(outfit.glasses)
	if(outfit.mask)
		loadout.mask.set_item(outfit.mask)
	if(outfit.l_pocket)
		loadout.l_pocket.set_item(outfit.l_pocket)
	if(outfit.r_pocket)
		loadout.r_pocket.set_item(outfit.r_pocket)
	if(outfit.l_hand)
		loadout.primary_firearm.set_item(outfit.l_hand)
	if(outfit.r_hand)
		loadout.secondary_firearm.set_item(outfit.r_hand)

	if(length(outfit.cybernetic_implants))
		for(var/implant in outfit.cybernetic_implants)
			loadout.cybernetic_implants.set_item(implant)

	if(length(outfit.bio_chips))
		for(var/bio_chip in outfit.bio_chips)
			loadout.bio_chips.set_item(bio_chip)

	if(length(outfit.backpack_contents))
		for(var/backpack_contents in outfit.backpack_contents)
			var/count = outfit.backpack_contents[backpack_contents]
			for(var/i in 1 to count)
				loadout.backpack_contents.set_item(backpack_contents)

	return loadout

/// Copy the hardcoded ERT outfits into loadouts.
/proc/generate_ert_loadouts_from_outfits()
	var/list/loadouts = list()

	for(var/response_team_outfit in subtypesof(/datum/outfit/job/response_team))
		var/datum/outfit/job/response_team/outfit = new response_team_outfit()
		loadouts += ert_loadout_from_outfit(outfit)

	return loadouts
