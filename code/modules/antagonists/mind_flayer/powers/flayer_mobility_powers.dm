/datum/spell/ethereal_jaunt/proc/create_jaunt_holder(turf/mobloc, mob/living/target)
	return new jaunt_type_path(mobloc)

//Basically shadow anchor, but with computers. I'm not in your walls I'm in your PC
/datum/spell/flayer/computer_recall
	name = "Data Transfer"
	desc = "Cast once to mark a computer, then cast this next to a different computer to recall yourself back to the first. Alt click to check your current mark."
	base_cooldown = 5 SECONDS //TODO change this back to 60 seconds when testing is done
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_INTRUDER
	centcom_cancast = FALSE
	var/obj/machinery/computer/marked_computer = null
	stage = 2

/datum/spell/flayer/computer_recall/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /obj/machinery/computer
	T.try_auto_target = TRUE
	T.range = 1
	return T

/datum/spell/flayer/computer_recall/cast(list/targets, mob/living/user)
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
	target.Beam(marked_computer, icon_state = "rped_upgrade", icon ='icons/effects/effects.dmi', time = 3 SECONDS, maxdistance = INFINITY)
	playsound(start_turf, 'sound/items/pshoom.ogg', 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(end_turf, 'sound/items/pshoom.ogg', 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	user.forceMove(end_turf)
	user.pixel_x = 0 //Snap back to the center, then animate the un-shrinking
	user.pixel_y = 0
	animate(user, 0.5 SECONDS, 0, transform = previous)
	user.visible_message(
		"<span class='warning'>[user] suddenly crawls through the monitor of [marked_computer]!</span>",
		"<span class='notice'>As you reform yourself at [marked_computer] you feel the mark you left on it fade.</span>")
	marked_computer = null

/datum/spell/flayer/computer_recall/AltClick(mob/user)
	if(!marked_computer)
		to_chat(user, "<span class='notice'>You do not current have a marked computer.</span>")
		return
	to_chat(user, "<span class='notice'>Your current mark is [marked_computer].</span>")

