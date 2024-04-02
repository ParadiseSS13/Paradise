/datum/spell/alien_spell/tail_lash
	name = "Tail lash"
	desc = "Knocks down anyone around you."
	action_icon_state = "tailsweep"
	base_cooldown = 10 SECONDS

/datum/spell/alien_spell/tail_lash/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/alien_spell/tail_lash/cast(list/targets, mob/user)
	var/turf/T = user.loc
	var/cast_resolved = FALSE
	if(!istype(T))
		revert_cast()
		return
	for(var/mob/living/to_knock_down in orange(1, user))
		if(to_knock_down.KnockDown(10 SECONDS))
			cast_resolved = TRUE
			to_knock_down.visible_message("<span class='noticealien'>[user] sweeps [to_knock_down] off their feet!</span>")
	if(!cast_resolved)
		revert_cast()

	return cast_resolved
