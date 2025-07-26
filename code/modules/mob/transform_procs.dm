/mob/living/carbon/human/proc/monkeyize()
	var/mob/H = src
	H.dna.SetSEState(GLOB.monkeyblock, 1)
	singlemutcheck(H, GLOB.monkeyblock, MUTCHK_FORCED)

/mob/new_player/AIize()
	spawning = TRUE
	return ..()

/mob/living/carbon/AIize()
	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_to_ground(W)
	notransform = TRUE
	icon = null
	invisibility = 101
	return ..()

/mob/proc/AIize()
	if(client)
		stop_sound_channel(CHANNEL_LOBBYMUSIC)

	var/mob/living/silicon/ai/O = new (loc, null, null,1)//No MMI but safety is in effect.
	O.invisibility = 0
	O.aiRestorePowerRoutine = 0

	if(mind)
		mind.transfer_to(O)
		O.mind.set_original_mob(O)
	else
		O.key = key

	O.on_mob_init()

	O.add_ai_verbs()

	O.rename_self("AI", TRUE)

	O.blurb_it()

	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src) // To prevent the proc from returning null. Todo: Convert to QDEL_IN
	return O



/**
	For transforming humans into robots (cyborgs).

	Arguments:
	* cell_type: A type path of the cell the new borg should receive.
	* connect_to_default_AI: TRUE if you want /robot/New() to handle connecting the borg to the AI with the least borgs.
	* AI: A reference to the AI we want to connect to.
*/
/mob/living/carbon/human/proc/Robotize(cell_type = null, connect_to_default_AI = TRUE, mob/living/silicon/ai/AI = null)
	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_to_ground(W)

	notransform = TRUE
	icon = null
	invisibility = 101

	// Creating a new borg here will connect them to a default AI and notify that AI, if `connect_to_default_AI` is TRUE.
	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(loc, connect_to_AI = connect_to_default_AI)

	// If `AI` is passed in, we want to connect to that AI specifically.
	if(AI)
		O.lawupdate = TRUE
		O.connect_to_ai(AI)

	if(!cell_type)
		O.cell = new /obj/item/stock_parts/cell/high(O)
	else
		O.cell = new cell_type(O)

	O.gender = gender
	O.invisibility = 0

	if(mind)		//TODO
		mind.transfer_to(O)
		if(O.mind.assigned_role == "Cyborg")
			O.mind.set_original_mob(O)
		else if(mind && mind.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.forceMove(loc)
	O.job = "Cyborg"

	if(O.mind && O.mind.assigned_role == "Cyborg")
		var/obj/item/mmi/new_mmi
		switch(O.client.prefs.active_character.cyborg_brain_type)
			if(ROBOBRAIN_BORG)
				new_mmi = new /obj/item/mmi/robotic_brain(O)
				if(new_mmi.brainmob)
					new_mmi.brainmob.name = O.name
			if(MMI_BORG)
				new_mmi = new /obj/item/mmi(O)
			if(POSITRONIC_BORG)
				new_mmi = new /obj/item/mmi/robotic_brain/positronic(O)
				if(new_mmi.brainmob)
					new_mmi.brainmob.name = O.name
			else
				// This should never happen, but oh well
				new_mmi = new /obj/item/mmi(O)
		new_mmi.transfer_identity(src) //Does not transfer key/client.
		// Replace the MMI.
		QDEL_NULL(O.mmi)
		O.mmi = new_mmi

	O.update_pipe_vision()

	O.check_custom_sprite()
	O.Namepick()

	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src) // To prevent the proc from returning null. Todo: Convert to QDEL_IN
	return O

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_to_ground(W)
	regenerate_icons()
	notransform = TRUE
	icon = null
	invisibility = 101
	for(var/t in bodyparts)
		qdel(t)

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(loc)

	new_xeno.a_intent = INTENT_HARM
	new_xeno.key = key

	to_chat(new_xeno, "<B>You are now an alien.</B>")
	new_xeno.update_pipe_vision()
	qdel(src)

/mob/living/carbon/human/proc/slimeize(reproduce as num)
	if(notransform)
		return
	notransform = TRUE
	for(var/obj/item/I in src)
		drop_item_to_ground(I)
	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)
		qdel(t)

	var/mob/living/simple_animal/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/simple_animal/slime/M = new/mob/living/simple_animal/slime(loc)
			M.set_nutrition(round(nutrition / number))
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		new_slime = new /mob/living/simple_animal/slime(loc)
	new_slime.a_intent = INTENT_HARM
	new_slime.key = key

	to_chat(new_slime, "<B>You are now a slime. Skreee!</B>")
	new_slime.update_pipe_vision()
	. = new_slime
	qdel(src)

/mob/living/carbon/human/proc/corgize()
	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_to_ground(W)
	regenerate_icons()
	notransform = TRUE
	icon = null
	invisibility = 101
	for(var/t in bodyparts)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/pet/dog/corgi/new_corgi = new /mob/living/simple_animal/pet/dog/corgi (loc)
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	new_corgi.update_pipe_vision()
	qdel(src)

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = tgui_input_list(usr, "Which type of mob should [src] turn into?", "Choose a Type", mobtypes)

	if(!mobpath)
		return

	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_to_ground(W)

	regenerate_icons()
	notransform = TRUE
	icon = null
	invisibility = 101

	for(var/t in bodyparts)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "You suddenly feel more... animalistic.")
	new_mob.update_pipe_vision()
	qdel(src)

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	mobtypes |= subtypesof(/mob/living/basic)
	var/mobpath = tgui_input_list(usr, "Which type of mob should [src] turn into?", "Choose a Type", mobtypes)

	if(!mobpath)
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "You feel more... animalistic")
	new_mob.update_pipe_vision()
	qdel(src)


/mob/living/carbon/human/proc/paize(name)
	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_item_to_ground(W)
	regenerate_icons()
	notransform = TRUE
	icon = null
	invisibility = 101
	for(var/t in bodyparts)	//this really should not be necessary
		qdel(t)

	var/obj/item/paicard/card = new(loc)
	var/mob/living/silicon/pai/pai = new(card)
	pai.key = key
	card.setPersonality(pai)

	pai.name = name
	pai.real_name = name
	card.name = name

	to_chat(pai, "<B>You have become a pAI! Your name is [pai.name].</B>")
	pai.update_pipe_vision()
	qdel(src)

/mob/living/carbon/proc/gorillize(rage = FALSE)
	if(notransform)
		return

	if(stat == DEAD)
		return

	for(var/obj/item/W in get_all_slots())
		drop_item_to_ground(W)

	regenerate_icons()
	notransform = TRUE
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	visible_message("<span class='warning'>[src] transforms into a gorilla!</span>", "<span class='warning'>You transform into a gorilla! Ooga ooga!</span>", "<span class='warning'>You hear a loud roar!</span>")
	var/mob/living/basic/gorilla/new_gorilla
	if(rage)
		var/mob/living/basic/gorilla/rampaging/rampaging_gorilla = new (get_turf(src))
		new_gorilla = rampaging_gorilla
	else
		new_gorilla = new (get_turf(src))

	playsound(new_gorilla, 'sound/creatures/gorilla.ogg', 50)

	if(mind)
		mind.transfer_to(new_gorilla)
	else
		new_gorilla.key = key

	qdel(src)
