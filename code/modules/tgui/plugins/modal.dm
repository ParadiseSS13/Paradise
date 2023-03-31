/**
 * ui modals
 *
 * Allows creation of modals within tgui.
 */

GLOBAL_LIST(ui_modals)

/**
  * Call this from a proc that is called in ui_act() to process modal actions
  *
  * Example: /obj/machinery/chem_master/proc/ui_act_modal
  * You can then switch based on the return value and show different
  * modals depending on the answer.
  * Arguments:
  * * source - The source datum
  * * action - The called action
  * * params - The params to the action
  */
/datum/proc/ui_modal_act(datum/source = src, action = "", params)
	ASSERT(istype(source))

	. = null
	switch(action)
		if("modal_open") // Params: id, arguments
			return UI_MODAL_OPEN
		if("modal_answer") // Params: id, answer, arguments
			params["answer"] = ui_modal_preprocess_answer(source, params["answer"])
			if(ui_modal_answer(source, params["id"], params["answer"])) // If there's a current modal with a delegate that returned TRUE, no need to continue
				. = UI_MODAL_DELEGATE
			else
				. = UI_MODAL_ANSWER
			ui_modal_clear(source)
		if("modal_close") // Params: id
			ui_modal_clear(source)
			return UI_MODAL_CLOSE

/**
  * Call this from ui_data() to return modal information if needed

  * Arguments:
  * * source - The source datum
  */
/datum/proc/ui_modal_data(datum/source = src)
	ASSERT(istype(source))

	var/datum/ui_modal/current = LAZYACCESS(GLOB.ui_modals, source.UID())
	if(!current)
		return null

	return current.to_data()

/**
  * Clears the current modal for a given datum
  *
  * Arguments:
  * * source - The source datum
  */
/datum/proc/ui_modal_clear(datum/source = src)
	ASSERT(istype(source))

	LAZYINITLIST(GLOB.ui_modals)
	var/datum/ui_modal/previous = GLOB.ui_modals[source.UID()]
	if(!previous)
		return FALSE

	for(var/i in 1 to length(GLOB.ui_modals))
		var/key = GLOB.ui_modals[i]
		if(previous == GLOB.ui_modals[key])
			GLOB.ui_modals.Cut(i, i + 1)
			break

	SStgui.update_uis(source)
	return TRUE

/**
  * Opens a message UI modal
  *
  * Arguments:
  * * source - The source datum
  * * id - The ID of the modal
  * * text - The text to display above the answers
  * * delegate - The proc to call when closed
  * * arguments - List of arguments passed to and from JS (mostly useful for chaining modals)
  */
/datum/proc/ui_modal_message(datum/source = src, id, text = "Default modal message", delegate, arguments)
	ASSERT(length(id))

	var/datum/ui_modal/modal = new(id, text, delegate, arguments)
	return ui_modal_new(source, modal)

/**
  * Opens a text input UI modal
  *
  * Arguments:
  * * source - The source datum
  * * id - The ID of the modal
  * * text - The text to display above the answers
  * * delegate - The proc to call when submitted
  * * arguments - List of arguments passed to and from JS (mostly useful for chaining modals)
  * * value - The default value of the input
  * * max_length - The maximum char length of the input
  */
/datum/proc/ui_modal_input(datum/source = src, id, text = "Default modal message", delegate, arguments, value = "", max_length = UI_MODAL_INPUT_MAX_LENGTH)
	ASSERT(length(id))
	ASSERT(max_length > 0)

	var/datum/ui_modal/input/modal = new(id, text, delegate, arguments, value, max_length)
	return ui_modal_new(source, modal)

/**
  * Opens a dropdown input UI modal
  *
  * Internally checks if the answer is in the list of choices.
  * Arguments:
  * * source - The source datum
  * * id - The ID of the modal
  * * text - The text to display above the answers
  * * delegate - The proc to call when submitted
  * * arguments - List of arguments passed to and from JS (mostly useful for chaining modals)
  * * value - The default value of the dropdown
  * * choices - The list of available choices in the dropdown
  */
/datum/proc/ui_modal_choice(datum/source = src, id, text = "Default modal message", delegate, arguments, value = "", choices)
	ASSERT(length(id))

	var/datum/ui_modal/input/choice/modal = new(id, text, delegate, arguments, value, choices)
	return ui_modal_new(source, modal)

/**
  * Opens a bento input UI modal
  *
  * Internally checks if the answer is in the list of choices.
  * Arguments:
  * * source - The source datum
  * * id - The ID of the modal
  * * text - The text to display above the answers
  * * delegate - The proc to call when submitted
  * * arguments - List of arguments passed to and from JS (mostly useful for chaining modals)
  * * value - The default value of the bento
  * * choices - The list of available choices in the bento
  */
/datum/proc/ui_modal_bento(datum/source = src, id, text = "Default modal message", delegate, arguments, value, choices)
	ASSERT(length(id))

	var/datum/ui_modal/input/bento/modal = new(id, text, delegate, arguments, value, choices)
	return ui_modal_new(source, modal)

/**
  * Opens a yes/no UI modal
  *
  * Arguments:
  * * source - The source datum
  * * id - The ID of the modal
  * * text - The text to display above the answers
  * * delegate - The proc to call when "Yes" is pressed
  * * delegate_no - The proc to call when "No" is pressed
  * * arguments - List of arguments passed to and from JS (mostly useful for chaining modals)
  * * yes_text - The text to show in the "Yes" button
  * * no_text - The text to show in the "No" button
  */
/datum/proc/ui_modal_boolean(datum/source = src, id, text = "Default modal message", delegate, delegate_no, arguments, yes_text = "Yes", no_text = "No")
	ASSERT(length(id))

	var/datum/ui_modal/boolean/modal = new(id, text, delegate, delegate_no, arguments, yes_text, no_text)
	return ui_modal_new(source, modal)

/**
  * Registers a given modal to a source. Private.
  *
  * Arguments:
  * * source - The source datum
  * * modal - The datum/ui_modal to register
  * * replace_previous - Whether any modal currently assigned to source should be replaced
  * * instant_update - Whether the changes should reflect immediately
  */
/datum/proc/ui_modal_new(datum/source = src, datum/ui_modal/modal = null, replace_previous = TRUE, instant_update = TRUE)
	ASSERT(istype(source))
	ASSERT(istype(modal))

	var/datum/ui_modal/previous = LAZYACCESS(GLOB.ui_modals, source.UID())
	if(previous && !replace_previous)
		return FALSE

	modal.owning_source = source

	// Previous one should get GC'd
	LAZYSET(GLOB.ui_modals, source.UID(), modal)
	if(instant_update)
		SStgui.update_uis(source)
	return TRUE

/**
  * Calls the source's currently assigned modal's (if there is one) on_answer() proc. Private.
  *
  * Arguments:
  * * source - The source datum
  * * id - The ID of the modal
  * * answer - The provided answer
  */
/datum/proc/ui_modal_answer(datum/source = src, id, answer = "")
	ASSERT(istype(source))

	var/datum/ui_modal/current = LAZYACCESS(GLOB.ui_modals, source.UID())
	if(!current)
		return FALSE

	return current.on_answer(answer)

/**
  * Passes an answer from JS through the modal's proc.
  *
  * Used namely for cutting the text short if it's longer
  * than an input modal's max_length.
  * Arguments:
  * * source - The source datum
  * * answer - The provided answer
  */
/datum/proc/ui_modal_preprocess_answer(datum/source = src, answer = "")
	ASSERT(istype(source))

	var/datum/ui_modal/current = LAZYACCESS(GLOB.ui_modals, source.UID())
	if(!current)
		return answer

	return current.preprocess_answer(answer)

/**
  * Modal datum (contains base information for a modal)
  */
/datum/ui_modal
	var/datum/owning_source
	var/id
	var/text
	var/delegate
	var/list/arguments
	var/modal_type = "message"

/datum/ui_modal/New(id, text, delegate, list/arguments)
	src.id = id
	src.text = text
	src.delegate = delegate
	src.arguments = arguments

/**
  * Called when it's time to pre-process the answer before using it
  *
  * Arguments:
  * * answer - The answer, a nullable text
  */
/datum/ui_modal/proc/preprocess_answer(answer)
	return reject_bad_text(answer, UI_MODAL_INPUT_MAX_LENGTH) // bleh

/**
  * Called when a modal receives an answer
  *
  * Arguments:
  * * answer - The answer, a nullable text
  */
/datum/ui_modal/proc/on_answer(answer)
	if(delegate)
		return call(owning_source, delegate)(answer, arguments)
	return FALSE

/**
  * Creates a list that describes a modal visually to be passed to JS
  */
/datum/ui_modal/proc/to_data()
	. = list()
	.["id"] = id
	.["text"] = text
	.["args"] = arguments || list()
	.["type"] = modal_type

/**
  * Input modal - has a text entry that can be used to enter an answer
  */
/datum/ui_modal/input
	modal_type = "input"
	var/value
	var/max_length

/datum/ui_modal/input/New(id, text, delegate, list/arguments, value, max_length)
	..(id, text, delegate, arguments)
	src.value = value
	src.max_length = max_length

/datum/ui_modal/input/preprocess_answer(answer)
	. = ..(answer)
	if(length(answer) > max_length)
		. = copytext(., 1, max_length + 1)

/datum/ui_modal/input/to_data()
	. = ..()
	.["value"] = value

/**
  * Choice modal - has a dropdown menu that can be used to select an answer
  */
/datum/ui_modal/input/choice
	modal_type = "choice"
	var/choices

/datum/ui_modal/input/choice/New(id, text, delegate, list/arguments, value, choices)
	..(id, text, delegate, arguments, value, UI_MODAL_INPUT_MAX_LENGTH) // Max length doesn't really matter in dropdowns, but whatever
	src.choices = choices

/datum/ui_modal/input/choice/on_answer(answer)
	if(answer in choices) // Make sure the answer is actually in our choices!
		return ..(answer, arguments)
	return FALSE

/datum/ui_modal/input/choice/to_data()
	. = ..()
	.["choices"] = choices

/**
  * Bento modal - Similar to choice, it displays the choices in a grid of images
  *
  * The returned answer is the index of the choice.
  */
/datum/ui_modal/input/bento
	modal_type = "bento"
	var/choices

/datum/ui_modal/input/bento/New(id, text, delegate, list/arguments, value, choices)
	..(id, text, delegate, arguments, text2num(value), UI_MODAL_INPUT_MAX_LENGTH) // Max length doesn't really matter in here, but whatever
	src.choices = choices

/datum/ui_modal/input/bento/preprocess_answer(answer)
	return text2num(answer) || 0

/datum/ui_modal/input/bento/on_answer(answer)
	if(answer >= 1 && answer <= length(choices)) // Make sure the answer index is actually in our indexes!
		return ..(answer, arguments)
	return FALSE

/datum/ui_modal/input/bento/to_data()
	. = ..()
	.["choices"] = choices

/**
  * Boolean modal - has yes/no buttons that do different actions depending on which is pressed
  */
/datum/ui_modal/boolean
	modal_type = "boolean"
	var/delegate_no
	var/yes_text
	var/no_text

/datum/ui_modal/boolean/New(id, text, delegate, delegate_no, list/arguments, yes_text, no_text)
	..(id, text, delegate, arguments)
	src.delegate_no = delegate_no
	src.yes_text = yes_text
	src.no_text = no_text

/datum/ui_modal/boolean/preprocess_answer(answer)
	return text2num(answer) || FALSE

/datum/ui_modal/boolean/on_answer(answer)
	if(answer)
		return ..(answer, arguments)
	else if(delegate_no)
		return call(owning_source, delegate_no)(arguments)
	return FALSE

/datum/ui_modal/boolean/to_data()
	. = ..()
	.["yes_text"] = yes_text
	.["no_text"] = no_text
