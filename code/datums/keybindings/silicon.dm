/datum/keybinding/silicon
	category = KB_CATEGORY_SILICON

/datum/keybinding/silicon/can_use(client/C, mob/M)
	return issilicon(M) && ..()

/datum/keybinding/silicon/switch_intent
	name = "Switch Intents"
	keys = list("4")

/datum/keybinding/silicon/switch_intent/down(client/C)
	. = ..()
	var/mob/living/silicon/M = C.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
