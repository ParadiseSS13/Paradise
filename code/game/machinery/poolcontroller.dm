#define FRIGID		80
#define COOL		290
#define NORMAL		310
#define WARM		330
#define SCALDING	500

/obj/machinery/poolcontroller
	name = "Pool Controller"
	desc = "A controller for the nearby pool."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	anchored = 1 //this is what I get for assuming /obj/machinery has anchored set to 1 by default
	var/list/linkedturfs = list() //List contains all of the linked pool turfs to this controller, assignment happens on New()
	var/mobinpool = list() //List contains all of the mob in the pool, to prevent looping through the entire area to find mobs inside..
	var/decalinpool = list() // List containing all of the cleanable decals in pool
	var/linked_area = null
	var/temperature = NORMAL //The temperature of the pool, starts off on normal, which has no effects.
	var/temperaturecolor = "" //used for nanoUI fancyness
	var/srange = 5 //The range of the search for pool turfs, change this for bigger or smaller pools.
	var/list/linkedmist = list() //Used to keep track of created mist
	var/deep_water = FALSE		//set to 1 to drown even standing people

/obj/machinery/poolcontroller/invisible
	invisibility = INVISIBILITY_MAXIMUM
	name = "Water Controller"
	desc = "An invisible water controller. Players shouldn't see this."

/obj/machinery/poolcontroller/invisible/sea
	name = "Sea Controller"
	desc = "A controller for the underwater portion of the sea. Players shouldn't see this."
	deep_water = TRUE

/obj/machinery/poolcontroller/Initialize(mapload)
	var/contents_loop = linked_area
	if(!linked_area)
		contents_loop = range(srange, src)

	for(var/turf/T in contents_loop)
		if(istype(T, /turf/simulated/floor/beach/water))
			var/turf/simulated/floor/beach/water/W = T
			W.linkedcontroller = src
			linkedturfs += T
		else if(istype(T, /turf/unsimulated/beach/water))
			var/turf/unsimulated/beach/water/W = T
			W.linkedcontroller = src
			linkedturfs += T

	. = ..()

/obj/machinery/poolcontroller/invisible/Initialize(mapload)
	linked_area = get_area(src)
	. = ..()

/obj/machinery/poolcontroller/emag_act(user as mob) //Emag_act, this is called when it is hit with a cryptographic sequencer.
	if(!emagged) //If it is not already emagged, emag it.
		to_chat(user, "<span class='warning'>You disable \the [src]'s temperature safeguards.</span>")//Inform the mob of what emagging does.

		emagged = 1 //Set the emag var to true.

/obj/machinery/poolcontroller/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(emagged) //Check the emag status
		to_chat(user, "<span class='warning'>You re-enable [src]'s temperature safeguards.</span>")//Inform the user that they have just fixed the safeguards.
		emagged = FALSE //Set the emagged var to false.
	else
		to_chat(user, "<span class='warning'>Nothing happens.</span>")//If not emagged, don't do anything, and don't tell the user that it can be emagged.

/obj/machinery/poolcontroller/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/poolcontroller/process()
	processMob() //Call the mob affecting proc
	cleanPool() //Call the decal cleaning proc

/obj/machinery/poolcontroller/proc/processMob()
	for(var/M in mobinpool) //They're already typecasted when entering the turf
		// Following two are sanity check. If the mob is no longer in the pool for whatever reason (Looking at you teleport), remove them
		if(!istype(get_turf(M), /turf/simulated/floor/beach/water) && !istype(get_turf(M), /turf/unsimulated/beach/water)) // Water component when?
			mobinpool -= M
			continue
		handleTemp(M)	//handles pool temp effects on the swimmers
		if(ishuman(M)) //Only human types will drown, to keep things simple for non-human mobs that live in the water
			handleDrowning(M)

/obj/machinery/poolcontroller/proc/cleanPool()
	for(var/obj/effect/decal/cleanable/decal in decalinpool)		//Cleans up cleanable decals like blood and such
		if(!QDELETED(decal))
			animate(decal, alpha = 10, time = 20)
			QDEL_IN(decal, 25)

/obj/machinery/poolcontroller/proc/handleTemp(var/mob/M)
	if(!M || isAIEye(M) || issilicon(M) || isobserver(M) || M.stat == DEAD)
		return
	M.water_act(100, temperature, src)//leave temp at 0, we handle it in the switch. oh wait
	switch(temperature) //Apply different effects based on what the temperature is set to.
		if(SCALDING) //Burn the mob.
			to_chat(M, "<span class='danger'>The water is searing hot!</span>")

		if(WARM) //Warm the mob.
			if(prob(5)) //inform the mob of warm water occasionally
				to_chat(M, "<span class='warning'>The water is quite warm.</span>")//Inform the mob it's warm water.

		if(COOL) //Cool the mob.
			if(prob(5)) //inform the mob of cold water occasionally
				to_chat(M, "<span class='warning'>The water is chilly.</span>")//Inform the mob it's chilly water.

		if(FRIGID) //YOU'RE AS COLD AS ICE
			to_chat(M, "<span class='danger'>The water is freezing!</span>")

/obj/machinery/poolcontroller/proc/handleDrowning(var/mob/living/carbon/human/drownee)
	if(!drownee)
		return

	if(drownee && ((drownee.lying && !drownee.player_logged) || deep_water)) //Mob lying down and not SSD or water is deep (determined by controller)
		if(drownee.internal)
			return //Has internals, no drowning
		if((NO_BREATHE in drownee.dna.species.species_traits) || (BREATHLESS in drownee.mutations))
			return //doesn't breathe, no drowning
		if(HAS_TRAIT(drownee,TRAIT_WATERBREATH))
			return //fish things don't drown

		if(drownee.stat == DEAD)	//Dead spacemen don't drown more
			return
		if(drownee.losebreath > 20)	//You've probably got bigger problems than drowning at this point, so we won't add to it until you get that under control.
			return

		add_attack_logs(src, drownee, "Drowned", isLivingSSD(drownee) ? null : ATKLOG_ALL)
		if(drownee.stat) //Mob is in critical.
			drownee.AdjustLoseBreath(3, bound_lower = 0, bound_upper = 20)
			drownee.visible_message("<span class='danger'>\The [drownee] appears to be drowning!</span>","<span class='userdanger'>You're quickly drowning!</span>") //inform them that they are fucked.
		else
			drownee.AdjustLoseBreath(2, bound_lower = 0, bound_upper = 20)		//For every time you drown, you miss 2 breath attempts. Hope you catch on quick!
			if(prob(35)) //35% chance to tell them what is going on. They should probably figure it out before then.
				drownee.visible_message("<span class='danger'>\The [drownee] flails, almost like [drownee.p_they()] [drownee.p_are()] drowning!</span>","<span class='userdanger'>You're lacking air!</span>") //*gasp* *gasp* *gasp* *gasp* *gasp*



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
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "poolcontroller.tmpl", "Pool Controller Interface", 520, 410)
		ui.open()

/obj/machinery/poolcontroller/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	var/currenttemp
	switch(temperature) //So we can output nice things like "Cool" to nanoUI
		if(FRIGID)
			currenttemp = "frigid"
		if(COOL)
			currenttemp = "cool"
		if(NORMAL)
			currenttemp = "normal"
		if(WARM)
			currenttemp = "warm"
		if(SCALDING)
			currenttemp = "scalding"
	data["currentTemp"] = currenttemp
	data["emagged"] = emagged
	data["TempColor"] = temperaturecolor

	return data


/obj/machinery/poolcontroller/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["temp"])
		if("Scalding")
			if(!emagged)
				return 0
			temperature = SCALDING
			temperaturecolor = "#FF0000"
			miston()
		if("Frigid")
			if(!emagged)
				return 0
			temperature = FRIGID
			temperaturecolor = "#00CCCC"
			mistoff()
		if("Warm")
			temperature = WARM
			temperaturecolor = "#990000"
			mistoff()
		if("Cool")
			temperature = COOL
			temperaturecolor = "#009999"
			mistoff()
		if("Normal")
			temperature = NORMAL
			temperaturecolor = ""
			mistoff()

	return 1

#undef FRIGID
#undef COOL
#undef NORMAL
#undef WARM
#undef SCALDING
