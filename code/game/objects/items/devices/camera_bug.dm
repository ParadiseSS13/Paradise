// This item just has an integrated camera console, which the data is "proxied" to
/obj/item/camera_bug
	name = "camera bug"
	desc = "For illicit snooping through the camera network."
	icon = 'icons/obj/device.dmi'
	icon_state	= "camera_bug"
	w_class		= WEIGHT_CLASS_TINY
	item_state	= "camera_bug"
	throw_speed	= 4
	throw_range	= 20
	origin_tech = "syndicate=1;engineering=3"
	/// Integrated camera console to serve UI data
	var/obj/machinery/computer/security/integrated_console

/obj/item/camera_bug/Initialize(mapload)
	. = ..()
	integrated_console = new
	integrated_console.parent = src
	integrated_console.network = list("SS13")

/obj/item/camera_bug/Destroy()
	QDEL_NULL(integrated_console)
	return ..()

/obj/item/camera_bug/attack_self(mob/user as mob)
	tgui_interact(user)

/obj/item/camera_bug/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_inventory_state)
	integrated_console.tgui_interact(user, ui_key, ui, force_open, master_ui, state)
