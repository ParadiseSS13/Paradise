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

/datum/autochef_task/follow_recipe/proc/on_machine_step_complete(obj/item/reagent_containers/cooking/container)
	SIGNAL_HANDLER // COMSIG_COOK_MACHINE_STEP_COMPLETE
	unregister_for_completion()
	current_state = AUTOCHEF_TASK_COMPLETE

/datum/autochef_task/follow_recipe/proc/on_machine_step_interrupted(datum/cooking/recipe_tracker)
	SIGNAL_HANDLER // COMSIG_COOK_MACHINE_STEP_INTERRUPTED
	unregister_for_completion()
	current_state = AUTOCHEF_TASK_INTERRUPTED

/datum/autochef_task/follow_recipe/resume()
	switch(current_state)
		if(AUTOCHEF_TASK_START)
			var/obj/item/reagent_containers/cooking/target = autochef.find_free_container(recipe.container_type)
			if(target)
				target.claimed = autochef
				autochef.atom_say("[target] located.")
				current_state = AUTOCHEF_TASK_FOLLOW_STEPS
				container = target
				return
		if(AUTOCHEF_TASK_FOLLOW_STEPS)
			var/datum/cooking/recipe_step/step = recipe.steps[current_step]
			if(step.optional)
				current_step++
				return

			var/result = step.attempt_autochef_perform(src)
			switch(result)
				if(AUTOCHEF_STEP_COMPLETE)
					current_step++
					if(current_step > length(recipe.steps))
						current_state = AUTOCHEF_TASK_COMPLETE
				if(AUTOCHEF_STEP_STARTED)
					autochef.set_display("screen-fire")
					current_state = AUTOCHEF_TASK_WAIT_FOR_RESULT
				if(AUTOCHEF_STEP_FAILURE)
					autochef.atom_say("Recipe failed!")
					autochef.set_display("screen-error")
					current_state = AUTOCHEF_TASK_FAILED
		if(AUTOCHEF_TASK_INTERRUPTED)
			autochef.atom_say("Recipe interrupted!")
			autochef.set_display("screen-error")

/datum/autochef_task/follow_recipe/finalize()
	autochef.atom_say("Recipe complete.")
	var/moved = FALSE
	for(var/obj/machinery/smartfridge/storage in autochef.linked_storages)
		for(var/atom/movable/result in container.contents)
			if(storage.load(result))
				storage.Beam(get_turf(container), icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
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
					content.forceMove(T)
					content.pixel_x = rand(-8, 8)
					content.pixel_y = rand(-8, 8)

	container.do_empty()
	container.claimed = null

/datum/autochef_task/follow_recipe/reset()
	container = null
	current_step = 1
	current_state = AUTOCHEF_TASK_START
