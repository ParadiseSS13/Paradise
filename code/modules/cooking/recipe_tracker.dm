/// A recipe tracker is an abstract representation of the progress that a
/// cooking container has made towards any of its possible recipe outcomes.
///
/// When items are added/steps are performed on a cooking container, the tracker
/// is responsible for determining what known recipes are possible after the
/// step occurs, and tracking whether or not the step was successful. Once a
/// step has been performed that ends a recipe and is successful, the tracker
/// coordinates with the winning recipe to create the result, using what it
/// knows about the steps performed to choose the quality and other attributes
/// of the output.
/datum/cooking/recipe_tracker
	/// The parent object holding the recipe tracker.
	var/container_uid
	/// Tells if steps have been taken for this recipe.
	var/recipe_started = FALSE
	/// A list of recipe types to the index of the latest step we know we've
	/// gotten to.
	var/list/recipes_last_completed_step = list()
	/// A list of recipe types to list of step indices we know we've performed.
	/// Ensures we don't perform e.g. optional steps we skipped on completion.
	var/list/recipes_all_applied_steps = list()
	/// A list of recipe types to metadata returned from completing its steps.
	/// This may include things like a custom message shown to the player, or
	/// the UID of relevant items used for determining quality at recipe
	/// completion.
	var/list/recipes_applied_step_data = list()
	var/step_reaction_message

/datum/cooking/recipe_tracker/New(obj/item/reagent_containers/cooking/container)
	container_uid = container.UID()

/datum/cooking/recipe_tracker/Destroy(force, ...)
	// Not QDEL_LIST_CONTENTS because there's references to the global recipe
	// singletons.
	recipes_last_completed_step.Cut()
	recipes_all_applied_steps.Cut()
	recipes_applied_step_data.Cut()

	return ..()

/// Wrapper function for analyzing process_item internally.
/datum/cooking/recipe_tracker/proc/process_item_wrap(mob/user, obj/used)
	#ifdef PCWJ_DEBUG
	log_debug("/datum/cooking/recipe_tracker/proc/process_item_wrap called!")
	#endif

	var/response = process_item(user, used)
	if(response == PCWJ_SUCCESS || response == PCWJ_COMPLETE || response == PCWJ_PARTIAL_SUCCESS)
		if(!recipe_started)
			recipe_started = TRUE
	return response

/// Core function that checks if a object meets all the requirements for certain
/// recipe actions.
///
/// This is one of the thornier and grosser parts of the cooking system and most
/// people working with it or implementing recipes should never have to look at
/// this. The core idea is:
///
/// * we keep track of what recipes are still valid outcomes by testing the used
///   item against the list of recipes which are valid so far.
/// * each valid recipe is at a certain step, and check the used object against
///   [/datum/cooking/recipe_step/proc/check_conditions_met]. if we meet the
///   conditions, we track the recipe and the step.
/// * for each unique step type that we're tracking, call
///   [/datum/cooking/recipe_step/proc/follow_step] on the first instance of
///   that step type, then [/datum/cooking/recipe_step/proc/is_complete] on
///   all recipe step instances of that type, to see if we advance their
///   respective recipes.
///
/// Once a recipe reaches its final step, the tracker completes the recipe and
/// typically stops existing at that point.
/datum/cooking/recipe_tracker/proc/process_item(mob/user, obj/used)
	// TODO: I *hate* passing in a user here and want to move all the necessary
	// UI interactions (selecting which recipe to complete, selecting which step
	// to perform) to be moved somewhere else entirely.
	var/list/valid_steps = list()
	var/list/valid_recipes = list()
	var/list/completed_recipes = list()
	var/list/silent_recipes = list()
	var/list/attempted_step_per_recipe = list()

	for(var/datum/cooking/recipe/recipe in recipes_last_completed_step)
		var/current_idx = recipes_last_completed_step[recipe]
		var/datum/cooking/recipe_step/next_step

		var/match = FALSE
		do
			next_step = recipe.steps[++current_idx]
			var/conditions = next_step.check_conditions_met(used, src)
			if(conditions == PCWJ_CHECK_VALID)
				LAZYADD(valid_steps[next_step.type], next_step)
				LAZYADD(valid_recipes[next_step.type], recipe)
				attempted_step_per_recipe[recipe] = current_idx
				match = TRUE
				break
			else if(conditions == PCWJ_CHECK_SILENT)
				LAZYADD(silent_recipes, recipe)
		while(next_step && next_step.optional && current_idx <= length(recipe.steps))

		if(match)
			LAZYOR(recipes_all_applied_steps[recipe], current_idx)
			if(length(recipe.steps) == current_idx)
				completed_recipes |= recipe

	if(!length(valid_steps))
		if(length(silent_recipes))
			return PCWJ_PARTIAL_SUCCESS
		return PCWJ_NO_STEPS

	var/list/recipes_with_completed_steps = list()
	var/list/step_data
	var/complete_steps = 0
	for(var/step_type in valid_steps)
		// For each valid step type we only call follow_step() once since it's
		// pointless to e.g. add an item to the container more than once.
		//
		// However, we are still calling follow_step more than once. which means
		// we have to deal with the possibility that two valid steps may do two
		// different things with the used item and may expect different results.
		// Sojurn tried to handle this by adding a user prompt at this point,
		// asking which step the player wanted to perform. I want to avoid
		// throwing up interfaces during cooking, especially when unexpected, so
		// for now, we do nothing, and just watch out for situations where two
		// different recipe steps with incompatible end states are valid with
		// the same object.
		var/datum/cooking/recipe_step/sample_step = valid_steps[step_type][1]
		step_data = sample_step.follow_step(used, src)
		step_reaction_message = step_data["message"]

		for(var/i in 1 to length(valid_recipes[step_type]))
			var/datum/cooking/recipe/recipe = valid_recipes[step_type][i]
			var/datum/cooking/recipe_step/recipe_step = valid_steps[step_type][i]
			if(recipe_step.is_complete(used, src, step_data))
				recipes_last_completed_step[recipe] = attempted_step_per_recipe[recipe]
				recipes_with_completed_steps |= recipe
				complete_steps++

	var/obj/item/reagent_containers/cooking/container = locateUID(container_uid)
	if(complete_steps)
		recipes_applied_step_data += list(step_data)

		// Empty out the stove data here so that it can be reused from zero for
		// other cooking steps, as well as to prevent cheatiness where a recipe
		// gets all of its cooking time done before it was supposed to in the
		// recipe order
		if(container)
			container.clear_cooking_data()

		if("signal" in step_data)
			SEND_SIGNAL(container, step_data["signal"])
	else
		return PCWJ_PARTIAL_SUCCESS

	for(var/recipe in recipes_last_completed_step)
		if(!(recipe in recipes_with_completed_steps))
			recipes_last_completed_step -= recipe

	var/datum/cooking/recipe/recipe_to_complete
	if(length(completed_recipes))
		if(length(completed_recipes) == 1)
			recipe_to_complete = completed_recipes[1]
		else if(length(completed_recipes) > 1)
			var/list/types = list()
			for(var/datum/cooking/recipe/recipe in completed_recipes)
				types += "[recipe.type]"
			log_debug("More than one valid recipe completion at the same step, this shouldn't happen. Valid recipes: [jointext(types, ", ")]")
			recipe_to_complete = completed_recipes[1]

	if(recipe_to_complete)
		var/result = recipe_to_complete.create_product(src)
		if(!container)
			return PCWJ_COMPLETE

		if(user && user.Adjacent(container))
			if(result)
				to_chat(user, "<span class='notice'>You have completed \a [result]!</span>")
			else
				log_debug("failure to create result for recipe tracker")

		return PCWJ_COMPLETE

	return PCWJ_SUCCESS
