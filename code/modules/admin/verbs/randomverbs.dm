/client/proc/cmd_admin_drop_everything(mob/M as mob in GLOB.mob_list)
	set category = null
	set name = "Drop Everything"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		M.unEquip(W)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Everything") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_prison(mob/M as mob in GLOB.mob_list)
	set category = "Admin"
	set name = "Prison"

	if(!check_rights(R_ADMIN))
		return

	if(ismob(M))
		if(istype(M, /mob/living/silicon/ai))
			alert("The AI can't be sent to prison you jerk!", null, null, null, null, null)
			return
		//strip their stuff before they teleport into a cell :downs:
		for(var/obj/item/W in M)
			M.unEquip(W)
		//teleport person to cell
		M.Paralyse(5)
		sleep(5)	//so they black out before warping
		M.loc = pick(GLOB.prisonwarp)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), slot_w_uniform)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)
		spawn(50)
			to_chat(M, "<span class='warning'>You have been sent to the prison station!</span>")
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("<span class='notice'>[key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.</span>", 1)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Prison") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M as mob in GLOB.mob_list)
	set category = "Event"
	set name = "Subtle Message"

	if(!ismob(M))
		return

	if(!check_rights(R_EVENT))
		return

	var/msg = clean_input("Message:", text("Subtle PM to [M.key]"))

	if(!msg)
		return

	msg = admin_pencode_to_html(msg)

	if(usr)
		if(usr.client)
			if(usr.client.holder)
				to_chat(M, "<b>You hear a voice in your head... <i>[msg]</i></b>")

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	message_admins("<span class='boldnotice'>SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] : [msg]</span>", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Subtle Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mentor_check_new_players()	//Allows mentors / admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check new Players"

	if(!check_rights(R_MENTOR|R_MOD|R_ADMIN))
		return

	var/age = alert(src, "Age check", "Show accounts yonger then _____ days","7", "30" , "All")

	if(age == "All")
		age = 9999999
	else
		age = text2num(age)

	var/missing_ages = 0
	var/msg = ""
	for(var/client/C in GLOB.clients)
		if(C.player_age == "Requires database")
			missing_ages = 1
			continue
		if(C.player_age < age)
			if(check_rights(R_ADMIN, 0))
				msg += "[key_name_admin(C.mob)]: [C.player_age] days old<br>"
			else
				msg += "[key_name_mentor(C.mob)]: [C.player_age] days old<br>"

	if(missing_ages)
		to_chat(src, "Some accounts did not have proper ages set in their clients.  This function requires database to be present")

	if(msg != "")
		src << browse({"<meta charset="UTF-8">"}+msg, "window=Player_age_check")
	else
		to_chat(src, "No matches for that age range found.")


/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Event"
	set name = "Global Narrate"

	if(!check_rights(R_SERVER|R_EVENT))
		return

	var/msg = clean_input("Message:", text("Enter the text you wish to appear to everyone:"))

	if(!msg)
		return
	msg = admin_pencode_to_html(msg)
	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("<span class='boldnotice'>GlobalNarrate: [key_name_admin(usr)]: [msg]<BR></span>", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Global Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(var/mob/M)	// Targetted narrate -- TLE
	set category = null
	set name = "Direct Narrate"

	if(!check_rights(R_SERVER|R_EVENT))
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in get_mob_with_client_list()

	if(!M)
		return

	var/msg = clean_input("Message:", text("Enter the text you wish to appear to your target:"))

	if( !msg )
		return
	msg = admin_pencode_to_html(msg)

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([key_name(M)]): [msg]")
	message_admins("<span class='boldnotice'>DirectNarrate: [key_name_admin(usr)] to ([key_name_admin(M)]): [msg]<BR></span>", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Direct Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!




/client/proc/cmd_admin_headset_message(mob/M in GLOB.mob_list)
	set category = "Event"
	set name = "Headset Message"

	admin_headset_message(M)

/client/proc/admin_headset_message(mob/M in GLOB.mob_list, sender = null)
	var/mob/living/carbon/human/H = M

	if(!check_rights(R_EVENT))
		return

	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
		return
	if(!istype(H.l_ear, /obj/item/radio/headset) && !istype(H.r_ear, /obj/item/radio/headset))
		to_chat(usr, "The person you are trying to contact is not wearing a headset")
		return

	if(!sender)
		sender = input("Who is the message from?", "Sender") as null|anything in list("Centcomm", "Syndicate")
		if(!sender)
			return

	message_admins("[key_name_admin(src)] has started answering [key_name_admin(H)]'s [sender] request.")
	var/input = clean_input("Please enter a message to reply to [key_name(H)] via their headset.", "Outgoing message from [sender]", "")
	if(!input)
		message_admins("[key_name_admin(src)] decided not to answer [key_name_admin(H)]'s [sender] request.")
		return

	log_admin("[key_name(src)] replied to [key_name(H)]'s [sender] message with the message [input].")
	message_admins("[key_name_admin(src)] replied to [key_name_admin(H)]'s [sender] message with: \"[input]\"")
	to_chat(H, "<span class = 'specialnoticebold'>Incoming priority transmission from [sender == "Syndicate" ? "your benefactor" : "Central Command"].  Message as follows[sender == "Syndicate" ? ", agent." : ":"]</span><span class = 'specialnotice'> [input]</span>")




/client/proc/cmd_admin_godmode(mob/M as mob in GLOB.mob_list)
	set category = "Admin"
	set name = "Godmode"

	if(!check_rights(R_ADMIN))
		return

	M.status_flags ^= GODMODE
	to_chat(usr, "<span class='notice'>Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]</span>")

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Godmode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
	if(automute)
		if(!config.automute_on)
			return
	else
		if(!usr || !usr.client)
			return
		if(!check_rights(R_ADMIN|R_MOD))
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: You don't have permission to do this.</font>")
			return
		if(!M.client)
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: This mob doesn't have a client tied to it.</font>")
	if(!M.client)
		return

	var/muteunmute
	var/mute_string

	switch(mute_type)
		if(MUTE_IC)			mute_string = "IC (say and emote)"
		if(MUTE_OOC)		mute_string = "OOC"
		if(MUTE_PRAY)		mute_string = "pray"
		if(MUTE_ADMINHELP)	mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_DEADCHAT)	mute_string = "deadchat and DSAY"
		if(MUTE_ALL)		mute_string = "everything"
		else				return

	if(automute)
		muteunmute = "auto-muted"
		M.client.prefs.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(M)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
		to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Automute") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	if(M.client.prefs.muted & mute_type)
		muteunmute = "unmuted"
		M.client.prefs.muted &= ~mute_type
	else
		muteunmute = "muted"
		M.client.prefs.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(M)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
	to_chat(M, "You have been [muteunmute] from [mute_string].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mute") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_add_random_ai_law()
	set category = "Event"
	set name = "Add Random AI Law"

	if(!check_rights(R_EVENT))
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	log_admin("[key_name(src)] has added a random AI law.")
	message_admins("[key_name_admin(src)] has added a random AI law.")

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	new /datum/event/ion_storm(0, announce_ion_laws)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Random AI Law") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_antagHUD_use()
	set category = "Server"
	set name = "Toggle antagHUD usage"
	set desc = "Toggles antagHUD usage for observers"

	if(!check_rights(R_SERVER))
		return

	var/action=""
	if(config.antag_hud_allowed)
		for(var/mob/dead/observer/g in get_ghosts())
			if(!g.client.holder)						//Remove the verb from non-admin ghosts
				g.verbs -= /mob/dead/observer/verb/toggle_antagHUD
			if(g.antagHUD)
				g.antagHUD = FALSE						// Disable it on those that have it enabled
				g.has_enabled_antagHUD = 2				// We'll allow them to respawn
				to_chat(g, "<span class='danger'>The Administrator has disabled AntagHUD </span>")
		config.antag_hud_allowed = 0
		to_chat(src, "<span class='danger'>AntagHUD usage has been disabled</span>")
		action = "disabled"
	else
		for(var/mob/dead/observer/g in get_ghosts())
			if(!g.client.holder)						// Add the verb back for all non-admin ghosts
				g.verbs += /mob/dead/observer/verb/toggle_antagHUD
				to_chat(g, "<span class='boldnotice'>The Administrator has enabled AntagHUD </span>")// Notify all observers they can now use AntagHUD

		config.antag_hud_allowed = 1
		action = "enabled"
		to_chat(src, "<span class='boldnotice'>AntagHUD usage has been enabled</span>")


	log_admin("[key_name(usr)] has [action] antagHUD usage for observers")
	message_admins("Admin [key_name_admin(usr)] has [action] antagHUD usage for observers", 1)

/client/proc/toggle_antagHUD_restrictions()
	set category = "Server"
	set name = "Toggle antagHUD Restrictions"
	set desc = "Restricts players that have used antagHUD from being able to join this round."

	if(!check_rights(R_SERVER))
		return

	var/action=""
	if(config.antag_hud_restricted)
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='boldnotice'>The administrator has lifted restrictions on joining the round if you use AntagHUD</span>")
		action = "lifted restrictions"
		config.antag_hud_restricted = 0
		to_chat(src, "<span class='boldnotice'>AntagHUD restrictions have been lifted</span>")
	else
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='danger'>The administrator has placed restrictions on joining the round if you use AntagHUD</span>")
			to_chat(g, "<span class='danger'>Your AntagHUD has been disabled, you may choose to re-enabled it but will be under restrictions </span>")
			g.antagHUD = FALSE
			g.has_enabled_antagHUD = 0
		action = "placed restrictions"
		config.antag_hud_restricted = 1
		to_chat(src, "<span class='danger'>AntagHUD restrictions have been enabled</span>")

	log_admin("[key_name(usr)] has [action] on joining the round if they use AntagHUD")
	message_admins("Admin [key_name_admin(usr)] has [action] on joining the round if they use AntagHUD", 1)

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Event"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."

	if(!check_rights(R_SPAWN))
		return

	var/input = ckey(input(src, "Please specify which key will be respawned.", "Key", ""))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<font color='red'>There is no active key like that in the game or the person is not currently a ghost.</font>")
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		//Check if they were an alien
		if(G_found.mind.assigned_role=="Alien")
			if(alert("This character appears to have been an alien. Would you like to respawn them as such?",,"Yes","No")=="Yes")
				var/turf/T
				if(GLOB.xeno_spawn.len)	T = pick(GLOB.xeno_spawn)
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
				message_admins("<span class='notice'>[key_name_admin(usr)] has respawned [new_xeno.key] as a filthy xeno.</span>", 1)
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
		new_character.change_gender(pick(MALE,FEMALE))
		var/datum/preferences/A = new()
		A.real_name = G_found.real_name
		A.copy_to(new_character)

	if(!new_character.real_name)
		new_character.real_name = random_name(new_character.gender)
	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
		new_character.mind.special_verbs = list()
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)	new_character.mind.assigned_role = "Civilian"//If they somehow got a null assigned role.

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
				T.equip_traitor(src)
			else
				new_character.mind.add_antag_datum(/datum/antagonist/traitor)
		if("Wizard")
			new_character.loc = pick(GLOB.wizardstart)
			//ticker.mode.learn_basic_spells(new_character)
			SSticker.mode.equip_wizard(new_character)
		if("Syndicate")
			var/obj/effect/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
			if(synd_spawn)
				new_character.loc = get_turf(synd_spawn)
			call(/datum/game_mode/proc/equip_syndicate)(new_character)

		if("Death Commando")//Leaves them at late-join spawn.
			new_character.equip_death_commando()
			new_character.internal = new_character.s_store
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
					SSjobs.AssignRank(new_character, new_character.mind.assigned_role, 0)
					SSjobs.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found && new_character.mind.assigned_role != new_character.mind.special_role)//If there are no records for them. If they have a record, this info is already in there. Offstation special characters announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
				GLOB.data_core.manifest_inject(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
				call(/mob/new_player/proc/AnnounceArrival)(new_character, new_character.mind.assigned_role)

	message_admins("<span class='notice'>[key_name_admin(usr)] has respawned [key_name_admin(G_found)] as [new_character.real_name].</span>", 1)

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Respawn Character") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in GLOB.player_list)
			if(M.stat != DEAD)		continue	//we are not dead!
			if(!(ROLE_ALIEN in M.client.prefs.be_special))	continue	//we don't want to be an alium
			if(jobban_isbanned(M, "alien") || jobban_isbanned(M, "Syndicate")) continue //we are jobbanned
			if(M.client.is_afk())	continue	//we are afk
			if(M.mind && M.mind.current && M.mind.current.stat != DEAD)	continue	//we have a live body we are tied to
			candidates += M.ckey
		if(candidates.len)
			ckey = input("Pick the player you want to respawn as a xeno.", "Suitable Candidates") as null|anything in candidates
		else
			to_chat(usr, "<font color='red'>Error: create_xeno(): no suitable candidates.</font>")
	if(!istext(ckey))	return 0

	var/alien_caste = input(usr, "Please choose which caste to spawn.","Pick a caste",null) as null|anything in list("Queen","Hunter","Sentinel","Drone","Larva")
	var/obj/effect/landmark/spawn_here = GLOB.xeno_spawn.len ? pick(GLOB.xeno_spawn) : pick(GLOB.latejoin)
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Queen")		new_xeno = new /mob/living/carbon/alien/humanoid/queen/large(spawn_here)
		if("Hunter")	new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Sentinel")	new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Drone")		new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larva")		new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else			return 0

	new_xeno.ckey = ckey
	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned [ckey] as a filthy xeno [alien_caste].</span>", 1)
	return 1


/client/proc/get_ghosts(var/notify = 0,var/what = 2)
	// what = 1, return ghosts ass list.
	// what = 2, return mob list

	var/list/mobs = list()
	var/list/ghosts = list()
	var/list/sortmob = sortAtom(GLOB.mob_list)                           // get the mob list.
	var/any=0
	for(var/mob/dead/observer/M in sortmob)
		mobs.Add(M)                                             //filter it where it's only ghosts
		any = 1                                                 //if no ghosts show up, any will just be 0
	if(!any)
		if(notify)
			to_chat(src, "There doesn't appear to be any ghosts for you to select.")
		return

	for(var/mob/M in mobs)
		var/name = M.name
		ghosts[name] = M                                        //get the name of the mob for the popup list
	if(what==1)
		return ghosts
	else
		return mobs

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Event"
	set name = "Add Custom AI law"

	if(!check_rights(R_EVENT))
		return

	var/input = clean_input("Please enter anything you want the AI to do. Anything. Serious.", "What?", "")
	if(!input)
		return

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]")

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	new /datum/event/ion_storm(0, announce_ion_laws, input)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Custom AI Law") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M as mob in GLOB.mob_list)
	set category = null
	set name = "Rejuvenate"

	if(!check_rights(R_REJUVINATE))
		return

	if(!mob)
		return
	if(!istype(M))
		alert("Cannot revive a ghost")
		return
	M.revive()

	log_admin("[key_name(usr)] healed / revived [key_name(M)]")
	message_admins("<span class='warning'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!</span>", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Rejuvenate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Event"
	set name = "Create Communications Report"

	if(!check_rights(R_SERVER|R_EVENT))
		return

//the stuff on the list is |"report type" = "report title"|, if that makes any sense
	var/list/MsgType = list("Central Command Report" = "Nanotrasen Update",
		"Syndicate Communique" = "Syndicate Message",
		"Space Wizard Federation Message" = "Sorcerous Message",
		"Enemy Communications" = "Unknown Message",
		"Custom" = "Cryptic Message")

	var/list/MsgSound = list("Beep" = 'sound/misc/notice2.ogg',
		"Enemy Communications Intercepted" = 'sound/AI/intercept2.ogg',
		"New Command Report Created" = 'sound/AI/commandreport.ogg')

	var/type = input(usr, "Pick a type of report to send", "Report Type", "") as anything in MsgType

	if(type == "Custom")
		type = clean_input("What would you like the report type to be?", "Report Type", "Encrypted Transmission")

	var/customname = input(usr, "Pick a title for the report.", "Title", MsgType[type]) as text|null
	if(!customname)
		return
	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What's the message?") as message|null
	if(!input)
		return

	switch(alert("Should this be announced to the general population?",,"Yes","No", "Cancel"))
		if("Yes")
			var/beepsound = input(usr, "What sound should the announcement make?", "Announcement Sound", "") as anything in MsgSound

			GLOB.command_announcement.Announce(input, customname, MsgSound[beepsound], , , type)
			print_command_report(input, customname)
		if("No")
			//same thing as the blob stuff - it's not public, so it's classified, dammit
			GLOB.command_announcer.autosay("A classified message has been printed out at all communication consoles.")
			print_command_report(input, "Classified: [customname]")
		else
			return

	log_admin("[key_name(src)] has created a communications report: [input]")
	message_admins("[key_name_admin(src)] has created a communications report", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Create Comms Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_delete(atom/A as obj|mob|turf in view())
	set category = null
	set name = "Delete"

	if(!check_rights(R_ADMIN))
		return

	admin_delete(A)

/client/proc/admin_delete(datum/D)
	if(istype(D) && !D.can_vv_delete())
		to_chat(src, "[D] rejected your deletion")
		return
	var/atom/A = D
	var/coords = istype(A) ? "at ([A.x], [A.y], [A.z])" : ""
	if(alert(src, "Are you sure you want to delete:\n[D]\n[coords]?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [D] [coords]")
		message_admins("[key_name_admin(usr)] deleted [D] [coords]", 1)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(isturf(D))
			var/turf/T = D
			T.ChangeTurf(T.baseturf)
		else
			qdel(D)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin"
	set name = "List free slots"

	if(!check_rights(R_ADMIN))
		return

	if(SSjobs)
		var/currentpositiontally
		var/totalpositiontally
		to_chat(src, "<span class='notice'>Job Name: Filled job slot / Total job slots <b>(Free job slots)</b></span>")
		for(var/datum/job/job in SSjobs.occupations)
			to_chat(src, "<span class='notice'>[job.title]: [job.current_positions] / \
			[job.total_positions == -1 ? "<b>UNLIMITED</b>" : job.total_positions] \
			 <b>([job.total_positions == -1 ? "UNLIMITED" : job.total_positions - job.current_positions])</b></span>")
			if(job.total_positions != -1) // Only count position that isn't unlimited
				currentpositiontally += job.current_positions
				totalpositiontally += job.total_positions
		to_chat(src, "<b>Currently filled job slots (Excluding unlimited): [currentpositiontally] / [totalpositiontally] ([totalpositiontally - currentpositiontally])</b>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "List Free Slots") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in view())
	set category = "Event"
	set name = "Explosion"

	if(!check_rights(R_DEBUG|R_EVENT))
		return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null) return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null) return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null) return
	var/flames = input("Range of flames. -1 to none", text("Input"))  as num|null
	if(flames == null) return

	if((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if(alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion(O, devastation, heavy, light, flash, null, null,flames)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at ([O.x],[O.y],[O.z])")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in view())
	set category = "Event"
	set name = "EM Pulse"

	if(!check_rights(R_DEBUG|R_EVENT))
		return

	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null) return

	if(heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM pulse ([heavy], [light]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an EM pulse ([heavy], [light]) at ([O.x],[O.y],[O.z])", 1)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M as mob in GLOB.mob_list)
	set category = "Admin"
	set name = "Gib"

	if(!check_rights(R_ADMIN|R_EVENT))
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)	return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]", 1)

	if(istype(M, /mob/dead/observer))
		gibs(M.loc)
		return

	M.gib()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Event"

	if(!check_rights(R_ADMIN|R_EVENT))
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm == "Yes")
		if(istype(mob, /mob/dead/observer)) // so they don't spam gibs everywhere
			return
		else
			mob.gib()

		log_admin("[key_name(usr)] used gibself.")
		message_admins("<span class='notice'>[key_name_admin(usr)] used gibself.</span>", 1)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Gibself") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_check_contents(mob/living/M as mob in GLOB.mob_list)
	set name = "Check Contents"
	set category = null

	if(!check_rights(R_ADMIN))
		return

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Contents") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_view_range()
	set category = "Admin"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(!check_rights(R_ADMIN))
		return

	if(view == world.view)
		view = input("Select view range:", "View Range", world.view) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128)
	else
		view = world.view

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("<span class='notice'>[key_name_admin(usr)] changed their view range to [view].</span>", 1)	//why? removed by order of XSI

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Change View Range") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()

	set category = "Admin"
	set name = "Call Shuttle"

	if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
		return

	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return

	if(alert("Set Shuttle Recallable (Select Yes unless you know what this does)", "Recallable?", "Yes", "No") == "Yes")
		SSshuttle.emergency.canRecall = TRUE
	else
		SSshuttle.emergency.canRecall = FALSE

	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED)
		SSshuttle.emergency.request(coefficient = 0.5, redAlert = TRUE)
	else
		SSshuttle.emergency.request()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-called the emergency shuttle.</span>")
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin"
	set name = "Cancel Shuttle"

	if(!check_rights(R_ADMIN))
		return
	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes") return

	if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
		return

	if(SSshuttle.emergency.canRecall == FALSE)
		if(alert("Shuttle is currently set to be nonrecallable. Recalling may break things. Respect Recall Status?", "Override Recall Status?", "Yes", "No") == "Yes")
			return
		else
			var/keepStatus = alert("Maintain recall status on future shuttle calls?", "Maintain Status?", "Yes", "No") == "Yes" //Keeps or drops recallability
			SSshuttle.emergency.canRecall = TRUE // must be true for cancel proc to work
			SSshuttle.emergency.cancel()
			if(keepStatus)
				SSshuttle.emergency.canRecall = FALSE // restores original status
	else
		SSshuttle.emergency.cancel()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Cancel Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-recalled the emergency shuttle.</span>")
	return

/client/proc/admin_deny_shuttle()
	set category = "Admin"
	set name = "Toggle Deny Shuttle"

	if(!SSticker)
		return

	if(!check_rights(R_ADMIN))
		return

	if(alert(usr, "Do you want to [SSshuttle.emergencyNoEscape ? "ALLOW" : "DENY"] shuttle calls?", "Toggle Deny Shuttle", "Yes", "No") != "Yes")
		return

	if(SSshuttle)
		SSshuttle.emergencyNoEscape = !SSshuttle.emergencyNoEscape

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Deny Shuttle")
	log_admin("[key_name(src)] has [SSshuttle.emergencyNoEscape ? "denied" : "allowed"] the shuttle to be called.")
	message_admins("[key_name_admin(usr)] has [SSshuttle.emergencyNoEscape ? "denied" : "allowed"] the shuttle to be called.")

/client/proc/cmd_admin_attack_log(mob/M as mob in GLOB.mob_list)
	set category = "Admin"
	set name = "Attack Log"

	if(!check_rights(R_ADMIN))
		return

	to_chat(usr, text("<span class='danger'>Attack Log for []</span>", mob))
	for(var/t in M.attack_log_old)
		to_chat(usr, t)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Attack Log") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/everyone_random()
	set category = "Event"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(!check_rights(R_SERVER|R_EVENT))
		return

	if(SSticker && SSticker.mode)
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	if(SSticker.random_players)
		SSticker.random_players = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.", 1)
		to_chat(usr, "Disabled.")
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.", 1)

	if(notifyplayers == "Yes")
		to_chat(world, "<span class='notice'><b>Admin [usr.key] has forced the players to have completely random identities!</span>")

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.")

	SSticker.random_players = 1
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Everyone Random") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_random_events()
	set category = "Event"
	set name = "Toggle random events on/off"

	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off"
	if(!check_rights(R_SERVER|R_EVENT))
		return

	if(!config.allow_random_events)
		config.allow_random_events = 1
		to_chat(usr, "Random events enabled")
		message_admins("Admin [key_name_admin(usr)] has enabled random events.", 1)
	else
		config.allow_random_events = 0
		to_chat(usr, "Random events disabled")
		message_admins("Admin [key_name_admin(usr)] has disabled random events.", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Random Events") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reset_all_tcs()
	set category = "Admin"
	set name = "Reset NTTC Configuration"
	set desc = "Resets NTTC to the default configuration."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "You sure you want to reset NTTC?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		C.nttc.reset()

	log_admin("[key_name(usr)] reset NTTC scripts.")
	message_admins("[key_name_admin(usr)] reset NTTC scripts.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Reset NTTC Configuration") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/list_ssds_afks()
	set category = "Admin"
	set name = "List SSDs and AFKs"
	set desc = "Lists SSD and AFK players"

	if(!check_rights(R_ADMIN))
		return

	/* ======== SSD Section ========= */
	var/msg = {"<html><meta charset="UTF-8"><head><title>SSD & AFK Report</title></head><body>"}
	msg += "SSD Players:<BR><TABLE border='1'>"
	msg += "<TR><TD><B>Key</B></TD><TD><B>Real Name</B></TD><TD><B>Job</B></TD><TD><B>Mins SSD</B></TD><TD><B>Special Role</B></TD><TD><B>Area</B></TD><TD><B>PPN</B></TD><TD><B>Cryo</B></TD></TR>"
	var/mins_ssd
	var/job_string
	var/key_string
	var/role_string
	var/obj_count = 0
	var/obj_string = ""
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(!isLivingSSD(H))
			continue
		mins_ssd = round((world.time - H.last_logout) / 600)
		if(H.job)
			job_string = H.job
		else
			job_string = "-"
		key_string = H.key
		if(job_string in GLOB.command_positions)
			job_string = "<U>" + job_string + "</U>"
		role_string = "-"
		obj_count = 0
		obj_string = ""
		if(H.mind)
			if(H.mind.special_role)
				role_string = "<U>[H.mind.special_role]</U>"
			if(!H.key && H.mind.key)
				key_string = H.mind.key
			for(var/datum/objective/O in GLOB.all_objectives)
				if(O.target == H.mind)
					obj_count++
			if(obj_count > 0)
				obj_string = "<BR><U>Obj Target</U>"
		msg += "<TR><TD>[key_string]</TD><TD>[H.real_name]</TD><TD>[job_string]</TD><TD>[mins_ssd]</TD><TD>[role_string][obj_string]</TD>"
		msg += "<TD>[get_area(H)]</TD><TD>[ADMIN_PP(H,"PP")]</TD>"
		if(istype(H.loc, /obj/machinery/cryopod))
			msg += "<TD><A href='?_src_=holder;cryossd=[H.UID()]'>De-Spawn</A></TD>"
		else
			msg += "<TD><A href='?_src_=holder;cryossd=[H.UID()]'>Cryo</A></TD>"
		msg += "</TR>"
	msg += "</TABLE><br></BODY></HTML>"

	/* ======== AFK Section ========= */
	msg += "AFK Players:<BR><TABLE border='1'>"
	msg += "<TR><TD><B>Key</B></TD><TD><B>Real Name</B></TD><TD><B>Job</B></TD><TD><B>Mins AFK</B></TD><TD><B>Special Role</B></TD><TD><B>Area</B></TD><TD><B>PPN</B></TD><TD><B>Cryo</B></TD></TR>"
	var/mins_afk
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(H.client == null || H.stat == DEAD) // No clientless or dead
			continue
		mins_afk = round(H.client.inactivity / 600)
		if(mins_afk < config.list_afk_minimum)
			continue
		if(H.job)
			job_string = H.job
		else
			job_string = "-"
		key_string = H.key
		if(job_string in GLOB.command_positions)
			job_string = "<U>" + job_string + "</U>"
		role_string = "-"
		obj_count = 0
		obj_string = ""
		if(H.mind)
			if(H.mind.special_role)
				role_string = "<U>[H.mind.special_role]</U>"
			if(!H.key && H.mind.key)
				key_string = H.mind.key
			for(var/datum/objective/O in GLOB.all_objectives)
				if(O.target == H.mind)
					obj_count++
			if(obj_count > 0)
				obj_string = "<BR><U>Obj Target</U>"
		msg += "<TR><TD>[key_string]</TD><TD>[H.real_name]</TD><TD>[job_string]</TD><TD>[mins_afk]</TD><TD>[role_string][obj_string]</TD>"
		msg += "<TD>[get_area(H)]</TD><TD>[ADMIN_PP(H,"PP")]</TD>"
		if(istype(H.loc, /obj/machinery/cryopod))
			msg += "<TD><A href='?_src_=holder;cryossd=[H.UID()];cryoafk=1'>De-Spawn</A></TD>"
		else
			msg += "<TD><A href='?_src_=holder;cryossd=[H.UID()];cryoafk=1'>Cryo</A></TD>"
		msg += "</TR>"
	msg += "</TABLE></BODY></HTML>"
	src << browse(msg, "window=Player_ssd_afk_check;size=600x300")

/client/proc/toggle_ert_calling()
	set category = "Event"
	set name = "Toggle ERT"

	set desc = "Toggle the station's ability to call a response team."
	if(!check_rights(R_EVENT))
		return

	if(SSticker.mode.ert_disabled)
		SSticker.mode.ert_disabled = 0
		to_chat(usr, "<span class='notice'>ERT has been <b>Enabled</b>.</span>")
		log_admin("Admin [key_name(src)] has enabled ERT calling.")
		message_admins("Admin [key_name_admin(usr)] has enabled ERT calling.", 1)
	else
		SSticker.mode.ert_disabled = 1
		to_chat(usr, "<span class='warning'>ERT has been <b>Disabled</b>.</span>")
		log_admin("Admin [key_name(src)] has disabled ERT calling.")
		message_admins("Admin [key_name_admin(usr)] has disabled ERT calling.", 1)

/client/proc/show_tip()
	set category = "Event"
	set name = "Show Custom Tip"
	set desc = "Sends a tip (that you specify) to all players. After all \
		you're the experienced player here."

	if(!check_rights(R_EVENT))
		return

	var/input = input(usr, "Please specify your tip that you want to send to the players.", "Tip", "") as message|null
	if(!input)
		return

	if(!SSticker)
		return

	SSticker.selected_tip = input

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()

	message_admins("[key_name_admin(usr)] sent a Tip of the round.")
	log_admin("[key_name(usr)] sent \"[input]\" as the Tip of the Round.")

/client/proc/modify_goals()
	set category = "Event"
	set name = "Modify Station Goals"

	if(!check_rights(R_EVENT))
		return

	holder.modify_goals()

/datum/admins/proc/modify_goals()
	if(!SSticker || !SSticker.mode)
		to_chat(usr, "<span class='warning'>This verb can only be used if the round has started.</span>")
		return

	var/dat = {"<meta charset="UTF-8">"}
	for(var/datum/station_goal/S in SSticker.mode.station_goals)
		dat += "[S.name] - <a href='?src=[S.UID()];announce=1'>Announce</a> | <a href='?src=[S.UID()];remove=1'>Remove</a><br>"
	dat += "<br><a href='?src=[UID()];add_station_goal=1'>Add New Goal</a>"
	usr << browse(dat, "window=goals;size=400x400")

/// Allow admin to add or remove traits of datum
/datum/admins/proc/modify_traits(datum/D)
	if(!D)
		return

	var/add_or_remove = input("Remove/Add?", "Trait Remove/Add") as null|anything in list("Add","Remove")
	if(!add_or_remove)
		return
	var/list/availible_traits = list()

	switch(add_or_remove)
		if("Add")
			for(var/key in GLOB.traits_by_type)
				if(istype(D,key))
					availible_traits += GLOB.traits_by_type[key]
		if("Remove")
			if(!GLOB.trait_name_map)
				GLOB.trait_name_map = generate_trait_name_map()
			for(var/trait in D.status_traits)
				var/name = GLOB.trait_name_map[trait] || trait
				availible_traits[name] = trait

	var/chosen_trait = input("Select trait to modify", "Trait") as null|anything in availible_traits
	if(!chosen_trait)
		return
	chosen_trait = availible_traits[chosen_trait]

	var/source = "adminabuse"
	switch(add_or_remove)
		if("Add") //Not doing source choosing here intentionally to make this bit faster to use, you can always vv it.
			ADD_TRAIT(D, chosen_trait, source)
		if("Remove")
			var/specific = input("All or specific source ?", "Trait Remove/Add") as null|anything in list("All","Specific")
			if(!specific)
				return
			switch(specific)
				if("All")
					source = null
				if("Specific")
					source = input("Source to be removed","Trait Remove/Add") as null|anything in D.status_traits[chosen_trait]
					if(!source)
						return
			REMOVE_TRAIT(D, chosen_trait, source)
