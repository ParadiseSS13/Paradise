/obj/item/device/sensor_device
	name = "handheld crew monitor"
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = 2
	slot_flags = SLOT_BELT
	origin_tech = "biotech=3;materials=3;magnets=3"
	var/datum/nano_module/crew_monitor/crew_monitor

/obj/item/device/sensor_device/New()
	crew_monitor = new(src)

/obj/item/device/sensor_device/Destroy()
	qdel(crew_monitor)
	crew_monitor = null
	return ..()

/obj/item/device/sensor_device/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/device/sensor_device/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	crew_monitor.ui_interact(user, ui_key, ui, force_open)