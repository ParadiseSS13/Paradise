/obj/effect/countdown
	name = "countdown"
	desc = "We're leaving together\n\
		But still it's farewell\n\
		And maybe we'll come back\n\
		To earth, who can tell?"

	invisibility = INVISIBILITY_HIGH
	layer = MASSIVE_OBJ_LAYER
	color = "#ff0000" // text color
	var/text_size = 3 // larger values clip when the displayed text is larger than 2 digits.
	var/started = FALSE
	var/displayed_text
	var/atom/attached_to

/obj/effect/countdown/Initialize(mapload)
	. = ..()
	attach(loc)
	RegisterSignal(attached_to, COMSIG_MOVABLE_MOVED, PROC_REF(countdown_on_move))

/obj/effect/countdown/examine(mob/user)
	. = ..()
	. += "This countdown is displaying: [displayed_text]."

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

/// Get the value from our atom
/obj/effect/countdown/proc/get_value()
	return

/obj/effect/countdown/proc/countdown_on_move()
	SIGNAL_HANDLER
	forceMove(get_turf(attached_to))

/obj/effect/countdown/process()
	if(!attached_to || QDELETED(attached_to))
		qdel(src)
	if(!isturf(attached_to.loc)) // When in crates, lockers, etc. countdown_on_move wont be called. This is our backup
		forceMove(get_turf(attached_to))
	var/new_val = get_value()
	if(new_val == displayed_text)
		return
	displayed_text = new_val

	if(displayed_text)
		maptext = "<font face='Small Fonts' size=[text_size]>[displayed_text]</font>"
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

	return C.clone_progress

/obj/effect/countdown/supermatter
	name = "supermatter damage"
	text_size = 1
	color = "#00ff80"

/obj/effect/countdown/supermatter/get_value()
	var/obj/machinery/atmospherics/supermatter_crystal/S = attached_to
	if(!istype(S))
		return
	return "<div align='center' valign='middle' style='position:relative; top:0px; left:0px'>[round(S.get_integrity(), 1)]%</div>"

/obj/effect/countdown/anomaly
	name = "anomaly countdown"

/obj/effect/countdown/anomaly/get_value()
	var/obj/effect/anomaly/A = attached_to
	if(!istype(A))
		return
	var/time_left = max(0, (A.death_time - world.time) / 10)
	return round(time_left)
