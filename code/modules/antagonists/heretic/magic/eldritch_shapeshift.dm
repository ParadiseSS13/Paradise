// Given to heretic monsters.
/datum/spell/shapeshift/eldritch
	desc = "A spell that allows you to take on the form of another creature, gaining their abilities. \
		After making your choice, you will be unable to change to another."



	is_a_heretic_spell = TRUE
	invocation = "SH'PE"
	invocation_type = INVOCATION_WHISPER

	possible_shapes = list(
		/mob/living/basic/carp,
		/mob/living/basic/mouse,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/dog/fox,
		/mob/living/simple_animal/bot/secbot,
	)
