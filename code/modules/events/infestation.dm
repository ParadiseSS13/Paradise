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
	// shuffle in place so we don't have do that dance where we make a copy of
	// the list, then pick and take, then do some conditional logic to make sure
	// there's still areas to choose from, etc etc, it's a small list, it's cheap
	shuffle_inplace(spawn_areas)
	for(var/spawn_area in spawn_areas)
		for(var/area_type in typesof(spawn_area))
			var/area/destination = locate(area_type)
			if(!destination)
				continue
			for(var/turf/simulated/floor/F in destination.contents)
				if(!F.is_blocked_turf())
					turfs += F
			if(length(turfs))
				spawn_area_type = area_type
				spawn_on_turfs(turfs)
				return

	log_debug("Failed to locate area for infestation event!")
	kill()

/datum/event/infestation/proc/spawn_on_turfs(list/turfs)
	var/list/spawn_types = list()
	var/max_number
	vermin = rand(0, 2)
	switch(vermin)
		if(VERM_MICE)
			spawn_types = list(/mob/living/basic/mouse/gray, /mob/living/basic/mouse/brown, /mob/living/basic/mouse/white)
			max_number = 12
			vermstring = "mice"
		if(VERM_LIZARDS)
			spawn_types = list(/mob/living/basic/lizard)
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
	if(!spawn_area_type)
		if(false_alarm)
			spawn_area_type = pick(spawn_areas)
		else
			log_debug("Infestation Event didn't provide an area to announce(), something is likely broken.")
			kill()

	GLOB.minor_announcement.Announce("Bioscans indicate that [vermin_chosen] have been breeding in \the [initial(spawn_area_type.name)]. Clear them out, before this starts to affect productivity.", "Lifesign Alert")
	spawn_area_type = null

#undef VERM_MICE
#undef VERM_LIZARDS
#undef VERM_SPIDERS
