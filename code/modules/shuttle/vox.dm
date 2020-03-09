/obj/machinery/computer/shuttle/vox
	name = "skipjack control console"
	req_access = list(ACCESS_VOX)
	shuttleId = "skipjack"
	possible_destinations = "skipjack_away;skipjack_ne;skipjack_nw;skipjack_se;skipjack_sw;skipjack_z5;skipjack_custom"
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT

/obj/machinery/computer/camera_advanced/shuttle_docker/vox
	name = "skipjack navigation computer"
	desc = "Used to designate a precise transit location for the skipjack."
	icon_screen = "navigation"
	icon_keyboard = "med_key"
	shuttleId = "skipjack"
	shuttlePortId = "skipjack_custom"
	view_range = 13
	x_offset = -10
	y_offset = -10
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT
	access_derelict = TRUE
