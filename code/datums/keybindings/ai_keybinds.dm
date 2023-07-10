/datum/keybinding/ai
	category = KB_CATEGORY_AI

/datum/keybinding/ai/can_use(client/C, mob/M)
	return isAI(M) && ..()

/datum/keybinding/ai/switch_intent
	name = "Switch Intents"
	keys = list("6")

/datum/keybinding/ai/switch_intent/down(client/C)
	. = ..()
	var/mob/living/silicon/ai/M = C.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
