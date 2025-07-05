/datum/spell/inspectors_gaze
	name = "Inspector's Gaze"
	desc = "Let the crew know that they're being watched and inspected."
	base_cooldown = 6 SECONDS
	clothes_req = FALSE
	selection_activated_message		= "<span class='notice'>You look for a crewmember to inspect! <b>Left-click to gaze at a target!</b></span>"
	selection_deactivated_message	= "<span class='notice'>You relinquish your gaze... for now.</span>"
	action_icon_state = "genetic_view"

/datum/spell/inspectors_gaze/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/external/C = new()
	C.range = 10
	return C

/datum/spell/inspectors_gaze/cast(list/targets, mob/living/user = usr)
	var/mob/target = targets[1] // There is only ever one target for your gaze
	if(!istype(target))
		to_chat(user, "<span class='warning'>You don't think [target] can commit SOP violations.</span>")
		return FALSE
	to_chat(target, "<span class='warning'>You feel someone staring at you...</span>")
	to_chat(user, "<span class='notice'>You gaze at [target], intent to find SOP violations.</span>")

	return TRUE
