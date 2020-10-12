/obj/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	var/show_alpha = 255
	var/hide_alpha = 0
	var/current_filters = list()

/obj/screen/plane_master/proc/Show(override)
	alpha = override || show_alpha

/obj/screen/plane_master/proc/Hide(override)
	alpha = override || hide_alpha

/obj/screen/plane_master/proc/add_filter(key, filter)
	if(current_filters[key])
		filters -= current_filters[key]

	filters += filter
	current_filters[key] = filters[filters.len] //assigning `filter` will not allow it to work later while animating removal

/obj/screen/plane_master/proc/remove_filter(key)
	if(current_filters[key])
		animate(current_filters[key], size=0, time=5) //not all filters have a size param, but this is good enough for the general case
		addtimer(CALLBACK(src, .proc/remove_callback, key), 5)

/obj/screen/plane_master/proc/remove_callback(key)
	filters -= current_filters[key]
	current_filters -= key

//Why do plane masters need a backdrop sometimes? Read http://www.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/obj/screen/plane_master/proc/backdrop(mob/mymob)

/obj/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/game_world/backdrop(mob/mymob)
	if(istype(mymob) && mymob.client && mymob.client.prefs && (mymob.client.prefs.toggles & PREFTOGGLE_AMBIENT_OCCLUSION))
		add_filter(AMBIENT_OCCLUSION_FILTER_KEY, FILTER_AMBIENT_OCCLUSION)

/obj/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/plane_master/lighting/backdrop(mob/mymob)
	mymob.overlay_fullscreen("lighting_backdrop_lit", /obj/screen/fullscreen/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /obj/screen/fullscreen/lighting_backdrop/unlit)
