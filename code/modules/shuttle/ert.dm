/obj/machinery/computer/shuttle/ert
	name = "specops shuttle console"
	req_access = list(ACCESS_CENT_GENERAL)
	shuttleId = "specops"
	possible_destinations = "specops_home;specops_away;specops_custom"
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT

/obj/machinery/computer/camera_advanced/shuttle_docker/ert
	name = "specops navigation computer"
	desc = "Used to designate a precise transit location for the specops shuttle."
	icon_screen = "navigation"
	icon_keyboard = "med_key"
	shuttleId = "specops"
	shuttlePortId = "specops_custom"
	view_range = 13
	x_offset = 0
	y_offset = 0
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT
	access_tcomms = FALSE
	access_construction = FALSE
	access_mining = FALSE
