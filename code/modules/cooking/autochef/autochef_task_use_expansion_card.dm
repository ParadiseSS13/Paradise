RESTRICT_TYPE(/datum/autochef_task/use_expansion_card)

/datum/autochef_task/use_expansion_card
	var/obj/item/autochef_expansion_card/card
	var/expected_result_type
	var/expected_result_amount
	var/list/signal_handlers = list()

/datum/autochef_task/use_expansion_card/debug_string()
	return "[type]: [card.type] current_state=[autochef_act_to_string(current_state)]"

/datum/autochef_task/use_expansion_card/New(obj/machinery/autochef/autochef_, obj/item/autochef_expansion_card/card_, expected_result_type_, expected_result_amount_ = 1)
	autochef = autochef_
	card = card_
	expected_result_type = expected_result_type_
	expected_result_amount = expected_result_amount_

/datum/autochef_task/use_expansion_card/resume()
	current_state = card.perform_step(src, expected_result_type)
	if(current_state == AUTOCHEF_ACT_COMPLETE && length(card.contents))
		autochef.move_output_from_container(card)
		return

/datum/autochef_task/use_expansion_card/finalize()
	for(var/datum/handler in signal_handlers)
		UnregisterSignal(handler, list(COMSIG_MACHINE_PROCESS_COMPLETE, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))

	return

/datum/autochef_task/use_expansion_card/reset()
	return

/datum/autochef_task/use_expansion_card/proc/on_machine_process_complete(datum/source, list/created)
	SIGNAL_HANDLER // COMSIG_MACHINE_PROCESS_COMPLETE

	signal_handlers |= source

	// if the machine's process resulted in newly created things,
	// move those things to our card so they can be dealt with.
	if(islist(created))
		for(var/atom/movable/AM in created)
			if(card.is_valid_output(AM))
				AM.forceMove(card)

	current_state = AUTOCHEF_ACT_STEP_COMPLETE

/datum/autochef_task/use_expansion_card/proc/on_atom_after_successful_initialized_on(datum/source, atom/movable/object)
	SIGNAL_HANDLER // COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON

	signal_handlers |= source

	if(istype(object) && card.is_valid_output(object))
		object.forceMove(card)

	current_state = AUTOCHEF_ACT_STEP_COMPLETE
