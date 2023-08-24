/mob/living/carbon/alien/humanoid/hunter/vector
	name = "alien vector"
	icon_state = "alienh_running"

/mob/living/carbon/alien/humanoid/hunter/vector/New()
	if(name == "alien vector")
		name = "alien vector ([rand(1, 1000)])"
	real_name = name
	AddSpell(new /obj/effect/proc_holder/spell/alien_spell/impregnate)
	..()


