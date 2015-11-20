datum/game_mode/nations
	name = "nations"
	config_tag = "nations"
	required_players_secret = 25
	var/kickoff = 0
	var/victory = 0
	var/list/cargonians = list("Quartermaster","Cargo Technician","Shaft Miner")


/datum/game_mode/nations/post_setup()
	spawn (rand(1200, 3000))
		kickoff=1
		send_intercept()
		split_teams()
		set_ai()
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
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue

			if(H.mind.assigned_role in medical_positions)
				H.mind.nation = all_nations["Medistan"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudmedistan")
				H.client.images += I
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue

			if(H.mind.assigned_role in science_positions)
				H.mind.nation = all_nations["Scientopia"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudscientopia")
				H.client.images += I
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue

			if(H.mind.assigned_role in security_positions)
				H.mind.nation = all_nations["Brigston"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudbrigston")
				H.client.images += I
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue

			if(H.mind.assigned_role in cargonians)
				H.mind.nation = all_nations["Cargonia"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcargonia")
				H.client.images += I
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue

			if(H.mind.assigned_role in support_positions)
				H.mind.nation = all_nations["People's Republic of Commandzakstan"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
				H.client.images += I
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue

			if(H.mind.assigned_role in command_positions)
				H.mind.nation = all_nations["People's Republic of Commandzakstan"]
				H.hud_updateflag |= 1 << NATIONS_HUD
				var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
				H.client.images += I
				H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
				continue

		if(H.mind.assigned_role in civilian_positions)
			H << "You do not belong to any nation and are free to sell your services to the highest bidder."
			continue

			else
				message_admins("[H.name] with [H.mind.assigned_role] could not find any nation to assign!")
				continue

/datum/game_mode/nations/proc/set_ai()
	for(var/mob/living/silicon/ai/AI in mob_list)
		AI.laws = new (pick(subtypesof(/datum/ai_laws/nations)))
		AI.show_laws()
		for(var/mob/living/silicon/robot/R in AI.connected_robots)
			R.lawsync()
			R.show_laws()

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
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1

		if(H.mind.assigned_role in medical_positions)
			H.mind.nation = all_nations["Medistan"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudmedistan")
			H.client.images += I
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1

		if(H.mind.assigned_role in science_positions)
			H.mind.nation = all_nations["Scientopia"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudscientopia")
			H.client.images += I
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1

		if(H.mind.assigned_role in security_positions)
			H.mind.nation = all_nations["Brigston"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudbrigston")
			H.client.images += I
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1

		if(H.mind.assigned_role in cargonians)
			H.mind.nation = all_nations["Cargonia"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcargonia")
			H.client.images += I
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1

		if(H.mind.assigned_role in support_positions)
			H.mind.nation = all_nations["People's Republic of Commandzakstan"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
			H.client.images += I
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1

		if(H.mind.assigned_role in command_positions)
			H.mind.nation = all_nations["People's Republic of Commandzakstan"]
			H.hud_updateflag |= 1 << NATIONS_HUD
			var/I = image('icons/mob/hud.dmi', loc = H.mind.current, icon_state = "hudcommand")
			H.client.images += I
			H << "You are now part of the great sovereign nation of [H.mind.nation.name]!"
			return 1

		if(H.mind.assigned_role in civilian_positions)
			H << "You do not belong to any nation and are free to sell your services to the highest bidder."
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