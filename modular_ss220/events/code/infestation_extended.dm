#define VERM_RATS 		0
#define VERM_AXOLOTL 	1
#define VERM_FROGS 		2
#define VERM_IGUANAS 	3
#define VERM_SNAKES 	4
#define VERM_MOTH 		5
#define VERM_MOTHROACH 	6

/datum/event/infestation/extended
	announceWhen = 10
	endWhen = 11
	var/static/list/spawn_areas_extended = list(
		/area/station/service/chapel,
		/area/station/service/library,
		/area/station/service/hydroponics,
		/area/station/service/cafeteria,
		/area/station/service/hydroponics,
		/area/station/service/bar,
		/area/station/service/kitchen,
		/area/station/service/janitor,
		/area/station/public/construction,
		/area/station/public/arcade,
		/area/station/public/toilet,
		/area/station/public/fitness,
		/area/station/engineering/atmos,
		/area/station/engineering/tech_storage,
		/area/station/security/armory/secure,
		/area/station/security/permabrig,
		/area/station/security/lobby,
		/area/station/security/prison/cell_block/A
	)

/datum/event/infestation/extended/start()
	var/list/turf/simulated/floor/turfs = list()
	spawn_area_type = pick(spawn_areas_extended)
	for(var/areapath in typesof(spawn_area_type))
		var/area/A = locate(areapath)
		if(!A)
			log_debug("Failed to locate area for extended infestation event!")
			kill()
			return
		for(var/turf/simulated/floor/F in A.contents)
			if(turf_clear(F))
				turfs += F

	var/list/spawn_types = list()
	var/max_number
	vermin = rand(0, 6)
	switch(vermin)
		if(VERM_RATS)
			max_number = 12
			var/possible_vermin = rand(0, 2)
			switch(possible_vermin)
				if(0)
					spawn_types = list(/mob/living/simple_animal/mouse/rat)
					vermstring = "крыс"
				if(1)
					spawn_types = list(/mob/living/simple_animal/mouse/rat/irish)
					vermstring = "ирландских крыс борцов за независимость"
				if(2)
					spawn_types = list(/mob/living/simple_animal/mouse/rat/white)
					vermstring = "лабораторных крыс"
		if(VERM_AXOLOTL)
			spawn_types = list(/mob/living/simple_animal/lizard/axolotl)
			max_number = 9
			vermstring = "аксолотлей"
		if(VERM_IGUANAS)
			spawn_types = list(/mob/living/simple_animal/hostile/lizard)
			max_number = 5
			vermstring = "игуанн"
			if(prob(10))
				spawn_types = list(/mob/living/simple_animal/hostile/lizard/gator)
				max_number = 3
				vermstring = "аллигаторов"
		if(VERM_SNAKES)
			spawn_types = list(/mob/living/simple_animal/hostile/poison_snake)
			max_number = 9
			vermstring = "ядовитых змей"
		if(VERM_MOTH)
			spawn_types = list(/mob/living/simple_animal/moth)
			max_number = 5
			vermstring = "молей"
		if(VERM_MOTHROACH)
			spawn_types = list(/mob/living/simple_animal/mothroach)
			max_number = 5
			vermstring = "молетараканов"
	var/amount_to_spawn = rand(2, max_number)
	while(length(turfs) && amount_to_spawn > 0)
		var/turf/simulated/floor/T = pick_n_take(turfs)
		amount_to_spawn--
		var/spawn_type = pick(spawn_types)
		new spawn_type(T)


/datum/event/infestation/extended/announce(false_alarm)
	var/vermin_chosen = vermstring || pick("неопознанных форм жизни", "золотых жуков", "ошибок", "насекомых", "тараканов", "муравьев", "щиткьюров", "ассистентов", "экипажа", "вульпканинов", "таяринов", "слаймов", "слаймоменов")
	if(!spawn_area_type)
		if(false_alarm)
			spawn_area_type = pick(spawn_areas + spawn_areas_extended)
		else
			log_debug("Extended Infestation Event didn't provide an area to announce(), something is likely broken.")
			kill()

	GLOB.minor_announcement.Announce("Биосканеры фиксируют размножение [vermin_chosen] в [initial(spawn_area_type.name)]. Избавьтесь от них, прежде чем это начнет влиять на продуктивность станции.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ.")
	spawn_area_type = null

/datum/event/falsealarm/start()
	possible_event_types |= /datum/event/infestation/extended
	. = ..()

/datum/event_container/mundane/New()
	. = ..()
	available_events |= new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Vermin Infestation Extended",	/datum/event/infestation/extended, 		10,	list(ASSIGNMENT_JANITOR = 100, ASSIGNMENT_SECURITY = 30))

#undef VERM_RATS
#undef VERM_AXOLOTL
#undef VERM_FROGS
#undef VERM_IGUANAS
#undef VERM_SNAKES
#undef VERM_MOTH
#undef VERM_MOTHROACH
