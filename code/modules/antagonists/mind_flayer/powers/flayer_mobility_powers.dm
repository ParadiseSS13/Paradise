//This is all Charlie's code, I'm putting it in before I forget but I'll have to actually figure out how to integrate it in
//Okay so we'd either need make it a subtype of /obj/effect/proc_holder/spell/flayer, refactor jaunts, or make this spell special
/obj/effect/proc_holder/spell/ethereal_jaunt/phase_shift
	name = "Phase Shift"
	desc = "Shift into the space between dimensions, making you invisible and invulnerable but unable to "
	base_cooldown = 10 SECONDS
	clothes_req = FALSE
	action_icon_state = "sacredflame"
	jaunt_water_effect = FALSE
	jaunt_in_time = 0
	jaunt_out_type = null
	jaunt_in_type = null
	var/sight_cache

/obj/effect/proc_holder/spell/ethereal_jaunt/phase_shift/create_jaunt_holder(turf/mobloc, mob/living/target)
	var/obj/effect/dummy/spell_jaunt/holder = ..()
	holder.movespeed = target.movement_delay()
	return holder

/obj/effect/proc_holder/spell/ethereal_jaunt/phase_shift/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/target = targets[1]
	sight_cache = target.sight
	target.sight = SEE_TURFS | BLIND
	target.client.color = MATRIX_GREYSCALE
	addtimer(CALLBACK(src, PROC_REF(snap_back_to_reality), target), jaunt_duration)

/obj/effect/proc_holder/spell/ethereal_jaunt/phase_shift/proc/snap_back_to_reality(mob/living/target)
	target.sight = sight_cache
	target.client.color = null
	var/turf/T = get_turf(target)
	for(var/mob/living/L in T)
		if(L == target)
			continue
		L.gib() //lol, lmao even

/obj/effect/proc_holder/spell/ethereal_jaunt/do_jaunt(mob/living/target)
	target.notransform = TRUE
	var/turf/mobloc = get_turf(target)

	var/obj/effect/dummy/spell_jaunt/holder = create_jaunt_holder(mobloc, target)
	if(jaunt_out_type)
		new jaunt_out_type(mobloc, target.dir)
	target.ExtinguishMob()
	target.forceMove(holder)
	target.reset_perspective(holder)
	target.notransform = FALSE //mob is safely inside holder now, no need for protection.
	if(jaunt_water_effect)
		jaunt_steam(mobloc)

	sleep(jaunt_duration)

	if(target.loc != holder) //mob warped out of the warp
		qdel(holder)
		return
	mobloc = get_turf(target.loc)
	if(jaunt_water_effect)
		jaunt_steam(mobloc)
	ADD_TRAIT(target, TRAIT_IMMOBILIZED, "jaunt")
	holder.reappearing = 1
	playsound(get_turf(target), 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	sleep(jaunt_in_time * 4)
	if(jaunt_in_type)
		new jaunt_in_type(mobloc, holder.dir)
	target.setDir(holder.dir)
	sleep(jaunt_in_time)
	qdel(holder)
	if(QDELETED(target))
		return
	if(!is_blocked_turf(mobloc, TRUE))
		return
	for(var/turf/T in orange(7))
		if(isspaceturf(T))
			continue
		if(target.Move(T))
			target.remove_CC()
			REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, "jaunt")
			return
	for(var/turf/space/S in orange(7))
		if(target.Move(S))
			break
	REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, "jaunt")
	target.remove_CC()

/obj/effect/proc_holder/spell/ethereal_jaunt/proc/create_jaunt_holder(turf/mobloc, mob/living/target)
	return new jaunt_type_path(mobloc)

//Basically shadow anchor, but with computers. I'm not in your walls I'm in your PC
/obj/effect/proc_holder/spell/flayer/computer_recall
	name = "Data Transfer"
	desc = "Cast once to mark a computer, then cast this next to a different computer to recall yourself back to the first. Alt click to check your current mark."
	base_cooldown = 5 SECONDS //TODO change this back to 60 seconds when testing is done
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	centcom_cancast = FALSE
	var/obj/machinery/computer/marked_computer = null

/obj/effect/proc_holder/spell/flayer/computer_recall/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /obj/machinery/computer
	T.try_auto_target = TRUE
	T.range = 1
	return T

/obj/effect/proc_holder/spell/flayer/computer_recall/cast(list/targets, mob/living/user)
	var/obj/machinery/computer/target = targets[1]
	if(!marked_computer)
		marked_computer = target
		to_chat(user, "<span class='notice'>You discreetly tap [targets[1]] and mark it as your home computer.</span>")
		return

	var/turf/start_turf = get_turf(target)
	var/turf/end_turf = get_turf(marked_computer)
	if(end_turf.z != start_turf.z)
		to_chat(user, "<span class='notice'>The connection between [target] and [marked_computer] is too unstable!.</span>")
		return
	if(!is_teleport_allowed(end_turf.z))
		return
	user.visible_message(
		"<span class='warning'>[user] de-materializes and jumps through the screen of [target]!</span>",
		"<span class='notice'>You de-materialize and jump into [target]!")
	var/matrix/previous = user.transform
	var/matrix/shrank = user.transform.Scale(0.25)
	var/direction = get_dir(user, target)
	var/list/direction_signs = get_signs_from_direction(direction)
	animate(user, 0.5 SECONDS, 0, transform = shrank, pixel_x = 32 * direction_signs[1], pixel_y = 32 * direction_signs[2], dir = direction, easing = BACK_EASING|EASE_IN) //Blue skadoo, we can too!
	user.Immobilize(0.5 SECONDS)
	sleep(0.5 SECONDS)
	user.forceMove(end_turf)
	user.pixel_x = 0 //Snap back to the center, then animate the un-shrinking
	user.pixel_y = 0
	animate(user, 0.5 SECONDS, 0, transform = previous)
	user.visible_message(
		"<span class='warning'>[user] suddenly crawls through the monitor of [marked_computer]!</span>",
		"<span class='notice'>As you reform yourself at [marked_computer] you feel the mark you left on it fade.</span>")
	marked_computer = null

/obj/effect/proc_holder/spell/flayer/computer_recall/AltClick(mob/user)
	if(!marked_computer)
		to_chat(user, "<span class='notice'>You do not current have a marked computer.</span>")
		return
	to_chat(user, "<span class='notice'>Your current mark is [marked_computer].</span>")

