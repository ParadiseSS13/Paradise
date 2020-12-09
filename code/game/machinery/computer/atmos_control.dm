/obj/machinery/computer/atmoscontrol
	name = "\improper central atmospherics computer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "atmos_key"
	icon_screen = "tank"
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/atmoscontrol
	req_access = list(ACCESS_ATMOSPHERICS)
	var/datum/tgui_module/atmos_control/atmos_control

/obj/machinery/computer/atmoscontrol/Initialize()
	. = ..()
	atmos_control = new(src)

/obj/machinery/computer/atmoscontrol/laptop
	name = "atmospherics laptop"
	desc = "Cheap Nanotrasen laptop."
	icon_state = "medlaptop"
	density = FALSE

/obj/machinery/computer/atmoscontrol/attack_ai(mob/user)
	tgui_interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return
	tgui_interact(user)

/obj/machinery/computer/atmoscontrol/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	atmos_control.tgui_interact(user, ui_key, ui, force_open)
