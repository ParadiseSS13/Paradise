/obj/item/fluid_pipe
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	icon_state = "pipe_item"

/obj/machinery/fluid_pipe
	name = "fluid pipe"
	desc = "Moves around fluids"
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	icon_state = "pipe"
	power_state = NO_POWER_USE
	flags_2 = NO_MALF_EFFECT_2
	anchored = TRUE
	density = TRUE
	/// The pipe datum connected to this pipe
	var/datum/fluid_pipe/fluid_datum
	/// Is this fluid machinery or just a pipe
	var/just_a_pipe = TRUE
	/// How many neighbors do we have? `DO NOT VAREDIT THIS`
	var/neighbors = 0
	/// How much fluid units can we fit in this pipe?
	var/capacity = 50
	/// What directions do we look for connecting? Cardinals by default
	var/list/connect_dirs = list(NORTH, SOUTH, EAST, WEST)
	/// Do we only connect to one thing?
	var/only_one_connect = FALSE
	/// Are we connected to something?
	var/is_connected = FALSE

/obj/machinery/fluid_pipe/Initialize(mapload, direction)
	. = ..()
	if(direction)
		dir = direction
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/fluid_pipe/LateInitialize()
	. = ..()
	if(!fluid_datum) // DGTODO check if this isn't fucking things up
		blind_connect()
	START_PROCESSING(SSfluid, src)

/obj/machinery/fluid_pipe/Destroy()
	disconnect_pipe()
	return ..()

/obj/machinery/fluid_pipe/process()
	return PROCESS_KILL

/obj/machinery/fluid_pipe/examine(mob/user)
	. = ..()
	. += "[src] is currently [anchored ? "" : "un"]anchored"

/obj/machinery/fluid_pipe/return_analyzable_fluids()
	return TRUE

// This is currently as clean as I could make it
/obj/machinery/fluid_pipe/proc/connect_pipes(obj/machinery/fluid_pipe/pipe_to_connect_to)
	if(QDELETED(pipe_to_connect_to))
		return

	if(special_connect_check(pipe_to_connect_to))
		return

	else if((only_one_connect && is_connected) || (pipe_to_connect_to.only_one_connect && pipe_to_connect_to.is_connected))
		return

	else if(isnull(fluid_datum) && pipe_to_connect_to.fluid_datum)
		pipe_to_connect_to.fluid_datum.add_pipe(src)

	else if(fluid_datum && pipe_to_connect_to.fluid_datum)
		if(fluid_datum != pipe_to_connect_to.fluid_datum)
			fluid_datum.merge(pipe_to_connect_to.fluid_datum)

	else if(isnull(pipe_to_connect_to.fluid_datum))
		if(!fluid_datum)
			fluid_datum = new(src)
		fluid_datum.add_pipe(pipe_to_connect_to)

	is_connected = TRUE
	pipe_to_connect_to.is_connected = TRUE

	update_neighbors()
	pipe_to_connect_to.update_neighbors()

	update_icon()
	pipe_to_connect_to.update_icon()

/obj/machinery/fluid_pipe/proc/connect_chain(list/all_pipes = list())
	all_pipes -= src
	if(!length(all_pipes))
		return

	var/list/nearby_pipes = all_pipes & orange(1, src)
	for(var/obj/machinery/fluid_pipe/pipe as anything in nearby_pipes)
		if(!(get_dir(src, pipe) in connect_dirs) || !(REVERSE_DIR(get_dir(src, pipe)) in pipe.connect_dirs))
			continue
		if((only_one_connect && is_connected) || (pipe.only_one_connect && pipe.is_connected))
			continue
		if(pipe.fluid_datum) // Already connected, don't connect again
			if(fluid_datum != pipe.fluid_datum)
				fluid_datum.merge(pipe.fluid_datum)
			if(QDELETED(fluid_datum)) // Should theoretically only be called on the first pipe this proc is called on
				pipe.fluid_datum.add_pipe(src)

			update_neighbors()
			pipe.update_neighbors()
			continue

		if(QDELETED(fluid_datum)) // Should theoretically only be called on the first pipe this proc is called on
			fluid_datum = new(src)

		fluid_datum.add_pipe(pipe)
		update_neighbors()
		pipe.update_neighbors()
		pipe.is_connected = TRUE
		is_connected = TRUE
		// Normally you'd update icons here, however we do that at the end otherwise lag may happen
		pipe.connect_chain(all_pipes)

/obj/machinery/fluid_pipe/proc/disconnect_pipe()
	is_connected = FALSE
	if(neighbors <= 1) // Sad and alone
		fluid_datum = null
		return

	// DGTODO
	message_admins("WE ARE HERE AAAAA")
	SSfluid.datums_to_rebuild += list(list(fluid_datum, get_adjacent_pipes()))
	fluid_datum.remove_pipe(src)
	fluid_datum = null

/// Want to connect a pipe to other pipes, but don't know where the other pipes are?
/obj/machinery/fluid_pipe/proc/blind_connect()
	for(var/obj/machinery/fluid_pipe/pipe as anything in get_adjacent_pipes())
		pipe.connect_pipes(src) // The reason for this is so we can override the behaviour on pumps
								// so we can make them reconsider all of their connections every time they are connected

	update_icon()

/obj/machinery/fluid_pipe/proc/update_neighbors()
	neighbors = length(get_adjacent_pipes())

/obj/machinery/fluid_pipe/attack_hand(mob/user)
	if(..())
		return
	if(anchored)
		return TRUE
	dir = turn(dir, -90)

/obj/machinery/fluid_pipe/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	to_chat(user, "You start [anchored ? "un" : ""]wrenching [src].")
	if(!do_after(user, 3 SECONDS * I.toolspeed, TRUE, src))
		to_chat(user, "You stop.") // DGTODO: add span classes + message
		return

	if(!anchored)
		anchored = TRUE
		blind_connect()
	else
		// DGTODO: add item pipe here and make a new one // Maybe just keep an unwrenched version?
		anchored = FALSE

/obj/machinery/fluid_pipe/update_overlays()
	. = ..()
	. += fluid_datum?.return_percentile_full()

/// Basic icon state handling for pipes, will automatically connect to adjacent pipes, no hassle needed
/obj/machinery/fluid_pipe/update_icon_state()
	if(!anchored)
		icon_state = initial(icon_state)
		return

	var/temp_state = "pipe"
	for(var/obj/machinery/fluid_pipe/pipe as anything in get_adjacent_pipes())
		temp_state += "_[get_dir(src, pipe)]"

	icon_state = temp_state

/// Clears out the pipenet datum references. Override if your machinery holds more references
/obj/machinery/fluid_pipe/proc/clear_pipenet_refs()
	SHOULD_CALL_PARENT(TRUE)
	fluid_datum = null

/obj/machinery/fluid_pipe/proc/get_adjacent_pipes()
	. = list()
	for(var/direction in connect_dirs)
		for(var/obj/machinery/fluid_pipe/pipe in get_step(src, direction))
			if(pipe.anchored && (get_dir(pipe, src) in pipe.connect_dirs))
				. += pipe

/// Proc to check special conditions. Return `TRUE` if you don't want to connect with this pipe
/obj/machinery/fluid_pipe/proc/special_connect_check(obj/machinery/fluid_pipe/pipe)
	return FALSE

/obj/machinery/fluid_pipe/ex_act(severity)
	var/chance = 0
	switch(severity)
		if(EXPLODE_DEVASTATE)
			chance = 100
		if(EXPLODE_HEAVY)
			chance = 50 // It either happens or it don't
		if(EXPLODE_LIGHT)
			chance = 20
	if(prob(chance) && !QDELETED(fluid_datum)) // Big pipelines can go kinda crazy and we need to check if we aren't already half blown up
		fluid_datum.fluid_explosion(src, severity)
	return ..()

/obj/machinery/fluid_pipe/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_ADDFLUID, "Add fluid")
	VV_DROPDOWN_OPTION(VV_HK_DELFLUID, "Delete fluid")

/obj/machinery/fluid_pipe/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return

	if(href_list[VV_HK_ADDFLUID])
		if(!check_rights(R_DEBUG|R_SERVER))
			return

		var/fluid_type = tgui_alert(usr, "What type of fluid do you want to add?", "Fluid addition", GLOB.fluid_name_to_path)
		var/amount = tgui_input_number(usr, "How much should we add?", "Fluid amount", 1, INFINITY, 0)
		log_admin("Added [amount] units of [fluid_type]")

		fluid_type = GLOB.fluid_name_to_path[fluid_type]
		if(!fluid_datum)
			fluid_datum = new(src)
		fluid_datum.add_fluid(fluid_type, amount)


	if(href_list[VV_HK_DELFLUID])
		if(!check_rights(R_DEBUG|R_SERVER))
			return

		var/alist/fluids_to_pick_from = alist()
		for(var/datum/fluid/liquid as anything in fluid_datum.fluids)
			fluids_to_pick_from[liquid.fluid_name] = liquid.type
		var/fluid_name = tgui_alert(usr, "What fluid do you want to remove?", "Fluid removal", fluids_to_pick_from)
		if(!fluid_name)
			return
		fluid_datum.remove_fluid(fluids_to_pick_from[fluid_name])

// Abstract fluid pipes, useful for machinery that can have multiple intake slots
/obj/machinery/fluid_pipe/abstract
	name = "You should not see this"
	desc = "Please report where you saw this on the github"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = null
	icon_state = null
	just_a_pipe = FALSE
	connect_dirs = list()
	/// Ref to our parent
	var/obj/machinery/fluid_pipe/parent

/obj/machinery/fluid_pipe/abstract/Initialize(mapload, direction, _parent)
	. = ..()
	parent = _parent

/obj/machinery/fluid_pipe/abstract/Destroy()
	parent = null
	return ..()

/obj/machinery/fluid_pipe/abstract/update_icon_state()
	if(QDELETED(parent))
		return
	parent.update_icon()
