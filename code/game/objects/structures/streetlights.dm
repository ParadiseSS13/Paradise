GLOBAL_LIST_EMPTY(avernus_shieldgens)

/obj/structure/streetlight
	icon = 'icons/obj/structures/street.dmi'
	icon_state = "streetlamp-empty"
	var/list/two_closest = list()

/obj/structure/streetlight/Initialize(mapload)
	. = ..()
	var/obj/effect/streetlight_active_bulb/active_bulb = new(src)
	active_bulb.pixel_y = 50
	vis_contents += active_bulb
	GLOB.avernus_shieldgens |= src

/obj/structure/streetlight/Destroy()
	GLOB.avernus_shieldgens -= src
	. = ..()

/obj/effect/streetlight_active_bulb
	name = ""
	icon = 'icons/obj/structures/streetbulb.dmi'
	icon_state = "bulb_on"
	light_power = 1
	light_color = "#6a8edd"
	light_range = 6

/obj/effect/ebeam/avernus_shieldwall
