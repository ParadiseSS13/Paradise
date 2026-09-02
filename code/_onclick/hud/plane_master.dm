/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	var/show_alpha = 255
	var/hide_alpha = 0

/atom/movable/screen/plane_master/proc/Show(override)
	alpha = override || show_alpha

/atom/movable/screen/plane_master/proc/Hide(override)
	alpha = override || hide_alpha

//Why do plane masters need a backdrop sometimes? Read http://www.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/atom/movable/screen/plane_master/proc/backdrop(mob/mymob)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, add_filter), "displace", 1, displacement_map_filter(render_source = GRAVITY_PULSE_RENDER_TARGET, size = 10)), 2 SECONDS)//Why a timer vs just apply on initialize / async? I don't know. It just can't be, neither works correctly. Don't lower below 2 seconds unless you can see effects through walls with no issue.

/atom/movable/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER

/atom/movable/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	appearance_flags = PLANE_MASTER

/atom/movable/screen/plane_master/game_world/backdrop(mob/mymob)
	. = ..() //if you delete it so help me god
	clear_filters()
	if(istype(mymob) && mymob.client && mymob.client.prefs && (mymob.client.prefs.toggles & PREFTOGGLE_AMBIENT_OCCLUSION))
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/lighting/backdrop(mob/mymob)
	. = ..()
	mymob.overlay_fullscreen("lighting_backdrop_lit", /atom/movable/screen/fullscreen/stretch/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /atom/movable/screen/fullscreen/stretch/lighting_backdrop/unlit)

/atom/movable/screen/plane_master/lighting/Initialize(mapload)
	. = ..()
	add_filter("emissives", 1, alpha_mask_filter(render_source = EMISSIVE_RENDER_TARGET, flags = MASK_INVERSE))

/atom/movable/screen/plane_master/point
	name = "point plane master"
	plane = POINT_PLANE
	appearance_flags = PLANE_MASTER //should use client color

/atom/movable/screen/plane_master/point/backdrop(mob/mymob)
	if(istype(mymob) && mymob.client && mymob.client.prefs)
		alpha = (mymob.client.prefs.toggles2 & PREFTOGGLE_2_THOUGHT_BUBBLE) ? 255 : 0

/atom/movable/screen/plane_master/cogbar
	name = "cogbar plane master"
	plane = COGBAR_PLANE
	appearance_flags = PLANE_MASTER //should use client color

/atom/movable/screen/plane_master/cogbar/backdrop(mob/mymob)
	if(istype(mymob) && mymob.client?.prefs)
		alpha = (mymob.client.prefs.toggles3 & PREFTOGGLE_3_COGBAR_ANIMATIONS) ? 255 : 0

/**
  * Things placed on this mask the lighting plane. Doesn't render directly.
  *
  * Gets masked by blocking plane. Use for things that you want blocked by
  * mobs, items, etc.
  */
/atom/movable/screen/plane_master/emissive
	name = "emissive plane master"
	plane = EMISSIVE_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_RENDER_TARGET

/atom/movable/screen/plane_master/emissive/Initialize(mapload)
	. = ..()
	add_filter("em_block_masking", 1, color_matrix_filter(GLOB.em_mask_matrix))

/atom/movable/screen/plane_master/space
	name = "space plane master"
	plane = PLANE_SPACE
	appearance_flags = PLANE_MASTER

/atom/movable/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY

/atom/movable/screen/plane_master/blackness
	name = "blackness plane master"
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	color = list(null, null, null, "#0000", "#000f")
	blend_mode = BLEND_ADD
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR | PIXEL_SCALE

/atom/movable/screen/plane_master/gravpulse
	name = "gravpulse plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GRAVITY_PULSE_PLANE
	blend_mode = BLEND_ADD
	render_target = GRAVITY_PULSE_RENDER_TARGET

/atom/movable/screen/plane_master/smoke
	name = "point plane master"
	plane = SMOKE_PLANE
	appearance_flags = PLANE_MASTER

/atom/movable/screen/plane_master/lamps
	name = "lamps plane master"
	plane = LIGHTING_LAMPS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = LIGHTING_LAMPS_RENDER_TARGET

/atom/movable/screen/plane_master/lamps/floor
	name = "floor lamps plane master"
	plane = FLOOR_LIGHTING_LAMPS_PLANE
	render_target = FLOOR_LIGHTING_LAMPS_RENDER_TARGET

/atom/movable/screen/plane_master/exposure
	name = "exposure plane master"
	plane = LIGHTING_EXPOSURE_PLANE
	appearance_flags = parent_type::appearance_flags | PIXEL_SCALE //should use client color
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/exposure/backdrop(mob/mymob)
	remove_filter("blur_exposure")
	alpha = 0
	if(!istype(mymob) || !(mymob?.client?.prefs?.light & LIGHT_NEW_LIGHTING))
		return
	var/enabled = mymob?.client?.prefs?.light & LIGHT_EXPOSURE

	if(enabled)
		alpha = 255
		add_filter("blur_exposure", 1, gauss_blur_filter(size = 20)) // by refs such blur is heavy, but tests were okay and this allow us more flexibility with setup. Possible point for improvements

/atom/movable/screen/plane_master/lamps_selfglow
	name = "lamps selfglow plane master"
	plane = LIGHTING_LAMPS_SELFGLOW
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/target_rendering = LIGHTING_LAMPS_RENDER_TARGET

/atom/movable/screen/plane_master/lamps_selfglow/floor
	name = "floor lamps selfglow plane master"
	plane = FLOOR_LIGHTING_LAMPS_SELFGLOW
	target_rendering = FLOOR_LIGHTING_LAMPS_RENDER_TARGET

/atom/movable/screen/plane_master/lamps_selfglow/backdrop(mob/mymob)
	remove_filter("add_lamps_to_selfglow")
	remove_filter("lamps_selfglow_bloom")

	if(!istype(mymob) || !(mymob?.client?.prefs?.light & LIGHT_NEW_LIGHTING))
		return
	var/level = mymob?.client?.prefs?.glowlevel

	if(isnull(level))
		return
	var/bloomsize = 0
	var/bloomoffset = 0
	switch(level)
		if(GLOW_LOW)
			bloomsize = 2
			bloomoffset = 1
		if(GLOW_MED)
			bloomsize = 3
			bloomoffset = 2
		if(GLOW_HIGH)
			bloomsize = 5
			bloomoffset = 3
		else
			return

	add_filter("add_lamps_to_selfglow", 1, layering_filter(render_source = target_rendering, blend_mode = BLEND_OVERLAY))
	add_filter("lamps_selfglow_bloom", 1, bloom_filter(threshold = "#777777", size = bloomsize, offset = bloomoffset, alpha = 80))

/atom/movable/screen/plane_master/lamps_glare
	name = "lamps glare plane master"
	plane = LIGHTING_LAMPS_GLARE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/target_rendering = LIGHTING_LAMPS_RENDER_TARGET

/atom/movable/screen/plane_master/lamps_glare/floor
	name = "floor lamps glare plane master"
	plane = FLOOR_LIGHTING_LAMPS_GLARE
	target_rendering = FLOOR_LIGHTING_LAMPS_RENDER_TARGET

/atom/movable/screen/plane_master/lamps_glare/backdrop(mob/mymob)
	remove_filter("add_lamps_to_glare")
	remove_filter("lamps_glare")

	if(!istype(mymob) || !(mymob?.client?.prefs?.light & LIGHT_NEW_LIGHTING))
		return

	var/enabled = mymob?.client?.prefs?.light & LIGHT_GLARE

	if(enabled)
		add_filter("add_lamps_to_glare", 1, layering_filter(render_source = target_rendering, blend_mode = BLEND_ADD))
		add_filter("lamps_glare", 1, radial_blur_filter(size = 0.035))
