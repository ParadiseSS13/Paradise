/obj/machinery/computer/vr_pvp
	name = "VR PVP Console"
	desc = "Your one stop shot for VR arena tickets"
	icon_screen = "comm_logs"

	light_color = LIGHT_COLOR_DARKGREEN

/obj/machinery/computer/vr_pvp/New()
	..()

/obj/machinery/computer/vr_pvp/Destroy()
	return ..()

/obj/machinery/computer/vr_pvp/attack_ai(mob/user)
	ui_interact(user)


/obj/machinery/computer/vr_pvp/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/vr_pvp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	switch(alert("What would you like to do?", "VR PVP", "Join Roman", "Leave Roman", "Cancel"))
		if("Join Roman")
			vr_roman_ready.Add(user)
		if("Leave Roman")
			vr_roman_ready.Remove(user)
		if("Cancel")
			return

