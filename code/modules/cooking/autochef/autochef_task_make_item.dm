/datum/autochef_task/make_item
	var/obj/item/target_type

/datum/autochef_task/make_item/New(obj/machinery/autochef_, obj/item/target_type_)
	autochef = autochef_
	target_type = target_type_

/datum/autochef_task/make_item/debug_string()
	return "[type]: target_type=[target_type] current_state=[autochef_act_to_string(current_state)]"

/datum/autochef_task/make_item/resume()
	if(current_state == AUTOCHEF_ACT_ADDED_TASK)
		// if we added a task before and are back here,
		// i guess we'll assume we got what we needed
		current_state = AUTOCHEF_ACT_COMPLETE
		return

	var/list/possible_recipes = autochef.find_recipes(target_type)
	if(length(possible_recipes))
		var/list/capable_recipes = list()
		for(var/datum/cooking/recipe/recipe in possible_recipes)
			var/can_use_recipe = handle_recipe(recipe)
			if(can_use_recipe)
				capable_recipes.Add(recipe)

		if(length(capable_recipes))
			autochef.add_task(new/datum/autochef_task/follow_recipe(autochef, capable_recipes[1]), src)
			current_state = AUTOCHEF_ACT_ADDED_TASK
			return

	if(length(autochef.expansion_cards))
		for(var/card_type in autochef.expansion_cards)
			var/obj/item/autochef_expansion_card/card = autochef.expansion_cards[card_type]
			var/result = card.can_produce(autochef, target_type)
			switch(result)
				if(AUTOCHEF_ACT_VALID)
					autochef.add_task(new/datum/autochef_task/use_expansion_card(autochef, card, target_type), src)
					current_state = AUTOCHEF_ACT_ADDED_TASK
					return
				if(AUTOCHEF_ACT_MISSING_MACHINE)
					current_state = AUTOCHEF_ACT_MISSING_MACHINE
					return
				if(AUTOCHEF_ACT_FAILED)
					current_state = AUTOCHEF_ACT_FAILED
					autochef.atom_say("Failure accessing [card]. Please contact customer support.")
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
				var/datum/autochef_task/task = autochef.handle_missing_item_from_step(step)
				if(istype(task))
					autochef.add_task(task, src)
					current_state = AUTOCHEF_ACT_ADDED_TASK
				else
					current_state = AUTOCHEF_ACT_MISSING_INGREDIENT
					return FALSE
			else
				return FALSE
		if(AUTOCHEF_ACT_MISSING_REAGENT)
			if(autochef.upgrade_level > 2)
				var/datum/autochef_task/task = autochef.handle_missing_reagent_from_step(step)
				if(istype(task))
					autochef.add_task(task, src)
					current_state = AUTOCHEF_ACT_ADDED_TASK
				else
					current_state = AUTOCHEF_ACT_MISSING_REAGENT
					return FALSE
			else
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
