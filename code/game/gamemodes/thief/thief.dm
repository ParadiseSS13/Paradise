/datum/game_mode
	var/list/datum/mind/thieves = list()

/datum/game_mode/thief
	name = "thief"
	config_tag = "thief"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Cadet", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Nanotrasen Navy Field Officer", "Special Operations Officer", "Supreme Commander", "Syndicate Officer")
	prefered_species = list("Vox")
	prefered_species_mod = 4
	required_players = 0
	required_enemies = 1
	recommended_enemies = 3

	var/thieves_amount = 3

/datum/game_mode/thief/announce()
	to_chat(world, "<B>The current game mode is - thief!</B>")
	to_chat(world, "<B>На станции зафиксирована деятельность гильдии воров. Не допустите кражу дорогостоящего оборудования!</B>")

/datum/game_mode/thief/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_thieves = get_players_for_role(ROLE_THIEF)

	var/thieves_scale = 15
	if(config.traitor_scaling)
		thieves_scale = config.traitor_scaling
	thieves_amount = 1 + round(num_players() / thieves_scale)
	add_game_logs("Number of  thieves chosen: [thieves_amount]")

	if(possible_thieves.len>0)
		for(var/i = 0, i < thieves_amount, i++)
			if(!possible_thieves.len) break
			var/datum/mind/M = pick(possible_thieves)
			possible_thieves -= M
			thieves += M
			M.restricted_roles = restricted_jobs
			modePlayer += thieves
			M.special_role = SPECIAL_ROLE_THIEF
		..()
		return 1
	else
		return 0

/datum/game_mode/thief/post_setup()
	for(var/datum/mind/thief in thieves)
		thief.make_Thief()
	..()

/datum/game_mode/proc/forge_thief_objectives(datum/mind/thief)
	var/datum/objective/thief_objective

	//Hard objective
	if(prob(30))
		thief_objective = new /datum/objective/steal
	else
		thief_objective = new /datum/objective/steal/hard
	thief_objective.owner = thief
	thief_objective.find_target()
	thief.objectives += thief_objective

	//Medium objective
	if(prob(50))
		thief_objective = new /datum/objective/steal_pet
	else if(prob(70))
		thief_objective = new /datum/objective/steal/medium
	else
		thief_objective = new /datum/objective/steal_structure
	thief_objective.owner = thief
	thief_objective.find_target()
	thief.objectives += thief_objective

	//Collect objective
	if(prob(70))
		thief_objective = new /datum/objective/collect
		thief_objective.owner = thief
		thief_objective.find_target()
		thief.objectives += thief_objective
	else
		var/datum/objective/get_money/money_objective = new
		money_objective.owner = thief
		thief.objectives += money_objective
		money_objective.new_cash(accounts_procent = 50)


	//Escape objective
	if(!(locate(/datum/objective/escape) in thief.objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = thief
		thief.objectives += escape_objective
	return

/datum/game_mode/proc/greet_thief(datum/mind/thief, you_are=1)
	SEND_SOUND(thief.current, 'sound/ambience/antag/thiefalert.ogg')
	if(you_are)
		to_chat(thief.current, "<span class='danger'>Вы член гильдии воров!</span>")
	to_chat(thief.current, "<span class='danger'>Гильдия воров прислала новые заказы для кражи. Пора заняться старым добрым ремеслом, пока цели не украли конкуренты!</span>")
	to_chat(thief.current, "<B>Вам необходимо преуспеть в целях:</B>")
	if(thief.current.mind)
		if(thief.current.mind.assigned_role == "Clown")
			to_chat(thief.current, "Вы превзошли свою клоунскую натуру, ваши ловкие пальцы нивелировали былую неуклюжесть!")
			thief.current.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(thief.current)
	var/obj_count = 1
	for(var/datum/objective/objective in thief.objectives)
		to_chat(thief.current, "<B>Цель #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return

/datum/game_mode/proc/remove_thief(datum/mind/thief_mind)
	if(thief_mind in thieves)
		thieves -= thief_mind
		thief_mind.memory = ""
		thief_mind.special_role = null
		if(issilicon(thief_mind.current))
			to_chat(thief_mind.current, "<span class='userdanger'>Вы киборгизированы!</span>")
			to_chat(thief_mind.current, "<span class='danger'>Вы должны подчиняться своим законам и подчиняться мастеру ИИ. Ваши цели более недействительны.</span>")
		else
			to_chat(thief_mind.current, "<FONT color='red' size = 3><B>Вы встали на праведный путь и Гильдия Воров изгнала вас! Вы больше не вор!</B></FONT>")
		update_thief_icons_removed(thief_mind)

/datum/game_mode/proc/update_thief_icons_added(datum/mind/thief)
	var/datum/atom_hud/antag/thiefhud = GLOB.huds[ANTAG_HUD_THIEF]
	thiefhud.join_hud(thief.current)
	set_antag_hud(thief.current, "hudthief")

/datum/game_mode/proc/update_thief_icons_removed(datum/mind/thief)
	var/datum/atom_hud/antag/thiefhud = GLOB.huds[ANTAG_HUD_THIEF]
	thiefhud.leave_hud(thief.current)
	set_antag_hud(thief.current, null)

/datum/game_mode/proc/equip_thief(mob/living/carbon/thief)
	if(!istype(thief))
		return
	if(thief.back)
		thief.equip_to_slot(new /obj/item/thief_kit(thief), slot_in_backpack)
		to_chat(thief, "<span class='notice'>Набор гильдии воров находится у вас в рюкзаке.</span>")
	else
		thief.equip_to_appropriate_slot(new /obj/item/thief_kit(thief))

/datum/game_mode/proc/auto_declare_completion_thief()
	if(thieves.len)
		var/text = "<FONT size = 3><B>Воры в розыске:</B></FONT><br>"
		for(var/datum/mind/thief in thieves)
			var/thiefwin = 1
			text += printplayer(thief) + "<br>"

			if(thief.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in thief.objectives)
					if(objective.check_completion())
						text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='green'><B>Выполнена!</B></font><br>"
						SSblackbox.record_feedback("nested tally", "thief_objective", 1, list("[objective.type]", "SUCCESS"))
					else
						text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='red'>Провалена.</font><br>"
						SSblackbox.record_feedback("nested tally", "thief_objective", 1, list("[objective.type]", "FAIL"))
						thiefwin = 0
					count++

			if(thiefwin)
				text += "<br><font color='green'><B>Вор преуспел!</B></font><br>"
				SSblackbox.record_feedback("tally", "thief_success", 1, "SUCCESS")
			else
				text += "<br><font color='red'><B>Вор провалился.</B></font><br>"
				SSblackbox.record_feedback("tally", "thief_success", 1, "FAIL")

		to_chat(world, text)

	return 1
