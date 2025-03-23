RESTRICT_TYPE(/datum/cooking/recipe_step/add_reagent)

/datum/cooking/recipe_step/add_reagent
	var/expected_total
	var/reagent_id
	var/amount
	/// What percentage of the reagent ends up in the product, as a value from 0.0 to 1.0
	var/remain_percent = 0.0

/datum/cooking/recipe_step/add_reagent/New(reagent_id_,  amount_, options)
	reagent_id = reagent_id_
	amount = amount_

	if("remain_percent" in options)
		remain_percent = options["remain_percent"]

	..(options)

/datum/cooking/recipe_step/add_reagent/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	// Autochefs may do this up front before a tracker exists if nothing
	// has been added to the container yet. In this case, we just check
	// to see if the container has what we need.
	if(!tracker)
		if(!(used_item.container_type & OPENCONTAINER))
			return PCWJ_CHECK_INVALID

		var/obj/item/reagent_containers/reagent_container = used_item
		if(istype(reagent_container))
			if(reagent_container.reagents.has_reagent(reagent_id, amount))
				return PCWJ_CHECK_VALID

		return PCWJ_CHECK_INVALID


	var/obj/item/container = locateUID(tracker.container_uid)

	// Potentially might break shit, but we'll see; if we're currently being
	// processed on a cooking machine, look for that case specifically, and just
	// check to make sure we have the amount of reagents we need already, in
	// order to skip this step.
	//
	// This should hopefully make it easier to deal with adding reagents across
	// steps if, for example, you are adding a mix of reagents from a container,
	// or if you added the reagents in two consecutive steps in the wrong order
	// (e.g. adding pepper before salt versus salt before pepper, which really
	// shouldn't matter.)
	if(istype(used_item, /obj/machinery/cooking))
		if(container.reagents.has_reagent(reagent_id, amount))
			return PCWJ_CHECK_VALID

		return PCWJ_CHECK_SILENT

	if((container.reagents.total_volume + amount - container.reagents.get_reagent_amount(reagent_id)) > container.reagents.maximum_volume)
		return PCWJ_CHECK_FULL

	if(!istype(used_item, /obj/item/reagent_containers))
		return PCWJ_CHECK_INVALID
	if(!(used_item.container_type & OPENCONTAINER))
		return PCWJ_CHECK_INVALID

	var/obj/item/reagent_containers/reagent_container = used_item
	if(!istype(reagent_container))
		return PCWJ_CHECK_INVALID
	if(reagent_container.amount_per_transfer_from_this <= 0)
		return PCWJ_CHECK_INVALID
	if(reagent_container.reagents.total_volume == 0)
		return PCWJ_CHECK_INVALID

	if(reagent_container.reagents.total_volume)
		var/part = reagent_container.reagents.get_reagent_amount(reagent_id) / reagent_container.reagents.total_volume
		var/incoming_amount = max(0, min(reagent_container.amount_per_transfer_from_this, reagent_container.reagents.total_volume, container.reagents.get_free_space()))
		var/incoming_valid_amount = incoming_amount * part

		if(incoming_valid_amount > 0)
			return PCWJ_CHECK_VALID

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe_step/add_reagent/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/our_item = used_item
	if(!istype(our_item))
		return list()

	var/obj/item/container = locateUID(tracker.container_uid)
	var/trans = our_item.reagents.trans_to(container, our_item.amount_per_transfer_from_this)

	return list(message = "You transfer [trans] units to \the [container].")

/datum/cooking/recipe_step/add_reagent/is_complete(obj/used_item, datum/cooking/recipe_tracker/tracker, list/step_data)
	var/obj/item/container = locateUID(tracker.container_uid)
	if(!istype(container))
		return FALSE
	return container.reagents.has_reagent(reagent_id, amount)

/datum/cooking/recipe_step/add_reagent/get_pda_formatted_desc()
	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
	return "Add [amount] unit[amount > 1 ? "s" : ""] of [reagent.name]."

/datum/cooking/recipe_step/add_reagent/attempt_autochef_perform(datum/autochef_task/follow_recipe/task)
	for(var/obj/machinery/smartfridge/storage in task.autochef.linked_storages)
		for(var/obj/item/reagent_containers/container in storage)
			if(check_conditions_met(container, task.container.tracker))
				var/old_amount_per_transfer = container.amount_per_transfer_from_this
				container.amount_per_transfer_from_this = amount
				var/result = task.container.process_item(null, container)
				container.amount_per_transfer_from_this = old_amount_per_transfer

				switch(result)
					if(PCWJ_CONTAINER_FULL, PCWJ_NO_STEPS, PCWJ_NO_RECIPES)
						return AUTOCHEF_ACT_FAILED
					if(PCWJ_SUCCESS, PCWJ_PARTIAL_SUCCESS, PCWJ_COMPLETE)
						task.autochef.Beam(storage, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
						return AUTOCHEF_ACT_STEP_COMPLETE

	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
	task.autochef.atom_say("Missing [reagent.name].")
	return AUTOCHEF_ACT_MISSING_REAGENT

/datum/cooking/recipe_step/add_reagent/attempt_autochef_prepare(obj/machinery/autochef/autochef)
	for(var/storage in autochef.linked_storages)
		for(var/obj/item/reagent_containers/container in storage)
			if(container.reagents.has_reagent(reagent_id, amount))
				return AUTOCHEF_ACT_VALID

	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
	autochef.atom_say("Cannot find [reagent.name].")
	return AUTOCHEF_ACT_MISSING_REAGENT
