/obj/machinery/poolcontroller
	name = "Pool Controller"
	desc = "A controller for the nearby pool."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	var/list/linkedturfs = list() //List contains all of the linked pool turfs to this controller, assignment happens on New()
	var/temperature = "normal" //The temperature of the pool, starts off on normal, which has no effects.
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
	else //If it's not a multitool, defer to /obj/machinery/proc/attackby
		..()

/obj/machinery/poolcontroller/attack_hand()
	if(!Adjacent(usr))
		usr << "You moved away."
		return

	if(emagged) //Emagging unlocks more (deadly) options.
		var/temp = input("What temperature would you like to set the pool to?", "Pool Temperature") in list("Scalding","Frigid", "Warm", "Cool", "Normal","Cancel") //Allow user to choose which temperature they want.

		switch(temp) //Used for setting the actual temperature var based on user input.
			if("Scalding")
				miston() //Turn on warning mist for the pool
				temperature = "scalding" //Burn em!
				usr << "<span class='warning'>You flick the pool temperature to [temperature](WARNING).</span>" //Differ from standard message to make sure the user understands the temperature is harmful.
				return //Return to avoid calling the un-unique message.
			if("Frigid")
				temperature = "frigid"
				usr << "<span class='warning'>You flick the pool temperature to [temperature](WARNING).</span>" //Differ from standard message to make sure the user understands the temperature is harmful.
				mistoff() //this won't get called otherwise
				return //Return to avoid calling the un-unique message.

			//Regular non-traitorous temperature choices still avalible.
			if("Warm")
				temperature = "warm"
			if("Cool")
				temperature = "cool"
			if("Normal")
				temperature = "normal"
			if("Cancel")
				return

		mistoff() //Remove all mist, setting it to scalding returns before now, only regular temperatures will call it
		usr << "<span class='warning'>You flick the pool temperature to [temperature].</span>" //Inform the mob of the temperature they just picked.
		return

	else
		var/temp = input("What temperature would you like to set the pool to?", "Pool Temperature") in list("Warm","Cool","Normal","Cancel") //Allow user to choose which temperature they want.

		switch(temp) //Used for setting the actual temperature var based on user input.
			if("Warm")
				temperature = "warm"
			if("Cool")
				temperature = "cool"
			if("Normal")
				temperature = "normal"
			if("Cancel") //Cancel does nothing and leaves the temperature at it's previous state.
				return

		mistoff() //Remove all mist, because it shouldn't be here if the pool is not set to scalding
		usr << "<span class='warning'>You flick the pool temperature to [temperature].</span>" //Display what the user picked.
		return

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