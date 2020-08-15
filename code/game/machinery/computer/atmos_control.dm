/obj/machinery/computer/atmoscontrol
	name = "\improper Central Atmospherics Computer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "atmos_key"
	icon_screen = "tank"
	light_color = LIGHT_COLOR_GREEN
	density = 1
	anchored = 1.0
	circuit = /obj/item/circuitboard/atmoscontrol
	req_access = list(ACCESS_ATMOSPHERICS)
	var/list/monitored_alarm_ids = null
	var/datum/nano_module/atmos_control/atmos_control

/obj/machinery/computer/atmoscontrol/laptop
	name = "atmospherics laptop"
	desc = "Cheap Nanotrasen laptop."
	icon_state = "medlaptop"
	density = 0

/obj/machinery/computer/atmoscontrol/attack_ai(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)

/obj/machinery/computer/atmoscontrol/emag_act(mob/user)
	if(!emagged)
		user.visible_message("<span class='warning'>\The [user] does something \the [src], causing the screen to flash!</span>",\
			"<span class='warning'>You cause the screen to flash as you gain full control.</span>",\
			"You hear an electronic warble.")
		atmos_control.emagged = 1
		return 1

/obj/machinery/computer/atmoscontrol/ui_interact(var/mob/user)
	if(!atmos_control)
		atmos_control = new(src, req_access, req_one_access, monitored_alarm_ids)
	atmos_control.ui_interact(user)
