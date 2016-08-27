/client/proc/cmd_admin_drop_everything(mob/M as mob in mob_list)
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
	feedback_add_details("admin_verb","DEVR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_prison(mob/M as mob in mob_list)
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
		M.loc = pick(prisonwarp)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), slot_w_uniform)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)
		spawn(50)
			to_chat(M, "\red You have been sent to the prison station!")
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("\blue [key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.", 1)
		feedback_add_details("admin_verb","PRISON") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M as mob in mob_list)
	set category = "Event"
	set name = "Subtle Message"

	if(!ismob(M))
		return

	if(!check_rights(R_SERVER|R_EVENT))
		return

	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text

	if(!msg)
		return
	if(usr)
		if(usr.client)
			if(usr.client.holder)
				to_chat(M, "\bold You hear a voice in your head... \italic [msg]")

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	message_admins("\blue \bold SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] : [msg]", 1)
	feedback_add_details("admin_verb","SMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
	for(var/client/C in clients)
		if(C.player_age == "Requires database")
			missing_ages = 1
			continue
		if(C.player_age < age)
			msg += "[key_name_admin(C)]: account is [C.player_age] days old<br>"

	if(missing_ages)
		to_chat(src, "Some accounts did not have proper ages set in their clients.  This function requires database to be present")

	if(msg != "")
		src << browse(msg, "window=Player_age_check")
	else
		to_chat(src, "No matches for that age range found.")


/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Event"
	set name = "Global Narrate"

	if(!check_rights(R_SERVER|R_EVENT))
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text

	if(!msg)
		return
	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("\blue \bold GlobalNarrate: [key_name_admin(usr)]: [msg]<BR>", 1)
	feedback_add_details("admin_verb","GLN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(var/mob/M)	// Targetted narrate -- TLE
	set category = "Event"
	set name = "Direct Narrate"

	if(!check_rights(R_SERVER|R_EVENT))
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in get_mob_with_client_list()

	if(!M)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text

	if( !msg )
		return

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([key_name(M)]): [msg]")
	message_admins("\blue \bold DirectNarrate: [key_name_admin(usr)] to ([key_name_admin(M)]): [msg]<BR>", 1)
	feedback_add_details("admin_verb","DIRN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Godmode"

	if(!check_rights(R_ADMIN))
		return

	M.status_flags ^= GODMODE
	to_chat(usr, "\blue Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]")

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]", 1)
	feedback_add_details("admin_verb","GOD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
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
		feedback_add_details("admin_verb","AUTOMUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
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
	feedback_add_details("admin_verb","MUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
	feedback_add_details("admin_verb","ION") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
				g.antagHUD = 0						// Disable it on those that have it enabled
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
			g.antagHUD = 0
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
	set category = "Special Verbs"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."

	if(!check_rights(R_SPAWN))
		return

	var/input = ckey(input(src, "Please specify which key will be respawned.", "Key", ""))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in player_list)
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
				if(xeno_spawn.len)	T = pick(xeno_spawn)
				else				T = pick(latejoin)

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
				message_admins("\blue [key_name_admin(usr)] has respawned [new_xeno.key] as a filthy xeno.", 1)
				return	//all done. The ghost is auto-deleted

	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")
		for(var/datum/data/record/t in data_core.locked)
			if(t.fields["id"]==id)
				record_found = t//We shall now reference the record.
				break

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.change_gender(record_found.fields["sex"])
		new_character.age = record_found.fields["age"]
		new_character.b_type = record_found.fields["b_type"]
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
			job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)
			ticker.mode.equip_traitor(new_character)
		if("Wizard")
			new_character.loc = pick(wizardstart)
			//ticker.mode.learn_basic_spells(new_character)
			ticker.mode.equip_wizard(new_character)
		if("Syndicate")
			var/obj/effect/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
			if(synd_spawn)
				new_character.loc = get_turf(synd_spawn)
			call(/datum/game_mode/proc/equip_syndicate)(new_character)

		if("Death Commando")//Leaves them at late-join spawn.
			new_character.equip_death_commando()
			new_character.internal = new_character.s_store
			new_character.update_internals_hud_icon(1)
		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if("Cyborg")//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize()
					if(new_character.mind.special_role=="traitor")
						call(/datum/game_mode/proc/add_law_zero)(new_character)
				if("AI")
					new_character = new_character.AIize()
					var/mob/living/silicon/ai/ai_character = new_character
					ai_character.moveToAILandmark()
					if(new_character.mind.special_role=="traitor")
						call(/datum/game_mode/proc/add_law_zero)(new_character)
				//Add aliens.
				else
					job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found&&new_character.mind.assigned_role!="MODE")//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
				data_core.manifest_inject(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
				call(/mob/new_player/proc/AnnounceArrival)(new_character, new_character.mind.assigned_role)

	message_admins("\blue [key_name_admin(usr)] has respawned [key_name_admin(G_found)] as [new_character.real_name].", 1)

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	feedback_add_details("admin_verb","RSPCH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in player_list)
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
	var/obj/effect/landmark/spawn_here = xeno_spawn.len ? pick(xeno_spawn) : pick(latejoin)
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Queen")		new_xeno = new /mob/living/carbon/alien/humanoid/queen/large(spawn_here)
		if("Hunter")	new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Sentinel")	new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Drone")		new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larva")		new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else			return 0

	new_xeno.ckey = ckey
	message_admins("\blue [key_name_admin(usr)] has spawned [ckey] as a filthy xeno [alien_caste].", 1)
	return 1


/client/proc/get_ghosts(var/notify = 0,var/what = 2)
	// what = 1, return ghosts ass list.
	// what = 2, return mob list

	var/list/mobs = list()
	var/list/ghosts = list()
	var/list/sortmob = sortAtom(mob_list)                           // get the mob list.
	/var/any=0
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

	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]")

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	new /datum/event/ion_storm(0, announce_ion_laws, input)

	feedback_add_details("admin_verb","IONC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M as mob in mob_list)
	set category = "Special Verbs"
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
	message_admins("\red Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!", 1)
	feedback_add_details("admin_verb","REJU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Event"
	set name = "Create Communications Report"
	var/list/MsgType = list("Centcom Report","Enemy Communications")
	if(!check_rights(R_SERVER|R_EVENT))
		return

	var/type = input(usr, "Pick a type of report to send", "Report Type", "") as anything in MsgType
	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null
	var/customname = input(usr, "Pick a title for the report.", "Title") as text|null
	if(!input)
		return

	if(type == "Enemy Communications")
		if(!customname)
			customname = type

		var/from = input(usr, "What kind of report? Example: Syndicate Communique", "From") as text|null
		if(!from)
			from = "Syndicate Communique"
		switch(alert("Should this be announced to the general population?",,"Yes","No"))
			if("Yes")
				communications_announcement.Announce(input, customname, , , , from);
			if("No")
				to_chat(world, "\red [from] available at all communications consoles.")

		for(var/obj/machinery/computer/communications/C in machines)
			if(! (C.stat & (BROKEN|NOPOWER) ) )
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
				P.name = "[from]"
				P.info = input
				P.update_icon()
				C.messagetitle.Add("[from]")
				C.messagetext.Add(P.info)


	if(type == "Centcom Report")
		if(!customname)
			customname = "Nanotrasen Update"

		switch(alert("Should this be announced to the general population?",,"Yes","No"))
			if("Yes")
				command_announcement.Announce(input, customname);
			if("No")
				to_chat(world, "\red New Nanotrasen Update available at all communication consoles.")

		for(var/obj/machinery/computer/communications/C in machines)
			if(! (C.stat & (BROKEN|NOPOWER) ) )
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
				P.name = "'[command_name()] Update.'"
				P.info = input
				P.update_icon()
				C.messagetitle.Add("[command_name()] Update")
				C.messagetext.Add(P.info)

//	world << sound('sound/AI/commandreport.ogg')
	log_admin("[key_name(src)] has created a communications report: [input]")
	message_admins("[key_name_admin(src)] has created a communications report", 1)
	feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_delete(atom/O as obj|mob|turf in view())
	set category = "Admin"
	set name = "Delete"

	if(!check_rights(R_ADMIN))
		return

	if(alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] deleted [O] at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","DEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(istype(O, /turf))
			var/turf/T = O
			T.ChangeTurf(/turf/space)
			return
		qdel(O)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin"
	set name = "List free slots"

	if(!check_rights(R_ADMIN))
		return

	if(job_master)
		for(var/datum/job/job in job_master.occupations)
			to_chat(src, "[job.title]: [job.total_positions]")
	feedback_add_details("admin_verb","LFS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
		feedback_add_details("admin_verb","EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in view())
	set category = "Special Verbs"
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
		feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M as mob in mob_list)
	set category = "Special Verbs"
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
		gibs(M.loc, M.viruses)
		return

	M.gib()
	feedback_add_details("admin_verb","GIB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
		message_admins("\blue [key_name_admin(usr)] used gibself.", 1)
		feedback_add_details("admin_verb","GIBS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_check_contents(mob/living/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Check Contents"

	if(!check_rights(R_ADMIN))
		return

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]")
	feedback_add_details("admin_verb","CC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_view_range()
	set category = "Special Verbs"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(!check_rights(R_ADMIN))
		return

	if(view == world.view)
		view = input("Select view range:", "View Range", world.view) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128)
	else
		view = world.view

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("\blue [key_name_admin(usr)] changed their view range to [view].", 1)	//why? removed by order of XSI

	feedback_add_details("admin_verb","CVRA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()

	set category = "Admin"
	set name = "Call Shuttle"

	if(shuttle_master.emergency.mode >= SHUTTLE_DOCKED)
		return

	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return

	shuttle_master.emergency.request()

	feedback_add_details("admin_verb","CSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-called the emergency shuttle.</span>")
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin"
	set name = "Cancel Shuttle"

	if(!check_rights(R_ADMIN))
		return
	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes") return

	if(shuttle_master.emergency.mode >= SHUTTLE_DOCKED)
		return

	shuttle_master.emergency.cancel()
	feedback_add_details("admin_verb","CCSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-recalled the emergency shuttle.</span>")
	return

/client/proc/admin_deny_shuttle()
	set category = "Admin"
	set name = "Toggle Deny Shuttle"

	if(!ticker)
		return

	if(!check_rights(R_ADMIN))
		return

	if(shuttle_master)
		shuttle_master.emergencyNoEscape = !shuttle_master.emergencyNoEscape

	log_admin("[key_name(src)] has [shuttle_master.emergencyNoEscape ? "denied" : "allowed"] the shuttle to be called.")
	message_admins("[key_name_admin(usr)] has [shuttle_master.emergencyNoEscape ? "denied" : "allowed"] the shuttle to be called.")

/client/proc/cmd_admin_attack_log(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Attack Log"

	if(!check_rights(R_ADMIN))
		return

	to_chat(usr, text("<span class='danger'>Attack Log for []</span>", mob))
	for(var/t in M.attack_log)
		to_chat(usr, t)
	feedback_add_details("admin_verb","ATTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/everyone_random()
	set category = "Event"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(!check_rights(R_SERVER|R_EVENT))
		return

	if(ticker && ticker.mode)
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	if(ticker.random_players)
		ticker.random_players = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.", 1)
		to_chat(usr, "Disabled.")
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.", 1)

	if(notifyplayers == "Yes")
		to_chat(world, "\blue <b>Admin [usr.key] has forced the players to have completely random identities!")

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.")

	ticker.random_players = 1
	feedback_add_details("admin_verb","MER") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
	feedback_add_details("admin_verb","TRE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reset_all_tcs()
	set category = "Admin"
	set name = "Reset Telecomms Scripts"
	set desc = "Blanks all telecomms scripts from all telecomms servers"

	if(!check_rights(R_ADMIN, 1, src))
		return

	var/confirm = alert(src, "You sure you want to blank all NTSL scripts?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/machinery/telecomms/server/S in telecomms_list)
		var/datum/TCS_Compiler/C = S.Compiler
		S.rawcode = ""
		C.Compile("")
	for(var/obj/machinery/computer/telecomms/traffic/T in machines)
		T.storedcode = ""
	log_admin("[key_name(usr)] blanked all telecomms scripts.")
	message_admins("[key_name_admin(usr)] blanked all telecomms scripts.")
	feedback_add_details("admin_verb","RAT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_ert_calling()
	set category = "Event"
	set name = "Toggle ERT"

	set desc = "Toggle the station's ability to call a response team."
	if(!check_rights(R_EVENT))
		return

	if(ticker.mode.ert_disabled)
		ticker.mode.ert_disabled = 0
		to_chat(usr, "\blue ERT has been <b>Enabled</b>.")
		log_admin("Admin [key_name(src)] has enabled ERT calling.")
		message_admins("Admin [key_name_admin(usr)] has enabled ERT calling.", 1)
	else
		ticker.mode.ert_disabled = 1
		to_chat(usr, "\red ERT has been <b>Disabled</b>.")
		log_admin("Admin [key_name(src)] has disabled ERT calling.")
		message_admins("Admin [key_name_admin(usr)] has disabled ERT calling.", 1)
