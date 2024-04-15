/datum/spell/alien_spell/regurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach onto the ground."
	action_icon_state = "alien_barf"

/datum/spell/alien_spell/regurgitate/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/alien_spell/regurgitate/cast(list/targets, mob/living/carbon/user)
	for(var/mob/M in user.stomach_contents)
		var/turf/output_loc = user.loc
		if(!istype(output_loc))
			return
		user.stomach_contents -= M
		M.forceMove(output_loc)
		user.visible_message("<span class='alertalien'><b>[user] hurls out the contents of [p_their()] stomach!</b></span>")
		return
	user.visible_message("<span class='alertalien'><b>[user] dry heaves!</b></span>")
