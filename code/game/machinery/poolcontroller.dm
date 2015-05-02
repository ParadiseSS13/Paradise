/obj/machinery/poolcontroller
	name = "Pool Controller"
	desc = "A controller for the nearby pool."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	anchored = 1 //this is what I get for assuming /obj/machinery has anchored set to 1 by default
	var/list/linkedturfs = list() //List contains all of the linked pool turfs to this controller, assignment happens on New()
	var/temperature = "normal" //The temperature of the pool, starts off on normal, which has no effects.
	var/temperaturecolor = "" //used for nanoUI fancyness
	var/srange = 5 //The range of the search for pool turfs, change this for bigger or smaller pools.
	var/linkedmist = list() //Used to keep track of created mist
	var/misted = 0 //Used to check for mist.

	var/list/linkedfalls = list()
	var/wfon = 0

/obj/machinery/poolcontroller/New() //This proc automatically happens on world start
	for(var/turf/simulated/floor/beach/water/W in range(srange,src)) //Search for /turf/simulated/floor/beach/water in the range of var/srange
		src.linkedturfs += W //Add found pool turfs to the central list.
	for(var/obj/machinery/poolwaterfall/WF in range(srange,src)) //Search for waterfall objects in var/srange
		src.linkedfalls += WF
	..() //Changed to call parent as per MarkvA's recommendation

/obj/machinery/poolcontroller/emag_act(user as mob) //Emag_act, this is called when it is hit with a cryptographic sequencer.
	if(!emagged) //If it is not already emagged, emag it.
		user << "\red You disable \the [src]'s temperature safeguards." //Inform the mob of what emagging does.
		emagged = 1 //Set the emag var to true.

/obj/machinery/poolcontroller/attackby(obj/item/P as obj, mob/user as mob, params) //Proc is called when a user hits the pool controller with something.

	if(istype(P,/obj/item/device/multitool)) //If the mob hits the pool controller with a multitool, reset the emagged status
		if(emagged) //Check the emag status
			user << "\red You re-enable \the [src]'s temperature safeguards." //Inform the user that they have just fixed the safeguards.
			emagged = 0 //Set the emagged var to false.
			return
		else
			user << "\red Nothing happens." //If not emagged, don't do anything, and don't tell the user that it can be emagged.

		return //Return, nothing else needs to be done.
	else //If it's not a multitool, defer to /obj/machinery/attackby
		..()

/obj/machinery/poolcontroller/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/poolcontroller/process()
	updateMobs() //Call the mob affecting proc

/obj/machinery/poolcontroller/proc/updateMobs()
	for(var/turf/simulated/floor/beach/water/W in linkedturfs) //Check for pool-turfs linked to the controller.
		for(var/mob/M in W) //Check for mobs in the linked pool-turfs.
			//Sanity checks, don't affect robuts, AI eyes, and observers
			if(isAIEye(M))
				return
			if(issilicon(M))
				return
			if(isobserver(M))
				return
			//End sanity checks, go on
			switch(temperature) //Apply different effects based on what the temperature is set to.
				if("scalding") //Burn the mob.
					M.bodytemperature = min(500, M.bodytemperature + 35) //heat mob at 35k(elvin) per cycle
					M << "<span class='danger'>The water is searing hot!</span>"
					return

				if("frigid") //Freeze the mob.
					M.bodytemperature = max(80, M.bodytemperature - 35) //cool mob at -35k per cycle
					M << "<span class='danger'>The water is freezing!</span>"
					return

				if("normal") //Normal temp does nothing, because it's just room temperature water.
					return

				if("warm") //Gently warm the mob.
					M.bodytemperature = min(330, M.bodytemperature + 10) //Heats up mobs to just over normal, not enough to burn
					if(prob(50)) //inform the mob of warm water half the time
						M << "<span class='warning'>The water is quite warm.</span>" //Inform the mob it's warm water.
					return

				if("cool") //Gently cool the mob.
					M.bodytemperature = max(290, M.bodytemperature - 10) //Cools mobs to just below normal, not enough to burn
					if(prob(50)) //inform the mob of cold water half the time
						M << "<span class='warning'>The water is chilly.</span>" //Inform the mob it's chilly water.
					return

/obj/machinery/poolcontroller/proc/miston() //Spawn /obj/effect/mist (from the shower) on all linked pool tiles
	for(var/turf/simulated/floor/beach/water/W in linkedturfs)
		var/M = new /obj/effect/mist(W)
		if(misted)
			return
		linkedmist += M

	misted = 1 //var just to keep track of when the mist on proc has been called.

/obj/machinery/poolcontroller/proc/mistoff() //Delete all /obj/effect/mist from all linked pool tiles.
	for(var/obj/effect/mist/M in linkedmist)
		del(M)
	misted = 0 //no mist left, turn off the tracking var

/obj/machinery/poolcontroller/proc/WFtoggle(var/state=0)
	for(var/obj/machinery/poolwaterfall/WF in linkedfalls)
		WF.ToggleState(state)
	wfon = state

/obj/machinery/poolcontroller/proc/getWFnum()
	return src.linkedfalls.len

/obj/machinery/poolcontroller/proc/getWFstat()
	switch(wfon)
		if(1)
			return "On"
		if(0)
			return "Off"
	return "Off"

/obj/machinery/poolcontroller/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data["currentTemp"] = capitalize(src.temperature)
	data["emagged"] = emagged
	data["TempColor"] = temperaturecolor
	data["wfallstatus"] = getWFstat()
	data["linkedfalls"] = getWFnum()

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "poolcontroller.tmpl", "Pool Controller Interface", 520, 410)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/poolcontroller/Topic(href, href_list)
	if(..())	return 1

	if(href_list["temp"])
		switch(href_list["temp"])
			if("Scalding")
				if(!src.emagged)
					return 0
				src.temperature = "scalding"
				src.temperaturecolor = "#FF0000"
				miston()
			if("Frigid")
				if(!src.emagged)
					return 0
				src.temperature = "frigid"
				src.temperaturecolor = "#00CCCC"
				mistoff()
			if("Warm")
				src.temperature = "warm"
				src.temperaturecolor = "#990000"
				mistoff()
			if("Cool")
				src.temperature = "cool"
				src.temperaturecolor = "#009999"
				mistoff()
			if("Normal")
				src.temperature = "normal"
				src.temperaturecolor = ""
				mistoff()

	else if(href_list["WFtoggle"])
		switch(href_list["WFtoggle"])
			if("wfallon")
				src.WFtoggle(1)
			if("wfalloff")
				src.WFtoggle(0)

	return 1

/////////////////////////////
/////// MISC OBJECTS ////////
/////////////////////////////

/obj/machinery/poolwaterfall
	name = "waterfall port"
	desc = "Wooossshh."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wfnozzle_0"
	var/on = 0

/obj/machinery/poolwaterfall/New()
	..()
	src.layer = MOB_LAYER + 0.2 //intended to be on pool turfs, needs to be above the pool overlay

/obj/machinery/poolwaterfall/update_icon()
	flick("wfnozzle_a[on]",src)
	icon_state = "wfnozzle_[on]"

/obj/machinery/poolwaterfall/proc/SwitchOn()
	src.visible_message("<span class='notice'>\The [src] switches on.</span>", \
	 "<span class='notice'>\The [src] switches on.</span>", \
	 "<span class='notice'>You hear water falling.</span>")
	src.on = 1
	src.update_icon()

/obj/machinery/poolwaterfall/proc/SwitchOff()
	src.visible_message("<span class='notice'>\The [src] switches off.</span>", \
	 "<span class='notice'>\The [src] switches off.</span>", \
	 "<span class='notice'>You hear water abruptly stop falling.</span>")
	src.on = 0
	src.update_icon()

/obj/machinery/poolwaterfall/proc/ToggleState(var/state=0)
	switch(state)
		if(1)
			if(!src.on)
				src.SwitchOn()
		if(0)
			if(src.on)
				src.SwitchOff()
		else
			return