RESTRICT_TYPE(/datum/cooking/recipe_step/add_item/meathunk)

/// A specialized add-item step for specific meat subtypes
/datum/cooking/recipe_step/add_item/meathunk
	/// A list of subtypes of meat which aren't appropriate substitutes for the generic "hunk of meat" base type in recipes
	var/list/exclude_meat_subtypes = list(
		/obj/item/food/meat/chicken,
		/obj/item/food/meat/patty_raw,
		/obj/item/food/meat/patty,
		/obj/item/food/meat/raw_meatball,
	)

/datum/cooking/recipe_step/add_item/meathunk/New(options)
	..(/obj/item/food/meat, options)

/datum/cooking/recipe_step/add_item/meathunk/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	if(is_type_in_list(added_item, exclude_meat_subtypes))
		return PCWJ_CHECK_INVALID

	return ..()
