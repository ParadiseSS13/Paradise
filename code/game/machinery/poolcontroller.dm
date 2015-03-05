/obj/machinery/poolcontroller
	name = "Pool Controller"
	desc = "A controller for the nearby pool."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	var/list/linkedturfs = list()
	var/temperature = "normal"
	var/srange = 5

/obj/machinery/poolcontroller/New()
	for(var/turf/simulated/floor/beach/water/W in range(srange,src))
		src.linkedturfs += W
	processing_objects.Add(src)

/obj/machinery/poolcontroller/attack_hand()
	if(!Adjacent(usr))
		usr << "You moved away."
		return
	var/temp = input("What temperature would you like to set the pool to?", "Pool Temperature") in list("Hot","Cold","Normal","Cancel")
	switch(temp)
		if("Hot")
			temperature = "hot"
		if("Cold")
			temperature = "cold"
		if("Normal")
			temperature = "normal"
		if("Cancel")
			return

	usr << "<span class='warning'>You flick the pool temperature to [temperature].</span>"

/obj/machinery/poolcontroller/process()
	if(!linkedturfs)
		processing_objects.Remove(src)
		return
	for(var/turf/simulated/floor/beach/water/W in linkedturfs)
		for(var/mob/M in W)
			if(M)
				updateMobs()

/obj/machinery/poolcontroller/proc/updateMobs()
	for(var/turf/simulated/floor/beach/water/W in linkedturfs)
		for(var/mob/M in W)
			switch(temperature)
				if("hot")
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						H.bodytemperature = min(500, H.bodytemperature + 35)
						H.adjustFireLoss(5)
						H << "<span class='danger'>The water is searing hot!</span>"
					else
						M.bodytemperature = min(500, M.bodytemperature + 35)
						M << "<span class='danger'>The water is searing hot!</span>"

				if("cold")
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						H.bodytemperature = max(80, H.bodytemperature - 80)
						H.adjustFireLoss(5)
						H << "<span class='danger'>The water is freezing!</span>"
					else
						M.bodytemperature = max(80, M.bodytemperature - 80)
						M << "<span class='danger'>The water is freezing!</span>"

				if("normal")
					return