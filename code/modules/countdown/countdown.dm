/obj/effect/countdown
	name = "countdown"
	desc = "We're leaving together\n\
		But still it's farewell\n\
		And maybe we'll come back\n\
		To earth, who can tell?"

	var/displayed_text
	var/atom/attached_to
	color = "#ff0000"
	var/text_size = 4
	var/started = FALSE
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	layer = GHOST_LAYER

/obj/effect/countdown/New(atom/A)
	. = ..()
	attach(A)

/obj/effect/countdown/examine(mob/user)
	. = ..()
	. += "This countdown is displaying: [displayed_text]"

/obj/effect/countdown/proc/attach(atom/A)
	attached_to = A
	loc = get_turf(A)

/obj/effect/countdown/proc/start()
	if(!started)
		START_PROCESSING(SSfastprocess, src)
		started = TRUE

/obj/effect/countdown/proc/stop()
	if(started)
		maptext = null
		STOP_PROCESSING(SSfastprocess, src)
		started = FALSE

/obj/effect/countdown/proc/get_value()
	// Get the value from our atom
	return

/obj/effect/countdown/process()
	if(!attached_to || QDELETED(attached_to))
		qdel(src)
	forceMove(get_turf(attached_to))
	var/new_val = get_value()
	if(new_val == displayed_text)
		return
	displayed_text = new_val

	if(displayed_text)
		maptext = "<font size = [text_size]>[displayed_text]</font>"
	else
		maptext = null

/obj/effect/countdown/Destroy()
	attached_to = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/countdown/ex_act(severity) //immune to explosions
	return

/obj/effect/countdown/singularity_pull()
	return

/obj/effect/countdown/singularity_act()
	return

/obj/effect/countdown/syndicatebomb
	name = "syndicate bomb countdown"

/obj/effect/countdown/syndicatebomb/get_value()
	var/obj/machinery/syndicatebomb/S = attached_to
	if(!istype(S))
		return
	else if(S.active)
		return S.seconds_remaining()

/obj/effect/countdown/clonepod
	name = "cloning pod countdown"
	text_size = 1

/obj/effect/countdown/clonepod/get_value()
	var/obj/machinery/clonepod/C = attached_to
	if(!istype(C))
		return
	else if(C.occupant)
		var/completion = round(C.get_completion())
		return completion
