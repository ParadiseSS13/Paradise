// TODO refactor when spell code is component based instead of OO based
/obj/effect/proc_holder/spell/morph_spell/pass_airlock
	name = "Pass Airlock"
	desc = "Reform yourself so you can fit through a non bolted airlock. Takes a while to do and can only be used in a non disguised form."
	action_background_icon_state = "bg_morph"
	action_icon_state = "morph_airlock"
	base_cooldown = 10 SECONDS
	selection_activated_message = "<span class='sinister'>Click on an airlock to try pass it.</span>"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/morph_spell/pass_airlock/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.allowed_type = /obj/machinery/door/airlock
	T.click_radius = -1
	return T


/obj/effect/proc_holder/spell/morph_spell/pass_airlock/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return

	if(user.morphed)
		if(show_message)
			to_chat(user, "<span class='warning'>You can only pass through airlocks in your true form!</span>")
		return FALSE


/obj/effect/proc_holder/spell/morph_spell/pass_airlock/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	var/obj/machinery/door/airlock/airlock = targets[1]
	if(airlock.locked)
		to_chat(user, "<span class='warning'>[airlock] is bolted shut! You're unable to create a crack to pass through!</span>")
		revert_cast(user)
		return
	user.visible_message("<span class='warning'>[user] starts pushing itself against [airlock]!</span>", "<span class='sinister'>You try to pry [airlock] open enough to get through.</span>")
	if(!do_after(user, 6 SECONDS, FALSE, user, TRUE, list(CALLBACK(src, PROC_REF(pass_check), user, airlock)), FALSE))
		if(user.morphed)
			to_chat(user, "<span class='warning'>You need to stay in your true form to pass through [airlock]!</span>")
		else if(airlock.locked)
			to_chat(user, "<span class='warning'>[airlock] is bolted shut! You're unable to create a crack to pass through!</span>")
		else
			to_chat(user, "<span class='warning'>You need to stay still to pass through [airlock]!</span>")
		revert_cast(user)
		return

	user.visible_message("<span class='warning'>[user] briefly opens [airlock] slightly and passes through!</span>", "<span class='sinister'>You slide through the open crack in [airlock].</span>")
	user.forceMove(airlock.loc) // Move into the turf of the airlock


/obj/effect/proc_holder/spell/morph_spell/pass_airlock/proc/pass_check(mob/living/simple_animal/hostile/morph/user, obj/machinery/door/airlock/airlock)
	return user.morphed || airlock.locked
