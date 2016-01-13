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
	var/list/linkedmist = list() //Used to keep track of created mist


/obj/machinery/poolcontroller/New() //This proc automatically happens on world start
	for(var/turf/simulated/floor/beach/water/W in range(srange,src)) //Search for /turf/simulated/floor/beach/water in the range of var/srange
		linkedturfs += W //Add found pool turfs to the central list.
	..() //Changed to call parent as per MarkvA's recommendation

/obj/machinery/poolcontroller/emag_act(user as mob) //Emag_act, this is called when it is hit with a cryptographic sequencer.
	if(!emagged) //If it is not already emagged, emag it.
		user << "<span class='warning'>You disable \the [src]'s temperature safeguards.</span>" //Inform the mob of what emagging does.
		emagged = 1 //Set the emag var to true.

/obj/machinery/poolcontroller/attackby(obj/item/P as obj, mob/user as mob, params) //Proc is called when a user hits the pool controller with something.
	if(istype(P,/obj/item/device/multitool)) //If the mob hits the pool controller with a multitool, reset the emagged status
		if(emagged) //Check the emag status
			user << "<span class='warning'>You re-enable \the [src]'s temperature safeguards.</span>" //Inform the user that they have just fixed the safeguards.
			emagged = 0 //Set the emagged var to false.
		else
			user << "<span class='warning'>Nothing happens.</span>" //If not emagged, don't do anything, and don't tell the user that it can be emagged.

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
			if(M.stat == DEAD)
				continue
			//End sanity checks, go on
			switch(temperature) //Apply different effects based on what the temperature is set to.
				if("scalding") //Burn the mob.
					M.bodytemperature = min(500, M.bodytemperature + 35) //heat mob at 35k(elvin) per cycle
					M << "<span class='danger'>The water is searing hot!</span>"

				if("warm") //Gently warm the mob.
					M.bodytemperature = min(330, M.bodytemperature + 10) //Heats up mobs to just over normal, not enough to burn
					if(prob(50)) //inform the mob of warm water half the time
						M << "<span class='warning'>The water is quite warm.</span>" //Inform the mob it's warm water.

				if("cool") //Gently cool the mob.
					M.bodytemperature = max(290, M.bodytemperature - 10) //Cools mobs to just below normal, not enough to burn
					if(prob(50)) //inform the mob of cold water half the time
						M << "<span class='warning'>The water is chilly.</span>" //Inform the mob it's chilly water.

				if("frigid") //Freeze the mob.
					M.bodytemperature = max(80, M.bodytemperature - 35) //cool mob at -35k per cycle
					M << "<span class='danger'>The water is freezing!</span>"


			if(ishuman(M)) //Make sure they are human before typecasting.
				var/mob/living/carbon/human/drownee = M //Typecast them as human.
				if(drownee && drownee.lying) //Mob lying down
					if(drownee.internal)
						continue //Has internals, no drowning
					if((drownee.species.flags & NO_BREATHE) || (NO_BREATHE in drownee.mutations))
						continue //doesn't breathe, no drowning
					if(drownee.get_species() == "Skrell" || drownee.get_species() == "Neara")
						continue //fish things don't drown

					if(drownee.stat) //Mob is in critical.
						drownee.adjustOxyLoss(9) //Kill em quickly.
						add_logs(drownee, src, "drowned")
						drownee.visible_message("<span class='danger'>\The [drownee] appears to be drowning!</span>","<span class='userdanger'>You're quickly drowning!</span>") //inform them that they are fucked.
					else
						drownee.adjustOxyLoss(5) //5 oxyloss per cycle.
						add_logs(drownee, src, "drowned")
						if(prob(35)) //35% chance to tell them what is going on. They should probably figure it out before then.
							drownee.visible_message("<span class='danger'>\The [drownee] flails, almost like they are drowning!</span>","<span class='userdanger'>You're lacking air!</span>") //*gasp* *gasp* *gasp* *gasp* *gasp*

		for(var/obj/effect/decal/cleanable/decal in W)
			animate(decal, alpha = 10, time = 20)
			spawn(25)
				qdel(decal)

/obj/machinery/poolcontroller/proc/miston() //Spawn /obj/effect/mist (from the shower) on all linked pool tiles
	if(linkedmist.len)
		return

	for(var/turf/simulated/floor/beach/water/W in linkedturfs)
		var/M = new /obj/effect/mist(W)
		linkedmist += M

/obj/machinery/poolcontroller/proc/mistoff() //Delete all /obj/effect/mist from all linked pool tiles.
	for(var/obj/effect/mist/M in linkedmist)
		qdel(M)
	linkedmist.Cut()


/obj/machinery/poolcontroller/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data["currentTemp"] = temperature
	data["emagged"] = emagged
	data["TempColor"] = temperaturecolor

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "poolcontroller.tmpl", "Pool Controller Interface", 520, 410)
		ui.set_initial_data(data)
		ui.open()



/obj/machinery/poolcontroller/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["temp"])
		if("Scalding")
			if(!emagged)
				return 0
			temperature = "scalding"
			temperaturecolor = "#FF0000"
			miston()
		if("Frigid")
			if(!emagged)
				return 0
			temperature = "frigid"
			temperaturecolor = "#00CCCC"
			mistoff()
		if("Warm")
			temperature = "warm"
			temperaturecolor = "#990000"
			mistoff()
		if("Cool")
			temperature = "cool"
			temperaturecolor = "#009999"
			mistoff()
		if("Normal")
			temperature = "normal"
			temperaturecolor = ""
			mistoff()

	return 1