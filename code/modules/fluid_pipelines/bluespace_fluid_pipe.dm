GLOBAL_LIST_EMPTY(bluespace_fluid_pipes)

// Just links the fluid datums together lmao
/obj/machinery/fluid_pipe/bluespace
	name = "fluid transmitter"
	desc = "Can be used to transport fluids over large distances."
	icon = 'icons/obj/pipes/32x64fluid_machinery.dmi'
	icon_state = "transmitter"
	connect_dirs = list(NORTH, EAST, WEST)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Our linked pair
	var/obj/machinery/fluid_pipe/bluespace/pair
	uninstalled_type = /obj/structure/fluid_construction/pipe_bluespace

/obj/machinery/fluid_pipe/bluespace/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Warning: Explosions will also be transferred."

/obj/machinery/fluid_pipe/bluespace/Initialize(mapload, direction)
	. = ..()
	if(length(GLOB.bluespace_fluid_pipes) >= 2)
		log_debug("3 or more fluid transmitters have been spawned in.")
		visible_message("ERROR: Only 2 transmitters may be active at the same time!")
		new uninstalled_type(get_turf(src))
		return INITIALIZE_HINT_QDEL // What even

	GLOB.bluespace_fluid_pipes |= src

// Gotta do this when everything is finished up
/obj/machinery/fluid_pipe/bluespace/LateInitialize()
	. = ..()
	// Also I hate to put this in a code comment but for sanity, don't map this in next to other pipes
	setup_pipes()

/obj/machinery/fluid_pipe/bluespace/Destroy()
	GLOB.bluespace_fluid_pipes -= src
	return ..()

/obj/machinery/fluid_pipe/bluespace/proc/setup_pipes()
	if(pair && (fluid_datum == pair.fluid_datum))
		return // No need to connect again

	for(var/obj/machinery/fluid_pipe/bluespace/pipe as anything in GLOB.bluespace_fluid_pipes)
		if(pipe == src)
			continue
		pair = pipe
		break

	if(!pair)
		fluid_datum = new(src)
		return

	if(pair.fluid_datum)
		pair.fluid_datum.add_pipe(src)
	else
		fluid_datum = new(src)
		fluid_datum.add_pipe(pair)
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(remove_reference))
	RegisterSignal(pair, COMSIG_PARENT_QDELETING, PROC_REF(remove_reference))
	pair.setup_pipes()

/obj/machinery/fluid_pipe/bluespace/proc/remove_reference()
	pair = null

/obj/machinery/fluid_pipe/bluespace/update_icon_state()
	return

/obj/machinery/fluid_pipe/bluespace/update_overlays()
	. = ..()

	for(var/obj/pipe as anything in get_adjacent_pipes())
		if(pair == pipe)
			continue
		. += "conn_[get_dir(src, pipe)]"

/obj/machinery/fluid_pipe/bluespace/get_adjacent_pipes()
	. = ..()
	.++

/obj/machinery/fluid_pipe/bluespace/ex_act(severity)
	pair.ex_act(severity) // Bluespace link moment
	return ..()

/obj/item/beacon/blue_fluid_pipe
	name = "fluid transmitter beacon"
	desc = "Upon use, teleports a fluid transmitter to your location."

/obj/item/beacon/blue_fluid_pipe/attack_self__legacy__attackchain(mob/user)
	if(!user)
		return
	for(var/obj/machinery/fluid_pipe in get_turf(user))
		if(fluid_pipe.density)
			to_chat(user, SPAN_WARNING("There isn't enough space to install [src] here."))
			return

	to_chat(user, SPAN_NOTICE("Locked In"))
	new /obj/machinery/fluid_pipe/bluespace(get_turf(user))
	playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
	user.drop_item()
	qdel(src)
