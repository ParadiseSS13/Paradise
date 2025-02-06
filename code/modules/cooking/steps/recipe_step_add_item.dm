RESTRICT_TYPE(/datum/cooking/recipe_step/add_item)

// TODO for v2: See if a "count" option can be added to reduce
// the need for both longer recipe step lists, and whatever
// fuckery I eventually come up with for combining equivalent
// steps for generating instructions for the wiki.
/datum/cooking/recipe_step/add_item
	var/obj/item_type
	var/exact_path
	var/skip_reagents = FALSE
	var/list/exclude_reagents

/datum/cooking/recipe_step/add_item/New(item_type_, options)
	item_type = item_type_

	if("exact" in options)
		exact_path = options["exact"]
	if("skip_reagents" in options)
		skip_reagents = options["skip_reagents"]
	if("exclude_reagents" in options)
		exclude_reagents = options["exclude_reagents"]

	..(options)

/datum/cooking/recipe_step/add_item/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	#ifdef PCWJ_DEBUG
	log_debug("Called add_item/check_conditions_met for [added_item], checking against item type [item_type]. Exact_path = [exact_path]")
	#endif
	if(!istype(added_item, /obj/item))
		return PCWJ_CHECK_INVALID
	if(exact_path)
		if(added_item.type == item_type)
			return PCWJ_CHECK_VALID
	else
		if(istype(added_item, item_type))
			return PCWJ_CHECK_VALID
	return PCWJ_CHECK_INVALID

/datum/cooking/recipe_step/add_item/calculate_quality(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/food/food_item = used_item
	if(istype(food_item))
		var/raw_quality = food_item.food_quality * inherited_quality_modifier

		return clamp_quality(raw_quality)

	return ..()

/datum/cooking/recipe_step/add_item/is_complete(obj/added_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/container = locateUID(tracker.container_uid)
	if(!istype(container))
		return FALSE

	return (added_item in container.contents)

/datum/cooking/recipe_step/add_item/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	#ifdef PCWJ_DEBUG
	log_debug("Called: /datum/cooking/recipe_step/add_item/follow_step")
	#endif
	var/obj/item/container = locateUID(tracker.container_uid)
	if(!user && ismob(used_item.loc))
		user = used_item.loc
	if(container)
		if(istype(user) && user.Adjacent(container))
			if(user.unequip(used_item))
				used_item.forceMove(container)
			else
				to_chat(user, "<span class='notice'>You can't remove [used_item] from your hands!</span>")
				return list()
		else
			used_item.forceMove(container)

		return list(message = "You add \the [used_item] to \the [container].", target = used_item.UID())

	return list(message = "Something went real fucking wrong here!")

/datum/cooking/recipe_step/add_item/get_pda_formatted_desc()
	return "Add \a [item_type::name]."
