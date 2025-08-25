/datum/spell/alien_spell/plant_weeds
	name = "Plant weeds"
	desc = "Allows you to plant some alien weeds on the floor below you. Does not work while in space."
	plasma_cost = 50
	var/atom/weed_type = /obj/structure/alien/weeds/node
	var/weed_name = "alien weed node"
	action_icon_state = "alien_plant"
	var/requires_do_after = TRUE

/datum/spell/alien_spell/plant_weeds/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/alien_spell/plant_weeds/cast(list/targets, mob/living/carbon/user)
	var/turf/T = user.loc
	if(locate(weed_type) in T)
		to_chat(user, span_noticealien("There's already \a [weed_name] here."))
		revert_cast()
		return

	if(isspaceturf(T))
		to_chat(user, span_noticealien("You cannot plant [weed_name]s in space."))
		revert_cast()
		return

	if(!isturf(T))
		to_chat(user, span_noticealien("You cannot plant [weed_name]s inside something!"))
		revert_cast()
		return

	user.visible_message(span_warning("Vines burst from the back of [user], securing themselves to the ground and swarming onto [user.loc]."), span_warning("You begin infesting [user.loc] with [initial(weed_type.name)]."))
	if(requires_do_after && !do_mob(user, user, 2 SECONDS))
		revert_cast()
		return

	user.visible_message(span_alertalien("[user] has planted \a [weed_name]!"))
	new weed_type(T)
