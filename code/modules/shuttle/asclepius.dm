/obj/machinery/computer/shuttle/asclepius
	name = "NHV Asclepius shuttle console"
	req_access = list(access_cent_general)
	shuttleId = "asclepius"
	possible_destinations = "asclepius_home;asclepius_away;asclepius_custom"
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/camera_advanced/shuttle_docker/asclepius
	name = "NHV Asclepius navigation computer"
	desc = "Used to designate a precise transit location for the NHV Asclepius."
	icon_screen = "navigation"
	icon_keyboard = "med_key"
	shuttleId = "asclepius"
	shuttlePortId = "asclepius_custom"
	view_range = 14
	x_offset = 0
	y_offset = 0
	resistance_flags = INDESTRUCTIBLE
	access_tcomms = TRUE
	access_construction = TRUE
	access_mining = TRUE

