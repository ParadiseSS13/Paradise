RESTRICT_TYPE(/obj/item/autochef_expansion_card/basic)

/obj/item/autochef_expansion_card/basic
	name = "\improper Autochef Expansion Card: Basic"
	desc = "This fairly common expansion card enables autochefs to perform basic cutting, rolling, and shaping tasks."
	icon_state = "autochef_expansion_card_blue"
	task_message = "Basic prepping"
	var/static/list/sliceable_foods
	var/static/list/rollable_foods = list(
		/obj/item/food/sliceable/flatdough = /obj/item/food/dough,
	)

/obj/item/autochef_expansion_card/basic/Initialize(mapload)
	. = ..()
	if(!sliceable_foods)
		sliceable_foods = list()
		for(var/food_type in subtypesof(/obj/item/food/sliceable))
			var/obj/item/food/sliceable/sliceable_food_type = food_type
			sliceable_foods[sliceable_food_type::slice_path] = sliceable_food_type

/obj/item/autochef_expansion_card/basic/can_produce(obj/machinery/autochef/autochef, target_type)
	if(target_type in sliceable_foods)
		return AUTOCHEF_ACT_VALID
	if(target_type in rollable_foods)
		return AUTOCHEF_ACT_VALID
	// special case yay
	if(ispath(target_type, /obj/item/food/cutlet))
		return AUTOCHEF_ACT_VALID

	return FALSE

/obj/item/autochef_expansion_card/basic/perform_step(datum/autochef_task/origin_task, target_type)
	var/obj/item/item_type = target_type
	autochef.atom_say("Prepping [item_type::name].")
	autochef.set_display("screen-knife")

	if(target_type in sliceable_foods)
		var/sliceable_food_type = sliceable_foods[target_type]
		for(var/obj/machinery/smartfridge/smartfridge in autochef.linked_storages)
			var/obj/item/food/sliceable/ingredient = smartfridge.directly_move_to(sliceable_food_type, autochef)
			if(ingredient)
				var/list/output = ingredient.convert_to_slices(inaccurate = FALSE)
				for(var/atom/movable/A in output)
					A.forceMove(src) // that's right we're putting the results in the card itself

				return AUTOCHEF_ACT_COMPLETE
		if(autochef.upgrade_level > 2)
			var/datum/autochef_task/task = autochef.handle_missing_item(sliceable_food_type)
			if(istype(task))
				autochef.add_task(task, origin_task)
				return AUTOCHEF_ACT_ADDED_TASK
	else if(target_type in rollable_foods)
		var/rollable_food_type = rollable_foods[target_type]
		for(var/obj/machinery/smartfridge/smartfridge in autochef.linked_storages)
			var/atom/movable/ingredient = smartfridge.directly_move_to(rollable_food_type, autochef)
			if(ingredient)
				qdel(ingredient)
				new target_type(src)
				return AUTOCHEF_ACT_COMPLETE

		if(autochef.upgrade_level > 2)
			var/datum/autochef_task/task = autochef.handle_missing_item(rollable_food_type)
			if(istype(task))
				autochef.add_task(task, origin_task)
				return AUTOCHEF_ACT_ADDED_TASK
	else if(ispath(target_type, /obj/item/food/cutlet))
		var/meat_type = /obj/item/food/meat
		// i think asking the autochef to find a source of meat is
		// probably the start of a horror story so if we can't find
		// any we just give up
		for(var/obj/machinery/smartfridge/smartfridge in autochef.linked_storages)
			var/obj/item/food/meat/meat = smartfridge.directly_move_to(meat_type, autochef)
			if(istype(meat))
				meat.make_cutlets(src)
				return AUTOCHEF_ACT_COMPLETE

		return AUTOCHEF_ACT_MISSING_INGREDIENT

	// if an expansion card fails, we take the task off the list and let
	// whatever step called it find the best solution, which may not be
	// the expansion card still
	autochef.remove_task(origin_task)
	return AUTOCHEF_ACT_FAILED
