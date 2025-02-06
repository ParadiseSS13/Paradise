RESTRICT_TYPE(/datum/cooking/recipe_step/use_grill)

/datum/cooking/recipe_step/use_grill
	var/time
	var/temperature

/datum/cooking/recipe_step/use_grill/New(temperature_, time_, options)
	time = time_
	temperature = temperature_

	..(options)

/datum/cooking/recipe_step/use_grill/calculate_quality(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/machinery/cooking/grill/grill = used_item
	if(istype(grill))
		return clamp_quality(grill.quality_mod)

	return 1

/datum/cooking/recipe_step/use_grill/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/cooking/container = locateUID(tracker.container_uid)

	if(container.get_cooker_time(COOKER_SURFACE_GRILL, temperature) >= time)
		return PCWJ_CHECK_VALID

	if(istype(used_item, /obj/machinery/cooking/stovetop))
		return PCWJ_CHECK_SILENT

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe_step/use_grill/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	var/list/step_data = list(target = used_item.UID())
	var/obj/item/reagent_containers/cooking/container = locateUID(tracker.container_uid)
	if(istype(container))
		step_data["cooker_data"] = container.cooker_data.Copy()

	return step_data

/datum/cooking/recipe_step/use_grill/get_pda_formatted_desc()
	return "Cook on a grill for [DisplayTimeText(time)] at [lowertext(temperature)] temperature."
