/obj/item/sensor_device
	name = "handheld crew monitor"
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "programming=3;materials=3;magnets=3"
	var/datum/ui_module/crew_monitor/crew_monitor

/obj/item/sensor_device/Initialize(mapload)
	.=..()
	crew_monitor = new(src)

/obj/item/sensor_device/Destroy()
	QDEL_NULL(crew_monitor)
	return ..()

/obj/item/sensor_device/attack_self(mob/user as mob)
	ui_interact(user)


/obj/item/sensor_device/MouseDrop(atom/over)
	. = ..()
	if(!.)
		return FALSE

	var/mob/user = usr
	if(istype(over, /obj/screen))
		return FALSE

	if(user.incapacitated() || !ishuman(user))
		return FALSE

	if(over == user)
		attack_self(user)
		return TRUE

	return FALSE


/obj/item/sensor_device/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	crew_monitor.ui_interact(user, ui_key, ui, force_open)

/obj/item/sensor_device/command
	name = "command crew monitor"
	desc = "A miniature machine that tracks suit sensors across the station."
	icon_state = "c_scanner"

/obj/item/sensor_device/command/Initialize(mapload)
	. = ..()
	crew_monitor.with_command = TRUE
