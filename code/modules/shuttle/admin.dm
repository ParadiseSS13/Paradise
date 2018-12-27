/obj/machinery/computer/shuttle/admin
	name = "Administration Shuttle Console"
	desc = "Used to call and send the administration shuttle."
	shuttleId = "admin"
	possible_destinations = "admin_home;admin_away;admin_custom"
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/camera_advanced/shuttle_docker/admin
	name = "Administration Shuttle Navigation Computer"
	desc = "Used to designate a precise transit location for the administration shuttle."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	shuttleId = "admin"
	shuttlePortId = "admin_custom"
	view_range = 13
	x_offset = 0
	y_offset = 0
	see_hidden = TRUE
	resistance_flags = INDESTRUCTIBLE
	access_derelict = TRUE
	access_deepspace = TRUE