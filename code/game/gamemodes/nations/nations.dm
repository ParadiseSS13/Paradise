var/global/no_synthetic = 0

datum/game_mode/nations
	name = "nations"
	config_tag = "nations"
	required_players_secret = 25
	var/const/waittime_l = 1200 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 3000 //upper bound on time before intercept arrives (in tenths of seconds)
	var/kickoff = 0
	var/victory = 0
	var/list/cargonians = list("Quartermaster","Cargo Technician","Shaft Miner")

/datum/game_mode/nations/pre_pre_setup()
	no_synthetic = 1

/datum/game_mode/nations/post_setup()
	spawn (rand(waittime_l, waittime_h))
		remove_flags()
		spawn(50)
			kickoff=1
			send_intercept()
			split_teams()
			spawn_flags()
			populate_vars()
			for(var/mob/M in player_list)
				if(!istype(M,/mob/new_player))
					M << sound('sound/effects/purge_siren.ogg')
	return ..()

/datum/game_mode/nations/send_intercept()
	command_alert("Due to recent and COMPLETELY UNFOUNDED allegations of massive fraud and insider trading \
					affecting trillions of investors, the Nanotrasen Corporation has decided to liquidate all \
					assets of the Centcom Division in order to pay the massive legal fees that will be incurred \
					during the following centuries long court process. Therefore, all current employment contracts \
					are IMMEDIATELY TERMINATED. Nanotrasen will be unable to send a rescue shuttle to carry you home,\
					however they remain willing for the time being to continue trading cargo. Have a pleasant \
					day.", "FINAL TRANSMISSION, CENTCOM COMMAND.")



/datum/game_mode/nations/proc/remove_flags()
	for(var/obj/item/flag/F in world)
		del(F)

/datum/game_mode/nations/proc/spawn_flags()

	for(var/obj/effect/landmark/nations/N in landmarks_list)
		switch(N.name)
			if("Atmosia")
				new /obj/item/flag/nation/atmos(get_turf(N))
			if("Brigston")
				new /obj/item/flag/nation/sec(get_turf(N))
			if("Cargonia")
				new /obj/item/flag/nation/cargo(get_turf(N))
			if("People's Republic of Commandzakstan")
				new /obj/item/flag/nation/command(get_turf(N))
			if("Medistan")
				new /obj/item/flag/nation/med(get_turf(N))
			if("Scientopia")
				new /obj/item/flag/nation/rnd(get_turf(N))

/datum/game_mode/nations/proc/split_teams()

	for(var/mob/living/carbon/human/H in player_list)
		if(H.mind)
			if(H.mind.assigned_role in engineering_positions)
				H.mind.nation = all_nations["Atmosia"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudatmosia")
				H.client.images += I
				H.verbs += /mob/proc/respawn_self
				H.verbs += /mob/proc/nations_status
				H.verbs -= /mob/living/verb/ghost
				H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue
			else if(H.mind.assigned_role in medical_positions)
				H.mind.nation = all_nations["Medistan"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudmedistan")
				H.client.images += I
				H.verbs += /mob/proc/respawn_self
				H.verbs += /mob/proc/nations_status
				H.verbs -= /mob/living/verb/ghost
				H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue
			else if(H.mind.assigned_role in science_positions)
				H.mind.nation = all_nations["Scientopia"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudscientopia")
				H.client.images += I
				H.verbs += /mob/proc/respawn_self
				H.verbs += /mob/proc/nations_status
				H.verbs -= /mob/living/verb/ghost
				H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue
			else if(H.mind.assigned_role in security_positions)
				H.mind.nation = all_nations["Brigston"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudbrigston")
				H.client.images += I
				H.verbs += /mob/proc/respawn_self
				H.verbs += /mob/proc/nations_status
				H.verbs -= /mob/living/verb/ghost
				H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue
			else if(H.mind.assigned_role in cargonians)
				H.mind.nation = all_nations["Cargonia"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcargonia")
				H.client.images += I
				H.verbs += /mob/proc/respawn_self
				H.verbs += /mob/proc/nations_status
				H.verbs -= /mob/living/verb/ghost
				H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue
			else if(H.mind.assigned_role in support_positions)
				H.mind.nation = all_nations["People's Republic of Commandzakstan"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
				H.client.images += I
				H.verbs += /mob/proc/respawn_self
				H.verbs += /mob/proc/nations_status
				H.verbs -= /mob/living/verb/ghost
				H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue
			else if(H.mind.assigned_role in command_positions)
				H.mind.nation = all_nations["People's Republic of Commandzakstan"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
				H.client.images += I
				H.verbs += /mob/proc/respawn_self
				H.verbs += /mob/proc/nations_status
				H.verbs -= /mob/living/verb/ghost
				H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue
			else
				message_admins("[H.name] with [H.mind.assigned_role] could not find any nation to assign!")
				continue

/datum/game_mode/nations/proc/populate_vars()
	for(var/obj/effect/landmark/nations/N in landmarks_list)
		switch(N.name)
			if("Atmosia")
				for(var/obj/item/flag/nation/atmos/A in flag_list)
					A.startloc = get_turf(N)
					continue
			if("Brigston")
				for(var/obj/item/flag/nation/sec/B in flag_list)
					B.startloc = get_turf(N)
					continue
			if("Cargonia")
				for(var/obj/item/flag/nation/cargo/C in flag_list)
					C.startloc = get_turf(N)
					continue
			if("People's Republic of Commandzakstan")
				for(var/obj/item/flag/nation/command/D in flag_list)
					D.startloc = get_turf(N)
					continue
			if("Medistan")
				for(var/obj/item/flag/nation/med/M in flag_list)
					M.startloc = get_turf(N)
					continue
			if("Scientopia")
				for(var/obj/item/flag/nation/rnd/S in flag_list)
					S.startloc = get_turf(N)
					continue

/datum/game_mode/nations/check_finished()
	if(victory)
		return 1
	return 0

/datum/game_mode/nations/declare_completion(var/datum/nations/N)
	world << "[N.name] has captured all of the station. All glory to [N.name]"
	victory = 1



/mob/proc/nations_status()
	set category = "OOC"
	set name = "Nation Status"
	set desc = "Information on your nation and your allies."

	if (!( ticker )) return
	if (ticker.mode.name != "nations") return
	if(!mind) return
	if(!mind.nation) return

	var/obj/item/flag/nation/F = locate(mind.nation.flagpath)

	var/dat = "<html><head><title>Nation Status</title></head><body><h1><B>Nation Status</B></h1>"

	dat += "You are part of the nation of <B>[mind.nation.name]</B>.<BR>"
	dat += "You -cannot- defect to another nation. Doing so or helping<br>"
	dat += "another nation you are not a vassal of is bannable.<br>"

	dat += "<br><table cellspacing=5><tr><td><B>Liege</B></td><td></td></tr>"
	if(F.liege)
		dat += "You are currently the vassal of [F.liege.name] and must obey<br>"
		dat += "the commands of ANY of their members.<br>"
	else
		dat += "You are not currently vassalized by anyone! Protect your flag!<br>"
	dat += "</table>"

	dat += "<br><table cellspacing=5><tr><td><B>Vassals</B></td><td></td></tr>"
	if(F.vassals.len)
		for(var/datum/nations/V in F.vassals)
			dat += "[V.name] is your vassal and must obey the commands of ANY of your members."
	else
		dat += "You do not currently have any vassals! Capture flags to vassalize!<br>"
	dat += "</table>"
	dat += "<br><table cellspacing=5><tr><td><B>Geneva Space Convention</B></td><td></td></tr>"
	dat += "The following are considered OUTLAWED by the Geneva Space Convention and will result"
	dat += "in severe consequences if used in warfare:<br>"
	dat += "<B>Scientopia - Large Scale Bombs - Nuclear Warfare"
	dat += "Atmosia - Using atmos as a weapon - Chemical Warfare"
	dat += "Medistan - Releasing harmful viruses - Biological Warfare</B>"
	dat += "</table>"

	dat += "</body></html>"
	usr << browse(dat, "window=nationstatus;size=400x500")

/mob/proc/respawn_self()
	set category = "OOC"
	set name = "Respawn Character"
	set desc = "Respawn yourself (15 minute cooldown)."

	if (!( ticker ))
		usr << "\blue <B>The round hasn't started!</B>"
		return
	if(stat!=2)
		usr << "\blue You must be dead to respawn."
		return
	if (ticker.mode.name != "nations")
		usr << "\blue Respawn is disabled."
		return
	if(!mind)
		return
	if(!mind.nation)
		src << "It appears you're not part of a nation. Use Respawn as NPC instead."
		return
	if(!mind.assigned_role)
		src << "It appears you're not part of a nation. Use Respawn as NPC instead."
		return
	if(!mind.assigned_role in get_all_jobs())
		src << "It appears you're not part of a nation. Use Respawn as NPC instead."
		return
	if(mind.special_role)
		src << "It appears you beame an antag and are longer part of a nation. Use Respawn as NPC instead."
		return
	else
		var/deathtime = world.time - src.timeofdeath
		var/deathtimeminutes = round(deathtime / 600)
		var/pluralcheck = "minute"
		if(deathtimeminutes == 0)
			pluralcheck = ""
		else if(deathtimeminutes == 1)
			pluralcheck = " [deathtimeminutes] minute and"
		else if(deathtimeminutes > 1)
			pluralcheck = " [deathtimeminutes] minutes and"
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
		usr << "You have been dead for[pluralcheck] [deathtimeseconds] seconds."
		if (deathtime < 9000)
			usr << "You must wait 15 minutes to respawn!"
			return
		else

			//Ok, it's not a xeno or a monkey. So, spawn a human.
			var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

			var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
			if(mind)	//mind isn't currently in use by someone/something
				/*Try and locate a record for the person being respawned through data_core.
				This isn't an exact science but it does the trick more often than not.*/
				var/id = md5("[real_name][mind.assigned_role]")
				for(var/datum/data/record/t in data_core.locked)
					if(t.fields["id"]==id)
						record_found = t//We shall now reference the record.
						break

			if(record_found)//If they have a record we can determine a few things.
				new_character.real_name = record_found.fields["name"]
				new_character.gender = record_found.fields["sex"]
				new_character.age = record_found.fields["age"]
				new_character.b_type = record_found.fields["b_type"]
			else
				new_character.gender = pick(MALE,FEMALE)
				var/datum/preferences/A = new()
				A.randomize_appearance_for(new_character)
				new_character.real_name = real_name

			if(!new_character.real_name)
				if(new_character.gender == MALE)
					new_character.real_name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
				else
					new_character.real_name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
			new_character.name = new_character.real_name

			if(mind)
				mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
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

			new_character.key = key

			job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

			if(!record_found)//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
				data_core.manifest_inject(new_character)

			new_character << "You have been fully respawned. Get back in the fight!."
			new_character.hud_updateflag |= 1 << NATIONS_HUD
			return new_character



/**
 * LateSpawn hook.
 * Called in newplayer.dm when a humanoid character joins the round after it started.
 * Parameters: var/mob/living/carbon/human, var/rank
 */
/hook/latespawn/proc/give_latejoiners_nations(var/mob/living/carbon/human/H)
	var/datum/game_mode/nations/mode = get_nations_mode()
	if (!mode) return 1

	if(!mode.kickoff) return 1

	var/list/cargonians = list("Quartermaster","Cargo Technician","Shaft Miner")
	if(H.mind)
		if(H.mind.assigned_role in engineering_positions)
			H.mind.nation = all_nations["Atmosia"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudatmosia")
			H.client.images += I
			H.verbs += /mob/proc/respawn_self
			H.verbs += /mob/proc/nations_status
			H.verbs -= /mob/living/verb/ghost
			H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1
		else if(H.mind.assigned_role in medical_positions)
			H.mind.nation = all_nations["Medistan"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudmedistan")
			H.client.images += I
			H.verbs += /mob/proc/respawn_self
			H.verbs += /mob/proc/nations_status
			H.verbs -= /mob/living/verb/ghost
			H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1
		else if(H.mind.assigned_role in science_positions)
			H.mind.nation = all_nations["Scientopia"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudscientopia")
			H.client.images += I
			H.verbs += /mob/proc/respawn_self
			H.verbs += /mob/proc/nations_status
			H.verbs -= /mob/living/verb/ghost
			H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1
		else if(H.mind.assigned_role in security_positions)
			H.mind.nation = all_nations["Brigston"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudbrigston")
			H.client.images += I
			H.verbs += /mob/proc/respawn_self
			H.verbs += /mob/proc/nations_status
			H.verbs -= /mob/living/verb/ghost
			H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1
		else if(H.mind.assigned_role in cargonians)
			H.mind.nation = all_nations["Cargonia"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcargonia")
			H.client.images += I
			H.verbs += /mob/proc/respawn_self
			H.verbs += /mob/proc/nations_status
			H.verbs -= /mob/living/verb/ghost
			H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1
		else if(H.mind.assigned_role in support_positions)
			H.mind.nation = all_nations["People's Republic of Commandzakstan"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
			H.client.images += I
			H.verbs += /mob/proc/respawn_self
			H.verbs += /mob/proc/nations_status
			H.verbs -= /mob/living/verb/ghost
			H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1
		else if(H.mind.assigned_role in command_positions)
			H.mind.nation = all_nations["People's Republic of Commandzakstan"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
			H.client.images += I
			H.verbs += /mob/proc/respawn_self
			H.verbs += /mob/proc/nations_status
			H.verbs -= /mob/living/verb/ghost
			H.equip_or_collect(new /obj/item/weapon/pinpointer/advpinpointer/flag(H), slot_r_hand)
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1
		else
			message_admins("[H.name] with [H.mind.assigned_role] could not find any nation to assign!")
			return 1
	message_admins("[H.name] latejoined with no mind.")
	return 1

/proc/get_nations_mode()
	if(!ticker || !istype(ticker.mode, /datum/game_mode/nations))
		return null

	return ticker.mode