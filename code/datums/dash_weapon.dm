/datum/action/innate/dash
	name = "Dash"
	desc = "Teleport to the targeted location."
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "jetboot"
	var/current_charges = 1
	var/max_charges = 1
	var/charge_rate = 250
	var/obj/item/dashing_item
	var/dash_sound = 'sound/magic/blink.ogg'
	var/recharge_sound = 'sound/magic/charge.ogg'
	var/beam_effect = "blur"
	var/phasein = /obj/effect/temp_visual/dir_setting/ninja/phase
	var/phaseout = /obj/effect/temp_visual/dir_setting/ninja/phase/out
	var/last_used = null

/datum/action/innate/dash/Grant(mob/user, obj/dasher)
	. = ..()
	dashing_item = dasher

/datum/action/innate/dash/Destroy()
	dashing_item = null
	return ..()

/datum/action/innate/dash/IsAvailable()
	if(current_charges > 0)
		return TRUE
	else if((last_used + (charge_rate * max_charges)) <= world.time && current_charges != max_charges)	// Существует неприятный баг из-за которого заряды переставали регениться совсем.
		current_charges = max_charges																	// Этот код позволит проверить прошло ли время требуемое для регена всех зарядов
		return TRUE																						// и мгновенно зарядить предмет обратно! Воть
	else
		return FALSE

/datum/action/innate/dash/Activate()
	dashing_item.attack_self(owner) //Used to toggle dash behavior in the dashing item

/// Teleports user to target using do_teleport. Returns TRUE if teleport successful, FALSE otherwise.
/datum/action/innate/dash/proc/teleport(mob/user, atom/target)
	if(!IsAvailable())
		return FALSE

	var/turf/target_turf = get_turf(target)
	var/turf/starting_turf = get_turf(user)
	if(target in view(user.client.view, user))
		var/mob/living/pulled_mob = user.pulling
		if(!do_teleport(user, target_turf))
			to_chat(user, "<span class='warning'>Dash blocked by location!</span>")
			return FALSE
		var/obj/spot1 = new phaseout(starting_turf, user.dir)
		playsound(target_turf, dash_sound, 25, TRUE)
		var/obj/spot2 = new phasein(target_turf, user.dir)
		spot1.Beam(spot2,beam_effect,time=2 SECONDS)
		current_charges--
		if(owner)
			owner.update_action_buttons_icon()
		addtimer(CALLBACK(src, .proc/charge), charge_rate)
		last_used = world.time
		if(istype(pulled_mob))
			pulled_mob.forceMove(target_turf)
//			user.start_pulling(pulled_mob) // Не работает, как задумано... Персонаж просто не берёт другого в пул после телепортации. Пока оставлю так
		return TRUE

	return FALSE

/datum/action/innate/dash/proc/charge()
	current_charges = clamp(current_charges + 1, 0, max_charges)
	if(recharge_sound)
		playsound(dashing_item, recharge_sound, 50, TRUE)

	if(!owner)
		return
	owner.update_action_buttons_icon()
	to_chat(owner, "<span class='warning'>[current_charges]/[max_charges] dash charges</span>")
