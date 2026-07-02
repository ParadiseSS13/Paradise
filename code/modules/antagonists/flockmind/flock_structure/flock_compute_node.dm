/obj/structure/flock/compute
	name = "strange computer"
	desc = "It almost looks like a terminal of some kind."

	flock_desc = "A computing node that provides bandwidth to the Flock."
	flock_id = "Compute Node"

	max_integrity = 60
	icon_state = "compute"
	bandwidth_provided = 30

/obj/structure/flock/compute/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	light_range = 1
	light_color = "#7BFFFFa2"
	light_power = 0.3

	update_appearance()

/obj/structure/flock/compute/update_overlays()
	. = ..()
	overlays.Cut()
	var/image/screen = image(icon, "compute_screen")
	screen.pixel_y = 16
	. += screen
	var/image/display = image(icon, "compute_display[rand(1, 9)]")
	display.pixel_y = 19
	. += display

/obj/structure/flock/compute/flock_structure_examine(mob/user)
	return list(
		SPAN_FLOCKSAY("<b>Bandwidth Provided:</b> [bandwidth_provided].")
	)

/obj/structure/flock/compute/update_info_tag()
	info_tag?.set_text("Bandwidth: [bandwidth_provided]")

