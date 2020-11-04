//--------------------------------------------
// Pipe colors
//
// Add them here and to the pipe_colors list
//  to automatically add them to all relevant
//  atmospherics devices.
//--------------------------------------------

/proc/pipe_color_lookup(var/color)
	for(var/C in GLOB.pipe_colors)
		if(color == GLOB.pipe_colors[C])
			return "[C]"

/proc/pipe_color_check(var/color)
	if(!color)
		return 1
	for(var/C in GLOB.pipe_colors)
		if(color == GLOB.pipe_colors[C])
			return 1
	return 0

//--------------------------------------------
// Icon cache generation
//--------------------------------------------

/datum/pipe_icon_manager
	var/list/pipe_icons[]
	var/list/manifold_icons[]
	var/list/device_icons[]
	var/list/underlays[]
	//var/list/underlays_down[]
	//var/list/underlays_exposed[]
	//var/list/underlays_intact[]
	//var/list/pipe_underlays_exposed[]
	//var/list/pipe_underlays_intact[]
	var/list/omni_icons[]

/datum/pipe_icon_manager/New()
	check_icons()

/datum/pipe_icon_manager/proc/get_atmos_icon(var/device, var/dir, var/color, var/state)
	check_icons()

	device = "[device]"
	state = "[state]"
	color = "[color]"
	dir = "[dir]"

	switch(device)
		if("pipe")
			return pipe_icons[state + color]
		if("manifold")
			return manifold_icons[state + color]
		if("device")
			return device_icons[state]
		if("omni")
			return omni_icons[state]
		if("underlay")
			return underlays[state + dir + color]
		//if("underlay_intact")
		//	return underlays_intact[state + dir + color]
	//	if("underlay_exposed")
	//		return underlays_exposed[state + dir + color]
	//	if("underlay_down")
	//		return underlays_down[state + dir + color]
	//	if("pipe_underlay_exposed")
	//		return pipe_underlays_exposed[state + dir + color]
	//	if("pipe_underlay_intact")
	//		return pipe_underlays_intact[state + dir + color]

/datum/pipe_icon_manager/proc/check_icons()
	if(!pipe_icons)
		gen_pipe_icons()
	if(!manifold_icons)
		gen_manifold_icons()
	if(!device_icons)
		gen_device_icons()
	if(!omni_icons)
		gen_omni_icons()
	//if(!underlays_intact || !underlays_down || !underlays_exposed || !pipe_underlays_exposed || !pipe_underlays_intact)
	if(!underlays)
		gen_underlay_icons()

/datum/pipe_icon_manager/proc/gen_pipe_icons()
	if(!pipe_icons)
		pipe_icons = new()

	var/icon/pipe = new('icons/atmos/pipes.dmi')

	for(var/state in pipe.IconStates())
		if(!state || findtext(state, "map"))
			continue

		var/cache_name = state
		var/image/I = image('icons/atmos/pipes.dmi', icon_state = state)
		pipe_icons[cache_name] = I

		for(var/pipe_color in GLOB.pipe_colors)
			I = image('icons/atmos/pipes.dmi', icon_state = state)
			I.color = GLOB.pipe_colors[pipe_color]
			pipe_icons[state + "[GLOB.pipe_colors[pipe_color]]"] = I

	pipe = new ('icons/atmos/heat.dmi')
	for(var/state in pipe.IconStates())
		if(!state || findtext(state, "map"))
			continue
		pipe_icons["hepipe" + state] = image('icons/atmos/heat.dmi', icon_state = state)

	pipe = new ('icons/atmos/junction.dmi')
	for(var/state in pipe.IconStates())
		if(!state || findtext(state, "map"))
			continue
		pipe_icons["hejunction" + state] = image('icons/atmos/junction.dmi', icon_state = state)

/datum/pipe_icon_manager/proc/gen_manifold_icons()
	if(!manifold_icons)
		manifold_icons = new()

	var/icon/pipe = new('icons/atmos/manifold.dmi')

	for(var/state in pipe.IconStates())
		if(findtext(state, "clamps"))
			var/image/I = image('icons/atmos/manifold.dmi', icon_state = state)
			manifold_icons[state] = I
			continue

		if(findtext(state, "core") || findtext(state, "4way"))
			var/image/I = image('icons/atmos/manifold.dmi', icon_state = state)
			manifold_icons[state] = I
			for(var/pipe_color in GLOB.pipe_colors)
				I = image('icons/atmos/manifold.dmi', icon_state = state)
				I.color = GLOB.pipe_colors[pipe_color]
				manifold_icons[state + GLOB.pipe_colors[pipe_color]] = I

/datum/pipe_icon_manager/proc/gen_device_icons()
	if(!device_icons)
		device_icons = new()

	var/icon/device

	device = new('icons/atmos/vent_pump.dmi')
	for(var/state in device.IconStates())
		if(!state || findtext(state, "map"))
			continue
		device_icons["vent" + state] = image('icons/atmos/vent_pump.dmi', icon_state = state)

	device = new('icons/atmos/vent_scrubber.dmi')
	for(var/state in device.IconStates())
		if(!state || findtext(state, "map"))
			continue
		device_icons["scrubber" + state] = image('icons/atmos/vent_scrubber.dmi', icon_state = state)

/datum/pipe_icon_manager/proc/gen_omni_icons()
	if(!omni_icons)
		omni_icons = new()

	var/icon/omni = new('icons/atmos/omni_devices.dmi')

	for(var/state in omni.IconStates())
		if(!state || findtext(state, "map"))
			continue
		omni_icons[state] = image('icons/atmos/omni_devices.dmi', icon_state = state)


/datum/pipe_icon_manager/proc/gen_underlay_icons()

	if(!underlays)
		underlays = new()

	var/icon/pipe = new('icons/atmos/pipe_underlays.dmi')

	for(var/state in pipe.IconStates())
		if(state == "")
			continue

		var/cache_name = state

		for(var/D in GLOB.cardinal)
			var/image/I = image(icon('icons/atmos/pipe_underlays.dmi', icon_state = state, dir = D))
			underlays[cache_name + "[D]"] = I
			for(var/pipe_color in GLOB.pipe_colors)
				I = image(icon('icons/atmos/pipe_underlays.dmi', icon_state = state, dir = D))
				I.color = GLOB.pipe_colors[pipe_color]
				underlays[state + "[D]" + "[GLOB.pipe_colors[pipe_color]]"] = I
