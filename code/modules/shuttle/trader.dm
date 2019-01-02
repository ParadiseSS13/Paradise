/obj/machinery/computer/shuttle/vox
	name = "skipjack control console"
	req_access = list(access_vox)
	shuttleId = "skipjack"
	possible_destinations = "skipjack_away;skipjack_ne;skipjack_nw;skipjack_se;skipjack_sw;skipjack_z5;skipjack_custom"
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/camera_advanced/shuttle_docker/vox
	name = "skipjack navigation computer"
	desc = "Used to designate a precise transit location for the skipjack."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	shuttleId = "skipjack"
	shuttlePortId = "skipjack_custom"
	view_range = 13
	x_offset = -10
	y_offset = -10
	resistance_flags = INDESTRUCTIBLE
	access_derelict = TRUE
	access_deepspace = TRUE

var/global/trade_dock_timelimit = 0
var/global/trade_dockrequest_timelimit = 0

/obj/machinery/computer/shuttle/trade
	name = "Freighter Console"
	docking_request = 1
	var/possible_destinations_dock
	var/possible_destinations_nodock
	var/docking_request_message = "A trading ship has submitted a request to dock for trading. This request can be accepted or denied using a communications console."
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/shuttle/trade/attack_hand(mob/user)
	if(world.time < trade_dock_timelimit)
		possible_destinations = possible_destinations_dock
	else
		possible_destinations = possible_destinations_nodock

	docking_request = (world.time > trade_dockrequest_timelimit && world.time > trade_dock_timelimit)
	..(user)

/obj/machinery/computer/shuttle/trade/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["request"])
		if(world.time < trade_dockrequest_timelimit || world.time < trade_dock_timelimit)
			return
		to_chat(usr, "<span class='notice'>Request sent.</span>")
		event_announcement.Announce(docking_request_message, "Docking Request")
		trade_dockrequest_timelimit = world.time + 1200 // They have 2 minutes to approve the request.
		return 1

/obj/machinery/computer/shuttle/trade/sol
	req_access = list(access_trade_sol)
	possible_destinations_dock = "trade_sol_base;trade_sol_offstation;trade_dock"
	possible_destinations_nodock = "trade_sol_base;trade_sol_offstation"
	shuttleId = "trade_sol"
	docking_request_message = "A trading ship of Sol origin has requested docking aboard the NSS Cyberiad for trading. This request can be accepted or denied using a communications console."
