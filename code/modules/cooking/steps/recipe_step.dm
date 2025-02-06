RESTRICT_TYPE(/datum/cooking/recipe_step)

/datum/cooking/recipe_step
	var/max_quality_award
	var/base_quality_award
	var/inherited_quality_modifier = 1
	var/optional = FALSE

/datum/cooking/recipe_step/New(options)
	if("qmod" in options)
		inherited_quality_modifier = options["qmod"]
	if("base" in options)
		base_quality_award = options["base"]
	if("max" in options)
		max_quality_award = options["max"]
	if("optional" in options)
		optional = options["optional"]

/datum/cooking/recipe_step/proc/calculate_quality(obj/used_item, datum/cooking/recipe_tracker/tracker)
	return 0

/datum/cooking/recipe_step/proc/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	SHOULD_CALL_PARENT(FALSE)
	return PCWJ_CHECK_VALID

//Automatically clamps food based on their maximum and minimum quality, if they are set.
/datum/cooking/recipe_step/proc/clamp_quality(raw_quality)
	if(!isnull(base_quality_award) && !isnull(max_quality_award))
		return clamp(raw_quality, base_quality_award, max_quality_award)
	if(!isnull(base_quality_award))
		return max(raw_quality, base_quality_award)
	if(!isnull(max_quality_award))
		return min(raw_quality, max_quality_award)
	return raw_quality

/datum/cooking/recipe_step/proc/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	return list()

//Special function to check if the step has been satisfied. Sometimed just following the step is enough, but not always.
/datum/cooking/recipe_step/proc/is_complete(obj/added_item, datum/cooking/recipe_tracker/tracker)
	return TRUE

/datum/cooking/recipe_step/proc/get_pda_formatted_desc()
	SHOULD_CALL_PARENT(FALSE)
	return ""
