/obj/machinery/computer/podtracker
	name = "Pod Tracking Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "podtracking"
	light_color = LIGHT_COLOR_PURPLE
	req_access = list(access_robotics)
	circuit = "/obj/item/weapon/circuitboard/pod_locater"

/obj/machinery/computer/podtracker/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/podtracker/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<html><head><title>[src.name]</title><style>h3 {margin: 0px; padding: 0px;}</style></head><body>"
	dat += "<h3>Pod beacons data</h3>"
	for(var/obj/item/device/spacepod_equipment/misc/tracker/TR in world)
		var/obj/spacepod/myPod = TR.my_atom
		var/enabled = TR.enabled
		if(myPod && enabled)
			dat += {"<hr>[capitalize(myPod.name)]</br>
					  <b>&nbsp;Pod SPS X:</b> [myPod.x]</br>
					  <b>&nbsp;Pod SPS Y:</b> [myPod.y]</br>
					  <b>&nbsp;Pod SPS Z:</b> [myPod.z]</br>"}
			if(myPod.occupant)
				dat += {"<b>&nbsp;Pod Pilot:</b> [myPod.occupant.name]</br>"}
			if(myPod.occupant2)
				dat += {"<b>&nbsp;Pod Passenger:</b> [myPod.occupant2.name]</br>"}

	dat += "<A href='?src=\ref[src];refresh=1'>(Refresh)</A><BR>"
	dat += "</body></html>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/podtracker/Topic(href, href_list)
	if(..())
		return
	src.updateUsrDialog()
	return
