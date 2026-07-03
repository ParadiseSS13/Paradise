/obj/machinery/computer/science_collector/
	var/obj/item/disk/tech_disk/inserted_disk
	/// Used to determine what reward item is needed to increase the max level
	var/datum/tech/science_type
	/// Holds items already redeemed, so they cant be redeemed multiple times
	var/list/redeemed_reward_items = list()
	/// Used to exceed the tech limit on tech datums (usually 7)
	var/max_level_increase = 0
	var/list/thresholds = list(
		SCIENCE_POINTS_FOR_LEVEL_2,
		SCIENCE_POINTS_FOR_LEVEL_3,
		SCIENCE_POINTS_FOR_LEVEL_4,
		SCIENCE_POINTS_FOR_LEVEL_5,
		SCIENCE_POINTS_FOR_LEVEL_6,
		SCIENCE_POINTS_FOR_LEVEL_7,
		SCIENCE_POINTS_FOR_LEVEL_8,
		SCIENCE_POINTS_FOR_LEVEL_9,
		SCIENCE_POINTS_FOR_LEVEL_10,
	)

/obj/machinery/computer/science_collector/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/disk/tech_disk))
		user.drop_item()
		used.forceMove(src)
		inserted_disk = used
		return ITEM_INTERACT_COMPLETE
	else if(try_redeem_reward_item(used)) // on sucessful redeem
		return ITEM_INTERACT_COMPLETE
	return ..()

/// Increases the maximum level this computer can load onto a disk.
/obj/machinery/computer/science_collector/proc/try_redeem_reward_item(obj/item/used)
	if(!istype(science_type, /datum/tech/)) // you forgot to set this
		log_debug("Science type not set on [src]")
		return FALSE

	if(!used.science_reward_types.len) // if its not a reward item
		return FALSE

	if(used in redeemed_reward_items) // if the item has already been redeemed here
		atom_say("Error: This item has already been scanned.")
		return FALSE

	if(!(science_type in used.science_reward_types)) // if the item is a reward item, but of the wrong type
		atom_say("Error: Unknown object.")
		return FALSE

	// if the used item is a reward for this machine
	max_level_increase++;
	redeemed_reward_items += used
	atom_say("Item sucessfully scanned, capabilities improved.")

	return TRUE

/// Converts the `data_points` variable into levels on the tech datum, then puts a new datum onto the disk. Capped by the maximum level on the tech datum plus any redeemed reward items.
/obj/machinery/computer/science_collector/proc/load_data_onto_disk(datum/tech/tech_to_load, data_points)
	if(!inserted_disk)
		return

	var/datum/tech/new_tech = new tech_to_load
	for(var/i = 1; i < thresholds.len; i++)
		if(data_points < thresholds[i])
			continue
		new_tech.level = min(i + 1, tech_to_load.max_level + max_level_increase)

	atom_say("loaded [new_tech.name] level [new_tech.level]")
	inserted_disk.load_tech(new_tech)

/// Puts an inserted disk, if any into the users hand.
/obj/machinery/computer/science_collector/proc/eject_disk(mob/user)
	if(!inserted_disk)
		return

	inserted_disk.forceMove(loc)
	if(user)
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(inserted_disk)

	inserted_disk = null
