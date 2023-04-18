/obj/machinery/computer/atmoscontrol
	name = "\improper central atmospherics computer"
	icon = 'icons/obj/machines/computer.dmi'
	icon_keyboard = "atmos_key"
	icon_screen = "tank"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/atmoscontrol
	req_access = list(ACCESS_ATMOSPHERICS)
	var/datum/ui_module/atmos_control/atmos_control

/obj/machinery/computer/atmoscontrol/Initialize()
	. = ..()
	atmos_control = new(src)

/obj/machinery/computer/atmoscontrol/laptop
	name = "atmospherics laptop"
	desc = "Cheap Nanotrasen laptop."
	icon_state = "medlaptop"
	density = FALSE

/obj/machinery/computer/atmoscontrol/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	atmos_control.ui_interact(user, ui_key, ui, force_open)
