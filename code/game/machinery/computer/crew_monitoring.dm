/obj/machinery/computer/crew
	name = "crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_keyboard = "med_key"
	icon_screen = "crew"
	idle_power_consumption = 250
	active_power_consumption = 500
	light_color = LIGHT_COLOR_DARKBLUE
	circuit = /obj/item/circuitboard/crew
	var/datum/ui_module/crew_monitor/crew_monitor

/obj/machinery/computer/crew/Initialize()
	. = ..()
	crew_monitor = new(src)

/obj/machinery/computer/crew/Destroy()
	QDEL_NULL(crew_monitor)
	return ..()

/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/crew/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	crew_monitor.ui_interact(user, ui_key, ui, force_open)

/obj/machinery/computer/crew/interact(mob/user)
	crew_monitor.ui_interact(user)

/obj/machinery/computer/crew/advanced
	name = "advanced crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms across multiple sectors."

/obj/machinery/computer/crew/advanced/Initialize()
	. = ..()
	crew_monitor.is_advanced = TRUE
