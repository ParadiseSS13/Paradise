/obj/effect/proc_holder/spell/wizard/targeted/explosion
	name = "Explosion"
	desc = "This spell explodes an area."

	var/ex_severe = 1
	var/ex_heavy = 2
	var/ex_light = 3

/obj/effect/proc_holder/spell/wizard/targeted/explosion/cast(list/targets)

	for(var/mob/living/target in targets)
		explosion(target.loc,ex_severe,ex_heavy,ex_light)

	return