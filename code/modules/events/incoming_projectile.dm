#define ARRIVAL_MIN 210
#define ARRIVAL_MAX 300

/datum/event/incoming_projectile
	name = "Incoming Projectile"
	noAutoEnd = TRUE
	// nominal_severity = EVENT_LEVEL_MAJOR
	// role_weights = list(ASSIGNMENT_ENGINEERING = 4)
	// role_requirements = list(ASSIGNMENT_ENGINEERING = 5)
	/// The variant of projectile that is about to hit the station
	var/datum/incoming_projectile_variant/variant
	/// When the super tunguska will spawn at the station Z level
	var/arrival_time
	/// Whether we already launched the projectile
	var/launched = FALSE
	/// Alert for Dchat
	var/atom/movable/screen/alert/augury/meteor/screen_alert
	/// Start turf of our projectile
	var/turf/start
	/// Initial target of our projectile
	var/turf/end
	/// Where we expect our projectile to hit the station
	var/turf/expected_impact
	/// When to remove the alert from observers
	var/remove_alert_when = -1

/datum/event/incoming_projectile/New(datum/event_meta/EM, skeleton, force_variant)
	. = ..()
	if(force_variant)
		variant = new force_variant
	else
		var/list/types = typesof(/datum/incoming_projectile_variant/artillery)
		for(var/type in types)
			variant = new type
			if(!variant.can_roll)
				types -= type
			qdel(variant)
			variant = null

		var/type = pick(types)
		variant = new type


/datum/event/incoming_projectile/setup()
	var/list/turfs = across_map_center()
	if(length(turfs) == 2)
		start = turfs[1]
		end = turfs[2]
	// 7 to 10 minutes
	arrival_time = rand(ARRIVAL_MIN, ARRIVAL_MAX)
	if(!start || !end)
		kill()
	// Locate the estimated station impact area
	var/m = (start.y - end.y) / (start.x - end.x)
	var/curr_x = start.x
	var/curr_y = start.y
	var/curr_z = level_name_to_num(MAIN_STATION)
	var/walk_dir = start.x > (world.maxx / 2) ? -1 : 1
	for(var/dx in 0 to 255)
		curr_x += walk_dir
		if(curr_x < 1 || curr_x > 255)
			break
		curr_y = m * (curr_x - start.x) + start.y
		var/turf/curr_turf = locate(curr_x, curr_y, curr_z)
		var/area/curr_area = curr_turf.loc
		if(istype(curr_area, /area/station))
			expected_impact = curr_turf
			break

/datum/event/incoming_projectile/announce(false_alarm)
	variant.announce(arrival_time, expected_impact)

/datum/event/incoming_projectile/tick()
	if(arrival_time < activeFor && !launched)
		for(var/mob/dead/observer/O in GLOB.dead_mob_list)
			var/atom/movable/screen/alert/augury/meteor/A = O.throw_alert("\ref[src]_augury", /atom/movable/screen/alert/augury/meteor)
			if(A)
				screen_alert = A
		variant.launch(start, end)
		launched = TRUE
		noAutoEnd = FALSE
		endWhen = activeFor + 1000
		// Remove the alert after 30 seconds
		remove_alert_when = activeFor + 15
	if(activeFor == remove_alert_when)
		remove_alert()

/datum/event/incoming_projectile/proc/remove_alert()
	for(var/mob/M in GLOB.dead_mob_list)
		M.clear_alert("\ref[src]_augury")
	QDEL_NULL(screen_alert)

//MARK: Variant Datums

/datum/incoming_projectile_variant
	var/announcement_message = "Meteor detected on collision course with the station\
	\nAll engineers are instructed to fortify the projected impact area"
	var/announcement_title = "Meteor Alert"
	var/list/meteor_types = list(/obj/effect/meteor)
	var/can_roll = TRUE
	var/alert_sound
	var/siren_sound = 'sound/effects/alert2.ogg'

/datum/incoming_projectile_variant/proc/launch(start, end)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_meteor_targeted), meteor_types, start, end)

/datum/incoming_projectile_variant/proc/announce(arrival_time, turf/expected_impact)
	if(!expected_impact)
		expected_impact = locate(world.maxx / 2, world.maxy / 2, level_name_to_num(MAIN_STATION))
	var/bearing = arctan((world.maxx / 2) - expected_impact.x, (world.maxy / 2) - expected_impact.y)
	bearing = bearing < 0 ? 90 - bearing : (bearing > 90 ? 450 - bearing : 90 - bearing)
	var/announce_text = announcement_message + \
	"\nExpected Arrival Time: [time2text(station_time(world.time + (arrival_time * 2) SECONDS, TRUE), "hh:mm:ss")]" + \
	"\nExpected Impact Location: [expected_impact.loc] "+\
	"\nGPS coords: ([expected_impact.x], [expected_impact.y], [expected_impact.z])"+\
	"\nBearing: [bearing]° [bearing_to_dir_text(bearing)]"
	GLOB.major_announcement.Announce(announce_text, announcement_title, new_sound = alert_sound, new_sound2 = siren_sound)

// Super Tunguska Datum
/datum/incoming_projectile_variant/super_tunguska
	announcement_message = "Super Tunguska class meteor detected on collision course with the station\
	\nAll engineers are instructed to fortify the projected impact area"
	announcement_title = "Super Tunguska Alert"
	meteor_types = list(/obj/effect/meteor/super_tunguska)
	can_roll = FALSE

// Tunguska Datum
/datum/incoming_projectile_variant/tunguska
	announcement_message = "Tunguska class meteor detected on collision course with the station\
	\nAll engineers are instructed to fortify the projected impact area"
	announcement_title = "Tunguska Alert"
	meteor_types = list(/obj/effect/meteor/super_tunguska)
	can_roll = FALSE

// Artillery Variant
/datum/incoming_projectile_variant/artillery
	announcement_message = "Armor penetrating artillery shell detected on collision course with the station\
	\nAll engineers are instructed to fortify the projected impact area"
	announcement_title = "Artillery Misfire"
	meteor_types = list(/obj/effect/meteor/artillery)

// MARK: Helper Procs

/// Picks a random start point on an edge of the map and returns it with an endpoint such that a line between them crosses the map's center
/proc/across_map_center()
	var/turf/pickedstart
	var/turf/pickedgoal
	var/startZ = level_name_to_num(MAIN_STATION)
	var/max_i = 10 //number of tries to spawn meteor.
	while(!isspaceturf(pickedstart))
		var/startSide = pick(GLOB.cardinal)
		pickedstart = pick_edge_loc(startSide, startZ)
		max_i--
		if(max_i <= 0)
			return
	var/end_x = world.maxx - pickedstart.x + 1
	var/end_y = world.maxy - pickedstart.y + 1
	pickedgoal = locate(end_x, end_y, startZ)

	return list(pickedstart, pickedgoal)

/// Takes in a bearing in degrees and returns the appropriate text for it
/proc/bearing_to_dir_text(bearing)
	switch(bearing)
		if(348.75 to 360)
			return "N"
		if(0 to 11.25)
			return "N"
		if(11.25 to 33.75)
			return "NNE"
		if(33.75 to 56.25)
			return "NE"
		if(56.25 to 78.75)
			return "ENE"
		if(78.75 to 101.25)
			return "E"
		if(101.25 to 123.75)
			return "ESE"
		if(123.75 to 146.25)
			return "SE"
		if(146.25 to 168.75)
			return "SSE"
		if(168.75 to 191.25)
			return "S"
		if(191.25 to 213.75)
			return "SSW"
		if(213.75 to 236.25)
			return "SW"
		if(236.25 to 258.75)
			return "WSW"
		if(258.75 to 281.25)
			return "W"
		if(281.25 to 303.75)
			return "WNW"
		if(303.75 to 326.25)
			return "NW"
		if(326.25 to 348.75)
			return "NNW"


#undef ARRIVAL_MIN
#undef ARRIVAL_MAX
