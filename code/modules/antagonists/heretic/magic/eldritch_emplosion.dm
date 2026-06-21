// Given to heretic monsters.
/datum/spell/emplosion/heretic
	name = "Energetic Pulse"
	desc = "A spell that causes a large EMP around you, disabling electronics."



	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "E'P"
	invocation_type = INVOCATION_WHISPER

	emp_heavy = 6
	emp_light = 10
