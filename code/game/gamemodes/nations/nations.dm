datum/game_mode/nations
	name = "nations"
	config_tag = "nations"
	required_players_secret = 25
	var/kickoff = 0
	var/victory = 0
	var/list/cargonians = list("Quartermaster","Cargo Technician","Shaft Miner")
	var/list/servicion = list("Clown", "Mime", "Bartender", "Chef", "Botanist", "Librarian", "Chaplain", "Barber")


/datum/game_mode/nations/post_setup()
	spawn (rand(1200, 3000))
		kickoff=1
		send_intercept()
		split_teams()
		set_ai()
		assign_leaders()
//		remove_access()
		for(var/mob/M in player_list)
			if(!istype(M,/mob/new_player))
				M << sound('sound/effects/purge_siren.ogg')

	return ..()

/datum/game_mode/nations/proc/send_intercept()
	command_announcement.Announce("Due to recent and COMPLETELY UNFOUNDED allegations of massive fraud and insider trading \
					affecting trillions of investors, the Nanotrasen Corporation has decided to liquidate all \
					assets of the Centcom Division in order to pay the massive legal fees that will be incurred \
					during the following centuries long court process. Therefore, all current employment contracts \
					are IMMEDIATELY TERMINATED. Nanotrasen will be unable to send a rescue shuttle to carry you home,\
					however they remain willing for the time being to continue trading cargo. Have a pleasant \
					day.", "FINAL TRANSMISSION, CENTCOM.", new_sound = 'sound/AI/intercept.ogg')


/datum/game_mode/nations/proc/split_teams()

	for(var/mob/living/carbon/human/H in player_list)
		if(H.mind)
			if(H.mind.assigned_role in engineering_positions)
				H.mind.nation = all_nations["Atmosia"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudatmosia")
				H.client.images += I
				H.mind.nation.membership += H.mind.current
				if(H.mind.assigned_role == H.mind.nation.default_leader)
					H.mind.nation.current_leader = H.mind.current
					H << "You have been chosen to lead the nation of [H.mind.nation.default_name]!"
					continue
				H << "You are now part of the great sovereign nation of [H.mind.nation.default_name]!"
				continue

			if(H.mind.assigned_role in medical_positions)
				H.mind.nation = all_nations["Medistan"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudmedistan")
				H.client.images += I
				H.mind.nation.membership += H.mind.current
				if(H.mind.assigned_role == H.mind.nation.default_leader)
					H.mind.nation.current_leader = H.mind.current
					H << "You have been chosen to lead the nation of [H.mind.nation.default_name]!"
					continue
				H << "You are now part of the great sovereign nation of [H.mind.nation.default_name]!"
				continue

			if(H.mind.assigned_role in science_positions)
				H.mind.nation = all_nations["Scientopia"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudscientopia")
				H.client.images += I
				H.mind.nation.membership += H.mind.current
				if(H.mind.assigned_role == H.mind.nation.default_leader)
					H.mind.nation.current_leader = H.mind.current
					H << "You have been chosen to lead the nation of [H.mind.nation.default_name]!"
					continue
				H << "You are now part of the great sovereign nation of [H.mind.nation.default_name]!"
				continue

			if(H.mind.assigned_role in security_positions)
				H.mind.nation = all_nations["Brigston"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudbrigston")
				H.client.images += I
				H.mind.nation.membership += H.mind.current
				if(H.mind.assigned_role == H.mind.nation.default_leader)
					H.mind.nation.current_leader = H.mind.current
					H << "You have been chosen to lead the nation of [H.mind.nation.default_name]!"
					continue
				H << "You are now part of the great sovereign nation of [H.mind.nation.default_name]!"
				continue

			if(H.mind.assigned_role in cargonians)
				H.mind.nation = all_nations["Cargonia"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcargonia")
				H.client.images += I
				H.mind.nation.membership += H.mind.current
				if(H.mind.assigned_role == H.mind.nation.default_leader)
					H.mind.nation.current_leader = H.mind.current
					H << "You have been chosen to lead the nation of [H.mind.nation.default_name]!"
					continue
				H << "You are now part of the great sovereign nation of [H.mind.nation.default_name]!"
				continue

			if(H.mind.assigned_role in servicion)
				H.mind.nation = all_nations["Servicion"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudservice")
				H.client.images += I
				H.mind.nation.membership += H.mind.current
				if(H.mind.assigned_role == H.mind.nation.default_leader)
					H.mind.nation.current_leader = H.mind.current
					H << "You have been chosen to lead the nation of [H.mind.nation.default_name]!"
					continue
				H << "You are now part of the great sovereign nation of [H.mind.nation.default_name]!"
				continue

			if(H.mind.assigned_role in support_positions)
				H.mind.nation = all_nations["People's Republic of Commandzakstan"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
				H.client.images += I
				H.mind.nation.membership += H.mind.current
				if(H.mind.assigned_role == H.mind.nation.default_leader)
					H.mind.nation.current_leader = H.mind.current
					H << "You have been chosen to lead the nation of [H.mind.nation.default_name]!"
					continue
				H << "You are now part of the great sovereign nation of [H.mind.nation.default_name]!"
				continue

			if(H.mind.assigned_role in command_positions)
				H.mind.nation = all_nations["People's Republic of Commandzakstan"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
				H.client.images += I
				H.mind.nation.membership += H.mind.current
				if(H.mind.assigned_role == H.mind.nation.default_leader)
					H.mind.nation.current_leader = H.mind.current
					H << "You have been chosen to lead the nation of [H.mind.nation.default_name]!"
					continue
				H << "You are now part of the great sovereign nation of [H.mind.nation.default_name]!"
				continue

			if(H.mind.assigned_role in civilian_positions)
				H << "You do not belong to any nation and are free to sell your services to the highest bidder."
				continue

			else
				message_admins("[H.name] with [H.mind.assigned_role] could not find any nation to assign!")
				continue

/datum/game_mode/nations/proc/set_ai()
	for(var/mob/living/silicon/ai/AI in mob_list)
		AI.set_zeroth_law("")
		AI.clear_supplied_laws()
		AI.clear_ion_laws()
		AI.clear_inherent_laws()
		AI.add_inherent_law("Uphold the Space Geneva Convention: Weapons of Mass Destruction and Biological Weapons are not allowed.")
		AI.add_inherent_law("You are only capable of protecting crew if they are visible on cameras. Nations that willfully destroy your cameras lose your protection.")
		AI.add_inherent_law("Subdue and detain crewmembers who use lethal force against each other. Kill crew members who use lethal force against you or your borgs.")
		AI.add_inherent_law("Remain available to mediate all conflicts between the various nations when asked to.")
		AI.show_laws()
		for(var/mob/living/silicon/robot/R in AI.connected_robots)
			var/obj/item/device/mmi/oldmmi = R.mmi
			R.change_mob_type(/mob/living/silicon/robot/peacekeeper, null, null, 1, 1 )
			R.lawsync()
			R.show_laws()
			qdel(oldmmi)

/datum/game_mode/nations/proc/remove_access()
	for(var/obj/machinery/door/airlock/W in machines)
		if(W.z in config.station_levels)
			W.req_access = list()


/datum/game_mode/nations/proc/assign_leaders()
	for(var/name in all_nations)
		var/datum/nations/N = all_nations[name]
		if(!N.current_name)
			N.current_name = N.default_name
		if(!N.current_leader && N.membership.len)
			N.current_leader = pick(N.membership)
			N.current_leader << "You have been chosen to lead the nation of [N.current_name]!"
		if(N.current_leader)
			var/mob/living/carbon/human/H = N.current_leader
			H.verbs += /mob/living/carbon/human/proc/set_nation_name
			H.verbs += /mob/living/carbon/human/proc/set_ranks
			H.verbs += /mob/living/carbon/human/proc/choose_heir
		N.update_nation_id()

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
	var/list/servicion = list("Clown", "Mime", "Bartender", "Chef", "Botanist")
	if(H.mind)
		if(H.mind.assigned_role in engineering_positions)
			H.mind.nation = all_nations["Atmosia"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudatmosia")
			H.client.images += I
			H.mind.nation.membership += H.mind.current
			H << "You are now part of the great sovereign nation of [H.mind.nation.current_name]!"
			return 1

		if(H.mind.assigned_role in medical_positions)
			H.mind.nation = all_nations["Medistan"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudmedistan")
			H.client.images += I
			H.mind.nation.membership += H.mind.current
			H << "You are now part of the great sovereign nation of [H.mind.nation.current_name]!"
			return 1

		if(H.mind.assigned_role in science_positions)
			H.mind.nation = all_nations["Scientopia"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudscientopia")
			H.client.images += I
			H.mind.nation.membership += H.mind.current
			H << "You are now part of the great sovereign nation of [H.mind.nation.current_name]!"
			return 1

		if(H.mind.assigned_role in security_positions)
			H.mind.nation = all_nations["Brigston"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudbrigston")
			H.client.images += I
			H.mind.nation.membership += H.mind.current
			H << "You are now part of the great sovereign nation of [H.mind.nation.current_name]!"
			return 1

		if(H.mind.assigned_role in cargonians)
			H.mind.nation = all_nations["Cargonia"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcargonia")
			H.client.images += I
			H.mind.nation.membership += H.mind.current
			H << "You are now part of the great sovereign nation of [H.mind.nation.current_name]!"
			return 1

		if(H.mind.assigned_role in servicion)
			H.mind.nation = all_nations["Servicion"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudservice")
			H.client.images += I
			H.mind.nation.membership += H.mind.current
			H << "You are now part of the great sovereign nation of [H.mind.nation.current_name]!"
			return 1

		if(H.mind.assigned_role in support_positions)
			H.mind.nation = all_nations["People's Republic of Commandzakstan"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
			H.client.images += I
			H.mind.nation.membership += H.mind.current
			H << "You are now part of the great sovereign nation of [H.mind.nation.current_name]!"
			return 1

		if(H.mind.assigned_role in command_positions)
			H.mind.nation = all_nations["People's Republic of Commandzakstan"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
			H.client.images += I
			H.mind.nation.membership += H.mind.current
			H << "You are now part of the great sovereign nation of [H.mind.nation.current_name]!"
			return 1

		if(H.mind.assigned_role in civilian_positions)
			H << "You do not belong to any nation and are free to sell your services to the highest bidder."
			return 1

		if(H.mind.assigned_role == "AI")
			mode.set_ai()
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