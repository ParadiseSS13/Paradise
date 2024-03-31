/obj/effect/proc_holder/spell/alien_spell/regurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach onto the ground."
	action_icon_state = "alien_barf"

/obj/effect/proc_holder/spell/alien_spell/regurgitate/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/alien_spell/regurgitate/cast(list/targets, mob/living/carbon/user)
	for(var/mob/M in user.stomach_contents)
		var/turf/output_loc = user.loc
		if(!istype(output_loc))
			return
		user.stomach_contents -= M
		M.forceMove(output_loc)
		visible_message("<span class='alertalien'><B>[user] hurls out the contents of [p_their()] stomach!</span>")
		return
	visible_message("<span class='alertalien'><B>[user] dry heaves!</span>")
