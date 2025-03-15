/datum/autochef_task/make_item
	var/obj/item/target_type

/datum/autochef_task/make_item/New(obj/machinery/autochef_, obj/item/target_type_)
	autochef = autochef_
	target_type = target_type_

/datum/autochef_task/make_item/resume()
	var/list/possible_recipes = autochef.find_recipes(target_type)
	if(!length(possible_recipes))
		autochef.atom_say("No recipes found for [target_type::name].")
		current_state = AUTOCHEF_ACT_FAILED
		return

	var/list/capable_recipes = list()
	for(var/datum/cooking/recipe/recipe in possible_recipes)
		var/can_use_recipe = handle_recipe(recipe)
		if(can_use_recipe)
			capable_recipes.Add(recipe)

	if(length(capable_recipes))
		autochef.task_queue.Insert(autochef.task_queue.Find(src), new/datum/autochef_task/follow_recipe(autochef, capable_recipes[1]))
		current_state = AUTOCHEF_ACT_COMPLETE
		return

	autochef.atom_say("Cannot make [target_type::name].")
	current_state = AUTOCHEF_ACT_FAILED

/datum/autochef_task/make_item/proc/handle_recipe(datum/cooking/recipe/recipe)
	var/container_count = 0
	for(var/obj/item/reagent_containers/container in autochef.linked_cooking_containers)
		if(istype(container, recipe.container_type))
			container_count++

	if(!container_count)
		autochef.atom_say("No linked [recipe.container_type::name].")
		return FALSE

	for(var/datum/cooking/recipe_step/step in recipe.steps)
		if(step.optional)
			continue
		var/result = handle_step(step)
		if(!result)
			return FALSE

	return TRUE

/datum/autochef_task/make_item/proc/handle_step(datum/cooking/recipe_step/step)
	var/prep_result = step.attempt_autochef_prepare(autochef)
	switch(prep_result)
		if(AUTOCHEF_ACT_VALID)
			return TRUE
		if(AUTOCHEF_ACT_MISSING_INGREDIENT)
			if(autochef.upgrade_level > 2)
				handle_missing_item(step)
			else
				return FALSE
		if(AUTOCHEF_ACT_MISSING_REAGENT)
			return FALSE
		if(AUTOCHEF_ACT_FAILED)
			autochef.atom_say("Unknown error.")
			return FALSE
		if(AUTOCHEF_ACT_NO_AVAILABLE_STORAGE)
			autochef.atom_say("No linked storage.")
			return FALSE
		if(AUTOCHEF_ACT_NO_AVAILABLE_MACHINES)
			var/datum/cooking/recipe_step/use_machine/use_machine_step = step
			autochef.atom_say("No available [use_machine_step.machine_type::name].")
			return FALSE

	return TRUE

/datum/autochef_task/make_item/proc/handle_missing_item(datum/cooking/recipe_step/step)
	var/datum/cooking/recipe_step/add_item/add_item_step = step
	if(istype(add_item_step))
		for(var/container_type in GLOB.pcwj_recipe_dictionary)
			for(var/datum/cooking/recipe/next_recipe in GLOB.pcwj_recipe_dictionary[container_type])
				if(next_recipe.product_type == add_item_step.item_type)
					autochef.task_queue.Insert(autochef.task_queue.Find(src), new/datum/autochef_task/make_item(autochef, add_item_step.item_type))
					autochef.atom_say("Making [add_item_step.item_type::name] first.")
					return AUTOCHEF_ACT_ADDED_TASK
		autochef.atom_say("Cannot find [add_item_step.item_type::name].")
		return AUTOCHEF_ACT_MISSING_INGREDIENT
	var/datum/cooking/recipe_step/add_produce/add_produce_step = step
	if(istype(add_produce_step))
		autochef.atom_say("Cannot find [add_produce_step.produce_type::name].")
		return AUTOCHEF_ACT_MISSING_INGREDIENT

	autochef.atom_say("Unknown failure. Please contact customer support.")
	return AUTOCHEF_ACT_FAILED
