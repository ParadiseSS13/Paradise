/mob/proc/overlay_fullscreen(category, type, severity, animated = 0)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	var/is_centered = istype(screen, /atom/movable/screen/fullscreen/center)

	if(!screen || screen.type != type)
		// needs to be recreated
		clear_fullscreen(category, FALSE)
		screens[category] = screen = new type()
	else if((!severity || severity == screen.severity) && (!is_centered && (!client || screen.screen_loc != "CENTER-7,CENTER-7" || screen.view == client.view)))
		// doesn't need to be updated
		return screen

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity
	if(client && screen.should_show_to(src))
		if(animated)
			INVOKE_ASYNC(src, PROC_REF(apply_screen_animation), animated, screen)
		if(!is_centered)
			screen.update_for_view(client.view)
		client.screen += screen

	return screen

/mob/proc/apply_screen_animation(animated = 0, atom/movable/screen/fullscreen/screen)
	screen.alpha = 0
	animate(screen, alpha = 255, time = animated)

/mob/proc/clear_fullscreen(category, animated = 10)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if(!screen)
		return

	screens -= category

	if(animated)
		spawn(0)
			animate(screen, alpha = 0, time = animated)
			sleep(animated)
			if(client)
				client.screen -= screen
			qdel(screen)
		return

	if(client)
		client.screen -= screen
	qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/mob/proc/reload_fullscreen()
	if(!client)
		return
	var/atom/movable/screen/fullscreen/screen
	for(var/category in screens)
		screen = screens[category]
		if(screen.should_show_to(src))
			screen.update_for_view(client.view)
			client.screen |= screen
		else
			client.screen -= screen

/atom/movable/screen/fullscreen
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	var/view
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/severity = 0
	var/show_when_dead = FALSE

/atom/movable/screen/fullscreen/proc/should_show_to(mob/mymob)
	if(!show_when_dead && mymob.stat == DEAD)
		return FALSE
	return TRUE

/atom/movable/screen/fullscreen/Destroy()
	severity = 0
	return ..()

/// Stretch version is suitable for images that stick to screen edges, as they scale with user screen size
/// For centrally located screen objects, use /atom/movable/screen/fullscreen/center
/atom/movable/screen/fullscreen/stretch
	view = 7

/atom/movable/screen/fullscreen/proc/update_for_view(client_view)
	if(screen_loc == "CENTER-7,CENTER-7" && view != client_view)
		var/list/actualview = getviewsize(client_view)
		view = client_view
		transform = matrix(actualview[1]/FULLSCREEN_OVERLAY_RESOLUTION_X, 0, 0, 0, actualview[2]/FULLSCREEN_OVERLAY_RESOLUTION_Y, 0)

/atom/movable/screen/fullscreen/stretch/brute
	icon_state = "brutedamageoverlay"
	layer = UI_DAMAGE_LAYER

/atom/movable/screen/fullscreen/stretch/oxy
	icon_state = "oxydamageoverlay"
	layer = UI_DAMAGE_LAYER

/atom/movable/screen/fullscreen/stretch/crit
	icon_state = "passage"
	layer = CRIT_LAYER

/atom/movable/screen/fullscreen/stretch/blind
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER

/atom/movable/screen/fullscreen/stretch/impaired
	icon_state = "impairedoverlay"

/atom/movable/screen/fullscreen/stretch/payback
	icon = 'icons/mob/screen_payback.dmi'
	icon_state = "payback"
	show_when_dead = TRUE

/atom/movable/screen/fullscreen/stretch/fog
	icon = 'icons/mob/screen_fog.dmi'
	icon_state = "fog"
	color = "#FF0000"

/atom/movable/screen/fullscreen/stretch/flash
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"

/atom/movable/screen/fullscreen/stretch/flash/noise
	icon_state = "noise"

/atom/movable/screen/fullscreen/stretch/high
	icon = 'icons/mob/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"

/atom/movable/screen/fullscreen/stretch/lighting_backdrop
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "flash"
	transform = matrix(200, 0, 0, 0, 200, 0)
	plane = LIGHTING_PLANE
	blend_mode = BLEND_OVERLAY
	show_when_dead = TRUE

//Provides darkness to the back of the lighting plane
/atom/movable/screen/fullscreen/stretch/lighting_backdrop/lit
	invisibility = INVISIBILITY_LIGHTING
	layer = BACKGROUND_LAYER+21
	color = "#000"

//Provides whiteness in case you don't see lights so everything is still visible
/atom/movable/screen/fullscreen/stretch/lighting_backdrop/unlit
	layer = BACKGROUND_LAYER+20

/atom/movable/screen/fullscreen/stretch/see_through_darkness
	icon_state = "nightvision"
	plane = LIGHTING_PLANE
	layer = LIGHTING_LAYER
	blend_mode = BLEND_ADD
	show_when_dead = TRUE

/// An effect which tracks the cursor's location on the screen
/atom/movable/screen/fullscreen/stretch/cursor_catcher
	icon_state = "fullscreen_blocker" // Fullscreen semi transparent icon
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON
	/// The mob whose cursor we are tracking.
	var/mob/owner
	/// Client view size of the scoping mob.
	var/list/view_list
	/// Pixel x we send to the scope component.
	var/given_x
	/// Pixel y we send to the scope component.
	var/given_y
	/// The turf we send to the scope component.
	var/turf/given_turf
	/// Mouse parameters, for calculation.
	var/mouse_params

/// Links this up with a mob
/atom/movable/screen/fullscreen/stretch/cursor_catcher/proc/assign_to_mob(mob/owner)
	src.owner = owner
	view_list = getviewsize(owner.client.view)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	calculate_params()

/// Update when the mob we're assigned to has moved
/atom/movable/screen/fullscreen/stretch/cursor_catcher/proc/on_move(atom/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!given_turf)
		return
	var/x_offset = source.loc.x - oldloc.x
	var/y_offset = source.loc.y - oldloc.y
	given_turf = locate(given_turf.x + x_offset, given_turf.y + y_offset, given_turf.z)

/atom/movable/screen/fullscreen/stretch/cursor_catcher/MouseEntered(location, control, params)
	. = ..()
	MouseMove(location, control, params)
	if(usr == owner)
		calculate_params()

/atom/movable/screen/fullscreen/stretch/cursor_catcher/MouseMove(location, control, params)
	if(usr != owner)
		return
	mouse_params = params

/atom/movable/screen/fullscreen/stretch/cursor_catcher/proc/calculate_params()
	var/list/modifiers = params2list(mouse_params)
	var/icon_x = text2num(LAZYACCESS(modifiers, "vis-x"))
	if(isnull(icon_x))
		icon_x = text2num(LAZYACCESS(modifiers, "icon-x"))
	var/icon_y = text2num(LAZYACCESS(modifiers, "vis-y"))
	if(isnull(icon_y))
		icon_y = text2num(LAZYACCESS(modifiers, "icon-y"))
	var/our_x = round(icon_x / world.icon_size)
	var/our_y = round(icon_y / world.icon_size)
	given_turf = locate(owner.x + our_x - round(view_list[1] / 2), owner.y + our_y - round(view_list[2] / 2), owner.z)
	given_x = round(icon_x - world.icon_size * our_x, 1)
	given_y = round(icon_y - world.icon_size * our_y, 1)

/// Centered fullscreen atoms
/// These are used to center a widescreen image so it scales properly across screen sizes, not suitable for screen images that eminate from the edge of the screen
/atom/movable/screen/fullscreen/center
	appearance_flags = TILE_BOUND

/atom/movable/screen/fullscreen/center/Initialize(mapload)
	. = ..()
	var/icon/I = new(icon)
	var/x_offset = -((I.Width() - world.icon_size) / 2)
	var/y_offset = -((I.Height() - world.icon_size) / 2)
	qdel(I)
	screen_loc = "CENTER:[x_offset],CENTER:[y_offset]"

/atom/movable/screen/fullscreen/center/blind/sleeping
	icon = 'icons/mob/screen_sleeping.dmi'
	icon_state = "sleepblind"
	layer = BLIND_LAYER

/atom/movable/screen/fullscreen/center/blind/disky
	icon = 'icons/mob/screen_tight.dmi'
	icon_state = "disky"
	layer = BLIND_LAYER

/atom/movable/screen/fullscreen/center/agent_box
	icon = 'icons/obj/cardboard_boxes.dmi'
	icon_state = "agentbox"
	alpha = 128

#undef FULLSCREEN_LAYER
#undef BLIND_LAYER
#undef CRIT_LAYER
