/datum/spell/paradox/object_click/space_distorition
	name = "Space Distorition"
	desc = "You partially leave this universe, which allows you to pass through one object. Not a wall."
	action_icon_state = "space_distortion"
	base_cooldown = 10 SECONDS
	selection_activated_message		= "<span class='warning'>Click on an object or turf to move into it.</span>"
	selection_deactivated_message	= "<span class='notice'>You decided to not distorte space.</span>"

/datum/spell/paradox/object_click/space_distorition/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 1
	T.allowed_type = /obj/
	T.click_radius = -1
	return T

/datum/spell/paradox/object_click/space_distorition/cast(list/targets, mob/user = usr)
	var/obj/O = targets[1]
	var/mob/living/U = user
	U.forceMove(O.loc)
	if(U.pulling)
		U.pulling.forceMove(O.loc)
	do_sparks(rand(1,2), FALSE, O.loc)
