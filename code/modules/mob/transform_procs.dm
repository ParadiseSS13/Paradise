/mob/living/carbon/human/proc/monkeyize()
	var/mob/H = src
	H.dna.SetSEState(MONKEYBLOCK,1)
	domutcheck(H, null)

/*
/mob/living/carbon/human/proc/monkeyize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		if (W==w_uniform) // will be torn
			continue
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	stunned = 1
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	//animation = null

	if(!species.primitive) //If the creature in question has no primitive set, this is going to be messy.
		gib()
		return

	var/mob/living/carbon/monkey/O = null

	O = new species.primitive(loc)

	O.dna = dna.Clone()
	O.dna.SetSEState(MONKEYBLOCK,1)
	O.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)
	O.loc = loc
	O.viruses = viruses
	O.a_intent = "harm"


	if (client)
		client.mob = O
	if(mind)
		mind.transfer_to(O)

	O << "<B>You are now [O]. </B>"

	spawn(0)//To prevent the proc from returning null.
		del(src)
	del(animation)

	return O
*/

/mob/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/human/AIize(move=1) // 'move' argument needs defining here too because BYOND is dumb
	if (notransform)
		return
	for(var/t in organs)
		del(t)

	return ..(move)

/mob/living/carbon/AIize()
	if (notransform)
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
		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jams for AIs
	var/mob/living/silicon/ai/O = new (loc,,,1)//No MMI but safety is in effect.
	O.invisibility = 0
	O.aiRestorePowerRoutine = 0

	if(mind)
		mind.transfer_to(O)
		O.mind.original = O
	else
		O.key = key

	var/obj/loc_landmark
	for(var/obj/effect/landmark/start/sloc in landmarks_list)
		if (sloc.name != "AI")
			continue
		if (locate(/mob/living) in sloc.loc)
			continue
		loc_landmark = sloc
	if (!loc_landmark)
		for(var/obj/effect/landmark/tripai in landmarks_list)
			if (tripai.name == "tripai")
				if(locate(/mob/living) in tripai.loc)
					continue
				loc_landmark = tripai
	if (!loc_landmark)
		O << "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone."
		for(var/obj/effect/landmark/start/sloc in landmarks_list)
			if (sloc.name == "AI")
				loc_landmark = sloc

	O.loc = loc_landmark.loc
	for (var/obj/item/device/radio/intercom/comm in O.loc)
		comm.ai += O

	O.on_mob_init()

	O.add_ai_verbs()

	O.rename_self("ai",1)
	. = O
	qdel(src)

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

	if (should_gib)
		spawn(0)
			src.gib() // gib the body
	else
		spawn(0)//To prevent the proc from returning null.
			src.visible_message( \
				"[src] disappears into the shadows, never to be seen again.", \
				"You disappear into the shadows, never to be seen again.", \
				"You hear strange noise, you can't quite place it.")
			del(src)

	new_spirit << "<font color=\"purple\"><b><i>You are a Mask of Nar'sie now. You are a tiny fragment of the unknowable entity that is the god.</b></i></font>"
	new_spirit << "<font color=\"purple\"><b><i>Your job is to help your acolytes complete their goals. Be spooky. Do evil.</b></i></font>"

	new_spirit.set_name()

	// let spirits identify cultists
	if(ticker.mode)
		ticker.mode.reset_cult_icons_for_spirit(new_spirit)

	// highlander test
	there_can_be_only_one_mask(new_spirit)

	return new_spirit


//human -> robot
/mob/living/carbon/human/proc/Robotize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)
	for(var/i in internal_organs)
		del(i)

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

	if(O.mind.assigned_role == "Cyborg")
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
		del(src)
	return O

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(loc)

	new_xeno.a_intent = "harm"
	new_xeno.key = key

	new_xeno << "<B>You are now an alien.</B>"
	new_xeno.update_pipe_vision()
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return

/mob/living/carbon/human/proc/slimeize(adult as num, reproduce as num)
	if (notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)

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

	new_slime << "<B>You are now a slime. Skreee!</B>"
	new_slime.update_pipe_vision()
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return

/mob/living/carbon/human/proc/corgize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)	//this really should not be necessary
		del(t)

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (loc)
	new_corgi.a_intent = "harm"
	new_corgi.key = key

	new_corgi << "<B>You are now a Corgi. Yap Yap!</B>"
	new_corgi.update_pipe_vision()
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		usr << "\red Sorry but this mob type is currently unavailable."
		return

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
		del(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = "harm"


	new_mob << "You suddenly feel more... animalistic."
	new_mob.update_pipe_vision()
	spawn()
		del(src)
	return

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		usr << "\red Sorry but this mob type is currently unavailable."
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = "harm"
	new_mob << "You feel more... animalistic"
	new_mob.update_pipe_vision()

	del(src)

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(var/MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return 0	//Sanity, this should never happen.

	if(ispath(MP, /mob/living/simple_animal/hostile/spaceWorm))
		return 0 //Unfinished. Very buggy, they seem to just spawn additional space worms everywhere and eating your own tail results in new worms spawning.

	if(ispath(MP, /mob/living/simple_animal/construct/behemoth))
		return 0 //I think this may have been an unfinished WiP or something. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/armoured))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/wraith))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/builder))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

//Good mobs!
	if(ispath(MP, /mob/living/simple_animal/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/carp))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/mushroom))
		return 1
	if(ispath(MP, /mob/living/simple_animal/shade))
		return 1
	if(ispath(MP, /mob/living/simple_animal/tomato))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mouse))
		return 1 //It is impossible to pull up the player panel for mice (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/hostile/bear))
		return 1 //Bears will auto-attack mobs, even if they're player controlled (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/parrot))
		return 1 //Parrots are no longer unfinished! -Nodrak
	if(ispath(MP, /mob/living/simple_animal/pony))
		return 1 // ZOMG PONIES WHEEE
	if(ispath(MP, /mob/living/simple_animal/fox))
		return 1
	if(ispath(MP, /mob/living/simple_animal/chick))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pug))
		return 1
	if(ispath(MP, /mob/living/simple_animal/butterfly))
		return 1
	//Not in here? Must be untested!
	return 0


/mob/proc/safe_respawn(var/MP)
	if(!MP)
		return 0	//Sanity, this should never happen.

//Animals!
	if(ispath(MP, /mob/living/simple_animal/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/corgi))
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
	if(ispath(MP, /mob/living/simple_animal/fox))
		return 1
	if(ispath(MP, /mob/living/simple_animal/chick))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pug))
		return 1
	if(ispath(MP, /mob/living/simple_animal/butterfly))
		return 1

//Antag Creatures!
/*	if(ispath(MP, /mob/living/simple_animal/hostile/carp) && !jobban_isbanned(src, "Syndicate"))
		return 1 */
	if(ispath(MP, /mob/living/simple_animal/borer) && !jobban_isbanned(src, "alien") && !jobban_isbanned(src, "Syndicate"))
		return 1
	if(ispath(MP, /mob/living/carbon/alien) && !jobban_isbanned(src, "alien") && !jobban_isbanned(src, "Syndicate"))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/statue) && !jobban_isbanned(src, "Syndicate"))
		return 1

//Friendly Creatures!
	if(ispath(MP, /mob/living/carbon/monkey/diona) && !jobban_isbanned(src, "Dionaea"))
		return 1

	//Not in here? Must be untested!
	return 0
