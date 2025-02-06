RESTRICT_TYPE(/datum/cooking/recipe_step/add_produce)

/// A cooking step that involves using grown foods.
/datum/cooking/recipe_step/add_produce
	var/obj/produce_type
	var/base_potency
	var/exact_path
	var/skip_reagents = FALSE
	var/list/exclude_reagents

/datum/cooking/recipe_step/add_produce/New(produce_type_, options)
	produce_type = produce_type_

	if("exact" in options)
		exact_path = options["exact"]
	if("skip_reagents" in options)
		skip_reagents = options["skip_reagents"]
	if("exclude_reagents" in options)
		exclude_reagents = options["exclude_reagents"]

	..(options)

/datum/cooking/recipe_step/add_produce/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	if(!istype(added_item, /obj/item/food/grown))
		return PCWJ_CHECK_INVALID
	if(exact_path)
		if(added_item == produce_type)
			return PCWJ_CHECK_VALID
	else
		if(istype(added_item, produce_type))
			return PCWJ_CHECK_VALID

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe_step/add_produce/calculate_quality(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/food/grown/added_produce = used_item
	var/potency_raw = round(base_quality_award + (added_produce.seed.potency - base_potency) * inherited_quality_modifier)
	return clamp_quality(potency_raw)

/datum/cooking/recipe_step/add_produce/is_complete(obj/added_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/container = locateUID(tracker.container_uid)
	if(!istype(container))
		return FALSE

	return (added_item in container.contents)

/datum/cooking/recipe_step/add_produce/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	#ifdef PCWJ_DEBUG
	log_debug("Called: /datum/cooking/recipe_step/add_produce/follow_step")
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

/datum/cooking/recipe_step/add_produce/get_pda_formatted_desc()
	return "Add \a [produce_type::name]."
