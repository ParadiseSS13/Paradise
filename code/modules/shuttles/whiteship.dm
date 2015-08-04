/obj/machinery/computer/shuttle_control/multi/whiteship
	name = "medical ship control console"
	req_access = list()
	shuttle_tag = "White Ship"
	circuit = "/obj/item/weapon/circuitboard/white_ship"
	light_color = LIGHT_COLOR_DARKRED

/obj/machinery/computer/shuttle_control/multi/whiteship/attack_ai(user as mob)
	user << "\red Access Denied."
	return 1

/obj/machinery/computer/shuttle_control/multi/whiteship/New()
	var/area/A = get_area(src)
	if(!istype(A,/area/shuttle/derelict/ship))
		visible_message("<span class='warning'>\The [src] displays a message: No connectible systems located. Shutting down.</span>")
		var/V = text2path(circuit)
		new V(loc)

		animate(src, alpha = 10, time = 20)
		spawn(20)
			visible_message("<span class='danger'>\The [src] fades out of existence!</span>")
			qdel(src)
	..()