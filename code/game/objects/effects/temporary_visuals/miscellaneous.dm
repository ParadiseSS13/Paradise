/obj/effect/temp_visual/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "arrow"
	layer = POINT_LAYER
	duration = 20
	randomdir = FALSE

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
	if(set_dir in diagonals)
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
	icon = 'icons/mob/mob.dmi'
	icon_state = "phase_shift2"
	duration = 12

/obj/effect/temp_visual/dir_setting/wraith/out
	icon_state = "phase_shift"

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
