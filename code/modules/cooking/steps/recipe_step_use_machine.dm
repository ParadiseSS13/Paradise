/datum/cooking/recipe_step/use_machine
	var/time
	var/temperature
	var/obj/machinery/cooking/machine_type
	var/cooker_surface_name

/datum/cooking/recipe_step/use_machine/New(temperature_, time_, options)
	temperature = temperature_
	time = time_

	..(options)

/datum/cooking/recipe_step/use_machine/proc/extra_machine_step(obj/machinery/cooking/machine)
	return

/datum/cooking/recipe_step/use_machine/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/cooking/container = locateUID(tracker.container_uid)

	if(container.get_cooker_time(cooker_surface_name, temperature) >= time)
		return PCWJ_CHECK_VALID

	if(istype(used_item, machine_type))
		return PCWJ_CHECK_SILENT

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe_step/use_machine/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	var/list/step_data = list(target = used_item.UID())
	var/obj/item/reagent_containers/cooking/container = locateUID(tracker.container_uid)
	if(istype(container))
		step_data["cooker_data"] = container.cooker_data.Copy()

	if(istype(used_item, machine_type))
		var/obj/machinery/cooking/machine = used_item
		step_data["rating"] = machine.quality_mod

	step_data["signal"] = COMSIG_COOK_MACHINE_STEP_COMPLETE

	return step_data

/datum/cooking/recipe_step/use_machine/attempt_autochef_perform(datum/autochef_task/follow_recipe/task)
	var/matching_machines = 0
	var/unavailable_machines = 0

	var/obj/item/reagent_containers/cooking/container = task.container
	for(var/obj/machinery/cooking/machine in task.autochef.linked_machines)
		if(!istype(machine, machine_type))
			continue

		if(!can_use_machine(task.autochef, machine))
			continue

		matching_machines++
		var/list/free_surfaces = list()
		for(var/datum/cooking_surface/surface in machine.surfaces)
			if(!surface.container)
				free_surfaces.Add(surface)

			// If the container is already on the machine, no need to move it around
			if(surface.container == container)
				start_cooking(task, surface)
				return AUTOCHEF_ACT_WAIT_FOR_RESULT

		if(length(free_surfaces))
			// Grab that shit
			var/datum/cooking_surface/surface = free_surfaces[1]
			container.Beam(machine, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
			machine.surface_item_interaction(null, container, surface)
			start_cooking(task, surface)
			return AUTOCHEF_ACT_WAIT_FOR_RESULT
		else
			unavailable_machines++

	if(!matching_machines)
		return AUTOCHEF_ACT_MISSING_MACHINE
	if(unavailable_machines)
		return AUTOCHEF_ACT_NO_AVAILABLE_MACHINES

	return AUTOCHEF_ACT_FAILED

/datum/cooking/recipe_step/use_machine/proc/start_cooking(datum/autochef_task/follow_recipe/task, datum/cooking_surface/surface)
	task.autochef.atom_say("Preparing on [surface.parent.name].")
	surface.timer = time
	surface.temperature = temperature
	extra_machine_step(surface.parent)
	if(surface.on)
		surface.handle_cooking(null)
	else
		surface.handle_switch(null)

	task.register_for_completion(surface.container)

/datum/cooking/recipe_step/use_machine/attempt_autochef_prepare(obj/machinery/autochef/autochef)
	for(var/obj/machinery/cooking/machine in autochef.linked_machines)
		if(can_use_machine(autochef, machine))
			return AUTOCHEF_ACT_VALID

	return AUTOCHEF_ACT_NO_AVAILABLE_MACHINES

/datum/cooking/recipe_step/use_machine/proc/can_use_machine(obj/machinery/autochef, obj/machinery/cooking/machine)
	if(machine.stat & (NOPOWER|BROKEN))
		return FALSE

	for(var/datum/cooking_surface/surface in machine.surfaces)
		if(!surface.container)
			return TRUE
		if(surface.container && !surface.container.claimed)
			return TRUE
		if(surface.container && surface.container.claimed == autochef)
			return TRUE

	return FALSE

/datum/cooking/recipe_step/use_machine/oven
	machine_type = /obj/machinery/cooking/oven
	cooker_surface_name = COOKER_SURFACE_OVEN

/datum/cooking/recipe_step/use_machine/oven/get_pda_formatted_desc()
	return "Bake in an oven for [DisplayTimeText(time)] at [lowertext(temperature)] temperature."

/datum/cooking/recipe_step/use_machine/stovetop
	machine_type = /obj/machinery/cooking/stovetop
	cooker_surface_name = COOKER_SURFACE_STOVE

/datum/cooking/recipe_step/use_machine/stovetop/get_pda_formatted_desc()
	return "Heat on a stove for [DisplayTimeText(time)] at [lowertext(temperature)] temperature."

/datum/cooking/recipe_step/use_machine/ice_cream_mixer
	machine_type = /obj/machinery/cooking/ice_cream_mixer
	cooker_surface_name = COOKER_SURFACE_ICE_CREAM_MIXER

/datum/cooking/recipe_step/use_machine/ice_cream_mixer/New(time_, options)
	..(J_LO, time_, options)

/datum/cooking/recipe_step/use_machine/ice_cream_mixer/get_pda_formatted_desc()
	return "Mix in an ice cream mixer for [DisplayTimeText(time)]."

/datum/cooking/recipe_step/use_machine/grill
	machine_type = /obj/machinery/cooking/grill
	cooker_surface_name = COOKER_SURFACE_GRILL

/datum/cooking/recipe_step/use_machine/grill/get_pda_formatted_desc()
	return "Cook on a grill for [DisplayTimeText(time)] at [lowertext(temperature)] temperature."

/datum/cooking/recipe_step/use_machine/grill/can_use_machine(obj/machinery/autochef, obj/machinery/cooking/machine)
	. = ..()
	var/obj/machinery/cooking/grill/grill = machine
	return . && istype(grill) && grill.stored_wood > 0

/datum/cooking/recipe_step/use_machine/grill/attempt_autochef_perform(datum/autochef_task/follow_recipe/task)
	. = ..()
	if(. == AUTOCHEF_ACT_WAIT_FOR_RESULT)
		RegisterSignal(task.container, COMSIG_COOK_GRILL_NO_FUEL)

/datum/cooking/recipe_step/use_machine/deepfryer
	machine_type = /obj/machinery/cooking/deepfryer
	cooker_surface_name = COOKER_SURFACE_DEEPFRYER

/datum/cooking/recipe_step/use_machine/deepfryer/New(time_, options)
	..(J_LO, time_, options)

/datum/cooking/recipe_step/use_machine/deepfryer/get_pda_formatted_desc()
	return "Deep-fry for [DisplayTimeText(time)]."
