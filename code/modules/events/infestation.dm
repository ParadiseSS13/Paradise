#define VERM_MICE 0
#define VERM_LIZARDS 1
#define VERM_SPIDERS 2

/datum/event/infestation
	announceWhen = 10
	endWhen = 11
	/// Which kind of vermin we'll be spawning (one of the three defines)
	var/vermin
	/// Pretty name for the vermin we're spawning
	var/vermstring
	/// The area we'll be spawning things in
	var/area/spawn_area_type
	/// All possible areas for spawning, matched with their pretty names
	var/static/list/spawn_areas = list(
		/area/station/service/kitchen,
		/area/station/engineering/atmos,
		/area/station/maintenance/incinerator,
		/area/station/service/chapel,
		/area/station/service/library,
		/area/station/service/hydroponics,
		/area/station/command/vault,
		/area/station/public/construction,
		/area/station/engineering/tech_storage,
		/area/station/security/armory/secure
	)

/datum/event/infestation/start()
	var/list/turf/simulated/floor/turfs = list()
	spawn_area_type = pick(spawn_areas)
	for(var/areapath in typesof(spawn_area_type))
		var/area/A = locate(areapath)
		if(!A)
			log_debug("Failed to locate area for infestation event!")
			kill()
			return
		for(var/turf/simulated/floor/F in A.contents)
			if(turf_clear(F))
				turfs += F

	var/list/spawn_types = list()
	var/max_number
	vermin = rand(0, 2)
	switch(vermin)
		if(VERM_MICE)
			spawn_types = list(/mob/living/simple_animal/mouse/gray, /mob/living/simple_animal/mouse/brown, /mob/living/simple_animal/mouse/white)
			max_number = 12
			vermstring = "мышей"
		if(VERM_LIZARDS)
			spawn_types = list(/mob/living/simple_animal/lizard)
			max_number = 6
			vermstring = "ящериц"
		if(VERM_SPIDERS)
			spawn_types = list(/obj/structure/spider/spiderling)
			max_number = 3
			vermstring = "пауков"
	var/amount_to_spawn = rand(2, max_number)
	while(length(turfs) && amount_to_spawn > 0)
		var/turf/simulated/floor/T = pick_n_take(turfs)
		amount_to_spawn--

		if(vermin == VERM_SPIDERS)
			var/obj/structure/spider/spiderling/S = new(T)
			S.amount_grown = -1
		else
			var/spawn_type = pick(spawn_types)
			new spawn_type(T)


/datum/event/infestation/announce(false_alarm)
	var/vermin_chosen = vermstring || pick("пауков", "ящериц", "мышей")
	if(!spawn_area_type)
		if(false_alarm)
			spawn_area_type = pick(spawn_areas)
		else
			log_debug("Infestation Event didn't provide an area to announce(), something is likely broken.")
			kill()

	GLOB.minor_announcement.Announce("Биосканеры фиксируют размножение [vermin_chosen] в [initial(spawn_area_type.name)]. Избавьтесь от них, прежде чем это начнет влиять на продуктивность станции.", "ВНИМАНИЕ: Неопознанные формы жизни.")
	spawn_area_type = null

#undef VERM_MICE
#undef VERM_LIZARDS
#undef VERM_SPIDERS
