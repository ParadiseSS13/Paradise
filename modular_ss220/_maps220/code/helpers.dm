/obj/effect/mapping_helpers
	icon = 'modular_ss220/_maps220/icons/mapping_helpers.dmi'

/obj/effect/mapping_helpers/light
	icon_state = "sunlight_helper"
	light_color = null
	light_power = 1
	light_range = 10

/obj/effect/mapping_helpers/light/New()
	var/turf/T = get_turf(src)
	T.light_color = light_color
	T.light_power = light_power
	T.light_range = light_range
	. = ..()
