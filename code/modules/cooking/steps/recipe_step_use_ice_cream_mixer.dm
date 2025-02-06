RESTRICT_TYPE(/datum/cooking/recipe_step/use_ice_cream_mixer)

/datum/cooking/recipe_step/use_ice_cream_mixer
	var/time

/datum/cooking/recipe_step/use_ice_cream_mixer/New(time_, options)
	time = time_

	..(options)

/datum/cooking/recipe_step/use_ice_cream_mixer/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/cooking/container = locateUID(tracker.container_uid)

	if(container.get_cooker_time(COOKER_SURFACE_ICE_CREAM_MIXER, J_LO) >= time)
		return PCWJ_CHECK_VALID

	if(istype(used_item, /obj/machinery/cooking/ice_cream_mixer))
		return PCWJ_CHECK_SILENT

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe_step/use_ice_cream_mixer/calculate_quality(obj/used_item, datum/cooking/recipe_tracker/tracker)
	return 5

/datum/cooking/recipe_step/use_ice_cream_mixer/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	return list(target = used_item.UID())

/datum/cooking/recipe_step/use_ice_cream_mixer/get_pda_formatted_desc()
	return "Mix in an ice cream mixer for [DisplayTimeText(time)]."
