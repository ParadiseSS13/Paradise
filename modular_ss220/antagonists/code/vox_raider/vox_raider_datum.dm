/datum/antagonist/vox_raider
	name = "Vox Raider"
	roundend_category = "vox raiders"
	job_rank = ROLE_VOX_RAIDER
	special_role = SPECIAL_ROLE_VOX_RAIDER
	antag_hud_name = "hudvoxraider"
	antag_hud_type = ANTAG_HUD_VOX_RAIDER
	wiki_page_name = "vox_raiders"
	var/datum/team/vox_raiders/raiders_team = null

/datum/antagonist/vox_raider/add_owner_to_gamemode()
	SSticker.mode.vox_raiders |= owner
	if(owner.current && !("Vox" in owner.current.faction))
		owner.current.faction |= list("Vox")

/datum/antagonist/vox_raider/remove_owner_from_gamemode()
	SSticker.mode.vox_raiders -= owner

/datum/antagonist/vox_raider/greet()
	. = ..()
	SEND_SOUND(owner.current, sound('modular_ss220/antagonists/sound/ambience/antag/vox_raiders_intro.ogg'))

	. += {"Вы Вокс Рейдер, вы и ваша стая нашли станцию Нанотрейзен имеющую ценности.
		Раздобудьте эти ценности любым доступным способом: торговлей, кражей, договорами.
		Главное помните, не допустите своей гибели или гибели членов стаи. Ценные блестяшки не стоят мертвого собрата.
		\nВы можете заказывать товары и снаряжение в Киконсоле Закиказов.
		\nСдавайте ценности в Расчичетчикик.
		\nКовчег выделил вам товары которые могут потенциально заинтересовать экипаж станции.
		Разумеется не за бесплатно, выберите что вам действительно нужно и закажите это."}

	var/raider_names = get_raider_names_text()
	if(raider_names)
		. += "Оберегай собратьев и помогай стае: <b>[raider_names]</b>. Только стая важна!"
		antag_memory += "<b>Ваша стая:</b>: [raider_names]<br>"

	. += "Нужно больше ценностей!"

/datum/antagonist/vox_raider/create_team(datum/team/vox_raiders/team)
	if(!istype(team))
		error("Wrong team type passed to [type].")
		return

	raiders_team = team
	return raiders_team

/datum/antagonist/vox_raider/get_team()
	return raiders_team

/datum/antagonist/vox_raider/proc/get_raider_names_text()
	PRIVATE_PROC(TRUE)
	var/datum/team/vox_raiders/team = get_team()
	if(!istype(team))
		return ""

	return team.get_raider_names_text(owner)

/datum/antagonist/vox_raider/proc/admin_add(admin, datum/mind/new_antag)
	if(!new_antag)
		return FALSE

	if(new_antag.has_antag_datum(/datum/antagonist/vox_raider))
		alert(admin, "Кандидат уже Вокс Рейдер")
		return FALSE

	if(!can_be_owned(new_antag))
		alert(admin, "Кандидат не может быть Вокс Рейдером")
		return FALSE

	switch(alert(admin, "Создать новую команду или добавить в существующую?", "Воксы Рейдеры", "Создать", "Добавить", "Закрыть"))
		if("Создать")
			return create_new_vox_raiders_team(admin, new_antag)
		if("Добавить")
			return add_to_existing_vox_raiders_team(admin, new_antag)

	return FALSE

/datum/antagonist/vox_raider/proc/create_new_vox_raiders_team(admin, datum/mind/first_raider)
	PRIVATE_PROC(TRUE)
	var/list/choices = list()
	for(var/mob/living/alive_living_mob in GLOB.alive_mob_list)
		var/datum/mind/mind_to_check = alive_living_mob.mind
		if(!mind_to_check || mind_to_check == first_raider || !can_be_owned(mind_to_check))
			continue

		choices["[mind_to_check.name]([alive_living_mob.ckey])"] = mind_to_check

	sortTim(choices, GLOBAL_PROC_REF(cmp_text_asc))

	var/list/candidates_list = list(first_raider)
	while(TRUE)
		if(!length(choices))
			break
		var/choice = tgui_input_list(admin, "Выберите  кандидата, если вы завершили выбор, то закройте окно.", "Добавить нового вокс рейдера", choices)
		if(!choice)
			break
		var/datum/mind/mind = choices[choice]
		if(!mind)
			stack_trace("Chosen second vox raider `[choice]` was `null` for some reason")
		choices.Remove(choice)
		candidates_list.Add(mind)

	var/datum/team/vox_raiders/team = new(candidates_list, FALSE)
	for(var/datum/mind/mind in candidates_list)
		if(isnull(mind.add_antag_datum(src, team)))
			error("Antag datum couldn't be granted to new raider [mind.name] in `/datum/antagonist/vox_raider/proc/create_new_vox_raiders_team`")
			alert(admin, "Кандидат [mind.name] не был выбран для `Vox Raider` по каким-то причинам. Попробуйте еще раз.")

	offer_to_equip(admin, candidates_list)

	log_admin("[key_name(admin)] made vox raiders.")
	return TRUE

/datum/antagonist/vox_raider/proc/add_to_existing_vox_raiders_team(admin, datum/mind/raider_to_add)
	PRIVATE_PROC(TRUE)
	var/list/choices = list()
	for(var/datum/team/vox_raiders/team in GLOB.antagonist_teams)
		var/list/member_ckeys = team.get_member_ckeys()
		choices["[team.name][length(member_ckeys) ? "([member_ckeys.Join(", ")])" : ""]"] = team

	if(!length(choices))
		alert(admin, "Команда Воксов-Рейдеров не найдена. Попробуйте создать новую.")
		return FALSE

	sortTim(choices, GLOBAL_PROC_REF(cmp_text_asc))
	var/choice = tgui_input_list(admin, "Выбор команды Воксов-Рейдеров.", "Команда Воксов-Рейдеров", choices)
	if(!choice)
		return FALSE

	offer_to_equip(admin, list(raider_to_add))

	var/datum/team/vox_raiders/team = choices[choice]
	if(!team)
		stack_trace("Chosen vox raiders team `[choice]` was `null` for some reason.")

	return !isnull(raider_to_add.add_antag_datum(src, team))

/datum/antagonist/vox_raider/proc/offer_to_equip(admin, list/candidates_list, visualsOnly)
	if(!length(candidates_list))
		return
	var/choice = (alert(admin, "Снарядить в стандартную экипировку?", "Снаряжение", "Да", "Нет"))
	if(!choice || choice == "Нет")
		return
	for(var/datum/mind/mind in candidates_list)
		if(!isvox(mind.current))
			make_body(mind.current, mind, TRUE, "Vox")
		var/mob/living/carbon/human/H = mind.current
		if(mind.current)
			H.equipOutfit(/datum/outfit/vox, visualsOnly)

/datum/antagonist/vox_raider/make_body(spawn_loc, datum/mind/mind, try_use_preference = FALSE, species_name = null, list/possible_species)
	. = ..()
	mind.store_memory("<B> Я Вокс-Рейдер, основа моя: беречь стаю, тащить ценности. </B>.")
