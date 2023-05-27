/datum/keybinding/carbon
	category = KB_CATEGORY_CARBON

/datum/keybinding/carbon/can_use(client/C, mob/M)
	return iscarbon(M) && ..()

/datum/keybinding/carbon/throw_mode
	name = "Throw Mode (Toggle)"
	keys = list("R", "Southwest")

/datum/keybinding/carbon/throw_mode/down(client/C)
	. = ..()
	var/mob/living/carbon/M = C.mob
	M.toggle_throw_mode()

/datum/keybinding/carbon/throw_mode/hold
	name = "Throw Mode (Hold)"
	keys = null

/datum/keybinding/carbon/throw_mode/hold/up(client/C)
	. = ..()
	var/mob/living/carbon/M = C.mob
	M.throw_mode_off()

/datum/keybinding/carbon/give_item
	name = "Give Item (Toggle)"
	keys = list("G")

/datum/keybinding/carbon/give_item/down(client/C)
	. = ..()
	var/mob/living/carbon/user = C.mob
	user.toggle_give()

/datum/keybinding/carbon/intent
	/// The intent to switch to.
	var/intent

/datum/keybinding/carbon/intent/down(client/C)
	. = ..()
	var/mob/living/carbon/M = C.mob
	M.a_intent_change(intent)

/datum/keybinding/carbon/intent/help
	name = "Help Intent (Tap)"
	intent = INTENT_HELP
	keys = list("1")

/datum/keybinding/carbon/intent/disarm
	name = "Disarm Intent (Tap)"
	intent = INTENT_DISARM
	keys = list("2")

/datum/keybinding/carbon/intent/grab
	name = "Grab Intent (Tap)"
	intent = INTENT_GRAB
	keys = list("3")

/datum/keybinding/carbon/intent/harm
	name = "Harm Intent (Tap)"
	intent = INTENT_HARM
	keys = list("4")

/datum/keybinding/carbon/intent/hold
	/// The previous intent before holding.
	var/prev_intent

/datum/keybinding/carbon/intent/hold/down(client/C)
	var/mob/living/carbon/M = C.mob
	prev_intent = M.a_intent
	return ..()

/datum/keybinding/carbon/intent/hold/up(client/C)
	. = ..()
	var/mob/living/carbon/M = C.mob
	M.a_intent_change(prev_intent)
	prev_intent = null

/datum/keybinding/carbon/intent/hold/help
	name = "Help Intent (Hold)"
	intent = INTENT_HELP

/datum/keybinding/carbon/intent/hold/disarm
	name = "Disarm Intent (Hold)"
	intent = INTENT_DISARM

/datum/keybinding/carbon/intent/hold/grab
	name = "Grab Intent (Hold)"
	intent = INTENT_GRAB

/datum/keybinding/carbon/intent/hold/harm
	name = "Harm Intent (Hold)"
	intent = INTENT_HARM
