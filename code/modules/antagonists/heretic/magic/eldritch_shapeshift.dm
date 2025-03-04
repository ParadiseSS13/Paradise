// Given to heretic monsters.
/datum/spell/shapeshift/eldritch
	name = "Shapechange"
	desc = "A spell that allows you to take on the form of another creature, gaining their abilities. \
		After making your choice, you will be unable to change to another."



	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	invocation = "SH'PE"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	possible_shapes = list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/dog/fox,
		/mob/living/simple_animal/bot/secbot,
	)
