/datum/game_mode
	var/list/datum/mind/space_ninjas = list()

/datum/game_mode/space_ninja
	name = "Space Ninja"
	config_tag = "space-ninja"
	required_players = 25
	required_enemies = 1
	recommended_enemies = 1
	var/use_huds = 1
	var/finished = 0
	var/but_wait_theres_more = 0


/datum/game_mode/space_ninja/announce()
	to_chat(world, "<B>>Текущий игровой режим — Космический Ниндзя!</B>")
	to_chat(world, "<B>На станцию проник опасный наёмник из клана Паука. Более известный как Космический Ниндзя. Какие бы он не преследовал цели, станция в опасности!</B>")

/datum/game_mode/space_ninja/can_start()
	if(!..())
		return FALSE
	var/list/datum/mind/possible_ninjas = get_players_for_role(ROLE_NINJA)
	if(!length(possible_ninjas))
		return FALSE
	var/datum/mind/space_ninja = pick(possible_ninjas)

	space_ninjas += space_ninja
	modePlayer += space_ninja
	space_ninja.assigned_role = SPECIAL_ROLE_SPACE_NINJA //So they aren't chosen for other jobs.
	space_ninja.special_role = SPECIAL_ROLE_SPACE_NINJA
	space_ninja.original = space_ninja.current
	if(!length(GLOB.ninjastart))
		to_chat(space_ninja.current, span_danger("A starting location for you could not be found, please report this bug!"))
		return FALSE
	return TRUE

/datum/game_mode/space_ninja/pre_setup()
	for(var/datum/mind/ninja in space_ninjas)
		ninja.current.loc = pick(GLOB.ninjastart)
	..()
	return TRUE

/datum/game_mode/space_ninja/post_setup()
	for(var/datum/mind/space_ninja_mind in space_ninjas)
		add_game_logs("has been selected as a Space Ninja", space_ninja_mind.current)
		INVOKE_ASYNC(src, .proc/name_ninja, space_ninja_mind.current)
		equip_space_ninja(space_ninja_mind.current)
		give_ninja_datum(space_ninja_mind)
		forge_ninja_objectives(space_ninja_mind)
		greet_ninja(space_ninja_mind)
		basic_ninja_needs_check(space_ninja_mind)
		if(use_huds)
			update_ninja_icons_added(space_ninja_mind)
	..()

// Прок выдающий Нинзя-Датум отвечающий за уникальный игровой интерфейс ниндзя
// И за статус панель. Сам датум задан в конце этого файла.
/datum/game_mode/proc/give_ninja_datum(datum/mind/ninja_mind)
	var/datum/ninja/nin_datum = new
	var/mob/living/carbon/human/ninja = ninja_mind.current
	var/list/ninja_contents = ninja.get_contents()
	// Удаляем старый датум - если есть и переносим с него важные данные
	if(ninja_mind.ninja)
		nin_datum.purchased_abilities = ninja_mind.ninja.purchased_abilities
		qdel(ninja_mind.ninja)
	// Вписываем сам датум
	ninja_mind.ninja = nin_datum
	// Моб, владелец датума
	nin_datum.owner = ninja_mind.current
	// Это тут скорее на всякий случай...
	nin_datum.gender = ninja.gender
	// Записываем костюм дабы до него было легко дотянуться и считать данные для интерфейса
	nin_datum.my_suit = locate(/obj/item/clothing/suit/space/space_ninja) in ninja_contents
	// Записываем катану по той же причине
	nin_datum.my_katana = locate(/obj/item/melee/energy_katana) in ninja_contents
	// И батарею тоже
	nin_datum.cell = nin_datum.my_suit.cell


// Прок убирающий роль ниндзя как антагониста у игрока
// Сделана возможность вызвать его и просто кодом, например при боргизации, с тематическими сообщениями
// И возможность вызвать его админам с админ логами о том, кто снял антажку (Всяко лучше чем код по 10 раз копировать)
/datum/game_mode/proc/remove_ninja(datum/mind/ninja_mind, mob/caller = null, admin_removed = FALSE)
	if(ninja_mind in space_ninjas)
		SSticker.mode.space_ninjas -= ninja_mind
		ninja_mind.special_role = null
		QDEL_NULL(ninja_mind.ninja)
		ninja_mind.current.faction = list("Station")
		if(admin_removed)
			log_and_message_admins("has removed special role \"Ninja\" from [key_name_admin(ninja_mind.current)]")
		add_conversion_logs(ninja_mind.current, "De-ninjad")
		if(issilicon(ninja_mind.current))
			to_chat(ninja_mind.current, span_userdanger("Вы стали Роботом! И годы ваших тренировок становятся пылью..."))
		else
			to_chat(ninja_mind.current, span_userdanger("Вам промыло мозги! Вы больше не Ниндзя!"))
		SSticker.mode.update_ninja_icons_removed(ninja_mind)

// Прок дающий ниндзяхуд
/datum/game_mode/proc/update_ninja_icons_added(datum/mind/ninja_mind)
	var/datum/atom_hud/antag/ninja_hud = GLOB.huds[ANTAG_HUD_NINJA]
	ninja_hud.join_hud(ninja_mind.current)
	set_antag_hud(ninja_mind.current, "hudninja")

// Прок убирающий ниндзяхуд
/datum/game_mode/proc/update_ninja_icons_removed(datum/mind/ninja_mind)
	var/datum/atom_hud/antag/ninja_hud = GLOB.huds[ANTAG_HUD_NINJA]
	ninja_hud.leave_hud(ninja_mind.current)
	set_antag_hud(ninja_mind.current, null)

// Прок позволяющий ниндзя задать себе имя
// Либо принять рандомно сгенерированное
/datum/game_mode/proc/name_ninja(mob/living/carbon/human/ninja_mob)
	//Allows the ninja to choose a custom name or go with a random one. Spawn 0 so it does not lag the round starting.
	var/ninja_name_first = pick(GLOB.ninja_titles)
	var/ninja_name_second = pick(GLOB.ninja_names)
	var/randomname = "[ninja_name_first] [ninja_name_second]"
	var/newname = sanitize(copytext_char(input(ninja_mob, "Вы космический Ниндзя, гордый член клана Паука. Как вы хотите себя называть?", "Смена имени", randomname) as null|text,1,MAX_NAME_LEN))

	if(!newname)
		newname = randomname

	ninja_mob.real_name = newname
	ninja_mob.name = newname
	if(ninja_mob.mind)
		ninja_mob.mind.name = newname

// Прок отвечающий за "Приветствие" ниндзя
// Плюс выдаёт ему фракцию "space ninja"
/datum/game_mode/proc/greet_ninja(var/datum/mind/ninja, var/you_are = TRUE)
	ninja.current.playsound_local(null, 'sound/ambience/antag/ninja_greeting.ogg', 100, 0)
	if(you_are)
		to_chat(ninja.current, "Я элитный наёмник в составе могущественного Клана Паука! <font color='red'><B>Космический Ниндзя!</B></font>")
		to_chat(ninja.current, "Моё оружие внезапность. Моя броня Тень. Без них, я ничто.")
	ninja.current.faction = list(ROLE_NINJA)
	ninja.announce_objectives()
	return

// Прок ответственный за выдачу целей ниндзя согласно выпавшему игровому подходу
// Вызывает прок для выдачи целей ориентируясь на рандомно выбранный игровой подход - стелс/взлом/агрессивный
/datum/game_mode/proc/forge_ninja_objectives(datum/mind/ninja_mind, objective_type = null, datum/objective/custom_objective = null)
	if(!objective_type)
		objective_type = pick("protector", "hacker", "killer")
	switch(objective_type)
		if("generic")
			forge_generic_ninja_objectives(ninja_mind, custom_objective)
		if("protector")
			forge_protector_ninja_objectives(ninja_mind)
		if("hacker")
			forge_hacker_ninja_objectives(ninja_mind)
		if("killer")
			forge_killer_ninja_objectives(ninja_mind)

// Цели для нидзя одиночек. Будь то ивентовых или щитспавн.
// Такие ниндзя не спавнят других антагов вместе с собой.
// Им может быть выдана кастомная цель вместо генерации через этот прок.
/datum/game_mode/proc/forge_generic_ninja_objectives(datum/mind/ninja_mind, datum/objective/custom_objective = null)
	var/datum/ninja/ninja_datum = ninja_mind.ninja
	var/mob/living/carbon/human/ninja_mob = ninja_mind.current

	if(custom_objective)
		custom_objective.owner = src
		ninja_mind.objectives += custom_objective
	else
		if(prob(50))
			//Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
			var/datum/objective/cyborg_hijack/hijack = new
			ninja_mind.objectives += hijack

		var/pick_hack = pick(1,2)
		switch(pick_hack)
			if(1)
				//Поломка ИИ: Flag set to complete in the DrainAct in ninjaDrainAct.dm
				var/datum/objective/ai_corrupt/corrupt_objective = new
				corrupt_objective.owner = ninja_mind
				ninja_mind.objectives += corrupt_objective
			if(2)
				//Взлом РНД: Flag set to complete in the DrainAct in ninjaDrainAct.dm
				var/datum/objective/research_corrupt/rnd_hack_objective = new
				rnd_hack_objective.owner = ninja_mind
				ninja_mind.objectives += rnd_hack_objective

		var/pick_chance = rand(0, 100)
		if(pick_chance <= 25)
			//БОМБА
			var/datum/objective/plant_explosive/bomb_objective = new
			bomb_objective.owner = ninja_mind
			bomb_objective.choose_target_area()
			//Если у нас каким то чудом уже есть бомба(ы) с другой зоной или без неё - мы должны выдать ей(им) новую зону
			for(var/obj/item/grenade/plastic/c4/ninja/ninja_bomb in ninja_mob.get_contents())
				ninja_bomb.detonation_objective = bomb_objective
			ninja_mind.objectives += bomb_objective
		else if(pick_chance <= 50)
			//Подставить цель//
			var/datum/objective/set_up/set_up_objective = new
			set_up_objective.owner = ninja_mind
			set_up_objective.find_target()

			//Защита от повторяющихся целей
			for(var/sanity_check = 0, sanity_check < 10)
				if("[set_up_objective.target]" in ninja_datum.assigned_targets)
					set_up_objective.find_target()
					sanity_check++
					continue
				else
					break
			//Выдача или удаление цели если нету
			if(set_up_objective.target)
				ninja_datum.assigned_targets.Add("[set_up_objective.target]")
				ninja_mind.objectives += set_up_objective
			else
				qdel(set_up_objective)
		else
			//Нанесение увечий. Цели не будет если target совпадает с прошлыми.
			var/datum/objective/pain_hunter/pain_objective = new
			pain_objective.owner = ninja_mind
			pain_objective.find_target()
			if("[pain_objective]" in ninja_datum.assigned_targets)
				qdel(pain_objective)
			else if(pain_objective.target)
				ninja_datum.assigned_targets.Add("[pain_objective.target]")
				ninja_mind.objectives += pain_objective

		var/pick_objective = pick(1,2)
		switch(pick_objective)
			if(1)
				//Добыча денег
				var/datum/objective/get_money/money_objective = new
				money_objective.owner = ninja_mind
				ninja_mind.objectives += money_objective
				var/temp_cash_summ
				for(var/datum/money_account/account in GLOB.all_money_accounts)
					temp_cash_summ += account.money
				money_objective.req_amount = (temp_cash_summ / 100) * 60 //60% всех денег со всех аккаунтов
				money_objective.explanation_text = "Добудьте [money_objective.req_amount] кредитов со станции, наличкой."
			if(2)
				//Похищать людей пока не найдёшь нужного
				var/datum/objective/find_and_scan/find_objective = new
				find_objective.owner = ninja_mind
				find_objective.find_target()
				ninja_mind.objectives += find_objective

		var/pick_kill_or_steal = pick(1,2)
		switch(pick_kill_or_steal)
			if(1)
				//Банальное убийство. 2 штуки
				for(var/num_obj = 0, num_obj < 2, num_obj++)
					var/datum/objective/assassinate/kill_objective = new
					kill_objective.owner = ninja_mind
					kill_objective.find_target()
					//Защита от повторяющихся целей
					for(var/sanity_check = 0, sanity_check < 10)
						if("[kill_objective.target]" in ninja_datum.assigned_targets)
							kill_objective.find_target()
							sanity_check++
							continue
						else
							break
					//Выдача или удаление цели если нету
					if(kill_objective.target)
						ninja_datum.assigned_targets.Add("[kill_objective.target]")
						ninja_mind.objectives += kill_objective
					else
						qdel(kill_objective)
			if(2)
				//Банальная Кража. 2 штуки
				for(var/num_obj = 0, num_obj < 2, num_obj++)
					var/datum/objective/steal/steal_objective = new
					steal_objective.owner = ninja_mind
					steal_objective.find_target()
					if("[steal_objective.steal_target]" in ninja_datum.assigned_targets)
						steal_objective.find_target()
					else if(steal_objective.steal_target)
						ninja_datum.assigned_targets.Add("[steal_objective.steal_target]")
					ninja_mind.objectives += steal_objective

	//Выжить//
	if(!(locate(/datum/objective/survive) in ninja_mind.objectives))
		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = ninja_mind
		ninja_mind.objectives += survive_objective
	return

// Цели с которыми ниндзя в одном раунде с трейторами которые охотятся на его подзащищаемого.
// Остальные цели поощряют стелс геймплей
/datum/game_mode/proc/forge_protector_ninja_objectives(datum/mind/ninja_mind)
	var/datum/ninja/ninja_datum = ninja_mind.ninja

	//Защита цели//
	var/datum/objective/protect/ninja/protect_objective = new
	protect_objective.owner = ninja_mind
	var/datum/mind/protect_target = protect_objective.find_target()
	ninja_datum.assigned_targets.Add("[protect_target]")
	ninja_mind.objectives += protect_objective

	// Если не кого защищать
	// Или если трейторов не сгенерировалось,
	// просто не даём цель
	if(!protect_target || !length(SSticker.mode.traitors))
		GLOB.all_objectives -= protect_objective
		ninja_mind.objectives -= protect_objective
		qdel(protect_objective)

	if(prob(50))
		//Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
		var/datum/objective/cyborg_hijack/hijack = new
		ninja_mind.objectives += hijack

	//Подставить цель//
	var/datum/objective/set_up/set_up_objective = new
	set_up_objective.owner = ninja_mind
	set_up_objective.find_target()

	//Защита от повторяющихся целей
	for(var/sanity_check = 0, sanity_check < 10)
		if("[set_up_objective.target]" in ninja_datum.assigned_targets)
			set_up_objective.find_target()
			sanity_check++
			continue
		else
			break
	//Выдача или удаление цели если нету
	if(set_up_objective.target)
		ninja_datum.assigned_targets.Add("[set_up_objective.target]")
		ninja_mind.objectives += set_up_objective
	else
		qdel(set_up_objective)

	//Банальная Кража. 2 штуки
	for(var/num_obj = 0, num_obj < 2, num_obj++)
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = ninja_mind
		steal_objective.find_target()
		if("[steal_objective.steal_target]" in ninja_datum.assigned_targets)
			steal_objective.find_target()
		else if(steal_objective.steal_target)
			ninja_datum.assigned_targets.Add("[steal_objective.steal_target]")
		ninja_mind.objectives += steal_objective

	//Нанесение увечий. Цели не будет если target совпадает с прошлыми.
	var/datum/objective/pain_hunter/pain_objective = new
	pain_objective.owner = ninja_mind
	pain_objective.find_target()
	if("[pain_objective]" in ninja_datum.assigned_targets)
		qdel(pain_objective)
	else if(pain_objective.target)
		ninja_datum.assigned_targets.Add("[pain_objective.target]")
		ninja_mind.objectives += pain_objective

	//Выжить//
	if(!(locate(/datum/objective/survive) in ninja_mind.objectives))
		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = ninja_mind
		ninja_mind.objectives += survive_objective
	return

// Цели заточенные на взломе и кражах.
// Так же ниндзя прийдётся искать и добывать кровь вампиров.
// Но при успешном выполнении этой цели он получит доболнительную защиту от их абилок
/datum/game_mode/proc/forge_hacker_ninja_objectives(datum/mind/ninja_mind)
	var/datum/ninja/ninja_datum = ninja_mind.ninja

	//Сбор крови вампиров
	var/datum/objective/collect_blood/collect_vamp_blood = new
	collect_vamp_blood.owner = ninja_mind
	collect_vamp_blood.generate_vampires()
	ninja_mind.objectives += collect_vamp_blood
	if(!length(SSticker.mode.vampires)) //Если нет вампиров, просто не даём цель
		GLOB.all_objectives -= collect_vamp_blood
		ninja_mind.objectives -= collect_vamp_blood
		qdel(collect_vamp_blood)

	if(prob(75))
		//Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
		var/datum/objective/cyborg_hijack/hijack = new
		ninja_mind.objectives += hijack

	var/pick_hack = pick(1,2)
	switch(pick_hack)
		if(1)
			//Поломка ИИ: Flag set to complete in the DrainAct in ninjaDrainAct.dm
			var/datum/objective/ai_corrupt/corrupt_objective = new
			corrupt_objective.owner = ninja_mind
			ninja_mind.objectives += corrupt_objective
		if(2)
			//Взлом РНД: Flag set to complete in the DrainAct in ninjaDrainAct.dm
			var/datum/objective/research_corrupt/rnd_hack_objective = new
			rnd_hack_objective.owner = ninja_mind
			ninja_mind.objectives += rnd_hack_objective

	var/pick_objective = pick(1,2)
	switch(pick_objective)
		if(1)
			//Добыча денег
			var/datum/objective/get_money/money_objective = new
			money_objective.owner = ninja_mind
			ninja_mind.objectives += money_objective
			money_objective.new_cash(accounts_procent = 60)
		if(2)
			//Похищать людей пока не найдёшь нужного
			var/datum/objective/find_and_scan/find_objective = new
			find_objective.owner = ninja_mind
			find_objective.find_target()
			ninja_mind.objectives += find_objective

	//Банальная Кража
	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = ninja_mind
	steal_objective.find_target()
	if("[steal_objective.steal_target]" in ninja_datum.assigned_targets)
		steal_objective.find_target()
	else if(steal_objective.steal_target)
		ninja_datum.assigned_targets.Add("[steal_objective.steal_target]")
	ninja_mind.objectives += steal_objective

	//Банальное убийство
	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = ninja_mind
	kill_objective.find_target()
	//Защита от повторяющихся целей
	for(var/sanity_check = 0, sanity_check < 10)
		if("[kill_objective.target]" in ninja_datum.assigned_targets)
			kill_objective.find_target()
			sanity_check++
			continue
		else
			break
	//Выдача или удаление цели если нету
	if(kill_objective.target)
		ninja_datum.assigned_targets.Add("[kill_objective.target]")
		ninja_mind.objectives += kill_objective
	else
		qdel(kill_objective)

	//Выжить
	if(!(locate(/datum/objective/survive) in ninja_mind.objectives))
		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = ninja_mind
		ninja_mind.objectives += survive_objective
	return

// Цели с которыми для ниндзя больше поощряется агрессивный и заметный геймплей
// Так же в раунде вместе с ниндзя будут генокрады. которых ниндзя прийдётся истреблять
/datum/game_mode/proc/forge_killer_ninja_objectives(datum/mind/ninja_mind)
	var/datum/ninja/ninja_datum = ninja_mind.ninja
	var/mob/living/carbon/human/ninja_mob = ninja_mind.current

	//Очистка станции от генокрадов
	var/datum/objective/vermit_hunt/hunt_changelings = new
	hunt_changelings.owner = ninja_mind
	hunt_changelings.find_target()
	ninja_mind.objectives += hunt_changelings
	if(!length(SSticker.mode.changelings))//Если нет генокрадов, просто не даём цель
		GLOB.all_objectives -= hunt_changelings
		ninja_mind.objectives -= hunt_changelings
		qdel(hunt_changelings)

	if(prob(50))
		//Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
		var/datum/objective/cyborg_hijack/hijack = new
		ninja_mind.objectives += hijack

	//БОМБА
	var/datum/objective/plant_explosive/bomb_objective = new
	bomb_objective.owner = ninja_mind
	bomb_objective.choose_target_area()
	//Если у нас каким то чудом уже есть бомба(ы) с другой зоной или без неё - мы должны выдать ей(им) новую зону
	for(var/obj/item/grenade/plastic/c4/ninja/ninja_bomb in ninja_mob.get_contents())
		ninja_bomb.detonation_objective = bomb_objective
	ninja_mind.objectives += bomb_objective

	//Похищать людей пока не найдёшь нужного
	var/datum/objective/find_and_scan/find_objective = new
	find_objective.owner = ninja_mind
	find_objective.find_target()
	ninja_mind.objectives += find_objective

	//Банальное убийство. 2 штуки
	for(var/num_obj = 0, num_obj < 2, num_obj++)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = ninja_mind
		kill_objective.find_target()
		//Защита от повторяющихся целей
		for(var/sanity_check = 0, sanity_check < 10)
			if("[kill_objective.target]" in ninja_datum.assigned_targets)
				kill_objective.find_target()
				sanity_check++
				continue
			else
				break
		//Выдача или удаление цели если нету
		if(kill_objective.target)
			ninja_datum.assigned_targets.Add("[kill_objective.target]")
			ninja_mind.objectives += kill_objective
		else
			qdel(kill_objective)

	//Выжить
	if(!(locate(/datum/objective/survive) in ninja_mind.objectives))
		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = ninja_mind
		ninja_mind.objectives += survive_objective
	return

// Прок вызывающие надевание костюма на ниндзя.
/datum/game_mode/proc/equip_space_ninja(mob/living/carbon/human/ninja)
	if(!istype(ninja))
		return
	return ninja.equipOutfit(/datum/outfit/ninja)

// Прок ответственный за выдачу различных необходимых штук для ниндзя.
// Проверять на которые каждый раз тонной кода - не лучшая идея.
// Пока из таких штук - тут только бомба
/datum/game_mode/proc/basic_ninja_needs_check(datum/mind/ninja_mind)
	var/mob/living/carbon/human/ninja_mob = ninja_mind.current
	var/datum/objective/plant_explosive/bomb_objective = locate(/datum/objective/plant_explosive) in ninja_mind.objectives
	//Выдача бомбы
	if(bomb_objective) //Вместо спавна бомбы всегда, лучше пусть спавнится только если есть цель на бомбу
		if(!locate(/obj/item/grenade/plastic/c4/ninja) in ninja_mob.get_contents() && !bomb_objective.completed) //Если уже есть бомба, не надо делать вторую
			ninja_mob.equip_or_collect(new /obj/item/grenade/plastic/c4/ninja(ninja_mob), slot_l_store)
			var/obj/item/grenade/plastic/c4/ninja/charge = ninja_mob.l_store
			charge.detonation_objective = bomb_objective
			//charge.set_detonation_area(ninja_mind)

// Checks if the game should end due to all Ninjas being dead, or MMI'd/Borged
/datum/game_mode/space_ninja/check_finished()
	var/ninjas_alive = 0

	for(var/datum/mind/ninja in space_ninjas)
		if(!istype(ninja.current, /mob/living/carbon))
			continue
		if(ninja.current.stat==DEAD)
			continue
		if(istype(ninja.current, /obj/item/mmi)) // ninja is in an MMI, don't count them as alive
			continue
		ninjas_alive++

	if(ninjas_alive || but_wait_theres_more)
		return ..()
	else
		finished = 1
		return TRUE

/datum/game_mode/space_ninja/declare_completion(var/ragin = 0)
	if(finished && !ragin)
		SSticker.mode_result = "ninja loss - ninja killed"
		to_chat(world, span_warning("<FONT size = 3><B> Ниндзя был[(space_ninjas.len>1)?"и":""] убит[(space_ninjas.len>1)?"ы":""] экипажем! Клан Паука ещё не скоро отмоется от этого позора!</B></FONT>"))
	..()
	return TRUE

/datum/game_mode/proc/auto_declare_completion_ninja()
	if(space_ninjas.len)
		var/text = "<br><font size=3><b>Космическим[(space_ninjas.len>1)?"и":""] Ниндзя был[(space_ninjas.len>1)?"и":""]:</b></font>"

		for(var/datum/mind/ninja in space_ninjas)

			text += "<br><b>[ninja.key]</b> был <b>[ninja.name]</b> ("
			if(ninja.current)
				if(ninja.current.stat == DEAD)
					text += "Умер"
				else
					text += "Выжил"
				if(ninja.current.real_name != ninja.name)
					text += " как <b>[ninja.current.real_name]</b>"
			else
				text += "Тело уничтожено"
			text += ")"
			text += "<br>"
			var/datum/ninja/ninja_datum = ninja.ninja
			if(istype(ninja_datum)) // Защита от рантаймов в случае если по какой то причине он не прочитает датум
				text += "Выбранные способности: [ninja_datum.purchased_abilities]"

			var/count = 1
			var/ninjawin = 1
			for(var/datum/objective/objective in ninja.objectives)
				if(objective.check_completion())
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='green'><B>Успех!</B></font>"
					SSblackbox.record_feedback("nested tally", "ninja_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='red'>Провал.</font>"
					SSblackbox.record_feedback("nested tally", "ninja_objective", 1, list("[objective.type]", "FAIL"))
					ninjawin = 0
				count++

			if(ninja.current && ninja.current.stat!=DEAD && ninjawin)
				text += "<br><font color='green'><B>Ниндзя успешно выполнил свои задачи!</B></font>"
				SSblackbox.record_feedback("tally", "ninja_success", 1, "SUCCESS")
			else
				text += "<br><font color='red'><B>Ниндзя провалился!</B></font>"
				SSblackbox.record_feedback("tally", "ninja_success", 1, "FAIL")
			text += "<br>"

		to_chat(world, text)
	return TRUE

// Хранилище данных для ниндзя.
// Необходимо для элементов интерфейса и добавления данных в статус панельке
/datum/ninja
	var/mob/living/carbon/human/owner = null
	var/gender = FEMALE		//Вдруг понадобится. Но пока не используется
	var/list/assigned_targets = list() //Prevents duplicate objectives
	var/purchased_abilities
	var/allow_guns = FALSE	//Для админ арбузов
	var/no_guns_message = "Технологии моего клана в разы превосходят это жалкое подобие оружия! Я отказываюсь этим пользоваться!"
	var/datum/martial_art/ninja_martial_art/creeping_widow = null
	var/obj/item/clothing/suit/space/space_ninja/my_suit = null
	var/obj/item/melee/energy_katana/my_katana = null
	var/obj/item/stock_parts/cell/cell = null

/datum/ninja/New()
	return

/datum/ninja/Destroy()
	. = ..()
	if(owner.hud_used)
		owner.hud_used.remove_ninja_hud()
	owner = null
	creeping_widow = null
	my_suit = null
	my_katana = null
	cell = null
	purchased_abilities = null
	assigned_targets.Cut()
	return

/datum/ninja/proc/update_owner(mob/living/carbon/human/current) //Called when a ninja gets cloned. This updates ninja.owner to the new body.
	if(current.mind && current.mind.ninja && current.mind.ninja.owner && (current.mind.ninja.owner != current))
		current.mind.ninja.owner = current

/datum/ninja/proc/return_cell_charge()
	if(!cell)
		return "ERROR!"
	return "[cell.charge]/[cell.maxcharge]"

/datum/ninja/proc/return_dash_charge()
	if(!my_katana)
		return "ERROR!"
	return "[my_katana.jaunt.current_charges]/[my_katana.jaunt.max_charges]"

/datum/ninja/proc/handle_ninja()
	if(owner.hud_used)
		var/datum/hud/hud = owner.hud_used
		if(owner.wear_suit == my_suit)	// Нет костюма? Нет и интерфейса!
			// Отображение заряда костюма
			if(!hud.ninja_energy_display)
				hud.ninja_energy_display = new /obj/screen()
				hud.ninja_energy_display.name = "Заряд батареи"
				hud.ninja_energy_display.icon = 'icons/mob/screen_64x64.dmi'
				hud.ninja_energy_display.maptext_x = 0
				hud.ninja_energy_display.maptext_y = 0
				hud.ninja_energy_display.maptext_width = 64
				hud.ninja_energy_display.screen_loc = "SOUTH :48, CENTER :-16"
				hud.infodisplay += hud.ninja_energy_display
				hud.show_hud(hud.hud_version)
				hud.hidden_inventory_update()
			if(my_suit && cell)
				var/check_percentage = (cell.maxcharge/100)*20
				var/warning = cell.charge >= check_percentage ? "" : "_warning"
				hud.ninja_energy_display.icon_state = "ninja_energy_display_[my_suit.color_choice][warning]"
				hud.ninja_energy_display.maptext = "<div align='center' valign='middle' style='position:relative;'><font color='#FFFFFF' size='1'>[round(cell.charge)]</font></div>"
				hud.ninja_energy_display.invisibility = my_suit.show_charge_UI ? 0 : 100
			// Отображение концентрации
			if(!hud.ninja_focus_display && owner.mind.martial_art && istype(owner.mind.martial_art, /datum/martial_art/ninja_martial_art))
				creeping_widow = owner.mind.martial_art
				hud.ninja_focus_display = new /obj/screen()
				hud.ninja_focus_display.name = "Концентрация"
				hud.ninja_focus_display.screen_loc = "EAST:-6,CENTER-2:15"
				hud.infodisplay += hud.ninja_focus_display
				hud.show_hud(hud.hud_version)
				hud.hidden_inventory_update()
			if(creeping_widow && my_suit)	//На всякий случай.
				hud.ninja_focus_display.icon_state = creeping_widow.has_focus ? "focus_active_[my_suit.color_choice]" : "focus"
				hud.ninja_focus_display.invisibility = my_suit.show_concentration_UI ? 0 : 100
		else
			owner.hud_used.remove_ninja_hud()

/datum/hud/proc/remove_ninja_hud()
	if(!ninja_energy_display && !ninja_focus_display)
		return
	infodisplay -= ninja_energy_display
	QDEL_NULL(ninja_energy_display)
	infodisplay -= ninja_focus_display
	QDEL_NULL(ninja_focus_display)
	show_hud(hud_version)
	hidden_inventory_update()

//OTHER PROCS
/proc/isninja(mob/living/M as mob)
	return istype(M) && M.mind && SSticker && SSticker.mode && ((M.mind in SSticker.mode.space_ninjas))
