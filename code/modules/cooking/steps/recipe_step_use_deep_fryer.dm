RESTRICT_TYPE(/datum/cooking/recipe_step/use_deep_fryer)

/datum/cooking/recipe_step/use_deep_fryer
	var/time

/datum/cooking/recipe_step/use_deep_fryer/New(time_, options)
	time = time_

	..(options)

/datum/cooking/recipe_step/use_deep_fryer/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/cooking/container = locateUID(tracker.container_uid)

	if(container.get_cooker_time(COOKER_SURFACE_DEEPFRYER, J_LO) >= time)
		return PCWJ_CHECK_VALID

	if(istype(used_item, /obj/machinery/cooking/deepfryer))
		return PCWJ_CHECK_SILENT

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe_step/use_deep_fryer/calculate_quality(obj/used_item, datum/cooking/recipe_tracker/tracker)
	return 5

/datum/cooking/recipe_step/use_deep_fryer/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	return list(target = used_item.UID())

/datum/cooking/recipe_step/use_deep_fryer/get_pda_formatted_desc()
	return "Deep-fry for [DisplayTimeText(time)]."
