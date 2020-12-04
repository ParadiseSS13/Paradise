/obj/item/sensor_device
	name = "handheld crew monitor"
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "programming=3;materials=3;magnets=3"
	var/datum/ui_module/crew_monitor/crew_monitor

/obj/item/sensor_device/New()
	..()
	crew_monitor = new(src)

/obj/item/sensor_device/Destroy()
	QDEL_NULL(crew_monitor)
	return ..()

/obj/item/sensor_device/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/sensor_device/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	crew_monitor.ui_interact(user, ui_key, ui, force_open)
