/obj/effect/proc_holder/spell/emplosion
	name = "Emplosion"
	desc = "This spell emplodes an area."
	action_icon_state = "emp"
	var/emp_heavy = 2
	var/emp_light = 3


/obj/effect/proc_holder/spell/emplosion/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/emplosion/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		empulse(target.loc, emp_heavy, emp_light, TRUE)

