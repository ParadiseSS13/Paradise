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

/obj/machinery/poolcontroller/New() //This proc automatically happens on world start
	for(var/turf/simulated/floor/beach/water/W in range(srange,src)) //Search for /turf/simulated/floor/beach/water in the range of var/srange
		src.linkedturfs += W //Add found pool turfs to the central list.
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
	updatePool() //Call the mob affecting/decal cleaning proc

/obj/machinery/poolcontroller/proc/updatePool()
	for(var/turf/simulated/floor/beach/water/W in linkedturfs) //Check for pool-turfs linked to the controller.
		for(var/mob/M in W) //Check for mobs in the linked pool-turfs.
			//Sanity checks, don't affect robuts, AI eyes, and observers
			if(isAIEye(M))
				continue
			if(issilicon(M))
				continue
			if(isobserver(M))
				continue
			//End sanity checks, go on
			switch(temperature) //Apply different effects based on what the temperature is set to.
				if("scalding") //Burn the mob.
					M.bodytemperature = min(500, M.bodytemperature + 35) //heat mob at 35k(elvin) per cycle
					M << "<span class='danger'>The water is searing hot!</span>"

				if("frigid") //Freeze the mob.
					M.bodytemperature = max(80, M.bodytemperature - 35) //cool mob at -35k per cycle
					M << "<span class='danger'>The water is freezing!</span>"

				if("normal") //Normal temp does nothing, because it's just room temperature water.

				if("warm") //Gently warm the mob.
					M.bodytemperature = min(330, M.bodytemperature + 10) //Heats up mobs to just over normal, not enough to burn
					if(prob(50)) //inform the mob of warm water half the time
						M << "<span class='warning'>The water is quite warm.</span>" //Inform the mob it's warm water.

				if("cool") //Gently cool the mob.
					M.bodytemperature = max(290, M.bodytemperature - 10) //Cools mobs to just below normal, not enough to burn
					if(prob(50)) //inform the mob of cold water half the time
						M << "<span class='warning'>The water is chilly.</span>" //Inform the mob it's chilly water.

			if(ishuman(M)) //Make sure they are human before typecasting.
				var/mob/living/carbon/human/drownee = M //Typecast them as human.
				if(drownee.stat == DEAD) //Check stat, if they are dead, ignore them.
					continue
				if(drownee && drownee.lying && !drownee.internal && !(drownee.species.flags & NO_BREATHE) && !(drownee.species.name == "Skrell" || drownee.species.name =="Neara") && !(NO_BREATH in drownee.mutations))
				//Establish that there is a mob, the mob is lying down, has no internals, species does breathe, is not a skrell/neara, and does not have NO_BREATHE
					if(drownee.stat != CONSCIOUS) //Mob is in critical.
						drownee.adjustOxyLoss(9) //Kill em quickly.
						drownee << "<span class='danger'>You're quickly drowning!</span>" //inform them that they are fucked.
					else
						if(!drownee.internal) //double check they have no internals, just in case.
							drownee.adjustOxyLoss(5) //5 oxyloss per cycle.
							if(prob(35)) //35% chance to tell them what is going on. They should probably figure it out before then.
								drownee << "<span class='danger'>You're lacking air!</span>" //*gasp* *gasp* *gasp* *gasp* *gasp*

		for(var/obj/effect/decal/cleanable/decal in W)
			animate(decal, alpha = 10, time = 20)
			spawn(25)
				qdel(decal)

/obj/machinery/poolcontroller/proc/miston() //Spawn /obj/effect/mist (from the shower) on all linked pool tiles
	for(var/turf/simulated/floor/beach/water/W in linkedturfs)
		var/M = new /obj/effect/mist(W)
		if(misted)
			return
		linkedmist += M

	misted = 1 //var just to keep track of when the mist on proc has been called.

/obj/machinery/poolcontroller/proc/mistoff() //Delete all /obj/effect/mist from all linked pool tiles.
	for(var/obj/effect/mist/M in linkedmist)
		qdel(M)
	misted = 0 //no mist left, turn off the tracking var

/obj/machinery/poolcontroller/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data["currentTemp"] = capitalize(src.temperature)
	data["emagged"] = emagged
	data["TempColor"] = temperaturecolor

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "poolcontroller.tmpl", "Pool Controller Interface", 520, 410)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/poolcontroller/Topic(href, href_list)
	if(..())	return 1

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

	return 1