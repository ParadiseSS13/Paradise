/obj/machinery/computer/shuttle_control/multi/vox
	name = "skipjack control console"
	req_access = list(access_vox)
	shuttle_tag = "Vox Skipjack"
	is_syndicate = 1
	warn_on_return = 1

/obj/machinery/computer/shuttle_control/multi/vox/attack_ai(user as mob)
	user << "<span class='warning'>Access Denied.</span>"
	return 1

/obj/machinery/computer/shuttle_control/multi/syndicate
	name = "Syndicate control console"
	req_access = list(access_syndicate)
	shuttle_tag = "Syndicate"
	is_syndicate = 1

/obj/machinery/computer/shuttle_control/multi/syndicate/attack_ai(user as mob)
	user << "<span class='warning'>Access Denied.</span>"
	return 1
	
/obj/machinery/computer/shuttle_control/multi/xenos
	name = "alien control console"
	shuttle_tag = "Xenomorph"
	icon_keyboard = "telesci_key"
	icon_screen = "telesci"
	
/obj/machinery/computer/shuttle_control/multi/xenos/attack_hand(user as mob)
	user << "<span class='warning'>You do not know how to operate this machinery.</span>"
	return 1

/obj/machinery/computer/shuttle_control/multi/xenos/attack_ai(user as mob)
	user << "<span class='warning'>Access Denied.</span>"
	return 1
	
/obj/machinery/computer/shuttle_control/multi/xenos/attack_ghost(user as mob)
	ui_interact(user)

/obj/machinery/computer/shuttle_control/multi/xenos/attack_alien(user as mob)
	ui_interact(user)
	
/obj/machinery/computer/shuttle_control/multi/xenos/CanUseTopic(mob/user)
	if(isalien(user))
		return STATUS_INTERACTIVE
	
	if(ishuman(user))
		return STATUS_CLOSE
		
	return ..()