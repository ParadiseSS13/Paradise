GLOBAL_LIST_EMPTY(pcwj_recipe_dictionary)
GLOBAL_LIST_EMPTY(pcwj_cookbook_lookup)

/**
 * ## ParaCooking With Jane
 *
 * A cooking rework ported from Sojourn and heavily adapted for Para.
 *
 * The recipe datum outlines a list of steps from getting a piece of food from
 * point A to point B. Recipes have a list of steps including optional ones to
 * increase the total quality of the food. Following a recipe incorrectly (i.e.,
 * adding too much of an item, having the burner too hot, etc.) Will decrease
 * the quality of the food.
 *
 * Recipes have clear start and end points. They start with a particular item
 * and end with a particular item. That said, a start item can follow multiple
 * recipes until they eventually diverge as different steps are followed. In the
 * case two recipes have identical steps, the user should be prompted on what
 * their intended result should be. (Donuts vs Bagels)
 *
 * Recipes are loaded at startup. Food items reference it by the recipe_tracker
 * datum. By following the steps correctly, good food can be made. Food quality
 * is calculated based on the steps taken.
 *
 * Recipes and their steps are singletons. Cooking processes should never alter
 * them.
*/
/datum/cooking/recipe
	/// Name for the cooking guide. Auto-populates from result food if not set.
	var/name
	/// Description for the cooking guide. Auto-populates from result food if not set.
	var/description
	var/recipe_guide		// Step by step recipe guide. I hate it.
	var/recipe_icon			// Icon for the cooking guide. Auto-populates if not set.
	var/recipe_icon_state	// Icon state for the cooking guide. Auto-populates if not set.

	/// The name of the cooking container the recipe is performed in.
	var/cooking_container

	/// Type path for the product created by the recipe.
	var/product_type
	var/product_name
	/// How much of a thing is made per case of the recipe being followed.
	var/product_count = 1

	// Special variables that must be defined INSTEAD of product_type in order to create reagents instead of an object.
	var/reagent_id
	var/reagent_amount
	var/reagent_name
	var/reagent_desc

	var/icon_image_file

	/// Determines if we entirely replace the contents of the food product with the slurry that goes into it.
	var/replace_reagents = FALSE

	/// Everything appears in the catalog by default.
	var/appear_in_default_catalog = TRUE

	var/list/steps

/datum/cooking/recipe/proc/create_product(datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/cooking/container = locateUID(tracker.container_uid)
	var/tracked_quality = 0

	if(!istype(container))
		log_debug("failure to find container when creating recipe product!")
		return

	// Build up a list of reagents that went into this.
	var/datum/reagents/slurry = new(maximum = 1000000)
	slurry.my_atom = container

	var/list/applied_steps = tracker.recipes_all_applied_steps[src]
	// Remember this is not necessarily a consecutive list of step indexes
	// Optional steps may have been skipped
	for(var/i in 1 to length(applied_steps))
		var/current_index = applied_steps[i]
		var/datum/cooking/recipe_step/recipe_step = steps[current_index]
		var/list/applied_step_data = tracker.recipes_applied_step_data[i]

		// Filter out reagents based on settings
		var/datum/cooking/recipe_step/add_reagent/add_reagent_step = recipe_step
		if(istype(add_reagent_step))
			var/amount_to_remove = add_reagent_step.amount * (1 - add_reagent_step.remain_percent)
			if(!amount_to_remove)
				continue
			container.reagents.remove_reagent(add_reagent_step.reagent_id, amount_to_remove, safety = TRUE)

		var/target_uid = applied_step_data["target"]
		var/obj/added_item = locateUID(target_uid)
		if(istype(added_item))
			tracked_quality += recipe_step.calculate_quality(added_item, tracker)

		if("rating" in applied_step_data)
			product_count = max(product_count, min(3, applied_step_data["rating"]))

	if(product_type) // Make a regular item
		. = make_product_item(container, slurry, applied_steps, tracked_quality)
	else
		QDEL_LIST_CONTENTS(container.contents)
		container.contents = list()

	container.reagents.clear_reagents()

	if(reagent_id)
		var/total_quality = tracked_quality + calculate_reagent_quality(tracker)
		container.reagents.add_reagent(reagent_id, reagent_amount, data = list("FOOD_QUALITY" = total_quality))

	qdel(slurry)

/datum/cooking/recipe/proc/make_product_item(obj/item/reagent_containers/cooking/container, datum/reagents/slurry, list/applied_steps, tracked_quality)
	if(container.reagents.total_volume)
		#ifdef PCWJ_DEBUG
		log_debug("/recipe/proc/create_product: Transferring container reagents of [container.reagents.total_volume] to slurry of current volume [slurry.total_volume] max volume [slurry.maximum_volume]")
		#endif
		container.reagents.trans_to(slurry, amount=container.reagents.total_volume)

	// Do reagent filtering on added items and produce
	var/list/exclude_list = list()
	for(var/obj/item/added_item in container.contents)
		var/can_add = TRUE
		var/list/exclude_specific_reagents = list()
		#ifdef PCWJ_DEBUG
		log_debug("/recipe/proc/create_product: Analyzing reagents of [added_item].")
		#endif
		for(var/i in 1 to length(applied_steps))
			var/current_index = applied_steps[i]
			var/datum/cooking/recipe_step = steps[current_index]

			if(recipe_step in exclude_list)
				continue

			var/datum/cooking/recipe_step/add_item/add_item_step = recipe_step
			if(istype(add_item_step))
				if(add_item_step.exclude_reagents)
					exclude_specific_reagents |= add_item_step.exclude_reagents
				if(add_item_step.skip_reagents)
					can_add = FALSE
					exclude_list |= recipe_step
					break

			var/datum/cooking/recipe_step/add_produce/add_produce_step = recipe_step
			if(istype(add_produce_step))
				if(add_produce_step.exclude_reagents)
					exclude_specific_reagents |= add_produce_step.exclude_reagents
				if(add_produce_step.skip_reagents)
					can_add = FALSE
					exclude_list |= recipe_step
					break

		if(can_add)
			if(length(exclude_specific_reagents))
				for(var/id in exclude_specific_reagents)
					added_item.reagents.remove_reagent(id, added_item.reagents.get_reagent_amount(id), safety = TRUE)

			if(added_item.reagents)
				added_item.reagents.trans_to(slurry, amount = added_item.reagents.total_volume)

	// Purge the contents of the container we no longer need it
	QDEL_LIST_CONTENTS(container.contents)

	var/reagent_quality = calculate_reagent_quality(container.tracker)

	for(var/i in 1 to product_count)
		var/obj/item/new_item = new product_type(container)
		. = new_item
		#ifdef PCWJ_DEBUG
		log_debug("/recipe/proc/create_product: Item created with reagents of [new_item.reagents.total_volume]")
		#endif
		if(replace_reagents)
			//Clearing out reagents in data. If initialize hasn't been called, we also null that out here.
			#ifdef PCWJ_DEBUG
			log_debug("/recipe/proc/create_product: Clearing out reagents from the [new_item]")
			#endif
			new_item.reagents.clear_reagents()
		#ifdef PCWJ_DEBUG
		log_debug("/recipe/proc/create_product: Transferring slurry of [slurry.total_volume] to [new_item] of total volume [new_item.reagents.total_volume]")
		#endif
		slurry.copy_to(new_item, amount=slurry.total_volume)

		var/obj/item/food/food_item = new_item
		if(istype(food_item))
			food_item.food_quality = tracked_quality + reagent_quality
			food_item.get_food_tier()

/datum/cooking/recipe/proc/calculate_reagent_quality(datum/cooking/recipe_tracker/tracker)
	var/obj/item/container = locateUID(tracker.container_uid)
	var/total_volume = container.reagents.total_volume
	var/calculated_volume = 0
	var/calculated_quality = 0

	var/list/applied_steps = tracker.recipes_last_completed_step[src]
	for(var/i in 1 to length(applied_steps))
		var/current_index = applied_steps[i]
		var/datum/cooking/recipe_step/add_reagent/add_reagent_step = steps[current_index]
		if(!istype(add_reagent_step))
			continue

		calculated_volume += add_reagent_step.amount
		calculated_quality += add_reagent_step.base_quality_award

	return calculated_quality - (total_volume - calculated_volume)

/proc/initialize_cooking_recipes()
	GLOB.pcwj_recipe_dictionary.Cut()
	GLOB.pcwj_cookbook_lookup.Cut()
	var/list/recipe_paths = subtypesof(/datum/cooking/recipe)
	for(var/path in recipe_paths)
		var/datum/cooking/recipe/example_recipe = new path()
		if(!example_recipe.cooking_container)
			continue

		var/obj/item/reagent_containers/cooking/cooking_container = example_recipe.cooking_container

		LAZYORASSOCLIST(GLOB.pcwj_recipe_dictionary, example_recipe.cooking_container, example_recipe)

		if(!example_recipe.appear_in_default_catalog)
			continue

		if(example_recipe.product_type)
			var/atom/product = example_recipe.product_type

			var/list/entry = list()
			entry["name"] = product::name
			entry["container"] = "[cooking_container::preposition] \a [cooking_container::name]"
			entry["instructions"] = list()
			for(var/datum/cooking/recipe_step/step in example_recipe.steps)
				entry["instructions"] += step.get_pda_formatted_desc()

			GLOB.pcwj_cookbook_lookup += list(entry)
