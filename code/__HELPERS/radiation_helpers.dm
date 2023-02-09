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
		/obj/item/projectile))
	var/list/processing_list = list(location)
	. = list()
	while(length(processing_list))
		var/atom/thing = processing_list[1]
		processing_list -= thing
		if(ignored_things[thing.type])
			continue
		. += thing
		if((thing.flags_2 & RAD_PROTECT_CONTENTS_2) || (SEND_SIGNAL(thing, COMSIG_ATOM_RAD_PROBE) & COMPONENT_BLOCK_RADIATION))
			continue
		processing_list += thing.contents

/proc/radiation_pulse(atom/source, intensity, range_modifier, log = FALSE, can_contaminate = TRUE)
	if(!SSradiation.can_fire)
		return
	for(var/dir in GLOB.cardinal)
		new /datum/radiation_wave(source, dir, intensity, range_modifier, can_contaminate)

	var/list/things = get_rad_contents(source) //copypasta because I don't want to put special code in waves to handle their origin
	for(var/k in 1 to length(things))
		var/atom/thing = things[k]
		if(!thing)
			continue
		thing.rad_act(intensity)

	var/static/last_huge_pulse = 0
	if(intensity > 3000 && world.time > last_huge_pulse + 200)
		last_huge_pulse = world.time
		log = TRUE
	if(log)
		var/turf/_source_T = isturf(source) ? source : get_turf(source)
		log_game("Radiation pulse with intensity: [intensity] and range modifier: [range_modifier] in [loc_name(_source_T)] ")
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
