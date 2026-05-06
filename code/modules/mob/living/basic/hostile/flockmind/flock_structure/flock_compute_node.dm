/obj/structure/flock/compute
	name = "weird lookin' thinking thing"
	desc = "It almost looks like a terminal of some kind."

	flock_desc = "A computing node that provides bandwidth to the Flock."
	flock_id = "Compute Node"

	max_integrity = 60
	icon_state = "compute"
	bandwidth_provided = 30

	light_system = OVERLAY_LIGHT

/obj/structure/flock/compute/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	set_light_range(1)
	set_light_color("#7BFFFFa2")
	set_light_power(0.3)

	update_appearance()

/obj/structure/flock/compute/update_overlays()
	. = ..()
	var/image/I = image(icon, "compute_screen[rand(1, 9)]")
	I.pixel_y = 16
	. += I

/obj/structure/flock/compute/flock_structure_examine(mob/user)
	return list(
		span_flocksay("<b>Bandwidth Provided:</b> [bandwidth_provided].")
	)

/obj/structure/flock/compute/update_info_tag()
	info_tag?.set_text("Bandwidth: [bandwidth_provided]")

