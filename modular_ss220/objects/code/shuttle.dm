/obj/machinery/computer/shuttle/vox
	name = "Scavenger console"
	desc = "Консоль контроля полета шаттла мусорщиков."
	shuttleId = "vox_shuttle"
	possible_destinations = "vox_shuttle_home;vox_shuttle_away;vox_shuttle_custom"
	req_access = list(ACCESS_VOX)
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT

/obj/machinery/computer/shuttle/vox/attack_ai(mob/user)
	return

/obj/machinery/computer/camera_advanced/shuttle_docker/vox
	name = "Scavenger navigation computer"
	desc = "Консоль навигации шаттла мусорщиков."
	icon_screen = "navigation"
	icon_keyboard = "med_key"
	shuttleId = "vox_shuttle"
	shuttlePortId = "vox_shuttle_custom"
	view_range = 13
	x_offset = 0
	y_offset = 0
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT
	access_mining = FALSE
