/obj/effect/waterfall
	name = "waterfall effect"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	opacity = 0
	mouse_opacity = 0
	density = 0
	anchored = 1
	invisibility = 101

	var/water_frequency = 15
	var/water_timer = 0

/obj/effect/waterfall/New()
	water_timer = addtimer(src, "drip", water_frequency)

/obj/effect/waterfall/Destroy()
	if(water_timer)
		deltimer(water_timer)
	water_timer = null

/obj/effect/waterfall/proc/drip()
	var/obj/effect/effect/water/W = new(loc)
	W.dir = dir
	spawn(1)
		W.loc = get_step(W, dir)
	water_timer = addtimer(src, "drip", water_frequency)