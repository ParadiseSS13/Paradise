#define SYNDICATE_CHALLENGE_TIMER 12000 //20 minutes

/obj/machinery/computer/shuttle/syndicate
	name = "syndicate shuttle terminal"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	req_access = list(access_syndicate)
	circuit = /obj/item/circuitboard/shuttle/syndicate
	shuttleId = "syndicate"
	possible_destinations = "syndicate_away;syndicate_z5;syndicate_z3;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	var/challenge = FALSE
	var/moved = FALSE

/obj/machinery/computer/shuttle/syndicate/recall
	name = "syndicate shuttle recall terminal"
	circuit = /obj/item/circuitboard/shuttle/syndicate/recall
	possible_destinations = "syndicate_away"

/obj/machinery/computer/shuttle/syndicate/Topic(href, href_list)
	if(href_list["move"])
		if(challenge && world.time < SYNDICATE_CHALLENGE_TIMER)
			to_chat(usr, "<span class='warning'>You've issued a combat challenge to the station! You've got to give them at least [round(((SYNDICATE_CHALLENGE_TIMER - world.time) / 10) / 60)] more minutes to allow them to prepare.</span>")
			return 0
		moved = TRUE
	..()

/obj/machinery/computer/shuttle/syndicate/drop_pod
	name = "syndicate assault pod control"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	req_access = list(access_syndicate)
	circuit = /obj/item/circuitboard/shuttle/syndicate/drop_pod
	shuttleId = "steel_rain"
	possible_destinations = null

/obj/machinery/computer/shuttle/syndicate/drop_pod/Topic(href, href_list)
	if(href_list["move"])
		if(z != level_name_to_num(CENTCOMM))
			to_chat(usr, "<span class='warning'>Pods are one way!</span>")
			return 0
	..()

#undef SYNDICATE_CHALLENGE_TIMER
