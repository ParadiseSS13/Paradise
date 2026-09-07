/datum/autochef_task/follow_recipe
	var/datum/cooking/recipe/recipe
	var/obj/item/reagent_containers/cooking/container
	var/current_step = 1

/datum/autochef_task/follow_recipe/New(obj/machinery/autochef/autochef_, datum/cooking/recipe/recipe_)
	autochef = autochef_
	recipe = recipe_

/datum/autochef_task/follow_recipe/Destroy(force, ...)
	. = ..()
	autochef = null
	container = null
	recipe = null

/datum/autochef_task/follow_recipe/proc/register_for_completion(obj/item/reagent_containers/cooking/container)
	RegisterSignal(container, COMSIG_COOK_MACHINE_STEP_COMPLETE, PROC_REF(on_machine_step_complete), override = TRUE)
	RegisterSignal(container, COMSIG_COOK_MACHINE_STEP_INTERRUPTED, PROC_REF(on_machine_step_interrupted), override = TRUE)

/datum/autochef_task/follow_recipe/proc/unregister_for_completion()
	UnregisterSignal(src, list(COMSIG_COOK_MACHINE_STEP_COMPLETE, COMSIG_COOK_MACHINE_STEP_INTERRUPTED))

/datum/autochef_task/follow_recipe/proc/on_machine_step_complete(obj/item/reagent_containers/cooking/container, datum/cooking_surface/surface)
	SIGNAL_HANDLER // COMSIG_COOK_MACHINE_STEP_COMPLETE
	if(istype(surface))
		surface.turn_off()
	unregister_for_completion()
	current_state = AUTOCHEF_ACT_COMPLETE

/datum/autochef_task/follow_recipe/proc/on_machine_step_interrupted(datum/cooking/recipe_tracker, datum/cooking_surface/surface)
	SIGNAL_HANDLER // COMSIG_COOK_MACHINE_STEP_INTERRUPTED
	if(istype(surface))
		surface.turn_off()
	unregister_for_completion()
	current_state = AUTOCHEF_ACT_INTERRUPTED

/datum/autochef_task/follow_recipe/resume()
	switch(current_state)
		if(AUTOCHEF_ACT_STARTED)
			var/obj/item/reagent_containers/cooking/target = autochef.find_free_container(recipe.container_type)
			if(target)
				target.claim(autochef)
				autochef.atom_say("[target] located.")
				current_state = AUTOCHEF_ACT_FOLLOW_STEPS
				container = target
				return
		if(AUTOCHEF_ACT_FOLLOW_STEPS)
			var/datum/cooking/recipe_step/step = recipe.steps[current_step]
			if(step.optional)
				current_step++
				return

			var/result = step.attempt_autochef_perform(src)
			switch(result)
				if(AUTOCHEF_ACT_STEP_COMPLETE)
					current_step++
					if(current_step > length(recipe.steps))
						current_state = AUTOCHEF_ACT_COMPLETE
				if(AUTOCHEF_ACT_WAIT_FOR_RESULT)
					autochef.set_display("screen-fire")
					current_state = AUTOCHEF_ACT_WAIT_FOR_RESULT
				if(AUTOCHEF_ACT_FAILED)
					autochef.atom_say("Recipe failed.")
					autochef.set_display("screen-error")
					current_state = AUTOCHEF_ACT_FAILED
				if(AUTOCHEF_ACT_MISSING_INGREDIENT)
					autochef.set_display("screen-error")
					current_state = AUTOCHEF_ACT_INTERRUPTED
				if(AUTOCHEF_ACT_NO_AVAILABLE_MACHINES)
					autochef.set_display("screen-error")
					current_state = AUTOCHEF_ACT_INTERRUPTED
		if(AUTOCHEF_ACT_INTERRUPTED)
			autochef.atom_say("Attempting to resume...")
			current_state = AUTOCHEF_ACT_FOLLOW_STEPS

/datum/autochef_task/follow_recipe/finalize()
	autochef.atom_say("Recipe complete.")
	autochef.set_display("screen-complete")
	var/moved = FALSE
	for(var/i = length(autochef.linked_storages); i >= 1; i--)
		var/obj/machinery/smartfridge/storage = autochef.linked_storages[i]
		if(!istype(storage))
			continue
		for(var/atom/movable/result in container.contents)
			if(isInSight(autochef, storage) && storage.load(result))
				storage.Beam(get_turf(container), icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
				SStgui.update_uis(storage)
				moved = TRUE
		if(moved)
			break

	// If we can't find somewhere to store it, just toss it
	// on a nearby table.
	if(!moved)
		var/turf/center = get_turf(container)
		for(var/turf/T in RANGE_EDGE_TURFS(1, center))
			if(locate(/obj/structure/table) in T)
				for(var/atom/movable/content in container.contents)
					if(content.forceMove(T))
						content.pixel_x = rand(-8, 8)
						content.pixel_y = rand(-8, 8)
					else
						content.forceMove(content.loc)

	container.unclaim()
	container.do_empty()

/datum/autochef_task/follow_recipe/reset()
	container = null
	current_step = 1
	current_state = AUTOCHEF_ACT_STARTED
