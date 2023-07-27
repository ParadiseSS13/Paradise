/obj/effect/proc_holder/spell/explosion
	name = "Explosion"
	desc = "This spell explodes an area."
	action_icon_state = "explosion"
	var/ex_severe = 0
	var/ex_heavy = 0
	var/ex_light = 0
	var/ex_flash = 0
	var/ex_flame = 0


/obj/effect/proc_holder/spell/explosion/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/explosion/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		explosion(target.loc, ex_severe, ex_heavy, ex_light, ex_flash, flame_range = ex_flame)

