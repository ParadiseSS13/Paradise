/obj/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	var/show_alpha = 255
	var/hide_alpha = 0

/obj/screen/plane_master/proc/Show(override)
	alpha = override || show_alpha

/obj/screen/plane_master/proc/Hide(override)
	alpha = override || hide_alpha

//Why do plane masters need a backdrop sometimes? Read http://www.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/obj/screen/plane_master/proc/backdrop(mob/mymob)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, add_filter), "displace", 1, displacement_map_filter(render_source = GRAVITY_PULSE_RENDER_TARGET, size = 10)), 2 SECONDS)//Why a timer vs just apply on initialize / async? I don't know. It just can't be, neither works correctly. Don't lower below 2 seconds unless you can see effects through walls with no issue.

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
	. = ..() //if you delete it so help me god
	clear_filters()
	if(istype(mymob) && mymob.client && mymob.client.prefs && (mymob.client.prefs.toggles & PREFTOGGLE_AMBIENT_OCCLUSION))
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/obj/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/plane_master/lighting/backdrop(mob/mymob)
	. = ..()
	mymob.overlay_fullscreen("lighting_backdrop_lit", /obj/screen/fullscreen/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /obj/screen/fullscreen/lighting_backdrop/unlit)

/obj/screen/plane_master/lighting/Initialize()
	. = ..()
	add_filter("emissives", 1, alpha_mask_filter(render_source = EMISSIVE_RENDER_TARGET, flags = MASK_INVERSE))

/obj/screen/plane_master/point
	name = "point plane master"
	plane = POINT_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/point/backdrop(mob/mymob)
	if(istype(mymob) && mymob.client && mymob.client.prefs)
		alpha = (mymob.client.prefs.toggles2 & PREFTOGGLE_2_THOUGHT_BUBBLE) ? 255 : 0

/**
  * Things placed on this mask the lighting plane. Doesn't render directly.
  *
  * Gets masked by blocking plane. Use for things that you want blocked by
  * mobs, items, etc.
  */
/obj/screen/plane_master/emissive
	name = "emissive plane master"
	plane = EMISSIVE_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_RENDER_TARGET

/obj/screen/plane_master/emissive/Initialize()
	. = ..()
	add_filter("em_block_masking", 1, color_matrix_filter(GLOB.em_mask_matrix))

/obj/screen/plane_master/space
	name = "space plane master"
	plane = PLANE_SPACE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY

/obj/screen/plane_master/blackness
	name = "blackness plane master"
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	color = list(null, null, null, "#0000", "#000f")
	blend_mode = BLEND_ADD
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR | PIXEL_SCALE

/obj/screen/plane_master/gravpulse
	name = "gravpulse plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GRAVITY_PULSE_PLANE
	blend_mode = BLEND_ADD
	render_target = GRAVITY_PULSE_RENDER_TARGET
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
