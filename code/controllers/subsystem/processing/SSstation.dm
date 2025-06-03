PROCESSING_SUBSYSTEM_DEF(station)
	name = "Station"
	init_order = INIT_ORDER_STATION
	flags = SS_TICKER
	wait = 5 SECONDS
	cpu_display = SS_CPUDISPLAY_DEFAULT
	offline_implications = "Station traits will no longer process. No intervention needed at this time."

	/// A list of currently active station traits
	var/list/station_traits = list()
	/// Assoc list of trait type || assoc list of traits with weighted value. Used for picking traits from a specific category.
	var/list/selectable_traits_by_types = list(STATION_TRAIT_POSITIVE = list(), STATION_TRAIT_NEUTRAL = list(), STATION_TRAIT_NEGATIVE = list())

/datum/controller/subsystem/processing/station/Initialize()
	SetupTraits()

///Rolls for the amount of traits and adds them to the traits list
/datum/controller/subsystem/processing/station/proc/SetupTraits()

	if(fexists("data/next_traits.txt"))
		var/forced_traits_contents = file2text("data/next_traits.txt")
		fdel("data/next_traits.txt")
		var/list/temp_list = json_decode(forced_traits_contents)

		for(var/trait_text_path in temp_list)
			var/station_trait_path = text2path(trait_text_path)
			if(!ispath(station_trait_path, /datum/station_trait) || station_trait_path == /datum/station_trait)
				var/message = "Invalid station trait path [station_trait_path] was requested in the future station traits!"
				log_game(message)
				message_admins(message)
				continue

			setup_trait(station_trait_path)

		return

	if(!GLOB.configuration.gamemode.add_random_station_traits)
		return

	for(var/i in subtypesof(/datum/station_trait))
		var/datum/station_trait/trait_typepath = i

		// If forced, (probably debugging), just set it up now, keep it out of the pool.
		if(initial(trait_typepath.force))
			setup_trait(trait_typepath)
			continue

		if(initial(trait_typepath.trait_flags) & STATION_TRAIT_ABSTRACT)
			continue //Dont add abstract ones to it
		selectable_traits_by_types[initial(trait_typepath.trait_type)][trait_typepath] = initial(trait_typepath.weight)

	var/positive_trait_count = pick(20;0, 5;1, 1;2)
	var/neutral_trait_count = pick(10;0, 10;1, 3;2)
	var/negative_trait_count = pick(20;0, 5;1, 1;2)

	pick_traits(STATION_TRAIT_POSITIVE, positive_trait_count)
	pick_traits(STATION_TRAIT_NEUTRAL, neutral_trait_count)
	pick_traits(STATION_TRAIT_NEGATIVE, negative_trait_count)

///Picks traits of a specific category (e.g. bad or good) and a specified amount, then initializes them and adds them to the list of traits.
/datum/controller/subsystem/processing/station/proc/pick_traits(trait_sign, amount)
	if(!amount)
		return
	for(var/iterator in 1 to amount)
		var/datum/station_trait/trait_type = pickweight(selectable_traits_by_types[trait_sign]) //Rolls from the table for the specific trait type
		setup_trait(trait_type)

///Creates a given trait of a specific type, while also removing any blacklisted ones from the future pool.
/datum/controller/subsystem/processing/station/proc/setup_trait(datum/station_trait/trait_type)
	var/datum/station_trait/trait_instance = new trait_type()
	SSblackbox.record_feedback("text", "station_traits", 1, "[trait_type]")
	station_traits += trait_instance
	log_game("Station Trait: [trait_instance.name] chosen for this round.")
	trait_instance.blacklist += trait_instance.type
	for(var/i in trait_instance.blacklist)
		var/datum/station_trait/trait_to_remove = i
		selectable_traits_by_types[initial(trait_to_remove.trait_type)] -= trait_to_remove
