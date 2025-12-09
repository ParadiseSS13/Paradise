GLOBAL_LIST_EMPTY(bluespace_fluid_pipes)

// Just links the fluid datums together lmao
/obj/machinery/fluid_pipe/bluespace
	name = "bluespace fluid transporter"
	desc = "Can be used to transport fluids over large distances."
	// DGTODO I need to make the sprites animate nicely so iconless for now
	// Also hi reviewers, this thing is quite untested
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Are we the transporter that sets us up?
	var/is_setup_pipe = FALSE
	/// Our linked pair
	var/obj/machinery/fluid_pipe/bluespace/pair

/obj/machinery/fluid_pipe/bluespace/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Warning: Explosions will also be transferred."

/obj/machinery/fluid_pipe/bluespace/Initialize(mapload, direction)
	. = ..()
	if(length(GLOB.bluespace_fluid_pipes) >= 2)
		log_debug("3 or more bluespace fluid transporters have been spawned in.")
		return INITIALIZE_HINT_QDEL // What even
	GLOB.bluespace_fluid_pipes |= src

// Gotta do this when everything is finished up
/obj/machinery/fluid_pipe/bluespace/LateInitialize()
	. = ..()
	if(!is_setup_pipe)
		return
	INVOKE_ASYNC(src, PROC_REF(setup_pipes))

/obj/machinery/fluid_pipe/bluespace/proc/setup_pipes()
	for(var/obj/machinery/fluid_pipe/bluespace/pipe as anything in GLOB.bluespace_fluid_pipes)
		if(pipe == src)
			continue
		pair = pipe
		break
	if(!pair)
		log_debug("Bluespace fluid transporter without a pair found. Aborting pipe setup.")
		return
	fluid_datum = new(src)
	fluid_datum.add_pipe(pair)

/obj/machinery/fluid_pipe/bluespace/ex_act(severity)
	pair.ex_act(severity) // Bluespace link moment
	return ..()

// Type that sets up the pipe linking. The one on lavaland always starts the link
/obj/machinery/fluid_pipe/bluespace/setup
	is_setup_pipe = TRUE
