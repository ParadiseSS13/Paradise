RESTRICT_TYPE(/datum/cooking/recipe_step/add_reagent)

/datum/cooking/recipe_step/add_reagent
	var/expected_total
	var/reagent_id
	var/amount
	/// What percentage of the reagent ends up in the product, as a value from 0.0 to 1.0
	var/remain_percent = 1.0

/datum/cooking/recipe_step/add_reagent/New(reagent_id_,  amount_, options)
	reagent_id = reagent_id_
	amount = amount_

	if("remain_percent" in options)
		remain_percent = options["remain_percent"]

	..(options)

/datum/cooking/recipe_step/add_reagent/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
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

	var/obj/item/reagent_containers/our_item = used_item
	if(our_item.amount_per_transfer_from_this <= 0)
		return PCWJ_CHECK_INVALID
	if(our_item.reagents.total_volume == 0)
		return PCWJ_CHECK_INVALID

	return PCWJ_CHECK_VALID

/datum/cooking/recipe_step/add_reagent/calculate_quality(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/container = locateUID(tracker.container_uid)
	var/data = container.reagents.get_data(reagent_id)
	var/cooked_quality = 0
	if(data && islist(data) && data["FOOD_QUALITY"])
		cooked_quality = data["FOOD_QUALITY"]
	return cooked_quality

/datum/cooking/recipe_step/add_reagent/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/our_item = used_item
	if(!istype(our_item))
		return list()

	var/obj/item/container = locateUID(tracker.container_uid)
	var/trans = our_item.reagents.trans_to(container, our_item.amount_per_transfer_from_this)
	playsound(usr, 'sound/effects/Liquid_transfer_mono.ogg', 50, 1)

	return list(message = "You transfer [trans] units to \the [container].")

/datum/cooking/recipe_step/add_reagent/is_complete(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/reagent_containers/our_item = used_item
	var/obj/item/container = locateUID(tracker.container_uid)

	if(istype(used_item, /obj/machinery/cooking))
		if(container.reagents.has_reagent(reagent_id, amount))
			return TRUE
		return FALSE

	if(our_item.reagents.total_volume)
		var/part = our_item.reagents.get_reagent_amount(reagent_id) / our_item.reagents.total_volume
		var/incoming_amount = max(0, min(our_item.amount_per_transfer_from_this, our_item.reagents.total_volume, container.reagents.get_free_space()))
		var/incoming_valid_amount = incoming_amount * part

		var/resulting_total = container.reagents.get_reagent_amount(reagent_id) + incoming_valid_amount
		if(resulting_total >= amount)
			return TRUE

	return FALSE

/datum/cooking/recipe_step/add_reagent/get_pda_formatted_desc()
	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
	return "Add [amount] unit[amount > 1 ? "s" : ""] of [reagent.name]."
