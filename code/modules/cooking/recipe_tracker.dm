/// A single attempt to perform a step in a recipe.
/// These are created in a recipe tracker and not kept around.
/// This exists only to make the bookkeeping around recipe tracking easier.
/datum/cooking/step_attempt
	var/conditions_met
	var/current_step_index
	var/datum/cooking/recipe/recipe
	var/datum/cooking/recipe_step/recipe_step

/datum/cooking/step_attempt/New(
		datum/cooking/recipe/recipe,
		datum/cooking/recipe_step/recipe_step,
		current_step_index,
		conditions_met
	)
	src.recipe = recipe
	src.recipe_step = recipe_step
	src.current_step_index = current_step_index
	src.conditions_met = conditions_met

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
	log_debug("/datum/cooking/recipe_tracker/proc/process_item_wrap([user], [used])")
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
	var/list/completed_recipes = list()
	var/list/step_datas = list()
	var/list/step_attempts = list()
	var/completed_steps = 0

	for(var/datum/cooking/recipe/recipe in recipes_last_completed_step)
		var/current_idx = recipes_last_completed_step[recipe]
		var/datum/cooking/recipe_step/next_step

		do
			next_step = recipe.steps[++current_idx]
			var/conditions_met = next_step.check_conditions_met(used, src)
			if(conditions_met == PCWJ_CHECK_VALID || conditions_met == PCWJ_CHECK_SILENT)
				step_attempts += new/datum/cooking/step_attempt(
					recipe, next_step, current_idx, conditions_met)
		while(next_step && next_step.optional && current_idx <= length(recipe.steps))

	if(!length(step_attempts))
		return PCWJ_NO_STEPS

	for(var/datum/cooking/step_attempt/step_attempt in step_attempts)
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
		if(!(step_attempt.recipe_step.type in step_datas))
			var/step_data = step_attempt.recipe_step.follow_step(used, src)
			if(islist(step_data))
				step_datas[step_attempt.recipe_step.type] = step_data
				step_reaction_message = step_datas[step_attempt.recipe_step.type]["message"]

		var/previous_step = recipes_last_completed_step[step_attempt.recipe]
		if(step_attempt.recipe_step.is_complete(used, src, step_datas[step_attempt.recipe_step.type]))
			recipes_last_completed_step[step_attempt.recipe] = step_attempt.current_step_index
			LAZYOR(recipes_all_applied_steps[step_attempt.recipe], step_attempt.current_step_index)
			completed_steps++

			if(step_attempt.recipe_step == step_attempt.recipe.steps[length(step_attempt.recipe.steps)])
				completed_recipes += step_attempt.recipe
		else
			recipes_last_completed_step[step_attempt.recipe] = previous_step

	if(length(step_datas) > 1)
		var/list/types = list()
		for(var/step_type in step_datas)
			types += "[step_type]"
		log_debug("More than one valid step data at the same step, this shouldn't happen. Valid steps: [jointext(types, ", ")]")

	var/obj/item/reagent_containers/cooking/container = locateUID(container_uid)
	if(completed_steps)
		var/list/first_applied_step_data = step_datas[1]
		recipes_applied_step_data += list(step_datas[first_applied_step_data])

		// Empty out the stove data here so that it can be reused from zero for
		// other cooking steps, as well as to prevent cheatiness where a recipe
		// gets all of its cooking time done before it was supposed to in the
		// recipe order
		if(container)
			container.clear_cooking_data()

		if("signal" in first_applied_step_data)
			SEND_SIGNAL(container, first_applied_step_data["signal"])
	else
		return PCWJ_PARTIAL_SUCCESS

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
				to_chat(user, SPAN_NOTICE("You have completed \a [result]!"))
			else
				log_debug("failure to create result for recipe tracker")

		return PCWJ_COMPLETE

	// any recipes that have fewer completed steps than the number
	// of steps we've actually accomplished shouldn't be considered
	var/completed_step_count = length(recipes_applied_step_data)
	for(var/recipe in recipes_last_completed_step)
		if(!(recipe in recipes_all_applied_steps) || length(recipes_all_applied_steps[recipe]) < completed_step_count)
			recipes_last_completed_step.Remove(recipe)

	return PCWJ_SUCCESS
