// TODO refactor when spell code is component based instead of OO based
/datum/spell/morph_spell/pass_airlock
	name = "Pass Airlock"
	desc = "Reform yourself so you can fit through a non bolted airlock. Takes a while to do and can only be used in a non disguised form."
	action_icon_state = "morph_airlock"
	antimagic_flags = NONE
	selection_activated_message = SPAN_SINISTER("Click on an airlock to try pass it.")

/datum/spell/morph_spell/pass_airlock/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 1
	T.allowed_type = /obj/machinery/door/airlock
	T.click_radius = -1
	return T


/datum/spell/morph_spell/pass_airlock/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return

	if(user.morphed)
		if(show_message)
			to_chat(user, SPAN_WARNING("You can only pass through airlocks in your true form!"))
		return FALSE

/datum/spell/morph_spell/pass_airlock/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	var/obj/machinery/door/airlock/A = targets[1]
	if(A.locked)
		to_chat(user, SPAN_WARNING("[A] is bolted shut! You're unable to create a crack to pass through!"))
		revert_cast(user)
		return
	user.visible_message(SPAN_WARNING("[user] starts pushing itself against [A]!"), SPAN_SINISTER("You try to pry [A] open enough to get through."))
	if(!do_after(user, 6 SECONDS, FALSE, user, TRUE, list(CALLBACK(src, PROC_REF(pass_check), user, A)), FALSE))
		if(user.morphed)
			to_chat(user, SPAN_WARNING("You need to stay in your true form to pass through [A]!"))
		else if(A.locked)
			to_chat(user, SPAN_WARNING("[A] is bolted shut! You're unable to create a crack to pass through!"))
		else
			to_chat(user, SPAN_WARNING("You need to stay still to pass through [A]!"))
		revert_cast(user)
		return
	if(QDELETED(A))
		return

	user.visible_message(SPAN_WARNING("[user] briefly opens [A] slightly and passes through!"), SPAN_SINISTER("You slide through the open crack in [A]."))
	user.forceMove(A.loc) // Move into the turf of the airlock


/datum/spell/morph_spell/pass_airlock/proc/pass_check(mob/living/simple_animal/hostile/morph/user, obj/machinery/door/airlock/A)
	return user.morphed || A.locked
