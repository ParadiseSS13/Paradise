/client/proc/cmd_admin_drop_everything(mob/M as mob in GLOB.mob_list)
	set name = "\[Admin\] Drop Everything"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		M.drop_item_to_ground(W)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Everything") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(imprison, R_ADMIN, "Prison", "Send a mob to prison.", VERB_CATEGORY_ADMIN, mob/M as mob in GLOB.mob_list)
	if(ismob(M))
		if(is_ai(M))
			alert(client, "The AI can't be sent to prison you jerk!", null, null, null, null)
			return
		//strip their stuff before they teleport into a cell :downs:
		for(var/obj/item/W in M)
			M.drop_item_to_ground(W)
		//teleport person to cell
		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(10 SECONDS)
		sleep(5)	//so they black out before warping
		M.loc = pick(GLOB.prisonwarp)
		if(ishuman(M))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), ITEM_SLOT_JUMPSUIT)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), ITEM_SLOT_SHOES)
		spawn(50)
			to_chat(M, SPAN_WARNING("You have been sent to the prison station!"))
		log_admin("[key_name(client)] sent [key_name(M)] to the prison station.")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] sent [key_name_admin(M)] to the prison station."), 1)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Prison") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(subtle_message, R_EVENT, "\[Admin\] Subtle Message", mob/M as mob in GLOB.mob_list)
	if(!ismob(M))
		return

	var/msg = clean_input("Message:", "Subtle PM to [M.key]", user = client)

	if(!msg)
		return

	msg = admin_pencode_to_html(msg)

	if(client.holder)
		to_chat(M, "<b>You hear a voice in your head... <i>[msg]</i></b>")

	log_admin("SubtlePM: [key_name(client)] -> [key_name(M)] : [msg]")
	message_admins(SPAN_BOLDNOTICE("Subtle Message: [key_name_admin(client)] -> [key_name_admin(M)] : [msg]"), 1)
	M.create_log(MISC_LOG, "Subtle Message: [msg]", "From: [key_name_admin(client)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Subtle Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(check_new_players, R_MENTOR|R_MOD|R_ADMIN, "Check New Players", "Perform a player account age check.", VERB_CATEGORY_ADMIN)
	var/age = input(client, "Show accounts younger then ____ days", "Age check") as num|null
	var/playtime_hours = input(client, "Show accounts with less than ____ hours", "Playtime check") as num|null
	if(isnull(age))
		age = -1
	if(isnull(playtime_hours))
		playtime_hours = -1
	if(age <= 0 && playtime_hours <= 0)
		return

	var/missing_ages = 0
	var/msg = ""
	var/is_admin = check_rights(R_ADMIN, 0)
	for(var/client/C in GLOB.clients)
		if(C?.holder?.fakekey && !check_rights(R_ADMIN, FALSE))
			continue // Skip those in stealth mode if an admin isnt viewing the panel

		if(!isnum(C.player_age))
			missing_ages = 1
			continue
		if(C.player_age < age)
			if(is_admin)
				msg += "[key_name_admin(C.mob)]: [C.player_age] days old<br>"
			else
				msg += "[key_name_mentor(C.mob)]: [C.player_age] days old<br>"

		var/client_hours = C.get_exp_type_num(EXP_TYPE_LIVING) + C.get_exp_type_num(EXP_TYPE_GHOST)
		client_hours /= 60 // minutes to hours
		if(client_hours < playtime_hours)
			if(is_admin)
				msg += "[key_name_admin(C.mob)]: [client_hours] living + ghost hours<br>"
			else
				msg += "[key_name_mentor(C.mob)]: [client_hours] living + ghost hours<br>"

	if(missing_ages)
		to_chat(client, "Some accounts did not have proper ages set in their clients.  This function requires database to be present")

	if(msg != "")
		client << browse(msg, "window=Player_age_check")
	else
		to_chat(client, "No matches for that age range found.")

USER_VERB(global_narrate, R_SERVER|R_EVENT, "Global Narrate", "Narrate text to the whole game world.", VERB_CATEGORY_EVENT)
	var/msg = clean_input("Message:", "Enter the text you wish to appear to everyone:", user = client)

	if(!msg)
		return
	msg = admin_pencode_to_html(msg)
	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(client)] : [msg]")
	message_admins(SPAN_BOLDNOTICE("GlobalNarrate: [key_name_admin(client)]: [msg]<BR>"), 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Global Narrate")

USER_CONTEXT_MENU(direct_narrate, R_SERVER|R_EVENT, "\[Admin\] Direct Narrate", mob/M)
	if(!M)
		M = input(client, "Direct narrate to who?", "Active Players") as null|anything in get_mob_with_client_list()

	if(!M)
		return

	var/msg = clean_input("Message:", "Enter the text you wish to appear to your target:", user = client)

	if(!msg)
		return
	msg = admin_pencode_to_html(msg)

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(client)] to ([key_name(M)]): [msg]")
	message_admins(SPAN_BOLDNOTICE("Direct Narrate: [key_name_admin(client)] to ([key_name_admin(M)]): [msg]<br>"), 1)
	M.create_log(MISC_LOG, "Direct Narrate: [msg]", "From: [key_name_admin(client)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Direct Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(headset_message, R_SERVER|R_EVENT, "\[Admin\] Headset Message", mob/M in GLOB.mob_list)
	client.admin_headset_message(M)

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
	H.create_log(MISC_LOG, "Headset Message: [input]", "From: [key_name_admin(src)]")
	to_chat(H, "<span class = 'specialnotice bold'>Incoming priority transmission from [sender == "Syndicate" ? "your benefactor" : "Central Command"].  Message as follows[sender == "Syndicate" ? ", agent." : ":"]</span><span class = 'specialnotice'> [input]</span>")
	SEND_SOUND(H, 'sound/effects/headset_message.ogg')

USER_VERB(godmode, R_ADMIN, "Godmode", "Toggles godmode on a mob.", VERB_CATEGORY_ADMIN, mob/M as mob in GLOB.mob_list)
	M.status_flags ^= GODMODE
	to_chat(client, SPAN_NOTICE("Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]"))

	log_admin("[key_name(client)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(client)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Godmode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
	if(automute)
		if(!GLOB.configuration.general.enable_auto_mute)
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
		if(MUTE_IC)
			mute_string = "IC (say and emote)"
		if(MUTE_OOC)
			mute_string = "OOC"
		if(MUTE_PRAY)
			mute_string = "pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat and DSAY"
		if(MUTE_EMOTE)
			mute_string = "emote"
		if(MUTE_ALL)
			mute_string = "everything"
		else
			return

	if(automute)
		muteunmute = "auto-muted"
		force_add_mute(M.client.ckey, mute_type)
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(M)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
		to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Automute") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	toggle_mute(M.client.ckey, mute_type)

	if(check_mute(M.client.ckey, mute_type))
		muteunmute = "muted"
	else
		muteunmute = "unmuted"

	log_admin("[key_name(usr)] has [muteunmute] [key_name(M)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
	to_chat(M, "You have been [muteunmute] from [mute_string].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mute") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(add_random_ai_law, R_EVENT, "Add Random AI Law", "Add a random law to the AI.", VERB_CATEGORY_EVENT)
	var/confirm = alert(client, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	log_admin("[key_name(client)] has added a random AI law.")
	message_admins("[key_name_admin(client)] has added a random AI law.")

	var/show_log = alert(client, "Show ion message?", "Message", "Yes", "No")
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	new /datum/event/ion_storm(botEmagChance = 0, announceEvent = announce_ion_laws)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Random AI Law")

USER_VERB(toggle_antaghud_use, R_SERVER, "Toggle antagHUD usage", "Toggles antagHUD usage for observers", VERB_CATEGORY_SERVER)
	var/action=""
	if(GLOB.configuration.general.allow_antag_hud)
		GLOB.antag_hud_users.Cut()
		for(var/mob/dead/observer/g in client.get_ghosts())
			if(g.antagHUD)
				g.antagHUD = FALSE						// Disable it on those that have it enabled
				to_chat(g, SPAN_DANGER("The Administrators have disabled AntagHUD."))
		GLOB.configuration.general.allow_antag_hud = FALSE
		to_chat(client, SPAN_DANGER("AntagHUD usage has been disabled"))
		action = "disabled"
	else
		for(var/mob/dead/observer/g in client.get_ghosts())
			if(!g.client.holder)						// Add the verb back for all non-admin ghosts
				to_chat(g, SPAN_BOLDNOTICE("The Administrators have enabled AntagHUD."))// Notify all observers they can now use AntagHUD

		GLOB.configuration.general.allow_antag_hud = TRUE
		action = "enabled"
		to_chat(client, SPAN_BOLDNOTICE("AntagHUD usage has been enabled"))


	log_admin("[key_name(client)] has [action] antagHUD usage for observers")
	message_admins("Admin [key_name_admin(client)] has [action] antagHUD usage for observers", 1)

USER_VERB(toggle_antaghug_restrictions, R_SERVER, "Toggle antagHUD Restrictions", \
		"Restricts players that have used antagHUD from being able to join this round.", \
		VERB_CATEGORY_SERVER)
	if(!client.is_connecting_from_localhost())
		if(tgui_alert(client, "Are you sure about this?", "Confirm", list("Yes", "No")) != "Yes")
			return

	var/action=""
	if(GLOB.configuration.general.restrict_antag_hud_rejoin)
		for(var/mob/dead/observer/g in client.get_ghosts())
			to_chat(g, SPAN_BOLDNOTICE("The administrator has lifted restrictions on joining the round if you use AntagHUD"))
		action = "lifted restrictions"
		GLOB.configuration.general.restrict_antag_hud_rejoin = FALSE
		to_chat(client, SPAN_BOLDNOTICE("AntagHUD restrictions have been lifted"))
	else
		for(var/mob/dead/observer/g in client.get_ghosts())
			to_chat(g, SPAN_DANGER("The administrator has placed restrictions on joining the round if you use AntagHUD"))
			to_chat(g, SPAN_DANGER("Your AntagHUD has been disabled, you may choose to re-enabled it but will be under restrictions."))
			g.antagHUD = FALSE
			GLOB.antag_hud_users -= g.ckey
		action = "placed restrictions"
		GLOB.configuration.general.restrict_antag_hud_rejoin = TRUE
		to_chat(client, SPAN_DANGER("AntagHUD restrictions have been enabled"))

	log_admin("[key_name(client)] has [action] on joining the round if they use AntagHUD")
	message_admins("Admin [key_name_admin(client)] has [action] on joining the round if they use AntagHUD", 1)

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

//I use this proc for respawn character too. /N
/proc/create_xeno(ckey, mob/user)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in GLOB.player_list)
			if(M.stat != DEAD)
				continue //we are not dead!
			if(!(ROLE_ALIEN in M.client.prefs.be_special))
				continue //we don't want to be an alium
			if(jobban_isbanned(M, ROLE_ALIEN) || jobban_isbanned(M, ROLE_SYNDICATE))
				continue //we are jobbanned
			if(M.client.is_afk())
				continue //we are afk
			if(M.mind && M.mind.current && M.mind.current.stat != DEAD)
				continue //we have a live body we are tied to
			candidates += M.ckey
		if(length(candidates))
			ckey = input("Pick the player you want to respawn as a xeno.", "Suitable Candidates") as null|anything in candidates
		else
			to_chat(user, "<font color='red'>Error: create_xeno(): no suitable candidates.</font>")
	if(!istext(ckey))	return 0

	var/alien_caste = input(user, "Please choose which caste to spawn.","Pick a caste",null) as null|anything in list("Queen","Hunter","Sentinel","Drone","Larva")
	var/obj/effect/landmark/spawn_here = length(GLOB.xeno_spawn) ? pick(GLOB.xeno_spawn) : pick(GLOB.latejoin)
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Queen")		new_xeno = new /mob/living/carbon/alien/humanoid/queen/large(spawn_here)
		if("Hunter")	new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Sentinel")	new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Drone")		new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larva")		new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else			return 0

	new_xeno.ckey = ckey
	message_admins(SPAN_NOTICE("[key_name_admin(user)] has spawned [ckey] as a filthy xeno [alien_caste]."), 1)
	return 1

/client/proc/get_ghosts(notify = 0, what = 2)
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

USER_VERB(add_freeform_ai_law, R_EVENT, "Add Custom AI law", "Add custom AI law.", VERB_CATEGORY_EVENT)
	var/input = clean_input("Please enter anything you want the AI to do. Anything. Serious.", "What?", "", user = client)
	if(!input)
		return

	log_admin("Admin [key_name(client)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(client)] has added a new AI law - [input]")

	var/show_log = alert(client, "Show ion message?", "Message", "Yes", "No")
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	new /datum/event/ion_storm(botEmagChance = 0, announceEvent = announce_ion_laws, ionMessage = input)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Custom AI Law") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(admin_rejuvenate, R_REJUVINATE, "\[Admin\] Rejuvenate", mob/living/M as mob in GLOB.mob_list)
	if(!istype(M))
		alert(client, "Cannot revive a ghost")
		return
	M.revive()

	log_admin("[key_name(client)] healed / revived [key_name(M)]")
	message_admins(SPAN_WARNING("Admin [key_name_admin(client)] healed / revived [key_name_admin(M)]!"), 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Rejuvenate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(create_centcom_report, R_SERVER|R_EVENT, "Create Communications Report", "Send an IC announcement to the game world.", VERB_CATEGORY_EVENT)
	//the stuff on the list is |"report type" = "report title"|, if that makes any sense
	var/list/MsgType = list("Central Command Report" = "Nanotrasen Update",
		"Syndicate Communique" = "Syndicate Message",
		"Space Wizard Federation Message" = "Sorcerous Message",
		"Enemy Communications" = "Unknown Message",
		"Custom" = "Cryptic Message")

	var/list/MsgSound = list("Beep" = 'sound/misc/notice2.ogg',
		"Enemy Communications Intercepted" = 'sound/AI/intercept.ogg',
		"New Command Report Created" = 'sound/AI/commandreport.ogg')

	var/type = input(client, "Pick a type of report to send", "Report Type", "") as anything in MsgType

	if(type == "Custom")
		type = clean_input("What would you like the report type to be?", "Report Type", "Encrypted Transmission", user = client)

	var/subtitle = input(client, "Pick a title for the report.", "Title", MsgType[type]) as text|null
	if(!subtitle)
		return
	var/message = input(client, "Please enter anything you want. Anything. Serious.", "What's the message?") as message|null
	if(!message)
		return

	switch(alert(client, "Should this be announced to the general population?", null,"Yes","No", "Cancel"))
		if("Yes")
			var/beepsound = input(client, "What sound should the announcement make?", "Announcement Sound", "") as anything in MsgSound
			var/should_translate = alert(client, "Should it be auto-translated for all human mobs?", "Translation", "Yes", "No")
			if(should_translate != "Yes")
				should_translate = null // We can just do it like this since force_translation just needs any value to not be false/null
			GLOB.major_announcement.Announce(
				message,
				new_title = type,
				new_subtitle = subtitle,
				new_sound = MsgSound[beepsound],
				force_translation = should_translate
			)
			print_command_report(message, subtitle)
		if("No")
			//same thing as the blob stuff - it's not public, so it's classified, dammit
			GLOB.command_announcer.autosay("A classified message has been printed out at all communication consoles.")
			print_command_report(message, "Classified: [subtitle]")
		else
			return

	log_admin("[key_name(client)] has created a communications report: [message]")
	message_admins("[key_name_admin(client)] has created a communications report", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Create Comms Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(admin_delete, R_ADMIN, "\[Admin\] Delete", atom/A as obj|mob|turf in view())
	client.admin_delete(A)

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

USER_VERB(list_open_jobs, R_ADMIN, "List free slots", "List available station jobs.", VERB_CATEGORY_ADMIN)
	if(SSjobs)
		var/currentpositiontally
		var/totalpositiontally
		to_chat(client, SPAN_NOTICE("Job Name: Filled job slot / Total job slots <b>(Free job slots)</b>"))
		for(var/datum/job/job in SSjobs.occupations)
			to_chat(client, "<span class='notice'>[job.title]: [job.current_positions] / \
			[job.total_positions == -1 ? "<b>UNLIMITED</b>" : job.total_positions] \
			<b>([job.total_positions == -1 ? "UNLIMITED" : job.total_positions - job.current_positions])</b></span>")
			if(job.total_positions != -1) // Only count position that isn't unlimited
				currentpositiontally += job.current_positions
				totalpositiontally += job.total_positions
		to_chat(client, "<b>Currently filled job slots (Excluding unlimited): [currentpositiontally] / [totalpositiontally] ([totalpositiontally - currentpositiontally])</b>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "List Free Slots") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(admin_explosion, R_DEBUG|R_EVENT, "Explosion", "Create a custom explosion.", VERB_CATEGORY_EVENT, atom/O as obj|mob|turf in view())
	var/devastation = input(client, "Range of total devastation. -1 to none", "Input")  as num|null
	if(devastation == null) return
	var/heavy = input(client, "Range of heavy impact. -1 to none", "Input")  as num|null
	if(heavy == null) return
	var/light = input(client, "Range of light impact. -1 to none", "Input")  as num|null
	if(light == null) return
	var/flash = input(client, "Range of flash. -1 to none", "Input")  as num|null
	if(flash == null) return
	var/flames = input(client, "Range of flames. -1 to none", "Input")  as num|null
	if(flames == null) return

	if((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if(alert(client, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion(O, devastation, heavy, light, flash, null, null,flames, cause = "[client.ckey]: Explosion command")
		log_admin("[key_name(client)] created an explosion ([devastation],[heavy],[light],[flames]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(client)] created an explosion ([devastation],[heavy],[light],[flames]) at ([O.x],[O.y],[O.z])")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

USER_VERB(admin_emp, R_DEBUG|R_EVENT, "EM Pulse", "Cause an electromagnetic pulse.", VERB_CATEGORY_EVENT, atom/O as obj|mob|turf in view())
	var/heavy = input(client, "Range of heavy pulse.", "Input")  as num|null
	if(heavy == null) return
	var/light = input(client, "Range of light pulse.", "Input")  as num|null
	if(light == null) return

	if(heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(client)] created an EM pulse ([heavy], [light]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(client)] created an EM pulse ([heavy], [light]) at ([O.x],[O.y],[O.z])", 1)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

USER_VERB(gib_mob, R_ADMIN|R_EVENT, "Gib", "Gibs a chosen mob.", VERB_CATEGORY_ADMIN, mob/M as mob in GLOB.mob_list)
	var/confirm = alert(client, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)	return

	log_admin("[key_name(client)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(client)] has gibbed [key_name_admin(M)]", 1)

	if(isobserver(M))
		gibs(M.loc)
		return

	M.gib()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(gib_self, R_ADMIN|R_EVENT, "Gibself", "Gibself.", VERB_CATEGORY_EVENT)
	var/mob/mob = client.mob
	var/confirm = alert(client, "You sure?", "Confirm", "Yes", "No")
	if(confirm == "Yes")
		if(isobserver(mob)) // so they don't spam gibs everywhere
			return
		else
			mob.gib()

		log_admin("[key_name(client)] used gibself.")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] used gibself."), 1)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Gibself") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(admin_check_contents, R_ADMIN, "\[Admin\] Check Contents", mob/living/M as mob)
	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(client, "[t]")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Contents") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_view_range, R_ADMIN, "Change View Range", "Change tile view range.", VERB_CATEGORY_ADMIN)
	if(client.view == world.view)
		client.view = input(client, "Select view range:", "View Range", world.view) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128)
	else
		client.view = world.view

	log_admin("[key_name(client)] changed their view range to [client.view].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Change View Range") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(call_shuttle, R_ADMIN, "Call Shuttle", "Calls the shuttle.", VERB_CATEGORY_ADMIN)
	if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
		return

	var/confirm = alert(client, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return

	if(alert(client, "Set Shuttle Recallable (Select Yes unless you know what this does)", "Recallable?", "Yes", "No") == "Yes")
		SSshuttle.emergency.canRecall = TRUE
	else
		SSshuttle.emergency.canRecall = FALSE

	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		SSshuttle.emergency.request(coefficient = 0.5, redAlert = TRUE)
	else
		SSshuttle.emergency.request()

	log_admin("[key_name(client)] admin-called the emergency shuttle.")
	message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] admin-called the emergency shuttle."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(cancel_shuttle, R_ADMIN, "Cancel Shuttle", "Cancels the shuttle.", VERB_CATEGORY_ADMIN)
	if(alert(client, "You sure?", "Confirm", "Yes", "No") != "Yes") return

	if(SSshuttle.emergency.mode >= SHUTTLE_DOCKED)
		return

	if(!SSshuttle.emergency.canRecall)
		if(alert(client, "Shuttle is currently set to be nonrecallable. Recalling may break things. Respect Recall Status?", "Override Recall Status?", "Yes", "No") == "Yes")
			return
		else
			var/keepStatus = alert(client, "Maintain recall status on future shuttle calls?", "Maintain Status?", "Yes", "No") == "Yes" //Keeps or drops recallability
			SSshuttle.emergency.canRecall = TRUE // must be true for cancel proc to work
			SSshuttle.emergency.cancel(byCC = TRUE)
			if(keepStatus)
				SSshuttle.emergency.canRecall = FALSE // restores original status
	else
		SSshuttle.emergency.cancel(byCC = TRUE)

	log_admin("[key_name(client)] admin-recalled the emergency shuttle.")
	message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] admin-recalled the emergency shuttle."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Cancel Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(deny_shuttle, R_ADMIN, "Toggle Deny Shuttle", "Toggles crew shuttle calling-ability.", VERB_CATEGORY_ADMIN)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "The game hasn't started yet!")
		return

	var/alert = alert(client, "Do you want to ALLOW or DENY shuttle calls?", "Toggle Deny Shuttle", "Allow", "Deny", "Cancel")
	if(alert == "Cancel")
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Deny Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(alert == "Allow")
		if(!length(SSshuttle.hostile_environments))
			to_chat(client, SPAN_NOTICE("No hostile environments found, cleared for takeoff!"))
			return
		if(alert(client, "[english_list(SSshuttle.hostile_environments)] is currently blocking the shuttle call, do you want to clear them?", "Toggle Deny Shuttle", "Yes", "No") == "Yes")
			SSshuttle.hostile_environments.Cut()
			var/log = "[key_name(client)] has cleared all hostile environments, allowing the shuttle to be called."
			log_admin(log)
			message_admins(log)
		return

	SSshuttle.registerHostileEnvironment(client) // wow, a client blocking the shuttle
	log_and_message_admins("has denied the shuttle to be called.")

USER_VERB(open_attack_log, R_ADMIN, "Attack Log", "Prints the attack log.", VERB_CATEGORY_ADMIN, mob/M as mob in GLOB.mob_list)
	to_chat(client, SPAN_DANGER("Attack Log for [M]"))
	for(var/t in M.attack_log_old)
		to_chat(client, t)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Attack Log") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(everyone_random, R_SERVER|R_EVENT, "Make Everyone Random", \
		"Make everyone have a random appearance. You can only use this before rounds!", \
		VERB_CATEGORY_EVENT)
	if(SSticker && SSticker.mode)
		to_chat(client, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	if(SSticker.random_players)
		SSticker.random_players = 0
		message_admins("Admin [key_name_admin(client)] has disabled \"Everyone is Special\" mode.", 1)
		to_chat(client, "Disabled.")
		return


	var/notifyplayers = alert(client, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(client)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(client)] has forced the players to have random appearances.", 1)

	if(notifyplayers == "Yes")
		to_chat(world, SPAN_NOTICE("<b>Admin [client.key] has forced the players to have completely random identities!</b>"))

	to_chat(client, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.")

	SSticker.random_players = 1
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Everyone Random") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_random_events, R_SERVER|R_EVENT, "Toggle random events on/off", \
		"Toggles random events such as meteors, black holes, blob (but not space dust) on/off", \
		VERB_CATEGORY_EVENT)

	if(tgui_alert(client, "[GLOB.configuration.event.enable_random_events ? "Disable" : "Enable"] random events?", "Confirm", list("Yes", "No")) != "Yes")
		return

	if(!GLOB.configuration.event.enable_random_events)
		GLOB.configuration.event.enable_random_events = TRUE
		to_chat(client, "Random events enabled")
		message_admins("Admin [key_name_admin(client)] has enabled random events.")
	else
		GLOB.configuration.event.enable_random_events = FALSE
		to_chat(client, "Random events disabled")
		message_admins("Admin [key_name_admin(client)] has disabled random events.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Random Events") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(reset_telecoms, R_ADMIN, "Reset NTTC Configuration", "Resets NTTC to the default configuration.", VERB_CATEGORY_ADMIN)
	var/confirm = alert(client, "You sure you want to reset NTTC?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/machinery/tcomms/core/C in GLOB.tcomms_machines)
		C.nttc.reset()

	log_admin("[key_name(client)] reset NTTC scripts.")
	message_admins("[key_name_admin(client)] reset NTTC scripts.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Reset NTTC Configuration") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(list_ssds_afks, R_ADMIN, "List SSDs and AFKs", "List SSDs and AFK players", VERB_CATEGORY_ADMIN)
	/* ======== SSD Section ========= */
	var/msg = "<html><meta charset='utf-8'><head><title>SSD & AFK Report</title></head><body>"
	msg += "SSD Players:<br><TABLE border='1'>"
	msg += "<tr><td><b>Key</b></td><td><b>Real Name</b></td><td><b>Job</b></td><td><b>Mins SSD</b></td><td><b>Special Role</b></td><td><b>Area</b></td><td><b>PPN</b></td><td><b>Cryo</b></td></tr>"
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
			msg += "<TD><A href='byond://?_src_=holder;cryossd=[H.UID()]'>De-Spawn</A></TD>"
		else
			msg += "<TD><A href='byond://?_src_=holder;cryossd=[H.UID()]'>Cryo</A></TD>"
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
		if(mins_afk < 5)
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
			msg += "<TD><A href='byond://?_src_=holder;cryossd=[H.UID()];cryoafk=1'>De-Spawn</A></TD>"
		else
			msg += "<TD><A href='byond://?_src_=holder;cryossd=[H.UID()];cryoafk=1'>Cryo</A></TD>"
		msg += "</TR>"
	msg += "</TABLE></BODY></HTML>"
	client << browse(msg, "window=Player_ssd_afk_check;size=600x300")

USER_VERB(toggle_ert_calling, R_EVENT, "Toggle ERT", "Toggle the station's ability to call a response team.", VERB_CATEGORY_EVENT)
	if(SSticker.mode.ert_disabled)
		SSticker.mode.ert_disabled = FALSE
		to_chat(client, SPAN_NOTICE("ERT has been <b>Enabled</b>."))
		log_admin("Admin [key_name(client)] has enabled ERT calling.")
		message_admins("Admin [key_name_admin(client)] has enabled ERT calling.", 1)
	else
		SSticker.mode.ert_disabled = TRUE
		to_chat(client, SPAN_WARNING("ERT has been <b>Disabled</b>."))
		log_admin("Admin [key_name(client)] has disabled ERT calling.")
		message_admins("Admin [key_name_admin(client)] has disabled ERT calling.", 1)

USER_VERB(show_tip, R_EVENT, "Show Custom Tip", \
		"Sends a tip (that you specify) to all players. After all, you're the experienced player here.", \
		VERB_CATEGORY_EVENT)
	var/input = input(client, "Please specify your tip that you want to send to the players.", "Tip", "") as message|null
	if(!input)
		return

	if(SSticker.current_state < GAME_STATE_PREGAME)
		return

	SSticker.selected_tip = input

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()
		message_admins("[key_name_admin(client)] sent a custom Tip of the round.")
		log_admin("[key_name(client)] sent \"[input]\" as the Tip of the Round.")
		return

	message_admins("[key_name_admin(client)] set the Tip of the round to \"[html_encode(SSticker.selected_tip)]\".")
	log_admin("[key_name(client)] sent \"[input]\" as the Tip of the Round.")

USER_VERB(modify_goals, R_EVENT, "Modify Station Goals", "Modify station goals.", VERB_CATEGORY_EVENT)
	client.holder.modify_goals()

/datum/admins/proc/modify_goals()
	if(SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(usr, SPAN_WARNING("This verb can only be used if the round has started."))
		return

	var/list/dat = list("<!DOCTYPE html>")
	for(var/datum/station_goal/S in SSticker.mode.station_goals)
		dat += "[S.name][S.completed ? " (C)" : ""] - <a href='byond://?src=[S.UID()];announce=1'>Announce</a> | <a href='byond://?src=[S.UID()];remove=1'>Remove</a>"
	dat += ""
	dat += "<a href='byond://?src=[UID()];add_station_goal=1'>Add New Goal</a>"
	dat += ""
	dat += "<b>Secondary goals</b>"
	for(var/datum/station_goal/secondary/SG in SSticker.mode.secondary_goals)
		dat += "[SG.admin_desc][SG.completed ? " (C)" : ""] for [SG.requester_name || SG.department] - <a href='byond://?src=[SG.UID()];announce=1'>Announce</a> | <a href='byond://?src=[SG.UID()];remove=1'>Remove</a> | <a href='byond://?src=[SG.UID()];mark_complete=1'>Mark complete</a> | <a href='byond://?src=[SG.UID()];reset_progress=1'>Reset progress</a>"
	dat += "<a href='byond://?src=[UID()];add_secondary_goal=1'>Add New Secondary Goal</a>"

	usr << browse(dat.Join("<br>"), "window=goals;size=400x400")

/// Allow admin to add or remove traits of datum
/datum/admins/proc/modify_traits(datum/D)
	if(!D)
		return

	var/add_or_remove = tgui_input_list(usr, "Add or Remove Trait?", "Modify Trait", list("Add","Remove"))
	if(!add_or_remove)
		return
	var/list/availible_traits = list()

	switch(add_or_remove)
		if("Add")
			for(var/key in GLOB.traits_by_type)
				if(istype(D, key))
					availible_traits += GLOB.traits_by_type[key]
		if("Remove")
			if(!GLOB.trait_name_map)
				GLOB.trait_name_map = generate_trait_name_map()
			for(var/trait in D.status_traits)
				var/name = GLOB.trait_name_map[trait] || trait
				availible_traits[name] = trait

	var/chosen_trait = tgui_input_list(usr, "Select trait to modify.", "Traits", availible_traits)
	if(!chosen_trait)
		return
	chosen_trait = availible_traits[chosen_trait]

	var/source = "adminabuse"
	switch(add_or_remove)
		if("Add") //Not doing source choosing here intentionally to make this bit faster to use, you can always vv it.
			ADD_TRAIT(D, chosen_trait, source)
		if("Remove")
			var/specific = tgui_input_list(usr, "All or from a specific source?", "Add or Remove Trait", list("All","Specific"))
			if(!specific)
				return
			switch(specific)
				if("All")
					source = null
				if("Specific")
					source = tgui_input_list(usr, "Source to be removed?", "Add or Remove Trait", D.status_traits[chosen_trait])
					if(!source)
						return
			REMOVE_TRAIT(D, chosen_trait, source)

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
