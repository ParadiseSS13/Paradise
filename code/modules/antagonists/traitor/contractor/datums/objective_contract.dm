/**
  * # Contract Objective
  *
  * Describes the target to kidnap and the extraction area of a [/datum/syndicate_contract].
  */
/datum/objective/contract
	// Settings
	/// Jobs that cannot be the kidnapping target.
	var/static/list/forbidden_jobs = list(
		"Captain",
		"Nanotrasen Career Trainer"
	)
	/// Static whitelist of area names that can be used as an extraction zone, structured by difficulty.
	/// An area's difficulty should be measured in how crowded it generally is, how out of the way it is and so on.
	/// Outdoor or invalid areas are filtered out.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => list(<area name>)
	var/static/list/possible_zone_names = list(
		EXTRACTION_DIFFICULTY_EASY = list(
			// Rooms
			"Альтернативная Зона Строительства",
			"Парикмахерская",
			"Escape Shuttle Hallway Podbay",
			"Сад",
			"Мусоросжигатель",
			"Бытовое Помещение",
			"Бытовые Туалеты",
			"Заброшенный Бар",
			"Дополнительный Склад Медицинского Отдела",
			"Западное Аварийное Хранилище",
			"Офис Психолога",
			"Комната Запуска Токсинов РНД",
			"Комната Смешивания Токсинов РНД",
			"Турбина",
			"Вирусология",
			"Комната Утилизации",
			// Maintenance
			"Южные Технические Тоннели",
			"Юго-Западные Технические Тоннели",
			"спомогательные Юго-Западные Технические Тоннели",
			"Юго-Западные Солнечные Панели",
			"Вспомогательные Южные Технические Тоннели",
			"Юго-Восточные Технические Тоннели",
			"Вспомогательные Юго-Восточные Технические Тоннели",
			"Юго-Восточные Солнечные Панели",
			"Необслуживаемое Помещение Электрооборудования",
			"Уголок Электроники",
			"Северные Технические Тоннели",
			"Северо-Западные Технические Тоннели",
			"Вспомогательные Северо-Западные Технические Тоннели",
			"Северо-Западные Солнечные Панели",
			"Вспомогательные Северные Технические Тоннели",
			"Северо-Восточные Технические Тоннели",
			"Вспомогательные Северо-Восточные Технические Тоннели",
			"Северо-Восточные Солнечные Панели",
			"Игровой Зал",
			"Технические Тоннели Генетики",
			"Западные Технические Тоннели",
			"Вспомогательные Западные Технические Тоннели",
			"Восточные Технические Тоннели",
			"Вспомогательные Восточные Технические Тоннели",
		),
		EXTRACTION_DIFFICULTY_MEDIUM = list(
			// Rooms
			"Основной Южный Коридор",
			"Атмосферный Отдел",
			"Аркаданый Зал",
			"Комната Сборочной Линии",
			"Вспомогательное Хранилище Инструментов",
			"Комната Отдыха РНД",
			"Кабинет Синего Щита",
			"Грузовой Отсек",
			"Церковь",
			"Офис Священника",
			"Офис Клоуна",
			"Зона Для Строительства",
			"Зал Суда",
			"Туалеты Дормиторий",
			"Инженерный Отдел",
			"Инженерная Комната Управления",
			"Коридор Эвакуационного Шаттла",
			"Experimentation Lab",
			"Holodeck Alpha",
			"Гидропоника",
			"Библиотека",
			"Офис Мима",
			"Шахтный Док",
			"Морг",
			"Комната Канцелярских Принадлежностей",
			"Зоомагазин",
			"Основное Хранилище Инструментов",
			"Отдел Исследований",
			"Контрольно-Пропускной Пункт Службы Безопасности",
			"Техническое Хранилище",
			"Телепортерная",
			"Хранилище Токсинов РНД",
			"Свободный Офис",
			"Лаборатория Химии РНД",
			"Лаборатория Ксенобиологии",
			// Maintenance
			"Технические Тоннели Атмоса",
			"Центральные Технические Тоннели",
			"Вспомогательные Центральные Технические Тоннели",
		),
		EXTRACTION_DIFFICULTY_HARD = list(
			// No AI Chamber because I'm not that sadistic.
			// Most Bridge areas are excluded because of they'd be basically impossible. So are Brig areas.
			"Фойе Спутника ИИ",
			"Атмос Спутника ИИ",
			"Сервисная Комната Спутника ИИ",
			"Коридор Спутника ИИ",
			"Бар",
			"Офис Карго",
			"Химическая Лаборатория Медицинского Отдела",
			"Кабинет Главного Инженера",
			"Кабинет Главного Врача",
			"Лаборатория Клонирования",
			"Криогеника",
			"Дормитории",
			"Инженерный Склад Снаряжения",
			"Фойе Инженерного Отдела",
			"Хранилище ВКД",
			"Комната Экспедиции",
			"Лаборатория Генетики",
			"Генератор Гравитации",
			"Кабинет Главы Персонала",
			"Конференц-Зал Командования",
			"Кухня", // Chef CQC is no joke.
			"Мех. Отсек РНД",
			"Медицинский Отдел",
			"Ресепшен Медицинского Отдела",
			"Склад Медицинского Отдела",
			"Центр Медицинского Лечения",
			"Комната Ожидания Медицинского Отдела",
			"Серверная Комната Обработки Сообщений",
			"Забегаловка Мистера Чанга",
			"Кабинет Представителя НТ",
			"Офис Парамедика",
			"Основной Западный Коридор",
			"Офис Квартирмейстера",
			"Кабинет Директора Исследований",
			"Отдел Исследований",
			"Робототехника",
			"Первая Операционная",
			"Вторая Операционная",
			"Центральное Отделение Телекоммуникаций",
			"Инженерное Защищенное Хранилище",
		),
	)
	// Variables
	/// The designated area where the kidnapee must be extracted to complete the objective.
	var/area/extraction_zone = null
	/// The contract's difficulty. Determines the reward on completion.
	var/chosen_difficulty = EXTRACTION_DIFFICULTY_EASY
	/// Associated lazy list of areas the contractor can pick from and extract the kidnapee there.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => /area
	var/list/area/candidate_zones = null
	/// List of people who cannot be selected as contract target.
	var/list/datum/mind/target_blacklist = null
	/// Static list that is basically [/datum/objective/contract/var/possible_zone_names] but with area names replaced by /area objects if available.
	var/static/list/possible_zones = null
	/// The owning [/datum/syndicate_contract].
	var/datum/syndicate_contract/owning_contract = null
	/// Name fixer regex because area names have rogue characters sometimes.
	var/static/regex/name_fixer = regex("(\[a-zа-яё0-9 \\'\]+)$", "ig") // SS220 EDIT - Regex for RU Areas

/datum/objective/contract/New(contract)
	owning_contract = contract
	// Init static variable
	if(!possible_zones)
		// Compute the list of all zones by their name first
		var/list/all_areas_by_name = list()
		for(var/a in GLOB.all_areas)
			var/area/A = a
			if(A.outdoors || !is_station_level(A.z))
				continue
			var/i = findtext(A.map_name, name_fixer)
			if(i)
				var/clean_name = copytext(A.map_name, i)
				clean_name = replacetext(clean_name, "\\", "")
				all_areas_by_name[clean_name] = A

		possible_zones = list()
		for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
			var/list/difficulty_areas = list()
			for(var/area_name in possible_zone_names[difficulty])
				var/area/A = all_areas_by_name[area_name]
				if(!A)
					continue
				difficulty_areas += A
			possible_zones += list(difficulty_areas)
	// Select zones
	for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
		pick_candidate_zone(difficulty)
	return ..()

/datum/objective/contract/is_invalid_target(datum/mind/possible_target)
	if((possible_target.assigned_role in forbidden_jobs) || (target_blacklist && (possible_target in target_blacklist)))
		return TARGET_INVALID_BLACKLISTED
	return ..()

/datum/objective/contract/on_target_cryo()
	if(owning_contract.status in list(CONTRACT_STATUS_COMPLETED, CONTRACT_STATUS_FAILED))
		return
	// We pick the target ourselves so we don't want the default behaviour.
	owning_contract.invalidate()

/datum/objective/contract/update_explanation_text()
	return

/**
  * Assigns a randomly selected zone to the contract's selectable zone at the given difficulty.
  *
  * Arguments:
  * * difficulty - The difficulty to assign.
  */
/datum/objective/contract/proc/pick_candidate_zone(difficulty = EXTRACTION_DIFFICULTY_EASY)
	if(!candidate_zones)
		candidate_zones = list(null, null, null)
	candidate_zones[difficulty] = pick(possible_zones[difficulty])

/**
  * Updates the objective's information with the given difficulty.
  *
  * Arguments:
  * * difficulty - The chosen difficulty.
  * * S - The parent [/datum/syndicate_contract].
  */
/datum/objective/contract/proc/choose_difficulty(difficulty = EXTRACTION_DIFFICULTY_EASY, datum/syndicate_contract/S)
	. = FALSE
	if(!ISINDEXSAFE(candidate_zones, difficulty))
		return

	var/area/A = candidate_zones[difficulty]
	extraction_zone = A
	chosen_difficulty = difficulty
	explanation_text = "Kidnap [S.target_name] by any means and extract them in [A.map_name] using your Contractor Uplink. You will earn [S.reward_tc[difficulty]] telecrystals and [S.reward_credits] credits upon completion. Your reward will be severely reduced if your target is dead."
	return TRUE

/**
  * Returns whether the extraction process can be started.
  *
  * Arguments:
  * * caller - The person trying to call the extraction.
  */
/datum/objective/contract/proc/can_start_extraction_process(mob/living/carbon/human/caller)
	return get_area(caller) == extraction_zone && get_area(target.current) == extraction_zone
