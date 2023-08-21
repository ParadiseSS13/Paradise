/datum/keybinding/living
	category = KB_CATEGORY_LIVING

/datum/keybinding/living/can_use(client/C, mob/M)
	return isliving(M) && ..()

/datum/keybinding/living/rest
	name = "Rest"
	keys = list("V")

/datum/keybinding/living/rest/down(client/C)
	. = ..()
	var/mob/living/M = C.mob
	M.rest()

/datum/keybinding/living/resist
	name = "Resist"
	keys = list("B")

/datum/keybinding/living/resist/down(client/C)
	. = ..()
	var/mob/living/M = C.mob
	M.resist()

/datum/keybinding/living/whisper
	name = "Whisper"
	keys = list("U")

/datum/keybinding/living/whisper/down(client/C)
	var/mob/M = C.mob
	M.set_typing_indicator(TRUE)
	M.hud_typing = 1
	var/message = typing_input(M, "", "Whisper (text)")
	M.hud_typing = 0
	M.set_typing_indicator(FALSE)
	if(message)
		M.whisper(message)
