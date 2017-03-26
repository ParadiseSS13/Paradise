/obj/machinery/computer/vr_control
	name = "VR console"
	desc = "A list and control panel for all virtual servers."
	icon_screen = "comm_logs"

	light_color = LIGHT_COLOR_DARKGREEN


/obj/machinery/computer/vr_control/New()
	//vr_control = new(src)
	..()

/obj/machinery/computer/vr_control/Destroy()
	//qdel(vr_control)
	return ..()

/obj/machinery/computer/vr_control/attack_ai(mob/user)
	attack_hand(user)
	ui_interact(user)


/obj/machinery/computer/vr_control/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/vr_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	//crew_monitor.ui_interact(user, ui_key, ui, force_open)

/obj/machinery/computer/vr_control/interact(mob/user)
	//crew_monitor.ui_interact(user)

/obj/machinery/computer/vr_control/proc/loadlevel(var/datum/map_template/template)
	//var/map = input(usr, "Choose a Map Template to place at your CURRENT LOCATION","Place Map Template") as null|anything in map_templates
	//if(!map)
	//	return
	template = "_maps/map_files/templates/vr/lobby.dmm"
	var/datum/space_chunk/C = space_manager.allocate_space(template.width, template.height)
	template.load(C, centered = FALSE)