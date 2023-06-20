
/obj/machinery/power/breaker_box
	name = "Breaker Box"
	desc = "a wall box panel which contains many small switch and one large switch which turn APCs on and off on the local network"
	icon = 'icons/obj/power.dmi'
	icon_state = "breakerbox"
	anchored = TRUE
	power_state = NO_POWER_USE
	power_voltage_type = null // breaker box's don't connect to powernets so they don't have a voltage type, but their terminals do!
	/// The power terminal connected to this breakerbox
	var/obj/machinery/power/terminal/terminal = null

/obj/machinery/power/breaker_box/Initialize(mapload)
	. = ..()
	setDir(NORTH) // This is only used for pixel offsets, and later terminal placement. APC dir doesn't affect its sprite since it only has one orientation.
	set_pixel_offsets_from_dir(24, -24, 24, -24)
	update_icon()
	make_terminal()

/obj/machinery/power/breaker_box/proc/make_terminal()
	terminal = new/obj/machinery/power/terminal(get_turf(src))
	terminal.setDir(dir)
	terminal.master = src

