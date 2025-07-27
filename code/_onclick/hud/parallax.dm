/datum/hud/proc/create_parallax(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return
	var/client/C = screenmob.client
	if(!apply_parallax_pref(screenmob))
		return
	// this is needed so it blends properly with the space plane and blackness plane.
	var/atom/movable/screen/plane_master/space/S = plane_masters["[PLANE_SPACE]"]
	if(C.prefs.toggles2 & PREFTOGGLE_2_PARALLAX_IN_DARKNESS)
		S.color = rgb(0, 0, 0, 0)
	else
		S.color = list(1, 1, 1, 1,
					1, 1, 1, 1,
					1, 1, 1, 1,
					1, 1, 1, 1,)
	S.appearance_flags |= NO_CLIENT_COLOR
	if(!length(C.parallax_layers_cached))
		C.parallax_layers_cached = list()
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/layer_1(null, C.view)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/layer_2(null, C.view)
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/planet(null, C.view)
		if(SSparallax.random_layer)
			C.parallax_layers_cached += new SSparallax.random_layer
		C.parallax_layers_cached += new /atom/movable/screen/parallax_layer/layer_3(null, C.view)

	C.parallax_layers = C.parallax_layers_cached.Copy()

	var/atom/movable/screen/plane_master/parallax/parallax_plane_master = plane_masters["[PLANE_SPACE_PARALLAX]"]
	if(C.prefs.toggles2 & PREFTOGGLE_2_PARALLAX_IN_DARKNESS)
		parallax_plane_master.blend_mode = BLEND_ADD
	else
		parallax_plane_master.blend_mode = BLEND_MULTIPLY

	if(length(C.parallax_layers) > C.parallax_layers_max)
		C.parallax_layers.len = C.parallax_layers_max

	C.screen |= (C.parallax_layers + C.parallax_static_layers_tail)

/datum/hud/proc/remove_parallax(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob.client
	C.screen -= (C.parallax_layers_cached + C.parallax_static_layers_tail)
	C.parallax_layers = null
	var/atom/movable/screen/plane_master/space/S = plane_masters["[PLANE_SPACE]"]
	S.color = null
	S.appearance_flags &= ~NO_CLIENT_COLOR

/datum/hud/proc/apply_parallax_pref(mob/viewmob)
	var/mob/screen_mob = viewmob || mymob
	var/client/C = screen_mob.client
	if(!istype(C))
		return FALSE
	if(C.prefs)
		var/pref = C.prefs.parallax
		if(isnull(pref))
			pref = PARALLAX_HIGH
		switch(C.prefs.parallax)
			if(PARALLAX_INSANE)
				C.parallax_throttle = FALSE
				C.parallax_layers_max = 5
				return TRUE

			if(PARALLAX_MED)
				C.parallax_throttle = PARALLAX_DELAY_MED
				C.parallax_layers_max = 3
				return TRUE

			if(PARALLAX_LOW)
				C.parallax_throttle = PARALLAX_DELAY_LOW
				C.parallax_layers_max = 1
				return TRUE

			if(PARALLAX_DISABLE)
				return FALSE

	//This is high parallax.
	C.parallax_throttle = PARALLAX_DELAY_DEFAULT
	C.parallax_layers_max = 4
	return TRUE

/datum/hud/proc/update_parallax_pref(mob/viewmob)
	var/mob/screen_mob = viewmob || mymob
	if(!screen_mob.client)
		return
	remove_parallax(screen_mob)
	create_parallax(screen_mob)
	update_parallax(screen_mob)

// This sets which way the current shuttle is moving (returns true if the shuttle has stopped moving so the caller can append their animation)
// Well, it would if our shuttle code had dynamic areas
/datum/hud/proc/set_parallax_movedir(mob/viewmob, new_parallax_movedir, skip_windups)
	. = FALSE
	var/mob/screen_mob = viewmob || mymob
	var/client/C = screen_mob.client
	if(!istype(C))
		return
	if(new_parallax_movedir == C.parallax_movedir)
		return
	var/animatedir = new_parallax_movedir
	if(!new_parallax_movedir)
		var/animate_time = 0
		for(var/thing in C.parallax_layers)
			var/atom/movable/screen/parallax_layer/L = thing
			L.icon_state = initial(L.icon_state)
			L.update_o(C.view)
			var/T = PARALLAX_LOOP_TIME / L.speed
			if(T > animate_time)
				animate_time = T
		animatedir = C.parallax_movedir

	var/matrix/newtransform
	switch(animatedir)
		if(NORTH)
			newtransform = matrix(1, 0, 0, 0, 1, 480)
		if(SOUTH)
			newtransform = matrix(1, 0, 0, 0, 1,-480)
		if(EAST)
			newtransform = matrix(1, 0, 480, 0, 1, 0)
		if(WEST)
			newtransform = matrix(1, 0,-480, 0, 1, 0)

	var/shortesttimer
	for(var/thing in C.parallax_layers)
		var/atom/movable/screen/parallax_layer/L = thing

		var/T = PARALLAX_LOOP_TIME / L.speed
		if(isnull(shortesttimer))
			shortesttimer = T
		if(T < shortesttimer)
			shortesttimer = T
		L.transform = newtransform
		animate(L, transform = matrix(), time = T, easing = QUAD_EASING | (new_parallax_movedir ? EASE_IN : EASE_OUT), flags = ANIMATION_END_NOW)
		if(new_parallax_movedir)
			L.transform = newtransform
			animate(transform = matrix(), time = T) //queue up another animate so lag doesn't create a shutter

	C.parallax_movedir = new_parallax_movedir
	if(C.parallax_animate_timer)
		deltimer(C.parallax_animate_timer)
	var/datum/callback/CB = CALLBACK(src, PROC_REF(update_parallax_motionblur), C, animatedir, new_parallax_movedir, newtransform)
	if(skip_windups)
		CB.Invoke()
	else
		C.parallax_animate_timer = addtimer(CB, min(shortesttimer, PARALLAX_LOOP_TIME), TIMER_CLIENT_TIME|TIMER_STOPPABLE)

/datum/hud/proc/update_parallax_motionblur(client/C, animatedir, new_parallax_movedir, matrix/newtransform)
	C.parallax_animate_timer = FALSE
	for(var/thing in C.parallax_layers)
		var/atom/movable/screen/parallax_layer/L = thing
		if(!new_parallax_movedir)
			animate(L)
			continue

		var/newstate = initial(L.icon_state)
		if(animatedir)
			if(animatedir == NORTH || animatedir == SOUTH)
				newstate += "_vertical"
			else
				newstate += "_horizontal"

		var/T = PARALLAX_LOOP_TIME / L.speed

		if(newstate in icon_states(L.icon))
			L.icon_state = newstate
			L.update_o(C.view)

		L.transform = newtransform

		animate(L, transform = L.transform, time = 0, loop = -1, flags = ANIMATION_END_NOW)
		animate(transform = matrix(), time = T)

/datum/hud/proc/update_parallax(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob.client
	var/turf/posobj = get_turf(C.eye)
	if(!posobj)
		return
	var/area/areaobj = posobj.loc

	// Update the movement direction of the parallax if necessary (for shuttles)
	var/area/shuttle/SA = areaobj
	if(!SA || !SA.moving)
		set_parallax_movedir(screenmob, 0)
	else
		set_parallax_movedir(screenmob, SA.parallax_move_direction)

	var/force
	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj
		force = TRUE

	if(!force && world.time < (C.last_parallax_shift + C.parallax_throttle))
		return

	//Doing it this way prevents parallax layers from "jumping" when you change Z-Levels.
	var/offset_x = posobj.x - C.previous_turf.x
	var/offset_y = posobj.y - C.previous_turf.y

	if(!offset_x && !offset_y && !force)
		return

	var/last_delay = world.time - C.last_parallax_shift
	last_delay = min(last_delay, C.parallax_throttle)
	C.previous_turf = posobj
	C.last_parallax_shift = world.time

	for(var/thing in C.parallax_layers)
		var/atom/movable/screen/parallax_layer/L = thing
		L.update_status(screenmob)
		if(L.view_sized != C.view)
			L.update_o(C.view)

		if(L.absolute)
			L.offset_x = -(posobj.x - SSparallax.planet_x_offset) * L.speed
			L.offset_y = -(posobj.y - SSparallax.planet_y_offset) * L.speed
		else
			L.offset_x -= offset_x * L.speed
			L.offset_y -= offset_y * L.speed

			if(L.offset_x > 240)
				L.offset_x -= 480
			if(L.offset_x < -240)
				L.offset_x += 480
			if(L.offset_y > 240)
				L.offset_y -= 480
			if(L.offset_y < -240)
				L.offset_y += 480

		L.screen_loc = "CENTER-7:[round(L.offset_x,1)],CENTER-7:[round(L.offset_y,1)]"

/atom/movable/proc/update_parallax_contents()
	if(length(client_mobs_in_contents))
		for(var/thing in client_mobs_in_contents)
			var/mob/M = thing
			if(M && M.client && M.hud_used && length(M.client.parallax_layers))
				M.hud_used.update_parallax()

/atom/movable/screen/parallax_layer
	icon = 'icons/effects/parallax.dmi'
	var/speed = 1
	var/offset_x = 0
	var/offset_y = 0
	var/view_sized
	var/absolute = FALSE
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_PARALLAX
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = 0


/atom/movable/screen/parallax_layer/New(view)
	..()
	if(!view)
		view = world.view
	update_o(view)

/atom/movable/screen/parallax_layer/proc/update_o(view)
	if(!view)
		view = world.view

	var/static/parallax_scaler = world.icon_size / 480

	// Turn the view size into a grid of correctly scaled overlays
	var/list/viewscales = getviewsize(view)
	var/countx = CEILING((viewscales[1] / 2) * parallax_scaler, 1) + 1
	var/county = CEILING((viewscales[2] / 2) * parallax_scaler, 1) + 1
	var/list/new_overlays = list()
	for(var/x in -countx to countx)
		for(var/y in -county to county)
			if(x == 0 && y == 0)
				continue
			var/mutable_appearance/texture_overlay = mutable_appearance(icon, icon_state)
			texture_overlay.transform = matrix(1, 0, x * 480, 0, 1, y * 480)
			new_overlays += texture_overlay
	cut_overlays()
	add_overlay(new_overlays)
	// Cache this
	view_sized = view

/atom/movable/screen/parallax_layer/proc/update_status(mob/M)
	return

/atom/movable/screen/parallax_layer/layer_1
	icon_state = "layer1"
	speed = 0.6
	layer = 1

/atom/movable/screen/parallax_layer/layer_2
	icon_state = "layer2"
	speed = 1
	layer = 2

/atom/movable/screen/parallax_layer/layer_3
	icon_state = "layer3"
	speed = 1.4
	layer = 3

/atom/movable/screen/parallax_layer/random
	blend_mode = BLEND_OVERLAY
	speed = 3
	layer = 3

/atom/movable/screen/parallax_layer/random/space_gas
	icon_state = "space_gas"

/atom/movable/screen/parallax_layer/random/space_gas/New(view)
	..()
	add_atom_colour(SSparallax.random_parallax_color, ADMIN_COLOUR_PRIORITY)

/atom/movable/screen/parallax_layer/random/asteroids
	icon_state = "asteroids"
	layer = 4

/atom/movable/screen/parallax_layer/planet
	icon_state = "planet_lava"
	blend_mode = BLEND_OVERLAY
	absolute = TRUE //Status of seperation
	speed = 3
	layer = 30

/atom/movable/screen/parallax_layer/planet/Initialize(mapload)
	. = ..()
	if(SSmapping.lavaland_theme?.planet_icon_state)
		icon_state = SSmapping.lavaland_theme.planet_icon_state

/atom/movable/screen/parallax_layer/planet/update_status(mob/M)
	var/turf/T = get_turf(M)
	if(is_station_level(T.z))
		invisibility = 0
	else
		invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/parallax_layer/planet/update_o()
	return //Shit wont move

/atom/movable/screen/parallax_pmaster
	appearance_flags = PLANE_MASTER
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = FALSE
	screen_loc = "CENTER-7,CENTER-7"

/atom/movable/screen/parallax_space_whitifier
	appearance_flags = PLANE_MASTER
	plane = PLANE_SPACE
	color = list(
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		1, 1, 1, 1,
		0, 0, 0, 0
		)
	screen_loc = "CENTER-7,CENTER-7"
