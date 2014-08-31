/obj/machinery/computer3/crew
	default_prog		= /datum/file/program/crew
	spawn_parts			= list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/radio)
	icon_state			= "frame-med"

/datum/file/program/crew
	name = "Crew Monitoring Console"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	active_state = "crew"
	var/list/tracked = list(  )

	interact(mob/user)
		if(!interactable())
			return

		scan()
		var/t = ""
		t += "<BR><A href='?src=\ref[src];update=1'>Refresh</A> "
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		t += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='30%'><h3>Vitals</h3></td><td width='30%'><h3>Position</h3></td></tr>"
		var/list/logs = list()
		for(var/obj/item/clothing/under/C in tracked)
			var/log = ""
			var/turf/pos = get_turf(C)
			if((C) && (C.has_sensor) && (pos) && (pos.z == computer.z) && C.sensor_mode)
				if(istype(C.loc, /mob/living/carbon/human))

					var/mob/living/carbon/human/H = C.loc

					var/dam1 = round(H.getOxyLoss(),1)
					var/dam2 = round(H.getToxLoss(),1)
					var/dam3 = round(H.getFireLoss(),1)
					var/dam4 = round(H.getBruteLoss(),1)

					var/life_status = "[H.stat > 1 ? "<span class='bad'>Deceased</span>" : "<span class='good'>Living</span>"]"
					var/damage_report = "(<font color='blue'>[dam1]</font>/<font color='green'>[dam2]</font>/<font color='orange'>[dam3]</font>/<font color='red'>[dam4]</font>)"

					if(H.wear_id)
						log += "<tr><td width='40%'>[H.wear_id.name]</td>"
					else
						log += "<tr><td width='40%'>Unknown</td>"

					switch(C.sensor_mode)
						if(1)
							log += "<td width='30%'>[life_status]</td><td width='30%'>Not Available</td></tr>"
						if(2)
							log += "<td width='30%'>[life_status] [damage_report]</td><td width='30%'>Not Available</td></tr>"
						if(3)
							var/area/player_area = get_area(H)
							log += "<td width='30%'>[life_status] [damage_report]</td><td width='30%'>[format_text(player_area.name)] ([pos.x], [pos.y])</td></tr>"
			logs += log
		logs = sortList(logs)
		for(var/log in logs)
			t += log
		t += "</table>"

		popup.set_content(t)
		popup.open()


	proc/scan()
		for(var/obj/item/clothing/under/C in world)
			if((C.has_sensor) && (istype(C.loc, /mob/living/carbon/human)))
				tracked |= C
		return 1