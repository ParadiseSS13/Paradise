/obj/machinery/computer/shuttle/white_ship
	name = "White Ship Console"
	desc = "Used to control the White Ship."
	circuit = /obj/item/circuitboard/white_ship
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_custom"

/obj/machinery/computer/camera_advanced/shuttle_docker/white_ship
	name = "White Ship Shuttle Navigation Computer"
	desc = "Used to designate a precise transit location for the white ship. Of course, it's not particularly useful without the actual shuttle console..."
	circuit = /obj/item/circuitboard/white_ship_nav
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	shuttleId = "whiteship"
	shuttlePortId = "whiteship_custom"
	designate_time = 100 //10 seconds
	view_range = 18
	x_offset = 0
	y_offset = 0
	access_derelict = TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship/Initialize()
	. = ..()
	GLOB.jam_on_wardec += src

/obj/machinery/computer/camera_advanced/shuttle_docker/whiteship/Destroy()
	GLOB.jam_on_wardec -= src
	return ..()