/datum/spell/uplifted_make_nest
	name = "Make Nest"
	desc = "Build a nest at your current location."

	action_icon = 'icons/obj/uplifted_primitive.dmi'
	action_icon_state = "nest"
	action_background_icon_state = "bg_default"

	base_cooldown = 15 SECONDS
	clothes_req = FALSE
	antimagic_flags = NONE

/datum/spell/uplifted_make_nest/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/uplifted_make_nest/cast(list/targets, mob/user)
	var/datum/antagonist/uplifted_primitive/U = user.mind.has_antag_datum(/datum/antagonist/uplifted_primitive)

	user.visible_message(SPAN_NOTICE("[user] starts building a nest!"), SPAN_NOTICE("You start building a nest!"))

	if(!do_after(user, 10 SECONDS, target = user))
		return

	var/obj/structure/uplifted_primitive/nest/nest = new(get_turf(user), U.initial_species)
	U.nest_uid = nest.UID()

/datum/spell/uplifted_make_nest/can_cast(mob/user, charge_check, show_message)
	if(!..())
		return FALSE

	var/datum/antagonist/uplifted_primitive/U = user.mind.has_antag_datum(/datum/antagonist/uplifted_primitive)

	if(!U)
		return FALSE

	var/obj/structure/uplifted_primitive/nest/nest = locateUID(U.nest_uid)
	if(!QDELETED(nest))
		if(show_message)
			to_chat(user, SPAN_WARNING("You already have a nest!"))
		return FALSE

	if(!isturf(user.loc))
		if(show_message)
			to_chat(user, SPAN_WARNING("You cannot make a nest here!"))
		return FALSE

	return TRUE
