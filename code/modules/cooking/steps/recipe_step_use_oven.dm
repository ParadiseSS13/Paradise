RESTRICT_TYPE(/datum/cooking/recipe_step/use_oven)

/datum/cooking/recipe_step/use_oven
	var/time
	var/temperature

/datum/cooking/recipe_step/use_oven/New(temperature_, time_, options)
	temperature = temperature_
	time = time_

	..(options)

/datum/cooking/recipe_step/use_oven/calculate_quality(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/machinery/cooking/oven/oven = used_item
	if(istype(oven))
		return clamp_quality(oven.quality_mod)

	return 1

/datum/cooking/recipe_step/use_oven/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/cooking/container = locateUID(tracker.container_uid)

	if(container.get_cooker_time(COOKER_SURFACE_OVEN, temperature) >= time)
		return PCWJ_CHECK_VALID

	if(istype(used_item, /obj/machinery/cooking/oven))
		return PCWJ_CHECK_SILENT

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe_step/use_oven/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	var/list/step_data = list(target = used_item.UID())
	var/obj/item/reagent_containers/cooking/container = locateUID(tracker.container_uid)
	if(istype(container))
		step_data["cooker_data"] = container.cooker_data.Copy()

	return step_data

/datum/cooking/recipe_step/use_oven/get_pda_formatted_desc()
	return "Bake in an oven for [DisplayTimeText(time)] at [lowertext(temperature)] temperature."
