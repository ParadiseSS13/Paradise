/mob/living/carbon/human/proc/monkeyize()
	var/mob/H = src
	H.dna.SetSEState(MONKEYBLOCK,1)
	domutcheck(H, null)

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
		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)// stop the jams for AIs

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

	spawn()
		qdel(src)
	return O

/mob/living/carbon/human/make_into_mask(var/should_gib = 0)
	for(var/t in organs)
		qdel(t)
	return ..(should_gib)


/mob/proc/make_into_mask(var/should_gib = 0, var/should_remove_items = 0)

	if(!should_gib)
		icon = null
		invisibility = 101

	if(!should_remove_items)
		for(var/obj/item/W in src)
			unEquip(W)

	var/mob/spirit/mask/new_spirit = new()

	if(mind)
		new_spirit.mind = mind
		new_spirit.mind.assigned_role = "Mask"
		new_spirit.mind.original = new_spirit

	new_spirit.key = key
	new_spirit.loc=loc

	if(should_gib)
		spawn(0)
			src.gib() // gib the body
	else
		spawn(0)//To prevent the proc from returning null.
			src.visible_message( \
				"[src] disappears into the shadows, never to be seen again.", \
				"You disappear into the shadows, never to be seen again.", \
				"You hear strange noise, you can't quite place it.")
			qdel(src)

	to_chat(new_spirit, "<font color=\"purple\"><b><i>You are a Mask of Nar'sie now. You are a tiny fragment of the unknowable entity that is the god.</b></i></font>")
	to_chat(new_spirit, "<font color=\"purple\"><b><i>Your job is to help your acolytes complete their goals. Be spooky. Do evil.</b></i></font>")

	new_spirit.set_name()

	// let spirits identify cultists
	if(ticker.mode)
		ticker.mode.add_cult_icon_to_spirit(new_spirit)

	// highlander test
	there_can_be_only_one_mask(new_spirit)

	return new_spirit


//human -> robot
/mob/living/carbon/human/proc/Robotize()
	if(notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		qdel(t)
	for(var/i in internal_organs)
		qdel(i)

	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot( loc )

	// cyborgs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = 7500
	O.cell.charge = 7500


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

	O.loc = loc
	O.job = "Cyborg"
	O.notify_ai(1)

	if(O.mind && O.mind.assigned_role == "Cyborg")
		if(O.mind.role_alt_title == "Android")
			O.mmi = new /obj/item/device/mmi/posibrain(O)
		else if(O.mind.role_alt_title == "Robot")
			O.mmi = null //Robots do not have removable brains.
		else
			O.mmi = new /obj/item/device/mmi(O)

		if(O.mmi) O.mmi.transfer_identity(src) //Does not transfer key/client.

	callHook("borgify", list(O))

	O.update_pipe_vision()

	O.Namepick()

	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return O

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if(notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
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

	new_xeno.a_intent = I_HARM
	new_xeno.key = key

	to_chat(new_xeno, "<B>You are now an alien.</B>")
	new_xeno.update_pipe_vision()
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return

/mob/living/carbon/human/proc/slimeize(adult as num, reproduce as num)
	if(notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		qdel(t)

	var/mob/living/carbon/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/carbon/slime/M = new/mob/living/carbon/slime(loc)
			M.nutrition = round(nutrition/number)
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		new_slime = new /mob/living/carbon/slime(loc)
		if(adult)
			new_slime.is_adult = 1
		else
	new_slime.key = key

	to_chat(new_slime, "<B>You are now a slime. Skreee!</B>")
	new_slime.update_pipe_vision()
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return

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
	for(var/t in organs)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/pet/corgi/new_corgi = new /mob/living/simple_animal/pet/corgi (loc)
	new_corgi.a_intent = I_HARM
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	new_corgi.update_pipe_vision()
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return

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

	for(var/t in organs)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = I_HARM


	to_chat(new_mob, "You suddenly feel more... animalistic.")
	new_mob.update_pipe_vision()
	spawn()
		qdel(src)
	return

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = I_HARM
	to_chat(new_mob, "You feel more... animalistic")
	new_mob.update_pipe_vision()

	qdel(src)


/mob/living/carbon/human/proc/paize(var/name)
	if(notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)	//this really should not be necessary
		qdel(t)

	var/obj/item/device/paicard/card = new(loc)
	var/mob/living/silicon/pai/pai = new(card)
	pai.key = key
	card.setPersonality(pai)

	pai.name = name
	pai.real_name = name
	card.name = name

	to_chat(pai, "<B>You have become a pAI! Your name is [pai.name].</B>")
	pai.update_pipe_vision()
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return

/mob/proc/safe_respawn(var/MP)
	if(!MP)
		return 0

	if(ispath(MP, /mob/living/simple_animal/pet/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/chicken))
		return 1
	if(ispath(MP, /mob/living/simple_animal/cow))
		return 1
	if(ispath(MP, /mob/living/simple_animal/parrot))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pony))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/fox))
		return 1
	if(ispath(MP, /mob/living/simple_animal/chick))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/pug))
		return 1
	if(ispath(MP, /mob/living/simple_animal/butterfly))
		return 1

	if(ispath(MP, /mob/living/simple_animal/borer) && !jobban_isbanned(src, ROLE_BORER) && !jobban_isbanned(src, "Syndicate"))
		return 1

	if(ispath(MP, /mob/living/simple_animal/diona) && !jobban_isbanned(src, ROLE_NYMPH))
		return 1

	return 0
