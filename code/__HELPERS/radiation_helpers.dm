/**
  * A special GetAllContents that doesn't search past things with rad insulation
  * Components which return COMPONENT_BLOCK_RADIATION prevent further searching into that object's contents. The object itself will get returned still.
  * The ignore list makes those objects never return at all
  */
/proc/get_rad_contents(atom/location, emission_type)
	var/static/list/ignored_things = typecacheof(list(
		/mob/camera,
		/mob/dead,
		/obj/effect,
		/obj/docking_port,
		/obj/projectile,
		/atom/movable/emissive_blocker,
	))
	var/insulation = 1
	// Usually a bare turf that radiation goes straight through
	if(!length(location.contents) && isturf(location))
		switch(emission_type)
			if(ALPHA_RAD)
				insulation = location.rad_insulation_alpha
			if(BETA_RAD)
				insulation = location.rad_insulation_beta
			if(GAMMA_RAD)
				insulation = location.rad_insulation_gamma
		if(insulation >= 1 && !(location.status_traits && location.status_traits["absorb_rads"]))
			return list()
	var/list/processing_list = list(location)
	// These only get made if something turns up for them
	var/list/window_priority
	var/list/collector_priority
	var/list/other_priority
	// Walk the list instead of cutting from the front, same order
	var/position = 0
	while(position < length(processing_list))
		var/atom/thing = processing_list[++position]
		if(!thing || ignored_things[thing.type])
			continue
		switch(emission_type)
			if(ALPHA_RAD)
				insulation = thing.rad_insulation_alpha
			if(BETA_RAD)
				insulation = thing.rad_insulation_beta
			if(GAMMA_RAD)
				insulation = thing.rad_insulation_gamma
		// 1 means no rad insulation, which means perfectly permeable, so no interaction with it directly, but the contents might be relevant.
		// HAS_TRAIT is used manually here since the macros for HAS_TRAIT as well as the traits aren't being recognized here
		if(insulation < 1 || (thing.status_traits ? (thing.status_traits["absorb_rads"] ? TRUE : FALSE) : FALSE))
			if(istype(thing, /obj/structure/window))
				LAZYADD(window_priority, thing)
			else if(istype(thing, /obj/machinery/power/rad_collector))
				LAZYADD(collector_priority, thing)
			else
				LAZYADD(other_priority, thing)
		if((thing.flags_2 & RAD_PROTECT_CONTENTS_2) || (SEND_SIGNAL(thing, COMSIG_ATOM_RAD_PROBE) & COMPONENT_BLOCK_RADIATION))
			continue
		if(ishuman(thing))
			var/mob/living/carbon/human/target_mob = thing
			if(target_mob.get_rad_protection() >= 0.99) // I would do exactly equal to 1, but you will never hit anything between 1 and .975, and byond seems to output 0.99999
				continue
		if(length(thing.contents))
			processing_list += thing.contents
	// Usually only this one has anything in it
	if(!window_priority && !collector_priority)
		return other_priority || list()
	. = list()
	if(window_priority)
		. += window_priority
	if(collector_priority)
		. += collector_priority
	if(other_priority)
		. += other_priority

/proc/get_rad_contamination_adjacent(atom/location, atom/source)
	var/static/list/ignored_things = typecacheof(list(
		/mob/camera,
		/mob/dead,
		/obj/effect,
		/obj/docking_port,
		/obj/projectile,
		/atom/movable/emissive_blocker,
	))
	var/list/processing_list = list(location)
	// We want to select which clothes and items we contaminate depending on where on the human we are. We assume we are in some form of storage or on the floor otherwise.
	// If the source is a human(like a uranium golem) we just attempt to contaminate all our contents
	if(!ishuman(location) || ishuman(source))
		processing_list += location.contents
	. = list()
	for(var/atom/thing in processing_list)
		if(thing && source && thing.UID() == source.UID())
			continue
		if(ignored_things[thing.type])
			continue
		if((SEND_SIGNAL(thing, COMSIG_ATOM_RAD_CONTAMINATING) & COMPONENT_BLOCK_CONTAMINATION) || thing.flags_2 & RAD_NO_CONTAMINATE_2)
			continue
		if(ishuman(thing) || ishuman(thing.loc))
			var/mob/living/carbon/human/target_mob = ishuman(thing) ? thing : thing.loc
			var/passed = TRUE
			var/zone
			var/pocket = FALSE
			// Check if we hold the contamination source, have it in our pockets or in our belts or if it's inside us
			if(target_mob.UID() == location.UID())
				// If it's in our hands check if it can permeate our gloves
				if((source && (target_mob.r_hand && target_mob.r_hand.UID() == source.UID()) || (target_mob.l_hand && target_mob.l_hand.UID() == source.UID())))
					zone = HANDS

				// If it's in our pockets check against our jumpsuit only
				else if((target_mob?.l_store && target_mob?.l_store?.UID() == source?.UID()) || (target_mob?.r_store && target_mob?.r_store.UID() == source?.UID()))
					zone = LOWER_TORSO
					pocket = TRUE

			// If it's on our belt check against both our outer layer and jumpsuit
			if(location.loc.UID() == target_mob.UID() && istype(location, /obj/item/storage/belt))
				zone = LOWER_TORSO

			// If on the floor check if it can permeate our shoes
			if(istype(location, /turf/))
				zone = FEET

			// zone being unchanged here means the item is inside the mob
			var/list/results = target_mob.rad_contaminate_zone(zone, pocket)
			passed = results[1]
			results -= results[1]
			. |= results
			if(!passed)
				continue
		. += thing

/proc/get_rad_contamination_target(atom/location, atom/source)
	var/static/list/ignored_things = typecacheof(list(
		/mob/camera,
		/mob/dead,
		/obj/effect,
		/obj/docking_port,
		/obj/projectile,
		/atom/movable/emissive_blocker,
	))
	var/list/processing_list = list(location) + location.contents
	. = list()
	while(length(processing_list))
		var/atom/thing = processing_list[1]
		processing_list -= thing
		if(thing?.UID() == source?.UID())
			continue
		if(ignored_things[thing.type])
			continue
		if((SEND_SIGNAL(thing, COMSIG_ATOM_RAD_CONTAMINATING) & COMPONENT_BLOCK_CONTAMINATION) || thing.flags_2 & RAD_NO_CONTAMINATE_2)
			continue
		/// If it's a human check for rad protection on all areas
		if(ishuman(thing))
			var/mob/living/carbon/human/target_mob = thing
			var/zone = 0
			var/list/contaminate = list()
			var/list/results = list()
			var/passed = TRUE
			for(var/i in 0 to 9)
				zone = (1<<i)
				results = target_mob.rad_contaminate_zone(zone)
				passed = results[1] || passed
				results -= results[1]
				contaminate |= results
			. |= contaminate
			if(!passed)
				continue
			for(var/atom/human_content in target_mob.contents)
				if(!istype(human_content, /obj/item/clothing))
					. |= human_content
		. += thing


/proc/radiation_pulse(atom/source, intensity, emission_type = ALPHA_RAD, log = FALSE)
	if(!SSradiation.can_fire || intensity < RAD_BACKGROUND_RADIATION)
		return
	var/turf/start_turf = source

	// Find the turf where we are
	while(!istype(start_turf, /turf))
		start_turf = start_turf.loc

	var/list/things = get_rad_contents(start_turf, emission_type) // Radiate the waves origin frist
	// Adjust the weights so the source tile doesn't get all the rads
	var/weight = RAD_SOURCE_WEIGHT
	for(var/atom/thing in things)
		if(thing.UID() == source.UID())
			// Don't block our own radiation
			source.base_rad_act(source ,intensity, emission_type)
		else
			weight = weight * thing.base_rad_act(source ,intensity * weight, emission_type)
	// Add the rest of the weight back
	weight += (1 - RAD_SOURCE_WEIGHT)
	// It spreads out from here a step each time SSradiation fires
	SSradiation.start_wave(new /datum/radiation_wave(source, intensity, emission_type), start_turf, weight)

	var/static/last_huge_pulse = 0
	if(intensity > 12000 && world.time > last_huge_pulse + 200)
		last_huge_pulse = world.time
		log = TRUE
	if(log)
		var/turf/_source_T = isturf(source) ? source : get_turf(source)
		log_game("Radiation pulse with intensity: [intensity] in [loc_name(_source_T)] ")
	return TRUE

/proc/get_rad_contamination(atom/location)
	var/rad_strength = 0
	for(var/i in get_rad_contents(location)) // Yes it's intentional that you can't detect radioactive things under rad protection. Gives traitors a way to hide their glowing green rocks.
		var/atom/thing = i
		if(!thing)
			continue
		var/datum/component/radioactive/radiation = thing.GetComponent(/datum/component/radioactive)
		if(radiation && rad_strength < (radiation.alpha_strength + radiation.beta_strength + radiation.gamma_strength))
			rad_strength = (radiation.alpha_strength + radiation.beta_strength + radiation.gamma_strength)
	return rad_strength

/// Contaminate things that share our immediate location(periodic)
/proc/contaminate_adjacent(atom/source, intensity, emission_type)
	// If the source is a turf it is it's location
	var/atom/location = isturf(source) ? source : source.loc
	// Are we on a turf or in something else
	var/is_source_on_turf = isturf(location)
	var/contamination_chance = is_source_on_turf ? CONTAMINATION_CHANCE_TURF : CONTAMINATION_CHANCE_OTHER
	var/list/contamination_contents = get_rad_contamination_adjacent(location, source)
	for(var/atom/thing in contamination_contents)
		if(prob(contamination_chance))
			thing.AddComponent(/datum/component/radioactive, intensity, source, emission_type)

/// Contaminate the contents of a target(single instance)
/proc/contaminate_target(atom/target, atom/source, intensity, emission_type)
	var/list/contamination_contents = get_rad_contamination_target(target, source)
	for(var/atom/thing in contamination_contents)
		thing.AddComponent(/datum/component/radioactive, intensity, source, emission_type)
