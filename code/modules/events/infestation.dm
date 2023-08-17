#define VERM_MICE 0
#define VERM_LIZARDS 1
#define VERM_SPIDERS 2

/datum/event/infestation
	announceWhen = 10
	endWhen = 11
	var/location
	var/locstring
	var/vermin
	var/vermstring
	var/static/list/spawn_areas = list(
		/area/crew_quarters/kitchen = "the kitchen",
		/area/atmos = "atmospherics",
		/area/maintenance/incinerator = "the incinerator",
		/area/chapel/main = "the chapel",
		/area/library = "the library",
		/area/hydroponics = "hydroponics",
		/area/security/nuke_storage = "the vault",
		/area/construction = "the construction area",
		/area/storage/tech = "technical storage",
		/area/security/securearmoury = "the armory"
	)

/datum/event/infestation/start()
	var/list/turf/simulated/floor/turfs = list()
	var/area/spawn_area_type = pick(spawn_areas)
	var/locstring = spawn_areas[location]
	for(var/areapath in typesof(spawn_area_type))
		var/area/A = locate(areapath)
		if(!A)
			log_debug("Failed to locate area for infestation event!")
			kill()
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
			vermstring = "mice"
		if(VERM_LIZARDS)
			spawn_types = list(/mob/living/simple_animal/lizard)
			max_number = 6
			vermstring = "lizards"
		if(VERM_SPIDERS)
			spawn_types = list(/obj/structure/spider/spiderling)
			max_number = 3
			vermstring = "spiders"
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
	var/vermin_chosen = vermstring || pick("spiders", "lizards", "mice")
	var/location_str = locstring
	if(false_alarm)
		var/area/loc_area = pick(spawn_areas)
		location_str = spawn_areas[loc_area]

	GLOB.minor_announcement.Announce("Bioscans indicate that [vermstring] have been breeding in [locstring]. Clear them out, before this starts to affect productivity.", "Lifesign Alert")

#undef LOC_KITCHEN
#undef LOC_ATMOS
#undef LOC_INCIN
#undef LOC_CHAPEL
#undef LOC_LIBRARY
#undef LOC_HYDRO
#undef LOC_VAULT
#undef LOC_TECH

#undef VERM_MICE
#undef VERM_LIZARDS
#undef VERM_SPIDERS
