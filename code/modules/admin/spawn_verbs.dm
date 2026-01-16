USER_VERB(create_crate, R_SPAWN, "Create Crate", \
		"Spawn a crate from a supplypack datum. Append a period to the text in order to exclude subtypes of paths matching the input.", \
		VERB_CATEGORY_EVENT,
		object as text)
	var/list/types = SSeconomy.supply_packs
	var/list/matches = list()

	var/include_subtypes = TRUE
	if(copytext(object, -1) == ".")
		include_subtypes = FALSE
		object = copytext(object, 1, -1)

	if(include_subtypes)
		for(var/path in types)
			if(findtext("[path]", object))
				matches += path
	else
		var/needle_length = length(object)
		for(var/path in types)
			if(copytext("[path]", -needle_length) == object)
				matches += path

	if(!length(matches))
		return

	var/chosen = input(client, "Select a supply crate type", "Create Crate", matches[1]) as null|anything in matches
	if(!chosen)
		return
	var/datum/supply_packs/the_pack = new chosen()

	var/spawn_location = get_turf(client.mob)
	if(!spawn_location)
		return
	var/obj/structure/closet/crate/crate = the_pack.create_package(spawn_location)
	crate.admin_spawned = TRUE
	for(var/atom/A in crate.contents)
		A.admin_spawned = TRUE
	qdel(the_pack)

	log_admin("[key_name(client)] created a '[chosen]' crate at ([COORD(client.mob)])")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Create Crate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/// If a guy was gibbed and you want to revive him, this is a good way to do so.
/// Works kind of like entering the game with a new character. Character
/// receives a new mind if they didn't have one. Traitors and the like can also
/// be revived with the previous role mostly intact.
USER_VERB(respawn_character, R_SPAWN, "Respawn Character", \
		"Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into.", \
		VERB_CATEGORY_EVENT)
	var/input = ckey(input(client, "Please specify which key will be respawned.", "Key", ""))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(client, "<font color='red'>There is no active key like that in the game or the person is not currently a ghost.</font>")
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		//Check if they were an alien
		if(G_found.mind.assigned_role=="Alien")
			if(alert(client, "This character appears to have been an alien. Would you like to respawn them as such?", null,"Yes","No")=="Yes")
				var/turf/T
				if(length(GLOB.xeno_spawn))	T = pick(GLOB.xeno_spawn)
				else				T = pick(GLOB.latejoin)

				var/mob/living/carbon/alien/new_xeno
				switch(G_found.mind.special_role)//If they have a mind, we can determine which caste they were.
					if("Hunter")	new_xeno = new /mob/living/carbon/alien/humanoid/hunter(T)
					if("Sentinel")	new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(T)
					if("Drone")		new_xeno = new /mob/living/carbon/alien/humanoid/drone(T)
					if("Queen")		new_xeno = new /mob/living/carbon/alien/humanoid/queen(T)
					else//If we don't know what special role they have, for whatever reason, or they're a larva.
						create_xeno(G_found.ckey)
						return

				//Now to give them their mind back.
				G_found.mind.transfer_to(new_xeno)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_xeno.key = G_found.key
				to_chat(new_xeno, "You have been fully respawned. Enjoy the game.")
				message_admins(SPAN_NOTICE("[key_name_admin(client)] has respawned [new_xeno.key] as a filthy xeno."), 1)
				return	//all done. The ghost is auto-deleted

	var/mob/living/carbon/human/new_character = new(pick(GLOB.latejoin))//The mob being spawned.

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")
		for(var/datum/data/record/t in GLOB.data_core.locked)
			if(t.fields["id"]==id)
				record_found = t//We shall now reference the record.
				break

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.change_gender(record_found.fields["sex"])
		new_character.age = record_found.fields["age"]
		new_character.dna.blood_type = record_found.fields["blood_type"]
	else
		// We make a random character
		new_character.change_gender(pick(MALE,FEMALE))
		var/datum/character_save/S = new
		S.randomise()
		S.real_name = G_found.real_name
		S.copy_to(new_character)

	if(!new_character.real_name)
		new_character.real_name = random_name(new_character.gender)
	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
		new_character.mind.special_verbs = list()
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)	new_character.mind.assigned_role = "Assistant" //If they somehow got a null assigned role.

	//DNA
	if(record_found)//Pull up their name from database records if they did have a mind.
		new_character.dna = new()//Let's first give them a new DNA.
		new_character.dna.unique_enzymes = record_found.fields["b_dna"]//Enzymes are based on real name but we'll use the record for conformity.

		// I HATE BYOND.  HATE.  HATE. - N3X
		var/list/newSE= record_found.fields["enzymes"]
		var/list/newUI = record_found.fields["identity"]
		new_character.dna.SE = newSE.Copy() //This is the default of enzymes so I think it's safe to go with.
		new_character.dna.UpdateSE()
		new_character.UpdateAppearance(newUI.Copy())//Now we configure their appearance based on their unique identity, same as with a DNA machine or somesuch.
	else//If they have no records, we just do a random DNA for them, based on their random appearance/savefile.
		new_character.dna.ready_dna(new_character)

	new_character.key = G_found.key

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Now for special roles and equipment.
	switch(new_character.mind.special_role)
		if("traitor")
			if(new_character.mind.has_antag_datum(/datum/antagonist/traitor))
				var/datum/antagonist/traitor/T = new_character.mind.has_antag_datum(/datum/antagonist/traitor)
				T.give_uplink()
			else
				new_character.mind.add_antag_datum(/datum/antagonist/traitor)
		if("Wizard")
			new_character.forceMove(pick(GLOB.wizardstart))
			//ticker.mode.learn_basic_spells(new_character)
			var/datum/antagonist/wizard/wizard = new_character.mind.has_antag_datum(/datum/antagonist/wizard)
			if(istype(wizard))
				wizard.equip_wizard()
		if("Syndicate")
			var/obj/effect/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
			if(synd_spawn)
				new_character.loc = get_turf(synd_spawn)
			call(TYPE_PROC_REF(/datum/game_mode, equip_syndicate))(new_character)

		if("Deathsquad Commando")//Leaves them at late-join spawn.
			new_character.equip_deathsquad_commando()
			new_character.update_action_buttons_icon()
		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if("Cyborg")//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize()
					if(new_character.mind.special_role=="traitor")
						new_character.mind.add_antag_datum(/datum/antagonist/traitor)
				if("AI")
					new_character = new_character.AIize()
					var/mob/living/silicon/ai/ai_character = new_character
					ai_character.moveToAILandmark()
					if(new_character.mind.special_role=="traitor")
						new_character.mind.add_antag_datum(/datum/antagonist/traitor)
				//Add aliens.
				else
					SSjobs.AssignRank(new_character, new_character.mind.assigned_role, FALSE)
					SSjobs.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found && new_character.mind.assigned_role != new_character.mind.special_role)//If there are no records for them. If they have a record, this info is already in there. Offstation special characters announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?", null,"No","Yes")=="Yes")
				GLOB.data_core.manifest_inject(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?", null,"No","Yes")=="Yes")
				call(TYPE_PROC_REF(/mob/new_player, AnnounceArrival))(new_character, new_character.mind.assigned_role)

	message_admins(SPAN_NOTICE("[key_name_admin(client)] has respawned [key_name_admin(G_found)] as [new_character.real_name]."), 1)

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Respawn Character") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

USER_VERB(spawn_atom, R_SPAWN, "Spawn", \
		"Spawn an atom. Append a period to the text in order to exclude subtypes of paths matching the input.", \
		VERB_CATEGORY_DEBUG, object as text)
	if(!object)
		return

	var/list/types = typesof(/atom)
	var/list/matches = list()

	var/include_subtypes = TRUE
	if(copytext(object, -1) == ".")
		include_subtypes = FALSE
		object = copytext(object, 1, -1)

	if(include_subtypes)
		for(var/path in types)
			if(findtext("[path]", object))
				matches += path
	else
		var/needle_length = length(object)
		for(var/path in types)
			if(copytext("[path]", -needle_length) == object)
				matches += path

	if(length(matches)==0)
		return

	var/chosen
	if(length(matches)==1)
		chosen = matches[1]
	else
		chosen = tgui_input_list(client, "Select an Atom Type", "Spawn Atom", matches)
		if(!chosen)
			return

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(client.mob.loc)
		T.ChangeTurf(chosen)
	else
		var/atom/A = new chosen(client.mob.loc)
		A.admin_spawned = TRUE

	log_admin("[key_name(client)] spawned [chosen] at ([client.mob.x],[client.mob.y],[client.mob.z])")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Atom") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(admin_robotize, R_SPAWN, "Make Robot", "Turn the target into a borg.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(client)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert(client, "Invalid mob")

USER_VERB(admin_animalize, R_SPAWN, "Make Simple Animal", "Turn the target into a simple animal.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return

	if(!M)
		alert(client, "That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		alert(client, "The mob must not be a new_player.")
		return

	log_admin("[key_name(client)] has animalized [M.key].")
	spawn(10)
		M.Animalize()

USER_VERB(admin_make_pai, R_SPAWN, "Make pAI", "Specify a location to spawn a pAI device, then specify a key to play that pAI", VERB_CATEGORY_EVENT, turf/T in GLOB.mob_list)
	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input(client, "Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!isobserver(choice))
		var/confirm = input(client, "[choice.key] isn't ghosting right now. Are you sure you want to yank [choice.p_them()] out of [choice.p_their()] body and place [choice.p_them()] in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	var/raw_name = clean_input("Enter your pAI name:", "pAI Name", "Personal AI", choice, user = client)
	var/new_name = reject_bad_name(raw_name, 1)
	if(new_name)
		pai.name = new_name
		pai.real_name = new_name
	else
		to_chat(client, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/pai_save/candidate in GLOB.paiController.pai_candidates)
		if(candidate.owner.ckey == choice.ckey)
			GLOB.paiController.pai_candidates.Remove(candidate)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make pAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(admin_alienize, R_SPAWN, "Make Alien", "Turn the target mob into an alien.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(client)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Alien") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(client)] made [key_name(M)] into an alien.")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] made [key_name(M)] into an alien."), 1)
	else
		alert(client, "Invalid mob")

USER_VERB(admin_slimezie, R_SPAWN, "Make slime", "Turn the target mob into a slime.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(client)] has slimeized [M.key].")
		spawn(10)
			M:slimeize()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Slime") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(client)] made [key_name(M)] into a slime.")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] made [key_name(M)] into a slime."), 1)
	else
		alert(client, "Invalid mob")

USER_VERB(admin_super, R_SPAWN, "Make Superhero", "Turn the target mob into a superhero.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return
	if(ishuman(M))
		var/type = input(client, "Pick the Superhero","Superhero") as null|anything in GLOB.all_superheroes
		var/datum/superheroes/S = GLOB.all_superheroes[type]
		if(S)
			S.create(M)
		log_admin("[key_name(client)] has turned [M.key] into a Superhero.")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] made [key_name(M)] into a Superhero."), 1)
	else
		alert(client, "Invalid mob")
