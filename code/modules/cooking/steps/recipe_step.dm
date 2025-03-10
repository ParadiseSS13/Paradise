RESTRICT_TYPE(/datum/cooking/recipe_step)

/datum/cooking/recipe_step
	var/optional = FALSE

/datum/cooking/recipe_step/New(options)
	if("optional" in options)
		optional = options["optional"]

/datum/cooking/recipe_step/proc/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	SHOULD_CALL_PARENT(FALSE)
	return PCWJ_CHECK_VALID

/datum/cooking/recipe_step/proc/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	return list()

//Special function to check if the step has been satisfied. Sometimed just following the step is enough, but not always.
/datum/cooking/recipe_step/proc/is_complete(obj/added_item, datum/cooking/recipe_tracker/tracker)
	return TRUE

/datum/cooking/recipe_step/proc/get_pda_formatted_desc()
	SHOULD_CALL_PARENT(FALSE)
	return ""

/datum/cooking/recipe_step/proc/attempt_autochef_perform(datum/autochef_task/follow_recipe/task)
	return AUTOCHEF_ACT_FAILED

/datum/cooking/recipe_step/proc/attempt_autochef_prepare(obj/machinery/autochef/autochef)
	return AUTOCHEF_ACT_FAILED
