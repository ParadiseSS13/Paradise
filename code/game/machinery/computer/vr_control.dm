/obj/machinery/computer/vr_control
	name = "crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
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

/obj/machinery/computer/vr_control/proc/loadlevel(template)
	var/datum/space_chunk/C = zlev_manager.allocate_space(template.width, template.height)
