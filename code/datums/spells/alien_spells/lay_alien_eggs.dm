/datum/spell/alien_spell/plant_weeds/eggs
	name = "Plant alien eggs"
	desc = "Allows you to plant alien eggs on your current turf. Does not work while in space."
	plasma_cost = 75
	weed_type = /obj/structure/alien/egg
	weed_name = "alien egg"
	action_icon_state = "alien_egg"
	requires_do_after = FALSE

/datum/spell/alien_spell/combust_facehuggers
	name = "Combust facehuggers and eggs"
	desc = "Take over the programming of facehuggers and eggs, sending out a shockwave which causes them to combust."
	plasma_cost = 25
	action_icon_state = "alien_egg"
	base_cooldown = 3 SECONDS

/datum/spell/alien_spell/combust_facehuggers/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/datum/spell/alien_spell/combust_facehuggers/cast(list/targets, mob/living/carbon/user)
	var/obj/target = targets[1]
	var/turf/T = user.loc
	if(!istype(T) || !istype(target))
		revert_cast()
		return FALSE

	if(!istype(target, /obj/item/clothing/mask/facehugger) && !istype(target, /obj/structure/alien/egg))
		revert_cast()
		return FALSE

	target.color = "#c72623"
	addtimer(CALLBACK(src, PROC_REF(blow_it_up), target, user), 3 SECONDS)
	to_chat(user, "<span class='noticealien'>[target] will explode in 3 seconds!</span>")
	return TRUE

/datum/spell/alien_spell/combust_facehuggers/proc/blow_it_up(obj/target, mob/user)
	add_attack_logs(user, target, "Caused it to explode")
	explosion(get_turf(target), 0, 2, 3, 3, cause = "[user.ckey]: [name]")
	to_chat(user, "<span class='noticealien'>[target] has detonated!</span>")
