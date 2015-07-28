/obj/machinery/computer/shuttle_control/multi/vox
	name = "skipjack control console"
	req_access = list(access_vox)
	shuttle_tag = "Vox Skipjack"
	is_syndicate = 1
	warn_on_return = 1

/obj/machinery/computer/shuttle_control/multi/vox/attack_ai(user as mob)
	user << "\red Access Denied."
	return 1

/obj/machinery/computer/shuttle_control/multi/syndicate
	name = "Syndicate control console"
	req_access = list(access_syndicate)
	shuttle_tag = "Syndicate"
	is_syndicate = 1

/obj/machinery/computer/shuttle_control/multi/syndicate/attack_ai(user as mob)
	user << "\red Access Denied."
	return 1