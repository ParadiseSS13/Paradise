// Given to heretic monsters.
/datum/spell/emplosion
	name = "Energetic Pulse"
	desc = "A spell that causes a large EMP around you, disabling electronics."

	overlay_icon_state = "bg_heretic_border"

	is_a_heretic_spell = TRUE
	base_cooldown = 30 SECONDS

	invocation = "E'P"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	emp_heavy = 6
	emp_light = 10
