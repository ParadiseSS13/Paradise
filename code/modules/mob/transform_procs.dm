/mob/living/carbon/human/proc/monkeyize()
	if (!dna.GetSEState(GLOB.monkeyblock)) // Monkey block NOT present.
		dna.SetSEState(GLOB.monkeyblock,1)
		genemutcheck(src,GLOB.monkeyblock,null,MUTCHK_FORCED)

/mob/living/carbon/human/proc/is_monkeyized()
	return dna.GetSEState(GLOB.monkeyblock)

/mob/living/carbon/human/proc/humanize()
	if (dna.GetSEState(GLOB.monkeyblock)) // Monkey block present.
		dna.SetSEState(GLOB.monkeyblock,0)
		genemutcheck(src,GLOB.monkeyblock,null,MUTCHK_FORCED)

/mob/living/carbon/human/proc/is_humanized()
	return !dna.GetSEState(GLOB.monkeyblock)

/mob/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/AIize()
	if(notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	return ..()

/mob/proc/AIize()
	if(client)
		stop_sound_channel(CHANNEL_LOBBYMUSIC)

	var/mob/living/silicon/ai/O = new (loc,,,1)//No MMI but safety is in effect.
	O.invisibility = 0
	O.aiRestorePowerRoutine = 0

	if(mind)
		mind.transfer_to(O)
		O.mind.original = O
	else
		O.key = key

	O.on_mob_init()

	O.add_ai_verbs()

	O.rename_self("AI",1)

	O.tts_seed = tts_seed

	INVOKE_ASYNC(GLOBAL_PROC, .proc/qdel, src) // To prevent the proc from returning null.
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
		unEquip(W)

	notransform = 1
	canmove = 0
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
			O.mind.original = O
		else if(mind && mind.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.forceMove(loc)
	O.job = "Cyborg"

	if(O.mind && O.mind.assigned_role == "Cyborg")
		if(O.mind.role_alt_title == "Robot")
			O.mmi = new /obj/item/mmi/robotic_brain(O)
			if(O.mmi.brainmob)
				O.mmi.brainmob.name = O.name
		else
			O.mmi = new /obj/item/mmi(O)
		O.mmi.transfer_identity(src) //Does not transfer key/client.

	O.update_pipe_vision()

	O.Namepick()

	O.tts_seed = tts_seed

	INVOKE_ASYNC(GLOBAL_PROC, .proc/qdel, src) // To prevent the proc from returning null.
	return O

/mob/living/carbon/human/proc/corgize()
	if(notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
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
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)

	regenerate_icons()
	notransform = 1
	canmove = 0
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
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "You feel more... animalistic")
	new_mob.update_pipe_vision()

	qdel(src)


/mob/proc/safe_respawn(var/MP)
	if(!MP)
		return 0

	if(!GAMEMODE_IS_NUCLEAR)
		if(ispath(MP, /mob/living/simple_animal/pet/cat/Syndi))
			return 0
	if(ispath(MP, /mob/living/simple_animal/pet/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/dog/security))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/dog/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/chicken))
		return 1
	if(ispath(MP, /mob/living/simple_animal/cow))
		return 1
	if(ispath(MP, /mob/living/simple_animal/parrot))
		return 1
	if(!GAMEMODE_IS_NUCLEAR)
		if(ispath(MP, /mob/living/simple_animal/pet/dog/fox/Syndifox))
			return 0
	if(ispath(MP, /mob/living/simple_animal/pet/dog/fox/alisa))
		return 0
	if(ispath(MP, /mob/living/simple_animal/pet/dog/fox))
		return 1
	if(ispath(MP, /mob/living/simple_animal/chick))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/dog/pug))
		return 1
	if(ispath(MP, /mob/living/simple_animal/butterfly))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/penguin))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/sloth))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pig))
		return 1
	if(ispath(MP, /mob/living/simple_animal/cock))
		return 1
	if(ispath(MP, /mob/living/simple_animal/goose))
		return 1
	if(ispath(MP, /mob/living/simple_animal/turkey))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mouse/hamster))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mouse/rat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/retaliate/poison/snake/rouge))
		return 1
	if(ispath(MP, /mob/living/simple_animal/possum))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/slugcat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/frog))
		return 1

	if(ispath(MP, /mob/living/simple_animal/borer) && !jobban_isbanned(src, ROLE_BORER) && !jobban_isbanned(src, "Syndicate"))
		return 1

	if(ispath(MP, /mob/living/simple_animal/diona) && !jobban_isbanned(src, ROLE_NYMPH))
		return 1

	return 0
