/obj/machinery/power/alien_cache
	icon = 'icons/obj/machines/alien_cache.dmi'
	icon_state = "cache_0"
	base_icon_state = "cache_0"
	pixel_x = -32
	pixel_y = -32
	var/list/random_rewards = list()
	var/list/open_rewards = list()
	var/obj/machinery/power/terminal/terminal

/obj/machinery/power/alien_cache/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/multitile, list(
		list(1, MACH_CENTER, 1),
		list(1, 0,		   1),
	))
