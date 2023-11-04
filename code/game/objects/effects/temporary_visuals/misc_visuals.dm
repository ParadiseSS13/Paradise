/obj/effect/temp_visual/dir_setting/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	duration = 5
	randomdir = FALSE
	layer = MOB_LAYER - 0.1
	color = "#C80000"
	var/splatter_type = "splatter"

/obj/effect/temp_visual/dir_setting/bloodsplatter/New(loc, set_dir, blood_color)
	if(blood_color)
		color = blood_color
	if(set_dir in GLOB.diagonals)
		icon_state = "[splatter_type][pick(1, 2, 6)]"
	else
		icon_state = "[splatter_type][pick(3, 4, 5)]"
	..()
	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(set_dir)
		if(NORTH)
			target_pixel_y = 16
		if(SOUTH)
			target_pixel_y = -16
			layer = MOB_LAYER + 0.1
		if(EAST)
			target_pixel_x = 16
		if(WEST)
			target_pixel_x = -16
		if(NORTHEAST)
			target_pixel_x = 16
			target_pixel_y = 16
		if(NORTHWEST)
			target_pixel_x = -16
			target_pixel_y = 16
		if(SOUTHEAST)
			target_pixel_x = 16
			target_pixel_y = -16
			layer = MOB_LAYER + 0.1
		if(SOUTHWEST)
			target_pixel_x = -16
			target_pixel_y = -16
			layer = MOB_LAYER + 0.1
	animate(src, pixel_x = target_pixel_x, pixel_y = target_pixel_y, alpha = 0, time = duration)

/obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter
	color = null
	splatter_type = "xsplatter"

/obj/effect/temp_visual/dir_setting/speedbike_trail
	name = "speedbike trails"
	icon_state = "ion_fade"
	duration = 10
	randomdir = FALSE
	layer = MOB_LAYER - 0.2

/obj/effect/temp_visual/dir_setting/ninja
	name = "ninja shadow"
	icon = 'icons/mob/mob.dmi'
	icon_state = "uncloak"
	duration = 9

/obj/effect/temp_visual/dir_setting/ninja/cloak
	icon_state = "cloak"

/obj/effect/temp_visual/dir_setting/ninja/shadow
	icon_state = "shadow"

/obj/effect/temp_visual/dir_setting/ninja/phase
	name = "ninja energy"
	icon_state = "phasein"

/obj/effect/temp_visual/dir_setting/ninja/phase/out
	icon_state = "phaseout"

/obj/effect/temp_visual/dir_setting/wraith
	name = "blood"
	icon = 'icons/mob/cult.dmi'
	icon_state = "phase_shift2"
	duration = 12

/obj/effect/temp_visual/dir_setting/wraith/Initialize(mapload)
	. = ..()
	icon_state = SSticker.cultdat?.wraith_jaunt_in_animation

/obj/effect/temp_visual/dir_setting/wraith/out
	icon_state = "phase_shift"

/obj/effect/temp_visual/dir_setting/wraith/out/Initialize(mapload)
	. = ..()
	icon_state = SSticker.cultdat?.wraith_jaunt_out_animation

/obj/effect/temp_visual/dir_setting/tailsweep
	icon_state = "tailsweep"
	duration = 4

/obj/effect/temp_visual/wizard
	name = "water"
	icon = 'icons/mob/mob.dmi'
	icon_state = "reappear"
	duration = 5

/obj/effect/temp_visual/wizard/out
	icon_state = "liquify"
	duration = 12

/obj/effect/temp_visual/monkeyify
	icon = 'icons/mob/mob.dmi'
	icon_state = "h2monkey"
	duration = 22

/obj/effect/temp_visual/monkeyify/humanify
	icon_state = "monkey2h"

/obj/effect/temp_visual/borgflash
	icon = 'icons/mob/mob.dmi'
	icon_state = "blspell"
	duration = 5

/obj/effect/temp_visual/guardian
	randomdir = FALSE

/obj/effect/temp_visual/guardian/phase
	duration = 5
	icon_state = "phasein"

/obj/effect/temp_visual/guardian/phase/out
	icon_state = "phaseout"

/obj/effect/temp_visual/decoy
	desc = "It's a decoy!"
	duration = 15

/obj/effect/temp_visual/decoy/New(loc, atom/mimiced_atom)
	..()
	alpha = initial(alpha)
	if(mimiced_atom)
		name = mimiced_atom.name
		appearance = mimiced_atom.appearance
		setDir(mimiced_atom.dir)
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/decoy/fading/New(loc, atom/mimiced_atom)
	..()
	animate(src, alpha = 0, time = duration)

/obj/effect/temp_visual/decoy/fading/threesecond
	duration = 40

/obj/effect/temp_visual/decoy/fading/fivesecond
	duration = 50

/obj/effect/temp_visual/decoy/fading/halfsecond
	duration = 5

/obj/effect/temp_visual/fire
	icon = 'icons/goonstation/effects/fire.dmi'
	icon_state = "3"
	light_range = LIGHT_RANGE_FIRE
	light_color = LIGHT_COLOR_FIRE
	duration = 10
	layer = MASSIVE_OBJ_LAYER
	alpha = 250
	blend_mode = BLEND_ADD

/obj/effect/temp_visual/fire/New(loc)
	color = heat2color(FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
	..()

/obj/effect/temp_visual/revenant
	name = "spooky lights"
	icon_state = "purplesparkles"

/obj/effect/temp_visual/revenant/cracks
	name = "glowing cracks"
	icon_state = "purplecrack"
	duration = 6

/obj/effect/temp_visual/gravpush
	name = "gravity wave"
	icon_state = "shieldsparkles"
	duration = 5

/obj/effect/temp_visual/telekinesis
	name = "telekinetic force"
	icon_state = "empdisable"
	duration = 5

/obj/effect/temp_visual/emp
	name = "emp sparks"
	icon_state = "empdisable"

/obj/effect/temp_visual/emp/pulse
	name = "emp pulse"
	icon_state = "emppulse"
	duration = 8
	randomdir = FALSE

/obj/effect/temp_visual/mummy_animation
	icon = 'icons/mob/mob.dmi'
	icon_state = "mummy_revive"
	duration = 20

/obj/effect/temp_visual/heal //color is white by default, set to whatever is needed
	name = "healing glow"
	icon_state = "heal"
	duration = 15

/obj/effect/temp_visual/heal/New(loc, colour)
	..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)
	if(colour)
		color = colour

/obj/effect/temp_visual/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = ABOVE_MOB_LAYER
	duration = 4

/obj/effect/temp_visual/explosion
	name = "explosion"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	pixel_x = -32
	pixel_y = -32
	duration = 8

/obj/effect/temp_visual/explosion/fast
	icon_state = "explosionfast"
	duration = 4

/obj/effect/temp_visual/heart
	name = "heart"
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	duration = 25

/obj/effect/temp_visual/heart/New(loc)
	..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)
	animate(src, pixel_y = pixel_y + 32, alpha = 0, time = 25)

/obj/effect/temp_visual/shockwave
	name = "shockwave"
	icon = 'icons/goonstation/effects/64x64.dmi'
	icon_state = "shockwave"
	randomdir = FALSE
	pixel_y = -16
	pixel_x = -16
	duration = 20

/obj/effect/temp_visual/implosion
	name = "implosion"
	icon = 'icons/goonstation/effects/64x64.dmi'
	icon_state = "implosion"
	randomdir = FALSE
	pixel_y = -16
	pixel_x = -16
	duration = 20

/obj/effect/temp_visual/bleed
	name = "bleed"
	icon = 'icons/effects/bleed.dmi'
	icon_state = "bleed0"
	duration = 10
	var/shrink = TRUE

/obj/effect/temp_visual/bleed/Initialize(mapload, atom/size_calc_target)
	. = ..()
	var/size_matrix = matrix()
	if(size_calc_target)
		layer = size_calc_target.layer + 0.01
		var/icon/I = icon(size_calc_target.icon, size_calc_target.icon_state, size_calc_target.dir)
		size_matrix = matrix() * (I.Height()/world.icon_size)
		transform = size_matrix //scale the bleed overlay's size based on the target's icon size
	var/matrix/M = transform
	if(shrink)
		M = size_matrix * 0.1
	else
		M = size_matrix * 2
	animate(src, alpha = 20, transform = M, time = duration, flags = ANIMATION_PARALLEL)

/obj/effect/temp_visual/bleed/explode
	icon_state = "bleed10"
	duration = 12
	shrink = FALSE

/obj/effect/temp_visual/small_smoke
	icon_state = "smoke"
	duration = 50

/obj/effect/temp_visual/small_smoke/halfsecond
	duration = 5

/obj/effect/temp_visual/dir_setting/firing_effect
	icon = 'icons/effects/effects.dmi'
	icon_state = "firing_effect"
	duration = 2

/obj/effect/temp_visual/dir_setting/firing_effect/setDir(newdir)
	switch(newdir)
		if(NORTH)
			layer = BELOW_MOB_LAYER
			pixel_x = rand(-3,3)
			pixel_y = rand(4,6)
		if(SOUTH)
			pixel_x = rand(-3,3)
			pixel_y = rand(-1,1)
		else
			pixel_x = rand(-1,1)
			pixel_y = rand(-1,1)
	..()

/obj/effect/temp_visual/dir_setting/firing_effect/energy
	icon_state = "firing_effect_energy"
	duration = 3

/obj/effect/temp_visual/dir_setting/firing_effect/magic
	icon_state = "shieldsparkles"
	duration = 3

/obj/effect/temp_visual/impact_effect
	icon_state = "impact_bullet"
	duration = 5

/obj/effect/temp_visual/impact_effect/Initialize(mapload, x, y)
	pixel_x = x
	pixel_y = y
	return ..()

/obj/effect/temp_visual/impact_effect/red_laser
	icon_state = "impact_laser"
	duration = 4

/obj/effect/temp_visual/impact_effect/blue_laser
	icon_state = "impact_laser_blue"
	duration = 4

/obj/effect/temp_visual/impact_effect/green_laser
	icon_state = "impact_laser_green"
	duration = 4

/obj/effect/temp_visual/impact_effect/purple_laser
	icon_state = "impact_laser_purple"
	duration = 4

/obj/effect/temp_visual/impact_effect/yellow_laser
	icon_state = "impact_laser_yellow"
	duration = 4

/obj/effect/temp_visual/impact_effect/ion
	icon_state = "shieldsparkles"
	duration = 6

/obj/effect/temp_visual/bsg_kaboom
	name = "bluespace explosion"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosionfast"
	color = "blue"
	pixel_x = -32
	pixel_y = -32
	duration = 42

/obj/effect/temp_visual/bsg_kaboom/Initialize(mapload)
	. = ..()
	new /obj/effect/warp_effect/bsg(loc)

/obj/effect/warp_effect/bsg

/obj/effect/warp_effect/bsg/Initialize(mapload)
	. = ..()
	var/matrix/M = matrix() * 0.5
	transform = M
	animate(src, transform = M * 8, time = 0.8 SECONDS, alpha = 0)
	QDEL_IN(src, 0.8 SECONDS)

/obj/effect/temp_visual/rcd_effect
	icon = 'icons/effects/effects_rcd.dmi'
	icon_state = "rcd"
	duration = 5 SECONDS
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/rcd_effect/short
	icon_state = "rcd_short"
	duration = 2 SECONDS

/obj/effect/temp_visual/rcd_effect/end
	icon_state = "rcd_end"
	duration = 1.1 SECONDS

/obj/effect/temp_visual/rcd_effect/reverse
	icon_state = "rcd_reverse"
	duration = 6.1 SECONDS

/obj/effect/temp_visual/rcd_effect/reverse_short
	icon_state = "rcd_short_reverse"
	duration = 3.1 SECONDS

/**
 * A visual effect that will be shown only to a particular user for a period of time.
 */
/obj/effect/temp_visual/single_user
	/// The image to show to the user
	var/image/displayed_image
	/// The UID of the person who the image is being displayed to
	var/source_UID
	/// The real icon state to be applied to the image
	var/image_icon_state
	/// The plane to apply the image to
	var/image_plane = ABOVE_LIGHTING_PLANE
	/// The layer to apply the image to
	var/image_layer = ABOVE_ALL_MOB_LAYER
	/// The icon to pull the image from
	var/image_icon


/obj/effect/temp_visual/single_user/Initialize(mapload, mob/living/user)
	. = ..()
	if(!user)
		return INITIALIZE_HINT_QDEL
	displayed_image = create_image(user)
	displayed_image.plane = image_plane
	displayed_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	source_UID = user.UID()
	add_mind(user)


/obj/effect/temp_visual/single_user/proc/create_image(mob/living/looker)
	return image(icon = image_icon, loc = src, icon_state = image_icon_state, layer = image_layer)


/obj/effect/temp_visual/single_user/Destroy()
	var/mob/living/previous_user = locateUID(source_UID)
	if(previous_user)
		remove_mind(previous_user)
	// Null so we don't shit the bed when we delete
	displayed_image = null
	return ..()

/// Add the image to the user's screen
/obj/effect/temp_visual/single_user/proc/add_mind(mob/living/looker)
	looker.client?.images |= displayed_image

/// Remove the image from the user's screen
/obj/effect/temp_visual/single_user/proc/remove_mind(mob/living/looker)
	looker.client?.images -= displayed_image

/obj/effect/temp_visual/single_user/lwap_ping
	duration = 0.5 SECONDS
	randomdir = FALSE
	image_icon = 'icons/obj/projectiles.dmi'
	image_icon_state = "red_laser"

/obj/effect/temp_visual/single_user/lwap_ping/Initialize(mapload, mob/living/looker, mob/living/creature)
	if(!looker || !creature)
		return INITIALIZE_HINT_QDEL
	. = ..()
	displayed_image.pixel_x = (creature.x - looker.x) * 32
	displayed_image.pixel_y = (creature.y - looker.y) * 32

/obj/effect/temp_visual/single_user/ai_telegraph
	duration = 2 SECONDS
	randomdir = FALSE
	image_layer = BELOW_MOB_LAYER
	image_plane = GAME_PLANE
	image_icon = 'icons/mob/telegraphing/telegraph_holographic.dmi'
	image_icon_state = "target_box"


/obj/effect/temp_visual/obliteration
	duration = 2 SECONDS

/obj/effect/temp_visual/obliteration/Initialize(mapload, atom/target)
	. = ..()
	if(isobj(target))
		loc = target.loc
	icon = target.icon
	icon_state = target.icon_state
	alpha = target.alpha
	dir = target.dir
	update_icon()
	var/obj/effect/dusting_anim/dust_effect = new(loc, UID())
	filters += filter(type = "displace", size = 256, render_source = "*snap[UID()]")
	animate(src, alpha = 0, time = 2 SECONDS, easing = (EASE_IN | SINE_EASING))
	QDEL_IN(dust_effect, 20)
	return TRUE

/obj/effect/temp_visual/obliteration_rays
	duration = 1.25 SECONDS

/obj/effect/temp_visual/obliteration_rays/Initialize(mapload)
	. = ..()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 40, "#ffd04f", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)
