#define ASSIGNMENT_ANY "Any"
#define ASSIGNMENT_AI "AI"
#define ASSIGNMENT_CYBORG "Cyborg"
#define ASSIGNMENT_ENGINEER "Engineer"
#define ASSIGNMENT_BOTANIST "Botanist"
#define ASSIGNMENT_JANITOR "Janitor"
#define ASSIGNMENT_MEDICAL "Medical"
#define ASSIGNMENT_SCIENTIST "Scientist"
#define ASSIGNMENT_SECURITY "Security"

GLOBAL_LIST_INIT(severity_to_string, list(EVENT_LEVEL_MUNDANE = "Mundane", EVENT_LEVEL_MODERATE = "Moderate", EVENT_LEVEL_MAJOR = "Major"))
GLOBAL_LIST_EMPTY(event_last_fired)

/datum/event_container
	var/severity = -1
	var/delayed = 0
	var/delay_modifier = 1
	var/next_event_time = 0
	var/list/available_events
	var/list/last_event_time = list()
	var/datum/event_meta/next_event = null

	var/last_world_time = 0

/datum/event_container/process()
	if(!next_event_time)
		set_event_delay()

	if(delayed)
		next_event_time += (world.time - last_world_time)
	else if(world.time > next_event_time)
		if(config.allow_random_events)
			start_event()

	last_world_time = world.time

/datum/event_container/proc/start_event()
	if(!next_event)	// If non-one has explicitly set an event, randomly pick one
		next_event = acquire_event()

	// Has an event been acquired?
	if(next_event)
		// Set when the event of this type was last fired, and prepare the next event start
		last_event_time[next_event] = world.time
		set_event_delay()
		next_event.enabled = !next_event.one_shot	// This event will no longer be available in the random rotation if one shot

		new next_event.event_type(next_event)	// Events are added and removed from the processing queue in their New/kill procs

		log_debug("Starting event '[next_event.name]' of severity [GLOB.severity_to_string[severity]].")
		next_event = null						// When set to null, a random event will be selected next time
	else
		// If not, wait for one minute, instead of one tick, before checking again.
		next_event_time += (60 * 10)


/datum/event_container/proc/acquire_event()
	if(available_events.len == 0)
		return
	var/active_with_role = number_active_with_role()

	var/list/possible_events = list()
	for(var/datum/event_meta/EM in available_events)
		var/event_weight = EM.get_weight(active_with_role)
		if(EM.enabled && event_weight)
			possible_events[EM] = event_weight

	for(var/event_meta in last_event_time) if(possible_events[event_meta])
		var/time_passed = world.time - GLOB.event_last_fired[event_meta]
		var/weight_modifier = max(0, (config.expected_round_length - time_passed) / 300)
		var/new_weight = max(possible_events[event_meta] - weight_modifier, 0)

		if(new_weight)
			possible_events[event_meta] = new_weight
		else
			possible_events -= event_meta

	if(possible_events.len == 0)
		return null

	// Select an event and remove it from the pool of available events
	var/picked_event = pickweight(possible_events)
	available_events -= picked_event
	return picked_event

/datum/event_container/proc/set_event_delay()
	// If the next event time has not yet been set and we have a custom first time start
	if(next_event_time == 0 && config.event_first_run[severity])
		var/lower = config.event_first_run[severity]["lower"]
		var/upper = config.event_first_run[severity]["upper"]
		var/event_delay = rand(lower, upper)
		next_event_time = world.time + event_delay
	// Otherwise, follow the standard setup process
	else
		var/playercount_modifier = 1
		switch(GLOB.player_list.len)
			if(0 to 10)
				playercount_modifier = 1.2
			if(11 to 15)
				playercount_modifier = 1.1
			if(16 to 25)
				playercount_modifier = 1
			if(26 to 35)
				playercount_modifier = 0.9
			if(36 to 50)
				playercount_modifier = 0.8
			if(50 to 80)
				playercount_modifier = 0.7
			if(80 to 10000)
				playercount_modifier = 0.6

		playercount_modifier = playercount_modifier * delay_modifier

		var/event_delay = rand(config.event_delay_lower[severity], config.event_delay_upper[severity]) * playercount_modifier
		next_event_time = world.time + event_delay

	log_debug("Next event of severity [GLOB.severity_to_string[severity]] in [(next_event_time - world.time)/600] minutes.")

/datum/event_container/proc/SelectEvent()
	var/datum/event_meta/EM = input("Select an event to queue up.", "Event Selection", null) as null|anything in available_events
	if(!EM)
		return
	if(next_event)
		available_events += next_event
	available_events -= EM
	next_event = EM
	return EM

/datum/event_container/mundane
	severity = EVENT_LEVEL_MUNDANE
	available_events = list(
		// Severity level, event name, event type, base weight, role weights, one shot, min weight, max weight. Last two only used if set.
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Ничего",				/datum/event/nothing,			1100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Спам на КПК",			/datum/event/pda_spam, 			0, 		list(ASSIGNMENT_ANY = 4), FALSE, 25, 50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Денежная лотерея",		/datum/event/money_lotto, 		0, 		list(ASSIGNMENT_ANY = 1), TRUE, 5,  15),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Взлом аккаунта",		/datum/event/money_hacker, 		0, 		list(ASSIGNMENT_ANY = 4), TRUE, 10, 25),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Новости экономики",		/datum/event/economic_event,	300),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Скудные новости",		/datum/event/trivial_news, 		400),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Обычные новости", 		/datum/event/mundane_news, 		300),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Нашествие вредителей",	/datum/event/infestation, 		100,	list(ASSIGNMENT_JANITOR = 100)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Сознание",				/datum/event/sentience,			50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Стенной грибок",		/datum/event/wallrot, 			0,		list(ASSIGNMENT_ENGINEER = 30, ASSIGNMENT_GARDENER = 50)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Скопление кои",			/datum/event/carp_migration/koi,		80,)
	)

/datum/event_container/moderate
	severity = EVENT_LEVEL_MODERATE
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Ничего",					/datum/event/nothing,					1230),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Аппендицит", 				/datum/event/spontaneous_appendicitis, 	0,		list(ASSIGNMENT_MEDICAL = 10), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Скопление карпов",			/datum/event/carp_migration,			200, 	list(ASSIGNMENT_ENGINEER = 10, ASSIGNMENT_SECURITY = 20), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Сбойные дроны",			/datum/event/rogue_drone, 				0,		list(ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Космолоза",				/datum/event/spacevine, 				250,	list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Метеорный дождь",			/datum/event/meteor_wave,				0,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Солнечная вспышка",		/datum/event/solar_flare,				0,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Мясной дождь",				/datum/event/dust/meaty,				0,		list(ASSIGNMENT_ENGINEER = 20)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Телекоммуникационный сбой",/datum/event/communications_blackout,	500,	list(ASSIGNMENT_AI = 150, ASSIGNMENT_SECURITY = 120)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Побег",					/datum/event/prison_break,				0,		list(ASSIGNMENT_SECURITY = 100)),
		//new /datum/event_meta(EVENT_LEVEL_MODERATE, "Virology Breach",			/datum/event/prison_break/virology,		0,		list(ASSIGNMENT_MEDICAL = 100)),
		//new /datum/event_meta(EVENT_LEVEL_MODERATE, "Xenobiology Breach",		/datum/event/prison_break/xenobiology,	0,		list(ASSIGNMENT_SCIENCE = 100)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Замыкание ЛКП",			/datum/event/apc_short, 				200,	list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Электрический шторм",		/datum/event/electrical_storm, 			250,	list(ASSIGNMENT_ENGINEER = 20, ASSIGNMENT_JANITOR = 150)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Радиационный шторм",		/datum/event/radiation_storm, 			25,		list(ASSIGNMENT_MEDICAL = 50), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Нашествие пауков",			/datum/event/spider_infestation, 		100,	list(ASSIGNMENT_SECURITY = 30), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Ионный шторм",				/datum/event/ion_storm, 				0,		list(ASSIGNMENT_AI = 50, ASSIGNMENT_CYBORG = 50, ASSIGNMENT_ENGINEER = 15, ASSIGNMENT_SCIENTIST = 5)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Нашествие бореров",		/datum/event/borer_infestation, 		40,		list(ASSIGNMENT_SECURITY = 30), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Несдвигаемый стержень",	/datum/event/immovable_rod,				0,		list(ASSIGNMENT_ENGINEER = 30), TRUE),
		//new /datum/event_meta/ninja(EVENT_LEVEL_MODERATE, "Space Ninja",		/datum/event/space_ninja, 				0,		list(ASSIGNMENT_SECURITY = 15), TRUE),
		// NON-BAY EVENTS
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Массовые галлюцинации",	/datum/event/mass_hallucination,		300),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Цифровой вирус",			/datum/event/brand_intelligence,		50, 	list(ASSIGNMENT_ENGINEER = 25),	TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Space Dust",				/datum/event/dust,						50,		list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Пространственный разрыв",	/datum/event/tear,						0,		list(ASSIGNMENT_SECURITY = 35)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Хонкономалия",				/datum/event/tear/honk,						0),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Отходы из вытяжек",		/datum/event/vent_clog,					250),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Червоточины",				/datum/event/wormholes,					150),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Атмосферная аномалия",		/datum/event/anomaly/anomaly_pyro,		75,		list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Вортекс-аномалия",			/datum/event/anomaly/anomaly_vortex,	75,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Блюспейс-аномалия",		/datum/event/anomaly/anomaly_bluespace,	75,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Флюкс-аномалия",			/datum/event/anomaly/anomaly_flux,		75,		list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Гравитационная аномалия",	/datum/event/anomaly/anomaly_grav,		200),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Ревенант", 				/datum/event/revenant, 					150),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Спавн свармеров", 			/datum/event/spawn_swarmer, 			150, is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Спавн морфа", 				/datum/event/spawn_morph, 				40,		list(ASSIGNMENT_SECURITY = 10), is_one_shot = TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Вспышка болезни",			/datum/event/disease_outbreak, 			0,		list(ASSIGNMENT_MEDICAL = 150), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Хедкрабы",					/datum/event/headcrabs, 				0,		list(ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Сбой работы дверей",		/datum/event/door_runtime,				50,		list(ASSIGNMENT_ENGINEER = 25, ASSIGNMENT_AI = 150), TRUE)
	)

/datum/event_container/major
	severity = EVENT_LEVEL_MAJOR
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Ничего",			/datum/event/nothing,			590),															// 57% on high pop (120+). 64.2% on lowpop (70+)
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Миграция карпов",	/datum/event/carp_migration,	10,						list(ASSIGNMENT_SECURITY =  3), TRUE),	// 4.8% on high pop, 3.4% on low pop
		//new /datum/event_meta(EVENT_LEVEL_MAJOR, "Containment Breach",	/datum/event/prison_break/station,	0,			list(ASSIGNMENT_ANY = 5)),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Перегрузка ЛКП",	/datum/event/apc_overload,		0),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Блоб",			/datum/event/blob, 				30,						list(ASSIGNMENT_ENGINEER =  5), TRUE),	// 6.9% on high pop, 5.5% on low pop
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Метеорный вал",	/datum/event/meteor_wave,		30,						list(ASSIGNMENT_ENGINEER =  5),	TRUE),	// 6.9% on high pop, 5.5% on low pop
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Визит абдукторов",/datum/event/abductor, 		    20, 					list(ASSIGNMENT_SECURITY =  3), TRUE),	// 5.8% on high pop, 4.5% on low pop
		new /datum/event_meta/alien(EVENT_LEVEL_MAJOR, "Заражение ксеноморфами",	/datum/event/alien_infestation, 		20,		list(ASSIGNMENT_SECURITY = 4), TRUE),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Торговцы",		/datum/event/traders,			85, is_one_shot = TRUE),										// 8.4% on high pop, 9.4% on low pop
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Пауки Ужаса",		/datum/event/spider_terror, 	20,						list(ASSIGNMENT_SECURITY = 4), TRUE),	// 7.1% on high pop, 5.3% on low pop
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Демон Резни",		/datum/event/spawn_slaughter,	10,  is_one_shot = TRUE)	// 3% on high pop, 2.1% on low pop
		//new /datum/event_meta(EVENT_LEVEL_MAJOR, "Floor Cluwne",	/datum/event/spawn_floor_cluwne,	15, is_one_shot = TRUE)
	)


#undef ASSIGNMENT_ANY
#undef ASSIGNMENT_AI
#undef ASSIGNMENT_CYBORG
#undef ASSIGNMENT_ENGINEER
#undef ASSIGNMENT_BOTANIST
#undef ASSIGNMENT_JANITOR
#undef ASSIGNMENT_MEDICAL
#undef ASSIGNMENT_SCIENTIST
#undef ASSIGNMENT_SECURITY
