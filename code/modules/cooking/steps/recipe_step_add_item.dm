RESTRICT_TYPE(/datum/cooking/recipe_step/add_item)

// TODO for v2: See if a "count" option can be added to reduce
// the need for both longer recipe step lists, and whatever
// fuckery I eventually come up with for combining equivalent
// steps for generating instructions for the wiki.
/datum/cooking/recipe_step/add_item
	var/obj/item_type
	var/exact_path
	var/skip_reagents = FALSE
	// The original cooking system removed nutriment from
	// the ingredients put into a recipe
	var/list/exclude_reagents = list("nutriment")

/datum/cooking/recipe_step/add_item/New(item_type_, options)
	item_type = item_type_

	if("exact" in options)
		exact_path = options["exact"]
	if("skip_reagents" in options)
		skip_reagents = options["skip_reagents"]
	if("exclude_reagents" in options)
		exclude_reagents |= options["exclude_reagents"]

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

/datum/cooking/recipe_step/add_item/is_complete(obj/added_item, datum/cooking/recipe_tracker/tracker, list/step_data)
	var/obj/item/container = locateUID(tracker.container_uid)
	if(!istype(container))
		return FALSE

	if(exact_path)
		if(step_data["stack_added"] == item_type)
			return TRUE
	else
		if(ispath(step_data["stack_added"], item_type))
			return TRUE

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
			var/obj/item/stack/stack = used_item
			if(istype(stack))
				if(stack.use(1))
					var/stack_type = stack.type
					new stack_type(container, 1)
					return list(message = "You add one of \the [stack.name] to \the [container].", stack_added = stack_type)
				else
					to_chat(user, "<span class='notice'>You can't remove one of \the [stack.name] from the stack!</span>")
					return list()
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

/datum/cooking/recipe_step/add_item/attempt_autochef_perform(datum/autochef_task/follow_recipe/task)
	for(var/obj/machinery/smartfridge/storage in task.autochef.linked_storages)
		for(var/obj/possible_item in storage)
			if(check_conditions_met(possible_item, task.container.tracker))
				var/result = task.container.process_item(null, possible_item)
				switch(result)
					if(PCWJ_CONTAINER_FULL, PCWJ_NO_STEPS, PCWJ_NO_RECIPES)
						return AUTOCHEF_ACT_FAILED
					if(PCWJ_COMPLETE, PCWJ_SUCCESS, PCWJ_PARTIAL_SUCCESS)
						task.autochef.Beam(storage, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
						// Boy howdy I sure do love having to manually update
						// the recorded quantities of items in smartfridges
						storage.item_quants[possible_item.name]--
						return AUTOCHEF_ACT_STEP_COMPLETE

	task.autochef.atom_say("Missing [item_type::name].")
	return AUTOCHEF_ACT_MISSING_INGREDIENT

/datum/cooking/recipe_step/add_item/attempt_autochef_prepare(obj/machinery/autochef/autochef)
	var/storage_count = 0
	for(var/obj/machinery/smartfridge/storage in autochef.linked_storages)
		storage_count++
		for(var/obj/possible_item in storage)
			if(check_conditions_met(possible_item, null))
				return AUTOCHEF_ACT_VALID

	if(!storage_count)
		return AUTOCHEF_ACT_NO_AVAILABLE_STORAGE

	autochef.atom_say("Cannot find [item_type::name].")
	return AUTOCHEF_ACT_MISSING_INGREDIENT
