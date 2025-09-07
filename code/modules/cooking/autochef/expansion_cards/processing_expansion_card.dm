RESTRICT_TYPE(/obj/item/autochef_expansion_card/processing)

#define MODE_NONE 0
#define MODE_GRIND 1
#define MODE_JUICE 2

/obj/item/autochef_expansion_card/processing
	name = "\improper Autochef Expansion Card: Processing"
	desc = "This extremely rare expansion card enables autochefs to utilize grinders and food processors."
	icon_state = "autochef_expansion_card_purple"
	task_message = "Food-processing"
	registerable_machines = list(
		/obj/machinery/chem_master/condimaster,
		/obj/machinery/reagentgrinder,
	)
	// gross to hang on to this but idk how to get this from the task to the card
	// after the grinder has finished grinding something
	var/obj/machinery/reagentgrinder/current_grinder

/obj/item/autochef_expansion_card/processing/can_produce(obj/machinery/autochef/autochef, target_type)
	var/valid_condimasters = 0
	var/available_reagent = 0

	for(var/obj/machinery/reagentgrinder/grinder in autochef.get_linked_objects(/obj/machinery/reagentgrinder))
		// lots of early breakouts because of horrid nested loop
		if(available_reagent > 0)
			break
		for(var/obj/machinery/smartfridge/fridge in autochef.linked_storages)
			if(available_reagent > 0)
				break
			for(var/obj/item/food/grown/grown in fridge)
				var/datum/reagent/reagent = grown.reagents.has_reagent(target_type)
				if(reagent)
					available_reagent += reagent.volume
					break

				var/list/blend = grinder.get_special_blend(grown)
				if(blend && (target_type in blend))
					available_reagent++ // sentinel increase, calculating available values hard
					break

				var/list/juice = grinder.get_special_juice(grown)
				if(juice && (target_type in juice))
					available_reagent++ // sentinel increase, calculating available values hard
					break

	for(var/obj/machinery/chem_master/condimaster/condimaster in autochef.get_linked_objects(/obj/machinery/chem_master/condimaster))
		valid_condimasters++

	if(!valid_condimasters)
		return AUTOCHEF_ACT_MISSING_MACHINE

	if(available_reagent > 0)
		return AUTOCHEF_ACT_VALID

	return AUTOCHEF_ACT_MISSING_INGREDIENT

/obj/item/autochef_expansion_card/processing/perform_step(datum/autochef_task/origin_task, target_type)
	autochef.set_display("screen-gear")

	switch(origin_task.current_state)
		if(AUTOCHEF_ACT_STARTED)
			return attempt_grinding(origin_task, target_type)
		if(AUTOCHEF_ACT_STEP_COMPLETE)
			return attempt_bottling()
		if(AUTOCHEF_ACT_WAIT_FOR_RESULT)
			return AUTOCHEF_ACT_WAIT_FOR_RESULT
		if(AUTOCHEF_ACT_FAILED)
			autochef.remove_task(origin_task)
			return AUTOCHEF_ACT_FAILED

/obj/item/autochef_expansion_card/processing/proc/attempt_grinding(datum/autochef_task/origin_task, target_type)
	var/datum/reagent/reagent = GLOB.chemical_reagents_list[target_type]
	// for each grinder we have access to:
	// - see if it can make what we need
	// - see if it has something in the output container already (no mixing outputs!)
	// - see if there's something in the hopper already (no mixing inputs!)
	// - if there is one type of thing in the hopper, see if it's something we can use
	// - how do we know if we have enough ingredients to make the amount of output we need? uhhhhhhhh
	//   i suspect we're going to just fill the grinder with the input as much as we can
	//   and then just repeatedly test to see if we've made enough
	// - oh yeah and since we can't make bottles out of thin air we need to connect
	//   to a condimaster too to make bottles of things! amazing!
	for(var/obj/machinery/reagentgrinder/grinder in autochef.get_linked_objects(/obj/machinery/reagentgrinder))
		if(!grinder.beaker)
			continue

		if(!grinder.beaker.reagents.is_empty())
			continue

		var/mode = MODE_NONE

		var/sole_input
		var/list/found_inputs = list()
		for(var/atom/movable/AM in grinder.holdingitems)
			found_inputs[AM.type]++
			sole_input = AM

		if(length(found_inputs) > 1)
			return AUTOCHEF_ACT_NO_AVAILABLE_MACHINES

		var/contains_valid_input_already = FALSE
		if(length(found_inputs) == 1)
			var/list/blend_items = grinder.get_special_blend(sole_input)
			if(blend_items && (target_type in blend_items))
				mode = MODE_GRIND
				contains_valid_input_already = TRUE
				break
			var/list/juice_items = grinder.get_special_juice(sole_input)
			if(juice_items && (target_type in juice_items))
				mode = MODE_JUICE
				contains_valid_input_already = TRUE
				break

		var/list/possible_items = list()
		if(!contains_valid_input_already)
			for(var/obj/machinery/smartfridge/fridge in autochef.linked_storages)
				for(var/obj/item/food/grown/possible_item in fridge)
					if(possible_item.reagents.has_reagent(target_type))
						possible_items += possible_item
						mode = MODE_GRIND
						continue
					var/list/blend_items = grinder.get_special_blend(possible_item)
					if(blend_items && (target_type in blend_items))
						possible_items += possible_item
						mode = MODE_GRIND
						continue
					var/list/juice_items = grinder.get_special_juice(possible_item)
					if(juice_items && (target_type in juice_items))
						possible_items += possible_item
						mode = MODE_JUICE
						continue

		while(length(grinder.holdingitems) < grinder.limit && length(possible_items))
			var/obj/input_item = possible_items[possible_items.len]
			possible_items.len--

			var/obj/machinery/smartfridge/fridge = input_item.loc
			if(!istype(fridge) || !(isInSight(autochef, fridge)))
				continue

			input_item.forceMove(grinder)
			grinder.holdingitems += input_item
			fridge.item_quants[input_item.name]--
			fridge.Beam(grinder, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
			fridge.update_appearance()

		var/datum/autochef_task/use_expansion_card/card_task = origin_task
		switch(mode)
			if(MODE_JUICE)
				autochef.atom_say("Juicing [reagent.name].")
				current_grinder = grinder
				card_task.RegisterSignal(current_grinder, COMSIG_MACHINE_PROCESS_COMPLETE, TYPE_PROC_REF(/datum/autochef_task/use_expansion_card, on_machine_process_complete))
				current_grinder.juice()
				return AUTOCHEF_ACT_WAIT_FOR_RESULT
			if(MODE_GRIND)
				autochef.atom_say("Grinding [reagent.name].")
				current_grinder = grinder
				card_task.RegisterSignal(current_grinder, COMSIG_MACHINE_PROCESS_COMPLETE, TYPE_PROC_REF(/datum/autochef_task/use_expansion_card, on_machine_process_complete))
				current_grinder.grind()
				return AUTOCHEF_ACT_WAIT_FOR_RESULT
			if(MODE_NONE)
				autochef.atom_say("Unknown error in [src]. please contact customer support.")
				return AUTOCHEF_ACT_FAILED

/obj/item/autochef_expansion_card/processing/proc/attempt_bottling()
	autochef.atom_say("Bottling reagents.")
	if(!current_grinder || !isInSight(current_grinder, autochef))
		return AUTOCHEF_ACT_MISSING_MACHINE

	for(var/obj/machinery/chem_master/condimaster/condimaster in autochef.get_linked_objects(/obj/machinery/chem_master/condimaster))
		if(condimaster.beaker)
			continue
		if(length(condimaster.reagents.reagent_list))
			continue

		autochef.Beam(current_grinder, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
		autochef.Beam(condimaster, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
		current_grinder.beaker.forceMove(condimaster)
		condimaster.beaker = current_grinder.beaker
		condimaster.update_appearance()
		current_grinder.beaker = null
		current_grinder.update_appearance()

		var/datum/chemical_production_mode/production_mode = condimaster.production_modes["condi_bottles"]
		if(!production_mode)
			return AUTOCHEF_ACT_FAILED

		while(!condimaster.beaker.reagents.is_empty())
			for(var/datum/reagent/R in condimaster.beaker.reagents.reagent_list)
				var/datum/reagents/temp = new
				condimaster.beaker.reagents.trans_id_to(temp, R.id, 50)
				production_mode.synthesize(null, src, temp)

			for(var/obj/item/reagent_containers/condiment/bottle in contents)
				if(bottle.name == "condiment bottle" && length(bottle.reagents.reagent_list) == 1)
					var/name = bottle.reagents.get_master_reagent_name()
					bottle.name = "[name] bottle"
					bottle.desc = "An autochef produced bottle of [name]."
					bottle.update_appearance(UPDATE_NAME|UPDATE_DESC)

		if(length(contents))
			if(!current_grinder.beaker)
				condimaster.beaker.forceMove(current_grinder)
				current_grinder.beaker = condimaster.beaker
				condimaster.beaker = null
				current_grinder.update_appearance()
				condimaster.update_appearance()

			current_grinder = null
			return AUTOCHEF_ACT_COMPLETE

	return AUTOCHEF_ACT_FAILED

#undef MODE_NONE
#undef MODE_GRIND
#undef MODE_JUICE
