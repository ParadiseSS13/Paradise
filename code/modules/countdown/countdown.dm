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
	var/started = 0
	invisibility = INVISIBILITY_OBSERVER
	anchored = 1
	layer = 5

/obj/effect/countdown/New(atom/A)
	. = ..()
	attach(A)

/obj/effect/countdown/proc/attach(atom/A)
	attached_to = A
	loc = get_turf(A)

/obj/effect/countdown/proc/start()
	if(!started)
		fast_processing += src
		started = 1

/obj/effect/countdown/proc/stop()
	if(started)
		maptext = null
		fast_processing -= src
		started = 0

/obj/effect/countdown/proc/get_value()
	// Get the value from our atom
	return

/obj/effect/countdown/process()
	if(!attached_to || qdeleted(attached_to))
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
	fast_processing -= src
	return ..()

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
