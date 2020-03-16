/*
//////////
	Item meant to spawn one of the three (Tesla / Singularity / Supermatter) engines on-station at round-start.
	Should be found in the CE's office. Not access-restricted.
//////////
*/

/obj/item/enginepicker
	name = "Bluespace Engine Delivery Device"
	desc = "A per-station bluespace-based delivery system for a unique engine Engineering Department's choice. Only one option can be chosen. Device self-destructs on use."
	icon = 'icons/obj/device.dmi'
	icon_state = "enginepicker"

	var/list/list_enginebeacons = list()
	var/isactive = FALSE

/obj/item/enginepicker/attack_self(mob/living/carbon/user)
	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(!isactive)
		isactive = TRUE	//Self-attack spam exploit prevention
	else
		return

	locatebeacons()
	var/default = null
	var/E = input("Select the station's Engine:", "[src]", default) as null|anything in list_enginebeacons
	if(E)
		processchoice(E, user)
	else
		isactive = FALSE
		return

//This proc re-assigns all of engine beacons in the global list to a local list.
/obj/item/enginepicker/proc/locatebeacons()
	LAZYCLEARLIST(list_enginebeacons)
	for(var/obj/item/radio/beacon/engine/B in GLOB.engine_beacon_list)
		if(B && !QDELETED(B))	//This ensures that the input pop-up won't have any qdeleted beacons
			list_enginebeacons += B

//Spawns and logs / announces the appropriate engine based on the choice made
/obj/item/enginepicker/proc/processchoice(var/obj/item/radio/beacon/engine/choice, mob/living/carbon/user)
	var/issuccessful = FALSE	//Check for a successful choice
	var/engtype					//Engine type
	var/G						//Generator that will be spawned
	var/turf/T = get_turf(choice)

	if(choice.enginetype.len > 1)	//If the beacon has multiple engine types
		var/default = null
		var/E = input("You have selected a combined beacon, which option would you prefer?", "[src]", default) as null|anything in choice.enginetype
		if(E)
			engtype = E
			issuccessful = TRUE
		else
			isactive = FALSE
			return

	if(!engtype)				//If it has only one type
		engtype = DEFAULTPICK(choice.enginetype, null)	//This should(?) account for a possibly scrambled list with a single entry
	switch(engtype)
		if(ENGTYPE_TESLA)
			G = /obj/machinery/the_singularitygen/tesla
		if(ENGTYPE_SING)
			G = /obj/machinery/the_singularitygen

	if(G)	//This can only be not-null if the switch operation was successful
		issuccessful = TRUE

	if(issuccessful)
		clearturf(T) 	//qdels all items / gibs all mobs on the turf. Let's not have an SM shard spawn on top of a poor sod.
		new G(T)		//Spawns the switch-selected engine on the chosen beacon's turf

		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in GLOB.living_mob_list)
			ailist += A
		if(ailist.len)
			var/mob/living/silicon/ai/announcer = pick(ailist)
			announcer.say(";Engine delivery detected. Type: [engtype].")	//Let's announce the terrible choice to everyone

		visible_message("<span class='notice'>\The [src] begins to violently vibrate and hiss, then promptly disintegrates!</span>")
		qdel(src)	//Self-destructs to prevent crew from spawning multiple engines.
	else
		visible_message("<span class='notice'>\The [src] buzzes! No beacon found or selected!</span>")
		isactive = FALSE
		return

//Deletes objects and mobs from the beacon's turf.
/obj/item/enginepicker/proc/clearturf(var/turf/T)
	for(var/obj/item/I in T)
		I.visible_message("\The [I] gets crushed to dust!")
		qdel(I)

	for(var/mob/living/M in T)
		M.visible_message("\The [M] gets obliterated!")
		M.gib()
