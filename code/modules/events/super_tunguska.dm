#define ARRIVAL_MIN 210
#define ARRIVAL_MAX 300

/datum/event/super_tunguska
	name = "Super Tunguska"
	noAutoEnd = TRUE
	// nominal_severity = EVENT_LEVEL_MAJOR
	// role_weights = list(ASSIGNMENT_ENGINEERING = 4)
	// role_requirements = list(ASSIGNMENT_ENGINEERING = 5)
	/// The variant of super tunguska that is about to hit the station
	var/datum/super_tunguska_variant/variant
	/// When the super tunguska will spawn at the station Z level
	var/arrival_time
	var/launched = FALSE
	var/atom/movable/screen/alert/augury/meteor/screen_alert
	var/turf/start
	var/turf/end
	var/turf/expected_impact

/datum/event/super_tunguska/setup()
	var/type = pick(typesof(/datum/super_tunguska_variant))
	variant = new type
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
		curr_y = m * curr_x + start.y
		var/turf/curr_turf = locate(curr_x, curr_y, curr_z)
		var/area/curr_area = curr_turf.loc
		if(istype(curr_area, /area/station))
			expected_impact = curr_turf
			break

/datum/event/super_tunguska/announce(false_alarm)
	variant.announce(arrival_time, expected_impact)

/datum/event/super_tunguska/tick()
	if(arrival_time < activeFor && !launched)
		for(var/mob/dead/observer/O in GLOB.dead_mob_list)
			var/atom/movable/screen/alert/augury/meteor/A = O.throw_alert("\ref[src]_augury", /atom/movable/screen/alert/augury/meteor)
			if(A)
				screen_alert = A
		variant.launch(start, end)
		launched = TRUE
		noAutoEnd = FALSE
		endWhen = activeFor + 1000

/datum/super_tunguska_variant
	var/announcement_message = "Super Tunguska Class Meteor Detected On Colision Course With The Station"
	var/list/meteor_types = list(/obj/effect/meteor/super_tunguska)



/datum/super_tunguska_variant/proc/launch(start, end)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_meteor_targeted), meteor_types, start, end)

/datum/super_tunguska_variant/proc/announce(arrival_time, turf/expected_impact)
	var/announce_text = announcement_message + \
	"\nExpected Arrival Time [round(arrival_time / 30)]:[round((arrival_time * 2) % 60)] minutes" + \
	"\nExpected Impact Location [expected_impact.x], [expected_impact.y]"
	GLOB.major_announcement.Announce(announce_text, "Meteor Alert", new_sound = 'sound/AI/meteors.ogg')

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
	// m = dy/dx, and the deltas we use are between the starting point and map center
	var/meteor_dir = ((world.maxy / 2) - pickedstart.y) / ((world.maxx / 2) - pickedstart.x)
	// c = y - mx
	var/meteor_y_at_zero_x = pickedstart.y - (meteor_dir * pickedstart.x)
	// We start by assuming the meteor goes to the end of the map horizontaly
	var/end_x = (world.maxx / 2) > pickedstart.x ? world.maxx : 1
	// We calculate which y value that would result in and clamp it to the boundries of the map
	// y = mx + c
	var/end_y = clamp(meteor_dir * end_x + meteor_y_at_zero_x, 1, world.maxy)
	// We calculate the x value back from that clamped y value to get our final x value.
	// x = (y - c) / m
	// If the calculated y was within bounds this should be unchanged
	end_x = clamp((end_y - meteor_y_at_zero_x) / meteor_dir, 1, world.maxx)
	pickedgoal = locate(end_x, end_y, startZ)

	return list(pickedstart, pickedgoal)

#undef ARRIVAL_MIN
#undef ARRIVAL_MAX
