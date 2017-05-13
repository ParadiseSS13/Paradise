/obj/machinery/computer/vr_control
	name = "VR console"
	desc = "A list and control panel for all virtual servers."
	icon_screen = "comm_logs"

	light_color = LIGHT_COLOR_DARKGREEN

/obj/machinery/computer/vr_control/attack_ai(mob/user)
	attack_hand(user)
	ui_interact(user)


/obj/machinery/computer/vr_control/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/vr_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	switch(alert("What would you like to do?", "VR Control", "Join Room", "Make Room", "Cancel"))
		if("Join Room")
			spawn_vr_avatar(user, input(user, "Choose a room to join.","Select Level") as null|anything in vr_rooms)
			qdel(user)
		if("Make Room")
			make_vr_room(input(user, "Name your new Room","Name here.") as null|text, input(user, "Choose a Level to load into your new Room.","Select Level") as null|anything in vr_templates)
		if("Cancel")
			return

/obj/machinery/computer/vr_control/interact(mob/user)

