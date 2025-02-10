/**
  * A special GetAllContents that doesn't search past things with rad insulation
  * Components which return COMPONENT_BLOCK_RADIATION prevent further searching into that object's contents. The object itself will get returned still.
  * The ignore list makes those objects never return at all
  */
/proc/get_rad_contents(atom/location)
	var/static/list/ignored_things = typecacheof(list(
		/mob/dead,
		/mob/camera,
		/obj/effect,
		/obj/docking_port,
		/atom/movable/lighting_object,
		/obj/item/projectile,
		/obj/structure/railing // uhhhh they're highly radiation resistant, or some shit (stops stupid exploits)
	))
	var/list/processing_list = list(location)
	. = list()
	while(length(processing_list))
		var/atom/thing = processing_list[1]
		processing_list -= thing
		if(ignored_things[thing.type])
			continue
		/// 1 means no rad insulation, which means perfectly permeable, so no interaction with it directly, but the contents might be relevant.
		if(thing.rad_insulation < 1)
			. += thing
		if((thing.flags_2 & RAD_PROTECT_CONTENTS_2) || (SEND_SIGNAL(thing, COMSIG_ATOM_RAD_PROBE) & COMPONENT_BLOCK_RADIATION))
			continue
		if(ishuman(thing))
			var/mob/living/carbon/human/target_mob = thing
			if(target_mob.get_rad_protection() >= 0.99) // I would do exactly equal to 1, but you will never hit anything between 1 and .975, and byond seems to output 0.99999
				continue
		processing_list += thing.contents

/proc/get_rad_contamination_adjacent(atom/location, atom/source)
	var/static/list/ignored_things = typecacheof(list(
		/mob/camera,
		/obj/effect,
		/obj/docking_port,
		/atom/movable/lighting_object,
		/obj/item/projectile,
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
		if(thing.flags_2 & RAD_NO_CONTAMINATE_2)
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
				else if(target_mob.l_store?.UID() == source?.UID() || target_mob?.r_store.UID() == source?.UID())
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
			. += results
			if(!passed)
				continue
		. += thing

/proc/get_rad_contamination_target(atom/location, atom/source)
	var/static/list/ignored_things = typecacheof(list(
		/mob/camera,
		/obj/effect,
		/obj/docking_port,
		/atom/movable/lighting_object,
		/obj/item/projectile
	))
	var/list/processing_list = list(location) + location.contents
	. = list()
	while(length(processing_list))
		var/atom/thing = processing_list[1]
		processing_list -= thing
		if(thing && source && thing.UID() == source.UID())
			continue
		if(ignored_things[thing.type])
			continue
		if(thing.flags_2 & RAD_NO_CONTAMINATE_2)
			continue
		/// If it's a human check for rad protection on all areas
		if(ishuman(thing))
			var/mob/living/carbon/human/target_mob = thing
			var/zone = 0
			var/list/results = list()
			var/list/contaminate = list()
			var/passed = TRUE
			for(var/i = 0, i < 10, i++)
				zone = (1<<zone)
				results = target_mob.rad_contaminate_zone(zone)
				passed = results[1]
				results -= results[1]
				contaminate += results
			. += contaminate
			if(!passed)
				continue
		. += thing


/proc/radiation_pulse(atom/source, intensity, log = FALSE)
	if(!SSradiation.can_fire || intensity < RAD_BACKGROUND_RADIATION)
		return
	var/datum/radiation_wave/wave = new /datum/radiation_wave(source, intensity)

	var/turf/start_turf = source

	// Find the turf where we are
	while(!istype(start_turf, /turf))
		start_turf = start_turf.loc

	var/list/things = get_rad_contents(start_turf) // Radiate the waves origin frist

	for(var/k in 1 to length(things))
		var/atom/thing = things[k]
		if(!thing || thing.UID() == source.UID())
			continue
		wave.weight_sum = wave.weight_sum * thing.rad_act(intensity)
	// We can do this because we are on one tile so we have one weight
	wave.weights[1] = wave.weight_sum

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
		if(radiation && rad_strength < radiation.strength)
			rad_strength = radiation.strength
	return rad_strength

/// Contaminate things that share our immediate location(periodic)
/proc/contaminate_adjacent(atom/source, intensity)
	var/list/contamination_contents = get_rad_contamination_adjacent(source.loc, source)
	for(var/atom/thing in contamination_contents)
		if(!(SEND_SIGNAL(thing, COMSIG_ATOM_RAD_CONTAMINATING, intensity) & COMPONENT_BLOCK_CONTAMINATION))
			thing.AddComponent(/datum/component/radioactive, intensity, source)

/// Contaminate the contents of a target area. This is more aggressive than contaminate adjacent and does not check against individual clothes on a human(single instance)
/proc/contaminate_target(atom/target, atom/source, intensity)
	var/list/contamination_contents = get_rad_contamination_target(target, source)
	for(var/atom/thing in contamination_contents)
		if(!(SEND_SIGNAL(thing, COMSIG_ATOM_RAD_CONTAMINATING, intensity) & COMPONENT_BLOCK_CONTAMINATION))
			thing.AddComponent(/datum/component/radioactive, intensity, source)

/// Contaminate something that is hitting, picking up or otherwise touching the source(single instance)
/proc/contaminate_touch(atom/target, atom/source, intensity)
	if(target.flags_2 & RAD_NO_CONTAMINATE_2)
		return
	target.AddComponent(/datum/component/radioactive, intensity, source)
