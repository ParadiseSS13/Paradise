/obj/machinery/computer/science_collector/
	var/obj/item/disk/tech_disk/inserted_disk
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
	return ..()

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

/obj/machinery/computer/science_collector/proc/eject_disk(mob/user)
	if(!inserted_disk)
		return

	inserted_disk.forceMove(loc)
	if(user)
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(inserted_disk)

	inserted_disk = null
