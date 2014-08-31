/obj/machinery/computer/shuttle_control/mining
	name = "mining shuttle console"
	shuttle_tag = "Mining"
	//req_access = list(access_mining)
	circuit = /obj/item/weapon/circuitboard/mining_shuttle

/obj/machinery/computer/shuttle_control/engineering
	name = "engineering shuttle console"
	shuttle_tag = "Engineering"
	//req_one_access_txt = "11;24"
	circuit = /obj/item/weapon/circuitboard/engineering_shuttle

/obj/machinery/computer/shuttle_control/research
	name = "research shuttle console"
	shuttle_tag = "Research"
	//req_access = list(access_research)
	circuit = /obj/item/weapon/circuitboard/research_shuttle

/obj/machinery/computer/shuttle_control/labor_camp
	name = "labor camp shuttle console"
	shuttle_tag = "Labor"
	req_access = list(access_brig)

/obj/machinery/computer/shuttle_control/labor_camp/one_way
	name = "prisoner shuttle console"
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
