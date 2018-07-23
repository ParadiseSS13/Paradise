/obj/machinery/computer/podtracker
	name = "pod tracking console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "tech_key"
	icon_screen = "rdcomp"
	light_color = LIGHT_COLOR_PURPLE
	req_access = list(access_robotics)
	circuit = /obj/item/circuitboard/pod_locater

/obj/machinery/computer/podtracker/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/podtracker/attack_hand(user as mob)
	ui_interact(user)

/obj/machinery/computer/podtracker/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "pod_tracking.tmpl", "Pod Tracking Console", 400, 500)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/podtracker/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	var/list/pods[0]
	for(var/obj/item/spacepod_equipment/misc/tracker/TR in world)
		var/obj/spacepod/my_pod = TR.my_atom
		var/enabled = TR.enabled
		if(my_pod && enabled)
			var/podname = capitalize(sanitize(my_pod.name))
			var/list/chairs = list()
			if(my_pod.pilot || my_pod.passengers)
				if(my_pod.pilot)
					chairs += list("pilot" = my_pod.pilot.name)
				var/i = 1
				for(var/mob/M in my_pod.passengers)
					chairs += list("passenger [i]" = M.name)
					i++

			pods.Add(list(list("pod" = "\ref[my_pod]", "name" = podname) + chairs + list("x" = my_pod.x, "y" = my_pod.y, "z" = my_pod.z)))

	data["pods"] = pods
	return data

/obj/machinery/computer/podtracker/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["refresh"])
		SSnanoui.update_uis(src)
