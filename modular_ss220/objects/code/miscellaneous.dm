/**
* Use that for creating non-varedited objects,
* or that you don't want to specify because they're insignificant for personal DM file
*/
// Spotlights, used for floors on station
/obj/structure/marker_beacon/spotlight
	name = "напольный прожектор"
	desc = "Осветительное устройство. Из него исходит яркий луч света."
	icon_state = "markerrandom"
	var/spotlight_color

/obj/structure/marker_beacon/spotlight/yellow
	icon_state = "markeryellow-on"
	spotlight_color = "Yellow"

/obj/structure/marker_beacon/spotlight/jade
	icon_state = "markerjade-on"
	spotlight_color = "Jade"

/obj/structure/marker_beacon/spotlight/Initialize(mapload)
	. = ..()
	picked_color = spotlight_color
	update_icon(UPDATE_ICON_STATE)

/obj/structure/marker_beacon/spotlight/yellow/update_icon_state()
	set_light(light_range, light_power, LIGHT_COLOR_YELLOW)

/obj/structure/marker_beacon/spotlight/jade/update_icon_state()
	set_light(light_range, light_power, LIGHT_COLOR_BLUEGREEN)
