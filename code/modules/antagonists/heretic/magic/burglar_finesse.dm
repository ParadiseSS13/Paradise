/datum/spell/pointed/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Steal a random item from the victim's backpack."

	overlay_icon_state = "bg_heretic_border"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "burglarsfinesse"

	is_a_heretic_spell = TRUE
	base_cooldown = 40 SECONDS

	invocation = "Y'O'K!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 6

//qwertodo: atom storage to however our storage is
