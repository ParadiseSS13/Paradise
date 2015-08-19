/obj/machinery/computer/shuttle_control/mining
	name = "Mining Shuttle Console"
	shuttle_tag = "Mining"
	req_access = list()
	circuit = /obj/item/weapon/circuitboard/mining_shuttle

/obj/machinery/computer/shuttle_control/engineering
	name = "Engineering Shuttle Console"
	shuttle_tag = "Engineering"
	req_one_access_txt = "10;24"
	circuit = /obj/item/weapon/circuitboard/engineering_shuttle

/obj/machinery/computer/shuttle_control/research
	name = "Research Shuttle Console"
	shuttle_tag = "Research"
	req_access = list(access_xenoarch)
	circuit = /obj/item/weapon/circuitboard/research_shuttle

/obj/machinery/computer/shuttle_control/labor_camp
	name = "Labor Camp Shuttle Console"
	shuttle_tag = "Labor"
	req_access = list(access_brig)

/obj/machinery/computer/shuttle_control/labor_camp/one_way
	name = "Prisoner Shuttle Console"
	req_access = list()

/obj/machinery/computer/shuttle_control/labor_camp/one_way/launch()
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return
	if (shuttle.location)
		src.visible_message("\blue Shuttle is already at the outpost.")
		return
	..()

/obj/machinery/computer/shuttle_control/labor_camp/one_way/force_launch()
	var/datum/shuttle/ferry/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return
	if (shuttle.location)
		src.visible_message("\blue Shuttle is already at the outpost.")
		return
	..()

/obj/machinery/computer/shuttle_control/labor_camp/one_way/cancel_launch()
	src.visible_message("\red That command has been disabled.")
