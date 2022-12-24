/obj/effect/proc_holder/spell/alien_spell/plant_weeds
	name = "Plant weeds"
	desc = "Allows you to plant some alien weeds on the floor below you, does not work while in space."
	base_cooldown = 1 // No cooldown
	plasma_cost = 50
	var/weed_type = /obj/structure/alien/weeds/node
	var/weed_name = "alien weed node"
	action_icon_state = "alien_plant"

/obj/effect/proc_holder/spell/alien_spell/plant_weeds/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/alien_spell/plant_weeds/cast(list/targets, mob/living/carbon/user)
	var/turf/T = user.loc
	if(locate(weed_type) in T)
		to_chat(user, "<span class='noticealien'>There's already an [weed_name] here.</span>")
		revert_cast()
		return

	if(isspaceturf(T))
		to_chat(user, "<span class='noticealien'>You cannot plant [weed_name]s in space.</span>")
		revert_cast()
		return

	for(var/mob/O in viewers(user, null))
		O.show_message(text("<span class='alertalien'>[user] has planted a [weed_name]!</span>"), 1)
	new weed_type(T)
	return
