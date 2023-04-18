/obj/machinery/computer/podtracker
	name = "pod tracking console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_keyboard = "tech_key"
	icon_screen = "rdcomp"
	light_color = LIGHT_COLOR_PURPLE
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/pod_locater

/obj/machinery/computer/podtracker/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/podtracker/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/podtracker/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PodTracking", name, 400, 500, master_ui, state)
		ui.open()

/obj/machinery/computer/podtracker/ui_data(mob/user)
	var/list/data = list()
	var/list/pods = list()
	for(var/obj/item/spacepod_equipment/misc/tracker/TR in GLOB.pod_trackers)
		var/obj/spacepod/my_pod = TR.my_atom
		var/podname = capitalize(sanitize(my_pod.name))
		var/pilot = "None"
		var/passengers = list()
		if(my_pod.pilot)
			pilot = my_pod.pilot
		if(my_pod.passengers)
			for(var/mob/M in my_pod.passengers)
				passengers += M.name
		var/passengers_text = english_list(passengers, "None")

		pods.Add(list(list("name" = podname, "podx" = my_pod.x, "pody" = my_pod.y, "podz" = my_pod.z, "pilot" = pilot, "passengers" = passengers_text)))

	data["pods"] = pods
	return data
