/client
	var/list/parallax_layers
	var/list/parallax_layers_cached
	var/static/list/parallax_static_layers_tail = newlist(/obj/screen/parallax_pmaster, /obj/screen/parallax_space_whitifier)
	var/atom/movable/movingmob
	var/turf/previous_turf
	var/dont_animate_parallax //world.time of when we can state animate()ing parallax again
	var/last_parallax_shift //world.time of last update
	var/parallax_throttle = 0 //ds between updates
	var/parallax_movedir = 0
	var/parallax_layers_max = 3
	var/parallax_animate_timer

/datum/hud/proc/create_parallax()
	var/client/C = mymob.client
	if(!apply_parallax_pref())
		return

	if(!length(C.parallax_layers_cached))
		C.parallax_layers_cached = list()
		C.parallax_layers_cached += new /obj/screen/parallax_layer/layer_1(null, C.view)
		C.parallax_layers_cached += new /obj/screen/parallax_layer/layer_2(null, C.view)
		C.parallax_layers_cached += new /obj/screen/parallax_layer/planet(null, C.view)
		C.parallax_layers_cached += new /obj/screen/parallax_layer/layer_3(null, C.view)

	C.parallax_layers = C.parallax_layers_cached.Copy()

	if(length(C.parallax_layers) > C.parallax_layers_max)
		C.parallax_layers.len = C.parallax_layers_max

	C.screen |= (C.parallax_layers + C.parallax_static_layers_tail)

/datum/hud/proc/remove_parallax()
	var/client/C = mymob.client
	C.screen -= (C.parallax_layers_cached + C.parallax_static_layers_tail)
	C.parallax_layers = null

/datum/hud/proc/apply_parallax_pref()
	var/client/C = mymob.client
	if(C.prefs)
		var/pref = C.prefs.parallax
		if (isnull(pref))
			pref = PARALLAX_HIGH
		switch(C.prefs.parallax)
			if (PARALLAX_INSANE)
				C.parallax_throttle = FALSE
				C.parallax_layers_max = 4
				return TRUE

			if (PARALLAX_MED)
				C.parallax_throttle = PARALLAX_DELAY_MED
				C.parallax_layers_max = 2
				return TRUE

			if (PARALLAX_LOW)
				C.parallax_throttle = PARALLAX_DELAY_LOW
				C.parallax_layers_max = 1
				return TRUE

			if (PARALLAX_DISABLE)
				return FALSE

	C.parallax_throttle = PARALLAX_DELAY_DEFAULT
	C.parallax_layers_max = 3
	return TRUE

/datum/hud/proc/update_parallax_pref()
	remove_parallax()
	create_parallax()
	update_parallax()

// This sets which way the current shuttle is moving (returns true if the shuttle has stopped moving so the caller can append their animation)
// Well, it would if our shuttle code had dynamic areas
/datum/hud/proc/set_parallax_movedir(new_parallax_movedir, skip_windups)
	. = FALSE
	var/client/C = mymob.client
	if(new_parallax_movedir == C.parallax_movedir)
		return
	var/animatedir = new_parallax_movedir
	if(new_parallax_movedir == FALSE)
		var/animate_time = 0
		for(var/thing in C.parallax_layers)
			var/obj/screen/parallax_layer/L = thing
			L.icon_state = initial(L.icon_state)
			L.update_o(C.view)
			var/T = PARALLAX_LOOP_TIME / L.speed
			if(T > animate_time)
				animate_time = T
		C.dont_animate_parallax = world.time + min(animate_time, PARALLAX_LOOP_TIME)
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
		var/obj/screen/parallax_layer/L = thing

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
	var/datum/callback/CB = CALLBACK(src, .proc/update_parallax_motionblur, C, animatedir, new_parallax_movedir, newtransform)
	if(skip_windups)
		CB.Invoke()
	else
		C.parallax_animate_timer = addtimer(CB, min(shortesttimer, PARALLAX_LOOP_TIME), TIMER_CLIENT_TIME|TIMER_STOPPABLE)

/datum/hud/proc/update_parallax_motionblur(client/C, animatedir, new_parallax_movedir, matrix/newtransform)
	C.parallax_animate_timer = FALSE
	for(var/thing in C.parallax_layers)
		var/obj/screen/parallax_layer/L = thing
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

		animate(L, transform = matrix(), time = T, loop = -1, flags = ANIMATION_END_NOW)

/datum/hud/proc/update_parallax()
	var/client/C = mymob.client
	var/turf/posobj = get_turf(C.eye)
	if(!posobj)
		return
	var/area/areaobj = posobj.loc

	// Update the movement direction of the parallax if necessary (for shuttles)
	var/area/shuttle/SA = areaobj
	if(!SA || !SA.moving)
		set_parallax_movedir(0)
	else
		set_parallax_movedir(SA.parallax_movedir)

	var/force
	if(!C.previous_turf || (C.previous_turf.z != posobj.z))
		C.previous_turf = posobj
		force = TRUE

	if(!force && world.time < C.last_parallax_shift+C.parallax_throttle)
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
		var/obj/screen/parallax_layer/L = thing
		L.update_status(mymob)
		if(L.view_sized != C.view)
			L.update_o(C.view)

		var/change_x
		var/change_y

		if(L.absolute)
			L.offset_x = -(posobj.x - SSparallax.planet_x_offset) * L.speed
			L.offset_y = -(posobj.y - SSparallax.planet_y_offset) * L.speed
		else
			change_x = offset_x * L.speed
			L.offset_x -= change_x
			change_y = offset_y * L.speed
			L.offset_y -= change_y

			if(L.offset_x > 240)
				L.offset_x -= 480
			if(L.offset_x < -240)
				L.offset_x += 480
			if(L.offset_y > 240)
				L.offset_y -= 480
			if(L.offset_y < -240)
				L.offset_y += 480

		if(!(areaobj.parallax_movedir && areaobj.moving) && C.dont_animate_parallax <= world.time && (offset_x || offset_y) && abs(offset_x) <= max(C.parallax_throttle/world.tick_lag+1,1) && abs(offset_y) <= max(C.parallax_throttle/world.tick_lag+1,1) && (round(abs(change_x)) > 1 || round(abs(change_y)) > 1))
			L.transform = matrix(1, 0, offset_x*L.speed, 0, 1, offset_y*L.speed)
			animate(L, transform=matrix(), time = last_delay)

		L.screen_loc = "CENTER-7:[round(L.offset_x,1)],CENTER-7:[round(L.offset_y,1)]"

/atom/movable/proc/update_parallax_contents()
	if(length(client_mobs_in_contents))
		for(var/thing in client_mobs_in_contents)
			var/mob/M = thing
			if(M && M.client && M.hud_used && length(M.client.parallax_layers))
				M.hud_used.update_parallax()

/obj/screen/parallax_layer
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


/obj/screen/parallax_layer/New(view)
	..()
	if(!view)
		view = world.view
	update_o(view)

/obj/screen/parallax_layer/proc/update_o(view)
	if(!view)
		view = world.view
	var/list/new_overlays = list()
	var/count = Ceiling(view/(480/world.icon_size))+1
	for(var/x in -count to count)
		for(var/y in -count to count)
			if(x == 0 && y == 0)
				continue
			var/mutable_appearance/texture_overlay = mutable_appearance(icon, icon_state)
			texture_overlay.transform = matrix(1, 0, x*480, 0, 1, y*480)
			new_overlays += texture_overlay

	overlays = new_overlays
	view_sized = view

/obj/screen/parallax_layer/proc/update_status(mob/M)
	return

/obj/screen/parallax_layer/layer_1
	icon_state = "layer1"
	speed = 0.6
	layer = 1

/obj/screen/parallax_layer/layer_2
	icon_state = "layer2"
	speed = 1
	layer = 2

/obj/screen/parallax_layer/layer_3
	icon_state = "layer3"
	speed = 1.4
	layer = 3

/obj/screen/parallax_layer/planet
	icon_state = "planet"
	blend_mode = BLEND_OVERLAY
	absolute = TRUE //Status of seperation
	speed = 3
	layer = 30

/obj/screen/parallax_layer/planet/update_status(mob/M)
	var/turf/T = get_turf(M)
	if(is_station_level(T.z))
		invisibility = 0
	else
		invisibility = INVISIBILITY_ABSTRACT

/obj/screen/parallax_layer/planet/update_o()
	return //Shit wont move

/obj/screen/parallax_pmaster
	appearance_flags = PLANE_MASTER
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = FALSE
	screen_loc = "CENTER-7,CENTER-7"

/obj/screen/parallax_space_whitifier
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


#undef LOOP_NONE
#undef LOOP_NORMAL
#undef LOOP_REVERSE
#undef LOOP_TIME