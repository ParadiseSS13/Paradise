#define MIN_CONTROLLER_SPEED 1
#define MAX_CONTROLLER_SPEED 10
#define MIN_ELECTRICITY_LEVEL 1
#define MAX_ELECTRICITY_LEVEL 12
#define MIN_MAGNETIC_FIELD 1
#define MAX_MAGNETIC_FIELD 4
#define MAX_PATH_LENGTH 50

// Magnetic attractor, creates variable magnetic fields and attraction.
// Can also be used to emit electron/proton beams to create a center of magnetism on another tile

// tl;dr: it's magnets lol
// This was created for firing ranges, but I suppose this could have other applications - Doohl

/obj/machinery/magnetic_module

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_magnet-f"
	name = "Electromagnetic Generator"
	desc = "A device that uses station power to create points of magnetic energy."
	level = 1		// underfloor
	layer = WIRE_LAYER + 0.001
	anchored = TRUE
	idle_power_consumption = 50

	var/freq = AIRLOCK_FREQ		// radio frequency
	var/electricity_level = MIN_ELECTRICITY_LEVEL // intensity of the magnetic pull
	var/magnetic_field = MIN_MAGNETIC_FIELD // the range of magnetic attraction
	var/code = 0 // frequency code, they should be different unless you have a group of magnets working together or something
	var/turf/center // the center of magnetic attraction
	var/on = FALSE
	var/magpulling = FALSE

	// x, y modifiers to the center turf; (0, 0) is centered on the magnet, whereas (1, -1) is one tile right, one tile down
	var/center_x = 0
	var/center_y = 0
	var/max_dist = 20 // absolute value of center_x,y cannot exceed this integer

/obj/machinery/magnetic_module/Initialize(mapload)
	. = ..()
	var/turf/T = loc
	if(!T.transparent_floor)
		hide(T.intact)
	center = T

	SSradio.add_object(src, freq, RADIO_MAGNETS)

	spawn()
		magnetic_process()

/obj/machinery/magnetic_module/Destroy()
	SSradio.remove_object(src, freq)  // i have zero idea what the hell is going on
	return ..()

	// update the invisibility and icon
/obj/machinery/magnetic_module/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/magnetic_module/update_icon_state()
	icon_state = "floor_magnet[on ? "" : "0"][invisibility ? "-f" : ""]"	// if invisible, set icon to faded version
											// in case of being revealed by T-scanner

// This is the LAST thing allowed to use this
/obj/machinery/magnetic_module/receive_signal(datum/signal/signal)
	var/command = signal.data["command"]
	var/modifier = signal.data["modifier"]
	var/signal_code = signal.data["code"]
	if(command && (signal_code == code))
		Cmd(command, modifier)

/obj/machinery/magnetic_module/proc/Cmd(command, modifier)
	if(command)
		switch(command)
			if("set-electriclevel")
				if(modifier)	electricity_level = modifier
			if("set-magneticfield")
				if(modifier)	magnetic_field = modifier

			if("add-elec")
				electricity_level++
				if(electricity_level > MAX_ELECTRICITY_LEVEL)
					electricity_level = MAX_ELECTRICITY_LEVEL
			if("sub-elec")
				electricity_level--
				if(electricity_level < MIN_ELECTRICITY_LEVEL)
					electricity_level = MIN_ELECTRICITY_LEVEL
			if("add-mag")
				magnetic_field++
				if(magnetic_field > MAX_MAGNETIC_FIELD)
					magnetic_field = MAX_MAGNETIC_FIELD
			if("sub-mag")
				magnetic_field--
				if(magnetic_field < MIN_MAGNETIC_FIELD)
					magnetic_field = MIN_MAGNETIC_FIELD

			if("set-x")
				if(modifier)	center_x = modifier
			if("set-y")
				if(modifier)	center_y = modifier

			if("N") // NORTH
				center_y++
			if("S")	// SOUTH
				center_y--
			if("E") // EAST
				center_x++
			if("W") // WEST
				center_x--
			if("C") // CENTER
				center_x = 0
				center_y = 0
			if("R") // RANDOM
				center_x = rand(-max_dist, max_dist)
				center_y = rand(-max_dist, max_dist)

			if("set-code")
				if(modifier)	code = modifier
			if("toggle-power")
				on = !on

				if(on)
					spawn()
						magnetic_process()

/obj/machinery/magnetic_module/process()
	if(stat & NOPOWER)
		on = FALSE

	// Sanity checks:
	if(electricity_level < MIN_ELECTRICITY_LEVEL)
		electricity_level = MIN_ELECTRICITY_LEVEL
	if(magnetic_field < MIN_MAGNETIC_FIELD)
		magnetic_field = MIN_MAGNETIC_FIELD


	// Limitations:
	if(abs(center_x) > max_dist)
		center_x = max_dist
	if(abs(center_y) > max_dist)
		center_y = max_dist
	if(magnetic_field > MAX_MAGNETIC_FIELD)
		magnetic_field = MAX_MAGNETIC_FIELD
	if(electricity_level > MAX_ELECTRICITY_LEVEL)
		electricity_level = MAX_ELECTRICITY_LEVEL

	// Update power usage:
	if(on)
		change_power_mode(ACTIVE_POWER_USE)
		active_power_consumption = electricity_level*15
	else
		change_power_mode(NO_POWER_USE)
		update_icon(UPDATE_ICON_STATE)


/obj/machinery/magnetic_module/proc/magnetic_process() // proc that actually does the pulling
	if(magpulling) return
	while(on)

		magpulling = TRUE
		center = locate(x+center_x, y+center_y, z)
		if(center)
			for(var/obj/M in orange(magnetic_field, center))
				if(!M.anchored && (M.flags & CONDUCT))
					step_towards(M, center)

			for(var/mob/living/silicon/S in orange(magnetic_field, center))
				if(isAI(S)) continue
				step_towards(S, center)

		use_power(electricity_level * 5)
		sleep(13 - electricity_level)

	magpulling = FALSE

/obj/machinery/magnetic_controller
	name = "Magnetic Control Console"
	icon = 'icons/obj/airlock_machines.dmi' // uses an airlock machine icon, THINK GREEN HELP THE ENVIRONMENT - RECYCLING!
	icon_state = "airlock_control_standby"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 45

	// this is a temp measure
	var/frequency = AIRLOCK_FREQ
	var/datum/radio_frequency/radio_connection
	var/code = 0
	var/list/magnets = list()
	var/title = "Magnetic Control Console"
	var/autolink = FALSE // if set to TRUE, can't probe for other magnets!
	var/probing = FALSE

	var/pathpos = 1 // position in the path
	var/path = "NULL" // text path of the magnet
	var/speed = MIN_CONTROLLER_SPEED
	var/list/rpath = list() // real path of the magnet, used in iterator
	var/static/list/valid_paths = list("n", "s", "e", "w", "c", "r")

	var/moving = FALSE // TRUE if scheduled to loop
	var/looping = FALSE // TRUE if looping


/obj/machinery/magnetic_controller/Initialize(mapload)
	. = ..()

	radio_connection = SSradio.add_object(src, frequency, RADIO_MAGNETS)

	if(path) // check for default path
		filter_path() // renders rpath

	if(autolink)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/magnetic_controller/LateInitialize()
	..()
	if(autolink)
		// GLOB.machines is populated in /machinery/Initialize
		// so linkage gets delayed until that one finished.
		link_magnets()

/obj/machinery/magnetic_controller/Destroy()
	SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/magnetic_controller/proc/on_magnet_del(atom/magnet)
	magnets -= magnet

/obj/machinery/magnetic_controller/proc/link_magnets()
	magnets = list()
	for(var/obj/machinery/magnetic_module/M in GLOB.machines)
		if(M.freq == frequency && M.code == code)
			magnets.Add(M)
			RegisterSignal(M, COMSIG_PARENT_QDELETING, PROC_REF(on_magnet_del), TRUE)

/obj/machinery/magnetic_controller/process()
	if(magnets.len == 0 && autolink)
		link_magnets()

/obj/machinery/magnetic_controller/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MagnetController", name, 400, 600)
		ui.open()

/obj/machinery/magnetic_controller/attack_ai(mob/user as mob)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/magnetic_controller/attack_ghost(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/magnetic_controller/attack_hand(mob/user as mob)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/magnetic_controller/proc/find_magnet(uid)
	var/potential_magnet = locateUID(uid)
	if(istype(potential_magnet, /obj/machinery/magnetic_module))
		return potential_magnet

/obj/machinery/magnetic_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	add_fingerprint(ui.user)

	if(ui_act_modal(action, params, ui, state))
		return TRUE

	. = TRUE
	switch(action)
		if("probe_magnets")
			if(probing || autolink)
				return
			probing = TRUE
			link_magnets()
			addtimer(VARSET_CALLBACK(src, probing, FALSE), 5 SECONDS)

		if("toggle_power")
			moving = !moving
			if(moving)
				INVOKE_ASYNC(src, PROC_REF(MagnetMove))
		if("set_speed")
			var/new_speed = text2num(params["speed"])
			if(isnull(new_speed))
				return
			speed = clamp(new_speed, MIN_CONTROLLER_SPEED, MAX_CONTROLLER_SPEED)

		if("path_add")
			if(length(rpath) >= MAX_PATH_LENGTH / 2)
				return
			var/code = params["code"]
			if(!(code in valid_paths))
				return
			moving = FALSE
			pathpos = 1
			rpath += code
			path = rpath.Join(";")
		if("path_remove")
			var/index = text2num(params["index"])
			if(isnull(index) || index < 0 || index > length(rpath))
				return
			var/code = params["code"]
			if(!(code in valid_paths))
				return
			moving = FALSE
			pathpos = 1
			if(rpath[index] == code)
				rpath.Cut(index, index + 1)
			path = rpath.Join(";")
		if("path_clear")
			moving = FALSE
			pathpos = 1
			rpath = list()
			path = ""

		if("toggle_magnet_power")
			var/obj/machinery/magnetic_module/magnet = find_magnet(params["id"])
			if(!magnet)
				return
			magnet.Cmd("toggle-power")
		if("set_electricity_level")
			var/obj/machinery/magnetic_module/magnet = find_magnet(params["id"])
			if(!magnet)
				return
			var/new_electricity_level = text2num(params["electricityLevel"])
			if(isnull(new_electricity_level))
				return
			magnet.Cmd("set-electriclevel", clamp(new_electricity_level, MIN_ELECTRICITY_LEVEL, MAX_ELECTRICITY_LEVEL))
		if("set_magnetic_field")
			var/obj/machinery/magnetic_module/magnet = find_magnet(params["id"])
			if(!magnet)
				return
			var/new_magnetic_field = text2num(params["magneticField"])
			if(isnull(new_magnetic_field))
				return
			magnet.Cmd("set-magneticfield", clamp(new_magnetic_field, MIN_MAGNETIC_FIELD, MAX_MAGNETIC_FIELD))

/obj/machinery/magnetic_controller/ui_data(mob/user)
	var/data = list()

	data["autolink"] = autolink
	data["code"] = code
	data["frequency"] = frequency

	var/list/linked_magnets = list()
	for(var/obj/machinery/magnetic_module/M in magnets)
		linked_magnets += list(list(
			"uid" = M.UID(),
			"powerState" = M.on,
			"electricityLevel" = M.electricity_level,
			"magneticField" = M.magnetic_field,
		))
	data["linkedMagnets"] = linked_magnets

	data["magnetConfiguration"] = list(
		"electricityLevel" = list(
			"min" = MIN_ELECTRICITY_LEVEL,
			"max" = MAX_ELECTRICITY_LEVEL,
		),
		"magneticField" = list(
			"min" = MIN_MAGNETIC_FIELD,
			"max" = MAX_MAGNETIC_FIELD,
		),
	)

	data["path"] = rpath
	data["pathPosition"] = pathpos
	data["probing"] = probing
	data["powerState"] = moving
	data["speed"] = list(
		"value" = speed,
		"min" = MIN_CONTROLLER_SPEED,
		"max" = MAX_CONTROLLER_SPEED,
	)

	data["modal"] = ui_modal_data(src)

	return data

/obj/machinery/magnetic_controller/proc/ui_act_modal(action, params, datum/tgui/ui, datum/ui_state/state)
	. = TRUE
	var/id = params["id"] // The modal's ID
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("path_custom_input")
					ui_modal_input(src, id, "Please enter the new path:", null, arguments, rpath.Join(";"), MAX_PATH_LENGTH)
				else
					return FALSE
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("path_custom_input")
					var/new_path = answer
					if(!new_path || length(new_path) > MAX_PATH_LENGTH)
						return
					moving = FALSE
					pathpos = 1
					path = new_path
					filter_path()
				else
					return FALSE
		else
			return FALSE

/obj/machinery/magnetic_controller/proc/MagnetMove()
	if(looping) return

	while(moving && rpath.len >= 1)

		if(stat & (BROKEN|NOPOWER))
			break

		looping = TRUE

		// Prepare the radio signal
		var/datum/signal/signal = new
		signal.transmission_method = TRANSMISSION_RADIO // radio transmission
		signal.source = src
		signal.frequency = frequency
		signal.data["code"] = code

		if(pathpos > rpath.len) // if the position is greater than the length, we just loop through the list!
			pathpos = 1

		var/nextmove = uppertext(rpath[pathpos]) // makes it un-case-sensitive

		if(!(nextmove in list("N","S","E","W","C","R")))
			// N, S, E, W are directional
			// C is center
			// R is random (in magnetic field's bounds)
			qdel(signal)
			break // break the loop if the character located is invalid

		signal.data["command"] = nextmove


		pathpos++ // increase iterator

		// Broadcast the signal
		spawn()
			radio_connection.post_signal(src, signal, filter = RADIO_MAGNETS)

		if(speed >= MAX_CONTROLLER_SPEED)
			sleep(1)
		else
			sleep(MAX_ELECTRICITY_LEVEL - speed)

	looping = FALSE


/obj/machinery/magnetic_controller/proc/filter_path()
	// Generates the rpath variable using the path string, think of this as "string2list"
	// Doesn't use params2list() because of the akward way it stacks entities
	rpath = list() //  clear rpath
	var/maximum_character = min( MAX_PATH_LENGTH, length(path) ) // chooses the maximum length of the iterator. 50 max length

	for(var/i=1, i<=maximum_character, i++) // iterates through all characters in path

		var/nextchar = copytext(path, i, i+1) // find next character

		if(!(nextchar in list(";", "&", "*", " "))) // if char is a separator, ignore
			rpath += copytext(path, i, i+1) // else, add to list

		// there doesn't HAVE to be separators but it makes paths syntatically visible



#undef MIN_CONTROLLER_SPEED
#undef MAX_CONTROLLER_SPEED
#undef MIN_ELECTRICITY_LEVEL
#undef MAX_ELECTRICITY_LEVEL
#undef MIN_MAGNETIC_FIELD
#undef MAX_MAGNETIC_FIELD
#undef MAX_PATH_LENGTH
